require "luabench.results"

local PlotHeader = [[
set terminal svg
set output '$path$measure$suffix.svg'
set title "$title"
set ylabel "$ylabel"
]]

local Plot1D = PlotHeader..[[
set style fill solid 0.25 border lt -1
set boxwidth .5 # relative
set xrange [-.5:$xmax]
set style data boxerrorbars
plot "$path.dat" \
	index "$measure" \
	using 0:2:3:0:xticlabels(1) \
	notitle \
	lc variable
]]

local Plot2D = PlotHeader..[[
set xlabel "$xlabel"
set style data errorlines
plot for [case in "$cases"] \
	"$path.dat" \
	index sprintf("$measure:%s", case) \
	title case
]]

local Plot3D = PlotHeader..[[
set xlabel "$xlabel"
set zlabel "$zlabel"
set style data lines
set grid ztics
set xyplane relative 0
#set xrange [4:20]
#set xtics 4
#set yrange [8:40]
#set ytics 8
#set palette gray
#set pm3d at s interpolate 4,5 depthorder # hidden3d
splot for [case in "$cases"] \
	"$path.dat" \
	index sprintf("$measure:%s$dataset", case) \
	title case # using 1:2:3:3
]]

local Measures = {
	{ id = "memo", label = "Memory allocated (kilobytes)" },
	{ id = "used", label = "Memory used (kilobytes)" },
	{ id = "proc", label = "CPU time used (seconds)" },
	{ id = "time", label = "Time elapsed (seconds)" },
}

local DataSetEnd = "\n\n"
local NumFmt = "%20f"
local TxtFmt = "%-20s"
local Data3DFmt = string.rep(NumFmt, 4, " ").."\n"
local Data2DFmt = string.rep(NumFmt, 3, " ").."\n"
local Data1DFmt = TxtFmt.." "..NumFmt.." "..NumFmt.."\n"

function plot(path)
	results = read(path..".csv")
	local cases = results.cases
	local variables = results.variables
	local xvar = variables[#variables]
	local yvar = variables[#variables-1]

	local datasetpat = {""}
	for i = 1, #variables-2 do
		local name = variables[i]
		datasetpat[#datasetpat+1] = name.."=%s"
	end
	datasetpat = table.concat(datasetpat, ":")

	local output = assert(io.open(path..".dat", "w"))
	output:write("#\n# ",results.name,"\n")
	output:write("# Date: ",os.date(),"\n#\n")
	for _, measure in ipairs(Measures) do
		for values, data in results:ivalues(measure.id, yvar==nil and 1 or 2) do
			if xvar == nil then
				output:write("# ",measure.id,"\n")
			end
			for i, case in ipairs(cases) do
				if xvar == nil then
					output:write(string.format(Data1DFmt, case, mean(data[case])))
				elseif yvar == nil then
					output:write("# ",measure.id,":",case,"\n")
					for _, value, datum in isorted(data) do
						output:write(string.format(Data2DFmt, value, mean(datum[case])))
					end
					output:write(DataSetEnd)
				else
					output:write("# ",measure.id,":",case,datasetpat:format(table.unpack(values)),"\n")
					for _, x, ys in isorted(data) do
						for _, y, datum in isorted(ys) do
							output:write(string.format(Data3DFmt, x, y, mean(datum[case])))
						end
						output:write("\n")
					end
					output:write(DataSetEnd)
				end
			end
			if xvar == nil then
				output:write(DataSetEnd)
			end
		end
	end
	output:close()

	for _, measure in ipairs(Measures) do
		for values, data in results:ivalues(measure.id) do
			if next(data) ~= nil then
				local script = Plot1D
				local tags = {
					path = path,
					selection = selection,
					title = results.name,
					measure = measure.id,
					suffix = "",
					ylabel = measure.label,
				}
				if xvar == nil then
					tags.xmax = #cases-.5
				else
					tags.cases = table.concat(cases, " ")
					tags.xlabel = xvar
					if yvar == nil then
						script = Plot2D
					else
						script = Plot3D
						local dataset = datasetpat:format(table.unpack(values))
						tags.suffix = dataset:gsub("[:=]", "")
						tags.dataset = dataset
						tags.xlabel = yvar
						tags.ylabel = xvar
						tags.zlabel = measure.label
					end
				end
				runcommand("gnuplot", script:tagged(tags))
			end
		end
	end
end
