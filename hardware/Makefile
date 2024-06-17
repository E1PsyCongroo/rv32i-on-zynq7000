SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(subst /cygdrive/c/,C:/,$(shell pwd))
SCRIPTS                 := $(ABS_TOP)/scripts
VIVADO                  ?= vivado
VIVADO_OPTS             ?= -nolog -nojournal -mode batch
FPGA_PART               ?= xc7z020clg400-1
RTL                     += $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/vsrc -type f -name "*.v"))
CONSTRAINTS             += $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/vsrc -type f -name "*.xdc"))
TOP                     ?= z1top
BUILD_DIR 							:= build
SYNTH_DIR 							:= $(BUILD_DIR)/synth
IMPL_DIR	 							:= $(BUILD_DIR)/impl

SIM_RTL                 := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/vsim -type f -name "*.v"))
SIM_MODELS              := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/vsim_models -type f -name "*.v"))
IVERILOG                := iverilog
IVERILOG_OPTS           := -Ttyp -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale -D ABS_TOP=$(ABS_TOP) -I $(ABS_TOP)/vsrc/riscv_core -I $(ABS_TOP)/vsim
VVP                     := vvp

ISA_TESTS               := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/riscv-isa-tests -type f -name "*.hex"))
ISA_TESTS_FILES         := $(notdir $(ISA_TESTS))
ISA_TESTS_FST           := $(addprefix vsim/isa/,$(subst .hex,.fst,$(ISA_TESTS_FILES)))
C_TESTS                 := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/c_tests -type f -name "*.c"))
C_TESTS_FILES           := $(notdir $(C_TESTS))
C_TESTS_FST             := $(addprefix vsim/c_tests/,$(subst .c,.fst,$(C_TESTS_FILES)))
SMALL_TESTS             := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/small -type f -name "*.c"))
SMALL_TESTS_FILES       := $(notdir $(SMALL_TESTS))
SMALL_TESTS_FST         := $(addprefix vsim/small/,$(subst .c,.fst,$(SMALL_TESTS_FILES)))
MYPORT                  ?= MYPORT_NOT_SET

VERILATOR 							?= verilator
VERILATOR_OPTS 					+= -MMD --build -cc -O3 --x-assign fast --x-initial fast --noassert --trace
VERILATOR_DIR 					:= $(BUILD_DIR)/verilator
OBJ_DIR 								:= $(VERILATOR_DIR)/obj_dir
CSRCS 									:= $(shell find $(ABS_TOP)/csrc -type f -name "*.c" -or -name "*.cc" -or -name "*.cpp")

NXDC_FILES							:= $(abspath ./constr/top.nxdc)
# constraint file
SRC_AUTO_BIND = $(abspath $(VERILATOR_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	@mkdir -p $(VERILATOR_DIR)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# rules for NVBoard
-include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS 								:= $(addprefix -I, $(INC_PATH))
CXXFLAGS 								+= $(INCFLAGS)

V%: $(VERILATOR_DIR)/V%
	@echo "Run $<"
	$<

$(VERILATOR_DIR)/V$(TOP): $(abspath csrc/$(TOP).cpp) $(RTL) $(SRC_AUTO_BIND) $(NVBOARD_ARCHIVE)
	@mkdir -p $(VERILATOR_DIR)
	@echo "Building $@"
	@rm -rf $(OBJ_DIR)/
	$(VERILATOR) $(VERILATOR_OPTS) \
		--top-module $* $^ \
		-I$(ABS_TOP)/vsrc/riscv_core $(ABS_TOP)/stubs/PLLE2_ADV.v $(ABS_TOP)/vsim_models/BUFG.v $(ABS_TOP)/stubs/IBUF.v \
		$(addprefix -CFLAGS , $(CXXFLAGS)) -CFLAGS -DTOP_NAME="\"V$*\"" \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $@)


$(VERILATOR_DIR)/V%: $(abspath csrc/%.cpp) $(RTL)
	@mkdir -p $(VERILATOR_DIR)
	@echo "Building $@"
	@rm -rf $(OBJ_DIR)/
	$(VERILATOR) $(VERILATOR_OPTS) \
		--top-module $* $^ \
		-I$(ABS_TOP)/vsrc/riscv_core $(ABS_TOP)/stubs/PLLE2_ADV.v $(ABS_TOP)/vsim_models/BUFG.v $(ABS_TOP)/stubs/IBUF.v \
		-CFLAGS -DTOP_NAME="\"V$*\"" \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $@)

all: $(IMPL_DIR)/$(TOP).bit

vsim/%.tbi: vsim/%.v $(RTL)
	cd vsim && $(IVERILOG) $(IVERILOG_OPTS) -o $*.tbi $*.v $(RTL) $(SIM_MODELS)

vsim/%.fst: vsim/%.tbi
	cd vsim && $(VVP) $*.tbi -fst |& tee $*.log

# ISA Tests
vsim/isa/isa_tb.tbi: vsim/isa_tb.v $(RTL) $(SIM_MODELS)
	mkdir -p vsim/isa
	cd vsim/isa && $(IVERILOG) $(IVERILOG_OPTS) -o isa_tb.tbi ../isa_tb.v $(RTL) $(SIM_MODELS)

vsim/isa/%.fst: vsim/isa/isa_tb.tbi $(ABS_TOP)/../software/riscv-isa-tests/%.hex
	@cd vsim/isa && $(VVP) isa_tb.tbi -fst +hex_file=$(word 2,$^) +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log |& grep -v "readmemh" |& grep -v "FST info"

isa-tests: $(ISA_TESTS_FST)

# C Tests
vsim/c_tests/c_tests_tb.tbi: vsim/c_tests_tb.v $(RTL) $(SIM_MODELS)
	mkdir -p vsim/c_tests
	cd vsim/c_tests && $(IVERILOG) $(IVERILOG_OPTS) -o c_tests_tb.tbi ../c_tests_tb.v $(RTL) $(SIM_MODELS)

vsim/c_tests/%.fst: vsim/c_tests/c_tests_tb.tbi $(ABS_TOP)/../software/c_tests/%
	@cd vsim/c_tests && $(VVP) c_tests_tb.tbi -fst +hex_file=$(word 2,$^)/$*.hex +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log |& grep -v "readmemh" |& grep -v "FST info"

c-tests: $(C_TESTS_FST)

# Small Tests
vsim/small/small_tb.tbi: vsim/small_tb.v $(RTL) $(SIM_MODELS)
	mkdir -p vsim/small
	cd vsim/small && $(IVERILOG) $(IVERILOG_OPTS) -o small_tb.tbi ../small_tb.v $(RTL) $(SIM_MODELS)

vsim/small/%.fst: vsim/small/small_tb.tbi $(ABS_TOP)/../software/small/%
	@cd vsim/small && $(VVP) small_tb.tbi -fst +hex_file=$(word 2,$^)/$*.hex +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log |& grep -v "readmemh" |& grep -v "FST info"

small-tests: $(SMALL_TESTS_FST)

$(BUILD_DIR)/target.tcl: $(RTL) $(CONSTRAINTS)
	mkdir -p $(BUILD_DIR)
	truncate -s 0 $@
	echo "set ABS_TOP                        $(ABS_TOP)"    >> $@
	echo "set TOP                            $(TOP)"    >> $@
	echo "set FPGA_PART                      $(FPGA_PART)"  >> $@
	echo "set MYPORT                         $(MYPORT)"  >> $@
	echo "set_param general.maxThreads       6"    >> $@
	echo "set_param general.maxBackupLogs    0"    >> $@
	echo -n "set RTL { " >> $@
	FLIST="$(RTL)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@
	echo -n "set CONSTRAINTS { " >> $@
	FLIST="$(CONSTRAINTS)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@

setup: $(BUILD_DIR)/target.tcl

elaborate: $(BUILD_DIR)/target.tcl $(SCRIPTS)/elaborate.tcl
	mkdir -p ./$(BUILD_DIR)
	cd ./$(BUILD_DIR) && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/elaborate.tcl |& tee elaborate.log

$(SYNTH_DIR)/$(TOP).dcp: $(BUILD_DIR)/target.tcl $(SCRIPTS)/synth.tcl
	mkdir -p ./$(SYNTH_DIR)/
	cd ./$(SYNTH_DIR)/ && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/synth.tcl |& tee synth.log

synth: $(SYNTH_DIR)/$(TOP).dcp

$(IMPL_DIR)/$(TOP).bit: $(SYNTH_DIR)/$(TOP).dcp $(SCRIPTS)/impl.tcl
	mkdir -p ./$(IMPL_DIR)/
	cd ./$(IMPL_DIR) && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/impl.tcl |& tee impl.log

impl: $(IMPL_DIR)/$(TOP).bit

program: $(IMPL_DIR)/$(TOP).bit $(SCRIPTS)/program.tcl
	cd $(IMPL_DIR) && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl

program-force:
	cd $(IMPL_DIR) && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl

remote: $(IMPL_DIR)/$(TOP).bit $(SCRIPTS)/program.tcl
	cd $(IMPL_DIR) && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/remote.tcl

remote-force:
	cd $(IMPL_DIR) && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/remote.tcl

vivado: $(BUILD_DIR)
	cd $(BUILD_DIR) && nohup $(VIVADO) </dev/null >/dev/null 2>&1 &

lint:
	verilator -DABS_TOP=$(ABS_TOP) --lint-only --top-module $(TOP) $(RTL) -I$(ABS_TOP)/vsrc/riscv_core $(ABS_TOP)/stubs/PLLE2_ADV.v $(ABS_TOP)/vsim_models/BUFG.v $(ABS_TOP)/stubs/IBUF.v

screen:
	screen /dev/ttyUSB0 115200

clean-vsim:
	rm -rf *.daidir vsim/output.txt \
	vsim/*.tb vsim/*.daidir vsim/csrc \
	vsim/ucli.key vsim/*.vpd vsim/*.vcd \
	vsim/*.tbi vsim/*.fst vsim/*.jou vsim/*.log vsim/*.out \
	vsim/isa vsim/c_tests vsim/small

clean-build:
	rm -rf ./$(BUILD_DIR)

.PHONY: setup synth impl program program-force remote remote-force vivado all clean-build clean-vsim all V%
.PRECIOUS: vsim/%.tbi vsim/%.fst $(VERILATOR_DIR)/V%