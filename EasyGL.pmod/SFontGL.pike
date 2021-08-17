// EasyGL
// Copyright 2011-2021 Matthew Clarke <pclar7@yahoo.co.uk>

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

// N.B. This code is adapted from Karl Bartel's SFont.  
// See <http://www.linux-games.com/sfont/> for details.




#pragma strict_types


// --------------------------------------------------
// PUBLIC METHODS
// FIXME: this method alters 'dest'.  Would be best to make this a 'dummy'
// method that makes a copy of that Rectf and then calls a private method
// that does all the work (and calls itself recursively) on that copy.
// See also draw_center().
public void draw(string text, EasyGL.Rectf dest, void|float opacity) 
{
    opacity = opacity || 1.0;

    int len = sizeof(text);

    m_tex->start_draw();
    for (int i = 0; i < len; ++i)
    {
        int index = text[i] - BEGIN_ASCII;
        if (index < 0 || index >= NUM_FONT_CHARS)
        {
            dest->x += m_spacing;
        }
        else
        {
            m_tex->draw_section_no_bind(dest, m_char_rects[index], opacity);
            dest->x += (m_char_rects[index]->w);
        } // if ... else
    } // for
    m_tex->end_draw();

} // draw()

// --------------------------------------------------

public void draw_center( string text,
                         EasyGL.Rectf dest,
                         int screen_width,
                         void|float opacity )
{
    int tw = text_width( text );
    dest->x = (screen_width - tw) / 2.0;
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
            width += m_spacing;
        }
        else
        {
            width += (int) (m_char_rects[index]->w);
        } // if ... else
    } // for
    
    return width;
    
} // text_width()

// --------------------------------------------------

public int text_height() { return m_font_height; }

// --------------------------------------------------

public int get_spacing() { return m_spacing; }

// --------------------------------------------------
 
public void set_spacing( void|int spc )
{
    if ( spc )    // if argument is supplied...
    {
        if ( spc < MIN_SPACING )
        {
            m_spacing = MIN_SPACING;
        }
        else if ( spc > MAX_SPACING )
        {
            m_spacing = MAX_SPACING;
        }
        else
        {
            m_spacing = spc;
        } // if ... else
    }
    else
    {
        m_spacing = DEFAULT_SPACING;
    } // if ... else
    
} // set_spacing()    




// --------------------------------------------------
// PROTECTED METHODS
protected void create(string image_file, array(int) rgb, void|int mag_filter)
{
    string my_data = Image.load_file( image_file );
    object my_image = Image.PNG.decode( my_data );
    object my_alpha = Image.PNG.decode_alpha( my_data );
    my_image->box( 0, 1, my_image->xsize(), my_image->ysize(), @rgb );

    // Lose 1 pixel from height - that's the top row with the pink spacers.
    m_font_height = (int) my_image->ysize() - 1;
    
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
            
            EasyGL.Rectf r = EasyGL.Rectf(
                    (float) begin, 
                    1.0, 
                    (float) (end - begin + 1), 
                    (float) m_font_height);
            m_char_rects += ({ r });
        } // if 
        ++x;
    } // while

    if (!zero_type(mag_filter))
    {
        m_tex = EasyGL.Texture((["image":my_image, "alpha":my_alpha]), mag_filter);
    }
    else
    {
        m_tex = EasyGL.Texture( (["image":my_image, "alpha":my_alpha]) );
    } // if ... else

} // create()




// --------------------------------------------------
// PRIVATE DATA
private constant DEFAULT_SPACING = 5;
private constant MIN_SPACING = 4;
private constant MAX_SPACING = 20;
private constant BEGIN_ASCII = 33;
private constant NUM_FONT_CHARS = 94;

private int                 m_spacing = DEFAULT_SPACING;
private int                 m_font_height;
private array(EasyGL.Rectf) m_char_rects = ({});
private EasyGL.Texture      m_tex;



