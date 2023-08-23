/* 
 * File: Program3.v
 * Author: Caleb Huning
 * Modules:
 * 		Sum			- Module which takes two 16-bit inputs and outputs their 17-bit sum
 * 		Product		- Module which takes two 16-bit inputs and outputs their 32-bit product
 * 		Diff		- Module which takes two 16-bit inputs and outputs their 16-bit absolute difference
 * 		Div			- Module which takes two 16-bit inputs and outputs their 16-bit quotient and remainder
 *		System		- Main system which performs and displays the above operations on a 1 KB memory
 *		TestSystem	- TestBench to demonstrate functionality of System module
 */

/*
 * Module: Sum
 * Author: Caleb Huning
 * Module which takes two 16-bit inputs and outputs their 17-bit sum
 * Ports:
 * 		a - I/P reg		First 16-bit operand
 * 		b - I/P reg		Second 16-bit operand
 *		o - O/P wire	The 17-bit sum of a and b
 */
module Sum(input[15:0] a, input[15:0] b, output[16:0] o);
	assign o = a + b;	// Evaluate o to sum of a and b
endmodule

/*
 * Module: Product
 * Author: Caleb Huning
 * Module Module which takes two 16-bit inputs and outputs their 32-bit product
 * Ports:
 * 		a - I/P reg		First 16-bit operand
 * 		b - I/P reg		Second 16-bit operand
 *		o - O/P wire	The 32-bit product of a and b
 */
module Product(input[15:0] a, input[15:0] b, output[31:0] o);
	assign o = a * b;	// Evaluate o to product of a and b
endmodule

/*
 * Module: Diff
 * Author: Caleb Huning
 * Module which takes two 16-bit inputs and outputs their 16-bit absolute difference
 * Ports:
 * 		a - I/P reg		First 16-bit operand
 * 		b - I/P reg		Second 16-bit operand
 *		o - O/P wire	The 16-bit absolute difference of a and b
 */
module Diff(input[15:0] a, input[15:0] b, output[15:0] o);
	assign o = a > b ? a - b : b - a;	// Evaluate o to absolute difference of a and b
endmodule

/*
 * Module: Div
 * Author: Caleb Huning
 * Module which takes two 16-bit inputs and outputs their 16-bit quotient and remainder
 * Ports:
 * 		a - I/P reg		First 16-bit operand
 * 		b - I/P reg		Second 16-bit operand
 *		q - O/P wire	The 16-bit quotient of a and b
 *		r - O/P wire	The 16-bit remainder of a and b
 */
module Div(input[15:0] a, input[15:0] b, output[15:0] q, output[15:0] r);
	assign q = a / b;	// Evaluate q to quotient of a and b
	assign r = a % b;	// Evaluate r to remainder of a and b
endmodule

/*
 * Module: System
 * Author: Caleb Huning
 * Main system which performs and displays the above operations on a 1 KB memory
 * Ports:
 * 		reset - I/P reg			Flag which causes the system to reset all memory locations
 * 		valid - I/P reg			Flag which signals that the system may begin looping through memory
 *		ready - O/P reg			Flag which signals that the system is ready to receive input
 *		terminate - O/P reg		Flag which is true while the system is not reading memory
 */
module System(input[0:0] reset, input[0:0] valid, output reg[0:0] ready, output reg[0:0] terminate);
	reg[0:15] mem[0:511];	// Memory storage for 256 32-bit values (further split into 512 32-bit values)
	reg[9:0] addr;			// Loop register
	
	reg[15:0] A, B;		// Two 16-bit values which operations will be performed on
	
	wire[16:0] s;		// Wire to store sum of a and b
	Sum Add(A,B,s);		// Use Sum module to calculate sum
	
	wire[31:0] p;		// Wire to store product of a and b
	Product Mult(A,B,p);// Use Product module to calculate product
	
	wire[15:0] d;		// Wire to store absolute difference of a and b
	Diff Sub(A,B,d);	// Use Diff module to calculate difference
	
	wire[15:0] q,r;		// Wires to store quotient and remainder of a and b
	Div Divide(A,B,q,r);// Use Div module to calculate quotient and remainder
	
	// System power-up
	initial begin
		terminate = 1;	// Terminate flag set to true
		ready = 0;		// Ready flag set to false
	end
	
	always @*
		// On reset input port
		if(reset)
			begin
				for(addr = 0; addr < 512; addr++)	// Loop through all 512 memory locations
					mem[addr] = 0;				// Reset all memory locations to zero
				if(addr == 512)				// Once memory is done being reset
					begin
						ready = 1;			// Set ready flag to true
					end
			end
		// On valid input port
		else if(valid)
            begin
				terminate = 0;	// Set terminate flag to false
				// Loop through memory until finished or until terminated
				for(addr = 0; addr < 512 & ~terminate; addr += 2)
					begin
						A = mem[addr];		// First 16 bits go into A
						B = mem[addr+1];	// Second 16 bits go into B
						if(B == 0)		// If B is zero
							begin
								terminate = 1;	// Terminate flag set to true
							end
						else if(~terminate)		// If B is non-zero and terminate is false
							begin 
								#4	// Wait to ensure output is defined
								// Display all calculated values with tab separation
								$display("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",addr>>1,A,B,s,d,p,q,r);
							end
					end
				// End of addresses
				if(addr == 512)
					begin
						terminate = 1;	// Terminate flag set to true
					end
            end
		else 
			// While reset and valid are false, terminate is true
			begin
				terminate = 1;
			end
endmodule

/*
 * Module: TestSystem
 * Author: Caleb Huning
 * TestBench to demonstrate functionality of System module
 * Ports: None
 */
module TestSystem;
	// System input and output
	wire[0:0] reset, valid, ready, terminate;
	// Registers to set valid and reset flags
	reg[0:0] r, v;
	
	// Initialize valid and reset flags to false
	initial begin
		v = 0;	// Set valid flag to false
		r = 0;	// Set ready flag to false
	end
	
	assign valid = v;	// Continuous assignment of valid input to v
	assign reset = r;	// Continuous assignment of reset input to r
	// Main system
	System Sys(reset, valid, ready, terminate);
	
	// On power up
	always @*
		begin
			v = 0;								// Set valid flag to false
			r = 1;								// Set reset flag to true
			wait(ready)							// Wait for ready flag from system
			r = 0;								// Set reset flag to false
			$readmemh("memory.data",Sys.mem);	// Load file memory.data
			v = 1;								// Set valid flag to true
			#4									// Wait before checking for terminate
			wait(terminate)						// Wait for terminate flag from system
			v = 0;								// Set valid flag to false
			$finish;							// End simulation
		end
endmodule