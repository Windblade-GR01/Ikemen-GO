--;===========================================================
--; DEFAULT VALUES
--;===========================================================
--This pre-made table (3/4 of the whole file) contains all default values used in screenpack. New table from parsed DEF file is merged on top of this one.
--This is important because there are more params available in Ikemen. Whole screenpack code refers to these values.
local motif =
{
	def = main.motifDef,
	info =
	{
		name = 'Default',
		author = 'Elecbyte',
		versiondate = '09,01,2009',
		mugenversion = '1.0',
		localcoord = {320, 240},
	},
	files =
	{
		spr = 'data/system.sff',
		snd = 'data/system.snd',
		logo_storyboard = '',
		intro_storyboard = '',
		select = 'data/select.def',
		fight = 'data/fight.def',
		font =
		{
			[1] = 'f-4x6.fnt',
			[2] = 'f-6x9.def',
			[3] = 'jg.fnt',
		},
		font_height = {},
		glyphs = 'data/glyphs.sff', --Ikemen feature
	},
	ja_files = {}, --not used in Ikemen
	music =
	{
		title_bgm = '',
		title_bgm_volume = 100,
		title_bgm_loop = 1,
		title_bgm_loopstart = 0,
		title_bgm_loopend = 0,
		select_bgm = '',
		select_bgm_volume = 100,
		select_bgm_loop = 1,
		select_bgm_loopstart = 0,
		select_bgm_loopend = 0,
		vs_bgm = '',
		vs_bgm_volume = 100,
		vs_bgm_loop = 1,
		vs_bgm_loopstart = 0,
		vs_bgm_loopend = 0,
		victory_bgm = '',
		victory_bgm_volume = 100,
		victory_bgm_loop = 1,
		victory_bgm_loopstart = 0,
		victory_bgm_loopend = 0,
		option_bgm = '', --Ikemen feature
		option_bgm_volume = 100, --Ikemen feature
		option_bgm_loop = 1, --Ikemen feature
		option_bgm_loopstart = 0, --Ikemen feature
		option_bgm_loopend = 0, --Ikemen feature
		replay_bgm = '', --Ikemen feature
		replay_bgm_volume = 100, --Ikemen feature
		replay_bgm_loop = 1, --Ikemen feature
		replay_bgm_loopstart = 0, --Ikemen feature
		replay_bgm_loopend = 0, --Ikemen feature
		continue_bgm = '', --Ikemen feature
		continue_bgm_volume = 100, --Ikemen feature
		continue_bgm_loop = 1, --Ikemen feature
		continue_bgm_loopstart = 0, --Ikemen feature
		continue_bgm_loopend = 0, --Ikemen feature
		continue_end_bgm = '', --Ikemen feature
		continue_end_bgm_volume = 100, --Ikemen feature
		continue_end_bgm_loop = 0, --Ikemen feature
		continue_end_bgm_loopstart = 0, --Ikemen feature
		continue_end_bgm_loopend = 0, --Ikemen feature
		results_bgm = '', --Ikemen feature
		results_bgm_volume = 100, --Ikemen feature
		results_bgm_loop = 1, --Ikemen feature
		results_bgm_loopstart = 0, --Ikemen feature
		results_bgm_loopend = 0, --Ikemen feature
		results_lose_bgm = '', --Ikemen feature
		results_lose_bgm_volume = 100, --Ikemen feature
		results_lose_bgm_loop = 1, --Ikemen feature
		results_lose_bgm_loopstart = 0, --Ikemen feature
		results_lose_bgm_loopend = 0, --Ikemen feature
		tournament_bgm = '', --Ikemen feature
		tournament_bgm_volume = 100, --Ikemen feature
		tournament_bgm_loop = 1, --Ikemen feature
		tournament_bgm_loopstart = 0, --Ikemen feature
		tournament_bgm_loopend = 0, --Ikemen feature
	},
	title_info =
	{
		fadein_time = 10,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 10,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		title_offset = {159, 19}, --Ikemen feature
		title_font = {-1, 0, 0, 255, 255, 255, 255, 0},
		title_font_scale = {1.0, 1.0}, --Ikemen feature
		title_font_height = -1, --Ikemen feature
		title_text = 'MAIN MENU', --Ikemen feature
		loading_offset = {main.SP_Localcoord[1] - math.floor(10 * main.SP_Localcoord[1] / 320 + 0.5), main.SP_Localcoord[2] - 8}, --Ikemen feature (310, 232)
		loading_font = {'debug.def', 0, -1, 191, 191, 191, 255, 0}, --Ikemen feature
		loading_font_scale = {1.0, 1.0}, --Ikemen feature
		loading_font_height = -1, --Ikemen feature
		loading_text = 'LOADING...', --Ikemen feature
		footer1_offset = {math.floor(2 * main.SP_Localcoord[1] / 320 + 0.5), main.SP_Localcoord[2]}, --Ikemen feature (2, 240)
		footer1_font = {'debug.def', 0, 1, 191, 191, 191, 255, 0}, --Ikemen feature
		footer1_font_scale = {1.0, 1.0}, --Ikemen feature
		footer1_font_height = -1, --Ikemen feature
		footer1_text = 'I.K.E.M.E.N. GO', --Ikemen feature
		footer2_offset = {main.SP_Localcoord[1] / 2, main.SP_Localcoord[2]}, --Ikemen feature (160, 240)
		footer2_font = {'debug.def', 0, 0, 191, 191, 191, 255, 0}, --Ikemen feature
		footer2_font_scale = {1.0, 1.0}, --Ikemen feature
		footer2_font_height = -1, --Ikemen feature
		footer2_text = 'Press F1 for info', --Ikemen feature
		footer3_offset = {main.SP_Localcoord[1] - math.floor(2 * main.SP_Localcoord[1] / 320 + 0.5), main.SP_Localcoord[2]}, --Ikemen feature (318, 240)
		footer3_font = {'debug.def', 0, -1, 191, 191, 191, 255, 0}, --Ikemen feature
		footer3_font_scale = {1.0, 1.0}, --Ikemen feature
		footer3_font_height = -1, --Ikemen feature
		footer3_text = 'v0.95', --Ikemen feature
		footer_boxbg_visible = 1, --Ikemen feature
		footer_boxbg_coords = {0, main.SP_Localcoord[2] - 7, main.SP_Localcoord[1] - 1, main.SP_Localcoord[2] - 1}, --Ikemen feature (0, 233, 319, 239)
		footer_boxbg_col = {0, 0, 64}, --Ikemen feature
		footer_boxbg_alpha = {255, 100}, --Ikemen feature
		connecting_offset = {math.floor(10 * main.SP_Localcoord[1] / 320 + 0.5), 40}, --Ikemen feature
		connecting_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		connecting_font_scale = {1.0, 1.0}, --Ikemen feature
		connecting_font_height = -1, --Ikemen feature
		connecting_host_text = 'Waiting for player 2... (%s)', --Ikemen feature
		connecting_join_text = 'Now connecting to %s... (%s)', --Ikemen feature
		connecting_boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		connecting_boxbg_col = {0, 0, 0}, --Ikemen feature
		connecting_boxbg_alpha = {20, 100}, --Ikemen feature
		input_ip_name_text = 'Enter Host display name, e.g. John.\nExisting entries can be removed with DELETE button.', --Ikemen feature
		input_ip_address_text = 'Enter Host IP address, e.g. 127.0.0.1\nCopied text can be pasted with INSERT button.', --Ikemen feature
		menu_key_next = '$D&$F', --Ikemen feature
		menu_key_previous = '$U&$B', --Ikemen feature
		menu_key_accept = 'a&b&c&x&y&z&s', --Ikemen feature
		menu_pos = {159, 158},
		menu_item_font = {'f-6x9.def', 0, 0, 191, 191, 191, 255, 0},
		menu_item_font_scale = {1.0, 1.0}, --broken parameter in mugen 1.1: http://mugenguild.com/forum/msg.1905756
		menu_item_font_height = -1, --Ikemen feature
		menu_item_active_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0},
		menu_item_active_font_scale = {1.0, 1.0}, --broken parameter in mugen 1.1: http://mugenguild.com/forum/msg.1905756
		menu_item_active_font_height = -1, --Ikemen feature
		menu_item_spacing = {0, 13},
		--menu_itemname_arcade = 'ARCADE',
		--menu_itemname_versus = 'VS MODE',
		--menu_itemname_teamarcade = 'TEAM ARCADE',
		--menu_itemname_teamcoop = 'TEAM CO-OP',
		--menu_itemname_versus = 'VS MODE',
		--menu_itemname_teamversus = 'TEAM VERSUS',
		--menu_itemname_storymode = 'STORY MODE', --Ikemen feature (not implemented yet)
		--menu_itemname_serverhost = 'HOST GAME', --Ikemen feature
		--menu_itemname_serverjoin = 'JOIN GAME', --Ikemen feature
		--menu_itemname_joinadd = 'NEW ADDRESS', --Ikemen feature
		--menu_itemname_netplayversus = 'VERSUS', --Ikemen feature
		--menu_itemname_netplayteamcoop = 'ARCADE CO-OP', --Ikemen feature
		--menu_itemname_netplaysurvivalcoop = 'SURVIVAL CO-OP', --Ikemen feature
		--menu_itemname_tournament32 = 'ROUND OF 32', --Ikemen feature (not implemented yet)
		--menu_itemname_tournament16 = 'ROUND OF 16', --Ikemen feature (not implemented yet)
		--menu_itemname_tournament8 = 'QUARTERFINALS', --Ikemen feature (not implemented yet)
		--menu_itemname_training = 'TRAINING',
		--menu_itemname_freebattle = 'QUICK MATCH', --Ikemen feature
		--menu_itemname_trials = 'TRIALS', --Ikemen feature (not implemented yet)
		--menu_itemname_timeattack = 'TIME ATTACK', --Ikemen feature
		--menu_itemname_survival = 'SURVIVAL',
		--menu_itemname_survivalcoop = 'SURVIVAL CO-OP',
		--menu_itemname_bossrush = 'BOSS RUSH', --Ikemen feature
		--menu_itemname_vs100kumite = 'VS 100 KUMITE', --Ikemen feature
		--menu_itemname_timechallenge = 'TIME CHALLENGE', --Ikemen feature
		--menu_itemname_scorechallenge = 'SCORE CHALLENGE', --Ikemen feature
		--menu_itemname_bonusgames = 'BONUS GAMES', --Ikemen feature
		--menu_itemname_watch = 'AI MATCH',
		--menu_itemname_randomtest = 'RANDOMTEST', --Ikemen feature
		--menu_itemname_replay = 'REPLAY', --Ikemen feature
		--menu_itemname_records = 'RECORDS', --Ikemen feature (not implemented yet)
		--menu_itemname_ranking = 'RANKING', --Ikemen feature (not implemented yet)
		--menu_itemname_options = 'OPTIONS',
		--menu_itemname_back = 'BACK', --Ikemen feature
		--menu_itemname_exit = 'EXIT',
		menu_window_margins_y = {12, 8},
		menu_window_visibleitems = 5,
		--menu_arrow_up_anim = nil, --Ikemen feature
		menu_arrow_up_spr = {}, --Ikemen feature
		menu_arrow_up_offset = {0, 0}, --Ikemen feature
		menu_arrow_up_facing = 1, --Ikemen feature
		menu_arrow_up_scale = {1.0, 1.0}, --Ikemen feature
		--menu_arrow_down_anim = nil, --Ikemen feature
		menu_arrow_down_spr = {}, --Ikemen feature
		menu_arrow_down_offset = {0, 0}, --Ikemen feature
		menu_arrow_down_facing = 1, --Ikemen feature
		menu_arrow_down_scale = {1.0, 1.0}, --Ikemen feature
		menu_boxcursor_visible = 1,
		menu_boxcursor_coords = {-40, -10, 39, 2},
		menu_boxcursor_col = {255, 255, 255}, --Ikemen feature
		menu_boxcursor_alpharange = {10, 40, 2, 255, 255, 0}, --Ikemen feature
		menu_boxbg_visible = 0, --Ikemen feature
		menu_boxbg_col = {0, 0, 0}, --Ikemen feature
		menu_boxbg_alpha = {20, 100}, --Ikemen feature
		menu_title_uppercase = 1, --Ikemen feature
		cursor_move_snd = {100, 0},
		cursor_done_snd = {100, 1},
		cancel_snd = {100, 2},
	},
	titlebgdef =
	{
		spr = '',
		bgclearcolor = {0, 0, 0},
	},
	infobox =
	{
		title = '', --Ikemen feature
		title_pos = {159, 19}, --Ikemen feature
		title_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		title_font_scale = {1.0, 1.0}, --Ikemen feature
		title_font_height = -1, --Ikemen feature
		text = "Welcome to SUEHIRO's I.K.E.M.E.N GO engine!\n\n* This is a public development release, for testing purposes.\n* This build may contain bugs and incomplete features.\n* Your help and cooperation are appreciated!\n* I.K.E.M.E.N GO source code: https://osdn.net/users/supersuehiro/\n* Feedback: https://mugenguild.com/forum/topics/ikemen-go-184152.0.html", --Ikemen feature (requires new 'text = ' entry under [Infobox] section)
		text_pos = {25, 32}, --Ikemen feature
		text_font = {'debug.def', 0, 1, 191, 191, 191, 255, 0},
		text_font_scale = {1.0, 1.0}, --Ikemen feature
		text_font_height = -1, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
	},
	infobox_text = '', --not used in Ikemen
	ja_infobox_text = '', --not used in Ikemen
	select_info =
	{
		fadein_time = 10,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 10,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		rows = 2,
		columns = 5,
		rows_scrolling = 0, --Ikemen feature
		wrapping = 0,
		wrapping_x = 1, --Ikemen feature
		wrapping_y = 1, --Ikemen feature
		pos = {90, 170},
		doubleselect_enabled = 0, --Ikemen feature
		p1_doubleselect_offset = {-80, 0}, --Ikemen feature
		p2_doubleselect_offset = {-1, 0}, --Ikemen feature
		showemptyboxes = 0,
		moveoveremptyboxes = 0,
		searchemptyboxesup = 0, --Ikemen feature
		searchemptyboxesdown = 0, --Ikemen feature
		cell_size = {27, 27},
		cell_spacing = {2, 2}, --Ikemen feature (optionally accepts x, y values instead of a single one for both coordinates)
		--cell_bg_anim = nil,
		cell_bg_spr = {},
		cell_bg_offset = {0, 0},
		cell_bg_facing = 1,
		cell_bg_scale = {1.0, 1.0},
		--cell_random_anim = nil,
		cell_random_spr = {},
		cell_random_offset = {0, 0},
		cell_random_facing = 1,
		cell_random_scale = {1.0, 1.0},
		cell_random_switchtime = 4,
		--cell_<col>_<row>_offset = {0, 0}, --Ikemen feature
		--cell_<col>_<row>_facing = 1, --Ikemen feature
		p1_cursor_startcell = {0, 0},
		--p1_cursor_active_anim = nil,
		p1_cursor_active_spr = {},
		p1_cursor_active_offset = {0, 0},
		p1_cursor_active_facing = 1,
		p1_cursor_active_scale = {1.0, 1.0},
		--p1_cursor_done_anim = nil,
		p1_cursor_done_spr = {},
		p1_cursor_done_offset = {0, 0},
		p1_cursor_done_facing = 1,
		p1_cursor_done_scale = {1.0, 1.0},
		p1_cursor_move_snd = {100, 0},
		p1_cursor_done_snd = {100, 1},
		p1_random_move_snd = {100, 0},
		p2_cursor_startcell = {0, 4},
		--p2_cursor_active_anim = nil,
		p2_cursor_active_spr = {},
		p2_cursor_active_offset = {0, 0},
		p2_cursor_active_facing = 1,
		p2_cursor_active_scale = {1.0, 1.0},
		--p2_cursor_done_anim = nil,
		p2_cursor_done_spr = {},
		p2_cursor_done_offset = {0, 0},
		p2_cursor_done_facing = 1,
		p2_cursor_done_scale = {1.0, 1.0},
		p2_cursor_blink = 1,
		p2_cursor_move_snd = {100, 0},
		p2_cursor_done_snd = {100, 1},
		p2_random_move_snd = {100, 0},
		random_move_snd_cancel = 0,
		stage_move_snd = {100, 0},
		stage_done_snd = {100, 1},
		cancel_snd = {100, 2},
		portrait_spr = {9000, 0},
		portrait_offset = {0, 0},
		portrait_scale = {1.0, 1.0},
		title_offset = {0, 0},
		title_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0},
		title_font_scale = {1.0, 1.0},
		title_font_height = -1, --Ikemen feature
		title_arcade_text = 'Arcade', --Ikemen feature
		title_teamarcade_text = 'Team Arcade', --Ikemen feature
		title_teamcoop_text = 'Team Cooperative', --Ikemen feature
		title_versus_text = 'Versus Mode', --Ikemen feature
		title_teamversus_text = 'Team Versus', --Ikemen feature
		title_storymode_text = 'Story Mode', --Ikemen feature (not implemented yet)
		title_netplayversus_text = 'Online Versus', --Ikemen feature
		title_netplayteamcoop_text = 'Online Cooperative', --Ikemen feature
		title_netplaysurvivalcoop_text = 'Online Survival', --Ikemen feature
		title_tournament32_text = 'Tournament Mode', --Ikemen feature (not implemented yet)
		title_tournament16_text = 'Tournament Mode', --Ikemen feature (not implemented yet)
		title_tournament8_text = 'Tournament Mode', --Ikemen feature (not implemented yet)
		title_training_text = 'Training Mode', --Ikemen feature
		title_freebattle_text = 'Quick Match', --Ikemen feature
		title_timeattack_text = 'Time Attack', --Ikemen feature
		title_survival_text = 'Survival', --Ikemen feature
		title_survivalcoop_text = 'Survival Cooperative', --Ikemen feature
		title_bossrush_text = 'Boss Rush', --Ikemen feature
		title_vs100kumite_text = 'VS 100 Kumite', --Ikemen feature
		title_timechallenge_text = 'Time Challenge', --Ikemen feature
		title_scorechallenge_text = 'Score Challenge', --Ikemen feature
		title_watch_text = 'Watch Mode', --Ikemen feature
		--title_replay_text = 'Replay', --Ikemen feature
		p1_face_spr = {9000, 1},
		p1_face_offset = {0, 0},
		p1_face_facing = 1,
		p1_face_scale = {1.0, 1.0},
		p1_face_window = {0, 0, config.GameWidth, config.GameHeight},
		p1_face_num = 1, --Ikemen feature
		p1_face_spacing = {0, 0}, --Ikemen feature
		p1_c1_face_offset = {0, 0}, --Ikemen feature
		p1_c1_face_scale = {1.0, 1.0}, --Ikemen feature
		p1_c2_face_offset = {0, 0}, --Ikemen feature
		p1_c2_face_scale = {1.0, 1.0}, --Ikemen feature
		p1_c3_face_offset = {0, 0}, --Ikemen feature
		p1_c3_face_scale = {1.0, 1.0}, --Ikemen feature
		p1_c4_face_offset = {0, 0}, --Ikemen feature
		p1_c4_face_scale = {1.0, 1.0}, --Ikemen feature
		p2_face_spr = {9000, 1},
		p2_face_offset = {0, 0},
		p2_face_facing = -1,
		p2_face_scale = {1.0, 1.0},
		p2_face_window = {0, 0, config.GameWidth, config.GameHeight},
		p2_face_num = 1, --Ikemen feature
		p2_face_spacing = {0, 0}, --Ikemen feature
		p2_c1_face_offset = {0, 0}, --Ikemen feature
		p2_c1_face_scale = {1.0, 1.0}, --Ikemen feature
		p2_c2_face_offset = {0, 0}, --Ikemen feature
		p2_c2_face_scale = {1.0, 1.0}, --Ikemen feature
		p2_c3_face_offset = {0, 0}, --Ikemen feature
		p2_c3_face_scale = {1.0, 1.0}, --Ikemen feature
		p2_c4_face_offset = {0, 0}, --Ikemen feature
		p2_c4_face_scale = {1.0, 1.0}, --Ikemen feature
		p1_name_offset = {0, 0},
		p1_name_font = {'jg.fnt', 4, 1, 255, 255, 255, 255, 0},
		p1_name_font_scale = {1.0, 1.0},
		p1_name_font_height = -1, --Ikemen feature
		p1_name_spacing = {0, 14},
		p2_name_offset = {0, 0},
		p2_name_font = {'jg.fnt', 1, -1, 255, 255, 255, 255, 0},
		p2_name_font_scale = {1.0, 1.0},
		p2_name_font_height = -1, --Ikemen feature
		p2_name_spacing = {0, 14},
		stage_pos = {0, 0},
		stage_active_offset = {0, 0}, --Ikemen feature
		stage_active_font = {'debug.def', 0, 0, 255, 255, 255, 255, 0},
		stage_active_font_scale = {1.0, 1.0},
		stage_active_font_height = -1, --Ikemen feature
		stage_active2_offset = {0, 0}, --Ikemen feature
		stage_active2_font = {'debug.def', 0, 0, 255, 255, 255, 255, 0},
		stage_active2_font_scale = {1.0, 1.0},
		stage_active2_font_height = -1, --Ikemen feature
		stage_done_offset = {0, 0}, --Ikemen feature
		stage_done_font = {'debug.def', 0, 0, 255, 255, 255, 255, 0},
		stage_done_font_scale = {1.0, 1.0},
		stage_done_font_height = -1, --Ikemen feature
		stage_text = 'Stage %i: %s', --Ikemen feature
		stage_random_text = 'Stage: Random', --Ikemen feature
		stage_portrait_spr = {9000, 0}, --Ikemen feature
		stage_portrait_offset = {0, 0}, --Ikemen feature
		stage_portrait_scale = {1.0, 1.0}, --Ikemen feature
		stage_portrait_random_spr = {}, --Ikemen feature
		--stage_portrait_random_anim = nil, --Ikemen feature
		stage_portrait_random_offset = {0, 0}, --Ikemen feature
		stage_portrait_random_scale = {1.0, 1.0}, --Ikemen feature
		stage_portrait_window = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature
		teammenu_key_next = '$D', --Ikemen feature
		teammenu_key_previous = '$U', --Ikemen feature
		teammenu_key_add = '$F', --Ikemen feature
		teammenu_key_subtract = '$B', --Ikemen feature
		teammenu_key_accept = 'a&b&c&x&y&z&s', --Ikemen feature
		teammenu_move_wrapping = 1,
		teammenu_itemname_single = 'Single', --Ikemen feature
		teammenu_itemname_simul = 'Simul', --Ikemen feature
		teammenu_itemname_turns = 'Turns', --Ikemen feature
		teammenu_itemname_tag = '', --Ikemen feature (Tag)
		teammenu_itemname_ratio = '', --Ikemen feature (Ratio)
		p1_teammenu_pos = {0, 0},
		--p1_teammenu_bg_anim = nil,
		p1_teammenu_bg_spr = {},
		p1_teammenu_bg_offset = {0, 0},
		p1_teammenu_bg_facing = 1,
		p1_teammenu_bg_scale = {1.0, 1.0},
		--p1_teammenu_bg_single_anim = nil, --Ikemen feature
		p1_teammenu_bg_single_spr = {}, --Ikemen feature
		p1_teammenu_bg_single_offset = {0, 0}, --Ikemen feature
		p1_teammenu_bg_single_facing = 1, --Ikemen feature
		p1_teammenu_bg_single_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_bg_simul_anim = nil, --Ikemen feature
		p1_teammenu_bg_simul_spr = {}, --Ikemen feature
		p1_teammenu_bg_simul_offset = {0, 0}, --Ikemen feature
		p1_teammenu_bg_simul_facing = 1, --Ikemen feature
		p1_teammenu_bg_simul_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_bg_turns_anim = nil, --Ikemen feature
		p1_teammenu_bg_turns_spr = {}, --Ikemen feature
		p1_teammenu_bg_turns_offset = {0, 0}, --Ikemen feature
		p1_teammenu_bg_turns_facing = 1, --Ikemen feature
		p1_teammenu_bg_turns_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_bg_tag_anim = nil, --Ikemen feature
		p1_teammenu_bg_tag_spr = {}, --Ikemen feature
		p1_teammenu_bg_tag_offset = {0, 0}, --Ikemen feature
		p1_teammenu_bg_tag_facing = 1, --Ikemen feature
		p1_teammenu_bg_tag_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_bg_ratio_anim = nil, --Ikemen feature
		p1_teammenu_bg_ratio_spr = {}, --Ikemen feature
		p1_teammenu_bg_ratio_offset = {0, 0}, --Ikemen feature
		p1_teammenu_bg_ratio_facing = 1, --Ikemen feature
		p1_teammenu_bg_ratio_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_selftitle_anim = nil,
		p1_teammenu_selftitle_spr = {},
		p1_teammenu_selftitle_offset = {0, 0},
		p1_teammenu_selftitle_facing = 1,
		p1_teammenu_selftitle_scale = {1.0, 1.0},
		p1_teammenu_selftitle_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0},
		p1_teammenu_selftitle_font_scale = {1.0, 1.0},
		p1_teammenu_selftitle_font_height = -1, --Ikemen feature
		p1_teammenu_selftitle_text = '',
		--p1_teammenu_enemytitle_anim = nil,
		p1_teammenu_enemytitle_spr = {},
		p1_teammenu_enemytitle_offset = {0, 0},
		p1_teammenu_enemytitle_facing = 1,
		p1_teammenu_enemytitle_scale = {1.0, 1.0},
		p1_teammenu_enemytitle_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0},
		p1_teammenu_enemytitle_font_scale = {1.0, 1.0},
		p1_teammenu_enemytitle_font_height = -1, --Ikemen feature
		p1_teammenu_enemytitle_text = '',
		p1_teammenu_move_snd = {100, 0},
		p1_teammenu_value_snd = {100, 0},
		p1_teammenu_done_snd = {100, 1},
		p1_teammenu_item_offset = {0, 0},
		p1_teammenu_item_spacing = {0, 15},
		p1_teammenu_item_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0},
		p1_teammenu_item_font_scale = {1.0, 1.0},
		p1_teammenu_item_font_height = -1, --Ikemen feature
		p1_teammenu_item_active_font = {'jg.fnt', 3, 1, 255, 255, 255, 255, 0},
		p1_teammenu_item_active_font_scale = {1.0, 1.0},
		p1_teammenu_item_active_font_height = -1, --Ikemen feature
		p1_teammenu_item_active2_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0},
		p1_teammenu_item_active2_font_scale = {1.0, 1.0},
		p1_teammenu_item_active2_font_height = -1, --Ikemen feature
		--p1_teammenu_item_cursor_anim = nil,
		p1_teammenu_item_cursor_spr = {},
		p1_teammenu_item_cursor_offset = {0, 0},
		p1_teammenu_item_cursor_facing = 1,
		p1_teammenu_item_cursor_scale = {1.0, 1.0},
		--p1_teammenu_value_icon_anim = nil,
		p1_teammenu_value_icon_spr = {},
		p1_teammenu_value_icon_offset = {0, 0},
		p1_teammenu_value_icon_facing = 1,
		p1_teammenu_value_icon_scale = {1.0, 1.0},
		--p1_teammenu_value_empty_icon_anim = nil,
		p1_teammenu_value_empty_icon_spr = {},
		p1_teammenu_value_empty_icon_offset = {0, 0},
		p1_teammenu_value_empty_icon_facing = 1,
		p1_teammenu_value_empty_icon_scale = {1.0, 1.0},
		p1_teammenu_value_spacing = {6, 0},
		--p1_teammenu_ratio1_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio1_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio1_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio1_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio1_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_ratio2_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio2_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio2_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio2_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio2_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_ratio3_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio3_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio3_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio3_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio3_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_ratio4_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio4_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio4_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio4_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio4_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_ratio5_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio5_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio5_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio5_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio5_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_ratio6_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio6_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio6_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio6_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio6_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p1_teammenu_ratio7_icon_anim = nil, --Ikemen feature
		p1_teammenu_ratio7_icon_spr = {}, --Ikemen feature
		p1_teammenu_ratio7_icon_offset = {0, 0}, --Ikemen feature
		p1_teammenu_ratio7_icon_facing = 1, --Ikemen feature
		p1_teammenu_ratio7_icon_scale = {1.0, 1.0}, --Ikemen feature
		p2_teammenu_pos = {0, 0},
		--p2_teammenu_bg_anim = nil,
		p2_teammenu_bg_spr = {},
		p2_teammenu_bg_offset = {0, 0},
		p2_teammenu_bg_facing = 1,
		p2_teammenu_bg_scale = {1.0, 1.0},
		--p2_teammenu_bg_single_anim = nil, --Ikemen feature
		p2_teammenu_bg_single_spr = {}, --Ikemen feature
		p2_teammenu_bg_single_offset = {0, 0}, --Ikemen feature
		p2_teammenu_bg_single_facing = 1, --Ikemen feature
		p2_teammenu_bg_single_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_bg_simul_anim = nil, --Ikemen feature
		p2_teammenu_bg_simul_spr = {}, --Ikemen feature
		p2_teammenu_bg_simul_offset = {0, 0}, --Ikemen feature
		p2_teammenu_bg_simul_facing = 1, --Ikemen feature
		p2_teammenu_bg_simul_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_bg_turns_anim = nil, --Ikemen feature
		p2_teammenu_bg_turns_spr = {}, --Ikemen feature
		p2_teammenu_bg_turns_offset = {0, 0}, --Ikemen feature
		p2_teammenu_bg_turns_facing = 1, --Ikemen feature
		p2_teammenu_bg_turns_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_bg_tag_anim = nil, --Ikemen feature
		p2_teammenu_bg_tag_spr = {}, --Ikemen feature
		p2_teammenu_bg_tag_offset = {0, 0}, --Ikemen feature
		p2_teammenu_bg_tag_facing = 1, --Ikemen feature
		p2_teammenu_bg_tag_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_bg_ratio_anim = nil, --Ikemen feature
		p2_teammenu_bg_ratio_spr = {}, --Ikemen feature
		p2_teammenu_bg_ratio_offset = {0, 0}, --Ikemen feature
		p2_teammenu_bg_ratio_facing = 1, --Ikemen feature
		p2_teammenu_bg_ratio_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_selftitle_anim = nil,
		p2_teammenu_selftitle_spr = {},
		p2_teammenu_selftitle_offset = {0, 0},
		p2_teammenu_selftitle_facing = 1,
		p2_teammenu_selftitle_scale = {1.0, 1.0},
		p2_teammenu_selftitle_font = {'jg.fnt', 0, -1, 255, 255, 255, 255, 0},
		p2_teammenu_selftitle_font_scale = {1.0, 1.0},
		p2_teammenu_selftitle_font_height = -1, --Ikemen feature
		p2_teammenu_selftitle_text = '',
		--p2_teammenu_enemytitle_anim = nil,
		p2_teammenu_enemytitle_spr = {},
		p2_teammenu_enemytitle_offset = {0, 0},
		p2_teammenu_enemytitle_facing = 1,
		p2_teammenu_enemytitle_scale = {1.0, 1.0},
		p2_teammenu_enemytitle_font = {'jg.fnt', 0, -1, 255, 255, 255, 255, 0},
		p2_teammenu_enemytitle_font_scale = {1.0, 1.0},
		p2_teammenu_enemytitle_font_height = -1, --Ikemen feature
		p2_teammenu_enemytitle_text = '',
		p2_teammenu_move_snd = {100, 0},
		p2_teammenu_value_snd = {100, 0},
		p2_teammenu_done_snd = {100, 1},
		p2_teammenu_item_offset = {0, 0},
		p2_teammenu_item_spacing = {0, 15},
		p2_teammenu_item_font = {'jg.fnt', 0, -1, 255, 255, 255, 255, 0},
		p2_teammenu_item_font_scale = {1.0, 1.0},
		p2_teammenu_item_font_height = -1, --Ikemen feature
		p2_teammenu_item_active_font = {'jg.fnt', 1, -1, 255, 255, 255, 255, 0},
		p2_teammenu_item_active_font_scale = {1.0, 1.0},
		p2_teammenu_item_active_font_height = -1, --Ikemen feature
		p2_teammenu_item_active2_font = {'jg.fnt', 0, -1, 255, 255, 255, 255, 0},
		p2_teammenu_item_active2_font_scale = {1.0, 1.0},
		p2_teammenu_item_active2_font_height = -1, --Ikemen feature
		--p2_teammenu_item_cursor_anim = nil,
		p2_teammenu_item_cursor_spr = {},
		p2_teammenu_item_cursor_offset = {0, 0},
		p2_teammenu_item_cursor_facing = 1,
		p2_teammenu_item_cursor_scale = {1.0, 1.0},
		--p2_teammenu_value_icon_anim = nil,
		p2_teammenu_value_icon_spr = {},
		p2_teammenu_value_icon_offset = {0, 0},
		p2_teammenu_value_icon_facing = 1,
		p2_teammenu_value_icon_scale = {1.0, 1.0},
		--p2_teammenu_value_empty_icon_anim = nil,
		p2_teammenu_value_empty_icon_spr = {},
		p2_teammenu_value_empty_icon_offset = {0, 0},
		p2_teammenu_value_empty_icon_facing = 1,
		p2_teammenu_value_empty_icon_scale = {1.0, 1.0},
		p2_teammenu_value_spacing = {-6, 0},
		--p2_teammenu_ratio1_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio1_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio1_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio1_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio1_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_ratio2_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio2_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio2_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio2_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio2_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_ratio3_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio3_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio3_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio3_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio3_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_ratio4_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio4_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio4_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio4_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio4_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_ratio5_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio5_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio5_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio5_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio5_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_ratio6_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio6_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio6_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio6_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio6_icon_scale = {1.0, 1.0}, --Ikemen feature
		--p2_teammenu_ratio7_icon_anim = nil, --Ikemen feature
		p2_teammenu_ratio7_icon_spr = {}, --Ikemen feature
		p2_teammenu_ratio7_icon_offset = {0, 0}, --Ikemen feature
		p2_teammenu_ratio7_icon_facing = 1, --Ikemen feature
		p2_teammenu_ratio7_icon_scale = {1.0, 1.0}, --Ikemen feature
		timer_enabled = 0, --Ikemen feature
		timer_offset = {0, 0}, --Ikemen feature
		timer_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		timer_font_scale = {1.0, 1.0}, --Ikemen feature
		timer_font_height = -1, --Ikemen feature
		timer_count = 99, --Ikemen feature
		timer_framespercount = 60, --Ikemen feature
		timer_displaytime = 10, --Ikemen feature
		record_offset = {0, 0}, --Ikemen feature
		record_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		record_font_scale = {1.0, 1.0}, --Ikemen feature
		record_font_height = -1, --Ikemen feature
		record_scorechallenge_text = '', --Ikemen feature
		record_timechallenge_text = '', --Ikemen feature
		p1_select_snd = {-1, 0}, --Ikemen feature
		p2_select_snd = {-1, 0}, --Ikemen feature
	},
	selectbgdef =
	{
		spr = '',
		bgclearcolor = {0, 0, 0},
	},
	vs_screen =
	{
		fadein_time = 15,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 15,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		time = 150,
		time_order = 60, --Ikemen feature
		match_text = 'Match %i',
		match_offset = {159, 12},
		match_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0},
		match_font_scale = {1.0, 1.0},
		match_font_height = -1, --Ikemen feature
		p1_pos = {0, 0},
		p1_spr = {9000, 1},
		p1_offset = {0, 0},
		p1_facing = 1,
		p1_scale = {1.0, 1.0},
		p1_window = {0, 0, config.GameWidth, config.GameHeight},
		p1_num = 1, --Ikemen feature
		p1_spacing = {0, 0}, --Ikemen feature
		p1_c1_offset = {0, 0}, --Ikemen feature
		p1_c1_scale = {1.0, 1.0}, --Ikemen feature
		p1_c1_slide_speed = {0, 0}, --Ikemen feature
		p1_c1_slide_dist = {0, 0}, --Ikemen feature
		p1_c2_offset = {0, 0}, --Ikemen feature
		p1_c2_scale = {1.0, 1.0}, --Ikemen feature
		p1_c2_slide_speed = {0, 0}, --Ikemen feature
		p1_c2_slide_dist = {0, 0}, --Ikemen feature
		p1_c3_offset = {0, 0}, --Ikemen feature
		p1_c3_scale = {1.0, 1.0}, --Ikemen feature
		p1_c3_slide_speed = {0, 0}, --Ikemen feature
		p1_c3_slide_dist = {0, 0}, --Ikemen feature
		p1_c4_offset = {0, 0}, --Ikemen feature
		p1_c4_scale = {1.0, 1.0}, --Ikemen feature
		p1_c4_slide_speed = {0, 0}, --Ikemen feature
		p1_c4_slide_dist = {0, 0}, --Ikemen feature
		p2_pos = {0, 0},
		p2_spr = {9000, 1},
		p2_offset = {0, 0},
		p2_facing = -1,
		p2_scale = {1.0, 1.0},
		p2_window = {0, 0, config.GameWidth, config.GameHeight},
		p2_num = 1, --Ikemen feature
		p2_spacing = {0, 0}, --Ikemen feature
		p2_c1_offset = {0, 0}, --Ikemen feature
		p2_c1_scale = {1.0, 1.0}, --Ikemen feature
		p2_c1_slide_speed = {0, 0}, --Ikemen feature
		p2_c1_slide_dist = {0, 0}, --Ikemen feature
		p2_c2_offset = {0, 0}, --Ikemen feature
		p2_c2_scale = {1.0, 1.0}, --Ikemen feature
		p2_c2_slide_speed = {0, 0}, --Ikemen feature
		p2_c2_slide_dist = {0, 0}, --Ikemen feature
		p2_c3_offset = {0, 0}, --Ikemen feature
		p2_c3_scale = {1.0, 1.0}, --Ikemen feature
		p2_c3_slide_speed = {0, 0}, --Ikemen feature
		p2_c3_slide_dist = {0, 0}, --Ikemen feature
		p2_c4_offset = {0, 0}, --Ikemen feature
		p2_c4_scale = {1.0, 1.0}, --Ikemen feature
		p2_c4_slide_speed = {0, 0}, --Ikemen feature
		p2_c4_slide_dist = {0, 0}, --Ikemen feature
		p1_name_pos = {0, 0},
		p1_name_offset = {0, 0},
		p1_name_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0},
		p1_name_font_scale = {1.0, 1.0},
		p1_name_font_height = -1, --Ikemen feature
		p1_name_spacing = {0, 14},
		p2_name_pos = {0, 0},
		p2_name_offset = {0, 0},
		p2_name_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0},
		p2_name_font_scale = {1.0, 1.0},
		p2_name_font_height = -1, --Ikemen feature
		p2_name_spacing = {0, 14},
		--p1_name_active_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		--p1_name_active_font_scale = {1.0, 1.0}, --Ikemen feature
		--p1_name_active_font_height = -1, --Ikemen feature
		--p2_name_active_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		--p2_name_active_font_scale = {1.0, 1.0}, --Ikemen feature
		--p2_name_active_font_height = -1, --Ikemen feature
		p1_cursor_move_snd = {100, 0}, --Ikemen feature
		p1_cursor_done_snd = {100, 1}, --Ikemen feature
		p2_cursor_move_snd = {100, 0}, --Ikemen feature
		p2_cursor_done_snd = {100, 1}, --Ikemen feature
		stage_snd = {9000, 0}, --Ikemen feature
		stage_time = 0, --Ikemen feature
	},
	versusbgdef =
	{
		spr = '',
		bgclearcolor = {0, 0, 0},
	},
	demo_mode =
	{
		enabled = 1,
		select_enabled = 0, --not used in ikemen
		vsscreen_enabled = 0, --not used in ikemen
		title_waittime = 600,
		fight_endtime = 1500,
		fight_playbgm = 0,
		fight_stopbgm = 0,
		fight_bars_display = 0,
		intro_waitcycles = 1,
		debuginfo = 0,
		fadein_time = 50, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 50, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
	},
	continue_screen =
	{
		--parameters used by both legacy and animated continue screens
		enabled = 1,
		animated_continue = 0, --Ikemen feature
		external_gameover = 1, --Ikemen feature
		fadein_time = 8, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 120, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef_continue = {5500, 5300}, --Ikemen feature
		p1_statedef_yes = {5510, 180}, --Ikemen feature
		p1_statedef_no = {5520, 170}, --Ikemen feature
		p2_statedef_continue = {}, --Ikemen feature
		p2_statedef_yes = {}, --Ikemen feature
		p2_statedef_no = {}, --Ikemen feature
		--legacy continue screen (used only if animated.continue = 0)
		pos = {160, 40},
		continue_text = 'Continue?',
		continue_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0},
		continue_font_scale = {1.0, 1.0},
		continue_font_height = -1, --Ikemen feature
		continue_offset = {0, 0},
		yes_text = 'Yes',
		yes_font = {'f-6x9.def', 0, 0, 191, 191, 191, 255, 0},
		yes_font_scale = {1.0, 1.0},
		yes_font_height = -1, --Ikemen feature
		yes_offset = {-17, 20},
		yes_active_text = 'Yes',
		yes_active_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0},
		yes_active_font_scale = {1.0, 1.0},
		yes_active_font_height = -1, --Ikemen feature
		yes_active_offset = {-17, 20},
		no_text = 'No',
		no_font = {'f-6x9.def', 0, 0, 191, 191, 191, 255, 0},
		no_font_scale = {1.0, 1.0},
		no_font_height = -1, --Ikemen feature
		no_offset = {15, 20},
		no_active_text = 'No',
		no_active_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0},
		no_active_font_scale = {1.0, 1.0},
		no_active_font_height = -1, --Ikemen feature
		no_active_offset = {15, 20},
		move_snd = {100, 0}, --Ikemen feature
		done_snd = {100, 1}, --Ikemen feature
		cancel_snd = {100, 2}, --Ikemen feature
		--animated continue screen (used only if animated.continue = 1)
		endtime = 0, --Ikemen feature
		continue_starttime = 0, --Ikemen feature
		--continue_anim = nil, --Ikemen feature
		continue_offset = {0, 0}, --Ikemen feature
		continue_scale = {1.0, 1.0}, --Ikemen feature
		continue_skipstart = 0, --Ikemen feature
		continue_9_skiptime = 0, --Ikemen feature
		continue_9_snd = {0, 0}, --Ikemen feature
		continue_8_skiptime = 0, --Ikemen feature
		continue_8_snd = {0, 0}, --Ikemen feature
		continue_7_skiptime = 0, --Ikemen feature
		continue_7_snd = {0, 0}, --Ikemen feature
		continue_6_skiptime = 0, --Ikemen feature
		continue_6_snd = {0, 0}, --Ikemen feature
		continue_5_skiptime = 0, --Ikemen feature
		continue_5_snd = {0, 0}, --Ikemen feature
		continue_4_skiptime = 0, --Ikemen feature
		continue_4_snd = {0, 0}, --Ikemen feature
		continue_3_skiptime = 0, --Ikemen feature
		continue_3_snd = {0, 0}, --Ikemen feature
		continue_2_skiptime = 0, --Ikemen feature
		continue_2_snd = {0, 0}, --Ikemen feature
		continue_1_skiptime = 0, --Ikemen feature
		continue_1_snd = {0, 0}, --Ikemen feature
		continue_0_skiptime = 0, --Ikemen feature
		continue_0_snd = {0, 0}, --Ikemen feature
		continue_end_skiptime = 0, --Ikemen feature
		continue_end_snd = {0, 0}, --Ikemen feature
		credits_text = 'Credits: %i', --Ikemen feature
		credits_offset = {0, 0}, --Ikemen feature
		credits_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		credits_font_scale = {1.0, 1.0}, --Ikemen feature
		credits_font_height = -1, --Ikemen feature
	},
	continuebgdef =
	{
		spr = '', --Ikemen feature
		bgclearcolor = {0, 0, 0}, --Ikemen feature
	},
	game_over_screen =
	{
		enabled = 1,
		storyboard = '',
	},
	victory_screen =
	{
		enabled = 0,
		cpu_enabled = 1, --Ikemen feature
		vs_enabled = 1, --Ikemen feature
		loser_name_enabled = 0, --Ikemen feature
		winner_teamko_enabled = 0, --Ikemen feature
		time = 300,
		fadein_time = 0,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 15,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		p1_pos = {0, 0},
		p1_spr = {9000, 2},
		p1_offset = {100, 20},
		p1_facing = 1,
		p1_scale = {1.0, 1.0},
		p1_window = {0, 0, config.GameWidth, config.GameHeight},
		p1_num = 1, --Ikemen feature
		p1_c1_spr = {9000, 2}, --Ikemen feature
		p1_c1_offset = {0, 0}, --Ikemen feature
		p1_c1_scale = {1.0, 1.0}, --Ikemen feature
		p1_c1_slide_speed = {0, 0}, --Ikemen feature
		p1_c1_slide_dist = {0, 0}, --Ikemen feature
		p1_c2_spr = {9000, 2}, --Ikemen feature
		p1_c2_offset = {0, 0}, --Ikemen feature
		p1_c2_scale = {1.0, 1.0}, --Ikemen feature
		p1_c2_slide_speed = {0, 0}, --Ikemen feature
		p1_c2_slide_dist = {0, 0}, --Ikemen feature
		p1_c3_spr = {9000, 2}, --Ikemen feature
		p1_c3_offset = {0, 0}, --Ikemen feature
		p1_c3_scale = {1.0, 1.0}, --Ikemen feature
		p1_c3_slide_speed = {0, 0}, --Ikemen feature
		p1_c3_slide_dist = {0, 0}, --Ikemen feature
		p1_c4_spr = {9000, 2}, --Ikemen feature
		p1_c4_offset = {0, 0}, --Ikemen feature
		p1_c4_scale = {1.0, 1.0}, --Ikemen feature
		p1_c4_slide_speed = {0, 0}, --Ikemen feature
		p1_c4_slide_dist = {0, 0}, --Ikemen feature
		p1_name_offset = {20, 180},
		p1_name_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0},
		p1_name_font_scale = {1.0, 1.0},
		p1_name_font_height = -1, --Ikemen feature
		p2_pos = {0, 0}, --Ikemen feature
		p2_spr = {9000, 2}, --Ikemen feature
		p2_offset = {100, 20}, --Ikemen feature
		p2_facing = 1, --Ikemen feature
		p2_scale = {1.0, 1.0}, --Ikemen feature
		p2_window = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature
		p2_num = 0, --Ikemen feature
		p2_c1_spr = {9000, 2}, --Ikemen feature
		p2_c1_offset = {0, 0}, --Ikemen feature
		p2_c1_scale = {1.0, 1.0}, --Ikemen feature
		p2_c1_slide_speed = {0, 0}, --Ikemen feature
		p2_c1_slide_dist = {0, 0}, --Ikemen feature
		p2_c2_spr = {9000, 2}, --Ikemen feature
		p2_c2_offset = {0, 0}, --Ikemen feature
		p2_c2_scale = {1.0, 1.0}, --Ikemen feature
		p2_c2_slide_speed = {0, 0}, --Ikemen feature
		p2_c2_slide_dist = {0, 0}, --Ikemen feature
		p2_c3_spr = {9000, 2}, --Ikemen feature
		p2_c3_offset = {0, 0}, --Ikemen feature
		p2_c3_scale = {1.0, 1.0}, --Ikemen feature
		p2_c3_slide_speed = {0, 0}, --Ikemen feature
		p2_c3_slide_dist = {0, 0}, --Ikemen feature
		p2_c4_spr = {9000, 2}, --Ikemen feature
		p2_c4_offset = {0, 0}, --Ikemen feature
		p2_c4_scale = {1.0, 1.0}, --Ikemen feature
		p2_c4_slide_speed = {0, 0}, --Ikemen feature
		p2_c4_slide_dist = {0, 0}, --Ikemen feature
		p2_name_offset = {20, 180}, --Ikemen feature
		p2_name_font = {'jg.fnt', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		p2_name_font_scale = {1.0, 1.0}, --Ikemen feature
		p2_name_font_height = -1, --Ikemen feature
		winquote_text = 'Winner!',
		winquote_offset = {20, 192},
		winquote_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0},
		winquote_font_scale = {1.0, 1.0},
		winquote_font_height = -1, --Ikemen feature
		winquote_delay = 2, --Ikemen feature
		winquote_textwrap = 'w', --default wrapping when winquote.length is not set
		winquote_window = {0, 0, config.GameWidth, config.GameHeight},
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
	},
	victorybgdef =
	{
		spr = '',
		bgclearcolor = {0, 0, 0},
	},
	win_screen =
	{
		enabled = 1,
		time = 300, --Ikemen feature
		fadein_time = 0,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		pose_time = 300,
		wintext_text = 'Congratulations!',
		wintext_offset = {159, 70},
		wintext_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0},
		wintext_font_scale = {1.0, 1.0},
		wintext_font_height = -1, --Ikemen feature
		wintext_displaytime = -1,
		wintext_layerno = 2,
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef = {180}, --Ikemen feature
		p2_statedef = {}, --Ikemen feature
	},
	default_ending =
	{
		enabled = 0,
		storyboard = '',
	},
	end_credits =
	{
		enabled = 0,
		storyboard = '',
	},
	survival_results_screen =
	{
		enabled = 1,
		time = 300, --Ikemen feature
		fadein_time = 0,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		show_time = 300,
		winstext_text = 'Rounds survived: %i',
		winstext_offset = {159, 70},
		winstext_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0},
		winstext_font_scale = {1.0, 1.0},
		winstext_font_height = -1, --Ikemen feature
		winstext_displaytime = -1,
		winstext_layerno = 2,
		roundstowin = 5,
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef_win = {180}, --Ikemen feature
		p1_statedef_lose = {175, 170}, --Ikemen feature
		p2_statedef_win = {}, --Ikemen feature
		p2_statedef_lose = {}, --Ikemen feature
	},
	vs100_kumite_results_screen =
	{
		enabled = 1, --Ikemen feature
		time = 300, --Ikemen feature
		fadein_time = 0, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		show_time = 300, --Ikemen feature
		winstext_text = 'Wins: %i\nLoses: %i', --Ikemen feature
		winstext_offset = {159, 70}, --Ikemen feature
		winstext_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		winstext_font_scale = {1.0, 1.0}, --Ikemen feature
		winstext_font_height = -1, --Ikemen feature
		winstext_displaytime = -1, --Ikemen feature
		winstext_layerno = 2, --Ikemen feature
		roundstowin = 51, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef_win = {180}, --Ikemen feature
		p1_statedef_lose = {175, 170}, --Ikemen feature
		p2_statedef_win = {}, --Ikemen feature
		p2_statedef_lose = {}, --Ikemen feature
	},
	time_attack_results_screen =
	{
		enabled = 1, --Ikemen feature
		time = 300, --Ikemen feature
		fadein_time = 0, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		show_time = 300, --Ikemen feature
		winstext_text = 'Clear Time: %m:%s.%x', --Ikemen feature
		winstext_offset = {159, 70}, --Ikemen feature
		winstext_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		winstext_font_scale = {1.0, 1.0}, --Ikemen feature
		winstext_font_height = -1, --Ikemen feature
		winstext_displaytime = -1, --Ikemen feature
		winstext_layerno = 2, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef_win = {180}, --Ikemen feature
		p1_statedef_lose = {175, 170}, --Ikemen feature
		p2_statedef_win = {}, --Ikemen feature
		p2_statedef_lose = {}, --Ikemen feature
	},
	time_challenge_results_screen =
	{
		enabled = 1, --Ikemen feature
		time = 300, --Ikemen feature
		fadein_time = 0, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		show_time = 300, --Ikemen feature
		winstext_text = 'Clear Time: %m:%s.%x', --Ikemen feature
		winstext_offset = {159, 70}, --Ikemen feature
		winstext_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		winstext_font_scale = {1.0, 1.0}, --Ikemen feature
		winstext_font_height = -1, --Ikemen feature
		winstext_displaytime = -1, --Ikemen feature
		winstext_layerno = 2, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef_win = {180}, --Ikemen feature
		p1_statedef_lose = {175, 170}, --Ikemen feature
		p2_statedef_win = {}, --Ikemen feature
		p2_statedef_lose = {}, --Ikemen feature
	},
	score_challenge_results_screen =
	{
		enabled = 1, --Ikemen feature
		time = 300, --Ikemen feature
		fadein_time = 0, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		show_time = 300, --Ikemen feature
		winstext_text = 'Score: %i', --Ikemen feature
		winstext_offset = {159, 70}, --Ikemen feature
		winstext_font = {'jg.fnt', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		winstext_font_scale = {1.0, 1.0}, --Ikemen feature
		winstext_font_height = -1, --Ikemen feature
		winstext_displaytime = -1, --Ikemen feature
		winstext_layerno = 2, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef_win = {180}, --Ikemen feature
		p1_statedef_lose = {175, 170}, --Ikemen feature
		p2_statedef_win = {}, --Ikemen feature
		p2_statedef_lose = {}, --Ikemen feature
	},
	boss_rush_results_screen =
	{
		enabled = 1, --Ikemen feature
		time = 300, --Ikemen feature
		fadein_time = 0, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 64, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		show_time = 300, --Ikemen feature
		winstext_text = 'Congratulations!', --Ikemen feature
		winstext_offset = {159, 70}, --Ikemen feature
		winstext_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		winstext_font_scale = {1.0, 1.0}, --Ikemen feature
		winstext_font_height = -1, --Ikemen feature
		winstext_displaytime = -1, --Ikemen feature
		winstext_layerno = 2, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		p1_statedef = {180}, --Ikemen feature
		p2_statedef = {}, --Ikemen feature
	},
	resultsbgdef =
	{
		spr = '', --Ikemen feature
		bgclearcolor = {0, 0, 0}, --Ikemen feature (disabled to not cover game screen)
	},
	option_info =
	{
		fadein_time = 10,
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 10,
		fadeout_col = {0, 0, 0}, --Ikemen feature
		title_offset = {159, 19},
		title_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0},
		title_font_scale = {1.0, 1.0},
		title_font_height = -1, --Ikemen feature
		title_text = 'OPTIONS', --Ikemen feature
		menu_pos = {85, 33}, --Ikemen feature
		menu_item_font = {'f-6x9.def', 0, 1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_font_height = -1, --Ikemen feature
		menu_item_active_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_active_font_height = -1, --Ikemen feature
		menu_item_selected_font = {'f-6x9.def', 0, 1, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_selected_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_selected_font_height = -1, --Ikemen feature
		menu_item_selected_active_font = {'f-6x9.def', 0, 1, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_selected_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_selected_active_font_height = -1, --Ikemen feature
		menu_item_value_font = {'f-6x9.def', 0, -1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_value_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_value_font_height = -1, --Ikemen feature
		menu_item_value_active_font = {'f-6x9.def', 0, -1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_value_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_value_active_font_height = -1, --Ikemen feature
		menu_item_value_conflict_font = {'f-6x9.def', 0, -1, 247, 0, 0, 255, 0}, --Ikemen feature
		menu_item_value_conflict_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_value_conflict_font_height = -1, --Ikemen feature
		menu_item_spacing = {150, 13}, --Ikemen feature
		--menu_itemname_roundtime = 'Time Limit', --Ikemen feature
		--menu_itemname_roundsnumsingle = 'Rounds to Win Single', --Ikemen feature
		--menu_itemname_roundsnumteam = 'Rounds to Win Simul/Tag', --Ikemen feature
		--menu_itemname_maxdrawgames = 'Max Draw Games', --Ikemen feature
		--menu_itemname_difficulty = 'Difficulty Level', --Ikemen feature
		--menu_itemname_credits = 'Credits', --Ikemen feature
		--menu_itemname_quickcontinue = 'Quick Continue', --Ikemen feature
		--menu_itemname_airamping = 'AI Ramping', --Ikemen feature
		--menu_itemname_aipalette = 'AI Palette', --Ikemen feature
		--menu_itemname_resolution = 'Resolution', --Ikemen feature
		--menu_itemname_customres = 'Custom', --Ikemen feature
		--menu_itemname_fullscreen = 'Fullscreen', --Ikemen feature
		--menu_itemname_vretrace = 'VSync', --Ikemen feature
		--menu_itemname_msaa = 'MSAA', --Ikemen feature
		--menu_itemname_shaders = 'Shaders', --Ikemen feature
		--menu_itemname_noshader = 'Disable', --Ikemen feature
		--menu_itemname_mastervolume = 'Master Volume', --Ikemen feature
		--menu_itemname_bgmvolume = 'BGM Volume', --Ikemen feature
		--menu_itemname_sfxvolume = 'SFX Volume', --Ikemen feature
		--menu_itemname_audioducking = 'Audio Ducking', --Ikemen feature
		--menu_itemname_keyboard = 'Key Config', --Ikemen feature
		--menu_itemname_gamepad = 'Joystick Config', --Ikemen feature
		--menu_itemname_inputdefault = 'Default', --Ikemen feature
		--menu_itemname_lifemul = 'Life', --Ikemen feature
		--menu_itemname_gamespeed = 'Game Speed', --Ikemen feature
		--menu_itemname_autoguard = 'Auto-Guard', --Ikemen feature
		--menu_itemname_singlevsteamlife = 'Single VS Team Life', --Ikemen feature
		--menu_itemname_teamlifeadjustment = 'Team Life Adjustment', --Ikemen feature
		--menu_itemname_teampowershare = 'Team Power Share', --Ikemen feature
		--menu_itemname_losekosimul = 'Simul Player KOed Lose', --Ikemen feature
		--menu_itemname_losekotag = 'Tag Partner KOed Lose', --Ikemen feature
		--menu_itemname_turnsrecoverybase = 'Turns Recovery Base', --Ikemen feature
		--menu_itemname_turnsrecoverybonus = 'Turns Recovery Bonus', --Ikemen feature
		--menu_itemname_ratio1life = 'Ratio 1 Life', --Ikemen feature
		--menu_itemname_ratio1attack = 'Ratio 1 Damage', --Ikemen feature
		--menu_itemname_ratio2life = 'Ratio 2 Life', --Ikemen feature
		--menu_itemname_ratio2attack = 'Ratio 2 Damage', --Ikemen feature
		--menu_itemname_ratio3life = 'Ratio 3 Life', --Ikemen feature
		--menu_itemname_ratio3attack = 'Ratio 3 Damage', --Ikemen feature
		--menu_itemname_ratio4life = 'Ratio 4 Life', --Ikemen feature
		--menu_itemname_ratio4attack = 'Ratio 4 Damage', --Ikemen feature
		--menu_itemname_minturns = 'Min Turns Chars', --Ikemen feature
		--menu_itemname_maxturns = 'Max Turns Chars', --Ikemen feature
		--menu_itemname_minsimul = 'Min Simul Chars', --Ikemen feature
		--menu_itemname_maxsimul = 'Max Simul Chars', --Ikemen feature
		--menu_itemname_mintag = 'Min Tag Chars', --Ikemen feature
		--menu_itemname_maxtag = 'Max Tag Chars', --Ikemen feature
		--menu_itemname_debugkeys = 'Debug Keys', --Ikemen feature
		--menu_itemname_helpermax = 'HelperMax', --Ikemen feature
		--menu_itemname_projectilemax = 'PlayerProjectileMax', --Ikemen feature
		--menu_itemname_explodmax = 'ExplodMax', --Ikemen feature
		--menu_itemname_afterimagemax = 'AfterImageMax', --Ikemen feature
		--menu_itemname_portchange = 'Port Change', --Ikemen feature
		--menu_itemname_default = 'Default Values', --Ikemen feature
		--menu_itemname_empty = '', --Ikemen feature
		--menu_itemname_back = 'Back', --Ikemen feature
		--menu_itemname_savereturn = 'Save and Return', --Ikemen feature
		--menu_itemname_return = 'Return Without Saving', --Ikemen feature
		menu_itemname_key_playerno = 'PLAYER', --Ikemen feature
		menu_itemname_key_all = 'Config all', --Ikemen feature
		menu_itemname_key_up = 'Up', --Ikemen feature
		menu_itemname_key_down = 'Down', --Ikemen feature
		menu_itemname_key_left = 'Left', --Ikemen feature
		menu_itemname_key_right = 'Right', --Ikemen feature
		menu_itemname_key_a = 'A', --Ikemen feature
		menu_itemname_key_b = 'B', --Ikemen feature
		menu_itemname_key_c = 'C', --Ikemen feature
		menu_itemname_key_x = 'X', --Ikemen feature
		menu_itemname_key_y = 'Y', --Ikemen feature
		menu_itemname_key_z = 'Z', --Ikemen feature
		menu_itemname_key_start = 'Start', --Ikemen feature
		menu_itemname_key_d = 'D', --Ikemen feature
		menu_itemname_key_w = 'W', --Ikemen feature
		menu_itemname_key_menu = 'Menu', --Ikemen feature
		menu_itemname_key_back = 'Back', --Ikemen feature
		menu_valuename_none = 'None', --Ikemen feature
		menu_valuename_random = 'Random', --Ikemen feature
		menu_valuename_default = 'Default', --Ikemen feature
		menu_valuename_f1 = '(F1)', --Ikemen feature
		menu_valuename_f2 = '(F2)', --Ikemen feature
		menu_valuename_esc = '(Esc)', --Ikemen feature
		menu_valuename_next = '(Tab)', --Ikemen feature
		menu_valuename_nokey = 'Not used', --Ikemen feature
		menu_valuename_yes = 'Yes', --Ikemen feature
		menu_valuename_no = 'No', --Ikemen feature
		menu_valuename_enabled = 'Enabled', --Ikemen feature
		menu_valuename_disabled = 'Disabled', --Ikemen feature
		menu_window_margins_y = {0, 0}, --Ikemen feature
		menu_window_visibleitems = 16, --Ikemen feature
		--menu_arrow_up_anim = nil, --Ikemen feature
		menu_arrow_up_spr = {}, --Ikemen feature
		menu_arrow_up_offset = {0, 0}, --Ikemen feature
		menu_arrow_up_facing = 1, --Ikemen feature
		menu_arrow_up_scale = {1.0, 1.0}, --Ikemen feature
		--menu_arrow_down_anim = nil, --Ikemen feature
		menu_arrow_down_spr = {}, --Ikemen feature
		menu_arrow_down_offset = {0, 0}, --Ikemen feature
		menu_arrow_down_facing = 1, --Ikemen feature
		menu_arrow_down_scale = {1.0, 1.0}, --Ikemen feature
		menu_boxcursor_visible = 1, --Ikemen feature
		menu_boxcursor_coords = {-5, -10, 154, 2}, --Ikemen feature
		menu_boxcursor_col = {255, 255, 255}, --Ikemen feature
		menu_boxcursor_alpharange = {10, 40, 2, 255, 255, 0}, --Ikemen feature
		menu_boxbg_visible = 1, --Ikemen feature
		menu_boxbg_col = {0, 0, 0}, --Ikemen feature
		menu_boxbg_alpha = {20, 100}, --Ikemen feature
		menu_title_uppercase = 1, --Ikemen feature
		menu_item_key_p1_font = {'f-6x9.def', 0, 0, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_key_p1_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_key_p1_font_height = -1, --Ikemen feature
		menu_item_key_p2_font = {'f-6x9.def', 0, 0, 247, 0, 0, 255, 0}, --Ikemen feature
		menu_item_key_p2_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_key_p2_font_height = -1, --Ikemen feature
		menu_item_info_font = {'f-6x9.def', 0, -1, 247, 247, 0, 255, 0}, --Ikemen feature
		menu_item_info_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_info_font_height = -1, --Ikemen feature
		menu_item_info_active_font = {'f-6x9.def', 0, -1, 247, 247, 0, 255, 0}, --Ikemen feature
		menu_item_info_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_info_active_font_height = -1, --Ikemen feature
		menu_item_p1_pos = {91, 33}, --Ikemen feature
		menu_item_p2_pos = {230, 33}, --Ikemen feature
		menu_key_p1_pos = {39, 33}, --Ikemen feature
		menu_key_p2_pos = {178, 33}, --Ikemen feature
		menu_key_item_spacing = {101, 12}, --Ikemen feature
		menu_key_boxcursor_coords = {-5, -9, 106, 2}, --Ikemen feature
		input_port_text = 'Type in Host Port, e.g. 7500.\nPress ENTER to accept.\nPress ESC to cancel.', --Ikemen feature
		input_reswidth_text = 'Type in screen width.\nPress ENTER to accept.\nPress ESC to cancel.', --Ikemen feature
		input_resheight_text = 'Type in screen height.\nPress ENTER to accept.\nPress ESC to cancel.', --Ikemen feature
		input_key_text = 'Press a key to assign to entry.\nPress SPACE to disable key.\nPress ESC to cancel.', --Ikemen feature
		cursor_move_snd = {100, 0},
		cursor_done_snd = {100, 1},
		cancel_snd = {100, 2},
	},
	character_edit_info =
	{
		--TODO: remove unused content
		menu_pos = {85, 33}, --Ikemen feature
		is_absolute = true,
		menu_item_font = {'f-6x9.def', 0, 1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_font_height = -1, --Ikemen feature
		menu_item_active_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_active_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_active_font_height = -1, --Ikemen feature
		menu_item_selected_font = {'f-6x9.def', 0, 1, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_selected_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_selected_font_height = -1, --Ikemen feature
		menu_item_selected_active_font = {'f-6x9.def', 0, 1, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_selected_active_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_selected_active_font_height = -1, --Ikemen feature
		menu_item_value_font = {'f-6x9.def', 0, -1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_value_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_value_font_height = -1, --Ikemen feature
		menu_item_value_active_font = {'f-6x9.def', 0, -1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_value_active_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_value_active_font_height = -1, --Ikemen feature
		menu_item_value_conflict_font = {'f-6x9.def', 0, -1, 247, 0, 0, 255, 0}, --Ikemen feature
		menu_item_value_conflict_font_scale = {heightscale(), heightscale()}, --Ikemen feature
		menu_item_value_conflict_font_height = -1, --Ikemen feature
		menu_item_spacing = {150*heightscale(), 13*heightscale()}, --Ikemen feature
		menu_window_margins_y = {0, 0}, --Ikemen feature
		menu_window_visibleitems = 16, --Ikemen feature
		--menu_arrow_up_anim = nil, --Ikemen feature
		menu_arrow_up_spr = {}, --Ikemen feature
		menu_arrow_up_offset = {0, 0}, --Ikemen feature
		menu_arrow_up_facing = 1, --Ikemen feature
		menu_arrow_up_scale = {1.0, 1.0}, --Ikemen feature
		--menu_arrow_down_anim = nil, --Ikemen feature
		menu_arrow_down_spr = {}, --Ikemen feature
		menu_arrow_down_offset = {0, 0}, --Ikemen feature
		menu_arrow_down_facing = 1, --Ikemen feature
		menu_arrow_down_scale = {1.0, 1.0}, --Ikemen feature
		menu_boxcursor_visible = 1, --Ikemen feature
		menu_boxcursor_coords = {-5*heightscale(), -10*heightscale(), 154*heightscale(), 2*heightscale()}, --Ikemen feature
		menu_boxcursor_col = {255, 255, 255}, --Ikemen feature
		menu_boxcursor_alpharange = {10, 40, 2, 255, 255, 0}, --Ikemen feature
		menu_boxbg_visible = 1, --Ikemen feature
		menu_boxbg_col = {0, 0, 0}, --Ikemen feature
		menu_boxbg_alpha = {20, 100}, --Ikemen feature
		menu_item_info_font = {'f-6x9.def', 0, -1, 247, 247, 0, 255, 0}, --Ikemen feature
		menu_item_info_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_info_font_height = -1, --Ikemen feature
		menu_item_info_active_font = {'f-6x9.def', 0, -1, 247, 247, 0, 255, 0}, --Ikemen feature
		menu_item_info_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_info_active_font_height = -1, --Ikemen feature
		cursor_move_snd = {100, 0},
		cursor_done_snd = {100, 1},
		cancel_snd = {100, 2},
		text_character_enabled = "enabled",
		text_character_disabled = "disabled",
		text_default = "default",
		text_this_ai_level = "this ai level",
		text_return = "return"
	},
	navigation_tip = {
		tip_font = {'f-6x9.def', 0, 1, 210, 210, 210, 255, 0}, --Ikemen feature
		tip_font_scale = {widthscale(), widthscale()}, --Ikemen feature
		tip_background = {0, 0, 0, 0, 100}, --Ikemen feature
		tip_font_height = widthscale()*8, --Ikemen feature
		tip_font_lower_diff = - widthscale()*1, --Ikemen feature
		tip_extra_space_bottom = heightscale()*3, --Ikemen feature
		tip_extra_space_top = heightscale()*3 --Ikemen feature
	},
	optionbgdef =
	{
		spr = '',
		bgclearcolor = {0, 0, 0},
	},
	replay_info =
	{
		fadein_time = 10, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 10, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		title_offset = {159, 19}, --Ikemen feature
		title_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		title_font_scale = {1.0, 1.0}, --Ikemen feature
		title_font_height = -1, --Ikemen feature
		title_text = 'REPLAY SELECT', --Ikemen feature
		menu_pos = {85, 33}, --Ikemen feature
		menu_item_font = {'f-6x9.def', 0, 1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_font_height = -1, --Ikemen feature
		menu_item_active_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_active_font_height = -1, --Ikemen feature
		menu_item_spacing = {150, 13}, --Ikemen feature
		menu_itemname_back = 'Back', --Ikemen feature
		menu_window_margins_y = {0, 0}, --Ikemen feature
		menu_window_visibleitems = 15, --Ikemen feature
		--menu_arrow_up_anim = nil, --Ikemen feature
		menu_arrow_up_spr = {}, --Ikemen feature
		menu_arrow_up_offset = {0, 0}, --Ikemen feature
		menu_arrow_up_facing = 1, --Ikemen feature
		menu_arrow_up_scale = {1.0, 1.0}, --Ikemen feature
		--menu_arrow_down_anim = nil, --Ikemen feature
		menu_arrow_down_spr = {}, --Ikemen feature
		menu_arrow_down_offset = {0, 0}, --Ikemen feature
		menu_arrow_down_facing = 1, --Ikemen feature
		menu_arrow_down_scale = {1.0, 1.0}, --Ikemen feature
		menu_boxcursor_visible = 1, --Ikemen feature
		menu_boxcursor_coords = {-5, -10, 154, 2}, --Ikemen feature
		menu_boxcursor_col = {255, 255, 255}, --Ikemen feature
		menu_boxcursor_alpharange = {10, 40, 2, 255, 255, 0}, --Ikemen feature
		menu_boxbg_visible = 1, --Ikemen feature
		menu_boxbg_col = {0, 0, 0}, --Ikemen feature
		menu_boxbg_alpha = {20, 100}, --Ikemen feature
		menu_title_uppercase = 1, --Ikemen feature
		cursor_move_snd = {100, 0}, --Ikemen feature
		cursor_done_snd = {100, 1}, --Ikemen feature
		cancel_snd = {100, 2}, --Ikemen feature
	},
	replaybgdef =
	{
		spr = '', --Ikemen feature
		bgclearcolor = {0, 0, 0}, --Ikemen feature
	},
	menu_info =
	{
		fadein_time = 0, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 0, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
		title_offset = {159, 19}, --Ikemen feature
		title_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		title_font_scale = {1.0, 1.0}, --Ikemen feature
		title_font_height = -1, --Ikemen feature
		title_text = 'PAUSE', --Ikemen feature
		menu_pos = {85, 33}, --Ikemen feature
		menu_item_font = {'f-6x9.def', 0, 1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_font_height = -1, --Ikemen feature
		menu_item_active_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_active_font_height = -1, --Ikemen feature
		menu_item_selected_font = {'f-6x9.def', 0, 1, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_selected_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_selected_font_height = -1, --Ikemen feature
		menu_item_selected_active_font = {'f-6x9.def', 0, 1, 0, 247, 247, 255, 0}, --Ikemen feature
		menu_item_selected_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_selected_active_font_height = -1, --Ikemen feature
		menu_item_value_font = {'f-6x9.def', 0, -1, 191, 191, 191, 255, 0}, --Ikemen feature
		menu_item_value_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_value_font_height = -1, --Ikemen feature
		menu_item_value_active_font = {'f-6x9.def', 0, -1, 255, 255, 255, 255, 0}, --Ikemen feature
		menu_item_value_active_font_scale = {1.0, 1.0}, --Ikemen feature
		menu_item_value_active_font_height = -1, --Ikemen feature
		menu_item_spacing = {150, 13}, --Ikemen feature
		--menu_itemname_back = 'Continue', --Ikemen feature
		--menu_itemname_keyboard = 'Key Config', --Ikemen feature
		--menu_itemname_gamepad = 'Joystick Config', --Ikemen feature
		--menu_itemname_inputdefault = 'Default', --Ikemen feature
		--menu_itemname_commandlist = 'Command List', --Ikemen feature
		--menu_itemname_characterchange = 'Character Change', --Ikemen feature
		--menu_itemname_exit = 'Exit', --Ikemen feature
		menu_window_margins_y = {0, 0}, --Ikemen feature
		menu_window_visibleitems = 15, --Ikemen feature
		--menu_arrow_up_anim = nil, --Ikemen feature
		menu_arrow_up_spr = {}, --Ikemen feature
		menu_arrow_up_offset = {0, 0}, --Ikemen feature
		menu_arrow_up_facing = 1, --Ikemen feature
		menu_arrow_up_scale = {1.0, 1.0}, --Ikemen feature
		--menu_arrow_down_anim = nil, --Ikemen feature
		menu_arrow_down_spr = {}, --Ikemen feature
		menu_arrow_down_offset = {0, 0}, --Ikemen feature
		menu_arrow_down_facing = 1, --Ikemen feature
		menu_arrow_down_scale = {1.0, 1.0}, --Ikemen feature
		menu_boxcursor_visible = 1, --Ikemen feature
		menu_boxcursor_coords = {-5, -10, 154, 2}, --Ikemen feature
		menu_boxcursor_col = {255, 255, 255}, --Ikemen feature
		menu_boxcursor_alpharange = {10, 40, 2, 255, 255, 0}, --Ikemen feature
		menu_boxbg_visible = 1, --Ikemen feature
		menu_boxbg_col = {0, 0, 0}, --Ikemen feature
		menu_boxbg_alpha = {20, 100}, --Ikemen feature
		menu_title_uppercase = 1, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
		cursor_move_snd = {100, 0}, --Ikemen feature
		cursor_done_snd = {100, 1}, --Ikemen feature
		cancel_snd = {100, 2}, --Ikemen feature
		enter_snd = {-1, -1}, --Ikemen feature
		movelist_pos = {10, 20}, --Ikemen feature
		movelist_label_offset = {150, 0}, --Ikemen feature
		movelist_label_font = {'Open_Sans.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		movelist_label_font_scale = {0.3, 0.3}, --Ikemen feature
		movelist_label_font_height = -1, --Ikemen feature
		movelist_label_text = '%s', --Ikemen feature
		movelist_label_uppercase = 0, --Ikemen feature
		movelist_text_offset = {0, 12}, --Ikemen feature
		movelist_text_font = {'Open_Sans.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		movelist_text_font_scale = {0.3, 0.3}, --Ikemen feature
		movelist_text_font_height = 36, --Ikemen feature
		movelist_text_spacing = {1, 1}, --Ikemen feature
		movelist_text_text = 'Command List not found.', --Ikemen feature
		movelist_glyphs_offset = {0, 2}, --Ikemen feature
		movelist_glyphs_scale = {1.0, 1.0}, --Ikemen feature
		movelist_glyphs_spacing = {2}, --Ikemen feature
		movelist_window_width = 300, --Ikemen feature
		movelist_window_margins_y = {20, 1}, --Ikemen feature
		movelist_window_visibleitems = 18, --Ikemen feature
		movelist_boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		movelist_boxbg_col = {0, 0, 0}, --Ikemen feature
		movelist_boxbg_alpha = {20, 100}, --Ikemen feature
		--movelist_arrow_up_anim = nil, --Ikemen feature
		movelist_arrow_up_spr = {}, --Ikemen feature
		movelist_arrow_up_offset = {0, 0}, --Ikemen feature
		movelist_arrow_up_facing = 1, --Ikemen feature
		movelist_arrow_up_scale = {1.0, 1.0}, --Ikemen feature
		--movelist_arrow_down_anim = nil, --Ikemen feature
		movelist_arrow_down_spr = {}, --Ikemen feature
		movelist_arrow_down_offset = {0, 0}, --Ikemen feature
		movelist_arrow_down_facing = 1, --Ikemen feature
		movelist_arrow_down_scale = {1.0, 1.0}, --Ikemen feature
	},
	menubgdef =
	{
		spr = '', --Ikemen feature
		bgclearcolor = {0, 0, 0}, --Ikemen feature
	},
	training_info =
	{
		--same default values menu_info
	},
	trainingbgdef =
	{
		spr = '', --Ikemen feature
		bgclearcolor = {0, 0, 0}, --Ikemen feature
	},
	glyphs =
	{
		['^A'] = {1, 0}, --A
		['^B'] = {2, 0}, --B
		['^C'] = {3, 0}, --C
		['^D'] = {4, 0}, --D
		['^W'] = {23, 0}, --W
		['^X'] = {24, 0}, --X
		['^Y'] = {25, 0}, --Y
		['^Z'] = {26, 0}, --Z
		['_+'] = {39, 0}, --+ (press at the same time as previous button)
		['_.'] = {40, 0}, --...
		['_DB'] = {41, 0}, --Down-Back
		['_D'] = {42, 0}, --Down
		['_DF'] = {43, 0}, --Down-Forward
		['_B'] = {44, 0}, --Back
		['_0'] = {45, 0}, --Joystick Ball (no direction)
		['_F'] = {46, 0}, --Forward
		['_UB'] = {47, 0}, --Up-Back
		['_U'] = {48, 0}, --Up
		['_UF'] = {49, 0}, --Up-Forward
		['^S'] = {51, 0}, --Start
		['^M'] = {52, 0}, --Menu (Select/Back)
		['^P'] = {53, 0}, --Any Punch (X / Y / Z)
		['^K'] = {54, 0}, --Any Kick (A / B / C)
		['^LP'] = {57, 0}, --Light Punch (X)
		['^MP'] = {58, 0}, --Middle Punch (Y)
		['^SP'] = {59, 0}, --Strong Punch (Z)
		['^LK'] = {60, 0}, --Light Kick (A)
		['^MK'] = {61, 0}, --Middle Kick (B)
		['^SK'] = {62, 0}, --Strong Kick (C)
		['^3K'] = {63, 0}, --3 Kick (A+B+C)
		['^3P'] = {64, 0}, --3 Punch (X+Y+Z)
		['^2K'] = {65, 0}, --2 Kick (A+B / B+C / A+C)
		['^2P'] = {66, 0}, --2 Punch (X+Y / Y+Z / X+Z)
		['_-'] = {90, 0}, --Arrow (tap following Button immediately - use in combos)
		['_!'] = {91, 0}, --Continue Arrow (follow with this move)
		['~DB'] = {92, 0}, --hold Down-Back
		['~D'] = {93, 0}, --hold Down
		['~DF'] = {94, 0}, --hold Down-Forward
		['~B'] = {95, 0}, --hold Back
		['~F'] = {96, 0}, --hold Forward
		['~UB'] = {97, 0}, --hold Up-Back
		['~U'] = {98, 0}, --hold Up
		['~UF'] = {99, 0}, --hold Up-Forward
		['_HCB'] = {100, 0}, --1/2 Circle Back
		['_HUF'] = {101, 0}, --1/2 Circle Forward Up
		['_HCF'] = {102, 0}, --1/2 Circle Forward
		['_HUB'] = {103, 0}, --1/2 Circle Back Up
		['_QFD'] = {104, 0}, --1/4 Circle Forward Down
		['_QDB'] = {105, 0}, --1/4 Circle Down Back (QCB/QDB)
		['_QCB'] = {105, 0}, --1/4 Circle Down Back (QCB/QDB)
		['_QBU'] = {106, 0}, --1/4 Circle Back Up
		['_QUF'] = {107, 0}, --1/4 Circle Up Forward
		['_QBD'] = {108, 0}, --1/4 Circle Back Down
		['_QDF'] = {109, 0}, --1/4 Circle Down Forward (QCF/QDF)
		['_QCF'] = {109, 0}, --1/4 Circle Down Forward (QCF/QDF)
		['_QFU'] = {110, 0}, --1/4 Circle Forward Up
		['_QUB'] = {111, 0}, --1/4 Circle Up Back
		['_FDF'] = {112, 0}, --Full Clock Forward
		['_FUB'] = {113, 0}, --Full Clock Back
		['_FUF'] = {114, 0}, --Full Count Forward
		['_FDB'] = {115, 0}, --Full Count Back
		['_XFF'] = {116, 0}, --2x Forward
		['_XBB'] = {117, 0}, --2x Back
		['_DSF'] = {118, 0}, --Dragon Screw Forward
		['_DSB'] = {119, 0}, --Dragon Screw Back
		['_AIR'] = {121, 0}, --AIR
		['_TAP'] = {122, 0}, --TAP
		['_MAX'] = {123, 0}, --MAX
		['_^'] = {127, 0}, --Air
		['_='] = {128, 0}, --Squatting
		['_)'] = {129, 0}, --Close
		['_('] = {130, 0}, --Away
		['^Q'] = {133, 0}, --Any Hard Button (A / B / C / X / Y / Z)
		['_`'] = {135, 0}, --Small Dot
	},
	tournament_info =
	{
		fadein_time = 15, --Ikemen feature
		fadein_col = {0, 0, 0}, --Ikemen feature
		fadeout_time = 15, --Ikemen feature
		fadeout_col = {0, 0, 0}, --Ikemen feature
	},
	tournamentbgdef =
	{
		spr = '', --Ikemen feature
		bgclearcolor = {0, 0, 0}, --Ikemen feature
	},
	warning_info =
	{
		title = 'WARNING', --Ikemen feature
		title_pos = {159, 19}, --Ikemen feature
		title_font = {'f-6x9.def', 0, 0, 255, 255, 255, 255, 0}, --Ikemen feature
		title_font_scale = {1.0, 1.0}, --Ikemen feature
		title_font_height = -1, --Ikemen feature
		text_chars_text = 'No characters in select.def available for random selection.\nPress any key to exit the program.', --Ikemen feature'
		text_stages_text = 'No stages in select.def available for random selection.\nPress any key to exit the program.', --Ikemen feature
		text_order_text = "Incorrect 'maxmatches' settings detected.\nCheck orders in [Characters] and [Options] sections\nto ensure that at least one battle is possible.\nPress any key to exit the program.", --Ikemen feature
		text_ratio_text = "Incorrect 'arcade.ratiomatches' settings detected.\nRefer to tutorial available in default select.def.", --Ikemen feature
		text_training_text = "Training character (" .. config.TrainingChar .. ") not found.\nPress any key to exit the program.", --Ikemen feature
		text_rivals_text = " not found.\nCharacter rivals assignment has been nulled.", --Ikemen feature
		text_reload_text = 'Some selected options require Ikemen to be restarted.\nPress any key to exit the program.', --Ikemen feature
		text_noreload_text = 'Some selected options require Ikemen to be restarted.\nPress any key to continue.', --Ikemen feature
		text_res_text = 'Non 4:3 resolutions require stages coded for different\naspect ratio. Change it back to 4:3 if stages look off.', --Ikemen feature
		text_keys_text = 'Conflict between button keys detected.\nAll keys should have unique assignment.\n\nPress any key to continue.\nPress ESC to reset.', --Ikemen feature
		text_pad_text = 'Controller not detected.\nCheck if your controller is plugged in.', --Ikemen feature
		text_options_text = 'No option items detected.\nCheck documentation and default system.def [Option Info]\nsection for a reference how to add option screen menus.', --Ikemen feature
		text_shaders_text = 'No external OpenGL shaders detected.\nIkemen GO supports files with .vert and .frag extensions.\nShaders are loaded from "./external/shaders" directory.', --Ikemen feature
		text_pos = {25, 33}, --Ikemen feature
		text_font = {'f-6x9.def', 0, 1, 255, 255, 255, 255, 0}, --Ikemen feature
		text_font_scale = {1.0, 1.0}, --Ikemen feature
		text_font_height = -1, --Ikemen feature
		boxbg_coords = {0, 0, config.GameWidth, config.GameHeight}, --Ikemen feature (0, 0, 320, 240)
		boxbg_col = {0, 0, 0}, --Ikemen feature
		boxbg_alpha = {20, 100}, --Ikemen feature
	},
	rankings =
	{
		max_entries = 10, --Ikemen feature
	},
	anim = {},
}

function motif.setBaseOptionInfo()
	motif.option_info.menu_itemname_menuarcade = "Arcade Settings"
	motif.option_info.menu_itemname_menuarcade_roundtime = "Time Limit"
	motif.option_info.menu_itemname_menuarcade_roundsnumsingle = "Rounds to Win Single"
	motif.option_info.menu_itemname_menuarcade_roundsnumteam = "Rounds to Win Simul/Tag"
	motif.option_info.menu_itemname_menuarcade_maxdrawgames = "Max Draw Games"
	motif.option_info.menu_itemname_menuarcade_difficulty = "Difficulty Level"
	motif.option_info.menu_itemname_menuarcade_credits = "Credits"
	motif.option_info.menu_itemname_menuarcade_quickcontinue = "Quick Continue"
	motif.option_info.menu_itemname_menuarcade_airamping = "AI Ramping"
	motif.option_info.menu_itemname_menuarcade_aipalette = "AI Palette"
	motif.option_info.menu_itemname_menuarcade_empty = ""
	motif.option_info.menu_itemname_menuarcade_back = "Back"

	motif.option_info.menu_itemname_menuvideo = "Video Settings"
	motif.option_info.menu_itemname_menuvideo_resolution = "Resolution" --reserved submenu
	-- Resolution is assigned based on values used in itemname suffix (e.g. 320x240)
	motif.option_info.menu_itemname_menuvideo_resolution_320x240 = "320x240    (4:3 QVGA)"
	motif.option_info.menu_itemname_menuvideo_resolution_640x480 = "640x480    (4:3 VGA)"
	motif.option_info.menu_itemname_menuvideo_resolution_960x720 = "960x720    (4:3 HD)"
	motif.option_info.menu_itemname_menuvideo_resolution_1280x720 = "1280x720   (16:9 HD)"
	motif.option_info.menu_itemname_menuvideo_resolution_1600x900 = "1600x900   (16:9 HD+)"
	motif.option_info.menu_itemname_menuvideo_resolution_1920x1080 = "1920x1080  (16:9 FHD)"
	motif.option_info.menu_itemname_menuvideo_resolution_empty = ""
	motif.option_info.menu_itemname_menuvideo_resolution_customres = "Custom"
	motif.option_info.menu_itemname_menuvideo_resolution_back = "Back"
	motif.option_info.menu_itemname_menuvideo_fullscreen = "Fullscreen"
	motif.option_info.menu_itemname_menuvideo_vretrace = "VSync"
	motif.option_info.menu_itemname_menuvideo_msaa = "MSAA"
	motif.option_info.menu_itemname_menuvideo_shaders = "Shaders" --reserved submenu
	-- This list is populated with shaders existing in 'external/shaders' directory
	motif.option_info.menu_itemname_menuvideo_shaders_empty = ""
	motif.option_info.menu_itemname_menuvideo_shaders_noshader = "Disable"
	motif.option_info.menu_itemname_menuvideo_shaders_back = "Back"
	motif.option_info.menu_itemname_menuvideo_empty = ""
	motif.option_info.menu_itemname_menuvideo_back = "Back"

	motif.option_info.menu_itemname_menuaudio = "Audio Settings"
	motif.option_info.menu_itemname_menuaudio_mastervolume = "Master Volume"
	motif.option_info.menu_itemname_menuaudio_bgmvolume = "BGM Volume"
	motif.option_info.menu_itemname_menuaudio_sfxvolume = "SFX Volume"
	motif.option_info.menu_itemname_menuaudio_audioducking = "Audio Ducking"
	motif.option_info.menu_itemname_menuaudio_empty = ""
	motif.option_info.menu_itemname_menuaudio_back = "Back"

	motif.option_info.menu_itemname_menuinput = "Input Settings"
	motif.option_info.menu_itemname_menuinput_keyboard = "Key Config"
	motif.option_info.menu_itemname_menuinput_gamepad = "Joystick Config"
	motif.option_info.menu_itemname_menuinput_empty = ""
	motif.option_info.menu_itemname_menuinput_inputdefault = "Default"
	motif.option_info.menu_itemname_menuinput_back = "Back"

	motif.option_info.menu_itemname_menugameplay = "Gameplay Settings"
	motif.option_info.menu_itemname_menugameplay_lifemul = "Life"
	motif.option_info.menu_itemname_menugameplay_gamespeed = "Game Speed"
	motif.option_info.menu_itemname_menugameplay_autoguard = "Auto-Guard"
	motif.option_info.menu_itemname_menugameplay_guardbar = "Guard Break"
	motif.option_info.menu_itemname_menugameplay_stunbar = "Dizzy"
	motif.option_info.menu_itemname_menugameplay_redlifebar = "Red Life"
	motif.option_info.menu_itemname_menugameplay_empty = ""
	motif.option_info.menu_itemname_menugameplay_menuteam = "Team Settings"
	motif.option_info.menu_itemname_menugameplay_menuteam_singlevsteamlife = "Single VS Team Life"
	motif.option_info.menu_itemname_menugameplay_menuteam_teamlifeadjustment = "Team Life Adjustment"
	motif.option_info.menu_itemname_menugameplay_menuteam_teampowershare = "Team Power Share"
	motif.option_info.menu_itemname_menugameplay_menuteam_losekosimul = "Simul Player KOed Lose"
	motif.option_info.menu_itemname_menugameplay_menuteam_losekotag = "Tag Partner KOed Lose"
	motif.option_info.menu_itemname_menugameplay_menuteam_turnsrecoverybase = "Turns Recovery Base"
	motif.option_info.menu_itemname_menugameplay_menuteam_turnsrecoverybonus = "Turns Recovery Bonus"
	motif.option_info.menu_itemname_menugameplay_menuteam_empty = ""
	motif.option_info.menu_itemname_menugameplay_menuteam_minturns = "Min Turns Chars"
	motif.option_info.menu_itemname_menugameplay_menuteam_maxturns = "Max Turns Chars"
	motif.option_info.menu_itemname_menugameplay_menuteam_minsimul = "Min Simul Chars"
	motif.option_info.menu_itemname_menugameplay_menuteam_maxsimul = "Max Simul Chars"
	motif.option_info.menu_itemname_menugameplay_menuteam_mintag = "Min Tag Chars"
	motif.option_info.menu_itemname_menugameplay_menuteam_maxtag = "Max Tag Chars"
	motif.option_info.menu_itemname_menugameplay_menuteam_empty = ""
	motif.option_info.menu_itemname_menugameplay_menuteam_back = "Back"
	motif.option_info.menu_itemname_menugameplay_menuratio = "Ratio Settings"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio1life = "Ratio 1 Life"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio1attack = "Ratio 1 Damage"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio2life = "Ratio 2 Life"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio2attack = "Ratio 2 Damage"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio3life = "Ratio 3 Life"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio3attack = "Ratio 3 Damage"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio4life = "Ratio 4 Life"
	motif.option_info.menu_itemname_menugameplay_menuratio_ratio4attack = "Ratio 4 Damage"
	motif.option_info.menu_itemname_menugameplay_menuratio_empty = ""
	motif.option_info.menu_itemname_menugameplay_menuratio_back = "Back"
	motif.option_info.menu_itemname_menugameplay_back = "Back"

	motif.option_info.menu_itemname_menuengine = "Engine Settings"
	motif.option_info.menu_itemname_menuengine_debugkeys = "Debug Keys"
	motif.option_info.menu_itemname_menuengine_empty = ""
	motif.option_info.menu_itemname_menuengine_helpermax = "HelperMax"
	motif.option_info.menu_itemname_menuengine_projectilemax = "PlayerProjectileMax"
	motif.option_info.menu_itemname_menuengine_explodmax = "ExplodMax"
	motif.option_info.menu_itemname_menuengine_afterimagemax = "AfterImageMax"
	motif.option_info.menu_itemname_menuengine_empty = ""
	motif.option_info.menu_itemname_menuengine_menupreloading = "Pre-loading"
	motif.option_info.menu_itemname_menuengine_menupreloading_preloadingsmall = "Small portraits"
	motif.option_info.menu_itemname_menuengine_menupreloading_preloadingbig = "Select portraits"
	motif.option_info.menu_itemname_menuengine_menupreloading_preloadingversus = "Versus portraits"
	motif.option_info.menu_itemname_menuengine_menupreloading_preloadingstage = "Stage portraits"
	motif.option_info.menu_itemname_menuengine_back = "Back"

	motif.option_info.menu_itemname_empty = ""
	motif.option_info.menu_itemname_portchange = "Port Change"
	motif.option_info_menu_itemname_characters = "Manage Characters"
	motif.option_info.menu_itemname_default = "Default Values"
	motif.option_info.menu_itemname_empty = ""
	motif.option_info.menu_itemname_savereturn = "Save and Return"
	motif.option_info.menu_itemname_return = "Return Without Saving"
	-- Default options screen order.
	main.t_sort.option_info = {
		"menuarcade",
		"menuarcade_roundtime",
		"menuarcade_roundsnumsingle",
		"menuarcade_roundsnumteam",
		"menuarcade_maxdrawgames",
		"menuarcade_difficulty",
		"menuarcade_credits",
		"menuarcade_quickcontinue",
		"menuarcade_airamping",
		"menuarcade_aipalette",
		"menuarcade_empty",
		"menuarcade_back",
		"menuvideo",
		"menuvideo_resolution",
		"menuvideo_resolution_320x240",
		"menuvideo_resolution_640x480",
		"menuvideo_resolution_960x720",
		"menuvideo_resolution_1280x720",
		"menuvideo_resolution_1600x900",
		"menuvideo_resolution_1920x1080",
		"menuvideo_resolution_empty",
		"menuvideo_resolution_customres",
		"menuvideo_resolution_back",
		"menuvideo_fullscreen",
		"menuvideo_vretrace",
		"menuvideo_msaa",
		"menuvideo_shaders",
		"menuvideo_shaders_empty",
		"menuvideo_shaders_noshader",
		"menuvideo_shaders_back",
		"menuvideo_empty",
		"menuvideo_back",
		"menuaudio",
		"menuaudio_mastervolume",
		"menuaudio_bgmvolume",
		"menuaudio_sfxvolume",
		"menuaudio_audioducking",
		"menuaudio_empty",
		"menuaudio_back",
		"menuinput",
		"menuinput_keyboard",
		"menuinput_gamepad",
		"menuinput_empty",
		"menuinput_inputdefault",
		"menuinput_back",
		"menugameplay",
		"menugameplay_lifemul",
		"menugameplay_gamespeed",
		"menugameplay_autoguard",
		"menugameplay_guardbar",
		"menugameplay_stunbar",
		"menugameplay_redlifebar",
		"menugameplay_empty",
		"menugameplay_menuteam",
		"menugameplay_menuteam_singlevsteamlife",
		"menugameplay_menuteam_teamlifeadjustment",
		"menugameplay_menuteam_teampowershare",
		"menugameplay_menuteam_losekosimul",
		"menugameplay_menuteam_losekotag",
		"menugameplay_menuteam_turnsrecoverybase",
		"menugameplay_menuteam_turnsrecoverybonus",
		"menugameplay_menuteam_empty",
		"menugameplay_menuteam_minturns",
		"menugameplay_menuteam_maxturns",
		"menugameplay_menuteam_minsimul",
		"menugameplay_menuteam_maxsimul",
		"menugameplay_menuteam_mintag",
		"menugameplay_menuteam_maxtag",
		"menugameplay_menuteam_empty",
		"menugameplay_menuteam_back",
		"menugameplay_menuratio",
		"menugameplay_menuratio_ratio1life",
		"menugameplay_menuratio_ratio1attack",
		"menugameplay_menuratio_ratio2life",
		"menugameplay_menuratio_ratio2attack",
		"menugameplay_menuratio_ratio3life",
		"menugameplay_menuratio_ratio3attack",
		"menugameplay_menuratio_ratio4life",
		"menugameplay_menuratio_ratio4attack",
		"menugameplay_menuratio_empty",
		"menugameplay_menuratio_back",
		"menugameplay_back",
		"menuengine",
		"menuengine_debugkeys",
		"menuengine_empty",
		"menuengine_helpermax",
		"menuengine_projectilemax",
		"menuengine_explodmax",
		"menuengine_afterimagemax",
		"menuengine_empty",
		"menuengine_menupreloading",
		"menuengine_menupreloading_preloadingsmall",
		"menuengine_menupreloading_preloadingbig",
		"menuengine_menupreloading_preloadingversus",
		"menuengine_menupreloading_preloadingstage",
		"menuengine_back",
		"empty",
		"portchange",
		"characters",
		"default",
		"empty",
		"savereturn",
		"return",
	}
end

function motif.setBaseMenuInfo()
	motif.menu_info.menu_itemname_back = "Continue"
	motif.menu_info.menu_itemname_menuinput = "Button Config"
	motif.menu_info.menu_itemname_menuinput_keyboard = "Key Config"
	motif.menu_info.menu_itemname_menuinput_gamepad = "Joystick Config"
	motif.menu_info.menu_itemname_menuinput_empty = ""
	motif.menu_info.menu_itemname_menuinput_inputdefault = "Default"
	motif.menu_info.menu_itemname_menuinput_back = "Back"
	motif.menu_info.menu_itemname_commandlist = "Command List"
	motif.menu_info.menu_itemname_characterchange = "Character Change"
	motif.menu_info.menu_itemname_exit = "Exit"
	main.t_sort.menu_info = {
		"back",
		"menuinput",
		"menuinput_keyboard",
		"menuinput_gamepad",
		"menuinput_empty",
		"menuinput_inputdefault",
		"menuinput_back",
		"commandlist",
		"characterchange",
		"exit",
	}
end

function motif.setBaseTrainingInfo()
	motif.training_info.menu_itemname_back = "Continue"
	motif.training_info.menu_itemname_menuinput = "Button Config"
	motif.training_info.menu_itemname_menuinput_keyboard = "Key Config"
	motif.training_info.menu_itemname_menuinput_gamepad = "Joystick Config"
	motif.training_info.menu_itemname_menuinput_empty = ""
	motif.training_info.menu_itemname_menuinput_inputdefault = "Default"
	motif.training_info.menu_itemname_menuinput_back = "Back"
	motif.training_info.menu_itemname_commandlist = "Command List"
	motif.training_info.menu_itemname_characterchange = "Character Change"
	motif.training_info.menu_itemname_exit = "Exit"
	main.t_sort.training_info = {
		"back",
		"menuinput",
		"menuinput_keyboard",
		"menuinput_gamepad",
		"menuinput_empty",
		"menuinput_inputdefault",
		"menuinput_back",
		"commandlist",
		"characterchange",
		"exit",
	}
end

--;===========================================================
--; PARSE SCREENPACK
--;===========================================================
--here starts proper screenpack DEF file parsing
main.t_fntDefault = {0, 0, 255, 255, 255, 255, 0}
main.t_sort = {}
local t = {}
local pos = t
local pos_sort = main.t_sort
local def_pos = motif
t.anim = {}
local fileDir, fileName = motif.def:match('^(.-)([^/\\]+)$')
t.fileDir = fileDir
t.fileName = fileName
local tmp = ''
local group = ''
--local file = io.open(motif.def, 'r')
--for line in file:lines() do
for line in main.motifData:gmatch('([^\n]*)\n?') do
	line = line:gsub('%s*;.*$', '')
	if line:match('^[^%g]*%s*%[.-%s*%]%s*$') then --matched [] group
		line = line:match('%[(.-)%s*%]%s*$') --match text between []
		line = line:gsub('[%. ]', '_') --change . and space to _
		group = tostring(line:lower())
		if group:match('^begin_action_[0-9]+$') then --matched anim
			group = tonumber(group:match('^begin_action_([0-9]+)$'))
			t.anim[group] = {}
			pos = t.anim[group]
		else --matched other []
			t[group] = {}
			main.t_sort[group] = {}
			pos = t[group]
			pos_sort = main.t_sort[group]
			def_pos = motif[group]
		end
	else --matched non [] line
		local param, value = line:match('^%s*([^=]-)%s*=%s*(.-)%s*$')
		if param ~= nil then
			param = param:gsub('[%. ]', '_') --change param . and space to _
			if group ~= 'glyphs' then
				param = param:lower() --lowercase param
			end
			if value ~= nil and def_pos ~= nil then --let's check if it's even a valid param
				if value == '' and (type(def_pos[param]) == 'number' or type(def_pos[param]) == 'table') then --text should remain empty
					value = nil
				end
			end
		end
		if param ~= nil and value ~= nil then --param = value pattern matched
			value = value:gsub('"', '') --remove brackets from value
			value = value:gsub('^(%.[0-9])', '0%1') --add 0 before dot if missing at the beginning of matched string
			value = value:gsub('([^0-9])(%.[0-9])', '%10%2') --add 0 before dot if missing anywhere else
			if param:match('^font[0-9]+') then --font declaration param matched
				if pos.font == nil then
					pos.font = {}
					pos.font_height = {}
				end
				local num = tonumber(param:match('font([0-9]+)'))
				if param:match('_height$') then
					pos.font_height[num] = main.f_dataType(value)
				else
					value = value:gsub('\\', '/')
					pos.font[num] = tostring(value)
				end
			elseif pos[param] == nil or param:match('_itemname_') or param:match('_font_height$') then --mugen takes into account only first occurrence
				if param:match('_font$') then --assign default font values if needed (also ensure that there are multiple values in the first place)
					local _, n = value:gsub(',%s*[0-9]*', '')
					for i = n + 1, #main.t_fntDefault do
						value = value:gsub(',?%s*$', ',' .. main.t_fntDefault[i])
					end
				end
				if param:match('_text$') or param:match('_valuename_') then --skip commas detection for strings
					pos[param] = value
				elseif param:match('_itemname_') then --skip commas detection and append value to main.t_sort for itemname
					table.insert(pos_sort, param:match('_itemname_(.+)$'))
					pos[param] = value
				elseif value:match('.+,.+') then --multiple values
					for i, c in ipairs(main.f_strsplit(',', value)) do --split value using "," delimiter
						if param:match('_anim$') then --mugen recognizes animations even if there are more values
							pos[param] = main.f_dataType(c)
							break
						elseif i == 1 then
							pos[param] = {}
							if param:match('_font$') and tonumber(c) ~= -1 then
								if t.files ~= nil and t.files.font ~= nil and t.files.font[tonumber(c)] ~= nil then
									if pos[param .. '_height'] == nil and t.files.font_height[tonumber(c)] ~= nil then
										pos[param .. '_height'] = t.files.font_height[tonumber(c)]
									end
									c = t.files.font[tonumber(c)]
								else
									break --use default font values
								end
							end
						end
						if c == nil or c == '' then
							table.insert(pos[param], 0)
						else
							table.insert(pos[param], main.f_dataType(c))
						end
					end
				else --single value
					pos[param] = main.f_dataType(value)
				end
			end
		elseif param == nil then --only valid lines left are animations
			line = line:lower()
			local value = line:match('^%s*([0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+%s*,%s*[0-9%-]+.-)[,%s]*$') or line:match('^%s*loopstart') or line:match('%s*interpolate [oasb][fncl][fgae][sln][ed]t?')
			if value ~= nil then
				value = value:gsub(',%s*,', ',0,') --add missing values
				value = value:gsub(',%s*$', '')
				table.insert(pos, value)
			end
		end
	end
	main.loadingRefresh()
end
--file:close()
if main.debugLog then main.f_printTable(main.t_sort, 'debug/t_sort.txt') end

--;===========================================================
--; FIX REFERENCES, LOAD DATA
--;===========================================================
--adopt old DEF code to Ikemen features
if type(t.select_info.cell_spacing) ~= "table" then
	t.select_info.cell_spacing = {t.select_info.cell_spacing, t.select_info.cell_spacing}
end

if t.victory_screen ~= nil then
	for i = 1, 4 do
		if t.victory_screen['p1_c' .. i .. '_spr'] == nil and t.victory_screen.p1_spr ~= nil then
			t.victory_screen['p1_c' .. i .. '_spr'] = t.victory_screen.p1_spr
		end
		if t.victory_screen['p2_c' .. i .. '_spr'] == nil and t.victory_screen.p2_spr ~= nil then
			t.victory_screen['p2_c' .. i .. '_spr'] = t.victory_screen.p2_spr
		end
	end
end

--training_info section reuses menu_info values (excluding itemnames)
motif.training_info = main.f_tableMerge(motif.training_info, motif.menu_info)
if t.menu_info == nil then t.menu_info = {} end
if t.training_info == nil then t.training_info = {} end
for k, v in pairs(t.menu_info) do
	if not k:match('_itemname_') then
		t.training_info[k] = v
	end
end

--merge tables
motif = main.f_tableMerge(motif, t)

--fix missing params/sections
if motif.victory_screen.enabled == 0 then
	motif.victory_screen.cpu_enabled = 0
	motif.victory_screen.vs_enabled = 0
end

--disable scaling if element should use default values (non-existing in mugen)
motif.defaultWarning = true --t.warning_info == nil or t.warning_info.text_font == nil
motif.defaultOptions = true --t.option_info == nil or t.option_info.menu_item_font == nil
motif.defaultReplay = true --t.replay_info == nil or t.replay_info.menu_item_font == nil
motif.defaultMenu = true --t.menu_info == nil or t.menu_info.menu_item_font == nil
motif.defaultConnecting = true --t.title_info == nil or t.title_info.connecting_font == nil
motif.defaultInfobox = false --t.infobox == nil or t.infobox.text_font == nil
motif.defaultLoading = false --t.title_info == nil or t.title_info.loading_font == nil
motif.defaultFooter = false --t.title_info == nil or t.title_info.footer1_font == nil
motif.defaultLocalcoord = main.SP_Localcoord[1] ~= config.GameWidth or main.SP_Localcoord[2] ~= config.GameHeight

--general paths
local t_dir = {
	{t = {'files',            'spr'},              skip = {'^data/'},        dirs = {motif.fileDir .. motif.files.spr,                   'data/' .. motif.files.spr}},
	{t = {'files',            'snd'},              skip = {'^data/',  '^$'}, dirs = {motif.fileDir .. motif.files.snd,                   'data/' .. motif.files.snd}},
	{t = {'files',            'logo_storyboard'},  skip = {'^data/',  '^$'}, dirs = {motif.fileDir .. motif.files.logo_storyboard,       'data/' .. motif.files.logo_storyboard}},
	{t = {'files',            'intro_storyboard'}, skip = {'^data/',  '^$'}, dirs = {motif.fileDir .. motif.files.intro_storyboard,      'data/' .. motif.files.intro_storyboard}},
	{t = {'files',            'select'},           skip = {'^data/'},        dirs = {motif.fileDir .. motif.files.select,                'data/' .. motif.files.select}},
	{t = {'files',            'fight'},            skip = {'^data/'},        dirs = {motif.fileDir .. motif.files.fight,                 'data/' .. motif.files.fight}},
	{t = {'files',            'glyphs'},           skip = {'^data/'},        dirs = {motif.fileDir .. motif.files.glyphs,                'data/' .. motif.files.glyphs}},
	{t = {'music',            'title_bgm'},        skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.title_bgm,             'music/' .. motif.music.title_bgm}},
	{t = {'music',            'select_bgm'},       skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.select_bgm,            'music/' .. motif.music.select_bgm}},
	{t = {'music',            'vs_bgm'},           skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.vs_bgm,                'music/' .. motif.music.vs_bgm}},
	{t = {'music',            'victory_bgm'},      skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.victory_bgm,           'music/' .. motif.music.victory_bgm}},
	{t = {'music',            'option_bgm'},       skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.option_bgm,            'music/' .. motif.music.option_bgm}},
	{t = {'music',            'replay_bgm'},       skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.replay_bgm,            'music/' .. motif.music.replay_bgm}},
	{t = {'music',            'continue_bgm'},     skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.continue_bgm,          'music/' .. motif.music.continue_bgm}},
	{t = {'music',            'continue_end_bgm'}, skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.continue_end_bgm,      'music/' .. motif.music.continue_end_bgm}},
	{t = {'music',            'results_bgm'},      skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.results_bgm,           'music/' .. motif.music.results_bgm}},
	{t = {'music',            'tournament_bgm'},   skip = {'^music/', '^$'}, dirs = {motif.fileDir .. motif.music.tournament_bgm,        'music/' .. motif.music.tournament_bgm}},
	{t = {'default_ending',   'storyboard'},       skip = {'^data/',  '^$'}, dirs = {motif.fileDir .. motif.default_ending.storyboard,   'data/' .. motif.default_ending.storyboard}},
	{t = {'end_credits',      'storyboard'},       skip = {'^data/',  '^$'}, dirs = {motif.fileDir .. motif.end_credits.storyboard,      'data/' .. motif.end_credits.storyboard}},
	{t = {'game_over_screen', 'storyboard'},       skip = {'^data/',  '^$'}, dirs = {motif.fileDir .. motif.game_over_screen.storyboard, 'data/' .. motif.game_over_screen.storyboard}},
}
for k, v in ipairs(t_dir) do
	local skip = false
	for j = 1, #v.skip do
		if motif[v.t[1]][v.t[2]]:match(v.skip[j]) then
			skip = true
			break
		end
	end
	if not skip then
		for j = 1, #v.dirs do
			if main.f_fileExists(v.dirs[j]) then
				motif[v.t[1]][v.t[2]] = v.dirs[j]
				break
			end
		end
	end
end

motif.files.spr_data = sffNew(motif.files.spr)
main.loadingRefresh()
motif.files.snd_data = sndNew(motif.files.snd)
main.loadingRefresh()
motif.files.glyphs_data = sffNew(motif.files.glyphs)
main.loadingRefresh()

--data
local anim = ''
local facing = ''
t_dir = {'titlebgdef', 'selectbgdef', 'versusbgdef', 'continuebgdef', 'victorybgdef', 'resultsbgdef', 'optionbgdef', 'replaybgdef', 'menubgdef', 'trainingbgdef', 'tournamentbgdef'}
for k, v in ipairs(t_dir) do
	if v == 'trainingbgdef' and t.trainingbgdef == nil then
		motif[v] = motif.menubgdef
	else
		--optional sff paths and data
		if motif[v].spr ~= '' then
			if not motif[v].spr:match('^data/') then
				if main.f_fileExists(motif.fileDir .. motif[v].spr) then
					motif[v].spr = motif.fileDir .. motif[v].spr
				elseif main.f_fileExists('data/' .. motif[v].spr) then
					motif[v].spr = 'data/' .. motif[v].spr
				end
			end
			motif[v].spr_data = sffNew(motif[v].spr)
			main.loadingRefresh()
		else
			motif[v].spr = motif.files.spr
			motif[v].spr_data = motif.files.spr_data
		end
		--backgrounds
		motif[v].bg = bgNew(motif[v].spr_data, motif.def, v:match('^(.+)def$'))
		main.loadingRefresh()
	end
end

local function f_facing(var)
	if var == -1 then
		return 'H'
	else
		return nil
	end
end

local function f_loadSprData(t, t_dir)
	for k, v in ipairs(t_dir) do
		--if t[v.s .. 'offset'] == nil then t[v.s .. 'offset'] = {0, 0} end
		--if t[v.s .. 'scale'] == nil then t[v.s .. 'scale'] = {1.0, 1.0} end
		if #t[v.s .. 'spr'] > 0 then --create sprite data
			if #t[v.s .. 'spr'] == 1 then --fix values
				if type(t[v.s .. 'spr'][1]) == 'string' then
					t[v.s .. 'spr'] = {tonumber(t[v.s .. 'spr'][1]:match('^([0-9]+)')), 0}
				else
					t[v.s .. 'spr'] = {t[v.s .. 'spr'][1], 0}
				end
			end
			if t[v.s .. 'facing'] == -1 then facing = ', H' else facing = '' end
			anim = t[v.s .. 'spr'][1] .. ', ' .. t[v.s .. 'spr'][2] .. ', ' .. t[v.s .. 'offset'][1] + v.x .. ', ' .. t[v.s .. 'offset'][2] + v.y .. ', -1' .. facing
			t[v.s .. 'data'] = animNew(motif.files.spr_data, anim)
			animSetScale(t[v.s .. 'data'], t[v.s .. 'scale'][1], t[v.s .. 'scale'][2])
			animUpdate(t[v.s .. 'data'])
		elseif t[v.s .. 'anim'] ~= nil and motif.anim[t[v.s .. 'anim']] ~= nil then --create animation data
			t[v.s .. 'data'] = main.f_animFromTable(
				motif.anim[t[v.s .. 'anim']],
				motif.files.spr_data,
				t[v.s .. 'offset'][1] + v.x,
				t[v.s .. 'offset'][2] + v.y,
				t[v.s .. 'scale'][1],
				t[v.s .. 'scale'][2],
				f_facing(t[v.s .. 'facing'])
			)
		else --create dummy data
			t[v.s .. 'data'] = animNew(motif.files.spr_data, '-1, -1, 0, 0, -1')
			animUpdate(t[v.s .. 'data'])
		end
		animSetWindow(t[v.s .. 'data'], 0, 0, motif.info.localcoord[1], motif.info.localcoord[2])
		main.loadingRefresh()
	end
end

t = motif.select_info
t_dir = {
	{s = 'cell_bg_',                      x = 0,                                                   y = 0},
	{s = 'cell_random_',                  x = 0,                                                   y = 0},
	{s = 'p1_cursor_active_',             x = 0,                                                   y = 0},
	{s = 'p1_cursor_done_',               x = 0,                                                   y = 0},
	{s = 'p2_cursor_active_',             x = 0,                                                   y = 0},
	{s = 'p2_cursor_done_',               x = 0,                                                   y = 0},
	{s = 'p1_teammenu_bg_',               x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_bg_single_',        x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_bg_simul_',         x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_bg_turns_',         x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_bg_tag_',           x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_bg_ratio_',         x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_selftitle_',        x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_enemytitle_',       x = t.p1_teammenu_pos[1],                                y = t.p1_teammenu_pos[2]},
	{s = 'p1_teammenu_item_cursor_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_value_icon_',       x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_value_empty_icon_', x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio1_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio2_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio3_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio4_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio5_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio6_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p1_teammenu_ratio7_icon_',      x = t.p1_teammenu_pos[1] + t.p1_teammenu_item_offset[1], y = t.p1_teammenu_pos[2] + t.p1_teammenu_item_offset[2]},
	{s = 'p2_teammenu_bg_',               x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_bg_single_',        x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_bg_simul_',         x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_bg_turns_',         x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_bg_tag_',           x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_bg_ratio_',         x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_selftitle_',        x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_enemytitle_',       x = t.p2_teammenu_pos[1],                                y = t.p2_teammenu_pos[2]},
	{s = 'p2_teammenu_item_cursor_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_value_icon_',       x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_value_empty_icon_', x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio1_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio2_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio3_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio4_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio5_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio6_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'p2_teammenu_ratio7_icon_',      x = t.p2_teammenu_pos[1] + t.p2_teammenu_item_offset[1], y = t.p2_teammenu_pos[2] + t.p2_teammenu_item_offset[2]},
	{s = 'stage_portrait_random_',        x = t.stage_pos[1] + t.stage_portrait_offset[1],         y = t.stage_pos[2] + t.stage_portrait_offset[2]},
}
f_loadSprData(motif.select_info, t_dir)

for k, v in ipairs({motif.title_info, motif.option_info, motif.replay_info, motif.menu_info, motif.training_info}) do
	f_loadSprData(v, {
		{s = 'menu_arrow_up_',   x = v.menu_pos[1], y = v.menu_pos[2]},
		{s = 'menu_arrow_down_', x = v.menu_pos[1], y = v.menu_pos[2]},
	})
end
for k, v in ipairs({motif.menu_info, motif.training_info}) do
	f_loadSprData(v, {
		{s = 'movelist_arrow_up_',   x = v.movelist_pos[1], y = v.movelist_pos[2]},
		{s = 'movelist_arrow_down_', x = v.movelist_pos[1], y = v.movelist_pos[2]},
	})
end

motif.glyphs_data = {}
for k, v in pairs(motif.glyphs) do
	--https://www.ssec.wisc.edu/~tomw/java/unicode.html#xE000
	k = numberToRune(v[1] + 0xe000) --Private Use 0xe000 (57344) - 0xf8ff (63743)
	local anim = animNew(motif.files.glyphs_data, v[1] .. ', ' .. v[2] .. ', 0, 0, -1')
	--animSetScale(anim, 1, 1)
	animUpdate(anim)
	motif.glyphs_data[k] = {
		anim = anim,
		--info = animGetSpriteInfo(anim, v[1], v[2]),
		info = animGetSpriteInfo(anim),
	}
end

if motif.vs_screen.p1_name_active_font == nil then
	motif.vs_screen.p1_name_active_font = {
		motif.vs_screen.p1_name_font[1],
		motif.vs_screen.p1_name_font[2],
		motif.vs_screen.p1_name_font[3],
		motif.vs_screen.p1_name_font[4],
		motif.vs_screen.p1_name_font[5],
		motif.vs_screen.p1_name_font[6],
		motif.vs_screen.p1_name_font[7],
		motif.vs_screen.p1_name_font[8]
	}
	motif.vs_screen.p1_name_active_font_scale = {motif.vs_screen.p1_name_font_scale[1], motif.vs_screen.p1_name_font_scale[2]}
end
if motif.vs_screen.p2_name_active_font == nil then
	motif.vs_screen.p2_name_active_font = {
		motif.vs_screen.p2_name_font[1],
		motif.vs_screen.p2_name_font[2],
		motif.vs_screen.p2_name_font[3],
		motif.vs_screen.p2_name_font[4],
		motif.vs_screen.p2_name_font[5],
		motif.vs_screen.p2_name_font[6],
		motif.vs_screen.p2_name_font[7],
		motif.vs_screen.p2_name_font[8]
	}
	motif.vs_screen.p2_name_active_font_scale = {motif.vs_screen.p2_name_font_scale[1], motif.vs_screen.p2_name_font_scale[2]}
end

--commands
local t_cmdItems = {
	motif.title_info.menu_key_next,
	motif.title_info.menu_key_previous,
	motif.title_info.menu_key_accept,
	motif.select_info.teammenu_key_next,
	motif.select_info.teammenu_key_previous,
	motif.select_info.teammenu_key_add,
	motif.select_info.teammenu_key_subtract,
	motif.select_info.teammenu_key_accept,
}
for k, v in ipairs(t_cmdItems) do
	for i, cmd in ipairs (main.f_extractKeys(v)) do
		main.f_commandAdd(cmd)
	end
end

-- If we don't find menu in system.def we use the default one.
if main.t_sort.option_info == nil or #main.t_sort.option_info == 0 then
	motif.setBaseOptionInfo()
end
if main.t_sort.menu_info == nil or #main.t_sort.menu_info == 0 then
	motif.setBaseMenuInfo()
end
if main.t_sort.training_info == nil or #main.t_sort.training_info == 0 then
	motif.setBaseTrainingInfo()
end

if main.debugLog then main.f_printTable(motif, "debug/t_motif.txt") end

return motif
