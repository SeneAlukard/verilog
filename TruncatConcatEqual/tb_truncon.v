`timescale 1ns/1ps

module tb_truncon();
reg [7:0] inVec;
wire [7:0] outVec;
wire equal;

    truncon uut (
      inVec, outVec, equal
    );

    
    // VCD file generation
    initial begin
        $dumpfile("truncon.vcd");
        $dumpvars(0, tb_truncon);
    end
    
    // Test stimulus
    initial begin
      inVec = 8'b11001100; #30;
      inVec = 8'b10101010; #30;
      inVec = 8'b01010101; #30;


        $display("Simulation completed");
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("At time %t: ", $time);
    end
endmodule
