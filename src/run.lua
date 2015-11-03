#!/usr/bin/env lua

require "luabench.test"

local path = ...
local default = {}
local tests = {}
local list = { dofile(path.."/benchmark.lua") }
for _, test in ipairs(list) do
	if test.id == nil and tests.benchmark == nil then
		test.id = "benchmark"
	end
	tests[test.id] = test
	default[#default+1] = test.id
end

if select("#", ...) < 2 then
	selection = default
else
	selection = {select(2, ...)}
end

for _, id in ipairs(selection) do
	local test = tests[id]
	if test ~= nil then
		Test(test):run(path, id)
	else
		io.stderr:write("WARNING: no test with id '",id,"' was found.")
	end
end
