local TableClass = [[
local oo = require(_CASE_)

local Class = { attribute = "value" }
function Class:method()
	-- empty
end
function Class:overriden()
	-- empty
end
function Class:getter()
	return self.private
end
function Class:getnil()
	return self.missing
end

if _CASE_ == "loop.scoped" then
	Class = {
		public = Class,
		private = { private = "value" },
	}
else
	Class.private = "value"
end

Class = oo.class(Class)
if _CASE_ ~= "loop.base" then
	for i = 2, depth do
		Class = oo.class({}, Class, oo.class())
		function Class:overriden()
			-- empty
		end
	end
end
]]

local ClosureClass = [[
local oo = require(_CASE_)

local Class = oo.class(function(self)
	oo.become(self)
	attribute = "value"
	local private = "value"
	function method()
		-- empty
	end
	function overriden()
		-- empty
	end
	function getter()
		return private
	end
	function getnil()
		return missing
	end
end)

for i = 2, depth do
	local Super1, Super2 = Class, oo.class(function() end)
	Class = oo.class(function(self)
		oo.become(self)
		oo.inherit(Super1, self)
		oo.inherit(Super2, self)
		function overriden()
			-- empty
		end
	end)
end
]]

local Tests = {
	newcls    = TableClass,
	newobj    = "obj[_ITERATION_] = Class()",
	clsatt    = "local _ = obj.attribute",
	nilatt    = "local _ = obj.missing",
	empty     = "obj:method()",
	overriden = "obj:overriden()",
	getter    = "obj:getter()",
	getnil    = "obj:getnil()",
}

local ClosureTests = {
	newcls    = ClosureClass,
	empty     = "obj.method()",
	overriden = "obj.overriden()",
	getter    = "obj.getter()",
	getnil    = "obj.getnil()",
}

for name, test in pairs(Tests) do
	if ClosureTests[name] == nil then
		ClosureTests[name] = test
	end
end

local Models = {
	base      = false,
	simple    = false,
	multiple  = false,
	--multiple2 = false,
	cached    = false,
	scoped    = false,
	--static    = ClosureTests,
}

local variables = { depth = { max=5, name="Class hierarchy depth" } }

local tests = {}
for name in pairs(Tests) do
	local cases = {}
	for model, tests in pairs(Models) do
		local specs = true
		if tests then
			specs = {
				test = tests[name],
				setup = (name~="newcls")
				        and tests.newcls.."\nlocal obj = Class()"
				         or nil
			}
		end
		cases["loop."..model] = specs
	end
	tests[#tests+1] = {
		id = name,
		variables = variables,
		repeats = (name=="newcls") and 1e4 or 1e6,
		test = Tests[name],
		setup = (name~="newcls")
		        and Tests.newcls.."\nlocal obj = Class()"
		         or nil,
		cases = cases,
	}
end
return table.unpack(tests)
