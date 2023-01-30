`timescale 1ns / 1ps
`include "MyModule.v"

module MyModule_tb;

  reg clk_tb, reset_tb;
  reg write, noise;
  reg  [7:0] data;

  wire [3:0] anodes;
  wire [6:0] led_out;

  MyModule mymodule (
      .clk(clk_tb),
      .reset(reset_tb),
      .write(write),
      .noise(noise),
      .data(data),
      .led_out(led_out),
      .anodes(anodes)
  );

  always #10 clk_tb = ~clk_tb;

  initial begin
    $dumpfile("waveforms/MyModule.vcd");
    $dumpvars;

    clk_tb = 0;
    reset_tb = 0;
    reset_tb = 1;
    noise = 0;

    @(posedge clk_tb) reset_tb = 0;

    data  = 8'b10100001;  // '-1'
    write = 1;
    @(posedge clk_tb) write = 0;
    repeat(19) @(posedge anodes[0]);

    @(posedge clk_tb);
    data  = 8'b10010100;  // '94'
    write = 1;
    @(posedge clk_tb) write = 0;
    repeat(19) @(posedge anodes[0]);

    repeat(10) @(posedge anodes[0]);


    /* @(posedge clk_tb); */
    /* data  = 8'b10100001;  // '-1' */
    /* write = 1; */
    /* @(posedge clk_tb) write = 0; */
    /* repeat ((16 * 5 + 1) + 4) @(posedge mymodule.uart_trans.Tx_SAMPLE); */
    /* noise = 1; */
    /* repeat (7) @(posedge mymodule.uart_trans.Tx_SAMPLE); */
    /* noise = 0; */
    /* repeat(19) @(posedge anodes[0]); */

    /* @(posedge clk_tb); */
    /* data  = 8'b10010100;  // '94' */
    /* write = 1; */
    /* @(posedge clk_tb) write = 0; */
    /* repeat(19) @(posedge anodes[0]); */

    /* repeat(10) @(posedge anodes[0]); */


    repeat (10) @(posedge clk_tb);
    $finish;
  end

endmodule
