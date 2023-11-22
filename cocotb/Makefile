SIM?=icarus
TOPLEVEL_LANG=verilog
WORK_BASE?=../..
#XILINX_BASE=${HOME}/projects/XilinxUnisimLibrary
#XILINX_BASE=/cadtools/ubuntu_x86/xilinx/Vivado/2021.2/data
PROJ_HOME?=..
RTLFLOW_PATH?=../../rtlflo

TOPLEVEL = dut
MODULE = test_${TOPLEVEL}

XILINX_PART?=xc7k325tffg900-2
XILINX_REV?=2021.2
ifneq (,$(wildcard ./makefile_synth.mak))
    include ./makefile_synth.mak
endif

IMPORT_SOURCES += \
    ${PROJ_HOME}/../verilog-axi/rtl/arbiter.v \
    ${PROJ_HOME}/../verilog-axi/rtl/priority_encoder.v \
    ${PROJ_HOME}/../verilog-axi/rtl/axi_interconnect.v \
	${PROJ_HOME}/../verilog-axi/rtl/axi_config_rd.v \
	${PROJ_HOME}/../verilog-axi/rtl/axi_config_wr.v \
    ${PROJ_HOME}/picorv32.v

RTL_SOURCES += \
	${PROJ_HOME}/../verilog-axi/rtl/axi_config.sv \
	${PROJ_HOME}/../axi_mem2p/rtl/blockmem_2p.sv \
	${PROJ_HOME}/../axi_mem2p/rtl/blockmem_2p_wrapper.sv \
	${PROJ_HOME}/../axi_mem2p/rtl/axi_2p.sv \
	${PROJ_HOME}/../axi_mem2p/rtl/blockmem_1p.sv \
	${PROJ_HOME}/../axi_mem2p/rtl/blockmem_1p_wrapper.sv \
	${PROJ_HOME}/../axi_mem2p/rtl/axi_1p.sv \
    ./axi_memory.sv \
    ./axi_interconnect_wrapper.sv \
    ./dut.sv

COCOTB_SOURCES = \

VERILOG_DESIGN += ${XILINX_SIM_SOURCES} ${RTL_SOURCES} ${SIM_SOURCES} ${IMPORT_SOURCES}

VERILOG_SOURCES = \
    ${VERILOG_DESIGN} \
    ${COCOTB_SOURCES}

GENERICS = \
	G_HEXFILE=./firmware.hex \

include ${WORK_BASE}/rtlflo/cocotb_helper.mak
