module LedDecoder (
    output reg  [6:0] led,
    input  wire [3:0] char
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

  parameter CharHyphen = 10, CharF = 11, CharSpace = 12;

  always @(char) begin
    case (char)
      //                   abcdefg
      0:          led = 7'b0000001;
      1:          led = 7'b1001111;
      2:          led = 7'b0010010;
      3:          led = 7'b0000110;
      4:          led = 7'b1001100;
      5:          led = 7'b0100100;
      6:          led = 7'b1100000;
      7:          led = 7'b0001111;
      8:          led = 7'b0000000;
      9:          led = 7'b0001100;
      CharHyphen: led = 7'b1111110;
      CharF:      led = 7'b0111000;
      CharSpace:  led = 7'b1111111;
      default:    led = 7'b1111111;
    endcase
  end

endmodule
