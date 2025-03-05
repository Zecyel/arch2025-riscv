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

    output reg_addr reg_dest_addr,
    output bool reg_write_enable,
    output word_t reg_write_data,

    output bool ok
);
    always_comb begin
        reg_dest_addr = mem_wb_state.reg_dest_addr;
        reg_write_enable = mem_wb_state.reg_write_enable;
        reg_write_data = mem_wb_state.reg_write_data;

        wb_commit_state.reg_write_data = mem_wb_state.reg_write_data;
        wb_commit_state.reg_dest_addr = mem_wb_state.reg_dest_addr;
        wb_commit_state.reg_write_enable = mem_wb_state.reg_write_enable;
        wb_commit_state.inst = mem_wb_state.inst;
        wb_commit_state.inst_pc = mem_wb_state.inst_pc;
        wb_commit_state.valid = mem_wb_state.valid;

        ok = 1;
    end

endmodule

`endif