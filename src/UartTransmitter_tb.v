`timescale 1ns / 1ps
`include "UartTransmitter.v"

module UartTransmitter_tb;

  reg clk_tb, reset_tb;
  reg [2:0] baud_sel_tb;
  reg [7:0] tx_data_tb;
  reg tx_wr_tb;
  wire busy;

  UartTransmitter uart_trans (
      .clk(clk_tb),
      .reset(reset_tb),
      .baud_sel(baud_sel_tb),
      .Tx_DATA(tx_data_tb),
      .Tx_WR(tx_wr_tb),
      .Tx_EN(1'b1),
      .Tx_BUSY(busy)
  );

  always #10 clk_tb = ~clk_tb;

  initial begin
    $dumpfile("waveforms/UartTransmitter.vcd");
    $dumpvars;

    clk_tb = 0;
    reset_tb = 0;
    baud_sel_tb = 3'b111;
    reset_tb = 1;

    @(posedge clk_tb) reset_tb = 0;

    tx_data_tb = 8'b11111111;
    tx_wr_tb   = 1;
    @(posedge clk_tb)// tx_wr_tb = 0;
    @(negedge busy);

    @(posedge clk_tb);
    tx_data_tb = 8'b10000000;
    tx_wr_tb   = 1;
    @(posedge clk_tb)// tx_wr_tb = 0;
    @(negedge busy);

    repeat (540) @(posedge clk_tb);
    $finish;
  end

endmodule
