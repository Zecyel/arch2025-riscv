`ifndef __RISCV_SV
`define __RISCV_SV

`include "include/common.sv"
`include "include/temp_storage.sv"

`include "src/IF/fetch.sv"
`include "src/ID/decoder.sv"
`include "src/EX/execute.sv"
`include "src/MEM/memory.sv"
`include "src/WB/writeback.sv"

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
    output bool reg_write_enable,
	output reg_addr reg_dest_addr,
	output word_t reg_write_data,
	output bool valid
);

	if_id if_id_state, if_id_state_new;
	id_ex id_ex_state, id_ex_state_new;
	ex_mem ex_mem_state, ex_mem_state_new;
	mem_wb mem_wb_state, mem_wb_state_new;

	bool fetch_inst_awaiting;

	bool awaiting = fetch_inst_awaiting;

	u32 cnt;

    fetch fetch_instance (
		.ireq(ireq),
		.iresp(iresp),
		.pc(pc),
		.clk(clk),
		.rst(rst),
		.if_id_state(if_id_state_new),
		.awaiting(fetch_inst_awaiting)
    );

    decoder decoder_instance (
		.if_id_state(if_id_state),
		.id_ex_state(id_ex_state_new),
		.reg_write_enable(reg_write_enable),
		.reg_dest_addr(reg_dest_addr),
		.reg_write_data(reg_write_data),

		.regs_value(regs),
		.clk(!awaiting ? clk : 0),
		.rst(rst)
    );

    execute execute_instance (
        .id_ex_state(id_ex_state),
        .ex_mem_state(ex_mem_state_new)
    );

	memory memory_instance (
		.ex_mem_state(ex_mem_state),
		.mem_wb_state(mem_wb_state_new)
	);

	bool temp_valid;

	writeback writeback_instance (
		.mem_wb_state(mem_wb_state),
		.reg_write_enable(reg_write_enable),
		.reg_dest_addr(reg_dest_addr),
		.reg_write_data(reg_write_data),

		.valid(temp_valid),
		.clk(!awaiting ? clk : 0)
	);

	assign valid = temp_valid && (cnt > 5);

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			cnt <= 0;
			// drink a cup of java ( also try brew! )
			// take on springboot
			// don't forget your redhat
		end else begin
			cnt <= cnt + 1;
			if (! awaiting) begin
				if_id_state <= if_id_state_new;
				id_ex_state <= id_ex_state_new;
				ex_mem_state <= ex_mem_state_new;
				mem_wb_state <= mem_wb_state_new;
			end
		end
	end

endmodule


`endif