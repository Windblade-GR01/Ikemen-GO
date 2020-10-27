-- this module allow to parse .def file, and modify it while keeping the
-- original template.

file_def = {}

-- parse a line of a .def file. Return a dictionary with key:
--
-- "kind": common for every line, can either be "empty" (contain no data),
--   "section", contain a section, and "data", contain data
-- "initial_withespace": the whitespace before the beggining of the data/comment
--   /end of line.
-- "have_comment": true if this line contain a comment
-- "comment": if this line have a comment, its stored here (without the ";")
-- "section": if this line is a section header, this is the contained section
-- "end_well": if this line is a section header, it is set to false if the line
--   doesn't end by "]" as expected
-- "data": if this line contain data, this is the data it contain
function file_def.parse_line(line)
	local result = {}
	local line_without_initial_space = ""
	local initial_space = ""
	local comment = ""
	local in_comment = false
	local first_char_meet = false
	for char_id = 1, #line do
		local char = line:sub(char_id, char_id)
		if not first_char_meet then
			if char == " " or char == "\t" then
				initial_space = initial_space .. char
			else
				first_char_meet = true
			end
		end
		if first_char_meet then
			if char == ";" then
				in_comment = true
			elseif in_comment then
				comment = comment .. char
			else
				line_without_initial_space = line_without_initial_space .. char
			end
		end
	end
	result["initial_whitespace"] = initial_space
	line = line_without_initial_space

	if in_comment then
		result["have_comment"] = true
		result["comment"] = comment
	else
		result["have_comment"] = false
	end

	if line:len() == 0 then
		result["kind"] = "empty"
	elseif line:sub(1, 1) == "[" then
		result["kind"] = "section"
		if not (line:sub(-1, -1) == "]") then
			print("warning: a .def file have the section header " .. line .. "that doesn't end with \"]\". considering it as " .. line:sub(2))
			result["section"] = line:sub(2)
			result["end_well"] = false
		else
			result["section"]  = line:sub(2, -2)
			result["end_well"] = true
		end
	else
		result["kind"] = "data"
		result["data"] = line
	end
	return result
end

-- recreate the .def file from a list of dictionary returned by def_parse_line
function file_def.rebuild_source_file(parsed)
	local result = ""
	for line_id = 1, #parsed do
		local line = parsed[line_id]
		result = result .. line["initial_whitespace"]
		if line["kind"] == "section" then
			result = result .. "[" .. line["section"]
			if line["end_well"] then
				result = result .. "]"
			end
		elseif line["kind"] == "data" then
			result = result .. line["data"]
		end
		if line["have_comment"] then
			result = result .. ";" .. line["comment"]
		end
		if not (line_id == #parsed) then
			result = result .. "\n"
		end
	end
	return result
end

function file_def.parse_char_line(data)
	local result = {}
	local data_str = ""
	result["config"] = {}

	for j, c in ipairs(main.f_strsplit(',', data)) do
		if j == 1 then
			result["name"] = c
		else
			data_str = data_str .. c .. ","
		end
	end
	result["option"] = file_def.parse_arg(data_str)
	return result
end

function file_def.rebuild_char(char)
	local result = char["name"] .. ", " .. file_def.arg_to_string(char.option)
	return result
end

-- TODO: use this function inside the various main.lua use of those value
function file_def.parse_arg_inner(arg, char_id)
	local result = {numerical = {}, named={}}
	local pre_equal = ""
	local is_post_equal = false
	local post_equal = ""

	while char_id <= #arg do
		char_id = char_id + 1
		char = arg:sub(char_id, char_id)
		if char == "{" then
			local ret = file_def.parse_arg_inner(arg, char_id)
			char_id = ret.pos
			if is_post_equal then
				post_equal = ret.value
			else
				pre_equal = ret.value
			end
		elseif char == "}" then
			if is_post_equal then
				result.named[pre_equal] = post_equal
			else
				table.insert(result.numerical, pre_equal)
			end
			pre_equal = ""
			post_equal = ""
			is_post_equal = false
			return {value=result, pos=char_id}

		elseif char == "=" then
			is_post_equal = true
		elseif char == " " and pre_equal == "" then
		elseif char == "," then
			if is_post_equal then
				result.named[pre_equal] = post_equal
			else
				table.insert(result.numerical, pre_equal)
			end
			pre_equal = ""
			post_equal = ""
			is_post_equal = false

		else
			if is_post_equal then
				if type(post_equal) == "string" then
					post_equal = post_equal .. char
				end
			else
				if type(pre_equal) == "string" then
					pre_equal = pre_equal .. char
				end
			end
		end
	end

	if is_post_equal then
		result.named[pre_equal] = post_equal
	else
		table.insert(result.numerical, pre_equal)
	end
	pre_equal = ""
	post_equal = ""
	is_post_equal = false

	return {value=result, pos=char_id}
end

function file_def.parse_arg(arg)
	return file_def.parse_arg_inner(arg , 0).value
end

function file_def.arg_to_string(arg)
	if arg == nil then
		return ""
	end
	result = ""
	main.f_printTable(arg, "arg_to_string.txt")
	for k, v in ipairs(arg.numerical) do
		if v ~= nil and v ~= "" then
			if type(v) == "table" then
				result = result .. "{" .. file_def.arg_to_string(v) .. "},"
			else
				result = result .. v .. ","
			end
		end
	end

	for k, v in pairs(arg.named) do
		if v ~= nil and v ~= "" then
			if type(v) == "table" then
				result = result .. k .. "={" .. file_def.arg_to_string(v) .. "},"
			else
				result = result .. k  .. "=" .. v .. ","
			end
		end
	end
	return result:sub(1, -2)
end

function file_def.get_default_option()
	return {numerical={}, named={}}
end

return file_def
