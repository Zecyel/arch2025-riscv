`ifndef __REG_SV
`define __REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module regs import common::*; (
    input logic clk,
    input logic rst,
    input bool reg_write_enable,
    input reg_addr reg_dest_addr,
    input word_t reg_write_data,

    output word_t [31:0] regs_value
);

    word_t [31:0] regs;

    assign regs_value = regs;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i = i + 1) begin
                regs[i] = 'h0000_0000_0000_0000;
            end
        end else begin
            if (reg_write_enable && reg_dest_addr != 0) begin
                regs[reg_dest_addr] = reg_write_data;
            end
        end
    end

endmodule

`endif