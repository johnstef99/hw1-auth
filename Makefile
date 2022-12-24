VC        = iverilog
SRC_DIR   = ./src
VVP_DIR   = ./build
VCD_DIR   = ./waveforms

TBFILES   = $(wildcard $(SRC_DIR)/*_tb.v)
MODULES   = $(subst _tb,,$(notdir $(basename $(TBFILES))))
VVPFILES  = $(addprefix $(VVP_DIR)/,$(addsuffix .vvp, $(MODULES)))
WAVEFORMS = $(addprefix $(VCD_DIR)/,$(addsuffix .vcd, $(MODULES)))

all: $(VVPFILES) $(WAVEFORMS)

$(VVP_DIR)/%.vvp: $(SRC_DIR)/%_tb.v $(SRC_DIR)/%.v
	$(VC) -I $(SRC_DIR) -o $@ $<

$(VCD_DIR)/%.vcd: $(VVP_DIR)/%.vvp
	vvp $<

.PHONY: clean test

clean:
	rm -f $(VVPFILES) $(WAVEFORMS)
