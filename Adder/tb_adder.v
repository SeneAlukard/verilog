// Example tb_adder.v
`timescale 1ns/1ps

module tb_adder();
    // Inputs
    reg [7:0] a;
    reg [7:0] b;
    
    // Outputs
    wire [8:0] sum;
    
    // Instantiate the Unit Under Test (UUT)
    adder uut (
        .a(a),
        .b(b),
        .sum(sum)
    );
    
    // VCD file generation
    initial begin
        $dumpfile("adder.vcd");  // This creates the VCD file for GTKWave
        $dumpvars(0, tb_adder);  // Dump all variables in this module
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        a = 0;
        b = 0;
        
        // Wait 10 ns for global reset
        #10;
        
        // Apply test cases
        a = 8'd10; b = 8'd15; #10;
        a = 8'd50; b = 8'd100; #10;
        a = 8'd200; b = 8'd50; #10;
        a = 8'd255; b = 8'd255; #10;
        
        // Finish simulation
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("At time %t: a=%d, b=%d, sum=%d", $time, a, b, sum);
    end
endmodule
