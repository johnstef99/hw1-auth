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
    msg_tb   = {`CHAR_HYP, 4'd1, 4'd9, 4'd4};

    #1 reset_tb = 1;
    #1 reset_tb = 0;

    repeat (16 * 4 * 4) @(posedge clk_tb);

    msg_tb = {`CHAR_SP, `CHAR_SP, 4'd1, 4'd0};
    repeat (16 * 4 * 4) @(posedge clk_tb);

    msg_tb = {`CHAR_HYP, `CHAR_SP, 4'd3, 4'd2};
    repeat (16 * 4 * 4) @(posedge clk_tb);

    msg_tb = {`CHAR_F, `CHAR_F, `CHAR_F, `CHAR_F};
    repeat (16 * 4 * 4) @(posedge clk_tb);

    #20 $finish;
  end

endmodule
