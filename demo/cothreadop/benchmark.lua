local setup = [[
	local resume = coroutine.resume
	local status = coroutine.status
	local yield = coroutine.yield
	
	local function action(...) return ... end
	local yieldops = { action = action }
	local function dothread(thread, success, opname, ...)
		if success and status(thread) ~= "dead" and opname ~= nil then
			return dothread(thread, resume(thread, yieldops[opname](...)))
		end
		return success, opname, ...
	end

	local thread = coroutine.create(function(...)
		while true do
			for i = 1, count do
				$call
			end
			yield()
		end
	end)
]]

return {
	name = "CoThread Scheduler Operation",
	warmup = true,
	nocollect = true,
	repeats = 1e5,
	variables = { count = { min=1e1, max=1e2, name="Calls" } },
	test = "assert(dothread(thread, resume(thread)))",
	cases = {
		ModuleFunction = {setup=setup:tagged{call='yieldops.action(...)'}},
		YieldParameter = {setup=setup:tagged{call='coroutine.yield("action")'}},
	},
}
