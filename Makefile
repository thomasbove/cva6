# Author: Florian Zaruba, ETH Zurich
# Date: 03/19/2017
# Description: Makefile for linting and testing Ariane.

# compile everything in the following library
library = work
# Top level module to compile
top_level = core_tb
test_top_level = core_tb
# test targets
tests = alu scoreboard fifo mem_arbiter store_queue
# UVM agents
agents = include/ariane_pkg.svh $(wildcard tb/agents/*/*.sv) tb/common/eth_tb_pkg.sv
# path to interfaces
interfaces = $(wildcard include/*.svh)
# UVM environments
envs = $(wildcard tb/env/*/*.sv)
# UVM Sequences
sequences =  $(wildcard tb/sequences/*/*.sv)
# Test packages
test_pkg = tb/test/alu/alu_lib_pkg.sv

src2obj     = $(addsuffix /_primary.dat, $(addprefix $(library)/, $(basename $(notdir $(1)))))

# this list contains the standalone components
src = alu.sv if_stage.sv compressed_decoder.sv	mem_arbiter.sv	decoder.sv			  \
	  fetch_fifo.sv commit_stage.sv prefetch_buffer.sv regfile.sv	            	  \
	  ptw.sv tlb.sv store_queue.sv mmu.sv lsu.sv fifo.sv ex_stage.sv   		    	  \
	  scoreboard.sv issue_read_operands.sv  id_stage.sv util/cluster_clock_gating.sv  \
	  ariane.sv

tbs =  tb/alu_tb.sv tb/mem_arbiter_tb.sv tb/core_tb.sv tb/scoreboard_tb.sv tb/store_queue_tb.sv tb/fifo_tb.sv

# Search here for include files (e.g.: non-standalone components)
incdir = ./includes
# Test case to run
test_case = alu_test
# QuestaSim Version
questa_version = -10.5c
compile_flag = +cover=bcfst+/dut

# Iterate over all include directories and write them with +incdir+ prefixed
# +incdir+ works for Verilator and QuestaSim
list_incdir = $(foreach dir, ${incdir}, +incdir+$(dir))
# create library if not exists

$(library):
	# Create the library
	vlib${questa_version} ${library}

# Build the TB and module using QuestaSim
build: $(library) build-agents build-interfaces
	# Suppress message that always_latch may not be checked thoroughly by QuestaSim.
	# Compile agents, interfaces and environments
	vlog${questa_version} ${compile_flag} -incr ${envs} ${sequences} ${test_pkg} ${list_incdir} -suppress 2583
	# Compile source files
	vlog${questa_version} ${compile_flag} -incr ${src} ${tbs}  ${list_incdir} -suppress 2583
	# Optimize top level
	vopt${questa_version} ${compile_flag} ${test_top_level} -o ${test_top_level}_optimized +acc -check_synthesis

build-agents: ${agents}
	vlog${questa_version} ${compile_flag} -incr ${agents} ${list_incdir} -suppress 2583

build-interfaces: ${interfaces}
	vlog${questa_version} ${compile_flag} -incr ${interfaces} ${list_incdir} -suppress 2583

# Run the specified test case
sim:
	# vsim${questa_version} ${top_level}_optimized -c -do "run -a"
	vsim${questa_version} ${top_level}_optimized +UVM_TESTNAME=${test_case}

$(tests):
	# Optimize top level
	vopt${questa_version} ${compile_flag} $@_tb -o $@_tb_optimized +acc -check_synthesis
	# vsim${questa_version} $@_tb_optimized
	vsim${questa_version} -c +UVM_TESTNAME=$@_test -coverage -do "coverage save -onexit $@.ucdb; run -a; quit -code [coverage attribute -name TESTSTATUS -concise]" $@_tb_optimized
# User Verilator to lint the target
lint:
	verilator ${src} --lint-only \
	${list_incdir}

clean:
	rm -rf work/

.PHONY:
	build lint
