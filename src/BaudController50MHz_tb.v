`timescale 1ns / 1ps
`include "BaudController50MHz.v"

module BaudController50MHz_tb;

  reg clk_tb, reset_tb;
  reg [2:0] baud_sel_tb;
  wire baud_out_tb;

  BaudController50MHz baud_contr (
      .clk(clk_tb),
      .reset(reset_tb),
      .baud_sel(baud_sel_tb),
      .baud_out(baud_out_tb)
  );

  always #10 clk_tb = ~clk_tb;

  initial begin
    $dumpfile("waveforms/BaudController50MHz.vcd");
    $dumpvars;

    clk_tb = 0;
    reset_tb = 0;
    baud_sel_tb = 3'b111;

    #1 reset_tb = 1;
    #1 reset_tb = 0;

    repeat(10) @(negedge baud_out_tb);

    baud_sel_tb = 3'b011;

    repeat(10) @(negedge baud_out_tb);


    $finish;
  end

endmodule
