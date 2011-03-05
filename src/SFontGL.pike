// $Id: SFontGL.pike 12 2011-02-20 09:48:09Z mafferyew@googlemail.com $

// EasyGL
// Copyright 2011 Matthew Clarke <mafferyew@googlemail.com>

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




// --------------------------------------------------
// PUBLIC METHODS

public void draw( string text,
                  SDL.Rect dest,
                  void|float opacity ) 
{
    float a = 1.0;
    if ( opacity )
    {
        a = opacity;
    } // if

    int len = sizeof( text );
    for ( int i = 0; i < len; ++i )
    {
        int index = text[i] - BEGIN_ASCII;
        if ( index < 0 || index >= NUM_FONT_CHARS )
        {
            dest->x += spacing;
            continue;
        } // if
        
        .EasyGL.draw_texture( my_font_chars[index], dest, a );
        dest->x += my_font_chars[index]->original_w;
    } // for
    
} // draw()

// --------------------------------------------------

public void draw_center( string text,
                         SDL.Rect dest,
                         int screen_width,
                         void|float opacity )
{
    int tw = text_width( text );
    dest->x = (screen_width - tw) / 2;
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
            width += my_font_chars[index]->original_w;
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
// STATIC METHODS

static void create( string image_file )
{
    string my_data = Image.load_file( image_file );
    mapping m = Image.PNG._decode( my_data );
    Image.Image my_image = m["image"];
    Image.Image my_alpha = m["alpha"];
    // Lose 1 pixel from height - that's the top row with the pink spacers.
    font_height = my_image->ysize() - 1;
    
    int x = 0;
    int begin = 0;
    int end = 0;
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
            object o = .EasyGL.texture_from_image( section, section_a );
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
private array( .EasyGL.Texture_data ) my_font_chars = ({});
private int spacing = DEFAULT_SPACING;
private int font_height;




constant SFontGL = (program) "SFontGL.pike";

