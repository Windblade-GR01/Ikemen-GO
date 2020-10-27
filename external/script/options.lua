local options = {}
--;===========================================================
--; COMMON
--;===========================================================
local modified = false
local needReload = false

require("external.script.option_select")

--return string depending on bool
function options.f_boolDisplay(bool, t, f)
	t = t or motif.option_info.menu_valuename_yes
	f = f or motif.option_info.menu_valuename_no
	if bool == true then
		return t
	else
		return f
	end
end

--return table entry (or ret if specified) if provided key exists in the table, otherwise return default argument
function options.f_definedDisplay(key, t, default, ret)
	if key ~= nil and t[key] ~= nil then
		return ret or t[key]
	end
	return default
end

--return correct precision
function options.f_precision(v, decimal)
	return tonumber(string.format(decimal, v))
end

-- change the numerical value "data" if left or right are pressed, with the minimal and maximal value "min" and "max" (wrapping).
-- also, "min" or (exclusive) "max" can be nil to indicate they can go up to an infinite/negative infinite value (disable wrapping in this case).
-- if accept_nil is set to true, then the value can also be set by the user to nil
-- audio_value is a list with two parameter for changed sound (can be nil for no sound)
-- step is the value that will be changed for each keypresses
--
-- return the new value and if the value has changed in this frame
function options.option_numerical_plage(data, min, max, audio_value, accept_nil, step)
	if min == nil and max == nil then
		print("options.option_numerical_plage called with min and max both nil. Expect unexpected comportement")
	end
	if step == nil then step = 1 end
	if accept_nil ~= true and data == nil then
		data = min
	end
	local changed = false
	if main.f_input(main.t_players, {'$F'}) then
		changed = true
		if data == nil and min ~= nil then
			data = min
		else
			data = data + step
			if max ~= nil then
				if data > max then
					if accept_nil then
						data = nil
					else
						if min == nil then
							data = max
						else
							data = min
						end
					end
				end
			end
		end
	elseif main.f_input(main.t_players, {'$B'}) then
		changed = true
		if data == nil and max ~= nil then
			data = max
		else
			data = data - step
			if min ~= nil then
				if data < min then
					if accept_nil then
						data = nil
					else
						if max == nil then
							data = min
						else
							data = max
						end
					end
				end
			end
		end
	end
	if changed then
		if audio_value ~= nil then
			sndPlay(motif.files.snd_data, audio_value[1], audio_value[2])
		end
	end
	return data, changed
end

--save configuration
function options.f_saveCfg(reload)
	--Data saving to config.json
	local file = io.open(main.flags['-config'], 'w+')
	file:write(json.encode(config, {indent = true}))
	file:close()

	-- save change to select.def
	if option_select.select_characters ~= nil then
		local need_to_save_select = false
		for k, v in ipairs(option_select.select_characters) do
			if v["changed"] == true then
				local chara_definition = file_def.rebuild_char(v)
				if v.line == nil then
					local new_line = {kind = "empty", initial_whitespace = ""}
					table.insert(option_select.select_lines, option_select.last_character_line, new_line)
					option_select.last_character_line = option_select.last_character_line + 1
					v.line = new_line
				end
				if v.user_enabled == true then
					v.line.kind = "data"
					v.line.data = chara_definition
				else
					v.line.kind = "empty"
					v.line.have_comment = true
					v.line.comment = "CHARDISABLED:" .. chara_definition
				end
				need_to_save_select = true
			end
		end

		if need_to_save_select then
			local select_compiled = file_def.rebuild_source_file(option_select.select_lines)
			local file = io.open(motif.files.select, 'w+')
			file:write(select_compiled)
			file:close()
		end
	end

	--Reload game if needed
	if reload then
		main.f_warning(main.f_extractText(motif.warning_info.text_reload_text), motif.option_info, motif.optionbgdef)
		os.exit()
	end
end

--reset key settings
function options.f_keyDefault()
	for i = 1, #config.KeyConfig do
		if i == 1 then
			config.KeyConfig[i].Buttons[1] = 'UP'
			config.KeyConfig[i].Buttons[2] = 'DOWN'
			config.KeyConfig[i].Buttons[3] = 'LEFT'
			config.KeyConfig[i].Buttons[4] = 'RIGHT'
			config.KeyConfig[i].Buttons[5] = 'z'
			config.KeyConfig[i].Buttons[6] = 'x'
			config.KeyConfig[i].Buttons[7] = 'c'
			config.KeyConfig[i].Buttons[8] = 'a'
			config.KeyConfig[i].Buttons[9] = 's'
			config.KeyConfig[i].Buttons[10] = 'd'
			config.KeyConfig[i].Buttons[11] = 'RETURN'
			config.KeyConfig[i].Buttons[12] = 'q'
			config.KeyConfig[i].Buttons[13] = 'w'
			config.KeyConfig[i].Buttons[14] = 'Not used'
		elseif i == 2 then
			config.KeyConfig[i].Buttons[1] = 'i'
			config.KeyConfig[i].Buttons[2] = 'k'
			config.KeyConfig[i].Buttons[3] = 'j'
			config.KeyConfig[i].Buttons[4] = 'l'
			config.KeyConfig[i].Buttons[5] = 'f'
			config.KeyConfig[i].Buttons[6] = 'g'
			config.KeyConfig[i].Buttons[7] = 'h'
			config.KeyConfig[i].Buttons[8] = 'r'
			config.KeyConfig[i].Buttons[9] = 't'
			config.KeyConfig[i].Buttons[10] = 'y'
			config.KeyConfig[i].Buttons[11] = 'RSHIFT'
			config.KeyConfig[i].Buttons[12] = 'LEFTBRACKET'
			config.KeyConfig[i].Buttons[13] = 'RIGHTBRACKET'
			config.KeyConfig[i].Buttons[14] = 'Not used'
		else
			for j = 1, #config.KeyConfig[i].Buttons do
				config.KeyConfig[i].Buttons[j] = tostring(motif.option_info.menu_valuename_nokey)
			end
		end
	end
	for i = 1, #config.JoystickConfig do
		config.JoystickConfig[i].Buttons[1] = '10'
		config.JoystickConfig[i].Buttons[2] = '12'
		config.JoystickConfig[i].Buttons[3] = '13'
		config.JoystickConfig[i].Buttons[4] = '11'
		config.JoystickConfig[i].Buttons[5] = '0'
		config.JoystickConfig[i].Buttons[6] = '1'
		config.JoystickConfig[i].Buttons[7] = '4'
		config.JoystickConfig[i].Buttons[8] = '2'
		config.JoystickConfig[i].Buttons[9] = '3'
		config.JoystickConfig[i].Buttons[10] = '5'
		config.JoystickConfig[i].Buttons[11] = '7'
		config.JoystickConfig[i].Buttons[12] = '-10'
		config.JoystickConfig[i].Buttons[13] = '-12'
		config.JoystickConfig[i].Buttons[14] = '6'
	end
	resetRemapInput()
end

options.txt_title = text:create({
	font =   motif.option_info.title_font[1],
	bank =   motif.option_info.title_font[2],
	align =  motif.option_info.title_font[3],
	text =   '',
	x =      motif.option_info.title_offset[1],
	y =      motif.option_info.title_offset[2],
	scaleX = motif.option_info.title_font_scale[1],
	scaleY = motif.option_info.title_font_scale[2],
	r =      motif.option_info.title_font[4],
	g =      motif.option_info.title_font[5],
	b =      motif.option_info.title_font[6],
	src =    motif.option_info.title_font[7],
	dst =    motif.option_info.title_font[8],
	height = motif.option_info.title_font_height,
	--defsc =  motif.defaultOptions --title font assignment exists in mugen
})

--;===========================================================
--; LOOPS
--;===========================================================
function options.f_displayRatio(value)
	local ret = options.f_precision((value - 1) * 100, '%.01f')
	if ret >= 0 then
		return '+' .. ret .. '%'
	end
	return ret .. '%'
end

local function f_externalShaderName()
	if #config.ExternalShaders > 0 and config.PostProcessingShader ~= 0 then
		return config.ExternalShaders[1]:gsub('^.+/', '')
	end
	return motif.option_info.menu_valuename_disabled
end

options.t_itemname = {
	--Back
	['back'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			return false
		end
		return true
	end,
	--Port Change
	['portchange'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			local port = main.f_drawInput(main.f_extractText(motif.option_info.input_port_text), motif.option_info, motif.optionbgdef, 'string')
			if tonumber(port) ~= nil then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
				config.ListenPort = tostring(port)
				setListenPort(port)
				t.items[item].vardisplay = getListenPort()
				modified = true
			else
				sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			end
		end
		return true
	end,
	-- characters management
	['characters'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			option_select.f_loop_character_edit()
			--TODO: let option_select.f_loop_character_edit control if modified should be set
			modified = true
		end
		return true
	end,
	--Default Values
	['default'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
			config.AIRamping = true
			config.AIRandomColor = true
			config.AudioDucking = false
			config.AutoGuard = false
			config.BarGuard = false
			config.BarRedLife = true
			config.BarStun = false
			config.Borderless = false
			config.ComboExtraFrameWindow = 1
			--config.CommonAir = "data/common.air"
			--config.CommonCmd = "data/common.cmd"
			--config.CommonLua = {
			--	"loop()"
			--}
			--config.CommonStates = {
			--	"data/dizzy.zss",
			--	"data/guardbreak.zss",
			--	"data/score.zss",
			--	"data/tag.zss"
			--}
			config.ConsoleType = 1
			--config.ControllerStickSensitivity = 0.4
			config.Credits = 10
			--config.DebugFont = "font/f-4x6.def"
			config.DebugKeys = true
			config.Difficulty = 8
			config.ExternalShaders = {}
			config.ForceStageZoomin = 0
			config.ForceStageZoomout = 0
			config.Fullscreen = false
			config.GameWidth = 640
			config.GameHeight = 480
			config.GameSpeed = 100
			--config.IP = {}
			--config.LegacyMode = false
			config.LifebarFontScale = 1
			config.LifeMul = 100
			config.ListenPort = "7500"
			config.LocalcoordScalingType = 1
			config.LoseSimul = true
			config.LoseTag = false
			config.MaxDrawGames = -2
			--config.Motif = "data/system.def"
			config.MaxHelper = 56
			config.MaxPlayerProjectile = 256
			config.MaxExplod = 512
			config.MaxAfterImage = 128
			config.MSAA = false
			config.NumSimul = {2, 4}
			config.NumTag = {2, 4}
			config.NumTurns = {2, 4}
			config.PostProcessingShader = 0
			config.PreloadingBig = true
			config.PreloadingSmall = true
			config.PreloadingStage = true
			config.PreloadingVersus = true
			config.QuickContinue = false
			config.RatioLife = {0.80, 1.0, 1.17, 1.40}
			config.RatioAttack = {0.82, 1.0, 1.17, 1.30}
			config.RoundsNumSingle = 2
			config.RoundsNumTeam = 2
			config.RoundTime = 99
			config.SafeLoading = false
			config.SingleVsTeamLife = 100
			--config.System = "external/script/main.lua"
			config.TeamLifeAdjustment = false
			config.TeamPowerShare = true
			--config.TrainingChar = "chars/training/training.def"
			config.TurnsRecoveryBase = 0
			config.TurnsRecoveryBonus = 20
			config.VolumeBgm = 80
			config.VolumeMaster = 80
			config.VolumeSfx = 80
			config.VRetrace = 1
			--config.WindowIcon = "external/icons/IkemenCylia.png"
			--config.WindowTitle = "Ikemen GO"
			--config.XinputTriggerSensitivity = 0
			config.ZoomActive = true
			config.ZoomDelay = false
			config.ZoomSpeed = 1
			loadLifebar(motif.files.fight)
			main.timeFramesPerCount = getTimeFramesPerCount()
			main.f_updateRoundsNum()
			options.f_resetVardisplay(options.menu)
			setAllowDebugKeys(config.DebugKeys)
			setAudioDucking(config.AudioDucking)
			setGameSpeed(config.GameSpeed / 100)
			setLifeAdjustment(config.TeamLifeAdjustment)
			setLifeMul(config.LifeMul / 100)
			setListenPort(config.ListenPort)
			setLoseSimul(config.LoseSimul)
			setLoseTag(config.LoseTag)
			setMaxAfterImage(config.MaxAfterImage)
			setMaxExplod(config.MaxExplod)
			setMaxHelper(config.MaxHelper)
			setMaxPlayerProjectile(config.MaxPlayerProjectile)
			setPowerShare(1, config.TeamPowerShare)
			setPowerShare(2, config.TeamPowerShare)
			setSingleVsTeamLife(config.SingleVsTeamLife / 100)
			setTurnsRecoveryBase(config.TurnsRecoveryBase / 100)
			setTurnsRecoveryBonus(config.TurnsRecoveryBonus / 100)
			setVolumeBgm(config.VolumeBgm)
			setVolumeMaster(config.VolumeMaster)
			setVolumeSfx(config.VolumeSfx)
			setZoom(config.ZoomActive)
			setZoomMax(config.ForceStageZoomin)
			setZoomMin(config.ForceStageZoomout)
			setZoomSpeed(config.ZoomSpeed)
			toggleFullscreen(config.Fullscreen)
			toggleVsync(config.VRetrace)
			modified = true
			needReload = true
		end
		return true
	end,
	--Save and Return
	['savereturn'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			if modified then
				options.f_saveCfg(needReload)
			end

			option_select.reload_base_character()

			main.f_menuFade('option_info', 'fadeout', cursorPosY, moveTxt, item, t.items)
			main.f_bgReset(motif.titlebgdef.bg)
			if motif.music.option_bgm ~= '' then
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
			end
			return false
		end
		return true
	end,
	--Return Without Saving
	['return'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			if needReload then
				main.f_warning(main.f_extractText(motif.warning_info.text_noreload_text), motif.option_info, motif.optionbgdef)
			end

			option_select.reload_base_character()

			main.f_menuFade('option_info', 'fadeout', cursorPosY, moveTxt, item, t.items)
			main.f_bgReset(motif.titlebgdef.bg)
			if motif.music.option_bgm ~= '' then
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
			end
			return false
		end
		return true
	end,
	--Time Limit
	['roundtime'] = function(cursorPosY, moveTxt, item, t)
		config.RoundTime, changed = options.option_numerical_plage(config.RoundTime, -1, 1000, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = options.f_definedDisplay(config.RoundTime, {[-1] = motif.option_info.menu_valuename_none}, config.RoundTime)
		end
		return true
	end,
	--Rounds to Win Single
	['roundsnumsingle'] = function(cursorPosY, moveTxt, item, t)
		main.roundsNumSingle, changed = options.option_numerical_plage(main.roundsNumSingle, 1, 10, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = main.roundsNumSingle
			config.RoundsNumSingle = main.roundsNumSingle
		end
		return true
	end,
	--Rounds to Win Simul/Tag
	['roundsnumteam'] = function(cursorPosY, moveTxt, item, t)
		main.roundsNumTeam, changed = options.option_numerical_plage(main.roundsNumTeam, 1, 10, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = main.roundsNumTeam
			config.RoundsNumTeam = main.roundsNumTeam
		end
		return true
	end,
	--Max Draw Games
	['maxdrawgames'] = function(cursorPosY, moveTxt, item, t)
		main.maxDrawGames, changed = options.option_numerical_plage(main.maxDrawGames, -1, 10, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = main.maxDrawGames
			config.MaxDrawGames = main.maxDrawGames
		end
		return true
	end,
	--Difficulty Level
	['difficulty'] = function(cursorPosY, moveTxt, item, t)
		config.Difficulty, changed = options.option_numerical_plage(config.Difficulty, 1, 8, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.Difficulty
		end
		return true
	end,
	--Credits
	['credits'] = function(cursorPosY, moveTxt, item, t)
		config.Credits, changed = options.option_numerical_plage(config.Credits, 1, 99, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.Credits
		end
		return true
	end,
	--Quick Continue
	['quickcontinue'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.QuickContinue then
				config.QuickContinue = false
			else
				config.QuickContinue = true
				end
			t.items[item].vardisplay = options.f_boolDisplay(config.QuickContinue)
			modified = true
		end
		return true
	end,
	--AI Ramping
	['airamping'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.AIRamping then
				config.AIRamping = false
			else
				config.AIRamping = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.AIRamping)
			modified = true
		end
		return true
	end,
	--AI Palette
	['aipalette'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.AIRandomColor then
				config.AIRandomColor = false
			else
				config.AIRandomColor = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.AIRandomColor, motif.option_info.menu_valuename_random, motif.option_info.menu_valuename_default)
			modified = true
		end
		return true
	end,
	--Resolution (submenu)
	['resolution'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			local t_pos = {}
			local ok = false
			for k, v in ipairs(t.submenu[t.items[item].itemname].items) do
				local width, height = v.itemname:match('^([0-9]+)x([0-9]+)$')
				if tonumber(width) == config.GameWidth and tonumber(height) == config.GameHeight then
					v.selected = true
					ok = true
				else
					v.selected = false
				end
				if v.itemname == 'customres' then
					t_pos = v
				end
			end
			if not ok and t_pos.selected ~= nil then
				t_pos.selected = true
			end
			t.submenu[t.items[item].itemname].loop()
			t.items[item].vardisplay = config.GameWidth .. 'x' .. config.GameHeight
		end
		return true
	end,
	--Fullscreen
	['fullscreen'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.Fullscreen then
				config.Fullscreen = false
			else
				config.Fullscreen = true
			end
			toggleFullscreen(config.Fullscreen)
			t.items[item].vardisplay = options.f_boolDisplay(config.Fullscreen)
			modified = true
		end
		return true
	end,
	--VSync
	['vretrace'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.VRetrace == 1 then
				config.VRetrace = 0
			else
				config.VRetrace = 1
			end
			toggleVsync()
			t.items[item].vardisplay = options.f_definedDisplay(config.VRetrace, {[1] = motif.option_info.menu_valuename_enabled}, motif.option_info.menu_valuename_disabled)
			modified = true
		end
		return true
	end,
	--MSAA
	['msaa'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.MSAA then
				config.MSAA = false
			else
				config.MSAA = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.MSAA, motif.option_info.menu_valuename_enabled, motif.option_info.menu_valuename_disabled)
			modified = true
			needReload = true
		end
		return true
	end,
	--Shaders (submenu)
	['shaders'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if #options.t_shaders == 0 then
				main.f_warning(main.f_extractText(motif.warning_info.text_shaders_text), motif.option_info, motif.optionbgdef)
				return true
			end
			for k, v in ipairs(t.submenu[t.items[item].itemname].items) do
				if config.ExternalShaders[1] == v.itemname then
					v.selected = true
				else
					v.selected = false
				end
			end
			t.submenu[t.items[item].itemname].loop()
			t.items[item].vardisplay = f_externalShaderName()
			modified = true
			needReload = true
		end
		return true
	end,
	--Disable (shader)
	['noshader'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			config.ExternalShaders = {}
			config.PostProcessingShader = 0
			modified = true
			needReload = true
			return false
		end
		return true
	end,
	--Custom resolution
	['customres'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			local width = tonumber(main.f_drawInput(main.f_extractText(motif.option_info.input_reswidth_text), motif.option_info, motif.optionbgdef, 'string'))
			if width ~= nil then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
				local height = tonumber(main.f_drawInput(main.f_extractText(motif.option_info.input_resheight_text), motif.option_info, motif.optionbgdef, 'string'))
				if height ~= nil then
					config.GameWidth = width
					config.GameHeight = height
					sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
					if (height / 3 * 4) ~= width then
						main.f_warning(main.f_extractText(motif.warning_info.text_res_text), motif.option_info, motif.optionbgdef)
					end
					modified = true
					needReload = true
				else
					sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
				end
			else
				sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			end
			return false
		end
		return true
	end,
	--Master Volume
	['mastervolume'] = function(cursorPosY, moveTxt, item, t)
		config.VolumeMaster, changed = options.option_numerical_plage(config.VolumeMaster, 0, 200, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.VolumeMaster .. '%'
			setVolumeMaster(config.VolumeMaster)
		end
		return true
	end,
	--BGM Volume
	['bgmvolume'] = function(cursorPosY, moveTxt, item, t)
		config.VolumeBgm, changed = options.option_numerical_plage(config.VolumeBgm, 0, 100, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.VolumeBgm .. '%'
			setVolumeBgm(config.VolumeMaster)
		end
		return true
	end,
	--SFX Volume
	['sfxvolume'] = function(cursorPosY, moveTxt, item, t)
		config.VolumeSfx, changed = options.option_numerical_plage(config.VolumeSfx, 0, 100, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.VolumeSfx .. '%'
			setVolumeSfx(config.VolumeSfx)
		end
		return true
	end,
	--Audio Ducking
	['audioducking'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.AudioDucking then
				config.AudioDucking = false
			else
				config.AudioDucking = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.AudioDucking, motif.option_info.menu_valuename_enabled, motif.option_info.menu_valuename_disabled)
			setAudioDucking(config.AudioDucking)
			modified = true
		end
		return true
	end,
	--Life
	['lifemul'] = function(cursorPosY, moveTxt, item, t)
		config.LifeMul, changed = options.option_numerical_plage(config.LifeMul, 10, 300, motif.option_info.cursor_move_snd, nil, 10)
		if changed then
			modified = true
			t.items[item].vardisplay = config.LifeMul .. '%'
			setLifeMul(config.LifeMul / 100)
		end
		return true
	end,
	--Game Speed
	['gamespeed'] = function(cursorPosY, moveTxt, item, t)
		config.GameSpeed, changed = options.option_numerical_plage(config.GameSpeed, 10, 200, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.GameSpeed .. '%'
			setGameSpeed(config.GameSpeed / 100)
		end
		return true
	end,
	--Auto-Guard
	['autoguard'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.AutoGuard then
				config.AutoGuard = false
			else
				config.AutoGuard = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.AutoGuard)
			modified = true
		end
		return true
	end,
	--Guard Break
	['guardbar'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.BarGuard then
				config.BarGuard = false
			else
				config.BarGuard = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.BarGuard)
			modified = true
		end
		return true
	end,
	--Dizzy
	['stunbar'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.BarStun then
				config.BarStun = false
			else
				config.BarStun = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.BarStun)
			modified = true
		end
		return true
	end,
	--Red Life
	['redlifebar'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.BarRedLife then
				config.BarRedLife = false
			else
				config.BarRedLife = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.BarRedLife)
			modified = true
		end
		return true
	end,
	--Single VS Team Life
	['singlevsteamlife'] = function(cursorPosY, moveTxt, item, t)
		config.SingleVsTeamLife, changed = options.option_numerical_plage(config.SingleVsTeamLife, 10, 300, motif.option_info.cursor_move_snd, nil, 10)
		if changed then
			modified = true
			t.items[item].vardisplay = config.SingleVsTeamLife .. '%'
			setSingleVsTeamLife(config.SingleVsTeamLife / 100)
		end
		return true
	end,
	--Team Life Adjustment
	['teamlifeadjustment'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.TeamLifeAdjustment then
				config.TeamLifeAdjustment = false
			else
				config.TeamLifeAdjustment = true
			end
			setLifeAdjustment(config.TeamLifeAdjustment)
			t.items[item].vardisplay = options.f_boolDisplay(config.TeamLifeAdjustment)
			modified = true
		end
		return true
	end,
	--Team Power Share
	['teampowershare'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.TeamPowerShare then
				config.TeamPowerShare = false
			else
				config.TeamPowerShare = true
			end
			setPowerShare(1, config.TeamPowerShare)
			setPowerShare(2, config.TeamPowerShare)
			t.items[item].vardisplay = options.f_boolDisplay(config.TeamPowerShare)
			modified = true
		end
		return true
	end,
	--Simul Player KOed Lose
	['losekosimul'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.LoseSimul then
				config.LoseSimul = false
			else
				config.LoseSimul = true
			end
			setLoseSimul(config.LoseSimul)
			t.items[item].vardisplay = options.f_boolDisplay(config.LoseSimul)
			modified = true
		end
		return true
	end,
	--Tag Partner KOed Lose
	['losekotag'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.LoseTag then
				config.LoseTag = false
			else
				config.LoseTag = true
			end
			setLoseTag(config.LoseTag)
			t.items[item].vardisplay = options.f_boolDisplay(config.LoseTag)
			modified = true
		end
		return true
	end,
	--Turns Recovery Base
	['turnsrecoverybase'] = function(cursorPosY, moveTxt, item, t)
		config.TurnsRecoveryBase, changed = options.option_numerical_plage(config.TurnsRecoveryBase, 0, 100, motif.option_info.cursor_move_snd, nil, 0.5)
		if changed then
			modified = true
			t.items[item].vardisplay = config.TurnsRecoveryBase .. '%'
			setTurnsRecoveryBase(config.TurnsRecoveryBase / 100)
		end
		return true
	end,
	--Turns Recovery Bonus
	['turnsrecoverybonus'] = function(cursorPosY, moveTxt, item, t)
		config.TurnsRecoveryBonus, changed = options.option_numerical_plage(config.TurnsRecoveryBonus, 0, 100, motif.option_info.cursor_move_snd, nil, 0.5)
		if changed then
			modified = true
			setTurnsRecoveryBonus(config.TurnsRecoveryBonus / 100)
			t.items[item].vardisplay = config.TurnsRecoveryBonus .. '%'
		end
		return true
	end,
	--Min Turns Chars
	['minturns'] = function(cursorPosY, moveTxt, item, t)
		config.NumTurns[1], changed = options.option_numerical_plage(config.NumTurns[1], 1, config.NumTurns[2], motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.NumTurns[1]
		end
		return true
	end,
	--Max Turns Chars
	['maxturns'] = function(cursorPosY, moveTxt, item, t)
		config.NumTurns[2], changed = options.option_numerical_plage(config.NumTurns[2], config.NumTurns[1], 8, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.NumTurns[2]
		end
		return true
	end,
	--Min Simul Chars
	['minsimul'] = function(cursorPosY, moveTxt, item, t)
		config.NumSimul[1], changed = options.option_numerical_plage(config.NumSimul[1], 2, NumSimul[2], motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.NumSimul[1]
		end
		return true
	end,
	--Max Simul Chars
	['maxsimul'] = function(cursorPosY, moveTxt, item, t)
		config.NumSimul[2], changed = options.option_numerical_plage(config.NumSimul[2], config.NumSimul[1], 8, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.NumTurns[2]
		end
		return true
	end,
	--Min Tag Chars
	['mintag'] = function(cursorPosY, moveTxt, item, t)
		config.NumTag[1], changed = options.option_numerical_plage(config.NumTag[1], 2, config.NumTag[2], motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.NumTag[1]
		end
		return true
	end,
	--Max Tag Chars
	['maxtag'] = function(cursorPosY, moveTxt, item, t)
		config.NumTag[2], changed = options.option_numerical_plage(config.NumTag[2], config.NumTag[1], 4, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.NumTag[2]
		end
		return true
	end,
	--Debug Keys
	['debugkeys'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.DebugKeys then
				config.DebugKeys = false
			else
				config.DebugKeys = true
			end
			t.items[item].vardisplay = options.f_boolDisplay(config.DebugKeys, motif.option_info.menu_valuename_enabled, motif.option_info.menu_valuename_disabled)
			setAllowDebugKeys(config.DebugKeys)
			modified = true
		end
		return true
	end,
	--HelperMax
	['helpermax'] = function(cursorPosY, moveTxt, item, t)
		config.MaxHelper, changed = options.option_numerical_plage(config.MaxHelper, 1, nil, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.MaxHelper
			setMaxHelper(config.MaxHelper)
		end
		return true
	end,
	--PlayerProjectileMax
	['projectilemax'] = function(cursorPosY, moveTxt, item, t)
		config.MaxPlayerProjectile, changed = options.option_numerical_plage(config.MaxPlayerProjectile, 1, nil, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.MaxPlayerProjectile
			setMaxPlayerProjectile(config.MaxPlayerProjectile)
		end
		return true
	end,
	--ExplodMax
	['explodmax'] = function(cursorPosY, moveTxt, item, t)
		config.MaxExplod, changed = options.option_numerical_plage(config.MaxExplod, 1, nil, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.MaxExplod
			setMaxExplod(config.MaxPlayerProjectile)
		end
		return true
	end,
	--AfterImageMax
	['afterimagemax'] = function(cursorPosY, moveTxt, item, t)
		config.MaxAfterImage, changed = options.option_numerical_plage(config.MaxAfterImage, 1, nil, motif.option_info.cursor_move_snd)
		if changed then
			modified = true
			t.items[item].vardisplay = config.MaxAfterImage
			setMaxAfterImage(config.MaxAfterImage)
		end
		return true
	end,
	--Small portraits
	['preloadingsmall'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.PreloadingSmall then
				config.PreloadingSmall = false
			else
				config.PreloadingSmall = true
				end
			t.items[item].vardisplay = options.f_boolDisplay(config.PreloadingSmall)
			modified = true
		end
		return true
	end,
	--Select portraits
	['preloadingbig'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.PreloadingBig then
				config.PreloadingBig = false
			else
				config.PreloadingBig = true
				end
			t.items[item].vardisplay = options.f_boolDisplay(config.PreloadingBig)
			modified = true
		end
		return true
	end,
	--Versus portraits
	['preloadingversus'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.PreloadingVersus then
				config.PreloadingVersus = false
			else
				config.PreloadingVersus = true
				end
			t.items[item].vardisplay = options.f_boolDisplay(config.PreloadingVersus)
			modified = true
		end
		return true
	end,
	--Stage portraits
	['preloadingstage'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'$F', '$B', 'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if config.PreloadingStage then
				config.PreloadingStage = false
			else
				config.PreloadingStage = true
				end
			t.items[item].vardisplay = options.f_boolDisplay(config.PreloadingStage)
			modified = true
		end
		return true
	end,
	--Key Config
	['keyboard'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'pal', 's'}) --[[or getKey() == 'F1']] then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			options.f_keyCfgInit('KeyConfig', t.submenu[t.items[item].itemname].title)
			while true do
				if not options.f_keyCfg('KeyConfig', t.items[item].itemname, 'optionbgdef', false) then
					break
				end
			end
		end
		return true
	end,
	--Joystick Config
	['gamepad'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'pal', 's'}) --[[or getKey() == 'F2']] then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
			if main.flags['-nojoy'] == nil then
				options.f_keyCfgInit('JoystickConfig', t.submenu[t.items[item].itemname].title)
				while true do
					if not options.f_keyCfg('JoystickConfig', t.items[item].itemname, 'optionbgdef', false) then
						break
					end
				end
			end
		end
		return true
	end,
	--Default
	['inputdefault'] = function(cursorPosY, moveTxt, item, t)
		if main.f_input(main.t_players, {'pal', 's'}) then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
			options.f_keyDefault()
			for pn = 1, #config.KeyConfig do
				setKeyConfig(pn, config.KeyConfig[pn].Joystick, config.KeyConfig[pn].Buttons)
			end
			if main.flags['-nojoy'] == nil then
				for pn = 1, #config.JoystickConfig do
					setKeyConfig(pn, config.JoystickConfig[pn].Joystick, config.JoystickConfig[pn].Buttons)
				end
			end
			modified = true
		end
		return true
	end,
}

--external shaders
options.t_shaders = {}
for k, v in ipairs(getDirectoryFiles('external/shaders')) do
	v:gsub('^(.-)([^\\/]+)%.([^%.\\/]-)$', function(path, filename, ext)
		path = path:gsub('\\', '/')
		ext = ext:lower()
		if ext == 'frag' then
			table.insert(options.t_shaders, {path = path, filename = filename})
		end
		if ext:match('vert') or ext:match('frag') --[[or ext:match('shader')]] then
			options.t_itemname[path .. filename] = function(cursorPosY, moveTxt, item, t)
				if main.f_input(main.t_players, {'pal', 's'}) then
					sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
					config.ExternalShaders = {path .. filename}
					config.PostProcessingShader = 4
					return false
				end
				return true
			end
		end
	end)
end
for k, v in ipairs(main.t_sort.option_info) do
	--resolution
	if v:match('_[0-9]+x[0-9]+$') then
		local width, height = v:match('_([0-9]+)x([0-9]+)$')
		options.t_itemname[width .. 'x' .. height] = function(cursorPosY, moveTxt, item, t)
			if main.f_input(main.t_players, {'pal', 's'}) then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
				config.GameWidth = tonumber(width)
				config.GameHeight = tonumber(height)
				if (config.GameHeight / 3 * 4) ~= config.GameWidth then
					main.f_warning(main.f_extractText(motif.warning_info.text_res_text), motif.option_info, motif.optionbgdef)
				end
				modified = true
				needReload = true
				return false
			end
			return true
		end
	--ratio
	elseif v:match('_ratio[1-4]+[al].-$') then
		local ratioLevel, tmp1, tmp2 = v:match('_ratio([1-4])([al])(.-)$')
		options.t_itemname['ratio' .. ratioLevel .. tmp1 .. tmp2] = function(cursorPosY, moveTxt, item, t)
			local ratioType = tmp1:upper() .. tmp2
			ratioLevel = tonumber(ratioLevel)
			if main.f_input(main.t_players, {'$F'}) then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
				config['Ratio' .. ratioType][ratioLevel] = options.f_precision(config['Ratio' .. ratioType][ratioLevel] + 0.01, '%.02f')
				t.items[item].vardisplay = options.f_displayRatio(config['Ratio' .. ratioType][ratioLevel])
				modified = true
			elseif main.f_input(main.t_players, {'$B'}) and config['Ratio' .. ratioType][ratioLevel] > 0.01 then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
				config['Ratio' .. ratioType][ratioLevel] = options.f_precision(config['Ratio' .. ratioType][ratioLevel] - 0.01, '%.02f')
				t.items[item].vardisplay = options.f_displayRatio(config['Ratio' .. ratioType][ratioLevel])
				modified = true
			end
			return true
		end
	end
end
if main.debugLog then main.f_printTable(options.t_itemname, 'debug/t_optionsItemname.txt') end

function options.createMenu(tbl, bool_bgreset, bool_main, bool_f1)
	return function()
		local cursorPosY = 1
		local moveTxt = 0
		local item = 1
		local t = tbl.items
		if bool_bgreset then
			main.f_bgReset(motif.optionbgdef.bg)
			main.f_playBGM(false, motif.music.option_bgm, motif.music.option_bgm_loop, motif.music.option_bgm_volume, motif.music.option_bgm_loopstart, motif.music.option_bgm_loopend)
			if #main.t_sort.option_info == 0 then
				main.f_warning(main.f_extractText(motif.warning_info.text_options_text), motif.option_info, motif.optionbgdef)
				return
			end
		end
		while true do
			if tbl.reset then
				tbl.reset = false
				main.f_cmdInput()
			else
				main.f_menuCommonDraw(cursorPosY, moveTxt, item, t, 'fadein', 'option_info', 'option_info', 'optionbgdef', options.txt_title, motif.defaultOptions, motif.defaultOptions, false, {})
			end
			cursorPosY, moveTxt, item = main.f_menuCommonCalc(cursorPosY, moveTxt, item, t, 'option_info', {'$U'}, {'$D'})
			options.txt_title:update({text = tbl.title})
			if esc() or main.f_input(main.t_players, {'m'}) then
				sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
				if bool_main then
					if modified then
						--options.f_saveCfg(needReload)
					end
					if needReload then
						main.f_warning(main.f_extractText(motif.warning_info.text_noreload_text), motif.option_info, motif.optionbgdef)
					end
					option_select.reload_base_character()
					main.f_menuFade('option_info', 'fadeout', cursorPosY, moveTxt, item, t)
					main.f_bgReset(motif.titlebgdef.bg)
					if motif.music.option_bgm ~= '' then
						main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
					end
				end
				break
			elseif bool_f1 and (getKey() == 'F1' or getKey() == 'F2') then
				if not options.t_itemname.keyboard(cursorPosY, moveTxt, item, tbl) then
					break
				end
				if not options.t_itemname.gamepad(cursorPosY, moveTxt, item, tbl) then
					break
				end
			elseif t[item].func ~= nil then
				if not t[item].func(cursorPosY, moveTxt, item, tbl) then
					break
				end
			elseif options.t_itemname[t[item].itemname] ~= nil then
				if not options.t_itemname[t[item].itemname](cursorPosY, moveTxt, item, tbl) then
					break
				end
			elseif main.f_input(main.t_players, {'pal', 's'}) then
				local f = main.f_checkSubmenu(tbl.submenu[t[item].itemname])
				if f ~= '' and not options.t_itemname[f](cursorPosY, moveTxt, item, tbl) then
					break
				end
			end
		end
	end
end

--reset vardisplay in tables
function options.f_resetVardisplay(t)
	for k, v in pairs(t) do
		if k == 'items' and type(v) == "table" and #v > 0 then
			for i, v2 in ipairs(v) do
				if v2.vardisplay ~= nil then
					v2.vardisplay = options.f_vardisplay(v2.itemname)
				end
			end
		elseif k == 'submenu' and type(v) == "table" then
			for k2, v2 in pairs(v) do
				options.f_resetVardisplay(v2)
			end
		end
	end
end

function options.f_vardisplay(itemname)
	if itemname == 'portchange' then return config.ListenPort end
	if itemname == 'roundtime' then return options.f_definedDisplay(config.RoundTime, {[-1] = motif.option_info.menu_valuename_none}, config.RoundTime) end
	if itemname == 'roundsnumsingle' then return main.roundsNumSingle end
	if itemname == 'roundsnumteam' then return main.roundsNumTeam end
	if itemname == 'maxdrawgames' then return main.maxDrawGames end
	if itemname == 'difficulty' then return config.Difficulty end
	if itemname == 'credits' then return config.Credits end
	if itemname == 'quickcontinue' then return options.f_boolDisplay(config.QuickContinue) end
	if itemname == 'airamping' then return options.f_boolDisplay(config.AIRamping) end
	if itemname == 'aipalette' then return options.f_boolDisplay(config.AIRandomColor, motif.option_info.menu_valuename_random, motif.option_info.menu_valuename_default) end
	if itemname == 'resolution' then return config.GameWidth .. 'x' .. config.GameHeight end
	if itemname == 'fullscreen' then return options.f_boolDisplay(config.Fullscreen) end
	if itemname == 'vretrace' then return options.f_definedDisplay(config.VRetrace, {[1] = motif.option_info.menu_valuename_enabled}, motif.option_info.menu_valuename_disabled) end
	if itemname == 'msaa' then return options.f_boolDisplay(config.MSAA, motif.option_info.menu_valuename_enabled, motif.option_info.menu_valuename_disabled) end
	if itemname == 'shaders' then return f_externalShaderName() end
	if itemname == 'mastervolume' then return config.VolumeMaster .. '%' end
	if itemname == 'bgmvolume' then return config.VolumeBgm .. '%' end
	if itemname == 'sfxvolume' then return config.VolumeSfx .. '%' end
	if itemname == 'audioducking' then return options.f_boolDisplay(config.AudioDucking, motif.option_info.menu_valuename_enabled, motif.option_info.menu_valuename_disabled) end
	if itemname == 'lifemul' then return config.LifeMul .. '%' end
	if itemname == 'gamespeed' then return config.GameSpeed .. '%' end
	if itemname == 'autoguard' then return options.f_boolDisplay(config.AutoGuard) end
	if itemname == 'guardbar' then return options.f_boolDisplay(config.BarGuard) end
	if itemname == 'stunbar' then return options.f_boolDisplay(config.BarStun) end
	if itemname == 'redlifebar' then return options.f_boolDisplay(config.BarRedLife) end
	if itemname == 'singlevsteamlife' then return config.SingleVsTeamLife .. '%' end
	if itemname == 'teamlifeadjustment' then return options.f_boolDisplay(config.TeamLifeAdjustment) end
	if itemname == 'teampowershare' then return options.f_boolDisplay(config.TeamPowerShare) end
	if itemname == 'losekosimul' then return options.f_boolDisplay(config.LoseSimul) end
	if itemname == 'losekotag' then return options.f_boolDisplay(config.LoseTag) end
	if itemname == 'turnsrecoverybase' then return config.TurnsRecoveryBase .. '%' end
	if itemname == 'turnsrecoverybonus' then return config.TurnsRecoveryBonus .. '%' end
	if itemname == 'ratio1life' then return options.f_displayRatio(config.RatioLife[1]) end
	if itemname == 'ratio1attack' then return options.f_displayRatio(config.RatioAttack[1]) end
	if itemname == 'ratio2life' then return options.f_displayRatio(config.RatioLife[2]) end
	if itemname == 'ratio2attack' then return options.f_displayRatio(config.RatioAttack[2]) end
	if itemname == 'ratio3life' then return options.f_displayRatio(config.RatioLife[3]) end
	if itemname == 'ratio3attack' then return options.f_displayRatio(config.RatioAttack[3]) end
	if itemname == 'ratio4life' then return options.f_displayRatio(config.RatioLife[4]) end
	if itemname == 'ratio4attack' then return options.f_displayRatio(config.RatioAttack[4]) end
	if itemname == 'minturns' then return config.NumTurns[1] end
	if itemname == 'maxturns' then return config.NumTurns[2] end
	if itemname == 'minsimul' then return config.NumSimul[1] end
	if itemname == 'maxsimul' then return config.NumSimul[2] end
	if itemname == 'mintag' then return config.NumTag[1] end
	if itemname == 'maxtag' then return config.NumTag[2] end
	if itemname == 'debugkeys' then return options.f_boolDisplay(config.DebugKeys, motif.option_info.menu_valuename_enabled, motif.option_info.menu_valuename_disabled) end
	if itemname == 'helpermax' then return config.MaxHelper end
	if itemname == 'projectilemax' then return config.MaxPlayerProjectile end
	if itemname == 'explodmax' then return config.MaxExplod end
	if itemname == 'afterimagemax' then return config.MaxAfterImage end
	if itemname == 'preloadingsmall' then return options.f_boolDisplay(config.PreloadingSmall) end
	if itemname == 'preloadingbig' then return options.f_boolDisplay(config.PreloadingBig) end
	if itemname == 'preloadingversus' then return options.f_boolDisplay(config.PreloadingVersus) end
	if itemname == 'preloadingstage' then return options.f_boolDisplay(config.PreloadingStage) end
	return ''
end

local t_menuWindow = {0, 0, main.SP_Localcoord[1], main.SP_Localcoord[2]}
if motif.option_info.menu_window_margins_y[1] ~= 0 or motif.option_info.menu_window_margins_y[2] ~= 0 then
	t_menuWindow = {
		0,
		math.max(0, motif.option_info.menu_pos[2] - motif.option_info.menu_window_margins_y[1]),
		motif.info.localcoord[1],
		motif.option_info.menu_pos[2] + (motif.option_info.menu_window_visibleitems - 1) * motif.option_info.menu_item_spacing[2] + motif.option_info.menu_window_margins_y[2]
	}
end

t_menuWindow = {
	t_menuWindow[1],
	t_menuWindow[2] * (GameHeight/main.SP_Localcoord[2]),
	t_menuWindow[3] * (GameWidth/main.SP_Localcoord[1]),
	t_menuWindow[4] * (GameHeight/main.SP_Localcoord[2])
}

--dynamically generates all option screen menus and submenus using itemname data stored in main.t_sort table
options.menu = {title = main.f_itemnameUpper(motif.option_info.title_text, motif.option_info.menu_title_uppercase == 1), submenu = {}, items = {}}
options.menu.loop = options.createMenu(options.menu, true, true, true)
local t_pos = {} --for storing current options.menu table position
local lastNum = 0
for i = 1, #main.t_sort.option_info do
	for j, c in ipairs(main.f_strsplit('_', main.t_sort.option_info[i])) do --split using "_" delimiter
		--populate shaders submenu
		if main.t_sort.option_info[i]:match('_shaders_back$') and c == 'back' then
			for k = #options.t_shaders, 1, -1 do
				table.insert(t_pos.items, 1, {data = text:create({}), window = t_menuWindow, itemname = options.t_shaders[k].path .. options.t_shaders[k].filename, displayname = options.t_shaders[k].filename, vardata = text:create({}), vardisplay = options.f_vardisplay(c), selected = false})
			end
		end
		--appending the menu table
		if j == 1 then --first string after menu.itemname (either reserved one or custom submenu assignment)
			if options.menu.submenu[c] == nil or c == 'empty' then
				options.menu.submenu[c] = {title = main.f_itemnameUpper(motif.option_info['menu_itemname_' .. main.t_sort.option_info[i]], motif.option_info.menu_title_uppercase == 1), submenu = {}, items = {}}
				options.menu.submenu[c].loop = options.createMenu(options.menu.submenu[c], false, false, false)
				if not main.t_sort.option_info[i]:match(c .. '_') then
					table.insert(options.menu.items, {data = text:create({}), window = t_menuWindow, itemname = c, displayname = motif.option_info['menu_itemname_' .. main.t_sort.option_info[i]], vardata = text:create({}), vardisplay = options.f_vardisplay(c), selected = false})
				end
			end
			t_pos = options.menu.submenu[c]
		else --following strings
			if t_pos.submenu[c] == nil or c == 'empty' then
				t_pos.submenu[c] = {title = main.f_itemnameUpper(motif.option_info['menu_itemname_' .. main.t_sort.option_info[i]], motif.option_info.menu_title_uppercase == 1), submenu = {}, items = {}}
				t_pos.submenu[c].loop = options.createMenu(t_pos.submenu[c], false, false, false)
				table.insert(t_pos.items, {data = text:create({}), window = t_menuWindow, itemname = c, displayname = motif.option_info['menu_itemname_' .. main.t_sort.option_info[i]], vardata = text:create({}), vardisplay = options.f_vardisplay(c), selected = false})
			end
			if j > lastNum then
				t_pos = t_pos.submenu[c]
			end
		end
		lastNum = j
	end
end
if main.debugLog then main.f_printTable(options.menu, 'debug/t_optionsMenu.txt') end

--;===========================================================
--; KEY SETTINGS
--;===========================================================
local function f_keyCfgText()
	return {text:create({}), text:create({})}
end
local t_keyCfg = {
	{data = f_keyCfgText(), itemname = 'empty', displayname = ''},
	{data = f_keyCfgText(), itemname = 'configall', displayname = motif.option_info.menu_itemname_key_all, infodata = f_keyCfgText(), infodisplay = ''},
	{data = f_keyCfgText(), itemname = 'up', displayname = motif.option_info.menu_itemname_key_up, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'down', displayname = motif.option_info.menu_itemname_key_down, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'left', displayname = motif.option_info.menu_itemname_key_left, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'right', displayname = motif.option_info.menu_itemname_key_right, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'a', displayname = motif.option_info.menu_itemname_key_a, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'b', displayname = motif.option_info.menu_itemname_key_b, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'c', displayname = motif.option_info.menu_itemname_key_c, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'x', displayname = motif.option_info.menu_itemname_key_x, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'y', displayname = motif.option_info.menu_itemname_key_y, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'z', displayname = motif.option_info.menu_itemname_key_z, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'start', displayname = motif.option_info.menu_itemname_key_start, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'd', displayname = motif.option_info.menu_itemname_key_d, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'w', displayname = motif.option_info.menu_itemname_key_w, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'menu', displayname = motif.option_info.menu_itemname_key_menu, vardata = f_keyCfgText()},
	{data = f_keyCfgText(), itemname = 'back', displayname = motif.option_info.menu_itemname_key_back, infodata = f_keyCfgText(), infodisplay = ''},
}
--t_keyCfg = main.f_tableClean(t_keyCfg, main.t_sort.option_info)

local txt_keyController = f_keyCfgText()
local cursorPosY = 2
local item = 2
local item_start = 2
local t_pos = {}
local configall = false
local key = ''
local t_keyList = {}
local t_conflict = {}
local t_savedConfig = {}
local btnReleased = false
local player = 1
local btn = ''
local joyNum = 0

function options.f_keyCfgReset(cfgType)
	t_keyList = {}
	for i = 1, #config[cfgType] do
		joyNum = config[cfgType][i].Joystick
		if t_keyList[joyNum] == nil then
			t_keyList[joyNum] = {} --creates subtable for each controller (1 for keyboard or at least 2 for gamepads)
			t_conflict[joyNum] = false --set default conflict flag for each controller
		end
		for k, v in pairs(config[cfgType][i].Buttons) do
			v = tostring(v)
			t_keyCfg[k + item_start]['vardisplay' .. i] = v --assign vardisplay entry (assigned button name) in t_keyCfg table
			if v ~= tostring(motif.option_info.menu_valuename_nokey) then --if button is not disabled
				if t_keyList[joyNum][v] == nil then
					t_keyList[joyNum][v] = 1
				else
					t_keyList[joyNum][v] = t_keyList[joyNum][v] + 1
				end
			end
		end
	end
end

function options.f_keyCfgInit(cfgType, title)
	resetKey()
	main.f_cmdInput()
	cursorPosY = 2
	item = 2
	item_start = 2
	t_pos = {motif.option_info.menu_key_p1_pos, motif.option_info.menu_key_p2_pos}
	configall = false
	key = ''
	t_conflict = {}
	t_savedConfig = main.f_tableCopy(config[cfgType])
	btnReleased = false
	player = 1
	btn = tostring(config[cfgType][player].Buttons[item - item_start])
	options.txt_title:update({text = title})
	options.f_keyCfgReset(cfgType)
	joyNum = config[cfgType][player].Joystick
end

function options.f_keyCfg(cfgType, controller, bgdef, skipClear)
	local t = t_keyCfg
	--Config all
	if configall then
		--esc (reset mapping)
		if esc() --[[or main.f_input(main.t_players, {'m'})]] then
			sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
			esc(false)
			config[cfgType][player] = main.f_tableCopy(t_savedConfig[player])
			for pn = 1, #config[cfgType] do
				setKeyConfig(pn, config[cfgType][pn].Joystick, config[cfgType][pn].Buttons)
			end
			options.f_keyCfgReset(cfgType)
			item = item_start
			cursorPosY = item_start
			configall = false
			commandBufReset(main.t_cmd[1])
			commandBufReset(main.t_cmd[2])
		--spacebar (disable key)
		elseif getKey() == 'SPACE' then
			key = 'SPACE'
		--keyboard key detection
		elseif cfgType == 'KeyConfig' then
			key = getKey()
		--gamepad key detection
		else
			local tmp = getJoystickKey(joyNum)
			if tonumber(tmp) == nil then
				btnReleased = true
			elseif btnReleased then
				key = tmp
				btnReleased = false
			end
			key = tostring(key)
		end
		--other keyboard or gamepad key
		if key ~= '' then
			if key == 'SPACE' then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
				--decrease old button count
				if t_keyList[joyNum][btn] ~= nil and t_keyList[joyNum][btn] > 1 then
					t_keyList[joyNum][btn] = t_keyList[joyNum][btn] - 1
				else
					t_keyList[joyNum][btn] = nil
				end
				--update vardisplay / config data
				t[item]['vardisplay' .. player] = motif.option_info.menu_valuename_nokey
				config[cfgType][player].Buttons[item - item_start] = tostring(motif.option_info.menu_valuename_nokey)
				modified = true
			elseif cfgType == 'KeyConfig' or (cfgType == 'JoystickConfig' and tonumber(key) ~= nil) then
				sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
				--decrease old button count
				if t_keyList[joyNum][btn] ~= nil and t_keyList[joyNum][btn] > 1 then
					t_keyList[joyNum][btn] = t_keyList[joyNum][btn] - 1
				else
					t_keyList[joyNum][btn] = nil
				end
				--remove previous button assignment if already set
				for k, v in ipairs(t) do
					if v['vardisplay' .. player] == key then
						v['vardisplay' .. player] = 'Not used'
						config[cfgType][player].Buttons[k - item_start] = 'Not used'
						if t_keyList[joyNum][key] ~= nil and t_keyList[joyNum][key] > 1 then
							t_keyList[joyNum][key] = t_keyList[joyNum][key] - 1
						else
							t_keyList[joyNum][key] = nil
						end
					end
				end
				--increase new button count
				if t_keyList[joyNum][key] == nil then
					t_keyList[joyNum][key] = 1
				else
					t_keyList[joyNum][key] = t_keyList[joyNum][key] + 1
				end
				--update vardisplay / config data
				t[item]['vardisplay' .. player] = key
				config[cfgType][player].Buttons[item - item_start] = key
				modified = true
			end
			--move to the next position
			item = item + 1
			cursorPosY = cursorPosY + 1
			if item > #t or t[item].itemname == 'back' then
				item = item_start
				cursorPosY = item_start
				configall = false
				commandBufReset(main.t_cmd[1])
				commandBufReset(main.t_cmd[2])
				for pn = 1, #config[cfgType] do
					setKeyConfig(pn, config[cfgType][pn].Joystick, config[cfgType][pn].Buttons)
				end
			end
			key = ''
		end
		resetKey()
	--move left / right
	elseif main.f_input(main.t_players, {'$F', '$B'}) then
		sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
		if player == 1 then
			player = 2
		else
			player = 1
		end
		joyNum = config[cfgType][player].Joystick
	--move up / down
	elseif main.f_input(main.t_players, {'$U', '$D'}) then
		sndPlay(motif.files.snd_data, motif.option_info.cursor_move_snd[1], motif.option_info.cursor_move_snd[2])
		if cursorPosY == item_start then
			cursorPosY = #t
			item = #t
		else
			cursorPosY = item_start
			item = item_start
		end
	end
	btn = tostring(config[cfgType][player].Buttons[item - item_start])
	if configall == false then
		if esc() or main.f_input(main.t_players, {'m'}) or (t[item].itemname == 'back' and main.f_input(main.t_players, {'pal', 's'})) then
			if t_conflict[joyNum] then
				if not main.f_warning(main.f_extractText(motif.warning_info.text_keys_text), motif.option_info, motif.optionbgdef) then
					options.txt_title:update({text = motif.option_info.title_input_text})
					config[cfgType] = main.f_tableCopy(t_savedConfig)
					for pn = 1, #config[cfgType] do
						setKeyConfig(pn, config[cfgType][pn].Joystick, config[cfgType][pn].Buttons)
					end
					menu.itemname = ''
					return false
				end
			else
				sndPlay(motif.files.snd_data, motif.option_info.cancel_snd[1], motif.option_info.cancel_snd[2])
				options.txt_title:update({text = motif.option_info.title_input_text})
				for pn = 1, #config[cfgType] do
					setKeyConfig(pn, config[cfgType][pn].Joystick, config[cfgType][pn].Buttons)
				end
				menu.itemname = ''
				return false
			end
		--Config all
		elseif (t[item].itemname == 'configall' and main.f_input(main.t_players, {'pal', 's'})) or getKey() == 'F1' or getKey() == 'F2' then
			sndPlay(motif.files.snd_data, motif.option_info.cursor_done_snd[1], motif.option_info.cursor_done_snd[2])
			if getKey() == 'F1' then
				player = 1
			elseif getKey() == 'F2' then
				player = 2
			end
			if cfgType == 'JoystickConfig' and getJoystickPresent(joyNum) == false then
				main.f_warning(main.f_extractText(motif.warning_info.text_pad_text), motif.option_info, motif.optionbgdef)
				item = item_start
				cursorPosY = item_start
			else
				item = item_start + 1
				cursorPosY = item_start + 1
				btnReleased = false
				configall = true
			end
			resetKey()
		end
	end
	t_conflict[joyNum] = false
	--draw clearcolor
	if not skipClear then
		clearColor(motif[bgdef].bgclearcolor[1], motif[bgdef].bgclearcolor[2], motif[bgdef].bgclearcolor[3])
	end
	--draw layerno = 0 backgrounds
	bgDraw(motif[bgdef].bg, false)
	local window = text:get_default_window(motif.defaultOptions)
	--draw player num
	for i = 1, 2 do
		txt_keyController[i]:update({
			font =   motif.option_info['menu_item_key_p' .. i .. '_font'][1],
			bank =   motif.option_info['menu_item_key_p' .. i .. '_font'][2],
			align =  motif.option_info['menu_item_key_p' .. i .. '_font'][3],
			text =   motif.option_info.menu_itemname_key_playerno .. ' ' .. i,
			x =      motif.option_info['menu_item_p' .. i .. '_pos'][1],
			y =      motif.option_info['menu_item_p' .. i .. '_pos'][2],
			scaleX = motif.option_info['menu_item_key_p' .. i .. '_font_scale'][1],
			scaleY = motif.option_info['menu_item_key_p' .. i .. '_font_scale'][2],
			r =      motif.option_info['menu_item_key_p' .. i .. '_font'][4],
			g =      motif.option_info['menu_item_key_p' .. i .. '_font'][5],
			b =      motif.option_info['menu_item_key_p' .. i .. '_font'][6],
			src =    motif.option_info['menu_item_key_p' .. i .. '_font'][7],
			dst =    motif.option_info['menu_item_key_p' .. i .. '_font'][8],
			height = motif.option_info['menu_item_key_p' .. i .. '_font_height'],
			window = window,
			defsc =  motif.defaultOptions
		})
		txt_keyController[i]:draw()
	end
	--draw menu box
	if motif.option_info.menu_boxbg_visible == 1 then
		for i = 1, 2 do
			fillRect(
				t_pos[i][1] + motif.option_info.menu_key_boxcursor_coords[1],
				t_pos[i][2] + motif.option_info.menu_key_boxcursor_coords[2],
				motif.option_info.menu_key_boxcursor_coords[3] - motif.option_info.menu_key_boxcursor_coords[1] + 1,
				#t * (motif.option_info.menu_key_boxcursor_coords[4] - motif.option_info.menu_key_boxcursor_coords[2] + 1) + main.f_oddRounding(motif.option_info.menu_key_boxcursor_coords[2]),
				motif.option_info.menu_boxbg_col[1],
				motif.option_info.menu_boxbg_col[2],
				motif.option_info.menu_boxbg_col[3],
				motif.option_info.menu_boxbg_alpha[1],
				motif.option_info.menu_boxbg_alpha[2],
				motif.defaultOptions,
				false
			)
		end
	end
	--draw title
	options.txt_title:draw()
	--draw menu items
	for i = 1, #t do
		for j = 1, 2 do
			if i > item - cursorPosY then
				if j == 1 then --player1 side (left)
					if t[i].itemname == 'configall' then
						t[i].infodisplay = motif.option_info.menu_valuename_f1
					elseif t[i].itemname == 'back' then
						t[i].infodisplay = motif.option_info.menu_valuename_esc
					end
				else --player2 side (right)
					if t[i].itemname == 'configall' then
						t[i].infodisplay = motif.option_info.menu_valuename_f2
					elseif t[i].itemname == 'back' then
						t[i].infodisplay = motif.option_info.menu_valuename_esc --menu_valuename_next
					end
				end
				if i == item and j == player then --active item
					--draw displayname
					t[i].data[j]:update({
						font =   motif.option_info.menu_item_active_font[1],
						bank =   motif.option_info.menu_item_active_font[2],
						align =  motif.option_info.menu_item_active_font[3],
						text =   t[i].displayname,
						x =      t_pos[j][1],
						y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
						scaleX = motif.option_info.menu_item_active_font_scale[1],
						scaleY = motif.option_info.menu_item_active_font_scale[2],
						r =      motif.option_info.menu_item_active_font[4],
						g =      motif.option_info.menu_item_active_font[5],
						b =      motif.option_info.menu_item_active_font[6],
						src =    motif.option_info.menu_item_active_font[7],
						dst =    motif.option_info.menu_item_active_font[8],
						height = motif.option_info.menu_item_active_font_height,
						window = window,
						defsc =  motif.defaultOptions
					})
					t[i].data[j]:draw()
					--draw vardata
					if t[i].vardata ~= nil then
						if t_keyList[joyNum][tostring(t[i]['vardisplay' .. j])] ~= nil and t_keyList[joyNum][tostring(t[i]['vardisplay' .. j])] > 1 then
							t[i].vardata[j]:update({
								font =   motif.option_info.menu_item_value_conflict_font[1],
								bank =   motif.option_info.menu_item_value_conflict_font[2],
								align =  motif.option_info.menu_item_value_conflict_font[3],
								text =   t[i]['vardisplay' .. j],
								x =      t_pos[j][1] + motif.option_info.menu_key_item_spacing[1],
								y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
								scaleX = motif.option_info.menu_item_value_conflict_font_scale[1],
								scaleY = motif.option_info.menu_item_value_conflict_font_scale[2],
								r =      motif.option_info.menu_item_value_conflict_font[4],
								g =      motif.option_info.menu_item_value_conflict_font[5],
								b =      motif.option_info.menu_item_value_conflict_font[6],
								src =    motif.option_info.menu_item_value_conflict_font[7],
								dst =    motif.option_info.menu_item_value_conflict_font[8],
								height = motif.option_info.menu_item_value_conflict_font_height,
								window = window,
								defsc =  motif.defaultOptions
							})
							t[i].vardata[j]:draw()
							t_conflict[joyNum] = true
						else
							t[i].vardata[j]:update({
								font =   motif.option_info.menu_item_value_active_font[1],
								bank =   motif.option_info.menu_item_value_active_font[2],
								align =  motif.option_info.menu_item_value_active_font[3],
								text =   t[i]['vardisplay' .. j],
								x =      t_pos[j][1] + motif.option_info.menu_key_item_spacing[1],
								y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
								scaleX = motif.option_info.menu_item_value_active_font_scale[1],
								scaleY = motif.option_info.menu_item_value_active_font_scale[2],
								r =      motif.option_info.menu_item_value_active_font[4],
								g =      motif.option_info.menu_item_value_active_font[5],
								b =      motif.option_info.menu_item_value_active_font[6],
								src =    motif.option_info.menu_item_value_active_font[7],
								dst =    motif.option_info.menu_item_value_active_font[8],
								height = motif.option_info.menu_item_value_active_font_height,
								window = window,
								defsc =  motif.defaultOptions
							})
							t[i].vardata[j]:draw()
						end
					--draw infodata
					elseif t[i].infodata ~= nil then
						t[i].infodata[j]:update({
							font =   motif.option_info.menu_item_info_active_font[1],
							bank =   motif.option_info.menu_item_info_active_font[2],
							align =  motif.option_info.menu_item_info_active_font[3],
							text =   t[i].infodisplay,
							x =      t_pos[j][1] + motif.option_info.menu_key_item_spacing[1],
							y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
							scaleX = motif.option_info.menu_item_value_active_font_scale[1],
							scaleY = motif.option_info.menu_item_value_active_font_scale[2],
							r =      motif.option_info.menu_item_info_active_font[4],
							g =      motif.option_info.menu_item_info_active_font[5],
							b =      motif.option_info.menu_item_info_active_font[6],
							src =    motif.option_info.menu_item_info_active_font[7],
							dst =    motif.option_info.menu_item_info_active_font[8],
							height = motif.option_info.menu_item_info_active_font_height,
							window = window,
							defsc =  motif.defaultOptions
						})
						t[i].infodata[j]:draw()
					end
				else --inactive item
					--draw displayname
					t[i].data[j]:update({
						font =   motif.option_info.menu_item_font[1],
						bank =   motif.option_info.menu_item_font[2],
						align =  motif.option_info.menu_item_font[3],
						text =   t[i].displayname,
						x =      t_pos[j][1],
						y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
						scaleX = motif.option_info.menu_item_font_scale[1],
						scaleY = motif.option_info.menu_item_font_scale[2],
						r =      motif.option_info.menu_item_font[4],
						g =      motif.option_info.menu_item_font[5],
						b =      motif.option_info.menu_item_font[6],
						src =    motif.option_info.menu_item_font[7],
						dst =    motif.option_info.menu_item_font[8],
						height = motif.option_info.menu_item_font_height,
						window = window,
						defsc =  motif.defaultOptions
					})
					t[i].data[j]:draw()
					--draw vardata
					if t[i].vardata ~= nil then
						if t_keyList[joyNum][tostring(t[i]['vardisplay' .. j])] ~= nil and t_keyList[joyNum][tostring(t[i]['vardisplay' .. j])] > 1 then
							t[i].vardata[j]:update({
								font =   motif.option_info.menu_item_value_conflict_font[1],
								bank =   motif.option_info.menu_item_value_conflict_font[2],
								align =  motif.option_info.menu_item_value_conflict_font[3],
								text =   t[i]['vardisplay' .. j],
								x =      t_pos[j][1] + motif.option_info.menu_key_item_spacing[1],
								y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
								scaleX = motif.option_info.menu_item_value_conflict_font_scale[1],
								scaleY = motif.option_info.menu_item_value_conflict_font_scale[2],
								r =      motif.option_info.menu_item_value_conflict_font[4],
								g =      motif.option_info.menu_item_value_conflict_font[5],
								b =      motif.option_info.menu_item_value_conflict_font[6],
								src =    motif.option_info.menu_item_value_conflict_font[7],
								dst =    motif.option_info.menu_item_value_conflict_font[8],
								height = motif.option_info.menu_item_value_conflict_font_height,
								window = window,
								defsc =  motif.defaultOptions
							})
							t[i].vardata[j]:draw()
							t_conflict[joyNum] = true
						else
							t[i].vardata[j]:update({
								font =   motif.option_info.menu_item_value_font[1],
								bank =   motif.option_info.menu_item_value_font[2],
								align =  motif.option_info.menu_item_value_font[3],
								text =   t[i]['vardisplay' .. j],
								x =      t_pos[j][1] + motif.option_info.menu_key_item_spacing[1],
								y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
								scaleX = motif.option_info.menu_item_value_font_scale[1],
								scaleY = motif.option_info.menu_item_value_font_scale[2],
								r =      motif.option_info.menu_item_value_font[4],
								g =      motif.option_info.menu_item_value_font[5],
								b =      motif.option_info.menu_item_value_font[6],
								src =    motif.option_info.menu_item_value_font[7],
								dst =    motif.option_info.menu_item_value_font[8],
								height = motif.option_info.menu_item_value_font_height,
								window = window,
								defsc =  motif.defaultOptions
							})
							t[i].vardata[j]:draw()
						end
					--draw infodata
					elseif t[i].infodata ~= nil then
						t[i].infodata[j]:update({
							font =   motif.option_info.menu_item_info_font[1],
							bank =   motif.option_info.menu_item_info_font[2],
							align =  motif.option_info.menu_item_info_font[3],
							text =   t[i].infodisplay,
							x =      t_pos[j][1] + motif.option_info.menu_key_item_spacing[1],
							y =      t_pos[j][2] + (i - 1) * motif.option_info.menu_key_item_spacing[2],
							scaleX = motif.option_info.menu_item_value_active_font_scale[1],
							scaleY = motif.option_info.menu_item_value_active_font_scale[2],
							r =      motif.option_info.menu_item_info_font[4],
							g =      motif.option_info.menu_item_info_font[5],
							b =      motif.option_info.menu_item_info_font[6],
							src =    motif.option_info.menu_item_info_font[7],
							dst =    motif.option_info.menu_item_info_font[8],
							height = motif.option_info.menu_item_info_font_height,
							window = window,
							defsc =  motif.defaultOptions
						})
						t[i].infodata[j]:draw()
					end
				end
			end
		end
	end
	--draw menu cursor
	if motif.option_info.menu_boxcursor_visible == 1 then
		local src, dst = main.f_boxcursorAlpha(
			motif.option_info.menu_boxcursor_alpharange[1],
			motif.option_info.menu_boxcursor_alpharange[2],
			motif.option_info.menu_boxcursor_alpharange[3],
			motif.option_info.menu_boxcursor_alpharange[4],
			motif.option_info.menu_boxcursor_alpharange[5],
			motif.option_info.menu_boxcursor_alpharange[6]
		)
		for i = 1, 2 do
			if i == player then
				fillRect(
					t_pos[i][1] + motif.option_info.menu_key_boxcursor_coords[1],
					t_pos[i][2] + motif.option_info.menu_key_boxcursor_coords[2] + (cursorPosY - 1) * motif.option_info.menu_key_item_spacing[2],
					motif.option_info.menu_key_boxcursor_coords[3] - motif.option_info.menu_key_boxcursor_coords[1] + 1,
					motif.option_info.menu_key_boxcursor_coords[4] - motif.option_info.menu_key_boxcursor_coords[2] + 1 + main.f_oddRounding(motif.option_info.menu_key_boxcursor_coords[2]),
					motif.option_info.menu_boxcursor_col[1],
					motif.option_info.menu_boxcursor_col[2],
					motif.option_info.menu_boxcursor_col[3],
					src,
					dst,
					motif.defaultOptions,
					false
				)
			end
		end
	end
	--draw layerno = 1 backgrounds
	bgDraw(motif[bgdef].bg, true)
	main.f_cmdInput()
	if not skipClear then
		refresh()
	end
	return true
end

return options
