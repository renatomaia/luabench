local TableSetup = [[
	local action = {}
	for i = 1, cases do
		action[-i] = function() return i end
	end
	local function default() end
]]
local cases = {
	TableIndex = {
		setup = TableSetup,
		action = ";(action[case] or default)()",
	},
	MetaTable = {
		setup = TableSetup..[[
			setmetatable(action, {__index = function () return default end})
		]],
		action = "action[case]()",
	},
	NestedIf = {
		setup = [[
			local action = {[=[
				local case = ...
				if case==-1 then
			]=]}
			for i = 2, cases do
				action[i] = "elseif case==-"..i.." then return "..i
			end
			action[cases+1] = "end"
			action = assert(load(table.concat(action, "\n"), "t"))
		]],
		action = "action(case)",
	},
	NumericFor = {
		setup = [[
			local function action(case)
				for i = -1, -cases, -1 do
					if case == i then return -i end
				end
			end
		]],
		action = "action(case)",
	},
}

for id, case in pairs(cases) do
	case.test = [[
		local case = -(1+_ITERATION_%range)
		]]..case.action..[[
	]]
end

return {
	id = "action",
	name = "Action Switch",
	warmup = true,
	repeats = 2e5,
	variables = {
		cases = { min=4,max=20 },
		range = { min=8,max=40 },
	},
	cases = cases
}, {
	id = "returnval",
	name = "Value Selection",
	repeats = 1e4,
	nocollect = true,
	setup = [[
		local allchars = {}
		for i=0, 255 do
			allchars[i] = string.char(i)
		end
		local kind
	]],
	cases = {
		LogicOr = {
			test = [[
				for _, char in ipairs(allchars) do
					if char == 'a' or
					   char == 'b' or
					   char == 'c' or
					   char == 'd' or
					   char == 'e' or
					   char == 'f' or
					   char == 'g' or
					   char == 'h' or
					   char == 'i' or
					   char == 'j' or
					   char == 'k' or
					   char == 'l' or
					   char == 'm' or
					   char == 'n' or
					   char == 'o' or
					   char == 'p' or
					   char == 'q' or
					   char == 'r' or
					   char == 's' or
					   char == 't' or
					   char == 'u' or
					   char == 'v' or
					   char == 'w' or
					   char == 'x' or
					   char == 'y' or
					   char == 'z' then
						kind = "lower"
					elseif char == '0' or
					       char == '1' or
					       char == '2' or
					       char == '3' or
					       char == '4' or
					       char == '5' or
					       char == '6' or
					       char == '7' or
					       char == '8' or
					       char == '9' then
						kind = "digit"
					end
					kind = "unknown"
				end
			]],
		},
		NestedIf = {
			test = [[
				for _, char in ipairs(allchars) do
					if char == 'a' then kind = "lower"
					elseif char == 'b' then kind = "lower"
					elseif char == 'c' then kind = "lower"
					elseif char == 'd' then kind = "lower"
					elseif char == 'e' then kind = "lower"
					elseif char == 'f' then kind = "lower"
					elseif char == 'g' then kind = "lower"
					elseif char == 'h' then kind = "lower"
					elseif char == 'i' then kind = "lower"
					elseif char == 'j' then kind = "lower"
					elseif char == 'k' then kind = "lower"
					elseif char == 'l' then kind = "lower"
					elseif char == 'm' then kind = "lower"
					elseif char == 'n' then kind = "lower"
					elseif char == 'o' then kind = "lower"
					elseif char == 'p' then kind = "lower"
					elseif char == 'q' then kind = "lower"
					elseif char == 'r' then kind = "lower"
					elseif char == 's' then kind = "lower"
					elseif char == 't' then kind = "lower"
					elseif char == 'u' then kind = "lower"
					elseif char == 'v' then kind = "lower"
					elseif char == 'w' then kind = "lower"
					elseif char == 'x' then kind = "lower"
					elseif char == 'y' then kind = "lower"
					elseif char == 'z' then kind = "lower"
					elseif char == '0' then kind = "digit"
					elseif char == '1' then kind = "digit"
					elseif char == '2' then kind = "digit"
					elseif char == '3' then kind = "digit"
					elseif char == '4' then kind = "digit"
					elseif char == '5' then kind = "digit"
					elseif char == '6' then kind = "digit"
					elseif char == '7' then kind = "digit"
					elseif char == '8' then kind = "digit"
					elseif char == '9' then kind = "digit" end
					kind = "unknown"
				end
			]],
		},
		TableIndex = {
			setup = [[
				local allchars = {}
				for i=0, 255 do
					allchars[i] = string.char(i)
				end
				local kind
				local KindOf = {
					['a'] = "lower",
					['b'] = "lower",
					['c'] = "lower",
					['d'] = "lower",
					['e'] = "lower",
					['f'] = "lower",
					['g'] = "lower",
					['h'] = "lower",
					['i'] = "lower",
					['j'] = "lower",
					['k'] = "lower",
					['l'] = "lower",
					['m'] = "lower",
					['n'] = "lower",
					['o'] = "lower",
					['p'] = "lower",
					['q'] = "lower",
					['r'] = "lower",
					['s'] = "lower",
					['t'] = "lower",
					['u'] = "lower",
					['v'] = "lower",
					['w'] = "lower",
					['x'] = "lower",
					['y'] = "lower",
					['z'] = "lower",
					['0'] = "digit",
					['1'] = "digit",
					['2'] = "digit",
					['3'] = "digit",
					['4'] = "digit",
					['5'] = "digit",
					['6'] = "digit",
					['7'] = "digit",
					['8'] = "digit",
					['9'] = "digit",
				}
			]],
			test = [[
				for _, char in ipairs(allchars) do
					kind = KindOf[tag] or "unknown"
				end
			]],
		},
	}
}

