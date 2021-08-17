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


int main()
{
    EasyGL.EasyGL.set_up(640, 480, ({1.0,1.0,1.0}));
    
    .String_sprite_sheet_creator sssc = .String_sprite_sheet_creator(
            "dejavu_serif_bold_28.png", ({0,0,0}), 
            ({"Snoopy", "Lucy", "Charlie", "Woodstock"}), 10);
    .Sprite_sheet ss = sssc->get_sprite_sheet();

    GL.glClear(GL.GL_COLOR_BUFFER_BIT);
    ss->start_draw();
    ss->draw(1, EasyGL.Rectf(50.0, 75.0), 1.0, 45.0);
    ss->end_draw();
    SDL.gl_swap_buffers();
    sleep(3);

    return 0;

} // main()

