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


// --------------------------------------------------
// FUNCTIONS ----------------------------------------
// --------------------------------------------------

// Sets up an OpenGL window of the given size.  You must also specify the r,g,b
// values for the color that will be used to clear the screen (with a call to
// glClear( GL_COLOR_BUFFER_BIT )).  By default, the video, audio and joystick
// subsystems will be initialized and double buffering will be turned on.
void set_up( int window_w, int window_h, array(float) clear_color )
{
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

} // set_up()

// --------------------------------------------------

// Draw the outline of a box with the given attributes.
void draw_box( .EasyGL.Rectf r, Image.Color.Color c, void|float line_w )
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

// Draw a box filled in with the given colour.
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

// Draw a line from x0,y0 to x1,y1 of the given colour and width.
void draw_line( 
        Rectf from_to, 
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
// CLASSES ------------------------------------------
// --------------------------------------------------

class Texture 
{
// --------------------------------------------------
// PUBLIC DATA


// --------------------------------------------------
// PUBLIC METHODS
public void draw( 
        int index,
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

// --------------------------------------------------

public void draw_section( 
        int index,
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

// --------------------------------------------------

public void draw_scaled( 
        int index,
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

// --------------------------------------------------

public int get_image_w() { return image_w; }
public int get_image_h() { return image_h; }




// --------------------------------------------------
// PROTECTED DATA


// --------------------------------------------------
// PROTECTED METHODS
// 'images' is either an array of filenames (strings) or an array of decodings
// (mappings) - returned from e.g. Image.ANY._decode().  All images should be
// the same format and have the same dimensions.
// If your images don't have an alpha channel and dimensions aren't powers of 2,
// image will be extended and extra pixels will be black by default.  If you
// want them to be a different colour, specify rgb values in a 3-element array
// as 2nd argument.
protected void create( array(mapping|string) images, 
                       void|array(int) rgb_bg )
{
    // TODO: check that EasyGL has been initialized!
    // TODO: check array sizes!

    if ( stringp(images[0]) )
    {
        images = files_to_mappings( images );
    } // if

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




// --------------------------------------------------
// PRIVATE DATA
private array(int) names = ({});
private int image_w;
private int image_h;
private int texture_w;
private int texture_h;
private int half_texture_w;
private int half_texture_h;


// --------------------------------------------------
// PRIVATE METHODS
private array(mapping) files_to_mappings( array(string) files )
{
    array(mapping) ms = ({});

    foreach ( files, string my_file )
    {
        string data = Image.load_file( my_file );
        mapping m = Image.ANY._decode( data );
        ms = Array.push( ms, m );
    } // foreach

    return ms;

} // files_to_mappings()

// --------------------------------------------------

private int next_power_of_two( int n )
{
    int x = 2;

    while ( x < n )
    {
        x *= 2;
    } // while

    return x;

} // next_power_of_two()

// --------------------------------------------------
} // class Texture


class SFont
{
// --------------------------------------------------
// PUBLIC METHODS

public void draw( string text, Rectf dest, void|float opacity ) 
{
    opacity = opacity || 1.0;

    int len = sizeof( text );
    for ( int i = 0; i < len; ++i )
    {
        int index = text[i] - BEGIN_ASCII;
        if ( index < 0 || index >= NUM_FONT_CHARS )
        {
            dest->x0 += spacing;
        }
        else
        {
            my_font_chars[index]->draw( 0, dest, opacity );
            dest->x0 += my_font_chars[index]->get_image_w();
        } // if ... else
    } // for

} // draw()

// --------------------------------------------------

public void draw_center( string text,
                         Rectf dest,
                         int screen_width,
                         void|float opacity )
{
    int tw = text_width( text );
    dest->x0 = (screen_width - tw) / 2.0;
    draw( text, dest, opacity );
    
} // draw_center()

// --------------------------------------------------

public int text_width( string text )
{
    int width = 0;
    int len = sizeof( text );
    for ( int i = 0; i < len; ++i )
    {
        int index = text[i] - BEGIN_ASCII;
        if ( index < 0 || index >= NUM_FONT_CHARS )
        {
            width += spacing;
        }
        else
        {
            width += my_font_chars[index]->get_image_w();
        } // if ... else
    } // for
    
    return width;
    
} // text_width()

// --------------------------------------------------

public int text_height() { return font_height; }

// --------------------------------------------------

public int get_spacing() { return spacing; }

// --------------------------------------------------
 
public void set_spacing( void|int spc )
{
    if ( spc )    // if argument is supplied...
    {
        if ( spc < MIN_SPACING )
        {
            spacing = MIN_SPACING;
        }
        else if ( spc > MAX_SPACING )
        {
            spacing = MAX_SPACING;
        }
        else
        {
            spacing = spc;
        } // if ... else
    }
    else
    {
        spacing = DEFAULT_SPACING;
    } // if ... else
    
} // set_spacing()    




// --------------------------------------------------
// PROTECTED METHODS

protected void create( string image_file )
{
    string my_data = Image.load_file( image_file );
    mapping m = Image.PNG._decode( my_data );
    Image.Image my_image = m["image"];
    Image.Image my_alpha = m["alpha"];
    // Lose 1 pixel from height - that's the top row with the pink spacers.
    font_height = my_image->ysize() - 1;
    
    int x     = 0;
    int begin = 0;
    int end   = 0;
    array(int) pink = ({ 255, 0, 255 });
    
    while ( x < my_image->xsize() )
    {
        if ( !equal(my_image->getpixel(x, 0), pink) )
        {
            // First clear pixel found - this is the start of a character.
            begin = x;
            
            do
            {
                ++x;
            } while ( !equal(my_image->getpixel(x, 0), pink) );
            end = x;    // index of first pink pixel after character
            
            Image.Image section = my_image->copy( begin, 1, 
                                                  end - 1, font_height );
            Image.Image section_a = my_alpha->copy( begin, 1, 
                                                    end - 1, font_height );
            object o = Texture( 
                    ({ (["image":section,"alpha":section_a]) }) );

            my_font_chars += ({ o });
        } // if 
        ++x;
    } // while

} // create()




// --------------------------------------------------
// PRIVATE DATA

private constant DEFAULT_SPACING = 5;
private constant MIN_SPACING = 4;
private constant MAX_SPACING = 20;
private constant BEGIN_ASCII = 33;
private constant NUM_FONT_CHARS = 94;
private array(Texture) my_font_chars = ({});
private int spacing = DEFAULT_SPACING;
private int font_height;
// --------------------------------------------------
} // class SFont


class Rectf
{
// --------------------------------------------------
// PUBLIC DATA
public float x0;
public float y0;
public float x1;
public float y1;


// --------------------------------------------------
// PUBLIC METHODS




// --------------------------------------------------
// PROTECTED DATA


// --------------------------------------------------
// PROTECTED METHODS
protected void create( 
        void|float x0_p,
        void|float y0_p,
        void|float x1_p,
        void|float y1_p )
{
    x0 = x0_p || 0.0;
    y0 = y0_p || 0.0;
    x1 = x1_p || 0.0;
    y1 = y1_p || 0.0;

} // create()




// --------------------------------------------------
// PRIVATE DATA


// --------------------------------------------------
// PRIVATE METHODS
// --------------------------------------------------
} // class Rectf

