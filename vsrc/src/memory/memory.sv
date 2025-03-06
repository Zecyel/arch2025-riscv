`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`endif

module memory
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
(
    input logic clk,
    input ex_mem ex_mem_state,
    output mem_wb mem_wb_state,

    output reg_writer forward,

    output bool ok
);
    always_comb begin
        mem_wb_state.writer = ex_mem_state.writer;
        forward = ex_mem_state.writer;
        
        mem_wb_state.inst = ex_mem_state.inst;
        mem_wb_state.inst_pc = ex_mem_state.inst_pc;

        mem_wb_state.valid = ex_mem_state.valid;

        ok = 1;
    end

endmodule

`endif