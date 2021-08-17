// EasyGL
// Copyright 2015 Matthew Clarke
//
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
// PUBLIC DATA


// --------------------------------------------------
// PUBLIC METHODS
public void check_beat()
{
    float dt = m_timer->peek();
    if (dt >= m_step)
    {
        m_timer->get();
        if (!m_paused)
        {
            `()(m_callback);
        } // if
    } // if

} // check_beat()

// --------------------------------------------------

public void pause()
{
    m_paused = 1;

} // pause()

// --------------------------------------------------

public void resume()
{
    m_paused = 0;

} // resume()

// --------------------------------------------------

public int toggle_pause()
{
    m_paused = !m_paused;
    return m_paused;

} // toggle_pause()

// --------------------------------------------------

public void set_step(float step)
{
    m_timer->get();
    m_step = step;

} // set_step()

// --------------------------------------------------

public float get_step()
{
    return m_step;

} // get_step()




// --------------------------------------------------
// PROTECTED DATA


// --------------------------------------------------
// PROTECTED METHODS
protected void create(function(void:void) callback, float step)
{
    m_callback = callback;
    m_step = step;
    m_timer = System.Timer();

} // create()




// --------------------------------------------------
// PRIVATE DATA
private System.Timer m_timer;
private float m_step;
private function(void:void) m_callback;
private int m_paused = 0;


// --------------------------------------------------
// PRIVATE METHODS



