return {
	id = "insert",
	name = "Element Insertion",
	repeats = 1e4,
	nocollect = true,
	variables = {
		count = { min = 100, max = 1000, name = "Elements inserted" },
	},
	cases = {
		ArrayTable = [[
		local array = {}
		for i = (-count), -1 do
			array[#array+1] = i
		end
		]],
		LinkedList = [[
		local list
		for i = (-count), -1 do
			list = {data=i, next=list}
		end
		]],
		OrderedSet = [[
		local next, head = {}
		for i = (-count), -1 do
			head, next[i] = i, head
		end
		]],
	}
}
