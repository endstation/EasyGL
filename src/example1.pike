// $Id: example1.pike 12 2011-02-20 09:48:09Z mafferyew@googlemail.com $

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


// A simple example that sets up a 640*480 window, loads in a texture and draws
// it in the window.
// 'passarinho.svg' from http://www.openclipart.org, uploaded by
// glauciarezende.

#pragma strict_types

import GL;

int main()
{
    // Set up and clear screen.
    .EasyGL.set_up( 640, 480, 0.3, 0.2, 0.3 );
    glClear( GL_COLOR_BUFFER_BIT );

    // Create a texture.  At the moment, both PNG and SVG files are supported.
    // It's very easy to add support for other formats if you need them.
    .EasyGL.Texture_data birds_tex = .EasyGL.texture_from_file( 
            "passarinho.svg" );

    // We're going to draw it at coordinates 50,50.
    SDL.Rect dest = SDL.Rect();
    dest->x = 178;
    dest->y = 178;
    // The 3rd argument to draw_texture() is the opacity.  '1.0' means full
    // opacity; '0.0' full transparency.
    .EasyGL.draw_texture( birds_tex, dest, 1.0, 10.0 );

    // Swap buffers so we can see our texture.
    SDL.gl_swap_buffers();
    sleep( 5 );
    return 0;

} // main()

