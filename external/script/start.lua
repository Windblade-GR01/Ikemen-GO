local start = {}

--default team count after starting the game
local p1NumTurns = math.max(2, config.NumTurns[1])
local p1NumSimul = math.max(2, config.NumSimul[1])
local p1NumTag = math.max(2, config.NumTag[1])
local p1NumRatio = 1
local p2NumTurns = math.max(2, config.NumTurns[1])
local p2NumSimul = math.max(2, config.NumSimul[1])
local p2NumTag = math.max(2, config.NumTag[1])
local p2NumRatio = 1
--default team mode after starting the game
local p1TeamMenu = 1
local p2TeamMenu = 1
--let cursor wrap around
local wrappingX = (motif.select_info.wrapping == 1 and motif.select_info.wrapping_x == 1)
local wrappingY = (motif.select_info.wrapping == 1 and motif.select_info.wrapping_y == 1)
--initialize other local variables
local t_victoryBGM = {}
local t_roster = {}
local t_aiRamp = {}
local t_p1Cursor = {}
local t_p2Cursor = {}
local p1RestoreCursor = false
local p2RestoreCursor = false
local p1Cell = false
local p2Cell = false
local p1TeamEnd = false
local p1SelEnd = false
local p1Ratio = false
local p2TeamEnd = false
local p2SelEnd = false
local p2Ratio = false
local selScreenEnd = false
local stageEnd = false
local coopEnd = false
local restoreTeam = false
local resetgrid = false
local continueData = false
local continueFlag = false
local p1NumChars = 0
local p2NumChars = 0
local matchNo = 0
local stageNo = 0
local p1SelX = 0
local p1SelY = 0
local p2SelX = 0
local p2SelY = 0
local p1FaceOffset = 0
local p2FaceOffset = 0
local p1RowOffset = 0
local p2RowOffset = 0
local winner = 0
local t_gameStats = {}
local t_recordText = {}
local winCnt = 0
local loseCnt = 0
local p1FaceX = 0
local p1FaceY = 0
local p2FaceX = 0
local p2FaceY = 0
local lastMatch = 0
local stageList = 0
local timerSelect = 0
local t_savedData = {
	win = {0, 0},
	lose = {0, 0},
	time = {total = 0, matches = {}},
	score = {total = {0, 0}, matches = {}},
	consecutive = {0, 0},
}
local fadeType = 'fadein'
local challenger = false

--;===========================================================
--; COMMON FUNCTIONS
--;===========================================================

--converts '.maxmatches' style table (key = order, value = max matches) to the same structure as '.ratiomatches' (key = match number, value = subtable with char num and order data)
function start.f_unifySettings(t, t_chars)
	local ret = {}
	for i = 1, #t do --for each order number
		if t_chars[i] ~= nil then --only if there are any characters available with this order
			local infinite = false
			local num = t[i]
			if num == -1 then --infinite matches
				num = #t_chars[i] --assign max amount of characters with this order
				infinite = true
			end
			for j = 1, num do --iterate up to max amount of matches versus characters with this order
				if j * p2NumChars > #t_chars[i] and #ret > 0 then --if there are not enough characters to fill all slots and at least 1 fight is already assigned
					local stop = true
					for k = (j - 1) * p2NumChars + 1, #t_chars[i] do --loop through characters left for this match
						if main.t_selChars[t_chars[i][k] + 1].single == 1 then --and allow appending if any of the remaining characters has 'single' flag set
							stop = false
						end
					end
					if stop then
						break
					end
				end
				table.insert(ret, {['rmin'] = p2NumChars, ['rmax'] = p2NumChars, ['order'] = i})
			end
			if infinite then
				table.insert(ret, {['rmin'] = p2NumChars, ['rmax'] = p2NumChars, ['order'] = -1})
				break --no point in appending additional matches
			end
		end
	end
	return ret
end

--generates roster table
function start.f_makeRoster(t_ret)
	t_ret = t_ret or {}
	--prepare correct settings tables
	local t = {}
	local t_static = {}
	local t_removable = {}
	--Arcade / Time Attack
	if gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop') or gamemode('timeattack') then
		t_static = main.t_orderChars
		if p2Ratio then --Ratio
			if main.t_selChars[start.t_p1Selected[1].ref + 1].ratiomatches ~= nil and main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].ratiomatches .. "_arcaderatiomatches"] ~= nil then --custom settings exists as char param
				t = main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].ratiomatches .. "_arcaderatiomatches"]
			else --default settings
				t = main.t_selOptions.arcaderatiomatches
			end
		elseif start.p2TeamMode == 0 then --Single
			if main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches ~= nil and main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches .. "_arcademaxmatches"] ~= nil then --custom settings exists as char param
				t = start.f_unifySettings(main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches .. "_arcademaxmatches"], t_static)
			else --default settings
				t = start.f_unifySettings(main.t_selOptions.arcademaxmatches, t_static)
			end
		else --Simul / Turns / Tag
			if main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches ~= nil and main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches .. "_teammaxmatches"] ~= nil then --custom settings exists as char param
				t = start.f_unifySettings(main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches .. "_teammaxmatches"], t_static)
			else --default settings
				t = start.f_unifySettings(main.t_selOptions.teammaxmatches, t_static)
			end
		end
	--Survival
	elseif gamemode('survival') or gamemode('survivalcoop') or gamemode('netplaysurvivalcoop') then
		t_static = main.t_orderSurvival
		if main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches ~= nil and main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches .. "_survivalmaxmatches"] ~= nil then --custom settings exists as char param
			t = start.f_unifySettings(main.t_selOptions[main.t_selChars[start.t_p1Selected[1].ref + 1].maxmatches .. "_survivalmaxmatches"], t_static)
		else --default settings
			t = start.f_unifySettings(main.t_selOptions.survivalmaxmatches, t_static)
		end
	--Boss Rush
	elseif gamemode('bossrush') then
		t_static = {main.t_bossChars}
		for i = 1, math.ceil(#main.t_bossChars / p2NumChars) do --generate ratiomatches style table
			table.insert(t, {['rmin'] = p2NumChars, ['rmax'] = p2NumChars, ['order'] = 1})
		end
	--VS 100 Kumite
	elseif gamemode('vs100kumite') then
		t_static = {main.t_randomChars}
		for i = 1, 100 do --generate ratiomatches style table for 100 matches
			table.insert(t, {['rmin'] = p2NumChars, ['rmax'] = p2NumChars, ['order'] = 1})
		end
	else
		panicError('LUA ERROR: ' .. gamemode() .. ' game mode unrecognized by start.f_makeRoster()')
	end
	--generate roster
	t_removable = main.f_tableCopy(t_static) --copy into editable order table
	for i = 1, #t do --for each match number
		if t[i].order == -1 then --infinite matches for this order detected
			table.insert(t_ret, {-1}) --append infinite matches flag at the end
			break
		end
		if t_removable[t[i].order] ~= nil then
			if #t_removable[t[i].order] == 0 and gamemode('vs100kumite') then
				t_removable = main.f_tableCopy(t_static) --ensure that there will be at least 100 matches in VS 100 Kumite mode
			end
			if #t_removable[t[i].order] >= 1 then --there is at least 1 character with this order available
				local remaining = t[i].rmin - #t_removable[t[i].order]
				table.insert(t_ret, {}) --append roster table with new subtable
				for j = 1, math.random(math.min(t[i].rmin, #t_removable[t[i].order]), math.min(t[i].rmax, #t_removable[t[i].order])) do --for randomized characters count
					local rand = math.random(1, #t_removable[t[i].order]) --randomize which character will be taken
					table.insert(t_ret[#t_ret], t_removable[t[i].order][rand]) --add such character into roster subtable
					table.remove(t_removable[t[i].order], rand) --and remove it from the available character pool
				end
				--fill the remaining slots randomly if there are not enough players available with this order
				while remaining > 0 do
					table.insert(t_ret[#t_ret], t_static[t[i].order][math.random(1, #t_static[t[i].order])])
					remaining = remaining - 1
				end
			end
		end
	end
	if main.debugLog then main.f_printTable(t_ret, 'debug/t_roster.txt') end
	return t_ret
end

--generates AI ramping table
function start.f_aiRamp(currentMatch)
	local start_match = 0
	local start_diff = 0
	local end_match = 0
	local end_diff = 0
	if currentMatch == 1 then
		t_aiRamp = {}
	end
	--Arcade
	if gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop') or gamemode('timeattack') then
		if start.p2TeamMode == 0 then --Single
			start_match = main.t_selOptions.arcadestart.wins
			start_diff = main.t_selOptions.arcadestart.offset
			end_match =  main.t_selOptions.arcadeend.wins
			end_diff = main.t_selOptions.arcadeend.offset
		elseif p2Ratio then --Ratio
			start_match = main.t_selOptions.ratiostart.wins
			start_diff = main.t_selOptions.ratiostart.offset
			end_match =  main.t_selOptions.ratioend.wins
			end_diff = main.t_selOptions.ratioend.offset
		else --Simul / Turns / Tag
			start_match = main.t_selOptions.teamstart.wins
			start_diff = main.t_selOptions.teamstart.offset
			end_match =  main.t_selOptions.teamend.wins
			end_diff = main.t_selOptions.teamend.offset
		end
	elseif gamemode('survival') or gamemode('survivalcoop') or gamemode('netplaysurvivalcoop') then
		start_match = main.t_selOptions.survivalstart.wins
		start_diff = main.t_selOptions.survivalstart.offset
		end_match =  main.t_selOptions.survivalend.wins
		end_diff = main.t_selOptions.survivalend.offset
	end
	local startAI = config.Difficulty + start_diff
	if startAI > 8 then
		startAI = 8
	elseif startAI < 1 then
		startAI = 1
	end
	local endAI = config.Difficulty + end_diff
	if endAI > 8 then
		endAI = 8
	elseif endAI < 1 then
		endAI = 1
	end
	for i = currentMatch, lastMatch do
		if i - 1 <= start_match then
			table.insert(t_aiRamp, startAI)
		elseif i - 1 <= end_match then
			local curMatch = i - (start_match + 1)
			table.insert(t_aiRamp, math.floor(curMatch * (endAI - startAI) / (end_match - start_match) + startAI))
		else
			table.insert(t_aiRamp, endAI)
		end
	end
	if main.debugLog then main.f_printTable(t_aiRamp, 'debug/t_aiRamp.txt') end
end

--returns bool depending of rivals match validity
function start.f_rivalsMatch(param, value)
	if main.t_selChars[start.t_p1Selected[1].ref + 1].rivals ~= nil and main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo] ~= nil then
		if param == nil then --check only if rivals assignment for this match exists at all
			return true
		elseif main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][param] ~= nil then
			if value == nil then --check only if param is assigned for this rival
				return true
			else --check if param equals value
				return main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][param] == value
			end
		end
	end
	return false
end

--calculates AI level
function start.f_difficulty(player, offset)
	local t = {}
	if player % 2 ~= 0 then --odd value (Player1 side)
		local pos = math.floor(player / 2 + 0.5)
		t = main.t_selChars[start.t_p1Selected[pos].ref + 1]
	else --even value (Player2 side)
		local pos = math.floor(player / 2)
		if pos == 1 and start.f_rivalsMatch('ai') then --player2 team leader and arcade mode and ai rivals param exists
			t = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo]
		else
			t = main.t_selChars[start.t_p2Selected[pos].ref + 1]
		end
	end
	if t.ai ~= nil then
		return t.ai
	else
		return config.Difficulty + offset
	end
end

--assigns AI level
function start.f_remapAI()
	--Offset
	local offset = 0
	if config.AIRamping and (gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop') or gamemode('survival') or gamemode('survivalcoop') or gamemode('netplaysurvivalcoop')) then
		offset = t_aiRamp[matchNo] - config.Difficulty
	end
	--Player 1
	if main.coop then
		remapInput(3, 2) --P3 character uses P2 controls
		setCom(1, 0)
		setCom(3, 0)
	elseif start.p1TeamMode == 0 then --Single
		if main.t_pIn[1] == 1 and not main.aiFight then
			setCom(1, 0)
		else
			setCom(1, start.f_difficulty(1, offset))
		end
	elseif start.p1TeamMode == 1 then --Simul
		if main.t_pIn[1] == 1 and not main.aiFight then
			setCom(1, 0)
		else
			setCom(1, start.f_difficulty(1, offset))
		end
		for i = 3, p1NumChars * 2 do
			if i % 2 ~= 0 then --odd value
				remapInput(i, 1) --P3/5/7 character uses P1 controls
				setCom(i, start.f_difficulty(i, offset))
			end
		end
	elseif start.p1TeamMode == 2 then --Turns
		for i = 1, p1NumChars * 2 do
			if i % 2 ~= 0 then --odd value
				if main.t_pIn[1] == 1 and not main.aiFight then
					remapInput(i, 1) --P1/3/5/7 character uses P1 controls
					setCom(i, 0)
				else
					setCom(i, start.f_difficulty(i, offset))
				end
			end
		end
	else --Tag
		for i = 1, p1NumChars * 2 do
			if i % 2 ~= 0 then --odd value
				if main.t_pIn[1] == 1 and not main.aiFight then
					remapInput(i, 1) --P1/3/5/7 character uses P1 controls
					setCom(i, 0)
				else
					setCom(i, start.f_difficulty(i, offset))
				end
			end
		end
	end
	--Player 2
	if start.p2TeamMode == 0 then --Single
		if main.t_pIn[2] == 2 and not main.aiFight and not main.coop then
			setCom(2, 0)
		else
			setCom(2, start.f_difficulty(2, offset))
		end
	elseif start.p2TeamMode == 1 then --Simul
		if main.t_pIn[2] == 2 and not main.aiFight and not main.coop then
			setCom(2, 0)
		else
			setCom(2, start.f_difficulty(2, offset))
		end
		for i = 4, p2NumChars * 2 do
			if i % 2 == 0 then --even value
				remapInput(i, 2) --P4/6/8 character uses P2 controls
				setCom(i, start.f_difficulty(i, offset))
			end
		end
	elseif start.p2TeamMode == 2 then --Turns
		for i = 2, p2NumChars * 2 do
			if i % 2 == 0 then --even value
				if main.t_pIn[2] == 2 and not main.aiFight and not main.coop then
					remapInput(i, 2) --P2/4/6/8 character uses P2 controls
					setCom(i, 0)
				else
					setCom(i, start.f_difficulty(i, offset))
				end
			end
		end
	else --Tag
		for i = 2, p2NumChars * 2 do
			if i % 2 == 0 then --even value
				if main.t_pIn[2] == 2 and not main.aiFight and not main.coop then
					remapInput(i, 2) --P2/4/6/8 character uses P2 controls
					setCom(i, 0)
				else
					setCom(i, start.f_difficulty(i, offset))
				end
			end
		end
	end
end

--sets lifebar elements, round time, rounds to win
function start.f_setRounds()
	setLifebarElements(main.t_lifebar)
	--round time
	local frames = main.timeFramesPerCount
	local p1FramesMul = 1
	local p2FramesMul = 1
	if start.p1TeamMode == 3 then --Tag
		p1FramesMul = p1NumChars
	end
	if start.p2TeamMode == 3 then --Tag
		p2FramesMul = p2NumChars
	end
	frames = frames * math.max(p1FramesMul, p2FramesMul)
	setTimeFramesPerCount(frames)
	if main.t_charparam.time and main.t_charparam.rivals and start.f_rivalsMatch('time') then --round time assigned as rivals param
		setRoundTime(math.max(-1, main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo].time * frames))
	elseif main.t_charparam.time and main.t_selChars[start.t_p2Selected[1].ref + 1].time ~= nil then --round time assigned as character param
		setRoundTime(math.max(-1, main.t_selChars[start.t_p2Selected[1].ref + 1].time * frames))
	else --default round time
		setRoundTime(math.max(-1, main.roundTime * frames))
	end
	--rounds to win
	if main.t_charparam.rounds and main.t_charparam.rivals and start.f_rivalsMatch('rounds') then --round num assigned as rivals param
		setMatchWins(main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo].rounds)
	elseif main.t_charparam.rounds and main.t_selChars[start.t_p2Selected[1].ref + 1].rounds ~= nil then --round num assigned as character param
		setMatchWins(main.t_selChars[start.t_p2Selected[1].ref + 1].rounds)
	elseif start.p2TeamMode == 0 then --default rounds num (Single mode)
		setMatchWins(main.matchWins[1])
	else --default rounds num (Team mode)
		setMatchWins(main.matchWins[2])
	end
	setMatchMaxDrawGames(main.matchWins[3])
	--timer / score counter
	local timer = 0
	local t_score = {0, 0}
	if not challenger then
		t_score = {t_savedData.score.total[1], t_savedData.score.total[2]}
		timer = t_savedData.time.total
	end
	setLifebarTimer(timer)
	setLifebarScore(t_score[1], t_score[2])
end

--save data between matches
function start.f_saveData()
	if main.debugLog then main.f_printTable(t_gameStats, 'debug/t_gameStats.txt') end
	if winner == -1 then
		return
	end
	--win/lose matches count, total score
	if winner == 1 then
		t_savedData.win[1] = t_savedData.win[1] + 1
		t_savedData.lose[2] = t_savedData.lose[2] + 1
		t_savedData.score.total[1] = t_gameStats.p1score
	else --if winner == 2 then
		t_savedData.win[2] = t_savedData.win[2] + 1
		t_savedData.lose[1] = t_savedData.lose[1] + 1
		if main.resetScore then --loosing sets score for the next match to lose count
			t_savedData.score.total[1] = t_savedData.lose[1]
		else
			t_savedData.score.total[1] = t_gameStats.p1score
		end
	end
	t_savedData.score.total[2] = t_gameStats.p2score
	--total time
	t_savedData.time.total = t_savedData.time.total + t_gameStats.matchTime
	--time in each round
	table.insert(t_savedData.time.matches, t_gameStats.timerRounds)
	--score in each round
	table.insert(t_savedData.score.matches, t_gameStats.scoreRounds)
	--individual characters
	local t_cheat = {false, false}
	for round = 1, #t_gameStats.match do
		for c, v in ipairs(t_gameStats.match[round]) do
			--cheat flag
			if v.cheated then
				t_cheat[v.teamside + 1] = true
			end
		end
	end
	--max consecutive wins
	for i = 1, #t_cheat do
		if t_cheat[i] then
			setConsecutiveWins(i, 0)
		elseif getConsecutiveWins(i) > t_savedData.consecutive[i] then
			t_savedData.consecutive[i] = getConsecutiveWins(i)
		end
	end
	if main.debugLog then main.f_printTable(t_savedData, 'debug/t_savedData.txt') end
end

--return sorted and capped table
local function f_formattedTable(t, append, f, size)
	local t = t or {}
	local size = size or -1
	local t_tmp = {}
	local tmp = 0
	table.insert(t, append)
	for _, v in main.f_sortKeys(t, f) do
		tmp = tmp + 1
		table.insert(t_tmp, v)
		if tmp == size then
			break
		end
	end
	return t_tmp
end

local function f_listCharRefs(t)
	local ret = {}
	for i = 1, #t do
		table.insert(ret, main.t_selChars[t[i].ref + 1].char:lower())
	end
	return ret
end

local t_sortRanking = {}
t_sortRanking['arcade'] = function(t, a, b) return t[b].score < t[a].score end
t_sortRanking['teamcoop'] = t_sortRanking.arcade
t_sortRanking['netplayteamcoop'] = t_sortRanking.arcade
t_sortRanking['scorechallenge'] = t_sortRanking.arcade
t_sortRanking['timeattack'] = function(t, a, b) return t[b].time > t[a].time end
t_sortRanking['timechallenge'] = t_sortRanking.timeattack
t_sortRanking['survival'] = function(t, a, b) return t[b].win < t[a].win or (t[b].win == t[a].win and t[b].score < t[a].score) end
t_sortRanking['survivalcoop'] = t_sortRanking.survival
t_sortRanking['netplaysurvivalcoop'] = t_sortRanking.survival
t_sortRanking['bossrush'] = t_sortRanking.survival
t_sortRanking['vs100kumite'] = t_sortRanking.survival

--data saving to stats.json
function f_saveStats()
	local file = io.open(main.flags['-stats'], 'w+')
	file:write(json.encode(stats, {indent = true}))
	file:close()
end

--store saved data to stats.json
function start.f_storeSavedData(mode, cleared)
	if stats.modes == nil then
		stats.modes = {}
	end
	stats.playtime = (stats.playtime or 0) + t_savedData.time.total / 60 --play time
	if stats.modes[mode] == nil then
		stats.modes[mode] = {}
	end
	local t = stats.modes[mode] --mode play time
	t.playtime = (t.playtime or 0) + t_savedData.time.total / 60
	if t_sortRanking[mode] == nil then
		f_saveStats()
		return --mode can't be cleared, so further data collecting is not needed
	end
	if cleared then
		t.clear = (t.clear or 0) + 1 --number times cleared
	elseif t.clear == nil then
		t.clear = 0
	end
	if not cleared and (mode == 'bossrush' or mode == 'scorechallenge' or mode == 'timechallenge') then
		return --only winning these modes produces ranking data
	end
	--rankings
	t.ranking = f_formattedTable(
		t.ranking,
		{
			['score'] = t_savedData.score.total[1],
			['time'] = t_savedData.time.total / 60,
			['name'] = t_savedData.name or '',
			['chars'] = f_listCharRefs(start.t_p1Selected),
			['tmode'] = start.p1TeamMode,
			['ailevel'] = config.Difficulty,
			['win'] = t_savedData.win[1],
			['lose'] = t_savedData.lose[1],
			['consecutive'] = t_savedData.consecutive[1]
		},
		t_sortRanking[mode],
		motif.rankings.max_entries
	)
	f_saveStats()
end

--sets stage
function start.f_setStage(num)
	num = num or 0
	--stage
	if not main.stageMenu and not continueData then
		if main.t_charparam.stage and main.t_charparam.rivals and start.f_rivalsMatch('stage') then --stage assigned as rivals param
			num = math.random(1, #main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo].stage)
			num = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo].stage[num]
		elseif main.t_charparam.stage and main.t_selChars[start.t_p2Selected[1].ref + 1].stage ~= nil then --stage assigned as character param
			num = math.random(1, #main.t_selChars[start.t_p2Selected[1].ref + 1].stage)
			num = main.t_selChars[start.t_p2Selected[1].ref + 1].stage[num]
		elseif (gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop')) and main.t_orderStages[main.t_selChars[start.t_p2Selected[1].ref + 1].order] ~= nil then --stage assigned as stage order param
			num = math.random(1, #main.t_orderStages[main.t_selChars[start.t_p2Selected[1].ref + 1].order])
			num = main.t_orderStages[main.t_selChars[start.t_p2Selected[1].ref + 1].order][num]
		else --stage randomly selected
			num = main.t_includeStage[1][math.random(1, #main.t_includeStage[1])]
		end
	end
	setStage(num)
	selectStage(num)
	return num
end

--sets music
function start.f_setMusic(num)
	start.t_music = {music = {}, musicalt = {}, musiclife = {}, musicvictory = {}}
	t_victoryBGM = {}
	for _, v in ipairs({'music', 'musicalt', 'musiclife', 'musicvictory', 'musicvictory'}) do
		local track = 0
		local music = ''
		local volume = 100
		local loopstart = 0
		local loopend = 0
		if main.stageMenu then --game modes with stage selection screen
			if main.t_selStages[num] ~= nil and main.t_selStages[num][v] ~= nil then --music assigned as stage param
				track = math.random(1, #main.t_selStages[num][v])
				music = main.t_selStages[num][v][track].bgmusic
				volume = main.t_selStages[num][v][track].bgmvolume
				loopstart = main.t_selStages[num][v][track].bgmloopstart
				loopend = main.t_selStages[num][v][track].bgmloopend
			end
		elseif not gamemode('demo') or motif.demo_mode.fight_playbgm == 1 then --game modes other than demo (or demo with stage BGM param enabled)
			if main.t_charparam.music and main.t_charparam.rivals and start.f_rivalsMatch(v) then --music assigned as rivals param
				track = math.random(1, #main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][v])
				music = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][v][track].bgmusic
				volume = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][v][track].bgmvolume
				loopstart = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][v][track].bgmloopstart
				loopend = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo][v][track].bgmloopend
			elseif main.t_charparam.music and main.t_selChars[start.t_p2Selected[1].ref + 1][v] ~= nil then --music assigned as character param
				track = math.random(1, #main.t_selChars[start.t_p2Selected[1].ref + 1][v])
				music = main.t_selChars[start.t_p2Selected[1].ref + 1][v][track].bgmusic
				volume = main.t_selChars[start.t_p2Selected[1].ref + 1][v][track].bgmvolume
				loopstart = main.t_selChars[start.t_p2Selected[1].ref + 1][v][track].bgmloopstart
				loopend = main.t_selChars[start.t_p2Selected[1].ref + 1][v][track].bgmloopend
			elseif main.t_selStages[num] ~= nil and main.t_selStages[num][v] ~= nil then --music assigned as stage param
				track = math.random(1, #main.t_selStages[num][v])
				music = main.t_selStages[num][v][track].bgmusic
				volume = main.t_selStages[num][v][track].bgmvolume
				loopstart = main.t_selStages[num][v][track].bgmloopstart
				loopend = main.t_selStages[num][v][track].bgmloopend
			end
		end
		if v == 'musicvictory' then
			table.insert(t_victoryBGM, music ~= '')
		end
		if music ~= '' or v == 'music' then
			if v == 'musicvictory' then
				start.t_music[v][#t_victoryBGM] = {bgmusic = music, bgmvolume = volume, bgmloopstart = loopstart, bgmloopend = loopend}
			else
				start.t_music[v] = {bgmusic = music, bgmvolume = volume, bgmloopstart = loopstart, bgmloopend = loopend}
			end
		end
	end
	for k, v in pairs({bgmtrigger_alt = 0, bgmratio_life = 30, bgmtrigger_life = 0}) do
		if main.t_selStages[num] ~= nil and main.t_selStages[num][k] ~= nil then
			start.t_music[k] = main.t_selStages[num][k]
		else
			start.t_music[k] = v
		end
	end
end

--remaps palette based on button press and character's keymap settings
function start.f_reampPal(ref, num)
	if main.t_selChars[ref + 1].pal_keymap[num] ~= nil then
		return main.t_selChars[ref + 1].pal_keymap[num]
	end
	return num
end

--returns palette number
function start.f_selectPal(ref, palno)
	local t_assignedKeys = {}
	for i = 1, #start.t_p1Selected do
		if start.t_p1Selected[i].ref == ref then
			t_assignedKeys[start.t_p1Selected[i].pal] = ''
		end
	end
	for i = 1, #start.t_p2Selected do
		if start.t_p2Selected[i].ref == ref then
			t_assignedKeys[start.t_p2Selected[i].pal] = ''
		end
	end
	local t = {}
	--selected palette
	if palno ~= nil then
		t = main.f_tableCopy(main.t_selChars[ref + 1].pal)
		if t_assignedKeys[start.f_reampPal(ref, palno)] == nil then
			return start.f_reampPal(ref, palno)
		else
			local wrap = 0
			for k, v in ipairs(t) do
				if start.f_reampPal(ref, v) == start.f_reampPal(ref, palno) then
					wrap = #t - k
					break
				end
			end
			main.f_tableWrap(t, wrap)
			for k, v in ipairs(t) do
				if t_assignedKeys[start.f_reampPal(ref, v)] == nil then
					return start.f_reampPal(ref, v)
				end
			end
		end
	--default palette
	elseif not config.AIRandomColor then
		t = main.f_tableCopy(main.t_selChars[ref + 1].pal_defaults)
		palno = main.t_selChars[ref + 1].pal_defaults[1]
		if t_assignedKeys[palno] == nil then
			return palno
		else
			local wrap = 0
			for k, v in ipairs(t) do
				if v == palno then
					wrap = #t - k
					break
				end
			end
			main.f_tableWrap(t, wrap)
			for k, v in ipairs(t) do
				if t_assignedKeys[v] == nil then
					return v
				end
			end
		end
	end
	--random palette
	t = main.f_tableCopy(main.t_selChars[ref + 1].pal)
	if #t_assignedKeys >= #t then --not enough palettes for unique selection
		return math.random(1, #t)
	end
	main.f_tableShuffle(t)
	for k, v in ipairs(t) do
		if t_assignedKeys[v] == nil then
			return v
		end
	end
end

--returns ratio level
local t_ratioArray = {
	{2, 1, 1},
	{1, 2, 1},
	{1, 1, 2},
	{2, 2},
	{3, 1},
	{1, 3},
	{4}
}
function start.f_setRatio(player)
	if player == 1 then
		if not p1Ratio then
			return nil
		end
		return t_ratioArray[p1NumRatio][#start.t_p1Selected + 1]
	end
	if not p2Ratio then
		return nil
	end
	if not continueData and not main.p2SelectMenu and #start.t_p2Selected == 0 then
		if p2NumChars == 3 then
			p2NumRatio = math.random(1, 3)
		elseif p2NumChars == 2 then
			p2NumRatio = math.random(4, 6)
		else
			p2NumRatio = 7
		end
	end
	return t_ratioArray[p2NumRatio][#start.t_p2Selected + 1]
end

--sets life recovery and ratio level
function start.f_overrideCharData()
	--round 2+ in survival mode
	if matchNo >= 2 and (gamemode('survival') or gamemode('survivalcoop') or gamemode('netplaysurvivalcoop')) then
		local lastRound = #t_gameStats.match
		local removedNum = 0
		local p1Count = 0
		--Turns
		if start.p1TeamMode == 2 then
			local t_p1Keys = {}
			--for each round in the last match
			for round = 1, #t_gameStats.match do
				--remove character from team if he/she has been defeated
				if not t_gameStats.match[round][1].win or t_gameStats.match[round][1].ko then
					table.remove(start.t_p1Selected, t_gameStats.match[round][1].memberNo + 1 - removedNum)
					removedNum = removedNum + 1
					p1NumChars = p1NumChars - 1
				--otherwise override character's next match life (done after all rounds have been checked)
				else
					t_p1Keys[t_gameStats.match[round][1].memberNo] = t_gameStats.match[round][1].life
				end
			end
			for k, v in pairs(t_p1Keys) do
				p1Count = p1Count + 1
				overrideCharData(p1Count, {['life'] = v})
			end
		--Single / Simul / Tag
		else
			--for each player data in the last round
			for player = 1, #t_gameStats.match[lastRound] do
				--only check P1 side characters
				if player % 2 ~= 0 and player <= (p1NumChars + removedNum) * 2 then --odd value, team size check just in case
					--in normal survival remove character from team if he/she has been defeated
					if gamemode('survival') and (not t_gameStats.match[lastRound][player].win or t_gameStats.match[lastRound][player].ko) then
						table.remove(start.t_p1Selected, t_gameStats.match[lastRound][player].memberNo + 1 - removedNum)
						removedNum = removedNum + 1
						p1NumChars = p1NumChars - 1
					--in coop modes defeated character can still fight
					elseif gamemode('survivalcoop') or gamemode('netplaysurvivalcoop') then
						local life = t_gameStats.match[lastRound][player].life
						if life <= 0 then
							life = math.max(1, t_gameStats.match[lastRound][player].lifeMax * config.TurnsRecoveryBase)
						end
						overrideCharData(player, {['life'] = life})
					--otherwise override character's next match life
					else
						if p1Count == 0 then
							p1Count = 1
						else
							p1Count = p1Count + 2
						end
						overrideCharData(p1Count, {['life'] = t_gameStats.match[lastRound][player].life})
					end
				end
			end
		end
		if removedNum > 0 then
			setTeamMode(1, start.p1TeamMode, p1NumChars)
		end
	end
	--ratio level
	if p1Ratio then
		for i = 1, #start.t_p1Selected do
			setRatioLevel(i * 2 - 1, start.t_p1Selected[i].ratio)
			overrideCharData(i * 2 - 1, {['lifeRatio'] = config.RatioLife[start.t_p1Selected[i].ratio]})
			overrideCharData(i * 2 - 1, {['attackRatio'] = config.RatioAttack[start.t_p1Selected[i].ratio]})
		end
	end
	if p2Ratio then
		for i = 1, #start.t_p2Selected do
			setRatioLevel(i * 2, start.t_p2Selected[i].ratio)
			overrideCharData(i * 2, {['lifeRatio'] = config.RatioLife[start.t_p2Selected[i].ratio]})
			overrideCharData(i * 2, {['attackRatio'] = config.RatioAttack[start.t_p2Selected[i].ratio]})
		end
	end
end

--Convert number to name and get rid of the ""
function start.f_getName(ref)
	local tmp = getCharName(ref)
	if main.t_selChars[ref + 1].hidden == 3 then
		tmp = 'Random'
	elseif main.t_selChars[ref + 1].hidden == 2 then
		tmp = ''
	end
	return tmp
end

--draws character names
function start.f_drawName(t, data, font, offsetX, offsetY, scaleX, scaleY, height, spacingX, spacingY, active_font, active_row)
	for i = 1, #t do
		local x = offsetX
		local f = font
		if active_font and active_row then
			if i == active_row then
				f = active_font
			else
				f = font
			end
		end
		data:update({
			font =   f[1],
			bank =   f[2],
			align =  f[3],
			text =   start.f_getName(t[i].ref),
			x =      x + (i - 1) * spacingX,
			y =      offsetY + (i - 1) * spacingY,
			scaleX = scaleX,
			scaleY = scaleY,
			r =      f[4],
			g =      f[5],
			b =      f[6],
			src =    f[7],
			dst =    f[8],
			height = height,
		})
		data:draw()
	end
end

--returns correct cell position after moving the cursor
function start.f_cellMovement(selX, selY, cmd, faceOffset, rowOffset, snd)
	local tmpX = selX
	local tmpY = selY
	local tmpFace = faceOffset
	local tmpRow = rowOffset
	local found = false
	if main.f_input({cmd}, {'$U'}) then
		for i = 1, motif.select_info.rows + motif.select_info.rows_scrolling do
			selY = selY - 1
			if selY < 0 then
				if wrappingY then
					faceOffset = motif.select_info.rows_scrolling * motif.select_info.columns
					rowOffset = motif.select_info.rows_scrolling
					selY = motif.select_info.rows + motif.select_info.rows_scrolling - 1
				else
					faceOffset = tmpFace
					rowOffset = tmpRow
					selY = tmpY
				end
			elseif selY < rowOffset then
				faceOffset = faceOffset - motif.select_info.columns
				rowOffset = rowOffset - 1
			end
			if (start.t_grid[selY + 1][selX + 1].char ~= nil and start.t_grid[selY + 1][selX + 1].hidden ~= 2) or motif.select_info.moveoveremptyboxes == 1 then
				break
			elseif motif.select_info.searchemptyboxesup ~= 0 then
				found, selX = start.f_searchEmptyBoxes(motif.select_info.searchemptyboxesup, selX, selY)
				if found then
					break
				end
			end
		end
	elseif main.f_input({cmd}, {'$D'}) then
		for i = 1, motif.select_info.rows + motif.select_info.rows_scrolling do
			selY = selY + 1
			if selY >= motif.select_info.rows + motif.select_info.rows_scrolling then
				if wrappingY then
					faceOffset = 0
					rowOffset = 0
					selY = 0
				else
					faceOffset = tmpFace
					rowOffset = tmpRow
					selY = tmpY
				end
			elseif selY >= motif.select_info.rows + rowOffset then
				faceOffset = faceOffset + motif.select_info.columns
				rowOffset = rowOffset + 1
			end
			if (start.t_grid[selY + 1][selX + 1].char ~= nil and start.t_grid[selY + 1][selX + 1].hidden ~= 2) or motif.select_info.moveoveremptyboxes == 1 then
				break
			elseif motif.select_info.searchemptyboxesdown ~= 0 then
				found, selX = start.f_searchEmptyBoxes(motif.select_info.searchemptyboxesdown, selX, selY)
				if found then
					break
				end
			end
		end
	elseif main.f_input({cmd}, {'$B'}) then
		for i = 1, motif.select_info.columns do
			selX = selX - 1
			if selX < 0 then
				if wrappingX then
					selX = motif.select_info.columns - 1
				else
					selX = tmpX
				end
			end
			if (start.t_grid[selY + 1][selX + 1].char ~= nil and start.t_grid[selY + 1][selX + 1].hidden ~= 2) or motif.select_info.moveoveremptyboxes == 1 then
				break
			end
		end
	elseif main.f_input({cmd}, {'$F'}) then
		for i = 1, motif.select_info.columns do
			selX = selX + 1
			if selX >= motif.select_info.columns then
				if wrappingX then
					selX = 0
				else
					selX = tmpX
				end
			end
			if (start.t_grid[selY + 1][selX + 1].char ~= nil and start.t_grid[selY + 1][selX + 1].hidden ~= 2) or motif.select_info.moveoveremptyboxes == 1 then
				break
			end
		end
	end
	if tmpX ~= selX or tmpY ~= selY then
		resetgrid = true
		--if tmpRow ~= rowOffset then
			--start.f_resetGrid()
		--end
		sndPlay(motif.files.snd_data, snd[1], snd[2])
	end
	return selX, selY, faceOffset, rowOffset
end

--used by above function to find valid cell in case of dummy character entries
function start.f_searchEmptyBoxes(direction, x, y)
	local selX = x
	local selY = y
	local tmpX = x
	local found = false
	if direction > 0 then --right
		while true do
			x = x + 1
			if x >= motif.select_info.columns then
				x = tmpX
				break
			elseif start.t_grid[y + 1][x + 1].char ~= nil and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
				found = true
				break
			end
		end
	elseif direction < 0 then --left
		while true do
			x = x - 1
			if x < 0 then
				x = tmpX
				break
			elseif start.t_grid[y + 1][x + 1].char ~= nil and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
				found = true
				break
			end
		end
	end
	return found, x
end

--generates table with cell coordinates
function start.f_resetGrid()
	start.t_drawFace = {}
	for row = 1, motif.select_info.rows do
		for col = 1, motif.select_info.columns do
			-- Note to anyone editing this function:
			-- The "elseif" chain is important if a "end" is added in the middle it could break the character icon display.
			--1Pのランダムセル表示位置 / 1P random cell display position
			if start.t_grid[row + p1RowOffset][col].char == 'randomselect' or start.t_grid[row + p1RowOffset][col].hidden == 3 then
				table.insert(start.t_drawFace, {
					d = 1,
					p1 = start.t_grid[row + p1RowOffset][col].char_ref,
					p2 = start.t_grid[row + p2RowOffset][col].char_ref,
					x1 = p1FaceX + start.t_grid[row][col].x,
					x2 = p2FaceX + start.t_grid[row][col].x,
					y1 = p1FaceY + start.t_grid[row][col].y,
					y2 = p2FaceY + start.t_grid[row][col].y,
					row = row,
					col = col
				})
			--1Pのキャラ表示位置 / 1P character display position
			elseif start.t_grid[row + p1RowOffset][col].char ~= nil and start.t_grid[row + p1RowOffset][col].hidden == 0 then
				table.insert(start.t_drawFace, {
					d = 2,
					p1 = start.t_grid[row + p1RowOffset][col].char_ref,
					p2 = start.t_grid[row + p2RowOffset][col].char_ref,
					x1 = p1FaceX + start.t_grid[row][col].x,
					x2 = p2FaceX + start.t_grid[row][col].x,
					y1 = p1FaceY + start.t_grid[row][col].y,
					y2 = p2FaceY + start.t_grid[row][col].y,
					row = row,
					col = col
				})
			--Empty boxes display position
			elseif motif.select_info.showemptyboxes == 1 then
				table.insert(start.t_drawFace, {
					d = 0,
					p1 = start.t_grid[row + p1RowOffset][col].char_ref,
					p2 = start.t_grid[row + p2RowOffset][col].char_ref,
					x1 = p1FaceX + start.t_grid[row][col].x,
					x2 = p2FaceX + start.t_grid[row][col].x,
					y1 = p1FaceY + start.t_grid[row][col].y,
					y2 = p2FaceY + start.t_grid[row][col].y,
					row = row,
					col = col
				})
			end
			--2Pのランダムセル表示位置 / 2P random cell display position
			if start.t_grid[row + p2RowOffset][col].char == 'randomselect' or start.t_grid[row + p2RowOffset][col].hidden == 3 then
				table.insert(start.t_drawFace, {
					d = 11,
					p1 = start.t_grid[row + p1RowOffset][col].char_ref,
					p2 = start.t_grid[row + p2RowOffset][col].char_ref,
					x1 = p1FaceX + start.t_grid[row][col].x,
					x2 = p2FaceX + start.t_grid[row][col].x,
					y1 = p1FaceY + start.t_grid[row][col].y,
					y2 = p2FaceY + start.t_grid[row][col].y,
					row = row,
					col = col
				})
			--2Pのキャラ表示位置 / 2P character display position
			elseif start.t_grid[row + p2RowOffset][col].char ~= nil and start.t_grid[row + p2RowOffset][col].hidden == 0 then
				table.insert(start.t_drawFace, {
					d = 12,
					p1 = start.t_grid[row + p1RowOffset][col].char_ref,
					p2 = start.t_grid[row + p2RowOffset][col].char_ref,
					x1 = p1FaceX + start.t_grid[row][col].x,
					x2 = p2FaceX + start.t_grid[row][col].x,
					y1 = p1FaceY + start.t_grid[row][col].y,
					y2 = p2FaceY + start.t_grid[row][col].y,
					row = row,
					col = col
				})
			--Empty boxes display position
			elseif motif.select_info.showemptyboxes == 1 then
				table.insert(start.t_drawFace, {
					d = 10,
					p1 = start.t_grid[row + p1RowOffset][col].char_ref,
					p2 = start.t_grid[row + p2RowOffset][col].char_ref,
					x1 = p1FaceX + start.t_grid[row][col].x,
					x2 = p2FaceX + start.t_grid[row][col].x,
					y1 = p1FaceY + start.t_grid[row][col].y,
					y2 = p2FaceY + start.t_grid[row][col].y,
					row = row,
					col = col
				})
			end
		end
	end
	--if main.debugLog then main.f_printTable(start.t_drawFace, 'debug/t_drawFace.txt') end
end

--sets correct start cell
function start.f_startCell()
	--starting row
	if motif.select_info.p1_cursor_startcell[1] < motif.select_info.rows then
		p1SelY = motif.select_info.p1_cursor_startcell[1]
	else
		p1SelY = 0
	end
	if motif.select_info.p2_cursor_startcell[1] < motif.select_info.rows then
		p2SelY = motif.select_info.p2_cursor_startcell[1]
	else
		p2SelY = 0
	end
	--starting column
	if motif.select_info.p1_cursor_startcell[2] < motif.select_info.columns then
		p1SelX = motif.select_info.p1_cursor_startcell[2]
	else
		p1SelX = 0
	end
	if motif.select_info.p2_cursor_startcell[2] < motif.select_info.columns then
		p2SelX = motif.select_info.p2_cursor_startcell[2]
	else
		p2SelX = 0
	end
end

--unlocks characters on select screen
function start.f_unlockChar(char, flag)
	main.t_selChars[char + 1].hidden = flag
	start.t_grid[main.t_selChars[char + 1].row][main.t_selChars[char + 1].col].hidden = flag
	start.f_resetGrid()
end

--return t_selChars table out of cell number
function start.f_selGrid(cell)
	if #main.t_selGrid[cell].chars == 0 then
		return {}
	end
	return main.t_selChars[main.t_selGrid[cell].chars[main.t_selGrid[cell].slot]]
end

--return true if slot is selected, update start.t_grid
function start.f_slotSelected(cell, cmd, x, y)
	if #main.t_selGrid[cell].chars > 0 then
		for _, cmdType in ipairs({'select', 'next', 'previous'}) do
			if main.t_selGrid[cell][cmdType] ~= nil then
				for k, v in pairs(main.t_selGrid[cell][cmdType]) do
					if main.f_input({cmd}, {k}) then
						if cmdType == 'next' then
							local ok = false
							for i = 1, #v do
								if v[i] > main.t_selGrid[cell].slot then
									main.t_selGrid[cell].slot = v[i]
									ok = true
									break
								end
							end
							if not ok then
								main.t_selGrid[cell].slot = v[1]
								ok = true
							end
						elseif cmdType == 'previous' then
							local ok = false
							for i = #v, 1, -1 do
								if v[i] < main.t_selGrid[cell].slot then
									main.t_selGrid[cell].slot = v[i]
									ok = true
									break
								end
							end
							if not ok then
								main.t_selGrid[cell].slot = v[#v]
								ok = true
							end
						else --select
							main.t_selGrid[cell].slot = v[math.random(1, #v)]
						end
						start.t_grid[y + 1][x + 1].char = start.f_selGrid(cell).char
						start.t_grid[y + 1][x + 1].char_ref = start.f_selGrid(cell).char_ref
						start.f_resetGrid()
						return cmdType == 'select'
					end
				end
			end
		end
	end
	if main.f_btnPalNo(main.t_cmd[cmd]) == 0 then
		return false
	end
	return true
end

--
function start.f_faceOffset(col, row, key)
	if motif.select_info['cell_' .. col .. '_' .. row .. '_offset'] ~= nil then
		return motif.select_info['cell_' .. col .. '_' .. row .. '_offset'][key] or 0
	end
	return 0
end

-- set start.t_grid, with adjancement of character in the select screen
function start.f_generateGrid()
	local cnt = motif.select_info.columns + 1
	local row = 1
	local col = 0
	start.t_grid = {[row] = {}}
	for i = 1, (motif.select_info.rows + motif.select_info.rows_scrolling) * motif.select_info.columns do
		if i == cnt then
			row = row + 1
			cnt = cnt + motif.select_info.columns
			start.t_grid[row] = {}
		end
		col = #start.t_grid[row] + 1
		start.t_grid[row][col] = {
			x = (col - 1) * (motif.select_info.cell_size[1] + motif.select_info.cell_spacing[1]) + start.f_faceOffset(col, row, 1),
			y = (row - 1) * (motif.select_info.cell_size[2] + motif.select_info.cell_spacing[2]) + start.f_faceOffset(col, row, 2)
		}
		if start.f_selGrid(i).char ~= nil then
			start.t_grid[row][col].char = start.f_selGrid(i).char
			start.t_grid[row][col].char_ref = start.f_selGrid(i).char_ref
			start.t_grid[row][col].hidden = start.f_selGrid(i).hidden
		end
	end
	if main.debugLog then main.f_printTable(start.t_grid, 'debug/t_grid.txt') end
end

start.f_generateGrid()

--return formatted clear time string
function start.f_clearTimeText(text, totalSec)
	local h = tostring(math.floor(totalSec / 3600))
	local m = tostring(math.floor((totalSec / 3600 - h) * 60))
	local s = tostring(math.floor(((totalSec / 3600 - h) * 60 - m) * 60))
	local x = tostring(math.floor((((totalSec / 3600 - h) * 60 - m) * 60 - s) * 100))
	if string.len(m) < 2 then
		m = '0' .. m
	end
	if string.len(s) < 2 then
		s = '0' .. s
	end
	if string.len(x) < 2 then
		x = '0' .. x
	end
	return text:gsub('%%h', h):gsub('%%m', m):gsub('%%s', s):gsub('%%x', x)
end

--return formatted record text table
function start.f_getRecordText()
	if motif.select_info['record_' .. gamemode() .. '_text'] == nil or stats.modes == nil or stats.modes[gamemode()] == nil or stats.modes[gamemode()].ranking == nil or stats.modes[gamemode()].ranking[1] == nil then
		return {}
	end
	local text = motif.select_info['record_' .. gamemode() .. '_text']
	--time
	text = start.f_clearTimeText(text, stats.modes[gamemode()].ranking[1].time)
	--score
	text = text:gsub('%%p', tostring(stats.modes[gamemode()].ranking[1].score))
	--char name
	local name = '?' --in case character being removed from roster
	if main.t_charDef[stats.modes[gamemode()].ranking[1].chars[1]] ~= nil then
		name = main.t_selChars[main.t_charDef[stats.modes[gamemode()].ranking[1].chars[1]] + 1].displayname
	end
	text = text:gsub('%%c', name)
	--player name
	text = text:gsub('%%n', stats.modes[gamemode()].ranking[1].name)
	return main.f_extractText(text)
end

--cursor sound data, play cursor sound
function start.f_playWave(ref, name, g, n, loops)
	if g < 0 or n < 0 then return end
	if name == 'stage' then
		local a = main.t_selStages[ref].attachedChar
		if a == nil or a.sound == nil then
			return
		end
		if main.t_selStages[ref][name .. '_wave_data'] == nil then
			main.t_selStages[ref][name .. '_wave_data'] = getWaveData(a.dir .. a.sound, g, n, loops or -1)
		end
		wavePlay(main.t_selStages[ref][name .. '_wave_data'])
	else
		local sound = getCharSnd(ref)
		if sound == nil or sound == '' then
			return
		end
		if main.t_selChars[ref + 1][name .. '_wave_data'] == nil then
			main.t_selChars[ref + 1][name .. '_wave_data'] = getWaveData(main.t_selChars[ref + 1].dir .. sound, g, n, loops or -1)
		end
		wavePlay(main.t_selChars[ref + 1][name .. '_wave_data'])
	end
end

--resets various data
function start.f_selectReset()
	main.f_cmdInput()
	local col = 1
	local row = 1
	for i = 1, #main.t_selGrid do
		if i > motif.select_info.columns * row then
			row = row + 1
			col = 1
		end
		if main.t_selGrid[i].slot ~= 1 then
			main.t_selGrid[i].slot = 1
			start.t_grid[row][col].char = start.f_selGrid(i).char
			start.t_grid[row][col].char_ref = start.f_selGrid(i).char_ref
			start.f_resetGrid()
		end
		col = col + 1
	end
	if main.p2Faces and motif.select_info.doubleselect_enabled == 1 then
		p1FaceX = motif.select_info.pos[1] + motif.select_info.p1_doubleselect_offset[1]
		p1FaceY = motif.select_info.pos[2] + motif.select_info.p1_doubleselect_offset[2]
		p2FaceX = motif.select_info.pos[1] + motif.select_info.p2_doubleselect_offset[1]
		p2FaceY = motif.select_info.pos[2] + motif.select_info.p2_doubleselect_offset[2]
	else
		p1FaceX = motif.select_info.pos[1]
		p1FaceY = motif.select_info.pos[2]
		p2FaceX = motif.select_info.pos[1]
		p2FaceY = motif.select_info.pos[2]
	end
	start.f_resetGrid()
	if gamemode('netplayversus') or gamemode('netplayteamcoop') or gamemode('netplaysurvivalcoop') then
		start.p1TeamMode = 0
		start.p2TeamMode = 0
		stageNo = 0
		stageList = 0
	end
	p1Cell = nil
	p2Cell = nil
	start.t_p1Selected = {}
	start.t_p2Selected = {}
	p1TeamEnd = false
	p1SelEnd = false
	p1Ratio = false
	p2TeamEnd = false
	p2SelEnd = false
	p2Ratio = false
	if main.t_pIn[2] == 1 then
		p2TeamEnd = true
		p2SelEnd = true
	end
	if not main.p2SelectMenu then
		p2SelEnd = true
	end
	selScreenEnd = false
	stageEnd = false
	coopEnd = false
	restoreTeam = false
	continueData = false
	p1NumChars = 1
	p2NumChars = 1
	winner = 0
	winCnt = 0
	loseCnt = 0
	matchNo = 0
	if not challenger then
		t_savedData = {
			['win'] = {0, 0},
			['lose'] = {0, 0},
			['time'] = {['total'] = 0, ['matches'] = {}},
			['score'] = {['total'] = {0, 0}, ['matches'] = {}},
			['consecutive'] = {0, 0},
		}
	end
	t_recordText = start.f_getRecordText()
	setMatchNo(matchNo)
	menu.movelistChar = 1
end

--;===========================================================
--; SIMPLE LOOP (VS MODE, TEAM VERSUS, TRAINING, WATCH, BONUS GAMES, TIME CHALLENGE, SCORE CHALLENGE)
--;===========================================================
function start.f_selectSimple()
	start.f_startCell()
	t_p1Cursor = {}
	t_p2Cursor = {}
	p1RestoreCursor = false
	p2RestoreCursor = false
	p1TeamMenu = 1
	p2TeamMenu = 1
	p1FaceOffset = 0
	p2FaceOffset = 0
	p1RowOffset = 0
	p2RowOffset = 0
	stageList = 0
	while true do --outer loop (moved back here after pressing ESC)
		start.f_selectReset()
		while true do --inner loop
			fadeType = 'fadein'
			selectStart()
			if not start.f_selectScreen() then
				sndPlay(motif.files.snd_data, motif.select_info.cancel_snd[1], motif.select_info.cancel_snd[2])
				main.f_bgReset(motif.titlebgdef.bg)
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
				return
			end
			--fight initialization
			start.f_overrideCharData()
			start.f_remapAI()
			start.f_setRounds()
			stageNo = start.f_setStage(stageNo)
			start.f_setMusic(stageNo)
			if start.f_selectVersus() == nil then break end
			clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
			loadStart()
			winner, t_gameStats = game()
			clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
			if gameend() then
				os.exit()
			end
			start.f_saveData()
			if challenger then
				return
			end
			if winner == -1 then break end --player exit the game via ESC
			start.f_storeSavedData(gamemode(), winner == 1)
			start.f_selectReset()
			--main.f_cmdInput()
			refresh()
		end
		esc(false) --reset ESC
		if gamemode('netplayversus') then
			--resetRemapInput()
			--main.reconnect = winner == -1
		end
		if start.exit then
			main.f_bgReset(motif.titlebgdef.bg)
			main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
			start.exit = false
			break
		end
	end
end

--;===========================================================
--; ARRANGED LOOP (SURVIVAL, SURVIVAL CO-OP, VS 100 KUMITE, BOSS RUSH)
--;===========================================================
function start.f_selectArranged()
	start.f_startCell()
	t_p1Cursor = {}
	t_p2Cursor = {}
	p1RestoreCursor = false
	p2RestoreCursor = false
	challenger = false
	p1TeamMenu = 1
	p2TeamMenu = 1
	p1FaceOffset = 0
	p2FaceOffset = 0
	p1RowOffset = 0
	p2RowOffset = 0
	stageList = 0
	while true do --outer loop (moved back here after pressing ESC)
		start.f_selectReset()
		while true do --inner loop
			fadeType = 'fadein'
			selectStart()
			if not start.f_selectScreen() then
				sndPlay(motif.files.snd_data, motif.select_info.cancel_snd[1], motif.select_info.cancel_snd[2])
				main.f_bgReset(motif.titlebgdef.bg)
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
				return
			end
			--first match
			if matchNo == 0 then
				--generate roster
				t_roster = start.f_makeRoster()
				lastMatch = #t_roster
				matchNo = 1
				--generate AI ramping table
				start.f_aiRamp(1)
			end
			--assign enemy team
			if #start.t_p2Selected == 0 then
				local shuffle = true
				for i = 1, #t_roster[matchNo] do
					table.insert(start.t_p2Selected, {ref = t_roster[matchNo][i], pal = start.f_selectPal(t_roster[matchNo][i]), ratio = start.f_setRatio(2)})
					if shuffle then
						main.f_tableShuffle(start.t_p2Selected)
					end
				end
			end
			--fight initialization
			setMatchNo(matchNo)
			start.f_overrideCharData()
			start.f_remapAI()
			start.f_setRounds()
			stageNo = start.f_setStage(stageNo)
			start.f_setMusic(stageNo)
			if start.f_selectVersus() == nil then break end
			clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
			loadStart()
			winner, t_gameStats = game()
			clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
			if gameend() then
				os.exit()
			end
			start.f_saveData()
			if winner == -1 then break end --player exit the game via ESC
			--player won in any mode or lost/draw in VS 100 Kumite mode
			if winner == 1 or gamemode('vs100kumite') then
				--infinite matches flag detected
				if t_roster[matchNo + 1] ~= nil and t_roster[matchNo + 1][1] == -1 then
					--remove flag
					table.remove(t_roster, matchNo + 1)
					--append entries to existing roster table
					t_roster = start.f_makeRoster(t_roster)
					local lastMatchRamp = lastMatch + 1
					lastMatch = #t_roster
					--append new entries to existing AI ramping table
					start.f_aiRamp(lastMatchRamp)
				end
				--no more matches left
				if matchNo == lastMatch then
					--store saved data to stats.json
					start.f_storeSavedData(gamemode(), true)
					--credits
					if motif.end_credits.enabled == 1 and main.f_fileExists(motif.end_credits.storyboard) then
						storyboard.f_storyboard(motif.end_credits.storyboard)
					end
					--game over
					if motif.game_over_screen.enabled == 1 and main.f_fileExists(motif.game_over_screen.storyboard) then
						storyboard.f_storyboard(motif.game_over_screen.storyboard)
					end
					--intro
					if motif.files.intro_storyboard ~= '' then
						storyboard.f_storyboard(motif.files.intro_storyboard)
					end
					main.f_bgReset(motif.titlebgdef.bg)
					main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
					return
				--next match available
				else
					matchNo = matchNo + 1
					start.t_p2Selected = {}
				end
			--player lost
			elseif winner ~= -1 then
				--store saved data to stats.json
				start.f_storeSavedData(gamemode(), true and gamemode() ~= 'bossrush')
				--game over
				if motif.game_over_screen.enabled == 1 and main.f_fileExists(motif.game_over_screen.storyboard) then
					storyboard.f_storyboard(motif.game_over_screen.storyboard)
				end
				--intro
				if motif.files.intro_storyboard ~= '' then
					storyboard.f_storyboard(motif.files.intro_storyboard)
				end
				main.f_bgReset(motif.titlebgdef.bg)
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
				return
			end
			--main.f_cmdInput()
			refresh()
		end
		esc(false) --reset ESC
		if gamemode('netplaysurvivalcoop') then
			--resetRemapInput()
			--main.reconnect = winner == -1
		end
		if start.exit then
			main.f_bgReset(motif.titlebgdef.bg)
			main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
			start.exit = false
			break
		end
	end
end

--;===========================================================
--; ARCADE LOOP (ARCADE, TEAM ARCADE, TEAM CO-OP, TIME ATTACK)
--;===========================================================
function start.f_selectArcade()
	start.f_startCell()
	t_p1Cursor = {}
	t_p2Cursor = {}
	p1RestoreCursor = false
	p2RestoreCursor = false
	challenger = false
	p1TeamMenu = 1
	p2TeamMenu = 1
	p1FaceOffset = 0
	p2FaceOffset = 0
	p1RowOffset = 0
	p2RowOffset = 0
	--stageEnd = true
	local teamMode = 0
	local numChars = 0
	while true do --outer loop (moved back here after pressing ESC)
		start.f_selectReset()
		while true do --inner loop
			fadeType = 'fadein'
			selectStart()
			--select screen
			if not start.f_selectScreen() then
				sndPlay(motif.files.snd_data, motif.select_info.cancel_snd[1], motif.select_info.cancel_snd[2])
				main.f_bgReset(motif.titlebgdef.bg)
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
				return
			end
			--first match
			if matchNo == 0 then
				--generate roster
				t_roster = start.f_makeRoster()
				lastMatch = #t_roster
				matchNo = 1
				--generate AI ramping table
				start.f_aiRamp(1)
				--intro
				if gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop') then --not timeattack
					local tPos = main.t_selChars[start.t_p1Selected[1].ref + 1]
					if tPos.intro ~= nil and main.f_fileExists(tPos.intro) then
						storyboard.f_storyboard(tPos.intro)
					end
				end
			end
			--assign enemy team
			local enemy_ref = 0
			if #start.t_p2Selected == 0 then
				if p2NumChars ~= #t_roster[matchNo] then
					p2NumChars = #t_roster[matchNo]
					setTeamMode(2, start.p2TeamMode, p2NumChars)
				end
				local shuffle = true
				for i = 1, #t_roster[matchNo] do
					if i == 1 and start.f_rivalsMatch('char_ref') then --enemy assigned as rivals param
						enemy_ref = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo].char_ref
						shuffle = false
					else
						enemy_ref = t_roster[matchNo][i]
					end
					table.insert(start.t_p2Selected, {ref = enemy_ref, pal = start.f_selectPal(enemy_ref), ratio = start.f_setRatio(2)})
					if shuffle then
						main.f_tableShuffle(start.t_p2Selected)
					end
				end
			end
			--Team conversion to Single match if single paramvalue on any opponents is detected
			if p2NumChars > 1 then
				for i = 1, #start.t_p2Selected do
					local single = false
					if start.f_rivalsMatch('char_ref') and start.f_rivalsMatch('single', 1) then --team conversion assigned as rivals param
						enemy_ref = main.t_selChars[start.t_p1Selected[1].ref + 1].rivals[matchNo].char_ref
						single = true
					elseif main.t_selChars[start.t_p2Selected[i].ref + 1].single == 1 then --team conversion assigned as character param
						enemy_ref = start.t_p2Selected[i].ref
						single = true
					end
					if single then
						teamMode = start.p2TeamMode
						numChars = p2NumChars
						start.p2TeamMode = 0
						p2NumChars = 1
						setTeamMode(2, start.p2TeamMode, p2NumChars)
						start.t_p2Selected = {}
						start.t_p2Selected[1] = {ref = enemy_ref, pal = start.f_selectPal(enemy_ref)}
						restoreTeam = true
						break
					end
				end
			end
			--fight initialization
			challenger = false
			setMatchNo(matchNo)
			start.f_overrideCharData()
			start.f_remapAI()
			start.f_setRounds()
			stageNo = start.f_setStage(stageNo)
			start.f_setMusic(stageNo)
			if start.f_selectVersus() == nil then break end
			clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
			loadStart()
			winner, t_gameStats = game()
			clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
			if gameend() then
				os.exit()
			end
			start.f_saveData()
			if t_gameStats.challenger > 0 then --here comes a new challenger
				start.f_challenger()
			elseif winner == -1 then --player exit the game via ESC
				break
			elseif winner == 1 then --player won
				--no more matches left
				if matchNo == lastMatch then
					--store saved data to stats.json
					start.f_storeSavedData(gamemode(), true)
					--ending
					if gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop') then --not timeattack
						local tPos = main.t_selChars[start.t_p1Selected[1].ref + 1]
						if tPos.ending ~= nil and main.f_fileExists(tPos.ending) then
							storyboard.f_storyboard(tPos.ending)
						elseif motif.default_ending.enabled == 1 and main.f_fileExists(motif.default_ending.storyboard) then
							storyboard.f_storyboard(motif.default_ending.storyboard)
						end
					end
					--credits
					if motif.end_credits.enabled == 1 and main.f_fileExists(motif.end_credits.storyboard) then
						storyboard.f_storyboard(motif.end_credits.storyboard)
					end
					--game over
					if motif.game_over_screen.enabled == 1 and main.f_fileExists(motif.game_over_screen.storyboard) then
						storyboard.f_storyboard(motif.game_over_screen.storyboard)
					end
					--intro
					if motif.files.intro_storyboard ~= '' then
						storyboard.f_storyboard(motif.files.intro_storyboard)
					end
					main.f_bgReset(motif.titlebgdef.bg)
					main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
					return
				--next match available
				else
					matchNo = matchNo + 1
					continueData = false
					start.t_p2Selected = {}
				end
			--player lost and doesn't have any credits left
			elseif main.credits == 0 then
				--store saved data to stats.json
				start.f_storeSavedData(gamemode(), false)
				--game over
				if motif.game_over_screen.enabled == 1 and main.f_fileExists(motif.game_over_screen.storyboard) then
					storyboard.f_storyboard(motif.game_over_screen.storyboard)
				end
				--intro
				if motif.files.intro_storyboard ~= '' then
					storyboard.f_storyboard(motif.files.intro_storyboard)
				end
				main.f_bgReset(motif.titlebgdef.bg)
				main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
				return
			--player lost but can continue
			else
				--continue screen
				if not gamemode('netplayteamcoop') then
					if not continueFlag then
						--store saved data to stats.json
						start.f_storeSavedData(gamemode(), false)
						--game over
						if motif.continue_screen.external_gameover == 1 and main.f_fileExists(motif.game_over_screen.storyboard) then
							storyboard.f_storyboard(motif.game_over_screen.storyboard)
						end
						--intro
						if motif.files.intro_storyboard ~= '' then
							storyboard.f_storyboard(motif.files.intro_storyboard)
						end
						main.f_bgReset(motif.titlebgdef.bg)
						main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
						return
					end
				end
				--character selection
				if (not main.quickContinue and not config.QuickContinue) or gamemode('netplayteamcoop') then --true if 'Quick Continue' is disabled or we're playing online
					start.t_p1Selected = {}
					p1SelEnd = false
					selScreenEnd = false
				end
				continueData = true
			end
			--restore P2 Team settings if needed
			if restoreTeam then
				start.p2TeamMode = teamMode
				p2NumChars = numChars
				setTeamMode(2, start.p2TeamMode, p2NumChars)
				restoreTeam = false
			end
			--main.f_cmdInput()
			refresh()
		end
		esc(false) --reset ESC
		if gamemode() == 'netplayteamcoop' then
			--resetRemapInput()
			--main.reconnect = winner == -1
		end
		if start.exit then
			main.f_bgReset(motif.titlebgdef.bg)
			main.f_playBGM(true, motif.music.title_bgm, motif.music.title_bgm_loop, motif.music.title_bgm_volume, motif.music.title_bgm_loopstart, motif.music.title_bgm_loopend)
			start.exit = false
			break
		end
	end
end

function start.f_challenger()
	esc(false)
	challenger = true
	--save values
	local t_p1Selected_sav = main.f_tableCopy(start.t_p1Selected)
	local t_p2Selected_sav = main.f_tableCopy(start.t_p2Selected)
	local p1TeamMenu_sav = main.f_tableCopy(main.p1TeamMenu)
	local p2TeamMenu_sav = main.f_tableCopy(main.p2TeamMenu)
	local t_charparam_sav = main.f_tableCopy(main.t_charparam)
	local p1Ratio_sav = p1Ratio
	local p2Ratio_sav = p2Ratio
	local p1NumRatio_sav = p1NumRatio
	local p2NumRatio_sav = p2NumRatio
	local p1Cell_sav = p1Cell
	local p2Cell_sav = p2Cell
	local winCnt_sav = winCnt
	local loseCnt_sav = loseCnt
	local matchNo_sav = matchNo
	local stageNo_sav = stageNo
	local restoreTeam_sav = restoreTeam
	local p1TeamMode_sav = start.p1TeamMode
	local p1NumChars_sav = p1NumChars
	local p2TeamMode_sav = start.p2TeamMode
	local p2NumChars_sav = p2NumChars
	local gameMode = gamemode()
	local p1score_sav = main.t_lifebar.p1score
	local p2score_sav = main.t_lifebar.p2score
	--temp mode data
	main.txt_mainSelect:update({text = motif.select_info.title_teamversus_text})
	setHomeTeam(1)
	p2NumRatio = 1
	main.t_pIn[2] = 2
	main.p2SelectMenu = true
	main.stageMenu = true
	main.p2Faces = true
	main.p1TeamMenu = {single = true, simul = true, turns = true, tag = true, ratio = true}
	main.p2TeamMenu = {single = true, simul = true, turns = true, tag = true, ratio = true}
	main.t_lifebar.p1score = true
	main.t_lifebar.p2score = true
	main.f_resetCharparam()
	setGameMode('teamversus')
	--start challenger match
	start.f_selectSimple()
	--restore mode data
	main.txt_mainSelect:update({text = motif.select_info.title_arcade_text})
	setHomeTeam(2)
	main.t_pIn[2] = 1
	main.p2SelectMenu = false
	main.stageMenu = false
	main.p2Faces = false
	main.p1TeamMenu = p1TeamMenu_sav
	main.p2TeamMenu = p2TeamMenu_sav
	main.t_lifebar.p1score = p1score_sav
	main.t_lifebar.p2score = p2score_sav
	main.t_charparam = t_charparam_sav
	setGameMode(gameMode)
	if esc() or main.f_input(main.t_players, {'m'}) then
		challenger = false
		start.f_selectReset()
		return
	end
	if getConsecutiveWins(1) > 0 then
		setConsecutiveWins(1, getConsecutiveWins(1) - 1)
	end
	if winner == 2 then
		--TODO: when player1 team lose continue playing the arcade mode as player2 team
	end
	--restore values
	p1TeamEnd = true
	p2TeamEnd = true
	p1SelEnd = true
	p2SelEnd = true
	start.t_p1Selected = t_p1Selected_sav
	start.t_p2Selected = t_p2Selected_sav
	p1Ratio = p1Ratio_sav
	p2Ratio = p2Ratio_sav
	p1NumRatio = p1NumRatio_sav
	p2NumRatio = p2NumRatio_sav
	p1Cell = p1Cell_sav
	p2Cell = p2Cell_sav
	winCnt = winCnt_sav
	loseCnt = loseCnt_sav
	matchNo = matchNo_sav
	stageNo = stageNo_sav
	restoreTeam = restoreTeam_sav
	start.p1TeamMode = p1TeamMode_sav
	p1NumChars = p1NumChars_sav
	setTeamMode(1, start.p1TeamMode, p1NumChars)
	start.p2TeamMode = p2TeamMode_sav
	p2NumChars = p2NumChars_sav
	setTeamMode(2, start.p2TeamMode, p2NumChars)
	continueData = true
end

--;===========================================================
--; TOURNAMENT LOOP
--;===========================================================
function start.f_selectTournament(size)
	return
end

--;===========================================================
--; TOURNAMENT SCREEN
--;===========================================================
function start.f_selectTournamentScreen(size)
	--draw clearcolor
	clearColor(motif.tournamentbgdef.bgclearcolor[1], motif.tournamentbgdef.bgclearcolor[2], motif.tournamentbgdef.bgclearcolor[3])
	--draw layerno = 0 backgrounds
	bgDraw(motif.tournamentbgdef.bg, false)
	--draw layerno = 1 backgrounds
	bgDraw(motif.tournamentbgdef.bg, true)
	--draw fadein / fadeout
	main.fadeActive = fadeColor(
		fadeType,
		main.fadeStart,
		motif.vs_screen[fadeType .. '_time'],
		motif.vs_screen[fadeType .. '_col'][1],
		motif.vs_screen[fadeType .. '_col'][2],
		motif.vs_screen[fadeType .. '_col'][3]
	)
	--frame transition
	if main.fadeActive then
		commandBufReset(main.t_cmd[1])
	elseif fadeType == 'fadeout' then
		commandBufReset(main.t_cmd[1])
		return --skip last frame rendering
	else
		main.f_cmdInput()
	end
	refresh()
end

--;===========================================================
--; SELECT SCREEN
--;===========================================================
local txt_recordSelect = text:create({
	font =   motif.select_info.record_font[1],
	bank =   motif.select_info.record_font[2],
	align =  motif.select_info.record_font[3],
	text =   '',
	x =      motif.select_info.record_offset[1],
	y =      motif.select_info.record_offset[2],
	scaleX = motif.select_info.record_font_scale[1],
	scaleY = motif.select_info.record_font_scale[2],
	r =      motif.select_info.record_font[4],
	g =      motif.select_info.record_font[5],
	b =      motif.select_info.record_font[6],
	src =    motif.select_info.record_font[7],
	dst =    motif.select_info.record_font[8],
	height = motif.select_info.record_font_height,
})
local txt_timerSelect = text:create({
	font =   motif.select_info.timer_font[1],
	bank =   motif.select_info.timer_font[2],
	align =  motif.select_info.timer_font[3],
	text =   '',
	x =      motif.select_info.timer_offset[1],
	y =      motif.select_info.timer_offset[2],
	scaleX = motif.select_info.timer_font_scale[1],
	scaleY = motif.select_info.timer_font_scale[2],
	r =      motif.select_info.timer_font[4],
	g =      motif.select_info.timer_font[5],
	b =      motif.select_info.timer_font[6],
	src =    motif.select_info.timer_font[7],
	dst =    motif.select_info.timer_font[8],
	height = motif.select_info.timer_font_height,
})
local txt_p1Name = text:create({
	font =   motif.select_info.p1_name_font[1],
	bank =   motif.select_info.p1_name_font[2],
	align =  motif.select_info.p1_name_font[3],
	text =   '',
	x =      0,
	y =      0,
	scaleX = motif.select_info.p1_name_font_scale[1],
	scaleY = motif.select_info.p1_name_font_scale[2],
	r =      motif.select_info.p1_name_font[4],
	g =      motif.select_info.p1_name_font[5],
	b =      motif.select_info.p1_name_font[6],
	src =    motif.select_info.p1_name_font[7],
	dst =    motif.select_info.p1_name_font[8],
	height = motif.select_info.p1_name_font_height,
})
local txt_p2Name = text:create({
	font =   motif.select_info.p2_name_font[1],
	bank =   motif.select_info.p2_name_font[2],
	align =  motif.select_info.p2_name_font[3],
	text =   '',
	x =      0,
	y =      0,
	scaleX = motif.select_info.p2_name_font_scale[1],
	scaleY = motif.select_info.p2_name_font_scale[2],
	r =      motif.select_info.p2_name_font[4],
	g =      motif.select_info.p2_name_font[5],
	b =      motif.select_info.p2_name_font[6],
	src =    motif.select_info.p2_name_font[7],
	dst =    motif.select_info.p2_name_font[8],
	height = motif.select_info.p2_name_font_height,
})

local p1RandomCount = motif.select_info.cell_random_switchtime
local p1RandomPortrait = main.t_randomChars[math.random(1, #main.t_randomChars)]
local p2RandomCount = motif.select_info.cell_random_switchtime
local p2RandomPortrait = main.t_randomChars[math.random(1, #main.t_randomChars)]

function start.f_selectScreen()
	if selScreenEnd then
		return true
	end
	main.f_bgReset(motif.selectbgdef.bg)
	main.f_playBGM(true, motif.music.select_bgm, motif.music.select_bgm_loop, motif.music.select_bgm_volume, motif.music.select_bgm_loopstart, motif.music.select_bgm_loopend)
	local t_enemySelected = {}
	local numChars = p2NumChars
	if main.coop and matchNo > 0 then --coop swap after first match
		t_enemySelected = main.f_tableCopy(start.t_p2Selected)
		p1NumChars = 1
		p2NumChars = 1
		start.t_p2Selected = {}
		p2SelEnd = false
	end
	timerSelect = 0
	while not selScreenEnd do
		if esc() or main.f_input(main.t_players, {'m'}) then
			return false
		end
		--draw clearcolor
		clearColor(motif.selectbgdef.bgclearcolor[1], motif.selectbgdef.bgclearcolor[2], motif.selectbgdef.bgclearcolor[3])
		--draw layerno = 0 backgrounds
		bgDraw(motif.selectbgdef.bg, false)
		--draw title
		main.txt_mainSelect:draw()
		if p1Cell then
			--draw p1 portrait
			local t_portrait = {}
			if #start.t_p1Selected < p1NumChars then
				if start.f_selGrid(p1Cell + 1).char == 'randomselect' or start.f_selGrid(p1Cell + 1).hidden == 3 then
					if p1RandomCount < motif.select_info.cell_random_switchtime then
						p1RandomCount = p1RandomCount + 1
					else
						if motif.select_info.random_move_snd_cancel == 1 then
							sndStop(motif.files.snd_data, motif.select_info.p1_random_move_snd[1], motif.select_info.p1_random_move_snd[2])
						end
						sndPlay(motif.files.snd_data, motif.select_info.p1_random_move_snd[1], motif.select_info.p1_random_move_snd[2])
						p1RandomPortrait = main.t_randomChars[math.random(1, #main.t_randomChars)]
						p1RandomCount = 0
					end
					t_portrait[1] = p1RandomPortrait
				elseif start.f_selGrid(p1Cell + 1).hidden ~= 2 then
					t_portrait[1] = start.f_selGrid(p1Cell + 1).char_ref
				end
			end
			for i = #start.t_p1Selected, 1, -1 do
				if #t_portrait < motif.select_info.p1_face_num then
					table.insert(t_portrait, start.t_p1Selected[i].ref)
				end
			end
			t_portrait = main.f_tableReverse(t_portrait)
			for n = #t_portrait, 1, -1 do
				drawPortraitChar(
					t_portrait[n],
					motif.select_info.p1_face_spr[1],
					motif.select_info.p1_face_spr[2],
					motif.select_info.p1_face_offset[1] + motif.select_info['p1_c' .. n .. '_face_offset'][1] + (n - 1) * motif.select_info.p1_face_spacing[1] + main.f_alignOffset(motif.select_info.p1_face_facing),
					motif.select_info.p1_face_offset[2] + motif.select_info['p1_c' .. n .. '_face_offset'][2] + (n - 1) * motif.select_info.p1_face_spacing[2],
					motif.select_info.p1_face_facing * motif.select_info.p1_face_scale[1] * motif.select_info['p1_c' .. n .. '_face_scale'][1],
					motif.select_info.p1_face_scale[2] * motif.select_info['p1_c' .. n .. '_face_scale'][2],
					motif.select_info.p1_face_window[1],
					motif.select_info.p1_face_window[2],
					motif.select_info.p1_face_window[3],
					motif.select_info.p1_face_window[4]
				)
			end
		end
		if p2Cell then
			--draw p2 portrait
			local t_portrait = {}
			if #start.t_p2Selected < p2NumChars then
				if start.f_selGrid(p2Cell + 1).char == 'randomselect' or start.f_selGrid(p2Cell + 1).hidden == 3 then
					if p2RandomCount < motif.select_info.cell_random_switchtime then
						p2RandomCount = p2RandomCount + 1
					else
						if motif.select_info.random_move_snd_cancel == 1 then
							sndStop(motif.files.snd_data, motif.select_info.p2_random_move_snd[1], motif.select_info.p2_random_move_snd[2])
						end
						sndPlay(motif.files.snd_data, motif.select_info.p2_random_move_snd[1], motif.select_info.p2_random_move_snd[2])
						p2RandomPortrait = main.t_randomChars[math.random(1, #main.t_randomChars)]
						p2RandomCount = 0
					end
					t_portrait[1] = p2RandomPortrait
				elseif start.f_selGrid(p2Cell + 1).hidden ~= 2 then
					t_portrait[1] = start.f_selGrid(p2Cell + 1).char_ref
				end
			end
			for i = #start.t_p2Selected, 1, -1 do
				if #t_portrait < motif.select_info.p2_face_num then
					table.insert(t_portrait, start.t_p2Selected[i].ref)
				end
			end
			t_portrait = main.f_tableReverse(t_portrait)
			for n = #t_portrait, 1, -1 do
				drawPortraitChar(
					t_portrait[n],
					motif.select_info.p2_face_spr[1],
					motif.select_info.p2_face_spr[2],
					motif.select_info.p2_face_offset[1] + motif.select_info['p2_c' .. n .. '_face_offset'][1] + (n - 1) * motif.select_info.p2_face_spacing[1] + main.f_alignOffset(motif.select_info.p2_face_facing),
					motif.select_info.p2_face_offset[2] + motif.select_info['p2_c' .. n .. '_face_offset'][2] + (n - 1) * motif.select_info.p2_face_spacing[2],
					motif.select_info.p2_face_facing * motif.select_info.p2_face_scale[1] * motif.select_info['p2_c' .. n .. '_face_scale'][1],
					motif.select_info.p2_face_scale[2] * motif.select_info['p2_c' .. n .. '_face_scale'][2],
					motif.select_info.p2_face_window[1],
					motif.select_info.p2_face_window[2],
					motif.select_info.p2_face_window[3],
					motif.select_info.p2_face_window[4]
				)
			end
		end
		--draw cell art
		for i = 1, #start.t_drawFace do
			--P1 side check before drawing
			if start.t_drawFace[i].d <= 2 then
				--draw cell background
				main.f_animPosDraw(
					motif.select_info.cell_bg_data,
					start.t_drawFace[i].x1,
					start.t_drawFace[i].y1,
					(motif.select_info['cell_' .. start.t_drawFace[i].col .. '_' .. start.t_drawFace[i].row .. '_facing'] or 1)
				)
				--draw random cell
				if start.t_drawFace[i].d == 1 then
					main.f_animPosDraw(
						motif.select_info.cell_random_data,
						start.t_drawFace[i].x1 + motif.select_info.portrait_offset[1],
						start.t_drawFace[i].y1 + motif.select_info.portrait_offset[2],
						(motif.select_info['cell_' .. start.t_drawFace[i].col .. '_' .. start.t_drawFace[i].row .. '_facing'] or 1)
					)
				--draw face cell
				elseif start.t_drawFace[i].d == 2 then
					drawPortraitChar(
						start.t_drawFace[i].p1,
						motif.select_info.portrait_spr[1],
						motif.select_info.portrait_spr[2],
						start.t_drawFace[i].x1 + motif.select_info.portrait_offset[1],
						start.t_drawFace[i].y1 + motif.select_info.portrait_offset[2],
						motif.select_info.portrait_scale[1] * (motif.select_info['cell_' .. start.t_drawFace[i].col .. '_' .. start.t_drawFace[i].row .. '_facing'] or 1),
						motif.select_info.portrait_scale[2]
					)
				end
			end
			--P2 side check before drawing (double select only)
			if main.p2Faces and motif.select_info.doubleselect_enabled == 1 and start.t_drawFace[i].d >= 10 then
				--draw cell background
				main.f_animPosDraw(
					motif.select_info.cell_bg_data,
					start.t_drawFace[i].x2,
					start.t_drawFace[i].y2,
					(motif.select_info['cell_' .. start.t_drawFace[i].col .. '_' .. start.t_drawFace[i].row .. '_facing'] or 1)
				)
				--draw random cell
				if start.t_drawFace[i].d == 11 then
					main.f_animPosDraw(
						motif.select_info.cell_random_data,
						start.t_drawFace[i].x2 + motif.select_info.portrait_offset[1],
						start.t_drawFace[i].y2 + motif.select_info.portrait_offset[2],
						(motif.select_info['cell_' .. start.t_drawFace[i].col .. '_' .. start.t_drawFace[i].row .. '_facing'] or 1)
					)
				--draw face cell
				elseif start.t_drawFace[i].d == 12 then
					drawPortraitChar(
						start.t_drawFace[i].p2,
						motif.select_info.portrait_spr[1],
						motif.select_info.portrait_spr[2],
						start.t_drawFace[i].x2 + motif.select_info.portrait_offset[1],
						start.t_drawFace[i].y2 + motif.select_info.portrait_offset[2],
						motif.select_info.portrait_scale[1] * (motif.select_info['cell_' .. start.t_drawFace[i].col .. '_' .. start.t_drawFace[i].row .. '_facing'] or 1),
						motif.select_info.portrait_scale[2]
					)
				end
			end
		end
		--drawFace(p1FaceX, p1FaceY, p1FaceOffset)
		--if main.p2Faces and motif.select_info.doubleselect_enabled == 1 then
		--	drawFace(p2FaceX, p2FaceY, p2FaceOffset)
		--end
		--draw p1 done cursor
		for i = 1, #start.t_p1Selected do
			if start.t_p1Selected[i].cursor ~= nil then
				main.f_animPosDraw(
					motif.select_info.p1_cursor_done_data,
					start.t_p1Selected[i].cursor[1],
					start.t_p1Selected[i].cursor[2],
					start.t_p1Selected[i].cursor[4]
				)
			end
		end
		--draw p2 done cursor
		for i = 1, #start.t_p2Selected do
			if start.t_p2Selected[i].cursor ~= nil then
				main.f_animPosDraw(
					motif.select_info.p2_cursor_done_data,
					start.t_p2Selected[i].cursor[1],
					start.t_p2Selected[i].cursor[2],
					start.t_p2Selected[i].cursor[4]
				)
			end
		end
		--Player1 team menu
		if not p1TeamEnd then
			start.f_p1TeamMenu()
		--Player1 select
		elseif main.t_pIn[1] > 0 or main.p1Char ~= nil then
			start.f_p1SelectMenu()
		end
		--Player2 team menu
		if not p2TeamEnd then
			start.f_p2TeamMenu()
		--Player2 select
		elseif main.t_pIn[2] > 0 or main.p2Char ~= nil then
			start.f_p2SelectMenu()
		end
		if p1Cell then
			--draw p1 name
			local t_name = {}
			for i = 1, #start.t_p1Selected do
				table.insert(t_name, {['ref'] = start.t_p1Selected[i].ref})
			end
			if #start.t_p1Selected < p1NumChars then
				if start.f_selGrid(p1Cell + 1).char_ref ~= nil then
					table.insert(t_name, {['ref'] = start.f_selGrid(p1Cell + 1).char_ref})
				end
			end
			start.f_drawName(
				t_name,
				txt_p1Name,
				motif.select_info.p1_name_font,
				motif.select_info.p1_name_offset[1],
				motif.select_info.p1_name_offset[2],
				motif.select_info.p1_name_font_scale[1],
				motif.select_info.p1_name_font_scale[2],
				motif.select_info.p1_name_font_height,
				motif.select_info.p1_name_spacing[1],
				motif.select_info.p1_name_spacing[2]
			)
		end
		if p2Cell then
			--draw p2 name
			local t_name = {}
			for i = 1, #start.t_p2Selected do
				table.insert(t_name, {['ref'] = start.t_p2Selected[i].ref})
			end
			if #start.t_p2Selected < p2NumChars then
				if start.f_selGrid(p2Cell + 1).char_ref ~= nil then
					table.insert(t_name, {['ref'] = start.f_selGrid(p2Cell + 1).char_ref})
				end
			end
			start.f_drawName(
				t_name,
				txt_p2Name,
				motif.select_info.p2_name_font,
				motif.select_info.p2_name_offset[1],
				motif.select_info.p2_name_offset[2],
				motif.select_info.p2_name_font_scale[1],
				motif.select_info.p2_name_font_scale[2],
				motif.select_info.p2_name_font_height,
				motif.select_info.p2_name_spacing[1],
				motif.select_info.p2_name_spacing[2]
			)
		end
		--draw timer
		if motif.select_info.timer_enabled == 1 and p1TeamEnd and (p2TeamEnd or not main.p2SelectMenu) then
			local num = math.floor((motif.select_info.timer_count * motif.select_info.timer_framespercount - timerSelect + motif.select_info.timer_displaytime) / motif.select_info.timer_framespercount + 0.5)
			if num <= -1 then
				timerSelect = -1
				txt_timerSelect:update({text = 0})
			else
				timerSelect = timerSelect + 1
				txt_timerSelect:update({text = math.max(0, num)})
			end
			if timerSelect >= motif.select_info.timer_displaytime then
				txt_timerSelect:draw()
			end
		end
		--draw record text
		for i = 1, #t_recordText do
			txt_recordSelect:update({
				text = t_recordText[i],
				y = motif.select_info.record_offset[2] + main.f_ySpacing(motif.select_info, 'record_font') * (i - 1),
			})
			txt_recordSelect:draw()
		end
		--team and character selection complete
		if p1SelEnd and p2SelEnd and p1TeamEnd and p2TeamEnd then
			p1RestoreCursor = true
			p2RestoreCursor = true
			if main.stageMenu and not stageEnd then --Stage select
				start.f_stageMenu()
			elseif main.coop and not coopEnd then
				coopEnd = true
				p2TeamEnd = false
			elseif fadeType == 'fadein' then
				main.fadeStart = getFrameCount()
				fadeType = 'fadeout'
			end
		end
		--draw layerno = 1 backgrounds
		bgDraw(motif.selectbgdef.bg, true)
		--draw fadein / fadeout
		main.fadeActive = fadeColor(
			fadeType,
			main.fadeStart,
			motif.select_info[fadeType .. '_time'],
			motif.select_info[fadeType .. '_col'][1],
			motif.select_info[fadeType .. '_col'][2],
			motif.select_info[fadeType .. '_col'][3]
		)
		--frame transition
		if main.fadeActive then
			commandBufReset(main.t_cmd[1])
		elseif fadeType == 'fadeout' then
			commandBufReset(main.t_cmd[1])
			selScreenEnd = true
			break --skip last frame rendering
		else
			main.f_cmdInput()
		end
		main.f_refresh()
	end
	if matchNo == 0 then --team mode set
		if main.coop then --coop swap before first match
			p1NumChars = 2
			start.t_p1Selected[2] = {ref = start.t_p2Selected[1].ref, pal = start.t_p2Selected[1].pal}
			start.t_p2Selected = {}
		end
		setTeamMode(1, start.p1TeamMode, p1NumChars)
		setTeamMode(2, start.p2TeamMode, p2NumChars)
	elseif main.coop then --coop swap after first match
		p1NumChars = 2
		p2NumChars = numChars
		start.t_p1Selected[2] = {ref = start.t_p2Selected[1].ref, pal = start.t_p2Selected[1].pal}
		start.t_p2Selected = t_enemySelected
	end
	return true
end

--;===========================================================
--; PLAYER 1 TEAM MENU
--;===========================================================
local txt_p1TeamSelfTitle = text:create({
	font =   motif.select_info.p1_teammenu_selftitle_font[1],
	bank =   motif.select_info.p1_teammenu_selftitle_font[2],
	align =  motif.select_info.p1_teammenu_selftitle_font[3],
	text =   motif.select_info.p1_teammenu_selftitle_text,
	x =      motif.select_info.p1_teammenu_pos[1] + motif.select_info.p1_teammenu_selftitle_offset[1],
	y =      motif.select_info.p1_teammenu_pos[2] + motif.select_info.p1_teammenu_selftitle_offset[2],
	scaleX = motif.select_info.p1_teammenu_selftitle_font_scale[1],
	scaleY = motif.select_info.p1_teammenu_selftitle_font_scale[2],
	r =      motif.select_info.p1_teammenu_selftitle_font[4],
	g =      motif.select_info.p1_teammenu_selftitle_font[5],
	b =      motif.select_info.p1_teammenu_selftitle_font[6],
	src =    motif.select_info.p1_teammenu_selftitle_font[7],
	dst =    motif.select_info.p1_teammenu_selftitle_font[8],
	height = motif.select_info.p1_teammenu_selftitle_font_height,
})
local txt_p1TeamEnemyTitle = text:create({
	font =   motif.select_info.p1_teammenu_enemytitle_font[1],
	bank =   motif.select_info.p1_teammenu_enemytitle_font[2],
	align =  motif.select_info.p1_teammenu_enemytitle_font[3],
	text =   motif.select_info.p1_teammenu_enemytitle_text,
	x =      motif.select_info.p1_teammenu_pos[1] + motif.select_info.p1_teammenu_enemytitle_offset[1],
	y =      motif.select_info.p1_teammenu_pos[2] + motif.select_info.p1_teammenu_enemytitle_offset[2],
	scaleX = motif.select_info.p1_teammenu_enemytitle_font_scale[1],
	scaleY = motif.select_info.p1_teammenu_enemytitle_font_scale[2],
	r =      motif.select_info.p1_teammenu_enemytitle_font[4],
	g =      motif.select_info.p1_teammenu_enemytitle_font[5],
	b =      motif.select_info.p1_teammenu_enemytitle_font[6],
	src =    motif.select_info.p1_teammenu_enemytitle_font[7],
	dst =    motif.select_info.p1_teammenu_enemytitle_font[8],
	height = motif.select_info.p1_teammenu_enemytitle_font_height,
})
local p1TeamActiveCount = 0
local p1TeamActiveType = 'p1_teammenu_item_active'

local t_p1TeamMenu = {
	{data = text:create({}), itemname = 'single', displayname = motif.select_info.teammenu_itemname_single, mode = 0, chars = 1},
	{data = text:create({}), itemname = 'simul', displayname = motif.select_info.teammenu_itemname_simul, mode = 1, chars = p1NumSimul},
	{data = text:create({}), itemname = 'turns', displayname = motif.select_info.teammenu_itemname_turns, mode = 2, chars = p1NumTurns},
	{data = text:create({}), itemname = 'tag', displayname = motif.select_info.teammenu_itemname_tag, mode = 3, chars = p1NumTag},
	{data = text:create({}), itemname = 'ratio', displayname = motif.select_info.teammenu_itemname_ratio, mode = 2, chars = p1NumRatio},
}
t_p1TeamMenuSorted = main.f_tableClean(t_p1TeamMenu, main.t_sort.select_info)

function start.f_p1TeamMenu()
	local t = {}
	for k, v in ipairs(t_p1TeamMenuSorted) do
		if main.p1TeamMenu[v.itemname] then
			table.insert(t, v)
		end
	end
	if #t == 0 then --all valid team modes disabled by screenpack
		for k, v in ipairs(t_p1TeamMenu) do
			if main.p1TeamMenu[v.itemname] then
				table.insert(t, v)
				break
			end
		end
	end
	if #t == 1 then --only 1 team mode available, skip selection
		start.p1TeamMode = t[1].mode
		if t[1].itemname.ratio ~= nil then
			p1NumRatio = t[1].chars
			if p1NumRatio <= 3 then
				p1NumChars = 3
			elseif p1NumRatio <= 6 then
				p1NumChars = 2
			else
				p1NumChars = 1
			end
			p1Ratio = true
		else
			p1NumChars = t[1].chars
		end
		setTeamMode(1, start.p1TeamMode, p1NumChars)
		p1TeamEnd = true
	else
		--Calculate team cursor position
		if p1TeamMenu > #t then
			p1TeamMenu = 1
		end
		if main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_previous)) then
			if p1TeamMenu > 1 then
				sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_move_snd[1], motif.select_info.p1_teammenu_move_snd[2])
				p1TeamMenu = p1TeamMenu - 1
			elseif motif.select_info.teammenu_move_wrapping == 1 then
				sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_move_snd[1], motif.select_info.p1_teammenu_move_snd[2])
				p1TeamMenu = #t
			end
		elseif main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_next)) then
			if p1TeamMenu < #t then
				sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_move_snd[1], motif.select_info.p1_teammenu_move_snd[2])
				p1TeamMenu = p1TeamMenu + 1
			elseif motif.select_info.teammenu_move_wrapping == 1 then
				sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_move_snd[1], motif.select_info.p1_teammenu_move_snd[2])
				p1TeamMenu = 1
			end
		elseif not main.coop then
			if t[p1TeamMenu].itemname == 'simul' then
				if main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
					if p1NumSimul > config.NumSimul[1] then
						sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
						p1NumSimul = p1NumSimul - 1
					end
				elseif main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
					if p1NumSimul < config.NumSimul[2] then
						sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
						p1NumSimul = p1NumSimul + 1
					end
				end
			elseif t[p1TeamMenu].itemname == 'turns' then
				if main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
					if p1NumTurns > config.NumTurns[1] then
						sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
						p1NumTurns = p1NumTurns - 1
					end
				elseif main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
					if p1NumTurns < config.NumTurns[2] then
						sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
						p1NumTurns = p1NumTurns + 1
					end
				end
			elseif t[p1TeamMenu].itemname == 'tag' then
				if main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
					if p1NumTag > config.NumTag[1] then
						sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
						p1NumTag = p1NumTag - 1
					end
				elseif main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
					if p1NumTag < config.NumTag[2] then
						sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
						p1NumTag = p1NumTag + 1
					end
				end
			elseif t[p1TeamMenu].itemname == 'ratio' then
				if main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
					sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
					if p1NumRatio > 1 then
						p1NumRatio = p1NumRatio - 1
					else
						p1NumRatio = 7
					end
				elseif main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
					sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_value_snd[1], motif.select_info.p1_teammenu_value_snd[2])
					if p1NumRatio < 7 then
						p1NumRatio = p1NumRatio + 1
					else
						p1NumRatio = 1
					end
				end
			end
		end
		--Draw team background
		main.t_animUpdate[motif.select_info.p1_teammenu_bg_data] = 1
		animDraw(motif.select_info.p1_teammenu_bg_data)
		--Draw team active element background
		main.t_animUpdate[motif.select_info['p1_teammenu_bg_' .. t[p1TeamMenu].itemname .. '_data']] = 1
		animDraw(motif.select_info['p1_teammenu_bg_' .. t[p1TeamMenu].itemname .. '_data'])
		--Draw team cursor
		main.f_animPosDraw(
			motif.select_info.p1_teammenu_item_cursor_data,
			(p1TeamMenu - 1) * motif.select_info.p1_teammenu_item_spacing[1],
			(p1TeamMenu - 1) * motif.select_info.p1_teammenu_item_spacing[2]
		)
		--Draw team title
		main.t_animUpdate[motif.select_info.p1_teammenu_selftitle_data] = 1
		animDraw(motif.select_info.p1_teammenu_selftitle_data)
		txt_p1TeamSelfTitle:draw()
		for i = 1, #t do
			if i == p1TeamMenu then
				if p1TeamActiveCount < 2 then --delay change
					p1TeamActiveCount = p1TeamActiveCount + 1
				elseif p1TeamActiveType == 'p1_teammenu_item_active' then
					p1TeamActiveType = 'p1_teammenu_item_active2'
					p1TeamActiveCount = 0
				else
					p1TeamActiveType = 'p1_teammenu_item_active'
					p1TeamActiveCount = 0
				end
				--Draw team active font
				t[i].data:update({
					font =   motif.select_info[p1TeamActiveType .. '_font'][1],
					bank =   motif.select_info[p1TeamActiveType .. '_font'][2],
					align =  motif.select_info[p1TeamActiveType .. '_font'][3], --p1_teammenu_item_font (winmugen ignores active font facing? Fixed in mugen 1.0)
					text =   t[i].displayname,
					x =      motif.select_info.p1_teammenu_pos[1] + motif.select_info.p1_teammenu_item_offset[1] + motif.select_info.p1_teammenu_item_spacing[1] * (i - 1),
					y =      motif.select_info.p1_teammenu_pos[2] + motif.select_info.p1_teammenu_item_offset[2] + motif.select_info.p1_teammenu_item_spacing[2] * (i - 1),
					scaleX = motif.select_info[p1TeamActiveType .. '_font_scale'][1],
					scaleY = motif.select_info[p1TeamActiveType .. '_font_scale'][2],
					r =      motif.select_info[p1TeamActiveType .. '_font'][4],
					g =      motif.select_info[p1TeamActiveType .. '_font'][5],
					b =      motif.select_info[p1TeamActiveType .. '_font'][6],
					src =    motif.select_info[p1TeamActiveType .. '_font'][7],
					dst =    motif.select_info[p1TeamActiveType .. '_font'][8],
					height = motif.select_info[p1TeamActiveType .. '_font_height'],
				})
				t[i].data:draw()
			else
				--Draw team not active font
				t[i].data:update({
					font =   motif.select_info.p1_teammenu_item_font[1],
					bank =   motif.select_info.p1_teammenu_item_font[2],
					align =  motif.select_info.p1_teammenu_item_font[3], --p1_teammenu_item_font (winmugen ignores active font facing? Fixed in mugen 1.0)
					text =   t[i].displayname,
					x =      motif.select_info.p1_teammenu_pos[1] + motif.select_info.p1_teammenu_item_offset[1] + motif.select_info.p1_teammenu_item_spacing[1] * (i - 1),
					y =      motif.select_info.p1_teammenu_pos[2] + motif.select_info.p1_teammenu_item_offset[2] + motif.select_info.p1_teammenu_item_spacing[2] * (i - 1),
					scaleX = motif.select_info.p1_teammenu_item_font_scale[1],
					scaleY = motif.select_info.p1_teammenu_item_font_scale[2],
					r =      motif.select_info.p1_teammenu_item_font[4],
					g =      motif.select_info.p1_teammenu_item_font[5],
					b =      motif.select_info.p1_teammenu_item_font[6],
					src =    motif.select_info.p1_teammenu_item_font[7],
					dst =    motif.select_info.p1_teammenu_item_font[8],
					height = motif.select_info.p1_teammenu_item_font_height,
				})
				t[i].data:draw()
			end
			--Draw team icons
			if not main.coop then
				if t[i].itemname == 'simul' then
					for j = 1, config.NumSimul[2] do
						if j <= p1NumSimul then
							main.f_animPosDraw(
								motif.select_info.p1_teammenu_value_icon_data,
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[1],
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[2]
							)
						else
							main.f_animPosDraw(
								motif.select_info.p1_teammenu_value_empty_icon_data,
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[1],
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[2]
							)
						end
					end
				elseif t[i].itemname == 'turns' then
					for j = 1, config.NumTurns[2] do
						if j <= p1NumTurns then
							main.f_animPosDraw(
								motif.select_info.p1_teammenu_value_icon_data,
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[1],
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[2]
							)
						else
							main.f_animPosDraw(
								motif.select_info.p1_teammenu_value_empty_icon_data,
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[1],
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[2]
							)
						end
					end
				elseif t[i].itemname == 'tag' then
					for j = 1, config.NumTag[2] do
						if j <= p1NumTag then
							main.f_animPosDraw(
								motif.select_info.p1_teammenu_value_icon_data,
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[1],
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[2]
							)
						else
							main.f_animPosDraw(
								motif.select_info.p1_teammenu_value_empty_icon_data,
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[1],
								(i - 1) * motif.select_info.p1_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p1_teammenu_value_spacing[2]
							)
						end
					end
				elseif t[i].itemname == 'ratio' and p1TeamMenu == i then
					main.t_animUpdate[motif.select_info['p1_teammenu_ratio' .. p1NumRatio .. '_icon_data']] = 1
					animDraw(motif.select_info['p1_teammenu_ratio' .. p1NumRatio .. '_icon_data'])
				end
			end
		end
		--Confirmed team selection
		if main.f_input({1}, main.f_extractKeys(motif.select_info.teammenu_key_accept)) then
			sndPlay(motif.files.snd_data, motif.select_info.p1_teammenu_done_snd[1], motif.select_info.p1_teammenu_done_snd[2])
			if main.coop then
				start.p1TeamMode = t[p1TeamMenu].mode
				p1NumChars = 1
			elseif t[p1TeamMenu].itemname == 'single' then
				start.p1TeamMode = t[p1TeamMenu].mode
				p1NumChars = 1
			elseif t[p1TeamMenu].itemname == 'simul' then
				start.p1TeamMode = t[p1TeamMenu].mode
				p1NumChars = p1NumSimul
			elseif t[p1TeamMenu].itemname == 'turns' then
				start.p1TeamMode = t[p1TeamMenu].mode
				p1NumChars = p1NumTurns
			elseif t[p1TeamMenu].itemname == 'tag' then
				start.p1TeamMode = t[p1TeamMenu].mode
				p1NumChars = p1NumTag
			elseif t[p1TeamMenu].itemname == 'ratio' then
				start.p1TeamMode = t[p1TeamMenu].mode
				if p1NumRatio <= 3 then
					p1NumChars = 3
				elseif p1NumRatio <= 6 then
					p1NumChars = 2
				else
					p1NumChars = 1
				end
				p1Ratio = true
			end
			p1TeamEnd = true
			--main.f_cmdInput()
		end
	end
end

--;===========================================================
--; PLAYER 2 TEAM MENU
--;===========================================================
local txt_p2TeamSelfTitle = text:create({
	font =   motif.select_info.p2_teammenu_selftitle_font[1],
	bank =   motif.select_info.p2_teammenu_selftitle_font[2],
	align =  motif.select_info.p2_teammenu_selftitle_font[3],
	text =   motif.select_info.p2_teammenu_selftitle_text,
	x =      motif.select_info.p2_teammenu_pos[1] + motif.select_info.p2_teammenu_selftitle_offset[1],
	y =      motif.select_info.p2_teammenu_pos[2] + motif.select_info.p2_teammenu_selftitle_offset[2],
	scaleX = motif.select_info.p2_teammenu_selftitle_font_scale[1],
	scaleY = motif.select_info.p2_teammenu_selftitle_font_scale[2],
	r =      motif.select_info.p2_teammenu_selftitle_font[4],
	g =      motif.select_info.p2_teammenu_selftitle_font[5],
	b =      motif.select_info.p2_teammenu_selftitle_font[6],
	src =    motif.select_info.p2_teammenu_selftitle_font[7],
	dst =    motif.select_info.p2_teammenu_selftitle_font[8],
	height = motif.select_info.p2_teammenu_selftitle_font_height,
})
local txt_p2TeamEnemyTitle = text:create({
	font =   motif.select_info.p2_teammenu_enemytitle_font[1],
	bank =   motif.select_info.p2_teammenu_enemytitle_font[2],
	align =  motif.select_info.p2_teammenu_enemytitle_font[3],
	text =   motif.select_info.p2_teammenu_enemytitle_text,
	x =      motif.select_info.p2_teammenu_pos[1] + motif.select_info.p2_teammenu_enemytitle_offset[1],
	y =      motif.select_info.p2_teammenu_pos[2] + motif.select_info.p2_teammenu_enemytitle_offset[2],
	scaleX = motif.select_info.p2_teammenu_enemytitle_font_scale[1],
	scaleY = motif.select_info.p2_teammenu_enemytitle_font_scale[2],
	r =      motif.select_info.p2_teammenu_enemytitle_font[4],
	g =      motif.select_info.p2_teammenu_enemytitle_font[5],
	b =      motif.select_info.p2_teammenu_enemytitle_font[6],
	src =    motif.select_info.p2_teammenu_enemytitle_font[7],
	dst =    motif.select_info.p2_teammenu_enemytitle_font[8],
	height = motif.select_info.p2_teammenu_enemytitle_font_height,
})
local p2TeamActiveCount = 0
local p2TeamActiveType = 'p2_teammenu_item_active'

local t_p2TeamMenu = {
	{data = text:create({}), itemname = 'single', displayname = motif.select_info.teammenu_itemname_single, mode = 0, chars = 1},
	{data = text:create({}), itemname = 'simul', displayname = motif.select_info.teammenu_itemname_simul, mode = 1, chars = p2NumSimul},
	{data = text:create({}), itemname = 'turns', displayname = motif.select_info.teammenu_itemname_turns, mode = 2, chars = p2NumTurns},
	{data = text:create({}), itemname = 'tag', displayname = motif.select_info.teammenu_itemname_tag, mode = 3, chars = p2NumTag},
	{data = text:create({}), itemname = 'ratio', displayname = motif.select_info.teammenu_itemname_ratio, mode = 2, chars = p2NumRatio},
}
t_p2TeamMenuSorted = main.f_tableClean(t_p2TeamMenu, main.t_sort.select_info)

function start.f_p2TeamMenu()
	if main.coop and not p1TeamEnd then
		return
	end
	local t = {}
	for k, v in ipairs(t_p2TeamMenuSorted) do
		if main.p2TeamMenu[v.itemname] then
			table.insert(t, v)
		end
	end
	if #t == 0 then --all valid team modes disabled by screenpack
		for k, v in ipairs(t_p2TeamMenu) do
			if main.p2TeamMenu[v.itemname] then
				table.insert(t, v)
				break
			end
		end
	end
	if #t == 1 then --only 1 team mode available, skip selection
		start.p2TeamMode = t[1].mode
		if t[1].itemname.ratio ~= nil then
			p2NumRatio = t[1].chars
			if p2NumRatio <= 3 then
				p2NumChars = 3
			elseif p2NumRatio <= 6 then
				p2NumChars = 2
			else
				p2NumChars = 1
			end
			p2Ratio = true
		else
			p2NumChars = t[1].chars
		end
		setTeamMode(2, start.p2TeamMode, p2NumChars)
		p2TeamEnd = true
	else
		--Command swap
		local cmd = 2
		if main.coop then
			cmd = 1
		end
		--Calculate team cursor position
		if p2TeamMenu > #t then
			p2TeamMenu = 1
		end
		if main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_previous)) then
			if p2TeamMenu > 1 then
				sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_move_snd[1], motif.select_info.p2_teammenu_move_snd[2])
				p2TeamMenu = p2TeamMenu - 1
			elseif motif.select_info.teammenu_move_wrapping == 1 then
				sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_move_snd[1], motif.select_info.p2_teammenu_move_snd[2])
				p2TeamMenu = #t
			end
		elseif main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_next)) then
			if p2TeamMenu < #t then
				sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_move_snd[1], motif.select_info.p2_teammenu_move_snd[2])
				p2TeamMenu = p2TeamMenu + 1
			elseif motif.select_info.teammenu_move_wrapping == 1 then
				sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_move_snd[1], motif.select_info.p2_teammenu_move_snd[2])
				p2TeamMenu = 1
			end
		elseif t[p2TeamMenu].itemname == 'simul' then
			if main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
				if p2NumSimul > config.NumSimul[1] then
					sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
					p2NumSimul = p2NumSimul - 1
				end
			elseif main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
				if p2NumSimul < config.NumSimul[2] then
					sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
					p2NumSimul = p2NumSimul + 1
				end
			end
		elseif t[p2TeamMenu].itemname == 'turns' then
			if main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
				if p2NumTurns > config.NumTurns[1] then
					sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
					p2NumTurns = p2NumTurns - 1
				end
			elseif main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
				if p2NumTurns < config.NumTurns[2] then
					sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
					p2NumTurns = p2NumTurns + 1
				end
			end
		elseif t[p2TeamMenu].itemname == 'tag' then
			if main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_add)) then
				if p2NumTag > config.NumTag[1] then
					sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
					p2NumTag = p2NumTag - 1
				end
			elseif main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) then
				if p2NumTag < config.NumTag[2] then
					sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
					p2NumTag = p2NumTag + 1
				end
			end
		elseif t[p2TeamMenu].itemname == 'ratio' then
			if main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_subtract)) and main.p2SelectMenu then
				sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
				if p2NumRatio > 1 then
					p2NumRatio = p2NumRatio - 1
				else
					p2NumRatio = 7
				end
			elseif main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_add)) and main.p2SelectMenu then
				sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_value_snd[1], motif.select_info.p2_teammenu_value_snd[2])
				if p2NumRatio < 7 then
					p2NumRatio = p2NumRatio + 1
				else
					p2NumRatio = 1
				end
			end
		end
		--Draw team background
		main.t_animUpdate[motif.select_info.p2_teammenu_bg_data] = 1
		animDraw(motif.select_info.p2_teammenu_bg_data)
		--Draw team active element background
		main.t_animUpdate[motif.select_info['p2_teammenu_bg_' .. t[p2TeamMenu].itemname .. '_data']] = 1
		animDraw(motif.select_info['p2_teammenu_bg_' .. t[p2TeamMenu].itemname .. '_data'])
		--Draw team cursor
		main.f_animPosDraw(
			motif.select_info.p2_teammenu_item_cursor_data,
			(p2TeamMenu - 1) * motif.select_info.p2_teammenu_item_spacing[1],
			(p2TeamMenu - 1) * motif.select_info.p2_teammenu_item_spacing[2]
		)
		--Draw team title
		if main.coop or main.t_pIn[2] == 1 then
			main.t_animUpdate[motif.select_info.p2_teammenu_enemytitle_data] = 1
			animDraw(motif.select_info.p2_teammenu_enemytitle_data)
			txt_p2TeamEnemyTitle:draw()
		else
			main.t_animUpdate[motif.select_info.p2_teammenu_selftitle_data] = 1
			animDraw(motif.select_info.p2_teammenu_selftitle_data)
			txt_p2TeamSelfTitle:draw()
		end
		for i = 1, #t do
			if i == p2TeamMenu then
				if p2TeamActiveCount < 2 then --delay change
					p2TeamActiveCount = p2TeamActiveCount + 1
				elseif p2TeamActiveType == 'p2_teammenu_item_active' then
					p2TeamActiveType = 'p2_teammenu_item_active2'
					p2TeamActiveCount = 0
				else
					p2TeamActiveType = 'p2_teammenu_item_active'
					p2TeamActiveCount = 0
				end
				--Draw team active font
				t[i].data:update({
					font =   motif.select_info[p2TeamActiveType .. '_font'][1],
					bank =   motif.select_info[p2TeamActiveType .. '_font'][2],
					align =  motif.select_info[p2TeamActiveType .. '_font'][3], --p2_teammenu_item_font (winmugen ignores active font facing? Fixed in mugen 1.0)
					text =   t[i].displayname,
					x =      motif.select_info.p2_teammenu_pos[1] + motif.select_info.p2_teammenu_item_offset[1] + motif.select_info.p2_teammenu_item_spacing[1] * (i - 1),
					y =      motif.select_info.p2_teammenu_pos[2] + motif.select_info.p2_teammenu_item_offset[2] + motif.select_info.p2_teammenu_item_spacing[2] * (i - 1),
					scaleX = motif.select_info[p2TeamActiveType .. '_font_scale'][1],
					scaleY = motif.select_info[p2TeamActiveType .. '_font_scale'][2],
					r =      motif.select_info[p2TeamActiveType .. '_font'][4],
					g =      motif.select_info[p2TeamActiveType .. '_font'][5],
					b =      motif.select_info[p2TeamActiveType .. '_font'][6],
					src =    motif.select_info[p2TeamActiveType .. '_font'][7],
					dst =    motif.select_info[p2TeamActiveType .. '_font'][8],
					height = motif.select_info[p2TeamActiveType .. '_font_height'],
				})
				t[i].data:draw()
			else
				--Draw team not active font
				t[i].data:update({
					font =   motif.select_info.p2_teammenu_item_font[1],
					bank =   motif.select_info.p2_teammenu_item_font[2],
					align =  motif.select_info.p2_teammenu_item_font[3], --p2_teammenu_item_font (winmugen ignores active font facing? Fixed in mugen 1.0)
					text =   t[i].displayname,
					x =      motif.select_info.p2_teammenu_pos[1] + motif.select_info.p2_teammenu_item_offset[1] + motif.select_info.p2_teammenu_item_spacing[1] * (i - 1),
					y =      motif.select_info.p2_teammenu_pos[2] + motif.select_info.p2_teammenu_item_offset[2] + motif.select_info.p2_teammenu_item_spacing[2] * (i - 1),
					scaleX = motif.select_info.p2_teammenu_item_font_scale[1],
					scaleY = motif.select_info.p2_teammenu_item_font_scale[2],
					r =      motif.select_info.p2_teammenu_item_font[4],
					g =      motif.select_info.p2_teammenu_item_font[5],
					b =      motif.select_info.p2_teammenu_item_font[6],
					src =    motif.select_info.p2_teammenu_item_font[7],
					dst =    motif.select_info.p2_teammenu_item_font[8],
					height = motif.select_info.p2_teammenu_item_font_height,
				})
				t[i].data:draw()
			end
			--Draw team icons
			if t[i].itemname == 'simul' then
				for j = 1, config.NumSimul[2] do
					if j <= p2NumSimul then
						main.f_animPosDraw(
							motif.select_info.p2_teammenu_value_icon_data,
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[1],
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[2]
						)
					else
						main.f_animPosDraw(
							motif.select_info.p2_teammenu_value_empty_icon_data,
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[1],
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[2]
						)
					end
				end
			elseif t[i].itemname == 'turns' then
				for j = 1, config.NumTurns[2] do
					if j <= p2NumTurns then
						main.f_animPosDraw(
							motif.select_info.p2_teammenu_value_icon_data,
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[1],
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[2]
						)
					else
						main.f_animPosDraw(
							motif.select_info.p2_teammenu_value_empty_icon_data,
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[1],
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[2]
						)
					end
				end
			elseif t[i].itemname == 'tag' then
				for j = 1, config.NumTag[2] do
					if j <= p2NumTag then
						main.f_animPosDraw(
							motif.select_info.p2_teammenu_value_icon_data,
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[1],
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[2]
						)
					else
						main.f_animPosDraw(
							motif.select_info.p2_teammenu_value_empty_icon_data,
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[1] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[1],
							(i - 1) * motif.select_info.p2_teammenu_item_spacing[2] + (j - 1) * motif.select_info.p2_teammenu_value_spacing[2]
						)
					end
				end
			elseif t[i].itemname == 'ratio' and p2TeamMenu == i and main.p2SelectMenu then
				main.t_animUpdate[motif.select_info['p2_teammenu_ratio' .. p2NumRatio .. '_icon_data']] = 1
				animDraw(motif.select_info['p2_teammenu_ratio' .. p2NumRatio .. '_icon_data'])
			end
		end
		--Confirmed team selection
		if main.f_input({cmd}, main.f_extractKeys(motif.select_info.teammenu_key_accept)) then
			sndPlay(motif.files.snd_data, motif.select_info.p2_teammenu_done_snd[1], motif.select_info.p2_teammenu_done_snd[2])
			if t[p2TeamMenu].itemname == 'single' then
				start.p2TeamMode = t[p2TeamMenu].mode
				p2NumChars = 1
			elseif t[p2TeamMenu].itemname == 'simul' then
				start.p2TeamMode = t[p2TeamMenu].mode
				p2NumChars = p2NumSimul
			elseif t[p2TeamMenu].itemname == 'turns' then
				start.p2TeamMode = t[p2TeamMenu].mode
				p2NumChars = p2NumTurns
			elseif t[p2TeamMenu].itemname == 'tag' then
				start.p2TeamMode = t[p2TeamMenu].mode
				p2NumChars = p2NumTag
			elseif t[p2TeamMenu].itemname == 'ratio' then
				start.p2TeamMode = t[p2TeamMenu].mode
				if p2NumRatio <= 3 then
					p2NumChars = 3
				elseif p2NumRatio <= 6 then
					p2NumChars = 2
				else
					p2NumChars = 1
				end
				p2Ratio = true
			end
			p2TeamEnd = true
			--main.f_cmdInput()
		end
	end
end

--;===========================================================
--; PLAYER 1 SELECT MENU
--;===========================================================
function start.f_p1SelectMenu()
	--predefined selection
	if main.p1Char ~= nil then
		local t = {}
		for i = 1, #main.p1Char do
			if t[main.p1Char[i]] == nil then
				t[main.p1Char[i]] = ''
			end
			start.t_p1Selected[i] = {
				ref = main.p1Char[i],
				pal = start.f_selectPal(main.p1Char[i])
			}
		end
		p1SelEnd = true
		return
	--manual selection
	elseif not p1SelEnd then
		resetgrid = false
		--cell movement
		if p1RestoreCursor and t_p1Cursor[p1NumChars - #start.t_p1Selected] ~= nil then --restore saved position
			p1SelX = t_p1Cursor[p1NumChars - #start.t_p1Selected][1]
			p1SelY = t_p1Cursor[p1NumChars - #start.t_p1Selected][2]
			p1FaceOffset = t_p1Cursor[p1NumChars - #start.t_p1Selected][3]
			p1RowOffset = t_p1Cursor[p1NumChars - #start.t_p1Selected][4]
			t_p1Cursor[p1NumChars - #start.t_p1Selected] = nil
		else --calculate current position
			p1SelX, p1SelY, p1FaceOffset, p1RowOffset = start.f_cellMovement(p1SelX, p1SelY, 1, p1FaceOffset, p1RowOffset, motif.select_info.p1_cursor_move_snd)
		end
		p1Cell = p1SelX + motif.select_info.columns * p1SelY
		--draw active cursor
		local cursorX = p1FaceX + p1SelX * (motif.select_info.cell_size[1] + motif.select_info.cell_spacing[1]) + start.f_faceOffset(p1SelX + 1, p1SelY + 1, 1)
		local cursorY = p1FaceY + (p1SelY - p1RowOffset) * (motif.select_info.cell_size[2] + motif.select_info.cell_spacing[2]) + start.f_faceOffset(p1SelX + 1, p1SelY + 1, 2)
		if resetgrid == true then
			start.f_resetGrid()
		end
		if start.f_selGrid(p1Cell + 1).hidden ~= 1 then
			main.f_animPosDraw(
				motif.select_info.p1_cursor_active_data,
				cursorX,
				cursorY,
				(motif.select_info['cell_' .. p1SelX + 1 .. '_' .. p1SelY + 1 .. '_facing'] or 1)
			)
		end
		--cell selected
		if start.f_slotSelected(p1Cell + 1, 1, p1SelX, p1SelY) and start.f_selGrid(p1Cell + 1).char ~= nil and start.f_selGrid(p1Cell + 1).hidden ~= 2 then
			sndPlay(motif.files.snd_data, motif.select_info.p1_cursor_done_snd[1], motif.select_info.p1_cursor_done_snd[2])
			local selected = start.f_selGrid(p1Cell + 1).char_ref
			if main.t_selChars[selected + 1].char == 'randomselect' or main.t_selChars[selected + 1].hidden == 3 then
				selected = main.t_randomChars[math.random(1, #main.t_randomChars)]
			end
			start.f_playWave(selected, 'cursor', motif.select_info.p1_select_snd[1], motif.select_info.p1_select_snd[2])
			table.insert(start.t_p1Selected, {
				ref = selected,
				pal = start.f_selectPal(selected, main.f_btnPalNo(main.t_cmd[1])),
				cursor = {cursorX, cursorY, p1RowOffset, (motif.select_info['cell_' .. p1SelX + 1 .. '_' .. p1SelY + 1 .. '_facing'] or 1)},
				ratio = start.f_setRatio(1)
			})
			t_p1Cursor[p1NumChars - #start.t_p1Selected + 1] = {p1SelX, p1SelY, p1FaceOffset, p1RowOffset}
			if #start.t_p1Selected == p1NumChars or (#start.t_p1Selected == 1 and main.coop) then --if all characters have been chosen
				if main.t_pIn[2] == 1 and matchNo == 0 then --if player1 is allowed to select p2 characters
					p2TeamEnd = false
					p2SelEnd = false
					--commandBufReset(main.t_cmd[2])
				end
				p1SelEnd = true
			end
			main.f_cmdInput()
		--select screen timer reached 0
		elseif motif.select_info.timer_enabled == 1 and timerSelect == -1 then
			sndPlay(motif.files.snd_data, motif.select_info.p1_cursor_done_snd[1], motif.select_info.p1_cursor_done_snd[2])
			local selected = start.f_selGrid(p1Cell + 1).char_ref
			local rand = false
			for i = #start.t_p1Selected + 1, p1NumChars do
				if rand or main.t_selChars[selected + 1].char == 'randomselect' or main.t_selChars[selected + 1].hidden == 3 then
					selected = main.t_randomChars[math.random(1, #main.t_randomChars)]
				end
				if not rand then --play it just for the first character
					start.f_playWave(selected, 'cursor', motif.select_info.p1_select_snd[1], motif.select_info.p1_select_snd[2])
				end
				rand = true
				table.insert(start.t_p1Selected, {
					ref = selected,
					pal = start.f_selectPal(selected),
					cursor = {cursorX, cursorY, p1RowOffset, (motif.select_info['cell_' .. p1SelX + 1 .. '_' .. p1SelY + 1 .. '_facing'] or 1)},
					ratio = start.f_setRatio(1)
				})
				t_p1Cursor[p1NumChars - #start.t_p1Selected + 1] = {p1SelX, p1SelY, p1FaceOffset, p1RowOffset}
			end
			if main.p2SelectMenu and main.t_pIn[2] == 1 and matchNo == 0 then --if player1 is allowed to select p2 characters
				start.p2TeamMode = start.p1TeamMode
				p2NumChars = p1NumChars
				setTeamMode(2, start.p2TeamMode, p2NumChars)
				p2Cell = p1Cell
				p2SelX = p1SelX
				p2SelY = p1SelY
				p2FaceOffset = p1FaceOffset
				p2RowOffset = p1RowOffset
				for i = 1, p2NumChars do
					selected = main.t_randomChars[math.random(1, #main.t_randomChars)]
					table.insert(start.t_p2Selected, {
						ref = selected,
						pal = start.f_selectPal(selected),
						cursor = {cursorX, cursorY, p2RowOffset, (motif.select_info['cell_' .. p2SelX + 1 .. '_' .. p2SelY + 1 .. '_facing'] or 1)},
						ratio = start.f_setRatio(2)
					})
					t_p2Cursor[p2NumChars - #start.t_p2Selected + 1] = {p2SelX, p2SelY, p2FaceOffset, p2RowOffset}
				end
			end
			if main.stageMenu then
				stageNo = main.t_includeStage[2][math.random(1, #main.t_includeStage[2])]
				stageEnd = true
			end
			p1SelEnd = true
		end
	end
end

--;===========================================================
--; PLAYER 2 SELECT MENU
--;===========================================================
function start.f_p2SelectMenu()
	--predefined selection
	if main.p2Char ~= nil then
		local t = {}
		for i = 1, #main.p2Char do
			if t[main.p2Char[i]] == nil then
				t[main.p2Char[i]] = ''
			end
			start.t_p2Selected[i] = {
				ref = main.p2Char[i],
				pal = start.f_selectPal(main.p2Char[i])
			}
		end
		p2SelEnd = true
		return
	--p2 selection disabled
	elseif not main.p2SelectMenu then
		p2SelEnd = true
		return
	--manual selection
	elseif not p2SelEnd then
		resetgrid = false
		--cell movement
		if p2RestoreCursor and t_p2Cursor[p2NumChars - #start.t_p2Selected] ~= nil then --restore saved position
			p2SelX = t_p2Cursor[p2NumChars - #start.t_p2Selected][1]
			p2SelY = t_p2Cursor[p2NumChars - #start.t_p2Selected][2]
			p2FaceOffset = t_p2Cursor[p2NumChars - #start.t_p2Selected][3]
			p2RowOffset = t_p2Cursor[p2NumChars - #start.t_p2Selected][4]
			t_p2Cursor[p2NumChars - #start.t_p2Selected] = nil
		else --calculate current position
			p2SelX, p2SelY, p2FaceOffset, p2RowOffset = start.f_cellMovement(p2SelX, p2SelY, 2, p2FaceOffset, p2RowOffset, motif.select_info.p2_cursor_move_snd)
		end
		p2Cell = p2SelX + motif.select_info.columns * p2SelY
		--draw active cursor
		local cursorX = p2FaceX + p2SelX * (motif.select_info.cell_size[1] + motif.select_info.cell_spacing[1]) + start.f_faceOffset(p2SelX + 1, p2SelY + 1, 1)
		local cursorY = p2FaceY + (p2SelY - p2RowOffset) * (motif.select_info.cell_size[2] + motif.select_info.cell_spacing[2]) + start.f_faceOffset(p2SelX + 1, p2SelY + 1, 2)
		if resetgrid == true then
			start.f_resetGrid()
		end
		main.f_animPosDraw(
			motif.select_info.p2_cursor_active_data,
			cursorX,
			cursorY,
			(motif.select_info['cell_' .. p2SelX + 1 .. '_' .. p2SelY + 1 .. '_facing'] or 1)
		)
		--cell selected
		if start.f_slotSelected(p2Cell + 1, 2, p2SelX, p2SelY) and start.f_selGrid(p2Cell + 1).char ~= nil and start.f_selGrid(p2Cell + 1).hidden ~= 2 then
			sndPlay(motif.files.snd_data, motif.select_info.p2_cursor_done_snd[1], motif.select_info.p2_cursor_done_snd[2])
			local selected = start.f_selGrid(p2Cell + 1).char_ref
			if main.t_selChars[selected + 1].char == 'randomselect' or main.t_selChars[selected + 1].hidden == 3 then
				selected = main.t_randomChars[math.random(1, #main.t_randomChars)]
			end
			start.f_playWave(selected, 'cursor', motif.select_info.p2_select_snd[1], motif.select_info.p2_select_snd[2])
			table.insert(start.t_p2Selected, {
				ref = selected,
				pal = start.f_selectPal(selected, main.f_btnPalNo(main.t_cmd[2])),
				cursor = {cursorX, cursorY, p2RowOffset, (motif.select_info['cell_' .. p2SelX + 1 .. '_' .. p2SelY + 1 .. '_facing'] or 1)},
				ratio = start.f_setRatio(2)
			})
			t_p2Cursor[p2NumChars - #start.t_p2Selected + 1] = {p2SelX, p2SelY, p2FaceOffset, p2RowOffset}
			if #start.t_p2Selected == p2NumChars then
				p2SelEnd = true
			end
			main.f_cmdInput()
		--select screen timer reached 0
		elseif motif.select_info.timer_enabled == 1 and timerSelect == -1 then
			sndPlay(motif.files.snd_data, motif.select_info.p2_cursor_done_snd[1], motif.select_info.p2_cursor_done_snd[2])
			local selected = start.f_selGrid(p2Cell + 1).char_ref
			local rand = false
			for i = #start.t_p2Selected + 1, p2NumChars do
				if rand or main.t_selChars[selected + 1].char == 'randomselect' or main.t_selChars[selected + 1].hidden == 3 then
					selected = main.t_randomChars[math.random(1, #main.t_randomChars)]
				end
				if not rand then --play it just for the first character
					start.f_playWave(selected, 'cursor', motif.select_info.p2_select_snd[1], motif.select_info.p2_select_snd[2])
				end
				rand = true
				table.insert(start.t_p2Selected, {
					ref = selected,
					pal = start.f_selectPal(selected),
					cursor = {cursorX, cursorY, p2RowOffset, (motif.select_info['cell_' .. p2SelX + 1 .. '_' .. p2SelY + 1 .. '_facing'] or 1)},
					ratio = start.f_setRatio(2)
				})
				t_p2Cursor[p2NumChars - #start.t_p2Selected + 1] = {p2SelX, p2SelY, p2FaceOffset, p2RowOffset}
			end
			p2SelEnd = true
		end
	end
end

--;===========================================================
--; STAGE MENU
--;===========================================================
local txt_selStage = text:create({
	font = motif.select_info.stage_active_font[1],
	height = motif.select_info.stage_active_font_height
})

local stageActiveCount = 0
local stageActiveType = 'stage_active'

function start.f_stageMenu()
	if main.f_input(main.t_players, {'$B'}) then
		sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
		stageList = stageList - 1
		if stageList < 0 then stageList = #main.t_includeStage[2] end
	elseif main.f_input(main.t_players, {'$F'}) then
		sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
		stageList = stageList + 1
		if stageList > #main.t_includeStage[2] then stageList = 0 end
	elseif main.f_input(main.t_players, {'$U'}) then
		sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
		for i = 1, 10 do
			stageList = stageList - 1
			if stageList < 0 then stageList = #main.t_includeStage[2] end
		end
	elseif main.f_input(main.t_players, {'$D'}) then
		sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
		for i = 1, 10 do
			stageList = stageList + 1
			if stageList > #main.t_includeStage[2] then stageList = 0 end
		end
	end
	if stageList == 0 then --draw random stage portrait loaded from screenpack SFF
		main.t_animUpdate[motif.select_info.stage_portrait_random_data] = 1
		animDraw(motif.select_info.stage_portrait_random_data)
	else --draw stage portrait loaded from stage SFF
		drawPortraitStage(
			stageList,
			motif.select_info.stage_portrait_spr[1],
			motif.select_info.stage_portrait_spr[2],
			motif.select_info.stage_pos[1] + motif.select_info.stage_portrait_offset[1],
			motif.select_info.stage_pos[2] + motif.select_info.stage_portrait_offset[2],
			--[[motif.select_info.stage_portrait_facing * ]]motif.select_info.stage_portrait_scale[1],
			motif.select_info.stage_portrait_scale[2],
			motif.select_info.stage_portrait_window[1],
			motif.select_info.stage_portrait_window[2],
			motif.select_info.stage_portrait_window[3],
			motif.select_info.stage_portrait_window[4]
		)
	end
	if main.f_input(main.t_players, {'pal', 's'}) then
		sndPlay(motif.files.snd_data, motif.select_info.stage_done_snd[1], motif.select_info.stage_done_snd[2])
		if stageList == 0 then
			stageNo = main.t_includeStage[2][math.random(1, #main.t_includeStage[2])]
		else
			stageNo = main.t_includeStage[2][stageList]
		end
		stageActiveType = 'stage_done'
		stageEnd = true
		--main.f_cmdInput()
	else
		if stageActiveCount < 2 then --delay change
			stageActiveCount = stageActiveCount + 1
		elseif stageActiveType == 'stage_active' then
			stageActiveType = 'stage_active2'
			stageActiveCount = 0
		else
			stageActiveType = 'stage_active'
			stageActiveCount = 0
		end
	end
	local t_txt = {}
	if stageList == 0 then
		t_txt[1] = motif.select_info.stage_random_text
	else
		t_txt = main.f_extractText(motif.select_info.stage_text, stageList, getStageName(main.t_includeStage[2][stageList]))
	end
	for i = 1, #t_txt do
		txt_selStage:update({
			font =   motif.select_info[stageActiveType .. '_font'][1],
			bank =   motif.select_info[stageActiveType .. '_font'][2],
			align =  motif.select_info[stageActiveType .. '_font'][3],
			text =   t_txt[i],
			x =      motif.select_info.stage_pos[1] + motif.select_info[stageActiveType .. '_offset'][1],
			y =      motif.select_info.stage_pos[2] + motif.select_info[stageActiveType .. '_offset'][2] + main.f_ySpacing(motif.select_info, stageActiveType .. '_font') * (i - 1),
			scaleX = motif.select_info[stageActiveType .. '_font_scale'][1],
			scaleY = motif.select_info[stageActiveType .. '_font_scale'][2],
			r =      motif.select_info[stageActiveType .. '_font'][4],
			g =      motif.select_info[stageActiveType .. '_font'][5],
			b =      motif.select_info[stageActiveType .. '_font'][6],
			src =    motif.select_info[stageActiveType .. '_font'][7],
			dst =    motif.select_info[stageActiveType .. '_font'][8],
			height = motif.select_info[stageActiveType .. '_font_height'],
		})
		txt_selStage:draw()
	end
end

--;===========================================================
--; VERSUS SCREEN
--;===========================================================
local txt_p1NameVS = text:create({
	font =   motif.vs_screen.p1_name_font[1],
	bank =   motif.vs_screen.p1_name_font[2],
	align =  motif.vs_screen.p1_name_font[3],
	text =   '',
	x =      0,
	y =      0,
	scaleX = motif.vs_screen.p1_name_font_scale[1],
	scaleY = motif.vs_screen.p1_name_font_scale[2],
	r =      motif.vs_screen.p1_name_font[4],
	g =      motif.vs_screen.p1_name_font[5],
	b =      motif.vs_screen.p1_name_font[6],
	src =    motif.vs_screen.p1_name_font[7],
	dst =    motif.vs_screen.p1_name_font[8],
	height = motif.vs_screen.p1_name_font_height,
})
local txt_p2NameVS = text:create({
	font =   motif.vs_screen.p2_name_font[1],
	bank =   motif.vs_screen.p2_name_font[2],
	align =  motif.vs_screen.p2_name_font[3],
	text =   '',
	x =      0,
	y =      0,
	scaleX = motif.vs_screen.p2_name_font_scale[1],
	scaleY = motif.vs_screen.p2_name_font_scale[2],
	r =      motif.vs_screen.p2_name_font[4],
	g =      motif.vs_screen.p2_name_font[5],
	b =      motif.vs_screen.p2_name_font[6],
	src =    motif.vs_screen.p2_name_font[7],
	dst =    motif.vs_screen.p2_name_font[8],
	height = motif.vs_screen.p2_name_font_height,
})
local txt_matchNo = text:create({
	font =   motif.vs_screen.match_font[1],
	bank =   motif.vs_screen.match_font[2],
	align =  motif.vs_screen.match_font[3],
	text =   '',
	x =      motif.vs_screen.match_offset[1],
	y =      motif.vs_screen.match_offset[2],
	scaleX = motif.vs_screen.match_font_scale[1],
	scaleY = motif.vs_screen.match_font_scale[2],
	r =      motif.vs_screen.match_font[4],
	g =      motif.vs_screen.match_font[5],
	b =      motif.vs_screen.match_font[6],
	src =    motif.vs_screen.match_font[7],
	dst =    motif.vs_screen.match_font[8],
	height = motif.vs_screen.match_font_height,
})

function start.f_selectChar(player, t)
	for i = 1, #t do
		selectChar(player, t[i].ref, t[i].pal)
	end
end

function start.f_selectVersus()
	if not main.versusScreen or not main.t_charparam.vsscreen or (main.t_charparam.rivals and start.f_rivalsMatch('vsscreen', 0)) or main.t_selChars[start.t_p1Selected[1].ref + 1].vsscreen == 0 then
		start.f_selectChar(1, start.t_p1Selected)
		start.f_selectChar(2, start.t_p2Selected)
		return true
	else
		local text = main.f_extractText(motif.vs_screen.match_text, matchNo)
		txt_matchNo:update({text = text[1]})
		main.f_bgReset(motif.versusbgdef.bg)
		main.f_playBGM(true, motif.music.vs_bgm, motif.music.vs_bgm_loop, motif.music.vs_bgm_volume, motif.music.vs_bgm_loopstart, motif.music.vs_bgm_loopend)
		local p1Confirmed = false
		local p2Confirmed = false
		local p1Row = 1
		local p2Row = 1
		local t_tmp = {}
		local t_p1_slide_dist = {0, 0}
		local t_p2_slide_dist = {0, 0}
		local orderTime = 0
		if main.t_pIn[1] == 1 and main.t_pIn[2] == 2 and (#start.t_p1Selected > 1 or #start.t_p2Selected > 1) and not main.coop then
			orderTime = math.max(#start.t_p1Selected, #start.t_p2Selected) - 1 * motif.vs_screen.time_order
			if #start.t_p1Selected == 1 then
				start.f_selectChar(1, start.t_p1Selected)
				p1Confirmed = true
			end
			if #start.t_p2Selected == 1 then
				start.f_selectChar(2, start.t_p2Selected)
				p2Confirmed = true
			end
		elseif #start.t_p1Selected > 1 and not main.coop then
			orderTime = #start.t_p1Selected - 1 * motif.vs_screen.time_order
		else
			start.f_selectChar(1, start.t_p1Selected)
			p1Confirmed = true
			start.f_selectChar(2, start.t_p2Selected)
			p2Confirmed = true
		end
		--main.f_cmdInput()
		main.fadeStart = getFrameCount()
		local counter = 0 - motif.vs_screen.fadein_time
		fadeType = 'fadein'
		while true do
			if counter == motif.vs_screen.stage_time then
				start.f_playWave(stageNo, 'stage', motif.vs_screen.stage_snd[1], motif.vs_screen.stage_snd[2])
			end
			if esc() or main.f_input(main.t_players, {'m'}) then
				--main.f_cmdInput()
				return nil
			elseif p1Confirmed and p2Confirmed then
				if fadeType == 'fadein' and (counter >= motif.vs_screen.time or main.f_input({1}, {'pal', 's'})) then
					main.fadeStart = getFrameCount()
					fadeType = 'fadeout'
				end
			elseif counter >= motif.vs_screen.time + orderTime then
				if not p1Confirmed then
					start.f_selectChar(1, start.t_p1Selected)
					p1Confirmed = true
				end
				if not p2Confirmed then
					start.f_selectChar(2, start.t_p2Selected)
					p2Confirmed = true
				end
			else
				--if Player1 has not confirmed the order yet
				if not p1Confirmed then
					if main.f_input({1}, {'pal', 's'}) then
						if not p1Confirmed then
							sndPlay(motif.files.snd_data, motif.vs_screen.p1_cursor_done_snd[1], motif.vs_screen.p1_cursor_done_snd[2])
							start.f_selectChar(1, start.t_p1Selected)
							p1Confirmed = true
						end
						if main.t_pIn[2] ~= 2 then
							if not p2Confirmed then
								start.f_selectChar(2, start.t_p2Selected)
								p2Confirmed = true
							end
						end
					elseif main.f_input({1}, {'$U'}) then
						if #start.t_p1Selected > 1 then
							sndPlay(motif.files.snd_data, motif.vs_screen.p1_cursor_move_snd[1], motif.vs_screen.p1_cursor_move_snd[2])
							p1Row = p1Row - 1
							if p1Row == 0 then p1Row = #start.t_p1Selected end
						end
					elseif main.f_input({1}, {'$D'}) then
						if #start.t_p1Selected > 1 then
							sndPlay(motif.files.snd_data, motif.vs_screen.p1_cursor_move_snd[1], motif.vs_screen.p1_cursor_move_snd[2])
							p1Row = p1Row + 1
							if p1Row > #start.t_p1Selected then p1Row = 1 end
						end
					elseif main.f_input({1}, {'$B'}) then
						if p1Row - 1 > 0 then
							sndPlay(motif.files.snd_data, motif.vs_screen.p1_cursor_move_snd[1], motif.vs_screen.p1_cursor_move_snd[2])
							p1Row = p1Row - 1
							t_tmp = {}
							t_tmp[p1Row] = start.t_p1Selected[p1Row + 1]
							for i = 1, #start.t_p1Selected do
								for j = 1, #start.t_p1Selected do
									if t_tmp[j] == nil and i ~= p1Row + 1 then
										t_tmp[j] = start.t_p1Selected[i]
										break
									end
								end
							end
							start.t_p1Selected = t_tmp
						end
					elseif main.f_input({1}, {'$F'}) then
						if p1Row + 1 <= #start.t_p1Selected then
							sndPlay(motif.files.snd_data, motif.vs_screen.p1_cursor_move_snd[1], motif.vs_screen.p1_cursor_move_snd[2])
							p1Row = p1Row + 1
							t_tmp = {}
							t_tmp[p1Row] = start.t_p1Selected[p1Row - 1]
							for i = 1, #start.t_p1Selected do
								for j = 1, #start.t_p1Selected do
									if t_tmp[j] == nil and i ~= p1Row - 1 then
										t_tmp[j] = start.t_p1Selected[i]
										break
									end
								end
							end
							start.t_p1Selected = t_tmp
						end
					end
				end
				--if Player2 has not confirmed the order yet and is not controlled by Player1
				if not p2Confirmed and main.t_pIn[2] ~= 1 then
					if main.f_input({2}, {'pal', 's'}) then
						if not p2Confirmed then
							sndPlay(motif.files.snd_data, motif.vs_screen.p2_cursor_done_snd[1], motif.vs_screen.p2_cursor_done_snd[2])
							start.f_selectChar(2, start.t_p2Selected)
							p2Confirmed = true
						end
					elseif main.f_input({2}, {'$U'}) then
						if #start.t_p2Selected > 1 then
							sndPlay(motif.files.snd_data, motif.vs_screen.p2_cursor_move_snd[1], motif.vs_screen.p2_cursor_move_snd[2])
							p2Row = p2Row - 1
							if p2Row == 0 then p2Row = #start.t_p2Selected end
						end
					elseif main.f_input({2}, {'$D'}) then
						if #start.t_p2Selected > 1 then
							sndPlay(motif.files.snd_data, motif.vs_screen.p2_cursor_move_snd[1], motif.vs_screen.p2_cursor_move_snd[2])
							p2Row = p2Row + 1
							if p2Row > #start.t_p2Selected then p2Row = 1 end
						end
					elseif main.f_input({2}, {'$B'}) then
						if p2Row + 1 <= #start.t_p2Selected then
							sndPlay(motif.files.snd_data, motif.vs_screen.p2_cursor_move_snd[1], motif.vs_screen.p2_cursor_move_snd[2])
							p2Row = p2Row + 1
							t_tmp = {}
							t_tmp[p2Row] = start.t_p2Selected[p2Row - 1]
							for i = 1, #start.t_p2Selected do
								for j = 1, #start.t_p2Selected do
									if t_tmp[j] == nil and i ~= p2Row - 1 then
										t_tmp[j] = start.t_p2Selected[i]
										break
									end
								end
							end
							start.t_p2Selected = t_tmp
						end
					elseif main.f_input({2}, {'$F'}) then
						if p2Row - 1 > 0 then
							sndPlay(motif.files.snd_data, motif.vs_screen.p2_cursor_move_snd[1], motif.vs_screen.p2_cursor_move_snd[2])
							p2Row = p2Row - 1
							t_tmp = {}
							t_tmp[p2Row] = start.t_p2Selected[p2Row + 1]
							for i = 1, #start.t_p2Selected do
								for j = 1, #start.t_p2Selected do
									if t_tmp[j] == nil and i ~= p2Row + 1 then
										t_tmp[j] = start.t_p2Selected[i]
										break
									end
								end
							end
							start.t_p2Selected = t_tmp
						end
					end
				end
			end
			counter = counter + 1
			--draw clearcolor
			clearColor(motif.versusbgdef.bgclearcolor[1], motif.versusbgdef.bgclearcolor[2], motif.versusbgdef.bgclearcolor[3])
			--draw layerno = 0 backgrounds
			bgDraw(motif.versusbgdef.bg, false)
			--draw p1 portraits
			local t_portrait = {}
			for i = 1, #start.t_p1Selected do
				if #t_portrait < motif.vs_screen.p1_num then
					table.insert(t_portrait, start.t_p1Selected[i].ref)
				end
			end
			t_portrait = main.f_tableReverse(t_portrait)
			for i = #t_portrait, 1, -1 do
				for j = 1, 2 do
					if t_p1_slide_dist[j] < motif.vs_screen['p1_c' .. i .. '_slide_dist'][j] then
						t_p1_slide_dist[j] = math.min(t_p1_slide_dist[j] + motif.vs_screen['p1_c' .. i .. '_slide_speed'][j], motif.vs_screen['p1_c' .. i .. '_slide_dist'][j])
					end
				end
				drawPortraitChar(
					t_portrait[i],
					motif.vs_screen.p1_spr[1],
					motif.vs_screen.p1_spr[2],
					motif.vs_screen.p1_pos[1] + motif.vs_screen.p1_offset[1] + motif.vs_screen['p1_c' .. i .. '_offset'][1] + (i - 1) * motif.vs_screen.p1_spacing[1] + main.f_alignOffset(motif.vs_screen.p1_facing) + math.floor(t_p1_slide_dist[1] + 0.5),
					motif.vs_screen.p1_pos[2] + motif.vs_screen.p1_offset[2] + motif.vs_screen['p1_c' .. i .. '_offset'][2] + (i - 1) * motif.vs_screen.p1_spacing[2] +  math.floor(t_p1_slide_dist[2] + 0.5),
					motif.vs_screen.p1_facing * motif.vs_screen.p1_scale[1] * motif.vs_screen['p1_c' .. i .. '_scale'][1],
					motif.vs_screen.p1_scale[2] * motif.vs_screen['p1_c' .. i .. '_scale'][2],
					motif.vs_screen.p1_window[1],
					motif.vs_screen.p1_window[2],
					motif.vs_screen.p1_window[3],
					motif.vs_screen.p1_window[4]
				)
			end
			--draw p2 portraits
			t_portrait = {}
			for i = 1, #start.t_p2Selected do
				if #t_portrait < motif.vs_screen.p2_num then
					table.insert(t_portrait, start.t_p2Selected[i].ref)
				end
			end
			t_portrait = main.f_tableReverse(t_portrait)
			for i = #t_portrait, 1, -1 do
				for j = 1, 2 do
					if t_p2_slide_dist[j] < motif.vs_screen['p2_c' .. i .. '_slide_dist'][j] then
						t_p2_slide_dist[j] = math.min(t_p2_slide_dist[j] + motif.vs_screen['p2_c' .. i .. '_slide_speed'][j], motif.vs_screen['p2_c' .. i .. '_slide_dist'][j])
					end
				end
				drawPortraitChar(
					t_portrait[i],
					motif.vs_screen.p2_spr[1],
					motif.vs_screen.p2_spr[2],
					motif.vs_screen.p2_pos[1] + motif.vs_screen.p2_offset[1] + motif.vs_screen['p2_c' .. i .. '_offset'][1] + (i - 1) * motif.vs_screen.p2_spacing[1] + main.f_alignOffset(motif.vs_screen.p2_facing) + math.floor(t_p2_slide_dist[1] + 0.5),
					motif.vs_screen.p2_pos[2] + motif.vs_screen.p2_offset[2] + motif.vs_screen['p2_c' .. i .. '_offset'][2] + (i - 1) * motif.vs_screen.p2_spacing[2] + math.floor(t_p2_slide_dist[2] + 0.5),
					motif.vs_screen.p2_facing * motif.vs_screen.p2_scale[1] * motif.vs_screen['p2_c' .. i .. '_scale'][1],
					motif.vs_screen.p2_scale[2] * motif.vs_screen['p2_c' .. i .. '_scale'][2],
					motif.vs_screen.p2_window[1],
					motif.vs_screen.p2_window[2],
					motif.vs_screen.p2_window[3],
					motif.vs_screen.p2_window[4]
				)
			end
			--draw names
			start.f_drawName(
				start.t_p1Selected,
				txt_p1NameVS,
				motif.vs_screen.p1_name_font,
				motif.vs_screen.p1_name_pos[1] + motif.vs_screen.p1_name_offset[1],
				motif.vs_screen.p1_name_pos[2] + motif.vs_screen.p1_name_offset[2],
				motif.vs_screen.p1_name_font_scale[1],
				motif.vs_screen.p1_name_font_scale[2],
				motif.vs_screen.p1_name_font_height,
				motif.vs_screen.p1_name_spacing[1],
				motif.vs_screen.p1_name_spacing[2],
				motif.vs_screen.p1_name_active_font,
				p1Row
			)
			start.f_drawName(
				start.t_p2Selected,
				txt_p2NameVS,
				motif.vs_screen.p2_name_font,
				motif.vs_screen.p2_name_pos[1] + motif.vs_screen.p2_name_offset[1],
				motif.vs_screen.p2_name_pos[2] + motif.vs_screen.p2_name_offset[2],
				motif.vs_screen.p2_name_font_scale[1],
				motif.vs_screen.p2_name_font_scale[2],
				motif.vs_screen.p2_name_font_height,
				motif.vs_screen.p2_name_spacing[1],
				motif.vs_screen.p2_name_spacing[2],
				motif.vs_screen.p2_name_active_font,
				p2Row
			)
			--draw match counter
			if matchNo > 0 then
				txt_matchNo:draw()
			end
			--draw layerno = 1 backgrounds
			bgDraw(motif.versusbgdef.bg, true)
			--draw fadein / fadeout
			main.fadeActive = fadeColor(
				fadeType,
				main.fadeStart,
				motif.vs_screen[fadeType .. '_time'],
				motif.vs_screen[fadeType .. '_col'][1],
				motif.vs_screen[fadeType .. '_col'][2],
				motif.vs_screen[fadeType .. '_col'][3]
			)
			--frame transition
			if main.fadeActive then
				commandBufReset(main.t_cmd[1])
				commandBufReset(main.t_cmd[2])
			elseif fadeType == 'fadeout' then
				commandBufReset(main.t_cmd[1])
				commandBufReset(main.t_cmd[2])
				clearColor(motif.versusbgdef.bgclearcolor[1], motif.versusbgdef.bgclearcolor[2], motif.versusbgdef.bgclearcolor[3]) --skip last frame rendering
				break
			else
				main.f_cmdInput()
			end
			main.f_refresh()
		end
		return true
	end
end

--;===========================================================
--; RESULT SCREEN
--;===========================================================
local txt_winscreen = text:create({
	font =   motif.win_screen.wintext_font[1],
	bank =   motif.win_screen.wintext_font[2],
	align =  motif.win_screen.wintext_font[3],
	text =   motif.win_screen.wintext_text,
	x =      motif.win_screen.wintext_offset[1],
	y =      motif.win_screen.wintext_offset[2],
	scaleX = motif.win_screen.wintext_font_scale[1],
	scaleY = motif.win_screen.wintext_font_scale[2],
	r =      motif.win_screen.wintext_font[4],
	g =      motif.win_screen.wintext_font[5],
	b =      motif.win_screen.wintext_font[6],
	src =    motif.win_screen.wintext_font[7],
	dst =    motif.win_screen.wintext_font[8],
	height = motif.win_screen.wintext_font_height,
})
local txt_resultSurvival = text:create({
	font =   motif.survival_results_screen.winstext_font[1],
	bank =   motif.survival_results_screen.winstext_font[2],
	align =  motif.survival_results_screen.winstext_font[3],
	text =   '',
	x =      motif.survival_results_screen.winstext_offset[1],
	y =      motif.survival_results_screen.winstext_offset[2],
	scaleX = motif.survival_results_screen.winstext_font_scale[1],
	scaleY = motif.survival_results_screen.winstext_font_scale[2],
	r =      motif.survival_results_screen.winstext_font[4],
	g =      motif.survival_results_screen.winstext_font[5],
	b =      motif.survival_results_screen.winstext_font[6],
	src =    motif.survival_results_screen.winstext_font[7],
	dst =    motif.survival_results_screen.winstext_font[8],
	height = motif.survival_results_screen.winstext_font_height,
})
local txt_resultVS100 = text:create({
	font =   motif.vs100_kumite_results_screen.winstext_font[1],
	bank =   motif.vs100_kumite_results_screen.winstext_font[2],
	align =  motif.vs100_kumite_results_screen.winstext_font[3],
	text =   '',
	x =      motif.vs100_kumite_results_screen.winstext_offset[1],
	y =      motif.vs100_kumite_results_screen.winstext_offset[2],
	scaleX = motif.vs100_kumite_results_screen.winstext_font_scale[1],
	scaleY = motif.vs100_kumite_results_screen.winstext_font_scale[2],
	r =      motif.vs100_kumite_results_screen.winstext_font[4],
	g =      motif.vs100_kumite_results_screen.winstext_font[5],
	b =      motif.vs100_kumite_results_screen.winstext_font[6],
	src =    motif.vs100_kumite_results_screen.winstext_font[7],
	dst =    motif.vs100_kumite_results_screen.winstext_font[8],
	height = motif.vs100_kumite_results_screen.winstext_font_height,
})
local txt_resultTimeAttack = text:create({
	font =   motif.time_attack_results_screen.winstext_font[1],
	bank =   motif.time_attack_results_screen.winstext_font[2],
	align =  motif.time_attack_results_screen.winstext_font[3],
	text =   '',
	x =      motif.time_attack_results_screen.winstext_offset[1],
	y =      motif.time_attack_results_screen.winstext_offset[2],
	scaleX = motif.time_attack_results_screen.winstext_font_scale[1],
	scaleY = motif.time_attack_results_screen.winstext_font_scale[2],
	r =      motif.time_attack_results_screen.winstext_font[4],
	g =      motif.time_attack_results_screen.winstext_font[5],
	b =      motif.time_attack_results_screen.winstext_font[6],
	src =    motif.time_attack_results_screen.winstext_font[7],
	dst =    motif.time_attack_results_screen.winstext_font[8],
	height = motif.time_attack_results_screen.winstext_font_height,
})
local txt_resultTimeChallenge = text:create({
	font =   motif.time_challenge_results_screen.winstext_font[1],
	bank =   motif.time_challenge_results_screen.winstext_font[2],
	align =  motif.time_challenge_results_screen.winstext_font[3],
	text =   '',
	x =      motif.time_challenge_results_screen.winstext_offset[1],
	y =      motif.time_challenge_results_screen.winstext_offset[2],
	scaleX = motif.time_challenge_results_screen.winstext_font_scale[1],
	scaleY = motif.time_challenge_results_screen.winstext_font_scale[2],
	r =      motif.time_challenge_results_screen.winstext_font[4],
	g =      motif.time_challenge_results_screen.winstext_font[5],
	b =      motif.time_challenge_results_screen.winstext_font[6],
	src =    motif.time_challenge_results_screen.winstext_font[7],
	dst =    motif.time_challenge_results_screen.winstext_font[8],
	height = motif.time_challenge_results_screen.winstext_font_height,
})
local txt_resultScoreChallenge = text:create({
	font =   motif.score_challenge_results_screen.winstext_font[1],
	bank =   motif.score_challenge_results_screen.winstext_font[2],
	align =  motif.score_challenge_results_screen.winstext_font[3],
	text =   '',
	x =      motif.score_challenge_results_screen.winstext_offset[1],
	y =      motif.score_challenge_results_screen.winstext_offset[2],
	scaleX = motif.score_challenge_results_screen.winstext_font_scale[1],
	scaleY = motif.score_challenge_results_screen.winstext_font_scale[2],
	r =      motif.score_challenge_results_screen.winstext_font[4],
	g =      motif.score_challenge_results_screen.winstext_font[5],
	b =      motif.score_challenge_results_screen.winstext_font[6],
	src =    motif.score_challenge_results_screen.winstext_font[7],
	dst =    motif.score_challenge_results_screen.winstext_font[8],
	height = motif.score_challenge_results_screen.winstext_font_height,
})
local txt_resultBossRush = text:create({
	font =   motif.boss_rush_results_screen.winstext_font[1],
	bank =   motif.boss_rush_results_screen.winstext_font[2],
	align =  motif.boss_rush_results_screen.winstext_font[3],
	text =   motif.boss_rush_results_screen.winstext_text,
	x =      motif.boss_rush_results_screen.winstext_offset[1],
	y =      motif.boss_rush_results_screen.winstext_offset[2],
	scaleX = motif.boss_rush_results_screen.winstext_font_scale[1],
	scaleY = motif.boss_rush_results_screen.winstext_font_scale[2],
	r =      motif.boss_rush_results_screen.winstext_font[4],
	g =      motif.boss_rush_results_screen.winstext_font[5],
	b =      motif.boss_rush_results_screen.winstext_font[6],
	src =    motif.boss_rush_results_screen.winstext_font[7],
	dst =    motif.boss_rush_results_screen.winstext_font[8],
	height = motif.boss_rush_results_screen.winstext_font_height,
})

local function f_drawTextAtLayerNo(t, prefix, t_text, txt, layerNo)
	if t[prefix .. '_layerno'] ~= layerNo then
		return
	end
	for i = 1, #t_text do
		txt:update({
			text = t_text[i],
			y =    t[prefix .. '_offset'][2] + main.f_ySpacing(t, prefix .. '_font') * (i - 1)
		})
		txt:draw()
	end
end

local function f_lowestRankingData(data)
	if stats.modes == nil or stats.modes[gamemode()] == nil or stats.modes[gamemode()].ranking == nil or #stats.modes[gamemode()].ranking < motif.rankings.max_entries then
		if data == 'score' then
			return 0
		else --time
			return 99
		end
	end
	local ret = 0
	for k, v in ipairs(stats.modes[gamemode()].ranking) do
		if k == 1 or (data == 'score' and ret > v[data]) or (data == 'time' and ret < v[data]) then
			ret = v[data]
		end
	end
	return ret
end

start.resultInit = false
function start.f_resultInit()
	if start.resultInit then
		return start.t_result.active
	end
	start.resultInit = true
	start.t_result = {
		active = false,
		prefix = 'winstext',
		resultText = {},
		txt = nil,
		displayTime = 0,
		fadeType = 'fadein'
	}
	if main.resultsTable == nil then
		return false
	end
	start.t_result.displayTime = 0 - main.resultsTable.fadein_time
	if winnerteam() == 1 then
		winCnt = winCnt + 1
	else
		loseCnt = loseCnt + 1
	end
	local t = main.resultsTable
	local stateType = ''
	local winBgm = true
	if gamemode('arcade') or gamemode('teamcoop') or gamemode('netplayteamcoop') then
		if winnerteam() ~= 1 or matchNo < lastMatch then
			return false
		end
		if main.t_selChars[start.t_p1Selected[1].ref + 1].ending ~= nil and main.f_fileExists(main.t_selChars[start.t_p1Selected[1].ref + 1].ending) then --not displayed if the team leader has an ending
			return false
		end
		start.t_result.prefix = 'wintext'
		start.t_result.resultText = main.f_extractText(t[start.t_result.prefix .. '_text'])
		start.t_result.txt = txt_winscreen
	elseif gamemode('bossrush') then
		if winnerteam() ~= 1 or matchNo < lastMatch then
			return false
		end
		start.t_result.resultText = main.f_extractText(t[start.t_result.prefix .. '_text'])
		start.t_result.txt = txt_resultBossRush
	elseif gamemode('survival') or gamemode('survivalcoop') or gamemode('netplaysurvivalcoop') then
		if winnerteam() == 1 and (matchNo < lastMatch or (t_roster[matchNo + 1] ~= nil and t_roster[matchNo + 1][1] == -1)) then
			return false
		end
		start.t_result.resultText = main.f_extractText(t[start.t_result.prefix .. '_text'], winCnt)
		start.t_result.txt = txt_resultSurvival
		if winCnt < t.roundstowin and matchNo < lastMatch then
			stateType = '_lose'
			winBgm = false
		else
			stateType = '_win'
		end
	elseif gamemode('vs100kumite') then
		if matchNo < lastMatch then
			return false
		end
		start.t_result.resultText = main.f_extractText(t[start.t_result.prefix .. '_text'], winCnt, loseCnt)
		start.t_result.txt = txt_resultVS100
		if winCnt < t.roundstowin then
			stateType = '_lose'
			winBgm = false
		else
			stateType = '_win'
		end
	elseif gamemode('timeattack') then
		if winnerteam() ~= 1 or matchNo < lastMatch then
			return false
		end
		start.t_result.resultText = main.f_extractText(start.f_clearTimeText(t[start.t_result.prefix .. '_text'], timetotal() / 60))
		start.t_result.txt = txt_resultTimeAttack
		if matchtime() / 60 >= f_lowestRankingData('time') then
			stateType = '_lose'
			winBgm = false
		else
			stateType = '_win'
		end
	elseif gamemode('timechallenge') then
		if winnerteam() ~= 1 then
			return false
		end
		start.t_result.resultText = main.f_extractText(start.f_clearTimeText(t[start.t_result.prefix .. '_text'], timetotal() / 60))
		start.t_result.txt = txt_resultTimeChallenge
		if matchtime() / 60 >= f_lowestRankingData('time') then
			stateType = '_lose'
			winBgm = false
		else
			stateType = '_win'
		end
	elseif gamemode('scorechallenge') then
		if winnerteam() ~= 1 then
			return false
		end
		player(1) --assign sys.debugWC to player 1
		start.t_result.resultText = main.f_extractText(t[start.t_result.prefix .. '_text'], scoretotal())
		start.t_result.txt = txt_resultScoreChallenge
		if scoretotal() <= f_lowestRankingData('score') then
			stateType = '_lose'
			winBgm = false
		else
			stateType = '_win'
		end
	else
		return false
	end
	for i = 1, 2 do
		for k, v in ipairs(t['p' .. i .. '_statedef' .. stateType]) do
			if charChangeState(i, v) then
				break
			end
		end
	end
	main.f_bgReset(motif.resultsbgdef.bg)
	if winBgm then
		main.f_playBGM(false, motif.music.results_bgm, motif.music.results_bgm_loop, motif.music.results_bgm_volume, motif.music.results_bgm_loopstart, motif.music.results_bgm_loopend)
	else
		main.f_playBGM(false, motif.music.results_lose_bgm, motif.music.results_lose_bgm_loop, motif.music.results_lose_bgm_volume, motif.music.results_lose_bgm_loopstart, motif.music.results_lose_bgm_loopend)
	end
	main.fadeStart = getFrameCount()
	start.t_result.active = true
	return true
end

function start.f_result()
	if not start.f_resultInit() then
		return false
	end
	local t = main.resultsTable
	start.t_result.displayTime = start.t_result.displayTime + 1
	--draw overlay
	fillRect(
		t.boxbg_coords[1],
		t.boxbg_coords[2],
		t.boxbg_coords[3] - t.boxbg_coords[1] + 1,
		t.boxbg_coords[4] - t.boxbg_coords[2] + 1,
		t.boxbg_col[1],
		t.boxbg_col[2],
		t.boxbg_col[3],
		t.boxbg_alpha[1],
		t.boxbg_alpha[2],
		false,
		false
	)
	--draw text at layerno = 0
	f_drawTextAtLayerNo(t, start.t_result.prefix, start.t_result.resultText, start.t_result.txt, 0)
	--draw layerno = 0 backgrounds
	bgDraw(motif.resultsbgdef.bg, false)
	--draw text at layerno = 1
	f_drawTextAtLayerNo(t, start.t_result.prefix, start.t_result.resultText, start.t_result.txt, 1)
	--draw layerno = 1 backgrounds
	bgDraw(motif.resultsbgdef.bg, true)
	--draw text at layerno = 1
	f_drawTextAtLayerNo(t, start.t_result.prefix, start.t_result.resultText, start.t_result.txt, 2)
	--draw fadein / fadeout
	if start.t_result.fadeType == 'fadein' and (start.t_result.displayTime >= t.time or main.f_input({1}, {'pal', 's'})) then
		main.fadeStart = getFrameCount()
		start.t_result.fadeType = 'fadeout'
	end
	main.fadeActive = fadeColor(
		start.t_result.fadeType,
		main.fadeStart,
		t[start.t_result.fadeType .. '_time'],
		t[start.t_result.fadeType .. '_col'][1],
		t[start.t_result.fadeType .. '_col'][2],
		t[start.t_result.fadeType .. '_col'][3]
	)
	--frame transition
	main.f_cmdInput()
	if esc() or main.f_input(main.t_players, {'m'}) then
		esc(false)
		start.t_result.active = false
		return false
	end
	if not main.fadeActive and start.t_result.fadeType == 'fadeout' then
		start.t_result.active = false
		return false
	end
	return true
end

--;===========================================================
--; VICTORY SCREEN
--;===========================================================
local txt_winquote = text:create({
	font =   motif.victory_screen.winquote_font[1],
	bank =   motif.victory_screen.winquote_font[2],
	align =  motif.victory_screen.winquote_font[3],
	text =   '',
	x =      0,
	y =      0,
	scaleX = motif.victory_screen.winquote_font_scale[1],
	scaleY = motif.victory_screen.winquote_font_scale[2],
	r =      motif.victory_screen.winquote_font[4],
	g =      motif.victory_screen.winquote_font[5],
	b =      motif.victory_screen.winquote_font[6],
	src =    motif.victory_screen.winquote_font[7],
	dst =    motif.victory_screen.winquote_font[8],
	height = motif.victory_screen.winquote_font_height,
	window = motif.victory_screen.winquote_window,
})
local txt_p1_winquoteName = text:create({
	font =   motif.victory_screen.p1_name_font[1],
	bank =   motif.victory_screen.p1_name_font[2],
	align =  motif.victory_screen.p1_name_font[3],
	text =   '',
	x =      motif.victory_screen.p1_name_offset[1],
	y =      motif.victory_screen.p1_name_offset[2],
	scaleX = motif.victory_screen.p1_name_font_scale[1],
	scaleY = motif.victory_screen.p1_name_font_scale[2],
	r =      motif.victory_screen.p1_name_font[4],
	g =      motif.victory_screen.p1_name_font[5],
	b =      motif.victory_screen.p1_name_font[6],
	src =    motif.victory_screen.p1_name_font[7],
	dst =    motif.victory_screen.p1_name_font[8],
	height = motif.victory_screen.p1_name_font_height,
})
local txt_p2_winquoteName = text:create({
	font =   motif.victory_screen.p2_name_font[1],
	bank =   motif.victory_screen.p2_name_font[2],
	align =  motif.victory_screen.p2_name_font[3],
	text =   '',
	x =      motif.victory_screen.p2_name_offset[1],
	y =      motif.victory_screen.p2_name_offset[2],
	scaleX = motif.victory_screen.p2_name_font_scale[1],
	scaleY = motif.victory_screen.p2_name_font_scale[2],
	r =      motif.victory_screen.p2_name_font[4],
	g =      motif.victory_screen.p2_name_font[5],
	b =      motif.victory_screen.p2_name_font[6],
	src =    motif.victory_screen.p2_name_font[7],
	dst =    motif.victory_screen.p2_name_font[8],
	height = motif.victory_screen.p2_name_font_height,
})

function start.f_teamOrder(teamNo, allow_ko, num)
	local allow_ko = allow_ko or 0
	local t = {}
	local playerNo = -1
	local selectNo = -1
	local ok = false
	for i = 1, #start.t_p1Selected + #start.t_p2Selected do
		if i % 2 ~= teamNo then --only if character belongs to selected team
			if player(i) then --assign sys.debugWC if player i exists
				if win() then --win team
					if alive() and not ok then --first not KOed win team member
						playerNo = i
						selectNo = selectno()
						if #t >= num then break end
						table.insert(t, {['pn'] = i, ['ref'] = selectno()})
						ok = true
					elseif alive() or allow_ko == 1 then --other win team members
						if #t >= num then break end
						table.insert(t, {['pn'] = i, ['ref'] = selectno()})
					end
				else --lose team
					if not ok then
						playerNo = i
						selectNo = selectno()
						ok = true
					end
					if #t >= num then break end
					table.insert(t, {['pn'] = i, ['ref'] = selectno()})
				end
			end
		end
	end
	return playerNo, selectNo, t
end

start.victoryInit = false
function start.f_victoryInit()
	if start.victoryInit then
		return start.t_victory.active
	end
	start.victoryInit = true
	start.t_victory = {
		active = false,
		winquote = '',
		textcnt = 0,
		textend = false,
		winnerNo = -1,
		winnerRef = -1,
		loserNo = -1,
		loserRef = -1,
		team1 = {},
		team2 = {},
		p1_slide_dist = {0, 0},
		p2_slide_dist = {0, 0},
		displayTime = 0 - motif.victory_screen.fadein_time,
		fadeType = 'fadein'
	}
	if winnerteam() < 1 or not main.victoryScreen or motif.victory_screen.enabled == 0 then
		return false
	elseif gamemode('versus') or gamemode('netplayversus') then
		if motif.victory_screen.vs_enabled == 0 then
			return false
		end
	elseif winnerteam() == 2 and motif.victory_screen.cpu_enabled == 0 then
		return false
	end
	for i = 1, 2 do
		if winnerteam() == i then
			start.t_victory.winnerNo, start.t_victory.winnerRef, start.t_victory.team1 = start.f_teamOrder(i - 1, motif.victory_screen.winner_teamko_enabled, motif.victory_screen.p1_num)
		else
			start.t_victory.loserNo, start.t_victory.loserRef, start.t_victory.team2 = start.f_teamOrder(i - 1, true, motif.victory_screen.p2_num)
		end
	end
	if start.t_victory.winnerNo == -1 or start.t_victory.winnerRef == -1 then
		return false
	elseif not main.t_charparam.winscreen then
		return false
	elseif main.t_charparam.rivals and start.f_rivalsMatch('winscreen', 0) then --winscreen assigned as rivals param
		return false
	elseif main.t_selChars[start.t_victory.winnerRef + 1].winscreen == 0 then --winscreen assigned as character param
		return false
	end
	main.f_bgReset(motif.victorybgdef.bg)
	if not t_victoryBGM[winnerteam()] then
		main.f_playBGM(false, motif.music.victory_bgm, motif.music.victory_bgm_loop, motif.music.victory_bgm_volume, motif.music.victory_bgm_loopstart, motif.music.victory_bgm_loopend)
	end
	start.t_victory.winquote = getCharVictoryQuote(start.t_victory.winnerNo)
	if start.t_victory.winquote == '' then
		start.t_victory.winquote = motif.victory_screen.winquote_text
	end
	txt_p1_winquoteName:update({text = start.f_getName(start.t_victory.winnerRef)})
	txt_p2_winquoteName:update({text = start.f_getName(start.t_victory.loserRef)})
	main.fadeStart = getFrameCount()
	start.t_victory.active = true
	return true
end

function start.f_victory()
	if not start.f_victoryInit() then
		return false
	end
	if start.t_victory.textend then
		start.t_victory.displayTime = start.t_victory.displayTime + 1
	end
	--draw overlay
	fillRect(
		motif.victory_screen.boxbg_coords[1],
		motif.victory_screen.boxbg_coords[2],
		motif.victory_screen.boxbg_coords[3] - motif.victory_screen.boxbg_coords[1] + 1,
		motif.victory_screen.boxbg_coords[4] - motif.victory_screen.boxbg_coords[2] + 1,
		motif.victory_screen.boxbg_col[1],
		motif.victory_screen.boxbg_col[2],
		motif.victory_screen.boxbg_col[3],
		motif.victory_screen.boxbg_alpha[1],
		motif.victory_screen.boxbg_alpha[2],
		false,
		false
	)
	--draw layerno = 0 backgrounds
	bgDraw(motif.victorybgdef.bg, false)
	--draw loser team portraits
	for i = #start.t_victory.team2, 1, -1 do
		for j = 1, 2 do
			if start.t_victory.p2_slide_dist[j] < motif.victory_screen['p2_c' .. i .. '_slide_dist'][j] then
				start.t_victory.p2_slide_dist[j] = math.min(start.t_victory.p2_slide_dist[j] + motif.victory_screen['p2_c' .. i .. '_slide_speed'][j], motif.victory_screen['p2_c' .. i .. '_slide_dist'][j])
			end
		end
		charSpriteDraw(
			start.t_victory.team2[i].pn,
			{
				motif.victory_screen['p2_c' .. i .. '_spr'][1], motif.victory_screen['p2_c' .. i .. '_spr'][2],
				motif.victory_screen.p2_spr[1], motif.victory_screen.p2_spr[2],
				9000, 1
			},
			motif.victory_screen.p2_pos[1] + motif.victory_screen.p2_offset[1] + motif.victory_screen['p2_c' .. i .. '_offset'][1] + math.floor(start.t_victory.p2_slide_dist[1] + 0.5),
			motif.victory_screen.p2_pos[2] + motif.victory_screen.p2_offset[2] + motif.victory_screen['p2_c' .. i .. '_offset'][2] + math.floor(start.t_victory.p2_slide_dist[2] + 0.5),
			motif.victory_screen.p2_scale[1] * motif.victory_screen['p2_c' .. i .. '_scale'][1],
			motif.victory_screen.p2_scale[2] * motif.victory_screen['p2_c' .. i .. '_scale'][2],
			motif.victory_screen.p2_facing,
			motif.victory_screen.p2_window[1],
			motif.victory_screen.p2_window[2],
			motif.victory_screen.p2_window[3] * config.GameWidth / main.SP_Localcoord[1],
			motif.victory_screen.p2_window[4] * config.GameHeight / main.SP_Localcoord[2]
		)
	end
	--draw winner team portraits
	for i = #start.t_victory.team1, 1, -1 do
		for j = 1, 2 do
			if start.t_victory.p1_slide_dist[j] < motif.victory_screen['p1_c' .. i .. '_slide_dist'][j] then
				start.t_victory.p1_slide_dist[j] = math.min(start.t_victory.p1_slide_dist[j] + motif.victory_screen['p1_c' .. i .. '_slide_speed'][j], motif.victory_screen['p1_c' .. i .. '_slide_dist'][j])
			end
		end
		charSpriteDraw(
			start.t_victory.team1[i].pn,
			{
				motif.victory_screen['p1_c' .. i .. '_spr'][1], motif.victory_screen['p1_c' .. i .. '_spr'][2],
				motif.victory_screen.p1_spr[1], motif.victory_screen.p1_spr[2],
				9000, 1
			},
			motif.victory_screen.p1_pos[1] + motif.victory_screen.p1_offset[1] + motif.victory_screen['p1_c' .. i .. '_offset'][1] + math.floor(start.t_victory.p1_slide_dist[1] + 0.5),
			motif.victory_screen.p1_pos[2] + motif.victory_screen.p1_offset[2] + motif.victory_screen['p1_c' .. i .. '_offset'][2] + math.floor(start.t_victory.p1_slide_dist[2] + 0.5),
			motif.victory_screen.p1_scale[1] * motif.victory_screen['p1_c' .. i .. '_scale'][1],
			motif.victory_screen.p1_scale[2] * motif.victory_screen['p1_c' .. i .. '_scale'][2],
			motif.victory_screen.p1_facing,
			motif.victory_screen.p1_window[1],
			motif.victory_screen.p1_window[2],
			motif.victory_screen.p1_window[3] * config.GameWidth / main.SP_Localcoord[1],
			motif.victory_screen.p1_window[4] * config.GameHeight / main.SP_Localcoord[2]
		)
	end
	--draw winner name
	txt_p1_winquoteName:draw()
	--draw loser name
	if motif.victory_screen.loser_name_enabled == 1 then
		txt_p2_winquoteName:draw()
	end
	--draw winquote
	start.t_victory.textcnt = start.t_victory.textcnt + 1
	start.t_victory.textend = main.f_textRender(
		txt_winquote,
		start.t_victory.winquote,
		start.t_victory.textcnt,
		motif.victory_screen.winquote_offset[1],
		motif.victory_screen.winquote_offset[2],
		main.font_def[motif.victory_screen.winquote_font[1] .. motif.victory_screen.winquote_font_height],
		motif.victory_screen.winquote_delay,
		main.f_lineLength(motif.victory_screen.winquote_offset[1], motif.info.localcoord[1], motif.victory_screen.winquote_font[3], motif.victory_screen.winquote_window, motif.victory_screen.winquote_textwrap:match('[wl]'))
	)
	--draw layerno = 1 backgrounds
	bgDraw(motif.victorybgdef.bg, true)
	--draw fadein / fadeout
	if start.t_victory.fadeType == 'fadein' and (start.t_victory.displayTime >= motif.victory_screen.time or main.f_input({1}, {'pal', 's'})) then
		main.fadeStart = getFrameCount()
		start.t_victory.fadeType = 'fadeout'
	end
	main.fadeActive = fadeColor(
		start.t_victory.fadeType,
		main.fadeStart,
		motif.victory_screen[start.t_victory.fadeType .. '_time'],
		motif.victory_screen[start.t_victory.fadeType .. '_col'][1],
		motif.victory_screen[start.t_victory.fadeType .. '_col'][2],
		motif.victory_screen[start.t_victory.fadeType .. '_col'][3]
	)
	--frame transition
	main.f_cmdInput()
	if esc() or main.f_input(main.t_players, {'m'}) then
		esc(false)
		start.t_victory.active = false
		return false
	end
	if not main.fadeActive and start.t_victory.fadeType == 'fadeout' then
		start.t_victory.active = false
		return false
	end
	return true
end

--;===========================================================
--; CONTINUE SCREEN
--;===========================================================
local txt_credits = text:create({
	font =   motif.continue_screen.credits_font[1],
	bank =   motif.continue_screen.credits_font[2],
	align =  motif.continue_screen.credits_font[3],
	text =   '',
	x =      motif.continue_screen.credits_offset[1],
	y =      motif.continue_screen.credits_offset[2],
	scaleX = motif.continue_screen.credits_font_scale[1],
	scaleY = motif.continue_screen.credits_font_scale[2],
	r =      motif.continue_screen.credits_font[4],
	g =      motif.continue_screen.credits_font[5],
	b =      motif.continue_screen.credits_font[6],
	src =    motif.continue_screen.credits_font[7],
	dst =    motif.continue_screen.credits_font[8],
	height = motif.continue_screen.credits_font_height,
})
local txt_continue = text:create({
	font =   motif.continue_screen.continue_font[1],
	bank =   motif.continue_screen.continue_font[2],
	align =  motif.continue_screen.continue_font[3],
	text =   motif.continue_screen.continue_text,
	x =      motif.continue_screen.pos[1] + motif.continue_screen.continue_offset[1],
	y =      motif.continue_screen.pos[2] + motif.continue_screen.continue_offset[2],
	scaleX = motif.continue_screen.continue_font_scale[1],
	scaleY = motif.continue_screen.continue_font_scale[2],
	r =      motif.continue_screen.continue_font[4],
	g =      motif.continue_screen.continue_font[5],
	b =      motif.continue_screen.continue_font[6],
	src =    motif.continue_screen.continue_font[7],
	dst =    motif.continue_screen.continue_font[8],
	height = motif.continue_screen.continue_font_height,
})
local txt_yes = text:create({})
local txt_no = text:create({})

start.continueInit = false
function start.f_continueInit()
	if start.continueInit then
		return start.t_continue.active
	end
	start.continueInit = true
	start.t_continue = {
		active = false,
		continue = false,
		yesActive = true,
		selected = false,
		counter = 0,-- - motif.victory_screen.fadein_time
		text = main.f_extractText(motif.continue_screen.credits_text, main.credits),
		fadeType = 'fadein'
	}
	continueFlag = false
	if motif.continue_screen.enabled == 0 or not main.continueScreen or winnerteam() == 1 then
		return false
	end
	txt_credits:update({text = start.t_continue.text[1]})
	main.f_bgReset(motif.continuebgdef.bg)
	main.f_playBGM(false, motif.music.continue_bgm, motif.music.continue_bgm_loop, motif.music.continue_bgm_volume, motif.music.continue_bgm_loopstart, motif.music.continue_bgm_loopend)
	--animReset(motif.continue_screen.continue_anim_data)
	--animUpdate(motif.continue_screen.continue_anim_data)
	for i = 1, 2 do
		for k, v in ipairs(motif.continue_screen['p' .. i .. '_statedef_continue']) do
			if charChangeState(i, v) then
				break
			end
		end
	end
	main.fadeStart = getFrameCount()
	start.t_continue.active = true
	return true
end

function start.f_continue()
	if not start.f_continueInit() then
		return false
	end
	--draw overlay
	fillRect(
		motif.continue_screen.boxbg_coords[1],
		motif.continue_screen.boxbg_coords[2],
		motif.continue_screen.boxbg_coords[3] - motif.continue_screen.boxbg_coords[1] + 1,
		motif.continue_screen.boxbg_coords[4] - motif.continue_screen.boxbg_coords[2] + 1,
		motif.continue_screen.boxbg_col[1],
		motif.continue_screen.boxbg_col[2],
		motif.continue_screen.boxbg_col[3],
		motif.continue_screen.boxbg_alpha[1],
		motif.continue_screen.boxbg_alpha[2],
		false,
		false
	)
	--draw layerno = 0 backgrounds
	bgDraw(motif.continuebgdef.bg, false)
	if motif.continue_screen.animated_continue == 1 then --advanced continue screen parameters
		if start.t_continue.counter < motif.continue_screen.continue_end_skiptime then
			if not start.t_continue.selected and main.f_input({1}, {'s'}) then
				start.t_continue.continue = true
				for i = 1, 2 do
					for k, v in ipairs(motif.continue_screen['p' .. i .. '_statedef_yes']) do
						if charChangeState(i, v) then
							break
						end
					end
				end
				start.t_continue.selected = true
				main.credits = main.credits - 1
				start.t_continue.text = main.f_extractText(motif.continue_screen.credits_text, main.credits)
				txt_credits:update({text = start.t_continue.text[1]})
			elseif not start.t_continue.selected and main.f_input({1}, {'pal', 's'}) and start.t_continue.counter >= motif.continue_screen.continue_starttime + motif.continue_screen.continue_skipstart then
				local cnt = 0
				if start.t_continue.counter < motif.continue_screen.continue_9_skiptime then
					cnt = motif.continue_screen.continue_9_skiptime
				elseif start.t_continue.counter <= motif.continue_screen.continue_8_skiptime then
					cnt = motif.continue_screen.continue_8_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_7_skiptime then
					cnt = motif.continue_screen.continue_7_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_6_skiptime then
					cnt = motif.continue_screen.continue_6_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_5_skiptime then
					cnt = motif.continue_screen.continue_5_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_4_skiptime then
					cnt = motif.continue_screen.continue_4_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_3_skiptime then
					cnt = motif.continue_screen.continue_3_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_2_skiptime then
					cnt = motif.continue_screen.continue_2_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_1_skiptime then
					cnt = motif.continue_screen.continue_1_skiptime
				elseif start.t_continue.counter < motif.continue_screen.continue_0_skiptime then
					cnt = motif.continue_screen.continue_0_skiptime
				end
				while start.t_continue.counter < cnt do
					start.t_continue.counter = start.t_continue.counter + 1
					animUpdate(motif.continue_screen.continue_anim_data)
				end
			end
			if start.t_continue.counter == motif.continue_screen.continue_9_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_9_snd[1], motif.continue_screen.continue_9_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_8_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_8_snd[1], motif.continue_screen.continue_8_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_7_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_7_snd[1], motif.continue_screen.continue_7_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_6_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_6_snd[1], motif.continue_screen.continue_6_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_5_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_5_snd[1], motif.continue_screen.continue_5_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_4_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_4_snd[1], motif.continue_screen.continue_4_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_3_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_3_snd[1], motif.continue_screen.continue_3_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_2_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_2_snd[1], motif.continue_screen.continue_2_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_1_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_1_snd[1], motif.continue_screen.continue_1_snd[2])
			elseif start.t_continue.counter == motif.continue_screen.continue_0_skiptime then
				sndPlay(motif.files.snd_data, motif.continue_screen.continue_0_snd[1], motif.continue_screen.continue_0_snd[2])
			end
		elseif start.t_continue.counter == motif.continue_screen.continue_end_skiptime then
			playBGM(motif.music.continue_end_bgm, true, motif.music.continue_end_bgm_loop, motif.music.continue_end_bgm_volume, motif.music.continue_end_bgm_loopstart, motif.music.continue_end_bgm_loopend)
			sndPlay(motif.files.snd_data, motif.continue_screen.continue_end_snd[1], motif.continue_screen.continue_end_snd[2])
			for i = 1, 2 do
				for k, v in ipairs(motif.continue_screen['p' .. i .. '_statedef_no']) do
					if charChangeState(i, v) then
						break
					end
				end
			end
		end
		--draw credits text
		if start.t_continue.counter >= motif.continue_screen.continue_skipstart then --show when counter starts counting down
			txt_credits:draw()
		end
		start.t_continue.counter = start.t_continue.counter + 1
		--draw counter
		animUpdate(motif.continue_screen.continue_anim_data)
		animDraw(motif.continue_screen.continue_anim_data)
	else --vanilla mugen continue screen parameters
		if not start.t_continue.selected and main.f_input({1}, {'$F', '$B'}) then
			sndPlay(motif.files.snd_data, motif.continue_screen.move_snd[1], motif.continue_screen.move_snd[2])
			if start.t_continue.yesActive then
				start.t_continue.yesActive = false
			else
				start.t_continue.yesActive = true
			end
		elseif not start.t_continue.selected and main.f_input({1}, {'pal', 's'}) then
			start.t_continue.continue = start.t_continue.yesActive
			if start.t_continue.continue then
				sndPlay(motif.files.snd_data, motif.continue_screen.done_snd[1], motif.continue_screen.done_snd[2])
				for i = 1, 2 do
					for k, v in ipairs(motif.continue_screen['p' .. i .. '_statedef_yes']) do
						if charChangeState(i, v) then
							break
						end
					end
				end
				start.t_continue.selected = true
				main.credits = main.credits - 1
				--start.t_continue.text = main.f_extractText(motif.continue_screen.credits_text, main.credits)
				--txt_credits:update({text = start.t_continue.text[1]})
			else
				sndPlay(motif.files.snd_data, motif.continue_screen.cancel_snd[1], motif.continue_screen.cancel_snd[2])
				for i = 1, 2 do
					for k, v in ipairs(motif.continue_screen['p' .. i .. '_statedef_no']) do
						if charChangeState(i, v) then
							break
						end
					end
				end
			end
			start.t_continue.counter = motif.continue_screen.endtime + 1
		end
		txt_continue:draw()
		for i = 1, 2 do
			local txt = ''
			local var = ''
			if i == 1 then
				txt = txt_yes
				if start.t_continue.yesActive then
					var = 'yes_active'
				else
					var = 'yes'
				end
			else
				txt = txt_no
				if start.t_continue.yesActive then
					var = 'no'
				else
					var = 'no_active'
				end
			end
			txt:update({
				font =   motif.continue_screen[var .. '_font'][1],
				bank =   motif.continue_screen[var .. '_font'][2],
				align =  motif.continue_screen[var .. '_font'][3],
				text =   motif.continue_screen[var .. '_text'],
				x =      motif.continue_screen.pos[1] + motif.continue_screen[var .. '_offset'][1],
				y =      motif.continue_screen.pos[2] + motif.continue_screen[var .. '_offset'][2],
				scaleX = motif.continue_screen[var .. '_font_scale'][1],
				scaleY = motif.continue_screen[var .. '_font_scale'][2],
				r =      motif.continue_screen[var .. '_font'][4],
				g =      motif.continue_screen[var .. '_font'][5],
				b =      motif.continue_screen[var .. '_font'][6],
				src =    motif.continue_screen[var .. '_font'][7],
				dst =    motif.continue_screen[var .. '_font'][8],
				height = motif.continue_screen[var .. '_font_height'],
			})
			txt:draw()
		end
	end
	--draw layerno = 1 backgrounds
	bgDraw(motif.continuebgdef.bg, true)
	--draw fadein / fadeout
	main.fadeActive = fadeColor(
		start.t_continue.fadeType,
		main.fadeStart,
		motif.continue_screen[start.t_continue.fadeType .. '_time'],
		motif.continue_screen[start.t_continue.fadeType .. '_col'][1],
		motif.continue_screen[start.t_continue.fadeType .. '_col'][2],
		motif.continue_screen[start.t_continue.fadeType .. '_col'][3]
	)
	--draw fadein / fadeout
	if start.t_continue.fadeType == 'fadein' and (start.t_continue.counter > motif.continue_screen.endtime or start.t_continue.continue or main.f_input({1}, {'pal', 's'})) then
		main.fadeStart = getFrameCount()
		start.t_continue.fadeType = 'fadeout'
	end
	main.fadeActive = fadeColor(
		start.t_continue.fadeType,
		main.fadeStart,
		motif.continue_screen[start.t_continue.fadeType .. '_time'],
		motif.continue_screen[start.t_continue.fadeType .. '_col'][1],
		motif.continue_screen[start.t_continue.fadeType .. '_col'][2],
		motif.continue_screen[start.t_continue.fadeType .. '_col'][3]
	)
	--frame transition
	main.f_cmdInput()
	if esc() or main.f_input(main.t_players, {'m'}) then
		esc(false)
		start.t_continue.active = false
		continueFlag = false
		return false
	end
	if not main.fadeActive and start.t_continue.fadeType == 'fadeout' then
		start.t_continue.active = false
		continueFlag = start.t_continue.continue
		return false
	end
	return true
end

--;===========================================================
--; STAGE MUSIC
--;===========================================================
function start.f_stageMusic()
	if main.flags['-nomusic'] ~= nil then
		return
	end
	if gamemode('demo') and (motif.demo_mode.fight_playbgm == 0 or motif.demo_mode.fight_stopbgm == 0) then
		return
	end
	if roundstart() then
		if roundno() == 1 then
			main.f_playBGM(true, start.t_music.music.bgmusic, 1, start.t_music.music.volume, start.t_music.music.bgmloopstart, start.t_music.music.bgmloopend)
			start.bgmstate = 0
		elseif start.bgmstate ~= 1 then
			if start.t_music.musicalt.bgmusic ~= nil and (start.t_music.bgmtrigger_alt == 0 or roundtype() == 3) then
				main.f_playBGM(true, start.t_music.musicalt.bgmusic, 1, start.t_music.musicalt.volume, start.t_music.musicalt.bgmloopstart, start.t_music.musicalt.bgmloopend)
				start.bgmstate = 1
			elseif start.bgmstate == 2 then
				main.f_playBGM(true, start.t_music.music.bgmusic, 1, start.t_music.music.volume, start.t_music.music.bgmloopstart, start.t_music.music.bgmloopend)
				start.bgmstate = 0
			end
		end
	elseif start.t_music.musiclife.bgmusic ~= nil and start.bgmstate ~= 2 and roundstate() == 2 then
		local p1cnt, p2cnt = 1, 1
		if start.p1TeamMode == 1 or start.p1TeamMode == 3 then --p1 simul or tag
			p1cnt = #start.t_p1Selected
		end
		if start.p2TeamMode == 1 or start.p2TeamMode == 3 then --p2 simul or tag
			p2cnt = #start.t_p2Selected
		end
		for i = 1, #start.t_p1Selected + #start.t_p2Selected do
			player(i) --assign sys.debugWC to player i
			if life() / lifemax() * 100 <= start.t_music.bgmratio_life then
				if teamside() == 1 then
					if p1cnt > 1 or alive() then
						p1cnt = p1cnt - 1
					end
				elseif p2cnt > 1 or alive() then
					p2cnt = p2cnt - 1
				end
			end
		end
		local bglife = false
		if start.t_music.bgmtrigger_life == 1 then
			bglife = p1cnt <= 0 or p2cnt <= 0
		else
			bglife = (p1cnt <= 0 and player(1) and roundtype() >= 2) or (p2cnt <= 0 and player(2) and roundtype() >= 2)
		end
		if bglife then
			main.f_playBGM(true, start.t_music.musiclife.bgmusic, 1, start.t_music.musiclife.volume, start.t_music.musiclife.bgmloopstart, start.t_music.musiclife.bgmloopend)
			start.bgmstate = 2
		end
	--elseif #start.t_music.musicvictory > 0 and start.bgmstate ~= -1 and matchover() then
	elseif #start.t_music.musicvictory > 0 and start.bgmstate ~= -1 and roundstate() == 3 then
		if start.t_music.musicvictory[1] ~= nil and player(1) and win() and (roundtype() == 1 or roundtype() == 3) then --assign sys.debugWC to player 1
			main.f_playBGM(true, start.t_music.musicvictory[1].bgmusic, 1, start.t_music.musicvictory[1].volume, start.t_music.musicvictory[1].bgmloopstart, start.t_music.musicvictory[1].bgmloopend)
			start.bgmstate = -1
		elseif start.t_music.musicvictory[2] ~= nil and player(2) and win() and (roundtype() == 1 or roundtype() == 3) then --assign sys.debugWC to player 2
			main.f_playBGM(true, start.t_music.musicvictory[2].bgmusic, 1, start.t_music.musicvictory[2].volume, start.t_music.musicvictory[2].bgmloopstart, start.t_music.musicvictory[2].bgmloopend)
			start.bgmstate = -1
		end
	end
end

return start
