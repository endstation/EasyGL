// $Id: example2.pike 12 2011-02-20 09:48:09Z mafferyew@googlemail.com $

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


// Load a font image into SFontGL and write some text to the screen.

import GL;

int main()
{
    .EasyGL.set_up( 640, 480, ({0.1,0.1,0.1}) );
    SDL.set_caption( "EasyGL example #2", "" );
    .SFontGL.SFontGL my_font = .SFontGL.SFontGL( "dejavu_serif_bold_28.png", 
            ({244, 203, 10}) );
    // Default spacing (between words) is 5 pixels, which can sometimes 
    // be a bit too short.
    my_font->set_spacing( 12 );

    glClear( GL_COLOR_BUFFER_BIT );
    .EasyGL.Rectf dest = .EasyGL.Rectf( 50.0, 50.0 );
    my_font->draw( "Hello, Pike!", dest, 0.3 );

    dest->y0 = 150.0;
    my_font->draw_center( "How are you?", dest, 640 );

    SDL.gl_swap_buffers();
    sleep( 5 );
    return 0;

} // main()

