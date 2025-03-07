`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`include "src/decode/arith_decoder.sv"
`endif

module decoder
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
(
    input if_id if_id_state,
    output id_ex id_ex_state,

    input reg_writer forward1,
    input reg_writer forward2,
    input reg_writer forward3,

    input word_t [31:0] regs_value,
    output bool ok
);

    inst_t inst = if_id_state.inst;

    arith_decoder arith_decoder_inst (
        .inst(inst),
        .op(id_ex_state.op),
        .immed(id_ex_state.immed)
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

        id_ex_state.writer.reg_dest_addr = inst[11:7];
        id_ex_state.writer.reg_write_enable = 1;

        id_ex_state.inst = if_id_state.inst;
        id_ex_state.inst_pc = if_id_state.inst_pc;

        id_ex_state.valid = if_id_state.valid;

        ok = 1;
    end

endmodule

`endif