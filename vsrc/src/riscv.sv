`ifndef __RISCV_SV
`define __RISCV_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"

`include "src/regs.sv"

`include "src/fetch/fetch.sv"
`include "src/decode/decoder.sv"
`include "src/execute/execute.sv"
`include "src/memory/memory.sv"
`include "src/writeback/writeback.sv"
`endif

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

	// output wb_commit wb_commit
	output bool valid,
	output inst_t inst,
	output addr_t inst_pc
);

	if_id if_id_state, if_id_state_new;
	id_ex id_ex_state, id_ex_state_new;
	ex_mem ex_mem_state, ex_mem_state_new;
	mem_wb mem_wb_state, mem_wb_state_new;
	wb_commit wb_commit_state, wb_commit_state_new;

	bool fetch_ok, decoder_ok, execute_ok, memory_ok, writeback_ok;
	bool unified_ok = fetch_ok & decoder_ok & execute_ok & memory_ok & writeback_ok;

    reg_addr forward_reg_dest_addr;
    bool forward_reg_write_enable;
    word_t forward_reg_write_data;

	regs regs_inst (
		.clk(clk),
		.rst(rst),
		.reg_write_enable(reg_write_enable & unified_ok),
		.reg_dest_addr(reg_dest_addr),
		.reg_write_data(reg_write_data),
		.regs_value(regs)
	);

    fetch fetch_instance (
		.ireq(ireq),
		.iresp(iresp),
		.pc(pc),
		.clk(clk),
		.rst(rst),
		.if_id_state(if_id_state_new),
		
		.ok(fetch_ok),
		.unified_ok(unified_ok)
    );

    decoder decoder_instance (
		.if_id_state(if_id_state),
		.id_ex_state(id_ex_state_new),
		.regs_value(regs),

		.forward_reg_dest_addr(forward_reg_dest_addr),
		.forward_reg_write_enable(forward_reg_write_enable),
		.forward_reg_write_data(forward_reg_write_data),

		.ok(decoder_ok)
    );

    execute execute_instance (
        .id_ex_state(id_ex_state),
        .ex_mem_state(ex_mem_state_new),

		.forward_reg_dest_addr(forward_reg_dest_addr),
		.forward_reg_write_enable(forward_reg_write_enable),
		.forward_reg_write_data(forward_reg_write_data),

		.ok(execute_ok)
    );

	memory memory_instance (
		.clk(clk),

		.ex_mem_state(ex_mem_state),
		.mem_wb_state(mem_wb_state_new),

		.ok(memory_ok)
	);

	writeback writeback_instance (
		.mem_wb_state(mem_wb_state),
		.wb_commit_state(wb_commit_state_new),

		// do writeback
		.reg_write_enable(reg_write_enable),
		.reg_dest_addr(reg_dest_addr),
		.reg_write_data(reg_write_data),

		.ok(writeback_ok)
	);

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			// drink a cup of java ( also try brew! )
			// take on springboot
			// don't forget your redhat
		end else begin
			if (unified_ok) begin
				if_id_state <= if_id_state_new;
				id_ex_state <= id_ex_state_new;
				ex_mem_state <= ex_mem_state_new;
				mem_wb_state <= mem_wb_state_new;
				wb_commit_state <= wb_commit_state_new;
			end
		end
	end

	always_comb begin
		valid = unified_ok & wb_commit_state.valid;
		inst = wb_commit_state.inst;
		inst_pc = wb_commit_state.inst_pc;
	end


endmodule


`endif