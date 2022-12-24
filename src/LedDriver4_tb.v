`timescale 1ns / 1ps
`include "LedDriver4.v"

module LedDriver4_tb;

  reg clk_tb, reset_tb;
  reg [15:0] msg_tb;

  LedDriver4 driver (
      .clk  (clk_tb),
      .reset(reset_tb),
      .msg  (msg_tb)
  );

  always #10 clk_tb = ~clk_tb;

  initial begin
    $dumpfile("waveforms/LedDriver4.vcd");
    $dumpvars;

    clk_tb   = 0;
    reset_tb = 0;
    msg_tb   = {4'b1010, 4'b1011, 4'b0011, 4'b0100};

    #1 reset_tb = 1;
    #1 reset_tb = 0;

    repeat (80) @(posedge clk_tb);
    $finish;
  end

endmodule
