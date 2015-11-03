require "luabench.utils"

local oo = require "loop.base"

local TestWarmUp = [[
do
	local env = setmetatable({}, { __index = _G })
	local function warmup(_ENV)
		local _START_ = _USAGE_()
		for _ITERATION_ = 1, $repeats do
			$testcode
			if _USAGE_()-_START_ > 1 then break end
		end
	end
	pcall(setfenv, warmup, env)
	warmup(env)
end
]]

local TestTemplate = [=[
local _NOW_ = $gettime
local _USAGE_ = $cputime
local _TESTID_ = "$testid"
local _TEST_ = [[$testname]]
local _CASE_ = [[$casename]]
$variables

-- setup environment
$setup

-- test warm up ?
$warmup

-- disable garbage collection ?
$collect

-- memory clean up ?
$cleanup

-- execute tests
local _TIME_ = _NOW_ and _NOW_()
local _CPU_ = _USAGE_()
for _ITERATION_ = 1, $repeats do
	$testcode
end
_CPU_ = _USAGE_()-_CPU_
_TIME_ = _TIME_ and _NOW_()-_TIME_

-- tear down environment
$teardown

local total = collectgarbage("count")
collectgarbage("collect")
local collected = collectgarbage("count")

-- write results
io.write(collected,",",total,",",_CPU_)
if _TIME_ then
	io.write(",",_TIME_)
end
]=]

local function values(vars)
	local values = {}
	local function ival(vars, index)
		index = index+1
		local var = vars[index]
		if var == nil then
			coroutine.yield(values)
		else
			for value = var.min, var.max, var.step do
				values[index] = value
				ival(vars, index)
			end
		end
	end
	return coroutine.wrap(ival), vars, 0
end

local function compname(one, other)
	return one.name < other.name
end

Test = oo.class{
	id        = "benchmark",
	name      = nil,
	repeats   = 1,   -- number of repetitions of the test code at each test
	nocollect = nil, -- disable automatic garbage collection during the test
	nocleanup = nil, -- do not collect garbage before the test
	warmup    = "",  -- warm up code or 'true' to calculate a proper value
	setup     = "",  -- code to be executed once before of the test
	teardown  = "",  -- code to be executed once after of the test
	code      = nil, -- code being evaluated
}

function Test:__new(...)
	self = oo.rawnew(self, ...)
	if self.name == nil then self.name = self.id end
	if self.cases == nil then self.cases = {} end
	if self.variables == nil then self.variables = {} end
	local Case = oo.class{ __index = self }
	for name, case in pairs(self.cases) do
		if case == true then
			case = {}
		elseif type(case) == "string" then
			case = { test = case }
		end
		if case.name == nil then case.name = name end
		self.cases[name] = Case(case)
	end
	local variables = {}
	for id, info in pairs(self.variables) do
		if info == true then
			info = {}
		elseif type(info) == "string" then
			info = { name = info }
		end
		if info.id == nil then info.id = id end
		if info.name == nil then info.name = id end
		if info.min == nil then info.min = 1 end
		if info.max == nil then info.max = info.min end
		if info.step == nil then info.step = info.min end
		variables[#variables+1] = info
	end
	table.sort(variables, compname)
	self.variables = variables
	return self
end

function Test:run(path, selection)
	msg("[",self.name,"]")
	local output = path.."/"..selection..".csv"
	
	appendto(output, "#",self.name,"\n")
	
	local varfmt = {}
	local header = {}
	for _, var in ipairs(self.variables) do
		varfmt[#varfmt+1] = var.id.."=%g"
		header[#header+1] = string.format("%q", var.name)
	end
	for _, _, case in isorted(self.cases) do
		header[#header+1] = string.format("%q", case.name.."(used)")
		header[#header+1] = string.format("%q", case.name.."(memo)")
		header[#header+1] = string.format("%q", case.name.."(proc)")
		if case.gettime then
			header[#header+1] = string.format("%q", case.name.."(time)")
		end
	end
	appendto(output, table.concat(header, ","),",\n")
	
	for vals in values(self.variables) do
		
		local initvars
		if #vals > 0 then
			msg("\n  ",string.format(table.concat(varfmt, " "), table.unpack(vals)))
			appendto(output, table.concat(vals, ","),",")
			initvars = {}
			for index, var in ipairs(self.variables) do
				initvars[#initvars+1] = "local "..var.id.." = "..vals[index]
			end
			initvars = table.concat(initvars, "\n")
		end
		
		msg(" ")
		
		for _, _, case in isorted(self.cases) do
			msg(".")
			local info = {
				testid    = self.id,
				testname  = self.name,
				repeats   = self.repeats,
				variables = initvars or "",
				cputime   = case.cputime or "os.clock",
				gettime   = case.gettime or "nil",
				casename  = case.name,
				testcode  = case.test,
				setup     = case.setup,
				teardown  = case.teardown,
				collect   = case.nocollect and "collectgarbage('stop')" or "",
				cleanup   = case.nocleanup and "" or "collectgarbage('collect')",
				warmup    = case.warmup,
			}
			if info.warmup == true then
				info.warmup = TestWarmUp:tagged(info)
			end
			local used, memo, proc, time = runscript(TestTemplate:tagged(info), case.lua)
			appendto(output, used,",",memo,",",proc,",")
			if case.gettime then
				appendto(output, time,",")
			end
		end
		msg(" done")
		appendto(output, "\n")
	end
	msg("\n")
end
