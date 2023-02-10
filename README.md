# UART with 7 segment display in verilog

## Tools used
- [iverilog](https://github.com/steveicarus/iverilog) for verilog compilation
- [yosys](https://github.com/YosysHQ/yosys) for synthesis
- [gtkwave](https://github.com/gtkwave/gtkwave) for viewing VCD files
- [monodraw](https://monodraw.helftone.com/) for drawing FSMs in text mode

## How to build

You need to have **iverilog** installed. Then running `make` will compile all
`*_tb.v` files to `.vvp` and generate the according VCD waveform files inside
the *waveforms* directory.

To generate the diagram images you need to install **yosys** and then run 
`make diagrams` (for a module to generate a diagram it needs to have a
testbench file following the naming convention seen inside the *src*
directory).
