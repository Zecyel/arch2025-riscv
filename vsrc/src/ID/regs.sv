`ifndef __REG_SV
`define __REG_SV

`include "include/common.sv"

module regs import common::*; (
    input reg_addr reg1_addr,
    input reg_addr reg2_addr,

    input logic clk,
    input logic rst,
    input bool reg_write_enable,
    input reg_addr reg_dest_addr,
    input word_t reg_write_data,

    output word_t [31:0] regs_value,
    output word_t reg1_value,
    output word_t reg2_value
);

    word_t [31:0] regs;

    always_comb begin
        reg1_value = regs[reg1_addr];
        reg2_value = regs[reg2_addr];

        regs_value = regs;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i = i + 1) begin
                regs[i] = 'h0000_0000_0000_0000;
            end
        end else begin
            if (reg_write_enable) begin
                regs[reg_dest_addr] = reg_write_data;
            end
        end
    end

endmodule

`endif