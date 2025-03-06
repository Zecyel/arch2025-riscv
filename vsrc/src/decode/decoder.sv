`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/wiring.sv"
`include "src/decode/arith_decoder.sv"
`endif

module decoder
    import common::*;
    import temp_storage::*;
    import wiring::*;
(
    input if_id if_id_state,
    output id_ex id_ex_state,

    input reg_addr forward_reg_dest_addr,
    input bool forward_reg_write_enable,
    input word_t forward_reg_write_data,

    input word_t [31:0] regs_value,
    output bool ok
);

    inst_t inst = if_id_state.inst;

    arith_decoder arith_decoder_inst (
        .inst(inst),
        .op(id_ex_state.op),
        .immed(id_ex_state.immed),
        .is_arith_inst(id_ex_state.is_arith_inst)
    );

    always_comb begin

        id_ex_state.reg1_addr = inst[19:15];
        id_ex_state.reg2_addr = inst[24:20];

        if (forward_reg_write_enable && forward_reg_dest_addr != 0) begin
            if (forward_reg_dest_addr == inst[19:15]) begin
                id_ex_state.reg1_value = forward_reg_write_data;
            end else begin
                id_ex_state.reg1_value = regs_value[inst[19:15]];
            end

            if (forward_reg_dest_addr == inst[24:20]) begin
                id_ex_state.reg2_value = forward_reg_write_data;
            end else begin
                id_ex_state.reg2_value = regs_value[inst[24:20]];
            end
        end else begin
            id_ex_state.reg1_value = regs_value[inst[19:15]];
            id_ex_state.reg2_value = regs_value[inst[24:20]];
        end

        id_ex_state.reg_dest_addr = inst[11:7];

        id_ex_state.reg_write_enable = 1;

        id_ex_state.inst = if_id_state.inst;
        id_ex_state.inst_pc = if_id_state.inst_pc;

        id_ex_state.valid = if_id_state.valid;

        ok = 1;
    end

endmodule

`endif