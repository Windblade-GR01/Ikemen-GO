navigation_tip = {}
navigation_tip.generation = 0

function navigation_tip.generate(data) -- TODO: transform this to keyboard keys
	result = ""
	for _, action in ipairs(data) do
		result = result .. action.name .. ":"
		for _, key in ipairs(action.keys) do
			result = result .. key .. " "
		end
		result = result .. "  "
	end
	return { text = result, height = motif.navigation_tip.tip_font_height + motif.navigation_tip.tip_extra_space_bottom + motif.navigation_tip.tip_extra_space_top} --TODO: correct height (proportional to height and text size)
end


navigation_tip.draw_text = text:create({
	font = motif.navigation_tip.tip_font[1],
	bank = motif.navigation_tip.tip_font[2],
	align = motif.navigation_tip.tip_font[3],
	text = "placeholder",
	x = config.GameWidth/50,
	y = nil,
	scaleX = motif.navigation_tip.tip_font_scale[1],
	scaleY = motif.navigation_tip.tip_font_scale[2],
	r = motif.navigation_tip.tip_font[4],
	g = motif.navigation_tip.tip_font[5],
	b = motif.navigation_tip.tip_font[6],
	src = motif.navigation_tip.tip_font[7],
	dst = motif.navigation_tip.tip_font[8],
	defsc = true
	--TODO: height, defsc too
})

function navigation_tip.draw(generated)
	navigation_tip.draw_text:update({
		text = generated.text,
		y = GameHeight + motif.navigation_tip.tip_font_lower_diff - motif.navigation_tip.tip_extra_space_bottom
	})

	fillRect(
		0,
		GameHeight - generated.height,
		GameWidth * 2,
		generated.height * 2,
		motif.navigation_tip.tip_background[1],
		motif.navigation_tip.tip_background[2],
		motif.navigation_tip.tip_background[3],
		motif.navigation_tip.tip_background[4],
		motif.navigation_tip.tip_background[5]
	)
	navigation_tip.draw_text:draw(true)
end

return navigation_tip
