Lua Microbenchmark Tool
=======================

`luabench` is a collection of Lua scripts to help execute, measure and compare the execution of small pieces or snipets of Lua code.

Example
-------

### Specification

Input file that describes the micro-benchmark (from `test/novars/benchmark.lua`).

```lua
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
```

### Execution

	$ cd src
	$ lua run.lua ../test/novars
	$ lua plot.lua tabplot ../test/novars/*.csv

### Results

Text tables with the obtained average and standard deviation.

	#
	# Closure vs. Table Creation
	# Date: Sun Jun 21 10:24:11 2015
	#
	____________________________
	Memory allocated (kilobytes)

	Closure              | Table                | 
	    24.123 (0.0e+00) |     47.539 (1.6e+03) | 
	_______________________
	Memory used (kilobytes)

	Closure              | Table                | 
	    24.092 (0.0e+00) |     23.855 (0.0e+00) | 
	_______________________
	CPU time used (seconds)

	Closure              | Table                | 
	 0.0044301 (1.1e-02) |   0.055661 (1.6e-01) | 


Documentation
-------------

- [Manual](doc/manual.md)
- [License](LICENSE)


History
-------

Version 1.0:
:	First commited version.
