require "luabench.utils"

local oo = require "loop.base"

local function confirm(current, value, name)
	if current ~= nil and current ~= value then
		error("different "..name.." found in the same file ("..current.." ~= "..value..")")
	end
	return value
end

local function ivalues(self, measure, freevars)
	if freevars == nil then freevars = 1 end
	local function ival(values, index, data)
		if data == nil then data = self[measure] end
		index = index+1
		if index > #self.variables-freevars then
			coroutine.yield(values, data)
		else
			local variable = self.variables[index]
			for _, value, valdata in isorted(data) do
				values[index] = value
				ival(values, index, valdata)
			end
		end
	end
	return coroutine.wrap(ival), {}, 0
end

local Matrix = oo.class()
function Matrix:__index(value)
	local matrix = Matrix()
	rawset(self, value, matrix)
	return matrix
end
function Matrix:__newindex(field, value)
	setmetatable(self, nil)
	return rawset(self, field, value)
end

--[[ function 'read' returns a table with type 'results' as described below
alias case = string
alias variable = string
alias dataval = number
alias varval = number
enum measure = {"used","memo","proc","time"}
table data = {
	[variable] = varval,
	[case] = { dataval... }
}
union result = { table { [varval] = result }, data }
table results = {
	name = string,
	cases = { case... },
	variables = { variable... },
	[measure] = result,
}
--]]
function read(file)
	file = assert(io.open(file))
	local test = { cases = {}, ivalues = ivalues }
	for _, measure in ipairs{"used","memo","proc","time"} do
		test[measure] = Matrix()
	end
	local colmeasure = {}
	local colcase = {}
	local colvar = {}
	local rowsize
	for line in file:lines() do
		if line:match("%S+") then
			if line:match("^#") then
				test.name = confirm(test.name, line:sub(2), "test names")
			else
				local row = assert(load("return {"..line.."}", nil, "t"))()
				rowsize = confirm(rowsize, #row, "row sizes")
				if type(row[1]) == "string" then
					for index, field in ipairs(row) do
						local case, measure = field:match("^(.-)%((%l+)%)$")
						if test[measure] then
							colmeasure[index] = confirm(colmeasure[index], measure, "column label")
							colcase[index] = confirm(colcase[index], case, "column label")
							if colcase[case] == nil then
								colcase[case] = true
								test.cases[#test.cases+1] = case
							end
						else
							colvar[index] = confirm(colvar[index], field, "column label")
						end
					end
					--TODO: check colvar is a proper array (containing only value at indices [1..n])
					test.variables = colvar
				else
					local varvals = {}
					for index, field in ipairs(row) do
						if index <= #colvar then
							varvals[index] = field
						else
							local point = test[colmeasure[index]]
							for _, value in ipairs(varvals) do
								point = point[value]
							end
							for i, name in ipairs(colvar) do
								point[name] = varvals[i]
							end
							local case = colcase[index]
							local values = point[case]
							if values == nil then
								values = {}
								point[case] = values
							end
							values[#values+1] = field
						end
					end
				end
			end
		end
	end
	file:close()
	return test
end
