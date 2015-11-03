local table = require "loop.table"

local cases = {
	IndexConcat = {
		new = "local data = {}",
		ref = "data[i..i]",
	},
	NestedTables = {
		new = [[
			local data = setmetatable({}, {
				__index = function (self, k)
					local t = {}
					rawset(self, k, t)
					return t
				end
			})
		]],
		ref = "data[i][i]",
	},
}

local fillup = [[
	for i = (-count), -1 do
		$ref = i
	end
]]
local checkup = [[
	for i = (-count), -1 do
		if $ref ~= i then error("oops!") end
	end
]]

local put = {}
local get = {}
for name, code in pairs(cases) do
	local fill = fillup:tagged(code)
	put[name] = {
		setup = code.new,
		test = fill,
	}
	get[name] = {
		setup = code.new.."\n"..fill,
		test = checkup:tagged(code),
	}
end

local configs = {
	nocollect = true,
	variables = {
		count = { min = 1e5, max = 1e6, name = "Elements" },
	},
}

return table.copy(configs, {
	id = "put",
	name = "Put Elements",
	cases = put,
}), table.copy(configs, {
	id = "get",
	name = "Get Elements",
	cases = get,
})
