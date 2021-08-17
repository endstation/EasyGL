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


//#pragma strict_types
import GL;


// --------------------------------------------------
// PUBLIC DATA


// --------------------------------------------------
// PUBLIC METHODS
public void draw( .Rectf dest, 
                  float opacity, 
                  void|float rotation )
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, name );
    glColor( 1.0, 1.0, 1.0, opacity );

    glMatrixMode( GL_MODELVIEW );
    glPushMatrix();
    glLoadIdentity();
    glTranslate( dest->x + half_texture_w, dest->y + half_texture_h,
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
    
public void draw_section( .Rectf dest, 
                          .Rectf src, 
                          float opacity,
                          void|float rotation )
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, name );
    glColor( 1.0, 1.0, 1.0, opacity );

    glMatrixMode( GL_MODELVIEW );
    glPushMatrix();
    glLoadIdentity();

    float half_w = src->w * 0.5;
    float half_h = src->h * 0.5;
    glTranslate( dest->x + half_w, dest->y + half_h, 0.0 );
    if ( rotation )
    {
        glRotate( rotation, 0.0, 0.0, 1.0 );
    } // if
    
    float x1 = src->x  / texture_w;
    float x2 = src->x2 / texture_w;
    float y1 = src->y  / texture_h;
    float y2 = src->y2 / texture_h;
                
    glBegin( GL_QUADS );
        // top-left
        glTexCoord( x1, y1 );
        glVertex( -half_w, -half_h );
        // top-right
        glTexCoord( x2, y1 );
        glVertex( half_w, -half_h );
        // bottom-right
        glTexCoord( x2, y2 );
        glVertex( half_w, half_h );
        // bottom-left
        glTexCoord( x1, y2 );
        glVertex( -half_w, half_h );
    glEnd();

    glPopMatrix();
    glDisable( GL_TEXTURE_2D );

} // draw_section()

// --------------------------------------------------

public void draw_scaled( .Rectf dest,
                         float opacity,
                         float scale_factor,
                         void|float rotation )                   
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, name );
    glColor( 1.0, 1.0, 1.0, opacity );

    float half_scaled_w = texture_w * scale_factor * 0.5;
    float half_scaled_h = texture_h * scale_factor * 0.5;

    glMatrixMode( GL_MODELVIEW );
    glPushMatrix();
    glLoadIdentity();
    glTranslate( dest->x + half_scaled_w, dest->y + half_scaled_h, 0.0 );
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

// --------------------------------------------------

public int get_image_h() { return image_h; }

// --------------------------------------------------

public void replace_image( object image )
{
    glEnable( GL_TEXTURE_2D );
    glBindTexture( GL_TEXTURE_2D, name );
    glTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, (["rgb":image]) );
    glDisable( GL_TEXTURE_2D );

} // replace_image()

// --------------------------------------------------

public void delete()
{
    glDeleteTextures( name );

} // delete()

// --------------------------------------------------

// FIXME: hack to make SFontGL more efficient.
public void start_draw()
{
    GL.glEnable(GL_TEXTURE_2D);
    GL.glBindTexture(GL_TEXTURE_2D, name);

} // start_draw()

// --------------------------------------------------

public void end_draw()
{
    glDisable(GL_TEXTURE_2D);

} // end_draw()

// --------------------------------------------------

public void draw_section_no_bind( 
        .Rectf dest, 
        .Rectf src, 
        float opacity)
{
    glColor(1.0, 1.0, 1.0, opacity);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    float half_w = src->w * 0.5;
    float half_h = src->h * 0.5;
    glTranslate(dest->x + half_w, dest->y + half_h, 0.0);
    
    float x1 = src->x  / texture_w;
    float x2 = src->x2 / texture_w;
    float y1 = src->y  / texture_h;
    float y2 = src->y2 / texture_h;
                
    glBegin(GL_QUADS);
        // top-left
        glTexCoord(x1, y1);
        glVertex(-half_w, -half_h);
        // top-right
        glTexCoord(x2, y1);
        glVertex(half_w, -half_h);
        // bottom-right
        glTexCoord(x2, y2);
        glVertex(half_w, half_h);
        // bottom-left
        glTexCoord(x1, y2);
        glVertex(-half_w, half_h);
    glEnd();

    glPopMatrix();

} // draw_section_no_bind()
// FIXME: end hack.




// --------------------------------------------------
// PROTECTED DATA


// --------------------------------------------------
// PROTECTED METHODS
// TODO: check that EasyGL has been initialized!
protected void create(string|mapping filepath, void|int mag_filter)
{
    mapping m;

    if ( stringp(filepath) )
    {
        string data = Image.load_file((string) filepath);
        int is_svg = 0;
        int is_jpg = 0;
        if ( has_suffix(lower_case((string) filepath), "svg") ) 
        {
            is_svg = 1;
        }
        else if (has_suffix(lower_case((string) filepath), "jpg"))
        {
            is_jpg = 1;
        } // if ... else

        if ( is_svg )
        {
            m = Image.SVG._decode( data );
        }
        else if (is_jpg)
        {
            // To ensure rotations are honoured.
#if __MAJOR__ == 8
            m = Image.JPEG.exif_decode(data);
#endif
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

    image_w = (int) m["image"]->xsize();
    image_h = (int) m["image"]->ysize();
    texture_w = image_w;//next_power_of_two( image_w );
    texture_h = image_h;//next_power_of_two( image_h );
    half_texture_w = texture_w / 2;
    half_texture_h = texture_h / 2;

    // Do we need to resize?
    if ( image_w < texture_w || image_h < texture_h )
    {
        m["image"] = m["image"]->copy( 0, 0, texture_w-1, texture_h-1,
                0, 0, 0 );
        if ( m["alpha"] )
        {
            m["alpha"] = m["alpha"]->copy( 0, 0, texture_w-1, texture_h-1,
                    0, 0, 0 );
        } // if
    } // if

    name = glGenTextures( 1 )[0];
    glBindTexture( GL_TEXTURE_2D, name );
    // Check if caller supplied a value for mag_filter, otherwise use default.
    int mf = GL_LINEAR;
    if (!zero_type(mag_filter))
    {
        mf = mag_filter;
    } // if
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mf);
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP );
    glTexParameter( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP );

        
    if ( m["alpha"] )
    {
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 0, 
                (["rgb":m["image"], "alpha":m["alpha"]]) );
    }
    else
    {
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, (["rgb":m["image"]]) );
    } // if ... else

} // create()




// --------------------------------------------------
// PRIVATE DATA
private int name;
private int image_w;
private int image_h;
private int texture_w;
private int texture_h;
private int half_texture_w;
private int half_texture_h;


// --------------------------------------------------
// PRIVATE METHODS
private int next_power_of_two(int n)
{
    int x = 2;
    while (x < n)
    {
        x *= 2;
    } // while

    return x;

} // next_power_of_two()



