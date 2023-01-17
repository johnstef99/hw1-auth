`include "LedDecoder.v"

//   ┌────────────────────────┐
//   │ LedDriver4 FSM diagram │
//   └────────────────────────┘
//
//                    ┌───────────────────────────────────────────────────────────────────────────┐
//                    │                                                                           │
//                    ▼                                                                           │
//   ┌──────┐     ┌───────┐                ┌───────┐                ┌───────┐                 ┌───────┐
//   │ Init │────▶│ AN3-3 │                │  AN2  │───────────────▶│ AN1-3 │                 │  AN0  │
//   └──────┘     └───────┘                └───────┘                └───────┘                 └───────┘
//                    │                        ▲                        │                         ▲
//                    │            (an = 1011) │                        │              (an = 1110)│
//                    ▼                        │                        ▼                         │
//                ┌───────┐                ┌───────┐                ┌───────┐                 ┌───────┐
//                │ AN3-2 │                │ AN2-1 │                │ AN1-2 │                 │ AN0-1 │
//                └───────┘                └───────┘                └───────┘                 └───────┘
//                    │                        ▲                        │                         ▲
// (char = msg[15:12])│      (char = msg[11:8])│       (char = msg[7:4])│        (char = msg[3:0])│
//                    ▼                        │                        ▼                         │
//                ┌───────┐                ┌───────┐                ┌───────┐                 ┌───────┐
//                │ AN3-1 │                │ AN2-2 │                │ AN1-1 │                 │ AN0-2 │
//                └───────┘                └───────┘                └───────┘                 └───────┘
//                    │                        ▲                        │                         ▲
//         (an = 0111)│                        │             (an = 1101)│                         │
//                    ▼                        │                        ▼                         │
//                ┌───────┐                ┌───────┐                ┌───────┐                 ┌───────┐
//                │  AN3  │───────────────▶│ AN2-3 │                │  AN1  │────────────────▶│ AN0-3 │
//                └───────┘                └───────┘                └───────┘                 └───────┘
//

// Drives 4 7-segment-displays using only 1 LedDecoder
module LedDriver4 (
    input clk,
    reset,
    input wire [15:0] msg,
    output reg [3:0] an,
    output wire [6:0] led_out
);

  reg [3:0] cur_state, next_state, char, counter;

  LedDecoder decoder (
      .led (led_out),
      .char(char)
  );

  parameter AN3 = 4'b1110, AN2 = 4'b1010, AN1 = 4'b0110, AN0 = 4'b0010;

  always @(posedge clk or posedge reset) begin : STATE_MEMORY
    if (reset) begin
      cur_state  <= 4'b0001;
      next_state <= 4'b0001;
      counter    <= 4'b0000;
    end else begin
      cur_state <= next_state;
      counter   <= counter + 1;
    end
  end

  always @(counter) begin : NEXT_STATE_LOGIC
    if (counter == 4'b1111) begin
      next_state = cur_state - 1;
    end else begin
      next_state = cur_state;
    end
  end

  always @(cur_state) begin : OUTPUT_LOGIC
    case (cur_state)
      AN3:     an = 4'b0111;
      AN2:     an = 4'b1011;
      AN1:     an = 4'b1101;
      AN0:     an = 4'b1110;
      4'b0000: char = msg[15:12];
      AN2 + 2: char = msg[11:8];
      AN1 + 2: char = msg[7:4];
      AN0 + 2: char = msg[3:0];
      default: an = 4'b1111;
    endcase
  end

endmodule
