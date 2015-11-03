local cases = {
	IndexConcat = {
		new = 'local map = {}',
		ref = 'map[host..":"..port]',
	},
	NestedTables = {
		new = [[
			local map = setmetatable({}, {
				__index = function (self, k)
					local t = {}
					rawset(self, k, t)
					return t
				end
			})
		]],
		ref = 'map[host][port]',
	},
	LuaTuple = {
		new = [[
			local tuples = require("tuple").index
			local map = {}
		]],
		ref = 'map[tuples[host][port]]',
	},
}

local setup = [[
	local lastcode = string.byte("Z")
	local function nextstr(text)
		for i = #text, 1, -1 do
			local code = text:byte(i)
			if code < lastcode then
				return text:sub(1,i-1)..string.char(code+1)..string.rep("A", #text-i)
			end
		end
		return string.rep("A", #text+1)
	end

	local entries = {}
	local host = "AAAA"
	for i = 1, count do
		entries[i] = {host=nextstr(host),port=999+i}
	end

	$new
]]

local body = [[
	for _, entry in ipairs(entries) do
		local host, port = entry.host, entry.port
		$ref = entry
	end
	for _, entry in ipairs(entries) do
		local host, port = entry.host, entry.port
		assert($ref == entry)
	end
	for _, entry in ipairs(entries) do
		local host, port = entry.host, entry.port
		$ref = nil
	end
]]

local testcase = {}
for name, code in pairs(cases) do
	testcase[name] = {
		setup = setup:tagged(code),
		test = body:tagged(code),
	}
end

local repeats = 1e3

return {
	name = "Insert/Check/Remove Addresses",
	warmup = true,
	nocollect = true,
	repeats = repeats,
	variables = { count = { min=1e2, max=1e3, name="Addresses" } },
	cases = testcase,
}
