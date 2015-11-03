require "debug"

function string:tagged(tags)
	return (self:gsub("$(%l+)", tags))
end

function msg(...)
	io.write(...)
	io.flush()
end

function appendto(file, ...)
	local file = assert(io.open(file, "a"))
	file:write(...)
	file:close()
end

function writeto(file, ...)
	local file = assert(io.open(file, "w"))
	file:write(...)
	file:close()
end

function readall(file)
	local file = assert(io.open(file))
	local contents = file:read("*a")
	file:close()
	return contents
end

function runscript(input, command)
	if input ~= nil then
		if command == nil then command = "lua" end
		writeto("input.tmp", input)
		writeto("output.tmp", "return ")
		assert(os.execute(command.." input.tmp >> output.tmp"))
		local output = assert(loadfile("output.tmp"))
		os.remove("input.tmp")
		os.remove("output.tmp")
		return output()
	end
end

function runcommand(command, input)
	if input == nil then
		assert(os.execute(command))
	else
		local exec = assert(io.popen(command, "w"))
		exec:write(input)
		assert(exec:close())
	end
end

function mean(values)
	local mean = 0
	local deviation = 0
	local count = #values
	if count > 0 then
		for i = 1, count do
			local value = values[i]
			mean = mean + value
			deviation = deviation + value^2
		end
		mean = mean/count
		deviation = (deviation/count - mean^2)^.5
	end
	return mean, deviation, count
end

local function iter(seq, index)
	index = index+1
	local key = seq[index]
	if key ~= nil then
		return index, key, rawget(seq.data, key)
	end
end
function isorted(data)
	local seq = {data=data}
	for value in pairs(data) do
		seq[#seq+1] = value
	end
	table.sort(seq)
	return iter, seq, 0
end

