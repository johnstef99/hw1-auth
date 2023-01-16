VC        = iverilog
SRC_DIR   = ./src
VVP_DIR   = ./build
VCD_DIR   = ./waveforms
PNG_DIR   = ./diagrams

TBFILES   = $(wildcard $(SRC_DIR)/*_tb.v)
MODULES   = $(subst _tb,,$(notdir $(basename $(TBFILES))))
VVPFILES  = $(addprefix $(VVP_DIR)/,$(addsuffix .vvp, $(MODULES)))
WAVEFORMS = $(addprefix $(VCD_DIR)/,$(addsuffix .vcd, $(MODULES)))
DIAGRAMS  = $(addprefix $(PNG_DIR)/,$(addsuffix .png, $(MODULES)))

all: $(VVPFILES) $(WAVEFORMS)

$(VVP_DIR)/%.vvp: $(SRC_DIR)/%_tb.v $(SRC_DIR)/%.v
	$(VC) -I $(SRC_DIR) -o $@ $<

$(VCD_DIR)/%.vcd: $(VVP_DIR)/%.vvp
	vvp $<

diagrams: $(DIAGRAMS)

$(PNG_DIR)/%.png: $(SRC_DIR)/%.v
	yosys -q -p "read_verilog $<; hierarchy; fsm; opt; show -stretch -colors 1 -format svg $(subst .v,,$(notdir $(basename $(<))))"
	convert ~/.yosys_show.svg $@

.PHONY: clean test

clean:
	rm -f $(VVPFILES) $(WAVEFORMS) $(DIAGRAMS) $(DIAGRAMS:.png=.ps)
