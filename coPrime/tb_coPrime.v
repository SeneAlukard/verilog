`timescale 1ns/1ps

module tb_coPrime();
  reg [3:0] a, b;
  wire is_coprime;

    coPrime uut (
      a, b,
      is_coprime
    );

    initial begin
        $dumpfile("coPrime.vcd");
        $dumpvars(0, tb_coPrime);
    end
    
    // Test stimulus
    initial begin
      a = 4; b = 3; #10;
      a = 3; b = 3; #10;
      a = 2; b = 3; #10;
      a = 1; b = 3; #10;
      a = 0; b = 3; #10;
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("At time %t: ", $time);
    end
endmodule
