`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "src/decode/instruction_util.sv"
`endif

module writeback
    import common::*;
    import temp_storage::*;
(
    input mem_wb mem_wb_state,
    output wb_commit wb_commit_state,

    output reg_writer forward,

    output bool ok
);

    is_write_reg is_write_reg_inst (
        .op(mem_wb_state.op),
        .write_reg(wb_commit_state.writer.reg_write_enable)
    );

    always_comb begin
        wb_commit_state.writer.reg_dest_addr = mem_wb_state.inst[11:7];
        wb_commit_state.writer.reg_write_data = mem_wb_state.value;
        forward = wb_commit_state.writer;

        wb_commit_state.inst = mem_wb_state.inst;
        wb_commit_state.inst_pc = mem_wb_state.inst_pc;
        wb_commit_state.valid = mem_wb_state.valid;
        wb_commit_state.jump = mem_wb_state.jump;
        wb_commit_state.difftest_skip = mem_wb_state.difftest_skip;
        wb_commit_state.inst_counter = mem_wb_state.inst_counter;
        ok = 1;
    end

endmodule

`endif