local table = require "loop.table"

local cases = {
	ArrayTable = {
		init = "local array = {}",
		push = "array[#array+1] = value",
		pop = "local top = #array; value, array[top] = array[top], nil",
	},
	CountedTable = {
		init = "local array, top = {}, 0",
		push = "top = top+1; array[top] = value",
		pop = "value, array[top], top = array[top], nil, top-1",
	},
	LinkedList = {
		init = "local list",
		push = "list = {data=value, next=list}",
		pop = "value, list = list.data, list.next",
	},
	OrderedSet = {
		init = "local next, head = {}",
		push = "head, next[value] = value, head",
		pop = "value, head, next[head] = head, next[head], nil",
	},
}

local fillup = [[
	$init
	for value = (-count), -1 do
		$push
	end
]]
local cleanup = [[
	for i = 1, count do
		local value
		$pop
		--if value ~= -i then error("oops!") end
	end
]]

local insert = {}
local remove = {}
for name, code in pairs(cases) do
	local fill = fillup:tagged(code)
	insert[name] = fill
	remove[name] = {
		setup = fill,
		test = cleanup:tagged(code),
	}
end

local configs = {
	nocollect = true,
	variables = {
		count = { min = 1e6, max = 1e7, name = "Elements" },
	},
}

return table.copy(configs, {
	id = "insert",
	name = "Insertion",
	cases = insert,
}), table.copy(configs, {
	id = "remove",
	name = "Removal",
	cases = remove,
})
