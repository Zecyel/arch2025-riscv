`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`endif

module writeback
    import common::*;
    import temp_storage::*;
(
    input mem_wb mem_wb_state,
    output wb_commit wb_commit_state,

    output reg_writer writer,

    output bool ok
);
    always_comb begin
        writer = mem_wb_state.writer;
        wb_commit_state.writer = mem_wb_state.writer;

        wb_commit_state.inst = mem_wb_state.inst;
        wb_commit_state.inst_pc = mem_wb_state.inst_pc;
        wb_commit_state.valid = mem_wb_state.valid;

        ok = 1;
    end

endmodule

`endif