module FA(
  input A, B, Cin,
  output S, Cout
);
wire w1, w2, w3;
HA x1 (A, B, w1, w2);
HA x2 (w1, Cin, S, w3);
assign Cout = w3 | w2;
endmodule
