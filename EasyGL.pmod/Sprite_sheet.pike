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

/*
 This class allows you to load in a sprite sheet as a single texture and draw
 as many sprites as you like from it with only one call to glBind().  E.g.
   Sprite_sheet.Sprite_sheet ss = Sprite_sheet.Sprite_sheet( ... );
   ...
   ss->start_draw();
   // Multiple calls...
   ss->draw( ... );
   ss->draw( ... );
   ss->end_draw();
 N.B. we assume that all sprites are the same size.
*/

//#pragma strict_types
import GL;


// --------------------------------------------------
// PUBLIC DATA


// --------------------------------------------------
// PUBLIC METHODS
public void start_draw()
{
    GL.glEnable( GL_TEXTURE_2D );
    GL.glBindTexture( GL_TEXTURE_2D, m_name );

} // start_draw()

// --------------------------------------------------

public void draw(   int i,
                    .Rectf dest,
                    float opacity,
                    void|float rotation )
{
    GL.glColor( 1.0, 1.0, 1.0, opacity );
    GL.glMatrixMode( GL_MODELVIEW );
    GL.glPushMatrix();
    GL.glLoadIdentity();
    GL.glTranslate( dest->x + m_half_sprite_w, dest->y + m_half_sprite_h, 
            0.0 );
    if ( rotation )
    {
        GL.glRotate( rotation, 0.0, 0.0, 1.0 );
    } // if
    
    glBegin( GL_QUADS );
        // top-left
        glTexCoord( m_texture_rects[i]->x, m_texture_rects[i]->y );
        glVertex( -m_half_sprite_w, -m_half_sprite_h );
        // top-right
        glTexCoord( m_texture_rects[i]->w, m_texture_rects[i]->y );
        glVertex( m_half_sprite_w, -m_half_sprite_h );
        // bottom-right
        glTexCoord( m_texture_rects[i]->w, m_texture_rects[i]->h );
        glVertex( m_half_sprite_w, m_half_sprite_h );
        // bottom-left
        glTexCoord( m_texture_rects[i]->x, m_texture_rects[i]->h );
        glVertex( -m_half_sprite_w, m_half_sprite_h );
    glEnd();

    glPopMatrix();

} // draw()

// --------------------------------------------------

public void draw_scaled(int i,
                        .Rectf dest,
                        float opacity,
                        float scale_factor,
                        void|float rotation )
{
    GL.glColor( 1.0, 1.0, 1.0, opacity );

    float half_scaled_w = m_half_sprite_w * scale_factor;
    float half_scaled_h = m_half_sprite_h * scale_factor;

    GL.glMatrixMode( GL_MODELVIEW );
    GL.glPushMatrix();
    GL.glLoadIdentity();
    /*GL.glTranslate( dest->x + m_half_sprite_w, dest->y + m_half_sprite_h, 
            0.0 );*/
    GL.glTranslate(dest->x + half_scaled_w, dest->y + half_scaled_h, 0.0);
    if ( rotation )
    {
        GL.glRotate( rotation, 0.0, 0.0, 1.0 );
    } // if
    
    glBegin( GL_QUADS );
        // top-left
        glTexCoord( m_texture_rects[i]->x, m_texture_rects[i]->y );
        //glVertex( -m_half_sprite_w, -m_half_sprite_h );
        glVertex( -half_scaled_w, -half_scaled_h );
        // top-right
        glTexCoord( m_texture_rects[i]->w, m_texture_rects[i]->y );
        //glVertex( m_half_sprite_w, -m_half_sprite_h );
        glVertex( half_scaled_w, -half_scaled_h );
        // bottom-right
        glTexCoord( m_texture_rects[i]->w, m_texture_rects[i]->h );
        //glVertex( m_half_sprite_w, m_half_sprite_h );
        glVertex( half_scaled_w, half_scaled_h );
        // bottom-left
        glTexCoord( m_texture_rects[i]->x, m_texture_rects[i]->h );
        //glVertex( -m_half_sprite_w, m_half_sprite_h );
        glVertex( -half_scaled_w, half_scaled_h );
    glEnd();

    glPopMatrix();

} // draw()

// --------------------------------------------------

public void end_draw()
{
    glDisable( GL_TEXTURE_2D );

} // end_draw()




// --------------------------------------------------
// PROTECTED DATA


// --------------------------------------------------
// PROTECTED METHODS
// NOTE: default mag_filter is 'LINEAR'.
protected void create(string|mapping filepath, 
                      int sprite_w, 
                      int sprite_h,
                      void|int mag_filter)
{
    m_half_sprite_w = sprite_w * 0.5;
    m_half_sprite_h = sprite_h * 0.5;
    mapping m;

    if ( stringp(filepath) )
    {
        string data = Image.load_file( (string) filepath );
        if ( has_suffix(lower_case((string) filepath), "svg") ) 
        {
            m = Image.SVG._decode( data );
        }
        else
        {
            m = Image.ANY._decode( data );
        } // if ... else
    }
    else if ( mappingp(filepath) )
    {
        m = (mapping) filepath;
    } // if ... else

    int image_w = (int) m["image"]->xsize();
    int image_h = (int) m["image"]->ysize();
    int texture_w = next_power_of_two( image_w );
    int texture_h = next_power_of_two( image_h );

    // Do we need to resize?
    if (image_w < texture_w || image_h < texture_h)
    {
        m["image"] = m["image"]->copy(0, 0, texture_w-1, texture_h-1,
                0, 0, 0);
        if (m["alpha"])
        {
            m["alpha"] = m["alpha"]->copy(0, 0, texture_w-1, texture_h-1,
                    0, 0, 0);
        } // if
    } // if

    m_name = glGenTextures(1)[0];
    glBindTexture(GL_TEXTURE_2D, m_name);
    int mf = GL_LINEAR;
    if (!zero_type(mag_filter))
    {
        mf = mag_filter;
    } // if
    glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mf);
    glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP);
    glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP);
        
    if ( m["alpha"] )
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 
                (["rgb":m["image"], "alpha":m["alpha"]]));
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, (["rgb":m["image"]]));
    } // if ... else

    build_texture_rects(image_w, image_h, texture_w, texture_h, sprite_w, 
            sprite_h);

} // create()




// --------------------------------------------------
// PRIVATE DATA
// N.B. These Rectf objects are not used in the standard way.  'x' and 'y'
// represent the top-left corner but 'w' and 'h' don't represent width and
// height but rather the bottom-right corner.
// FIXME: change this.
private array(.Rectf) m_texture_rects = ({});
private float m_half_sprite_w;
private float m_half_sprite_h;
private int   m_name;


// --------------------------------------------------
// PRIVATE METHODS
private void build_texture_rects(   
        int image_w,
        int image_h,
        int texture_w,
        int texture_h,
        int sprite_w,
        int sprite_h )
{
    int num_cols = image_w / sprite_w;
    int num_rows = image_h / sprite_h;
    for (int r = 0; r < num_rows; ++r)
    {
        for (int c = 0; c < num_cols; ++c)
        {
            .Rectf rect = .Rectf( 
                    (float) c * sprite_w,
                    (float) r * sprite_h,
                    (float) (c * sprite_w) + sprite_w - 1,
                    (float) (r * sprite_h) + sprite_h - 1);
            // Normalize.
            rect->x /= texture_w;
            rect->y /= texture_h;
            rect->w /= texture_w;
            rect->h /= texture_h;
            m_texture_rects += ({ rect });
        } // for
    } // for

} // build_texture_rects()

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



