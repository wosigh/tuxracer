/* 
 * Tux Racer 
 * Copyright (C) 1999-2001 Jasmin F. Patry
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#include "tuxracer.h"
#include "audio.h"
#include "keyboard.h"
#include "gl_util.h"
#include "fps.h"
#include "loop.h"
#include "render_util.h"
#include "textures.h"
#include "multiplayer.h"
#include "ui_mgr.h"
#include "ui_snow.h"
#include "textures.h"

#define COORD_OFFSET_AMT -0.5

#define SPLASH_DURATION 2000000000ULL //2 seconde
#define FADE_DURATION   400000000ULL //0.4 seconde


static const colour_t background_colour = { 0.48, 0.63, 0.90, 1.0 };
static char *logo_bindings = "splash_screen";
static uint64_t time_origin;
static bool quit_fading_out;
static bool must_draw_fade_in_out;

static void goto_next_mode()
{
    set_game_mode( GAME_TYPE_SELECT );

    /* 
     * Free textures
     */
    unbind_texture( logo_bindings );
    flush_textures();
    winsys_post_redisplay();
}

static void splash_screen_mouse_func( int button, int state, int x, int y )
{
	//car sinon a fonction est appelée deux fois, au cick et au release;
	if (quit_fading_out) return;
	uint64_t time = udate();
	/* Si on est déja dans une periode de fade out ca fait rien */
	if ((time-time_origin)>=(SPLASH_DURATION-FADE_DURATION)) return;
    time_origin = time;
	quit_fading_out=true;
	must_draw_fade_in_out=false;
}

void splash_screen_init(void) 
{
    init_ui_snow();
	
	time_origin = udate();
	quit_fading_out=false;
	must_draw_fade_in_out=true;
    winsys_set_display_func( main_loop );
    winsys_set_idle_func( main_loop );
    winsys_set_reshape_func( reshape );
    winsys_set_mouse_func( splash_screen_mouse_func );
    winsys_set_motion_func( ui_event_motion_func );
    winsys_set_passive_motion_func( ui_event_motion_func );

#ifndef __APPLE__
    play_music( "splash_screen" );
#endif

    reshape( getparam_x_resolution(), getparam_y_resolution() );
    
#ifdef __APPLE__
    // Skip the splash screen directly
    //goto_next_mode();
#endif
}


static void draw_logo()
{
    GLuint texid;
    point2d_t ll, ur;
    GLint w, h;

    glEnable( GL_TEXTURE_2D );
    get_texture_binding( logo_bindings, &texid );
    glColor4f( 1.0, 1.0, 1.0, 1.0 );

	glBindTexture( GL_TEXTURE_2D, texid );
    
	#ifdef __APPLE__
        w = 320;
        h = 480;
    #else
        glGetTexLevelParameteriv( GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &w );
        glGetTexLevelParameteriv( GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &h );
    #endif
    
	ll.x = getparam_x_resolution()/2 - w/2;
	ll.y = getparam_y_resolution()/2 - h/2;
	ur.x = ll.x + w;
	ur.y = ll.y + h;

	glBegin( GL_QUADS );
	{
	    glTexCoord2f( 0.0, 0.0 );
	    glVertex2f( ll.x, ll.y );
	    glTexCoord2f( 1.0, 0.0 );
	    glVertex2f( ur.x, ll.y );
	    glTexCoord2f( 1.0, 1.0 );
	    glVertex2f( ur.x, ur.y );
	    glTexCoord2f( 0.0, 1.0 );
	    glVertex2f( ll.x, ur.y );
	}
	glEnd();
}

float fade_in_out_func(uint64_t t) {
	float result;
	/* Changement de variable */
	float x = (float)t/(float)FADE_DURATION;
	if (t<FADE_DURATION) result = (1.-x);
	if (t>=FADE_DURATION && t<=(SPLASH_DURATION-FADE_DURATION)) result = 0.0;
	/* Changement de variable */
	x = (float)(t-(SPLASH_DURATION-FADE_DURATION))/(float)FADE_DURATION;
	if (t>(SPLASH_DURATION-FADE_DURATION)) result = x;
	return result;
}

float fade_out_func(uint64_t t) {
	float result;
	/* Changement de variable */
	float x = (float)t/(float)FADE_DURATION;
	if (t<FADE_DURATION) result = x;
	else result = 1.0;
	return result;
}

void draw_fade_in_out() {
	uint64_t time = udate()-time_origin;
	if (time>SPLASH_DURATION) goto_next_mode();
	
	float alpha = fade_in_out_func(time);
	
	int w = 320.;
	int h = 480.;
	
	glColor4f(0,0,0,alpha);
	glBegin( GL_QUADS );
	{
	    glVertex2f( 0, 0 );
		glVertex2f( w, 0 );
		glVertex2f( w, h );
		glVertex2f( 0, h );
	}
	glEnd();
}

//appelée quand on clique sur l'écran pour zapper le splash
void draw_fade_out() {
	uint64_t time = udate()-time_origin;
	if (time>FADE_DURATION) goto_next_mode();
	
	float alpha = fade_out_func(time);
	
	int w = 320.;
	int h = 480.;
	
	glColor4f(0,0,0,alpha);
	glBegin( GL_QUADS );
	{
	    glVertex2f( 0, 0 );
		glVertex2f( w, 0 );
		glVertex2f( w, h );
		glVertex2f( 0, h );
	}
	glEnd();
}

void splash_screen_loop( scalar_t time_step )
{
    check_gl_error();

    update_audio();

    clear_rendering_context();

    set_gl_options( GUI );

    ui_setup_display();

    if (getparam_ui_snow()) {
		update_ui_snow( time_step, False );
		draw_ui_snow();
    }

    draw_logo();
	
	if (must_draw_fade_in_out) draw_fade_in_out();
	
	if (quit_fading_out) draw_fade_out();
	
    ui_draw();

    reshape( getparam_x_resolution(), getparam_y_resolution() );

    winsys_swap_buffers();
} 

START_KEYBOARD_CB( splash_screen_cb )
{
#ifndef __APPLE__
    goto_next_mode();
#endif
}
END_KEYBOARD_CB

START_KEYBOARD_CB( toggle_snow )
{
    if ( release ) return;

    setparam_ui_snow( (bool_t) !getparam_ui_snow() );
}
END_KEYBOARD_CB

void splash_screen_register()
{
    int status = 0;

    status |= add_keymap_entry( SPLASH, DEFAULT_CALLBACK, NULL, NULL, 
				splash_screen_cb );

    status |= add_keymap_entry( ALL_MODES, FIXED_KEY, "tab", NULL, 
				toggle_snow );

    check_assertion( status == 0, "out of keymap entries" );

    register_loop_funcs( SPLASH, splash_screen_init, splash_screen_loop, 
			 NULL );

}
