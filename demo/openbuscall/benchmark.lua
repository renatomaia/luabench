local busconsole = "openbuscall/busconsole"
local setupbody = [[
	os.remove("openbuscall/ref.ior")
	local process = require "process"
	local oil = require "oil"
	process.create("openbuscall/busconsole", "DEBUG", "-e", [=[
		package.cpath=[==[openbuscall/?.so]==]
		local oil = require "oil"
		$server
	]=])
	$client
]]
local newservant = [[
	orb:loadidlfile("openbuscall/service.idl")
	oil.writeto("openbuscall/ref.ior", orb:newservant{
		__type = "DummyService",
		operation = function() end,
		shutdown = function() orb:shutdown() end,
	})
]]
local newproxy = [[
	orb:loadidlfile("openbuscall/service.idl")
	local ior
	for i = 1, 50 do
		ior = oil.readfrom("openbuscall/ref.ior")
		if ior ~= nil then break end
		oil.sleep(.1)
	end
	oil.sleep(.1)
	assert(ior, "IOR file not found!")
	local service = orb:newproxy(ior, nil, "DummyService")
	local data = {}
	math.randomseed(os.time())
	for i = 1, datasize do
		data[i] = string.char(math.random(0, 255))
	end
	data = table.concat(data)
]]
local initoilssl = [[
	local orb = oil.init{
		flavor = "cooperative;corba;corba.ssl;kernel.ssl",
		options = {
			security = "required",
			ssl = {
				key = "openbuscall/certs/$cert.key",
				certificate = "openbuscall/certs/$cert.crt",
				cafile = "openbuscall/certs/myca.crt",
			},
		},
	}
]]
local busconnect = [[
	local openbus = require "openbus"
	local log = require("openbus.util.logger")
	--log:level(5)
	--log.viewer.output = assert(io.open("openbus.log", "w"))
	local orb = openbus.initORB()
	local conn = orb.OpenBusContext:createConnection("localhost", 2089, {nolegacy=true})
	conn.legacy = nil
	orb.OpenBusContext:setDefaultConnection(conn)
	conn:loginByPassword("testuser", "testuser", "testing")
]]

return {
	name = "Service Invocation",
	warmup = true,
	repeats = 1e2,
	lua = busconsole.." DEBUG -e package.cpath=[[openbuscall/?.so]]",
	gettime = "require('socket.core').gettime",
	variables = {
		datasize = { min=0, max=0x1p10, step=0x1p10, name="OctetSeqSize" },
	},
	test = [[
		service:operation(data)
	]],
	teardown = [[
		service:shutdown()
		orb:shutdown()
	]],
	cases = {
		CORBA = {
			setup = setupbody:tagged{
				client = "local orb = oil.init()"..newproxy,
				server = "local orb = oil.init()"..newservant,
			},
		},
		CORBASSL = {
			setup = setupbody:tagged{
				client = initoilssl:tagged{cert="client"}..newproxy,
				server = initoilssl:tagged{cert="server"}..newservant,
			},
		},
		OpenBus = {
			setup = setupbody:tagged{
				client = busconnect..newproxy,
				server = busconnect..newservant:gsub("orb:shutdown%(%)",
				                                     "conn:logout();orb:shutdown()"),
			},
			teardown = [[
				service:shutdown()
				conn:logout()
				orb:shutdown()
			]]
		},
	}
}
