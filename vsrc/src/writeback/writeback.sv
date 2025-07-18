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
    input logic clk,
    input logic rst,
    input mem_wb mem_wb_state,
    output wb_commit wb_commit_state,

    output reg_writer forward,
    output csr_writer csr,
    input mode_t priviledge_mode,
    input csr_t mstatus,
    input csr_t mip,
    input csr_t mie,
    input csr_t mtvec,
    output bool ok
);

    parameter USER_MODE = 0;
    parameter MACHINE_MODE = 3;

    bool _ok;

    is_write_reg is_write_reg_inst (
        .op(mem_wb_state.op),
        .write_reg(wb_commit_state.writer.reg_write_enable)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            _ok <= 1;
        end else begin
            _ok <= !_ok;
        end
    end

    always_comb begin
        wb_commit_state.writer.reg_dest_addr = mem_wb_state.inst[11:7];
        wb_commit_state.writer.reg_write_data = mem_wb_state.value;
        forward = wb_commit_state.writer;

        csr.csr_write_enable = mem_wb_state.csr.csr_write_enable;
        csr.csr_write_data = mem_wb_state.csr.csr_write_data;
        csr.csr_dest_addr = mem_wb_state.csr.csr_dest_addr;
        csr.plain = mem_wb_state.csr.plain;
        csr.ecall = mem_wb_state.csr.ecall;
        csr.ebreak = mem_wb_state.csr.ebreak;
        csr.mret = mem_wb_state.csr.mret;
        csr.pc = mem_wb_state.csr.pc;
        csr.inst_counter = mem_wb_state.csr.inst_counter;

        wb_commit_state.inst = mem_wb_state.inst;
        wb_commit_state.inst_pc = mem_wb_state.inst_pc;
        wb_commit_state.valid = mem_wb_state.valid;

        if (mem_wb_state.trap.trap_valid == 1) begin
            // if ((priviledge_mode == MACHINE_MODE && mstatus[3] == 1 || priviledge_mode == USER_MODE) && 
                // (/*mip[mem_wb_state.trap.trap_code] == 1 &&*/ mie[mem_wb_state.trap.trap_code] == 1 || mem_wb_state.trap.is_exception == 1 || mem_wb_state.op == ECALL)) begin
            if (priviledge_mode == MACHINE_MODE && mstatus[3] == 1 || priviledge_mode == USER_MODE || (mem_wb_state.trap.is_exception == 0 && mem_wb_state.op != ECALL)) begin
                    csr.trap = mem_wb_state.trap; // enable the trap
                    wb_commit_state.jump.do_jump = 1;
                    wb_commit_state.jump.jump_inst = 1;
                    wb_commit_state.jump.dest_addr = mtvec;
                    wb_commit_state.jump.inst_counter = mem_wb_state.jump.inst_counter;
                // end else begin
                //     csr.trap.is_exception = 0;
                //     csr.trap.trap_code = 0;
                //     csr.trap.trap_valid = 0;
                //     wb_commit_state.jump = mem_wb_state.jump;
                end
        end else begin
            csr.trap.is_exception = 0;
            csr.trap.trap_code = 0;
            csr.trap.trap_valid = 0;
            wb_commit_state.jump = mem_wb_state.jump;
        end

        // csr.trap = wb_commit_state.csr.trap;

        wb_commit_state.difftest_skip = mem_wb_state.difftest_skip;
        wb_commit_state.inst_counter = mem_wb_state.inst_counter;
        ok = _ok;
    end

endmodule

`endif