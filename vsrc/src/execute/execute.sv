`ifndef __EX_SV
`define __EX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`include "src/execute/alu.sv"
`include "src/execute/jump_judge.sv"
`include "src/decode/instruction_util.sv"
`endif

module execute
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
(
    input logic clk,
    input id_ex id_ex_state,
    output ex_mem ex_mem_state,

    output reg_writer forward,
    input reg_writer forward1,
    input reg_writer forward2,

    output bool ok
);
    
    word_t alu_result;

    word_t op1, op2;
    bool csr, csr_immed, csr_plain;

    is_csr is_csr_inst (
        .op(id_ex_state.op),
        .csr(csr)
    );

    is_csr_immed is_csr_immed_inst (
        .op(id_ex_state.op),
        .csr_immed(csr_immed)
    );

    is_csr_plain is_csr_plain_inst (
        .op(id_ex_state.op),
        .csr_plain(csr_plain)
    );

    always_comb begin
        op1 = forward1.reg_write_enable && forward1.reg_dest_addr != 0 && forward1.reg_dest_addr == id_ex_state.reg1_addr ? forward1.reg_write_data :
              forward2.reg_write_enable && forward2.reg_dest_addr != 0 && forward2.reg_dest_addr == id_ex_state.reg1_addr ? forward2.reg_write_data :
              id_ex_state.reg1_value;
        op2 = forward1.reg_write_enable && forward1.reg_dest_addr != 0 && forward1.reg_dest_addr == id_ex_state.reg2_addr ? forward1.reg_write_data :
              forward2.reg_write_enable && forward2.reg_dest_addr != 0 && forward2.reg_dest_addr == id_ex_state.reg2_addr ? forward2.reg_write_data :
              id_ex_state.reg2_value;
    end

    // instruction_type last_op, last_op_to_write, last_last_op;

    // assign last_op_to_write = last_op;

    // always_ff @(posedge clk) begin
    //     last_op <= id_ex_state.op;
    //     last_last_op <= last_op_to_write;
    // end
    
    jump_judge jump_judge_inst (
        .op(id_ex_state.op),
        .op1(op1),
        .op2(op2),
        .do_jump(ex_mem_state.jump.do_jump)
    );

    is_jump is_jump_inst (
        .op(id_ex_state.op),
        .jump(ex_mem_state.jump.jump_inst)
    );

    csr_t new_csr;

    alu alu_inst (
        .immed(id_ex_state.immed),
        .op1(csr_immed ? { 59'b0, id_ex_state.reg1_addr } : op1),
        .op2(op2),
        .pc(id_ex_state.inst_pc),
        .new_pc(ex_mem_state.jump.dest_addr),
        .csr(id_ex_state.csr_value),
        .new_csr(new_csr),
        .mtvec(id_ex_state.mtvec),
        .mepc(id_ex_state.mepc),
        .op(id_ex_state.op),
        .result(alu_result)
    );

    is_arith is_arith_inst (
        .op(id_ex_state.op),
        .arith(forward.reg_write_enable)
    );

    always_comb begin
        ex_mem_state.inst = id_ex_state.inst;
        ex_mem_state.inst_pc = id_ex_state.inst_pc;

        ex_mem_state.valid = id_ex_state.valid;

        forward.reg_dest_addr = id_ex_state.inst[11:7];
        forward.reg_write_data = alu_result;

        ex_mem_state.alu_result = alu_result;
        ex_mem_state.write_mem_data = id_ex_state.reg2_value;
        ex_mem_state.op = id_ex_state.op;
        ex_mem_state.inst_counter = id_ex_state.inst_counter;
        ex_mem_state.jump.inst_counter = id_ex_state.inst_counter;

        ex_mem_state.csr.csr_write_enable = csr;
        ex_mem_state.csr.csr_write_data = new_csr;
        ex_mem_state.csr.csr_dest_addr = id_ex_state.inst[31:20];
        ex_mem_state.csr.pc = id_ex_state.inst_pc;
        ex_mem_state.csr.ecall = id_ex_state.op == ECALL ? 1 : 0;
        // ex_mem_state.csr.ebreak = id_ex_state.op == EBREAK ? 1 : 0;
        ex_mem_state.csr.mret = id_ex_state.op == MRET ? 1 : 0;
        ex_mem_state.csr.plain = csr_plain;
        ex_mem_state.csr.inst_counter = id_ex_state.inst_counter;

        ex_mem_state.trap = id_ex_state.trap;
        ok = 1;
    end

endmodule

`endif