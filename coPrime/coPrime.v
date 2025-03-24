module coPrime(
    input [3:0] in1, in2,
    output is_coprime
);

assign is_coprime =
                      (in1 == in2) ? 0 :
                      (in1 == 0 || in2 == 0) ? 0 :
                      (in1 == 1 || in2 == 1) ? 1 :
                      ((!in1[0]) && (!in2[0])) ? 0 :
                      (((in1 % 3) == 0 ) && ((in2 % 3) == 0)) ? 0 :
                      (((in1 % 5) == 0 ) && ((in2 % 5) == 0)) ? 0 :
                      (((in1 % 7) == 0 ) && ((in2 % 7) == 0)) ? 0 :
                      1;
endmodule

