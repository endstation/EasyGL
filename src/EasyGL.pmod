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


int initialized = 0;


// --------------------------------------------------

// Sets up an OpenGL window of the given size.  You must also specify the r,g,b
// values for the color that will be used to clear the screen (with a call to
// glClear( GL_COLOR_BUFFER_BIT )).  By default, the video, audio and joystick
// subsystems will be initialized and double buffering will be turned on.
void set_up( int window_w, 
             int window_h,
             array(float) clear_color )
{
    // TODO: check array size!

    SDL.init( SDL.INIT_VIDEO|SDL.INIT_AUDIO|SDL.INIT_JOYSTICK );
    atexit( SDL.quit );
    SDL.gl_set_attribute( SDL.GL_DOUBLEBUFFER, 1 );
    SDL.set_video_mode( window_w, window_h, 0, SDL.OPENGL );
    
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    gluOrtho2D( 0.0, (float) window_w, (float) window_h, 0.0 );
    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glClearColor( @clear_color );

    initialized = 1;

} // set_up()
    
// --------------------------------------------------

void draw_box( SDL.Rect r, Image.Color.Color c, void|float line_w )
{
    glLineWidth( line_w || 1.0 );
    glEnable( GL_LINE_SMOOTH );
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_LINE_LOOP );
        glVertex( r->x, r->y, 0 );
        glVertex( r->x + r->w, r->y, 0 );
        glVertex( r->x + r->w, r->y + r->h, 0 );
        glVertex( r->x, r->y + r->h, 0 );
    glEnd();

} // draw_box()

// --------------------------------------------------

void fill_box( SDL.Rect r, Image.Color.Color c )
{
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_QUADS );
        glVertex( r->x, r->y, 0 );
        glVertex( r->x + r->w, r->y, 0 );
        glVertex( r->x + r->w, r->y + r->h, 0 );
        glVertex( r->x, r->y + r->h, 0 );
    glEnd();

} // draw_box()

// --------------------------------------------------

void draw_line( SDL.Rect from, 
                SDL.Rect to, 
                Image.Color.Color c, 
                void|float line_w )
{
    glLineWidth( line_w || 1.0 );
    glEnable( GL_LINE_SMOOTH );
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_LINES );
        glVertex( from->x, from->y, 0 );
        glVertex( to->x, to->y, 0 );
    glEnd();

} // draw_line()

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

class Texture
{ 
    public void draw( SDL.Rect dest, float opacity, void|float rotation )
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, name );
        glColor( 1.0, 1.0, 1.0, opacity );

        glMatrixMode( GL_MODELVIEW );
        glPushMatrix();
        glLoadIdentity();
        glTranslate( dest->x + half_texture_w, dest->y + half_texture_h, 0.0 );
        if ( rotation )
        {
            glRotate( rotation, 0.0, 0.0, 1.0 );
        } // if

        glBegin(GL_QUADS);
            // top-left
            glTexCoord( 0.0, 0.0 );
            glVertex( -half_texture_w, -half_texture_h );
            // top-right
            glTexCoord( 1.0, 0.0 ); 
            glVertex( half_texture_w, -half_texture_h );
            // bottom-right
            glTexCoord( 1.0, 1.0 );
            glVertex( half_texture_w, half_texture_h );
            // bottom-left
            glTexCoord( 0.0, 1.0 );
            glVertex( -half_texture_w, half_texture_h );
        glEnd();

        glPopMatrix();
        glDisable( GL_TEXTURE_2D );

    } // draw()
        
    public void draw_section( SDL.Rect dest, SDL.Rect src, float alpha )
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, name );
        glColor( 1.0, 1.0, 1.0, alpha );

        float x1   = ((float) src->x) / texture_w;
        float x2   = (src->x + src->w - 1.0) / texture_w;
        float y1   = ((float) src->y) / texture_h;
        float y2   = (src->y + src->h - 1.0) / texture_h;
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

    } // draw_section()

    public void draw_scaled( SDL.Rect dest,
                             float opacity,
                             float scale_factor,
                             void|float rotation )                   
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, name );
        glColor( 1.0, 1.0, 1.0, opacity );

        float half_scaled_w = texture_w * scale_factor / 2.0;
        float half_scaled_h = texture_h * scale_factor / 2.0;

        glMatrixMode( GL_MODELVIEW );
        glPushMatrix();
        glLoadIdentity();
        glTranslate( dest->x + half_scaled_w, dest->y + half_scaled_h, 0.0 );
        if ( rotation )
        {
            glRotate( rotation, 0.0, 0.0, 1.0 );
        } // if

        glBegin(GL_QUADS);
            // top-left
            glTexCoord( 0.0, 0.0 );
            glVertex( -half_scaled_w, -half_scaled_h );
            // top-right
            glTexCoord( 1.0, 0.0 ); 
            glVertex( half_scaled_w, -half_scaled_h );
            // bottom-right
            glTexCoord( 1.0, 1.0 );
            glVertex( half_scaled_w, half_scaled_h );
            // bottom-left
            glTexCoord( 0.0, 1.0 );
            glVertex( -half_scaled_w, half_scaled_h );
        glEnd();

        glPopMatrix();
        glDisable( GL_TEXTURE_2D );

    } // draw_scaled()

    public int get_image_w() { return image_w; }
    public int get_image_h() { return image_h; }

    // To prepare a PNG image, for example:
    // string data = Image.load_file( "mypic.png" );
    // mapping m = Image.PNG._decode( data );
    // .EasyGL.Texture tex = .EasyGL.Texture( m["image"], m["alpha"] );
    protected void create( Image.Image image, 
                           void|Image.Image alpha, 
                           void|array(int) rgb_bg )
    {
        // TODO: check that EasyGL has been initialized!
        // TODO: check array size!
        rgb_bg = rgb_bg || ({0,0,0});

        image_w = image->xsize();
        image_h = image->ysize();
        texture_w = next_power_of_two( image_w );
        texture_h = next_power_of_two( image_h );
        half_texture_w = texture_w / 2;
        half_texture_h = texture_h / 2;

        // Do we need to resize?
        if ( image_w < texture_w || image_h < texture_h )
        {
            image = image->copy( 0, 0, texture_w - 1, texture_h - 1, @rgb_bg );
            if ( alpha )
            {
                alpha = alpha->copy( 0, 0, texture_w - 1, texture_h - 1 );
            } // if
        } // if

        name = glGenTextures( 1 )[0];
        glBindTexture( GL_TEXTURE_2D, name );
        glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP );
        glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP );

        if ( alpha )
        {
            glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 0, 
                    (["rgb":image, "alpha":alpha]) );
        }
        else
        {
            glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, (["rgb":image]) );
        } // if ... else

    } // create()

    private int name;
    private int image_w;
    private int image_h;
    private int texture_w;
    private int texture_h;
    private int half_texture_w;
    private int half_texture_h;

} // class Texture

