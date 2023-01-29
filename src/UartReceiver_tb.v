`timescale 1ns / 1ps
`include "UartTransmitter.v"
`include "UartReceiver.v"

module UartReceiver_tb;

  reg clk_tb, reset_tb;
  reg [2:0] baud_sel_tb;
  reg [7:0] tx_data_tb;
  reg tx_wr_tb;
  wire busy, txd_tb, rxd_tb;

  reg noise;
  assign rxd_tb = txd_tb ^ noise;

  UartTransmitter uart_trans (
      .clk(clk_tb),
      .reset(reset_tb),
      .baud_sel(baud_sel_tb),
      .Tx_DATA(tx_data_tb),
      .Tx_WR(tx_wr_tb),
      .Tx_EN(1'b1),
      .Tx_BUSY(busy),
      .TxD(txd_tb)
  );


  UartReceiver uart_receiv (
      .clk(clk_tb),
      .reset(reset_tb),
      .baud_sel(baud_sel_tb),
      .RxD(rxd_tb),
      .Rx_EN(1'b1)
  );

  always #10 clk_tb = ~clk_tb;

  initial begin
    $dumpfile("waveforms/UartReceiver.vcd");
    $dumpvars;

    clk_tb = 0;
    reset_tb = 0;
    baud_sel_tb = 3'b111;
    reset_tb = 1;
    noise = 0;

    @(posedge clk_tb) reset_tb = 0;

    tx_data_tb = 8'b10101010;
    tx_wr_tb   = 1;
    @(posedge clk_tb) tx_wr_tb = 0;
    @(negedge busy);

    // reproduce parity error
    @(posedge clk_tb);
    tx_data_tb = 8'b11111111;
    tx_wr_tb   = 1;
    @(posedge clk_tb) tx_wr_tb = 0;
    repeat ((16 * 5 + 1) + 4) @(posedge uart_trans.Tx_SAMPLE);
    noise = 1;
    repeat (7) @(posedge uart_trans.Tx_SAMPLE);
    noise = 0;
    @(negedge busy);

    @(posedge clk_tb);
    tx_data_tb = 8'b11111111;
    tx_wr_tb   = 1;
    @(posedge clk_tb) tx_wr_tb = 0;
    @(negedge busy);

    // reproduce frame error
    @(posedge clk_tb);
    tx_data_tb = 8'b11111111;
    tx_wr_tb   = 1;
    @(posedge clk_tb) tx_wr_tb = 0;
    repeat ((16 * 10 + 1) + 4) @(posedge uart_trans.Tx_SAMPLE);
    noise = 1;
    repeat (7) @(posedge uart_trans.Tx_SAMPLE);
    noise = 0;
    @(negedge busy);

    @(posedge clk_tb);
    tx_data_tb = 8'b00000000;
    tx_wr_tb   = 1;
    @(posedge clk_tb) tx_wr_tb = 0;
    @(negedge busy);

    repeat (540) @(posedge clk_tb);
    $finish;
  end

endmodule
