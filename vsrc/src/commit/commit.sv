`ifndef __COMMIT_SV
`define __COMMIT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`endif

module commit
    import common::*;
    import temp_storage::*;
(
    input logic clk,
    input logic rst,
    input wb_commit wb_commit_state,

    output logic valid,
    output inst_t inst,
    output addr_t inst_pc,
    output jump_writer jump,
    output bool difftest_skip,
    output bool ok
);

    word_t last_inst_counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            last_inst_counter <= 0;
        end else begin
            last_inst_counter <= wb_commit_state.inst_counter;
        end
    end

    always_comb begin
        ok = last_inst_counter == wb_commit_state.inst_counter;
        inst = wb_commit_state.inst;
        inst_pc = wb_commit_state.inst_pc;
        valid = last_inst_counter != wb_commit_state.inst_counter;
        jump = wb_commit_state.jump;
        difftest_skip = wb_commit_state.difftest_skip;
    end

endmodule

`endif