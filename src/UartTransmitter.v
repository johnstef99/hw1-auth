`include "BaudController50MHz.v"

//    ┌──────────────Tx_Busy=1────────────────┐
//    │               Tx_EN=0                 │
//    ▼                                       │
// ┌─────┐            ┌─────┐              ┌─────┐
// │ OFF │───────────▶│ ON  │─────────────▶│TRANS│
// └─────┘  Tx_EN=1   └─────┘   Tx_WR=1    └─────┘
//                       ▲                    │
//                       │                    │
//                       └─────Tx_Busy=1──────┘
//                              Tx_EN=1
//
module UartTransmitter (
    input reset,
    clk,
    Tx_WR,
    Tx_EN,
    input [7:0] Tx_DATA,
    input [2:0] baud_sel,
    output reg TxD,
    Tx_BUSY
);

  reg parity_bit;  // 0 for even, 1 for odd
  reg [7:0] data;
  reg [3:0] counter, bit_count;

  reg [1:0] cur_state, next_state;
  parameter OFF = 2'b01, ON = 2'b10, TRANS = 2'b11;

  BaudController50MHz baud_contr (
      .clk(clk),
      .reset(reset),
      .baud_sel(baud_sel),
      .baud_out(Tx_SAMPLE)
  );

  always @(posedge Tx_SAMPLE) begin : COUNT_16_SAMPLES
    if (cur_state == TRANS) begin
      if (counter == 4'b1111) begin
        counter = 4'b0000;

        case (bit_count)
          4'd0: begin
            TxD = 0;  // start bit
          end
          4'd9: begin
            TxD = parity_bit;  // parity bit
          end
          4'd10: begin
            TxD = 1;  // stop bit
            Tx_BUSY = 0;
          end
          default: begin
            TxD = data[bit_count-1];  // data bit
          end
        endcase

        if (bit_count == 4'd10) bit_count = 0;
        else bit_count = bit_count + 1;

      end else begin
        counter = counter + 1;
      end
    end else begin
      counter   = 4'b0000;
      bit_count = 4'd0;
    end
  end

  always @(posedge clk, posedge reset) begin : STATE_MEMORY
    if (reset) begin
      counter    <= 4'b0000;
      bit_count  <= 4'd0;
      data       <= 8'b00000000;
      parity_bit <= 1'b0;
      TxD        <= 1'b1;
      Tx_BUSY    <= 1'b0;
      cur_state  <= OFF;
      next_state <= OFF;
    end else begin
      cur_state <= next_state;
    end
  end

  always @(cur_state or Tx_EN or Tx_WR or Tx_BUSY) begin : NEXT_STATE_LOGIC
    case (cur_state)
      OFF: next_state = Tx_EN ? ON : OFF;
      ON: begin
        if (!Tx_EN) next_state = OFF;
        else if (Tx_WR) next_state = TRANS;
        else next_state = ON;
      end
      TRANS: begin
        if (Tx_BUSY) next_state = TRANS;
        else begin
          if (Tx_EN) next_state = ON;
          else next_state = OFF;
        end
      end
      default: next_state = cur_state;
    endcase
  end

  always @(cur_state) begin : OUTPUT_LOGIC
    case (cur_state)
      TRANS: begin
        data = Tx_DATA;
        parity_bit = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7];
        Tx_BUSY = 1'b1;
      end
      default: begin
      end
    endcase
  end

endmodule
