local table = require "loop.table"

local cases = {
	table = {
		pack = "value = {'A','B','C'}",
		unpack = "v1,v2,v3 = value[1],value[2],value[3]",
	},
	closure = {
		pack = [[
			do
				local up1,up2,up3 = 'A','B','C'
				value = function() return up1,up2,up3 end
			end
		]],
		unpack = "v1,v2,v3 = value()",
	},
}

local pack = {}
local unpack = {}
for name, code in pairs(cases) do
	pack[name] = code.pack
	unpack[name] = {
		setup = code.pack,
		test = code.unpack,
	}
end

local configs = {
	repeats = 1e6,
	nocollect = true,
	setup = "local value,v1,v2,v3",
}

return table.copy(configs, {
	id = "pack",
	name = "Pack Values",
	cases = pack,
}), table.copy(configs, {
	id = "unpack",
	name = "Unpack Values",
	cases = unpack,
})
