require "luabench.results"

local Measures = {
	{ id = "memo", label = "Memory allocated (kilobytes)" },
	{ id = "used", label = "Memory used (kilobytes)" },
	{ id = "gprc", label = "GC CPU time used (seconds)" },
	{ id = "gtim", label = "GC time elapsed (seconds)" },
	{ id = "proc", label = "CPU time used (seconds)" },
	{ id = "time", label = "Time elapsed (seconds)" },
}

local VarHeader = "%-10.10s"
local DatHeader = "%-20.20s"
local VarColumn = "%10.5g"
local DatColumn = "%10.5g (%7.1e)"

local function writerow(output, cases, datum)
	for i, case in ipairs(cases) do
		output:write(DatColumn:format(mean(datum[case]))," | ")
	end
	output:write("\n")
end

function plot(path)
	results = read(path..".csv")
	local cases = results.cases
	local variables = results.variables
	local varlabel = variables[#variables]
	local output = assert(io.open(path..".txt", "w"))
	output:write("#\n# ",results.name,"\n")
	output:write("# Date: ",os.date(),"\n#\n")
	for _, measure in ipairs(Measures) do
		if next(results[measure.id]) ~= nil then
			output:write(string.rep("_", #measure.label),"\n")
			output:write(measure.label,"\n")
			for values, data in results:ivalues(measure.id) do
				output:write("\n")
				for i = 1, #variables-1 do
					output:write(VarHeader:format(variables[i])," = ",VarColumn:format(values[i]),"\n")
				end
				if varlabel ~= nil then
					output:write(VarHeader:format(varlabel)," | ")
				end
				for i, case in ipairs(cases) do
					output:write(DatHeader:format(case)," | ")
				end
				output:write("\n")
				if varlabel ~= nil then
					for _, value, datum in isorted(data) do
						output:write(VarColumn:format(datum[varlabel])," | ")
						writerow(output, cases, datum)
					end
				else
					writerow(output, cases, data)
				end
			end
		end
	end
	output:close()
end
