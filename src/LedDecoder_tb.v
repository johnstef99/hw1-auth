`timescale 1ns / 1ps
`include "LedDecoder.v"

module LedDecoder_tb;
  reg [3:0] char_tb;

  LedDecoder ledDec (.char(char_tb));

  initial begin
    $dumpfile("waveforms/LedDecoder.vcd");
    $dumpvars;
    char_tb = 0;
    for (integer i = 0; i < 13; i++) begin
      #10 char_tb = char_tb + 1;
    end
    #10 $finish;
  end

endmodule
