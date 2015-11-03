return {
	id = "closure_vs_table",
	name = "Closure vs. Table Creation",
	warmup = true,
	repeats = 3e5,
	cases = {
		Table = "local t = {}",
		Closure = "local function f() end",
	}
}
