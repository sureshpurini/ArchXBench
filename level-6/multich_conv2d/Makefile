PY=python3
IVERILOG=iverilog
VVP=vvp
SRC=dut.v testbench.v
BIN=tb_multich_conv2d.out

all: stimuli mem compile run compare

stimuli:
	$(PY) scripts/generate_stimuli.py
	$(PY) ref_model/conv2d_ref.py

mem:
	$(PY) scripts/gen_tb_input_mem.py > tb_input.mem

compile:
	$(IVERILOG) -g2005 -o $(BIN) $(SRC)

run:
	mkdir -p outputs
	$(VVP) $(BIN)

compare:
	$(PY) scripts/compare_outputs.py

clean:
	rm -f *.out *.mem outputs/*.json
