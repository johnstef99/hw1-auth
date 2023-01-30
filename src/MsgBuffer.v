module MsgBuffer (
    input clk,
    reset,
    input valid,
    perror,
    ferror,
    input [7:0] half_msg,
    output reg [15:0] msg
);

  reg [1:0] cur_state, next_state;
  parameter ZERO = 2'b00, ONE = 2'b01, TWO = 2'b10;

  reg has_error;
  reg [7:0] msg_temp;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      cur_state  <= ZERO;
      next_state <= ZERO;
      msg        <= 16'd0;
      msg_temp   <= 8'd0;
      has_error  <= 0;
    end else begin
      cur_state <= next_state;
    end
  end

  always @(posedge (valid | perror | ferror)) begin
    if (cur_state == ZERO) begin
      if (valid) next_state = ONE;
      else if (perror || ferror) begin
        next_state = ZERO;
        has_error  = 1;
      end
    end else if (cur_state == ONE) begin
      if (valid) next_state = TWO;
      else if (perror || ferror) begin
        next_state = ZERO;
        has_error  = 1;
      end
    end else if (cur_state == TWO) begin
      if (valid) next_state = ONE;
      else if (perror || ferror) begin
        next_state = ZERO;
        has_error  = 1;
      end
    end
  end

  always @(cur_state or has_error) begin
    case (cur_state)
      ZERO: begin
        if (has_error) msg = {`CHAR_F, `CHAR_F, `CHAR_F, `CHAR_F};
        else msg = msg;
      end
      ONE: begin
        msg_temp = half_msg;
      end
      TWO: begin
        msg = {msg_temp, half_msg};
      end
      default: begin
        msg = msg;
      end
    endcase
  end
endmodule
