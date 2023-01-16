`define CHAR_HYP 4'd10
`define CHAR_F 4'd11
`define CHAR_SP 4'd12

module LedDecoder (
    input  wire [3:0] char,
    output reg  [6:0] led
);

  //        a
  //       ------
  //    f |      | b
  //      |  g   |
  //       ------
  //      |      |
  //    e |      | c
  //       ------
  //         d

  always @(char) begin
    case (char)
      //                  abcdefg
      0:         led = 7'b0000001;
      1:         led = 7'b1001111;
      2:         led = 7'b0010010;
      3:         led = 7'b0000110;
      4:         led = 7'b1001100;
      5:         led = 7'b0100100;
      6:         led = 7'b1100000;
      7:         led = 7'b0001111;
      8:         led = 7'b0000000;
      9:         led = 7'b0001100;
      `CHAR_HYP: led = 7'b1111110;
      `CHAR_F:   led = 7'b0111000;
      `CHAR_SP:  led = 7'b1111111;
      default:   led = 7'b1111111;
    endcase
  end

endmodule
