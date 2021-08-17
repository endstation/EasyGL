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

void draw_box( .Rectf r, Image.Color.Color c, void|float line_w )
{
    glLineWidth( line_w || 1.0 );
    glEnable( GL_LINE_SMOOTH );
    glColor( @c->rgbf(), 1.0 );
    glBegin( GL_LINE_LOOP );
        glVertex( r->x,  r->y,  0.0 );
        glVertex( r->x2, r->y,  0.0 );
        glVertex( r->x2, r->y2, 0.0 );
        glVertex( r->x,  r->y2, 0.0 );
    glEnd();

} // draw_box()

// --------------------------------------------------

void fill_box( .Rectf r, Image.Color.Color c, float opacity )
{
    glColor( @c->rgbf(), opacity );
    glBegin( GL_QUADS );
        glVertex( r->x,  r->y,  0.0 );
        glVertex( r->x2, r->y,  0.0 );
        glVertex( r->x2, r->y2, 0.0 );
        glVertex( r->x,  r->y2, 0.0 );
    glEnd();

} // fill_box()

// --------------------------------------------------

void draw_line(.Rectf from, 
               .Rectf to,
               Image.Color.Color c, 
               float opacity,
               void|float line_w)
{
    glLineWidth(line_w || 1.0);
    glEnable(GL_LINE_SMOOTH);
    glColor(@c->rgbf(), opacity);
    glBegin(GL_LINES);
        glVertex(from->x, from->y);
        glVertex(to->x, to->y);
    glEnd();

} // draw_line()

// --------------------------------------------------

void draw_pixel(.Rectf pos, Image.Color.Color c)
{
    glColor(@c->rgbf(), 1.0);
    glBegin(GL_POINTS);
        glVertex(pos->x, pos->y);
    glEnd();

} // draw_pixel()


