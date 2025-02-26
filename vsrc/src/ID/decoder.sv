`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "src/ID/regs.sv"
`include "src/ID/arith_decoder.sv"
`endif

module decoder
    import common::*;
    import temp_storage::*;
(
    input if_id if_id_state,
    output id_ex id_ex_state,

    input bool reg_write_enable,
    input reg_addr reg_dest_addr,
    input word_t reg_write_data,

    output word_t [31:0] regs_value,
    input logic clk,
    input logic rst
);

    inst_t inst = if_id_state.inst;

    regs regs_inst (
        .reg1_addr(inst[19:15]),
        .reg2_addr(inst[24:20]),
        .clk(clk),
        .rst(rst),
        .reg_write_enable(reg_write_enable),
        .reg_dest_addr(reg_dest_addr),
        .reg_write_data(reg_write_data),
        .regs_value(regs_value),
        .reg1_value(id_ex_state.reg1_value),
        .reg2_value(id_ex_state.reg2_value)
    );

    arith_decoder arith_decoder_inst (
        .inst(inst),
        .op(id_ex_state.op),
        .immed(id_ex_state.immed),
        .is_arith_inst(id_ex_state.is_arith_inst)
    );

    always_comb begin
        id_ex_state.reg_dest_addr = inst[11:7];

        id_ex_state.reg_write_enable = 1;

        id_ex_state.inst_signal = if_id_state.inst_signal;
        id_ex_state.inst = if_id_state.inst;
        id_ex_state.inst_pc = if_id_state.inst_pc;
    end

endmodule

`endif