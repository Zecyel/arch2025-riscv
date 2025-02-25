`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`include "include/common.sv"
`include "include/temp_storage.sv"

module writeback
    import common::*;
    import temp_storage::*;
(
    input mem_wb mem_wb_state,
    output reg_addr reg_dest_addr,
    output bool reg_write_enable,
    output word_t reg_write_data,

    input logic clk,
    output bool valid,
    output inst_t inst,
    output addr_t inst_pc,

    output bool reg_write_clk
);
    always_comb begin
        reg_dest_addr = mem_wb_state.reg_dest_addr;
        reg_write_enable = mem_wb_state.reg_write_enable;
        reg_write_data = mem_wb_state.reg_write_data;

        valid = mem_wb_state.inst_signal;
        inst = mem_wb_state.inst;
        inst_pc = mem_wb_state.inst_pc;
        reg_write_clk = mem_wb_state.inst_signal;
    end

endmodule

`endif