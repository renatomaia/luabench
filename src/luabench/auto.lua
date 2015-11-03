module("luabench.auto", package.seeall)

local CalcMax = [[
local function round(number, base)
	if not base then base = 1 end
	local remainder = number%base
	if remainder >= base/2 then
		number = number + base
	end
	return number - remainder 
end
local _NOW_ = gettime or require("socket").gettime

local max_$variable -- used only in code 'result'
local $variable = $min
local _MIN$i_ = $variable
local _MAX$i_
local _POS$i_ = 0
repeat
	$action
	if $condition then -- '$variable' is still too small
		_MIN$i_ = $variable
		if _MAX$i_ then
			$variable = round((_MIN$i_ + _MAX$i_)/2, $step)
		else
			$variable = 2^_POS$i_ * $step
			_POS$i_ = _POS$i_ + 1
		end
	elseif not _MAX$i_ or (_MAX$i_-_MIN$i_) > $step then
		_MAX$i_ = $variable
		$variable = round((_MIN$i_ + _MAX$i_)/2, $step)
	else
		max_$variable = math.max(max_$variable or $min, $variable)
		$result
		break
	end
until false
local result = $variable
]]

function calcIterations(test, timeout)
	local variables = {}
	for name, info in pairs(test.variables) do
		variables[#variables+1] = "local "..name.." = "..info.min
	end
	variables = table.concat(variables, "\n")
	local script = variables.."\n"..CalcMax:tagged{
		i = "",
		variable = "iterations",
		min = 1,
		step = 1,
		action = [[
local _TIME_ = _NOW_()
local _CASE_ = $label
for _REPEAT_ = 1, iterations do
	$test
end
_TIME_ = _NOW_()-_TIME_
]],
		condition = "_TIME_ < "..timeout,
		result = "print(iterations)",
	}
	
	msg("Finding iterations ... ")
	
	local minimum
	for name, case in pairs(test.cases) do
		local min = runscript(script:tagged(case))
		if minimum == nil or minimum > min then
			minimum = min
		end
	end
	
	msg(minimum, "\n")
	
	return minimum
end

function calcExecutions(test, timeout)
	local variables = {}
	for name, info in pairs(test.variables) do
		variables[#variables+1] = "local "..name.." = "..info.min
	end
	variables = table.concat(variables, "\n")
	local script = variables.."\n"..CalcMax:tagged{
		i = "",
		variable = "executions",
		min = 1,
		step = 1,
		action = [[
local _TIME_ = _NOW_()
local _CASE_ = $label
for execution = 1, executions do
	for _REPEAT_ = 1, $iterations do
		$test
	end
end
_TIME_ = _NOW_()-_TIME_
]],
		condition = "_TIME_ < "..timeout,
		result = "print(executions)",
	}
	
	msg("Finding steps ... ")
	
	local minimum
	for name, case in pairs(test.cases) do
		local min = runscript(script:tagged(case))
		if minimum == nil or minimum > min then
			minimum = min
		end
	end
	
	msg(minimum, "\n")
	
	return minimum
end

function calcVarMaxs(test, timeout)
	local provided = {}
	local variables = {}
	for name, info in pairs(test.variables) do
		if info.max == nil then
			variables[name] = info
		else
			provided[#provided+1] = "local "..name.." = "..info.max
		end
	end
	local names = {} -- all names of variables without max
	local unpack = {} -- to unpack the results found (solutions)
	local normal = {} -- normalized values (percentual in relation to the max)
	local diff = {} -- distance from other other variables in rel. to the max
	local answer = {} -- add values to the result table (a solution)
	for name in pairs(variables) do
		names[#names+1] = name
		unpack[#unpack+1] = "sol."..name
		normal[#normal+1] = "local normal_"..name.."="..name.."/max_"..name
		local other = next(variables, name)
		while other do
			diff[#diff+1] = "math.abs(normal_"..name.."-normal_"..other..")"
			other = next(variables, other)
		end
		answer[#answer+1] = name.."="..name
	end
	provided = table.concat(provided, "\n")
	unpack = "local "..table.concat(names, ", ").." = "..
	                   table.concat(unpack, ", ")
	normal = table.concat(normal, "\n")
	if #diff > 0 then
		diff = table.concat(diff, "+")
	else
		diff = "0"
	end
	answer = table.concat(answer, ",")
	
	local i = 1
	local name, info = next(variables)
	if name then
		local script = CalcMax:tagged{
			i = i,
			variable = name,
			min = info.min,
			step = info.step,
			action = [[
	local _TIME_ = _NOW_()
	local _CASE_ = $label
	for iteration = 1, $iterations do
		$test
	end
	_TIME_ = _NOW_()-_TIME_
	]],
			condition = "_TIME_ < "..timeout,
			result = [[_SOLUTIONS_[#_SOLUTIONS_+1] = {_TIME_,]]..answer..[[}]],
		}
		name, info = next(variables, name)
		while name do
			i = i+1
			script = CalcMax:tagged{
				i = i,
				variable = name,
				min = info.min,
				step = info.step,
				action = script:gsub("\n", "\n\t"),
				condition = "result > "..info.min,
				result = "",
			}
			name, info = next(variables, name)
		end
		script = [[
local _NOW_ = gettime or require("socket").gettime
local _SOLUTIONS_ = {}
]]..provided..[[ 
]]..script..[[ 
local min = math.huge
local best
for _, sol in ipairs(_SOLUTIONS_) do
	]]..unpack..[[ 
	]]..normal..[[ 
	local diff = ]]..diff..[[ 
	if diff < min then
		min = diff
		best = sol
	end
end
io.write("{",best[1],",")
best[1] = nil
for name, value in pairs(best) do
	io.write(name,"=",value,",")
end
print("}")
]]
		
		msg("Finding maximums ... ")
		
		local maximums
		for name, case in pairs(test.cases) do
			local maxs = runscript(script:tagged(case))
			if maximums == nil or maximums[1] > maxs[1] then
				maximums = maxs
			end
		end
		maximums[1] = nil
		for name, max in pairs(maximums) do
			varinfos[name].max = max
		end
		
		msg("done")
		
	end
end
