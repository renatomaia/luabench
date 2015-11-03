return {
	id = "matrix",
	name = "Matrix Representation",
	repeats = 1e4,
	variables = {
		x = { min = 1, max = 3 },
		y = { min = 10, max = 30 },
		z = { min = 100, max = 300 },
	},
	cases = {
		list = [[
		local m = {}
		for i = 0, x-1 do
			for j = 0, y-1 do
				for k = 0, z-1 do
					m[1 + i*y*z + j*z + k] = i.." "..j.." "..k
				end
			end
		end
		for i = 0, x-1 do
			for j = 0, y-1 do
				for k = 0, z-1 do
					assert(m[1 + i*y*z + j*z + k] == i.." "..j.." "..k)
				end
			end
		end
		]],
		nested = [[
		local m = {}
		for i = 1, x do
			m[i] = {}
			for j = 1, y do
				m[i][j] = {}
				for k = 1, z do
					m[i][j][k] = i.." "..j.." "..k
				end
			end
		end
		for i = 1, x do
			for j = 1, y do
				for k = 1, z do
					assert(m[i][j][k] == i.." "..j.." "..k)
				end
			end
		end
		]],
	}
}
