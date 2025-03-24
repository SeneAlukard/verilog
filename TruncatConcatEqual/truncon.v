module truncation(
    input [7:0] vec_in,
    output [3:0] vout0, vout1  // Renamed to match assignments
);
  assign vout0 = vec_in[3:0];
  assign vout1 = vec_in[7:4];
endmodule

module concatenation(
    input [3:0] vout0, vout1,
    output [7:0] vec_out
);
  assign vec_out = {vout1, vout0};
endmodule

module truncon(
  input [7:0] vec_in,
  output [7:0] vec_out, 
  output equal  // Single bit for comparison result
);
  wire [3:0] v0, v1;
  truncation op1 (vec_in, v0, v1);
  concatenation op2 (v0, v1, vec_out);
  assign equal = vec_out == vec_in ? 1'b1 : 1'b0;  // Fixed syntax
endmodule
