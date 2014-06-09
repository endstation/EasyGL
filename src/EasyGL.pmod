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
    glOrtho( 0.0, (float) window_w, (float) window_h, 0.0, -1.0, 1.0 );
    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glClearColor( @clear_color );

    initialized = 1;

} // set_up()
    
// --------------------------------------------------

void draw_box( Rectf r, Image.Color.Color c, void|float line_w )
{
    glLineWidth( line_w || 1.0 );
    glEnable( GL_LINE_SMOOTH );
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_LINE_LOOP );
        glVertex( r->x0, r->y0, 0.0 );
        glVertex( r->x1, r->y0, 0.0 );
        glVertex( r->x1, r->y1, 0.0 );
        glVertex( r->x0, r->y1, 0.0 );
    glEnd();

} // draw_box()

// --------------------------------------------------

void fill_box( Rectf r, Image.Color.Color c )
{
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_QUADS );
        glVertex( r->x0, r->y0, 0.0 );
        glVertex( r->x1, r->y0, 0.0 );
        glVertex( r->x1, r->y1, 0.0 );
        glVertex( r->x0, r->y1, 0.0 );
    glEnd();

} // draw_box()

// --------------------------------------------------

void draw_line( Rectf from_to, 
                Image.Color.Color c, 
                void|float line_w )
{
    glLineWidth( line_w || 1.0 );
    glEnable( GL_LINE_SMOOTH );
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_LINES );
        glVertex( from_to->x0, from_to->y0 );
        glVertex( from_to->x1, from_to->y1 );
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

// Similar to SDL.Rect, except it uses floats rather than ints and holds the
// corners of the rectangle rather than width and height.
class Rectf
{
    public float x0;
    public float y0;
    public float x1;
    public float y1;

    // Since these are floats, not much point checking for equality (?!).
    public int intersects( Rectf rhs )
    {
        return x0 >= rhs->x0 - (x1 - x0) 
                && x0 <= rhs->x0 + (rhs->x1 - rhs->x0)
                && y0 >= rhs->y0 - (y1 - y0)
                && y0 <= rhs->y0 + (rhs->y1 - rhs->y0);

    } // intersects()

    public int intersects_x( Rectf rhs )
    {
        return x0 >= rhs->x0 - (x1 - x0)
                && x0 <= rhs->x0 + (rhs->x1 - rhs->x0);

    } // intersects_x()

    public int intersects_y( Rectf rhs )
    {
        return y0 >= rhs->y0 - (y1 - y0)
                && y0 <= rhs->y0 + (rhs->y1 - rhs->y0);

    } // intersects_y()

    public Rectf copy()
    {
        return Rectf( x0, y0, x1, y1 );

    } // copy()

    protected void create( void|float x0_p,
                           void|float y0_p,
                           void|float x1_p,
                           void|float y1_p )
    {
        x0 = x0_p || 0.0;
        y0 = y0_p || 0.0;
        x1 = x1_p || 0.0;
        y1 = y1_p || 0.0;

    } // create()

} // class Rectf

// --------------------------------------------------

class Texture
{ 
    public void draw( int index,
                      Rectf dest, 
                      float opacity, 
                      void|float rotation )
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, names[index] );
        glColor( 1.0, 1.0, 1.0, opacity );

        glMatrixMode( GL_MODELVIEW );
        glPushMatrix();
        glLoadIdentity();
        glTranslate( dest->x0 + half_texture_w, dest->y0 + half_texture_h,
                0.0 );
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
        
    public void draw_section( int index,
                              Rectf dest, 
                              Rectf src, 
                              float alpha )
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, names[index] );
        glColor( 1.0, 1.0, 1.0, alpha );

        float x1 = src->x0 / texture_w;
        float x2 = src->x1 / texture_w;
        float y1 = src->y0 / texture_h;
        float y2 = src->y1 / texture_h;
        dest->x1 = dest->x0 + src->x1 - src->x0;
        dest->y1 = dest->y0 + src->y1 - src->y0;
                    
        glBegin( GL_QUADS );
            // top-left
            glTexCoord( x1, y1 );
            glVertex( dest->x0, dest->y0 );
            // top-right
            glTexCoord( x2, y1 );
            glVertex( dest->x1, dest->y0 );
            // bottom-right
            glTexCoord( x2, y2 );
            glVertex( dest->x1, dest->y1 );
            // bottom-left
            glTexCoord( x1, y2 );
            glVertex( dest->x0, dest->y1 );
        glEnd();

        glDisable( GL_TEXTURE_2D );

    } // draw_section()

    public void draw_scaled( int index,
                             Rectf dest,
                             float opacity,
                             float scale_factor,
                             void|float rotation )                   
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, names[0] );
        glColor( 1.0, 1.0, 1.0, opacity );

        float half_scaled_w = texture_w * scale_factor / 2.0;
        float half_scaled_h = texture_h * scale_factor / 2.0;

        glMatrixMode( GL_MODELVIEW );
        glPushMatrix();
        glLoadIdentity();
        glTranslate( dest->x0 + half_scaled_w, dest->y0 + half_scaled_h, 0.0 );
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

    public void replace_image( object image )
    {
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, names[0] );
        glTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, (["rgb":image]) );
        glDisable( GL_TEXTURE_2D );

    } // replace_image()

    public void delete()
    {
        glDeleteTextures( names[0] );
    } // delete()

    // To prepare a PNG image, for example:
    //     string data = Image.load_file( "mypic.png" );
    //     mapping m = Image.PNG._decode( data );
    //     .EasyGL.Texture tex = .EasyGL.Texture( ({m}) );
    // All images should be exactly the same dimensions and format (i.e. all
    // with an alpha channel or all without an alpha channel).
    protected void create( array(mapping) images, 
                           void|array(int) rgb_bg )
    {
        // TODO: check that EasyGL has been initialized!
        // TODO: check array size!
        rgb_bg = rgb_bg || ({0,0,0});

        image_w = images[0]["image"]->xsize();
        image_h = images[0]["image"]->ysize();
        texture_w = next_power_of_two( image_w );
        texture_h = next_power_of_two( image_h );
        half_texture_w = texture_w / 2;
        half_texture_h = texture_h / 2;

        foreach ( images, mapping(string:mixed) m )
        {
            // Do we need to resize?
            if ( image_w < texture_w || image_h < texture_h )
            {
                m["image"] = m["image"]->copy( 0, 0, texture_w - 1, 
                        texture_h - 1, @rgb_bg );
                if ( m["alpha"] )
                {
                    m["alpha"] = m["alpha"]->copy( 0, 0, texture_w - 1, 
                            texture_h - 1 );
                } // if
            } // if

            int name = glGenTextures( 1 )[0];
            glBindTexture( GL_TEXTURE_2D, name );
            names = Array.push( names, name );
            glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
            glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
            glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP );
            glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP );

            if ( m["alpha"] )
            {
                glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 0, 
                        (["rgb":m["image"], "alpha":m["alpha"]]) );
            }
            else
            {
                glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, 
                        (["rgb":m["image"]]) );
            } // if ... else
        } // foreach

    } // create()

    private array(int) names = ({});
    private int image_w;
    private int image_h;
    private int texture_w;
    private int texture_h;
    private int half_texture_w;
    private int half_texture_h;

} // class Texture

