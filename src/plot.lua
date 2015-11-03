#!/usr/bin/env lua

local module = ...

require("luabench.plot."..(...))

for index = 2, select("#", ...) do
	local path = select(index, ...)
	plot(path:match("^(.+)%.csv$") or path)
end
