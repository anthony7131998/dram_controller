#!/usr/bin/tclsh

vlib work

vmap work

vlog ../rtl/counter.v
vlog ../rtl/dram_addr_translator.v
vlog ../rtl/dram_buffer.v
vlog ../rtl/dram_decoder3x8.v
vlog ../rtl/dram_piso.v
vlog ../rtl/dram_row_decoder.v
vlog ../rtl/dram_sipo.v
vlog ../rtl/dram_ctrl_fsm.v
vlog ../rtl/dram_ctrl.v
vlog ../tb/dram_bfm.v
vlog ../tb/dram_ctrl_top_tb.v

vsim dram_ctrl_top_tb

do wave.do

run -all


