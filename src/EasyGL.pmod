// $Id: EasyGL.pmod 12 2011-02-20 09:48:09Z mafferyew@googlemail.com $

// EasyGL
// Copyright 2011 Matthew Clarke <pclar7@yahoo.co.uk>

// This file is part of EasyGL.
//
// EasyGL is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// EasyGL is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with EasyGL.  If not, see <http://www.gnu.org/licenses/>.




import GL;
import GLU;


int next_texture_name = 0;

// --------------------------------------------------

// Sets up an OpenGL window of the given size.  You must also specify the r,g,b
// values for the color that will be used to clear the screen (with a call to
// glClear( GL_COLOR_BUFFER_BIT )).  By default, the video, audio and joystick
// subsystems will be initialized and double buffering will be turned on.
void set_up( int window_w, 
             int window_h,
             float clear_color_r,
             float clear_color_g,
             float clear_color_b )
{
    SDL.init( SDL.INIT_VIDEO|SDL.INIT_AUDIO|SDL.INIT_JOYSTICK );
    atexit( SDL.quit );
    SDL.gl_set_attribute( SDL.GL_DOUBLEBUFFER, 1 );
    SDL.set_video_mode( window_w, window_h, 0, SDL.OPENGL );
    
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    gluOrtho2D( 0.0, (float) window_w, (float) window_h, 0.0 );
    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glClearColor( clear_color_r, clear_color_g, clear_color_b );

} // set_up()
    
// --------------------------------------------------

object texture_from_file( string filename )
{
    string data = Image.load_file(filename);
    mapping decoded;
    if ( has_suffix(filename, "png") )
    {
        decoded = Image.PNG._decode(data);
    }
    else if ( has_suffix(filename, "svg") )
    {
        decoded = Image.SVG._decode(data);
    }
    else if ( has_suffix(filename, "jpg") )
    {
        decoded = Image.JPEG._decode(data);
    } // if ... else

    return texture_from_image( decoded["image"], decoded["alpha"] );

} // texture_from_file()

// --------------------------------------------------

object texture_from_image( Image.Image img_rgb, void|Image.Image img_alpha )
{
    int original_w = img_rgb->xsize();
    int original_h = img_rgb->ysize();
    int pow_w = next_power_of_two( original_w );
    int pow_h = next_power_of_two( original_h );
    if ( original_w < pow_w || original_h < pow_h )
    {
        // Need to resize.
        img_rgb = img_rgb->copy( 0, 0, pow_w - 1, pow_h - 1 );
        if ( img_alpha )
        {
            img_alpha = img_alpha->copy( 0, 0, pow_w - 1, pow_h - 1 );
        } // if
    } // if

    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, next_texture_name );
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP );
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP );

    if ( img_alpha )
    {
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 0, 
                      (["rgb":img_rgb, "alpha":img_alpha]) );
    }
    else
    {
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, (["rgb":img_rgb]) );
    } // if ... else
    glDisable( GL_TEXTURE_2D );

    Texture_data td = Texture_data( next_texture_name,
                                    original_w, original_h,
                                    pow_w, pow_h );
    ++next_texture_name;
    return td;

} // texture_from_image()

// --------------------------------------------------

void draw_texture( object tex_data,
                   SDL.Rect dest,
                   float opacity,
                   void|float rotation )                   
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, tex_data->texture_name );
    glColor( 1.0, 1.0, 1.0, opacity );

    if ( rotation )
    {
        glMatrixMode( GL_TEXTURE );
        glPushMatrix();
        glLoadIdentity();
        glTranslate( 0.5, 0.5, 0.0 );
        glRotate( rotation, 0.0, 0.0, 1.0 );
        glTranslate( -0.5, -0.5, 0.0 );
        glMatrixMode( GL_MODELVIEW );
    } // if

    glBegin(GL_QUADS);
        // top-left
        glTexCoord( 0.0, 0.0 );
        glVertex( dest->x, dest->y );
        // top-right
        glTexCoord( 1.0, 0.0 ); 
        glVertex( dest->x + tex_data->texture_w - 1, dest->y );
        // bottom-right
        glTexCoord( 1.0, 1.0 );
        glVertex( dest->x + tex_data->texture_w - 1,
                  dest->y + tex_data->texture_h - 1 );
        // bottom-left
        glTexCoord( 0.0, 1.0 );
        glVertex( dest->x, dest->y + tex_data->texture_h - 1 );
    glEnd();

    if ( rotation )
    {
        glMatrixMode( GL_TEXTURE );
        glPopMatrix();
        glMatrixMode( GL_MODELVIEW );
    } // if

    glDisable( GL_TEXTURE_2D );

} // draw_texture()

// --------------------------------------------------

void draw_texture_section( object tex_data,
                           SDL.Rect dest,
                           SDL.Rect src,
                           float alpha )
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, tex_data->texture_name );
    glColor( 1.0, 1.0, 1.0, alpha );

    float x1   = ((float) src->x) / tex_data->texture_w;
    float x2   = (src->x + src->w - 1.0) / tex_data->texture_w;
    float y1   = ((float) src->y) / tex_data->texture_h;
    float y2   = (src->y + src->h - 1.0) / tex_data->texture_h;
    int quad_w = src->w;
    int quad_h = src->h;
                    
    glBegin( GL_QUADS );
        // top-left
        glTexCoord( x1, y1 );
        glVertex( dest->x, dest->y );
        // top-right
        glTexCoord( x2, y1 );
        glVertex( dest->x + quad_w, dest->y );
        // bottom-right
        glTexCoord( x2, y2 );
        glVertex( dest->x + quad_w, dest->y + quad_h );
        // bottom-left
        glTexCoord( x1, y2 );
        glVertex( dest->x, dest->y + quad_h );
    glEnd();

    glDisable( GL_TEXTURE_2D );

} // draw_texture_section()

// --------------------------------------------------

// If you don't need texture scaling, just call draw_texture() for a tiny
// bit of extra speed.
void draw_texture_scaled( object tex_data,
                          SDL.Rect dest,
                          float opacity,
                          float scale_factor,
                          void|float rotation )                   
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, tex_data->texture_name );
    glColor( 1.0, 1.0, 1.0, opacity );

    if ( rotation )
    {
        glMatrixMode( GL_TEXTURE );
        glPushMatrix();
        glLoadIdentity();
        glTranslate( 0.5, 0.5, 0.0 );
        glRotate( rotation, 0.0, 0.0, 1.0 );
        glTranslate( -0.5, -0.5, 0.0 );
        glMatrixMode( GL_MODELVIEW );
    } // if

    glBegin(GL_QUADS);
        // top-left
        glTexCoord( 0.0, 0.0 );
        glVertex( dest->x, dest->y );
        // top-right
        glTexCoord( 1.0, 0.0 ); 
        glVertex( dest->x + ((tex_data->texture_w - 1) * scale_factor), 
                  dest->y );
        // bottom-right
        glTexCoord( 1.0, 1.0 );
        glVertex( dest->x + ((tex_data->texture_w - 1) * scale_factor),
                  dest->y + ((tex_data->texture_h - 1) * scale_factor) );
        // bottom-left
        glTexCoord( 0.0, 1.0 );
        glVertex( dest->x, 
                  dest->y + ((tex_data->texture_h - 1) * scale_factor) );
    glEnd();

    if ( rotation )
    {
        glMatrixMode( GL_TEXTURE );
        glPopMatrix();
        glMatrixMode( GL_MODELVIEW );
    } // if

    glDisable( GL_TEXTURE_2D );

} // draw_texture_scaled()

// --------------------------------------------------

int next_power_of_two( int n )
{
    int x = 2;
    while ( x < n )
    {
        x *= 2;
    } // while

    return x;

} // next_power_of_two()

// --------------------------------------------------

class Texture_data
{
    int   texture_name;
    int   original_w;
    int   original_h;
    int   texture_w;
    int   texture_h;

    void create( int texture_name_p,
                 int original_w_p,
                 int original_h_p,
                 int texture_w_p,
                 int texture_h_p )
    {
        texture_name = texture_name_p;
        original_w   = original_w_p;
        original_h   = original_h_p;
        texture_w    = texture_w_p;
        texture_h    = texture_h_p;

    } // create()

} // class Texture_data

