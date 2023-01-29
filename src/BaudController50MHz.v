`ifndef _BAUD_CONTROLLER_50MHZ_
`define _BAUD_CONTROLLER_50MHZ_

module BaudController50MHz (
    input clk,
    reset,
    input [2:0] baud_sel,
    output reg baud_out
);

  reg [13:0] limit[0:8];

  reg [13:0] counter;

  initial begin
    limit[3'b000] = 14'd10417;  // 300    bits/sec
    limit[3'b001] = 14'd2604;  //  1200   bits/sec
    limit[3'b010] = 14'd651;  //   4800   bits/sec
    limit[3'b011] = 14'd326;  //   9600   bits/sec
    limit[3'b100] = 14'd163;  //   19200  bits/sec
    limit[3'b101] = 14'd81;  //    38400  bits/sec
    limit[3'b110] = 14'd54;  //    57600  bits/sec
    limit[3'b111] = 14'd27;  //    115200 bits/sec
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter  <= 0;
      baud_out <= 0;
    end else begin
      if (counter == limit[baud_sel] - 1) begin
        counter  <= 0;
        baud_out <= 1;
      end else begin
        counter  <= counter + 1;
        baud_out <= 0;
      end
    end
  end

endmodule

`endif
