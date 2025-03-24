module tb();

reg A, B, Cin;
wire S, Cout;

FA x0(A, B, Cin, S, Cout);

initial begin
  $dumpfile("FA.vcd");
  $dumpvars(0, tb);

  A = 0; B = 0; Cin = 1; #10;
  A = 0; B = 1; Cin = 1; #10;
  A = 1; B = 1; Cin = 1; #10;
end

endmodule
