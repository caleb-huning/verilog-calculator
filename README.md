# verilog-calculator
A verilog program which describes a circuit that reads 16-bit numbers and computes different operations on them.

Steps to run:
1. Install Icarus Verilog from here: https://bleyer.org/icarus/ -- Icarus Verilog v12 was used to run this program.
2. Make sure to get VerilogCalculator.v and memory.data from this repository.
3. Run iverilog through the command line: `iverilog -o output VerilogCalculator.v`
4. Display the program output using vvp: `vvp output`

------------------

This is a Verilog program which describes a circuit which performs several mathematical operations on 16-bit numbers. The program reads a 1 KB memory in memory.data and splits it into pairs of 16-bit numbers. For each pair, it then outputs the sums, absolute
differences, products, quotients, and remainders.

Here is a block diagram to visualize the circuit:
![BlockDiagram](https://github.com/caleb-huning/verilog-calculator/assets/80488655/1d53b6ae-fe55-42ee-a751-1f8c9f06a21e)
