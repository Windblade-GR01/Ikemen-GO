local replay = {}

replay.txt_title = text:create({
	font =   motif.replay_info.title_font[1],
	bank =   motif.replay_info.title_font[2],
	align =  motif.replay_info.title_font[3],
	text =   motif.replay_info.title_text,
	x =      motif.replay_info.title_offset[1],
	y =      motif.replay_info.title_offset[2],
	scaleX = motif.replay_info.title_font_scale[1],
	scaleY = motif.replay_info.title_font_scale[2],
	r =      motif.replay_info.title_font[4],
	g =      motif.replay_info.title_font[5],
	b =      motif.replay_info.title_font[6],
	src =    motif.replay_info.title_font[7],
	dst =    motif.replay_info.title_font[8],
	height = motif.replay_info.title_font_height,
	defsc =  motif.defaultReplay
})

local t_menuWindow = {0, 0, main.SP_Localcoord[1], main.SP_Localcoord[2]}
if motif.replay_info.menu_window_margins_y[1] ~= 0 or motif.replay_info.menu_window_margins_y[2] ~= 0 then
	t_menuWindow = {
		0,
		math.max(0, motif.replay_info.menu_pos[2] - motif.replay_info.menu_window_margins_y[1]),
		motif.info.localcoord[1],
		motif.replay_info.menu_pos[2] + (motif.replay_info.menu_window_visibleitems - 1) * motif.replay_info.menu_item_spacing[2] + motif.replay_info.menu_window_margins_y[2]
	}
end

function replay.f_replay()
	local cursorPosY = 1
	local moveTxt = 0
	local item = 1
	local t = {}
	for k, v in ipairs(getDirectoryFiles('save/replays')) do
		v:gsub('^(.-)([^\\/]+)%.([^%.\\/]-)$', function(path, filename, ext)
			path = path:gsub('\\', '/')
			ext = ext:lower()
			if ext == 'replay' then
				table.insert(t, {data = text:create({}), window = t_menuWindow, itemname = path .. filename .. '.' .. ext, displayname = filename})
			end
		end)
	end
	table.insert(t, {data = text:create({}), window = t_menuWindow, itemname = 'back', displayname = motif.replay_info.menu_itemname_back})
	main.f_bgReset(motif.replaybgdef.bg)
	main.f_playBGM(false, motif.music.replay_bgm, motif.music.replay_bgm_loop, motif.music.replay_bgm_volume, motif.music.replay_bgm_loopstart, motif.music.replay_bgm_loopend)
	while true do
		main.f_menuCommonDraw(cursorPosY, moveTxt, item, t, 'fadein', 'replay_info', 'replay_info', 'replaybgdef', replay.txt_title, motif.defaultReplay, motif.defaultReplay, false, {})
		cursorPosY, moveTxt, item = main.f_menuCommonCalc(cursorPosY, moveTxt, item, t, 'replay_info', {'$U'}, {'$D'})
		if esc() or main.f_input(main.t_players, {'m'}) or (t[item].itemname == 'back' and main.f_input(main.t_players, {'pal', 's'})) then
			sndPlay(motif.files.snd_data, motif.replay_info.cancel_snd[1], motif.replay_info.cancel_snd[2])
			main.f_menuFade('replay_info', 'fadeout', cursorPosY, moveTxt, item, t)
			main.f_bgReset(motif.titlebgdef.bg)
			if motif.music.replay_bgm ~= '' then
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
			end
			break
		elseif main.f_input(main.t_players, {'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.title_info.cursor_done_snd[1], motif.title_info.cursor_done_snd[2])
			enterReplay(t[item].itemname)
			synchronize()
			math.randomseed(sszRandom())
			--main.menu.submenu.server.loop()
			local f = main.f_checkSubmenu(main.menu.submenu.server, 2)
			if f ~= '' then
				main.f_default()
				main.t_itemname[f](cursorPosY, moveTxt, item, t)
				--resetRemapInput()
			end
			exitNetPlay()
			exitReplay()
		end
	end
end

return replay
