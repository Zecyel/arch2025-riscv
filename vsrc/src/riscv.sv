`ifndef __RISCV_SV
`define __RISCV_SV

`include "include/common.sv"
`include "include/temp_storage.sv"

module riscv
    import common::*;
    import temp_storage::*;
(
    // cpu basics
    input logic clk,
    input logic rst,

    // bus signals
	output ibus_req_t ireq,
	input ibus_resp_t iresp,

    // for DiffTest
    output word_t pc,
    output word_t [31:0] regs,
    output bool write_regs_enable,
	output u5 write_reg_addr,
	output word_t write_reg_data,
)

	if_id if_id_state, if_id_state_new;
	id_ex id_ex_state, id_ex_state_new;
	ex_mem ex_mem_state, ex_mem_state_new;
	mem_wb mem_wb_state, mem_wb_state_new;

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			pc = PCINIT;
			// do other reset stuff
		end else begin
			if_id_state = if_id_state_new;
			id_ex_state = id_ex_state_new;
			ex_mem_state = ex_mem_state_new;
			mem_wb_state = mem_wb_state_new;
		end
	end

endmodule


`endif