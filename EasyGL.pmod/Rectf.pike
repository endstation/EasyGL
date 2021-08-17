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
// TODO: make sure width and height are always positive.


// --------------------------------------------------
// PUBLIC DATA


// --------------------------------------------------
// PUBLIC METHODS
public int intersects(EasyGL.Rectf rhs)
{
    return     m_x >= rhs->x - m_w
            && m_x <= rhs->x + rhs->w
            && m_y >= rhs->y - m_h
            && m_y <= rhs->y + rhs->h;

} // intersects()

// --------------------------------------------------

public int intersects_x(EasyGL.Rectf rhs)
{
    return (m_x >= rhs->x - m_w) && (m_x <= rhs->x + rhs->w);

} // intersects_x()

// --------------------------------------------------

public int intersects_y(EasyGL.Rectf rhs)
{
    return (m_y >= rhs->y - m_h) && (m_y <= rhs->y + rhs->h);

} // intersects_y()

// --------------------------------------------------

public EasyGL.Rectf copy()
{
    return EasyGL.Rectf(m_x, m_y, m_w, m_h);

} // copy()

// --------------------------------------------------

public string to_s()
{
    return sprintf("%f,%f,%f,%f", m_x, m_y, m_w, m_h);

} // to_s()

// --------------------------------------------------

public float `x() { return m_x; }
public float `y() { return m_y; }
public float `w() { return m_w; }
public float `h() { return m_h; }

// --------------------------------------------------

public void `x=(float x) { m_x = x; }
public void `y=(float y) { m_y = y; }
public void `w=(float w) { m_w = w; }
public void `h=(float h) { m_h = h; }

// --------------------------------------------------

public float `x2() { return m_x + m_w - 1.0; }
public float `y2() { return m_y + m_h - 1.0; }

// --------------------------------------------------

public void translate(float dx, float dy)
{
    m_x += dx;
    m_y += dy;

} // translate()

// --------------------------------------------------

public void set_location(float x, float y)
{
    m_x = x;
    m_y = y;
    
} // set_location()

// --------------------------------------------------

public EasyGL.Rectf `-(EasyGL.Rectf rhs)
{
    return EasyGL.Rectf(m_x - rhs->x, m_y - rhs->y);

} // `-()



// --------------------------------------------------
// PROTECTED DATA


// --------------------------------------------------
// PROTECTED METHODS
protected void create( 
        void|float x,
        void|float y,
        void|float w,
        void|float h)
{
    if (x) { m_x = x; }
    if (y) { m_y = y; }
    if (w) { m_w = w; }
    if (h) { m_h = h; }

} // create()




// --------------------------------------------------
// PRIVATE DATA
private float m_x = 0.0;
private float m_y = 0.0;
private float m_w = 0.0;
private float m_h = 0.0;


// --------------------------------------------------
// PRIVATE METHODS




