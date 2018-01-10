Lua Microbenchmark Tool
=======================

`luabench` is a collection of Lua scripts to help execute, measure and compare the execution of small pieces or snipets of Lua code.


Benchmark Specification
-----------------------

Benchmark are specified in a file named `benchmark.lua`.
This file must contain a Lua code that returns a sequence of tables describing benchmark tests.
Each of these tables must provide the following fields:

`id`
:	string with the test ID, which is used as the prefix of files created with the results of the test.
	Default is `"benchmark"`.

`name`
:	string with the test descriptive title.
	Default is the value of field `id`.

`repeats`
:	number of times the code shall be executed when being measured (for time and memory).
	Default is 1.

`variables`
:	Table with definition of the variables of the code to be measured.
	The code shall be measured for each possible combination of these variables.
	These variables can only assume numeric values.
	This table maps values (the variable key) to a variable speficiation, which is either a table with the possibile fields:
	`id`
	:	string with the variable ID, which will be the name the variable shall be referenced in the code to be measured.
		Default value is the variable key.
	`name`
	:	string with the descriptive title of the variable.
		Default value is the variable key.
	`min`
	:	initial value for the variable.
		Default is 1.
	`max`
	:	maximum value for the variable.
		Default is the value of field `min`.
	`step`
	:	how much the variable must variate at each new measurement.
		Default is the value of field `min`.
	Alternatively, the variable speficiation can be `true` (which works as the same as `{}`, or a table with all the default field values) or a string with the variable name (thus `var1 = "Variable 1"` is the same as `var1 = {name="Variable 1"}`).

`cases`
:	Table with definitions of the cases to be measured.
	Each case shall specify a different code to be measured.
	This table maps values (the case key) to a case speficiation, which can be a table with the following fields (which can be inherited from the test table):
	`name`
	:	string with the descriptive title of the case.
		Default value is the case key.
	`test`
	:	string containing the code to be measured.
	`warmup`
	:	string containing code to be executed before the measuments take place;
		or `true` to indicate that an automatic warmup code should be used, which basically executed the code to be measured for for about one second.
		By default no warmup is done.
	`setup`
	:	string containing code to be executed once before any test code is executed, including the `warmup`.
		It is usually used to allocate resources required for the execution of test code.
		By default no code is executed.
	`teardown`
	:	string containing code to be executed once after all the test code is executed.
		It is usually used to free any allocated resources by the setup or test code.
		By default no code is executed.
	`nocollect`
	:	boolean that indicates whether garbage collection should be disabled during the execution of the code to be measured.
	`nocleanup`
	:	boolean that indicates whether no full garbage collection shall be perfomed before the execution of the code to be measured.

	Alternatively, the case speficiation can be `true` (which works as the same as `{}`, or a table with all the default field values) or a string with the case test code (thus `case1 = "i = i+1"` is the same as `case1 = {test="i = i+1"}`).


Benchmark Execution
-------------------

Execute script `lua/run.lua` passing as argument a directory containing the benchmark specification file (file named `benchmark.lua`).
As the result all the data collected by the measured executions are appended to CSV files in the provided directory.
One CSV file is created for each test returned by the benchmark file.

Optionally, you can specify the ID of the tests specified in the benchmark file that shall be perfomed.
When no ID is provided, all tests are perfomed.
Therefore to execute only the test with ID `insert` described in file `demo/lifo/benchmark.lua` run the command:

	lua lua/run.lua demo/lifo insert

Such command shall produce file `demo/lifo/insert.csv` with the collected results.


Benchmark Results
-----------------

To compile and visualize the results of the benchmark, execute script `lua/plot.lua` passing as arguments the plot module name and the CSV file produced by the execution of a single test.
There are two plot modules available:

`tabplot`
:	produces a textual file with the results.

`gnuplot`
:	produces a SVG file with a graph that depicts the results (uses command-line tool GNUPlot).

Therefore to visualize the results in file `demo/lifo/insert.csv` in a textual table run the command:

	lua lua/plot.lua tabplot demo/lifo/insert.csv

Such command shall produce file `demo/lifo/insert.txt` with textual tables containing the results.
Alternatively, to visualize the results in file `demo/lifo/insert.csv` in a graph run the command:

	lua lua/plot.lua gnuplot demo/lifo/insert.csv

Such command shall produce the SVG file `demo/lifo/insert.svg` with graph depicting the results.
