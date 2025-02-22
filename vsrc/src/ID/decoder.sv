`ifndef __DECODER_SV
`define __DECODER_SV

`include "include/common.sv"
`include "src/ID/regs.sv"

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

    always_comb begin
        id_ex_state.opcode = inst[6:0];
        id_ex_state.funct3 = inst[14:12];
        id_ex_state.funct7 = inst[31:25];
        if (id_ex_state.opcode == 7'b0010011) begin
            id_ex_state.immed = inst[31:20];
        end;

        id_ex_state.reg_dest_addr = inst[11:7];

        id_ex_state.reg_write_enable = 1;
    end

endmodule

`endif