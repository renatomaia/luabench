Lua Microbenchmark Tool
=======================

`luabench` is a collection of Lua scripts to help execute, measure and compare the execution of small pieces or snipets of Lua code.

Example
-------

### Specification

Input file that describes the micro-benchmark (from [`demo/novars/benchmark.lua`](demo/novars/benchmark.lua)).

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
	$ lua run.lua ../demo/novars
	$ lua plot.lua tabplot ../demo/novars/*.csv

### Results

Text tables with the obtained average and standard deviation will be generated at `demo/novars/closure_vs_table.txt`.

	#
	# Closure vs. Table Creation
	# Date: Wed Jan 10 01:03:35 2018
	#
	____________________________
	Memory allocated (kilobytes)

	Closure              | Table                | 
	    25.352 (0.0e+00) |     30.123 (0.0e+00) | 
	_______________________
	Memory used (kilobytes)

	Closure              | Table                | 
	     25.32 (0.0e+00) |     25.115 (0.0e+00) | 
	__________________________
	GC CPU time used (seconds)

	Closure              | Table                | 
	     6e-06 (0.0e+00) |      8e-06 (0.0e+00) | 
	_______________________
	CPU time used (seconds)

	Closure              | Table                | 
	  0.002214 (0.0e+00) |   0.015777 (0.0e+00) |

Documentation
-------------

- [Manual](doc/manual.md)
- [License](LICENSE)


History
-------

Version 1.0:
:	First commited version.
