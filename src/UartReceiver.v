`include "BaudController50MHz.v"

module UartReceiver (
    input reset,
    clk,
    Rx_EN,
    RxD,
    input [2:0] baud_sel,
    output reg [7:0] Rx_DATA,
    output reg Rx_VALID,
    Rx_PERROR,
    Rx_FERROR
);

  reg [3:0] counter, bit_count;

  reg [1:0] cur_state, next_state;
  parameter OFF = 2'b01, ON = 2'b10, REC = 2'b11;

  BaudController50MHz baud_contr (
      .clk(clk),
      .reset(reset),
      .baud_sel(baud_sel),
      .baud_out(Rx_SAMPLE)
  );

  always @(posedge clk, posedge reset) begin : STATE_MEMORY
    if (reset) begin
      counter    <= 0;
      bit_count  <= 0;
      Rx_DATA    <= 8'b00000000;
      Rx_VALID   <= 0;
      Rx_PERROR  <= 0;
      Rx_FERROR  <= 0;
      cur_state  <= Rx_EN ? OFF : ON;
      next_state <= Rx_EN ? OFF : ON;
    end else begin
      cur_state <= next_state;
    end
  end

  always @(cur_state or RxD or counter) begin : NEXT_STATE_LOGIC
    case (cur_state)
      OFF: next_state = Rx_EN ? OFF : ON;
      ON: begin
        if (RxD == 0) next_state = REC;
        else next_state = Rx_EN ? OFF : ON;
      end
      REC: begin
        if (bit_count == 10 && counter == 4'b1111) next_state = Rx_EN ? OFF : ON;
      end
      default: next_state = cur_state;
    endcase
  end

  always @(posedge Rx_SAMPLE) begin : COUNT_16_SAMPLES
    if (cur_state == REC) begin
      if (counter == 4'b0111) begin

        case (bit_count)
          4'd0: begin
            // start bit
          end
          4'd9: begin
            // parity bit
          end
          4'd10: begin
            // stop bit
          end
          default: begin
            Rx_DATA[bit_count-1] = RxD;  // data bit
          end
        endcase
        counter = counter + 1;

      end else if (counter == 4'b1111) begin
        counter = 4'b0000;
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

  always @(cur_state) begin : OUTPUT_LOGIC
    case (cur_state)
      REC: begin
        Rx_PERROR = 0;
        Rx_FERROR = 0;
        Rx_VALID  = 0;
        Rx_DATA <= 8'b00000000;
      end
      default: begin
      end
    endcase
  end

endmodule
