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

  wire Rx_SAMPLE;
  BaudController50MHz baud_contr (
      .clk(clk),
      .reset(reset),
      .baud_sel(baud_sel),
      .baud_out(Rx_SAMPLE)
  );

  always @(posedge clk, posedge reset) begin : STATE_MEMORY
    if (reset) begin
      counter    <= 4'b1111;
      bit_count  <= 4'b1111;
      Rx_DATA    <= 8'b00000000;
      Rx_VALID   <= 0;
      Rx_PERROR  <= 0;
      Rx_FERROR  <= 0;
      cur_state  <= OFF;
      next_state <= OFF;
    end else begin
      cur_state <= next_state;
    end
  end

  always @(cur_state or RxD) begin : NEXT_STATE_LOGIC
    case (cur_state)
      OFF: next_state = Rx_EN ? ON : OFF;
      ON: begin
        if (RxD == 0) next_state = REC;
        else next_state = Rx_EN ? ON : OFF;
      end
      REC: begin
        if (bit_count == 10 && counter == 4'b1111) next_state = Rx_EN ? ON : OFF;
      end
      default: next_state = cur_state;
    endcase
  end

  always @(posedge Rx_SAMPLE) begin : COUNT_16_SAMPLES
    if (cur_state == REC) begin
      if (counter == 4'd6) begin
        counter = counter + 1;

        if (bit_count == 4'd10) begin
          bit_count = 0;
        end else bit_count = bit_count + 1;

        case (bit_count)
          4'd0: begin
            if (RxD != 0) Rx_FERROR = 1;
          end
          4'd9: begin
            if(Rx_DATA[0] ^ Rx_DATA[1] ^ Rx_DATA[2] ^ Rx_DATA[3] ^
               Rx_DATA[4] ^ Rx_DATA[5] ^ Rx_DATA[6] ^ Rx_DATA[7] != RxD) begin
              Rx_PERROR = 1;
            end
          end
          4'd10: begin
            if (RxD != 1) Rx_FERROR = 1;
            Rx_VALID = !(Rx_FERROR || Rx_PERROR);
          end
          default: begin
            Rx_DATA[bit_count-1] = RxD;  // data bit
          end
        endcase

      end else begin
        if (counter == 4'b1111) counter = 4'b0000;
        else counter = counter + 1;
      end
    end
  end

  always @(cur_state) begin : OUTPUT_LOGIC
    case (cur_state)
      REC: begin
        Rx_PERROR = 0;
        Rx_FERROR = 0;
        Rx_VALID  = 0;
        Rx_DATA   = 8'b00000000;
      end
      default: begin
        Rx_PERROR = Rx_PERROR;
        Rx_FERROR = Rx_FERROR;
        Rx_VALID  = Rx_VALID;
        Rx_DATA   = Rx_DATA;
        counter   = 4'b1111;
        bit_count = 4'b1111;
      end
    endcase
  end

endmodule
