`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`include "include/csr.sv"

`include "src/decode/parse_instruction.sv"
`include "src/decode/parse_immed.sv"
`include "src/decode/instruction_util.sv"
`include "src/csr/selector.sv"
`endif

module decoder
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
    import csr_pkg::*;
(
    input if_id if_id_state,
    output id_ex id_ex_state,

    input reg_writer forward1,
    input reg_writer forward2,
    input reg_writer forward3,

    // interrupts
    input logic trint,
    input logic swint,
    input logic exint,

    input word_t [31:0] regs_value,
    input csr_pack csr_values,
    output bool ok
);

    inst_t inst = if_id_state.inst;
    instruction_type op;

    parse_instruction parse_operation_inst (
        .inst(inst),
        .op(op)
    );

    parse_immed parse_immed_inst (
        .inst(inst),
        .immed(id_ex_state.immed)
    );

    csr_selector csr_selector_inst (
        .csr(csr_values),
        .csr_dest_addr(inst[31:20]),
        .csr_out(id_ex_state.csr_value),
        .trint(trint),
        .swint(swint),
        .exint(exint)
    );

    always_comb begin

        id_ex_state.reg1_addr = inst[19:15];
        id_ex_state.reg2_addr = inst[24:20];

        id_ex_state.reg1_value = forward1.reg_write_enable && forward1.reg_dest_addr != 0 && forward1.reg_dest_addr == inst[19:15] ? forward1.reg_write_data :
                                 forward2.reg_write_enable && forward2.reg_dest_addr != 0 && forward2.reg_dest_addr == inst[19:15] ? forward2.reg_write_data :
                                 forward3.reg_write_enable && forward3.reg_dest_addr != 0 && forward3.reg_dest_addr == inst[19:15] ? forward3.reg_write_data :
                                 regs_value[inst[19:15]];
        id_ex_state.reg2_value = forward1.reg_write_enable && forward1.reg_dest_addr != 0 && forward1.reg_dest_addr == inst[24:20] ? forward1.reg_write_data :
                                 forward2.reg_write_enable && forward2.reg_dest_addr != 0 && forward2.reg_dest_addr == inst[24:20] ? forward2.reg_write_data :
                                 forward3.reg_write_enable && forward3.reg_dest_addr != 0 && forward3.reg_dest_addr == inst[24:20] ? forward3.reg_write_data :
                                 regs_value[inst[24:20]];

        id_ex_state.op = op;
        id_ex_state.inst = if_id_state.inst;
        id_ex_state.inst_pc = if_id_state.inst_pc;
        id_ex_state.valid = if_id_state.valid;
        id_ex_state.inst_counter = if_id_state.inst_counter;

        id_ex_state.mtvec = csr_values.mtvec;
        id_ex_state.mepc = csr_values.mepc;

        if (op == ILLEGAL_INST) begin
            id_ex_state.trap.trap_valid = 1;
            id_ex_state.trap.trap_code = 2; // illegal instruction
            id_ex_state.trap.is_exception = 1;
        end else begin
            id_ex_state.trap = if_id_state.trap;
        end

        ok = 1;
    end

endmodule

`endif