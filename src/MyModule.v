`include "UartReceiver.v"
`include "UartTransmitter.v"
`include "LedDriver4.v"
`include "MsgBuffer.v"

module MyModule (
    input clk,
    reset,
    write,
    noise,
    input [7:0] data,
    output [3:0] anodes,
    output [6:0] led_out
);

  wire [15:0] msg;
  wire [ 7:0] rx_data;
  wire rx_valid, rx_perror, rx_ferror;

  wire txd, rxd, busy;
  assign rxd = txd ^ noise;

  UartTransmitter uart_trans (
      .clk(clk),
      .reset(reset),
      .baud_sel(3'b111),
      .Tx_DATA(data),
      .Tx_WR(write),
      .Tx_EN(1'b1),
      .Tx_BUSY(busy),
      .TxD(txd)
  );


  UartReceiver uart_receiv (
      .clk(clk),
      .reset(reset),
      .baud_sel(3'b111),
      .RxD(rxd),
      .Rx_EN(1'b1),
      .Rx_DATA(rx_data),
      .Rx_VALID(rx_valid),
      .Rx_PERROR(rx_perror),
      .Rx_FERROR(rx_ferror)
  );

  LedDriver4 led_driver (
      .clk(clk),
      .reset(reset),
      .msg(msg),
      .an(anodes),
      .led_out(led_out)
  );

  MsgBuffer msg_buffer (
      .clk(clk),
      .reset(reset),
      .valid(rx_valid),
      .perror(rx_perror),
      .ferror(rx_ferror),
      .half_msg(rx_data),
      .msg(msg)
  );

endmodule
