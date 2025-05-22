PY=python3
IVERILOG=iverilog
VVP=vvp
SRC=conv3d.v tb_conv3d.v
BIN=tb_conv3d.out

all: stimuli mem compile run compare

stimuli:
	$(PY) scripts/generate_stimuli.py
	$(PY) ref_model/conv3d_ref.py

mem:
	@echo "Memory inputs generated in tb_input.mem"

compile:
	$(IVERILOG) -g2005 -o $(BIN) $(SRC)

run:
	$(VVP) $(BIN)

compare:
	$(PY) scripts/compare_outputs.py

clean:
	rm -f *.out *.mem outputs/dut_output.json outputs/golden_output.json
