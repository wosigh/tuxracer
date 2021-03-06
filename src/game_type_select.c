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
#include "game_type_select.h"
#include "ui_mgr.h"
#include "ui_theme.h"
#include "button.h"
#include "loop.h"
#include "render_util.h"
#include "audio.h"
#include "gl_util.h"
#include "keyboard.h"
#include "multiplayer.h"
#include "ui_snow.h"
#include "joystick.h"
#include "event_select.h"
#include "winsys.h"

static button_t *enter_event_btn = NULL;
static button_t *practice_btn = NULL;
static button_t *credits_btn = NULL;
static button_t *pref_btn = NULL;
static button_t *rankings_btn = NULL;
static button_t *day_remaining_btn = NULL;
static const char* actionAfterQuittingSuscribtionView="";

/* predefinition of these two functions */
void rankings_click_cb( button_t *button, void *userdata );
void practice_click_cb( button_t *button, void *userdata );

//The training mode of Tux Racer World challenge has been binded to the event mode of tuxracer
void enter_event_click_cb( button_t* button, void *userdata )
{
    check_assertion( userdata == NULL, "userdata is not null" );
	
    g_game.current_event = NULL;
    g_game.current_cup = NULL;
    g_game.current_race = -1;
    g_game.practicing = False;
    
    zappe_event_screen(NULL, userdata);
    hideFBButton(true);
	
    ui_set_dirty();
}

void setActionAfterQuitting(const char* action) {
	actionAfterQuittingSuscribtionView=action;
}

void action_after_quitting_susctibtion_view() {
	if  (!strcmp(actionAfterQuittingSuscribtionView,"play")) {
		actionAfterQuittingSuscribtionView="";
		if (isPlayerRegistered()) practice_click_cb( NULL, NULL );
	}
}

//wich is in this version the "Play" click callback
void practice_click_cb( button_t *button, void *userdata )
{
	check_assertion( userdata == NULL, "userdata is not null" );
	
	//Only registered players can go in this mode
	if ((isPlayerRegistered() && wasChallengePresented()) || (isPlayerRegistered() && !isChallengeOn())) {
		g_game.current_event = NULL;
		g_game.current_cup = NULL;
		g_game.current_race = -1;
		g_game.practicing = True;
		
		//usefull for score saving
		g_game.race.name=NULL;
		
		set_game_mode( RACING_MODE_SELECT );
		hideFBButton(true);
		ui_set_dirty();
		
	} else {
		setActionAfterQuitting("play");
		showChallengeSuscribtion();
	}
}

void credits_click_cb( button_t *button, void *userdata )
{
	check_assertion( userdata == NULL, "userdata is not null" );
	
	set_game_mode( CREDITS );
	hideFBButton(true);
	ui_set_dirty();
}

#ifndef __APPLE__
void quit_click_cb( button_t *button, void *userdata )
{
	check_assertion( userdata == NULL, "userdata is not null" );
	
	winsys_exit( 0 );
}
#else
void pref_click_cb( button_t *button, void *userdata )
{
	check_assertion( userdata == NULL, "userdata is not null" );
	
	winsys_show_preferences();
}

void rankings_click_cb( button_t *button, void *userdata )
{
	check_assertion( userdata == NULL, "userdata is not null" );
	winsys_show_rankings();
}
#endif

static void set_widget_positions()
{
	button_t **button_list[] = { &enter_event_btn,
		&practice_btn,
#ifndef __APPLE__
		&quit_btn
#else
		&rankings_btn,
		&pref_btn,
#endif
		&credits_btn
	};
	int w = getparam_x_resolution();
	int h = getparam_y_resolution();
	int box_height;
	int box_max_y;
	int top_y;
	int bottom_y;
	int num_buttons = sizeof( button_list ) / sizeof( button_list[0] );
	int i;
	int tot_button_height = 0;
	int button_sep =0;
	int cur_y_pos;
	
	box_height = 240;
	box_max_y = h - 90;
	
	bottom_y = 0.45*h - box_height/2;
	
	if ( bottom_y + box_height > box_max_y ) {
		bottom_y = box_max_y - box_height;
	}
	
	top_y = bottom_y + box_height;
	
	for (i=0; i<num_buttons; i++) {
		tot_button_height += button_get_height( *button_list[i] );
	}
	
	if ( num_buttons > 1 ) {
		button_sep = ( top_y - bottom_y - tot_button_height ) / 
		( num_buttons - 1 );
		button_sep = max( 0, button_sep );
	}
	
	cur_y_pos = top_y;
	for (i=0; i<num_buttons; i++) {
		cur_y_pos -= button_get_height( *button_list[i] );
		button_set_position( 
							*button_list[i],
							make_point2d( w/2.0 - button_get_width( *button_list[i] )/2.0,
										 cur_y_pos ) );
		cur_y_pos -= button_sep;
	}
	
	button_set_position( day_remaining_btn, make_point2d( w/2.0 - button_get_width( day_remaining_btn )/2.0, 5.0 ) );
}

static void game_type_select_init(void)
{	
	//Load facebook button
	loadFBButton();
	hideFBButton(false);
	
	point2d_t dummy_pos = {0, 0};
	
	winsys_set_display_func( main_loop );
	winsys_set_idle_func( main_loop );
	winsys_set_reshape_func( reshape );
	winsys_set_mouse_func( ui_event_mouse_func );
	winsys_set_motion_func( ui_event_motion_func );
	winsys_set_passive_motion_func( ui_event_motion_func );
	
	enter_event_btn = button_create( dummy_pos,
									300, 40, 
									"button_label", 
									"Tutorial" );
	button_set_hilit_font_binding( enter_event_btn, "button_label_hilit" );
	button_set_visible( enter_event_btn, True );
	button_set_click_event_cb( enter_event_btn, enter_event_click_cb, NULL );
	
	practice_btn = button_create( dummy_pos,
								 300, 40,
								 "button_label",
								 Localize("Play","") );
	button_set_hilit_font_binding( practice_btn, "button_label_hilit" );
	button_set_visible( practice_btn, True );
	button_set_click_event_cb( practice_btn, practice_click_cb, NULL );
	
	credits_btn = button_create( dummy_pos,
								300, 40,
								"button_label",
								"Credits");
	button_set_hilit_font_binding( credits_btn, "button_label_hilit" );
	button_set_visible( credits_btn, True );
	button_set_click_event_cb( credits_btn, credits_click_cb, NULL );
	
	rankings_btn = button_create( dummy_pos,
								 300, 40,
								 "button_label",
								 Localize("Rankings","") );
	button_set_hilit_font_binding( rankings_btn, "button_label_hilit" );
	button_set_visible( rankings_btn, True );
	button_set_click_event_cb( rankings_btn, rankings_click_cb, NULL );
	
	pref_btn = button_create( dummy_pos,
							 300, 40,
							 "button_label",
							 Localize("Settings","") );
	button_set_hilit_font_binding( pref_btn, "button_label_hilit" );
	button_set_visible( pref_btn, True );
	button_set_click_event_cb( pref_btn, pref_click_cb, NULL );
	
	/*This button is in fact just a text infos Lable */
	
	day_remaining_btn = button_create( dummy_pos, 300, 40,
									  "informational", challengeTextInfos());
	button_set_hilit_font_binding( day_remaining_btn, "button_label_hilit" );
	button_set_visible( day_remaining_btn, True );
	button_set_enabled(day_remaining_btn, False);
	
	play_music( "start_screen" );
}

static void game_type_select_loop( scalar_t time_step )
{
	check_gl_error();
	
	update_audio();
	
	set_gl_options( GUI );
	
	clear_rendering_context();
	
	set_widget_positions();
	
	ui_setup_display();
	
	if (getparam_ui_snow()) {
		update_ui_snow( time_step, False );
		draw_ui_snow();
	}
	
	ui_draw_menu_decorations();
	
	ui_draw();
	
	action_after_quitting_susctibtion_view();
	
	reshape( getparam_x_resolution(), getparam_y_resolution() );
	
	winsys_swap_buffers();
	
	button_set_label(day_remaining_btn, challengeTextInfos());
}

static void game_type_select_term(void)
{
	button_delete( enter_event_btn );
	enter_event_btn = NULL;
	
	button_delete( practice_btn );
	practice_btn = NULL;
	
	button_delete( credits_btn );
	credits_btn = NULL;
	
	button_delete( day_remaining_btn );
	day_remaining_btn = NULL;
	
	button_delete( pref_btn );
	pref_btn = NULL;
	
	button_delete( rankings_btn );
	rankings_btn = NULL;

}

START_KEYBOARD_CB( game_type_select_cb )
{
	if (release) return;
	
	if ( !special ) {
		key = (int) tolower( (char) key );
		
		switch( key ) {
			case 'q':
			case 27: /* Esc */
				winsys_exit(0);
				break;
			case 'e':
			case 13: /* Enter */
				if ( enter_event_btn ) {
					button_simulate_mouse_click( enter_event_btn );
				}
				break;
			case 'p':
				if ( practice_btn ) {
					button_simulate_mouse_click( practice_btn );
				}
				break;
			case 'c':
				if ( credits_btn ) {
					button_simulate_mouse_click( credits_btn );
				}
				break;
		}
	}
	
	winsys_post_redisplay();
}
END_KEYBOARD_CB

void game_type_select_register()
{
	int status = 0;
	
	status |=
	add_keymap_entry( GAME_TYPE_SELECT,
					 DEFAULT_CALLBACK, NULL, NULL, game_type_select_cb );
	register_loop_funcs( GAME_TYPE_SELECT, 
						game_type_select_init,
						game_type_select_loop,
						game_type_select_term );
	
}


/* EOF */
