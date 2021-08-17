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


#pragma strict_types


// --------------------------------------------------
// PUBLIC METHODS
public .Sprite_sheet get_sprite_sheet() { return m_sprite_sheet; }




// --------------------------------------------------
// PROTECTED METHODS
// Same as SFont ctor but we save Image objects rather than immediately 
// creating an EasyGL.Texture.
protected void create(string image_file, 
                      array(int) rgb,
                      array(string) strs,
                      void|int spacing)
{
    if (spacing)
    {
        set_spacing(spacing);
    } // if

    string my_data = Image.load_file( image_file );
    m_image = Image.PNG.decode( my_data );
    m_alpha = Image.PNG.decode_alpha( my_data );
    m_image->box( 0, 1, m_image->xsize(), m_image->ysize(), @rgb );

    // Lose 1 pixel from height - that's the top row with the pink spacers.
    m_font_height = (int) m_image->ysize() - 1;
    
    int x     = 0;
    int begin = 0;
    int end   = 0;
    array(int) pink = ({ 255, 0, 255 });
    
    while ( x < m_image->xsize() )
    {
        if ( !equal(m_image->getpixel(x, 0), pink) )
        {
            // First clear pixel found - this is the start of a character.
            begin = x;
            
            do
            {
                ++x;
            } while ( !equal(m_image->getpixel(x, 0), pink) );
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

    build_texture(strs);

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

private object m_image;
private object m_alpha;

private .Sprite_sheet m_sprite_sheet;


// --------------------------------------------------
// PRIVATE METHODS
private void build_texture(array(string) strs)
{
    int total_height = m_font_height * sizeof(strs);

    // TODO: should work with all types of font...
    // Find width of longest string - assume a fixed-width font.
    string longest = "";
    foreach (strs, string s)
    {
        if (sizeof(s) > sizeof(longest))
        {
            longest = s;
        } // if
    } // foreach
    int total_width = text_width(longest);

    // Create a new Image object with these dimensions.
    Image.Image image = Image.Image(total_width, total_height);
    Image.Image alpha = Image.Image(total_width, total_height);
    for (int i = 0; i < sizeof(strs); ++i)
    {
        EasyGL.Rectf dest = EasyGL.Rectf(0.0, (float) (m_font_height * i));
        draw_center(strs[i], dest, image, alpha, total_width);
    } // for
    
    // Now create the Sprite_sheet object using our new Image objects.
    m_sprite_sheet = .Sprite_sheet((["image":image, "alpha":alpha]),
            total_width, m_font_height);
    
} // build_texture()

// --------------------------------------------------

private void draw(string text, EasyGL.Rectf dest, object dest_image, 
        object dest_alpha) 
{
    int len = sizeof(text);

    for (int i = 0; i < len; ++i)
    {
        int index = text[i] - BEGIN_ASCII;
        if (index < 0 || index >= NUM_FONT_CHARS)
        {
            dest->x += m_spacing;
        }
        else
        {
            object i = (object) m_image->copy(
                    (int) m_char_rects[index]->x,
                    (int) m_char_rects[index]->y,
                    (int) m_char_rects[index]->x2,
                    (int) m_char_rects[index]->y2);
            object a = (object) m_alpha->copy(
                    (int) m_char_rects[index]->x,
                    (int) m_char_rects[index]->y,
                    (int) m_char_rects[index]->x2,
                    (int) m_char_rects[index]->y2);
            dest_image->paste(i, (int) dest->x, (int) dest->y);
            dest_alpha->paste(a, (int) dest->x, (int) dest->y);
            
            dest->x += (m_char_rects[index]->w);
        } // if ... else
    } // for

} // draw()

// --------------------------------------------------

private int text_width(string text)
{
    int width = 0;
    int len = sizeof(text);
    for (int i = 0; i < len; ++i)
    {
        int index = text[i] - BEGIN_ASCII;
        if (index < 0 || index >= NUM_FONT_CHARS)
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

private void set_spacing(int spc)
{
    if (spc < MIN_SPACING)
    {
        m_spacing = MIN_SPACING;
    }
    else if (spc > MAX_SPACING)
    {
        m_spacing = MAX_SPACING;
    }
    else
    {
        m_spacing = spc;
    } // if ... else
    
} // set_spacing()    

// --------------------------------------------------

private void draw_center(string text,
                         EasyGL.Rectf dest,
                         object dest_image,
                         object dest_alpha,
                         int screen_width)
{
    int tw = text_width(text);
    dest->x = (screen_width - tw) / 2.0;
    draw(text, dest, dest_image, dest_alpha);
    
} // draw_center()


