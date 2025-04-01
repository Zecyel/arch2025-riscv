`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`include "src/memory/visit_memory.sv"
`include "src/decode/instruction_util.sv"
`endif

module memory
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
(
    input logic clk,
    input logic rst,
    input logic enable,

    output dbus_req_t dreq,
    input dbus_resp_t dresp,
    input ex_mem ex_mem_state,
    output mem_wb mem_wb_state,

    output reg_writer forward,

    output bool ok
);

    bool waiting, memory_enable;
    word_t data;

    is_memory is_memory_util (
        .op(ex_mem_state.op),
        .memory(memory_enable)
    );

    bool mem_read;
    bool mem_write;
    
    assign mem_write = memory_enable & !mem_read;

    is_memory_read is_memory_read_inst (
        .op(ex_mem_state.op),
        .memory_read(mem_read)
    );

    visit_memory visit_memory_inst (
        .clk(clk),
        .rst(rst),
        .enable(memory_enable),
        .unified_ok(enable),
        .dreq(dreq),
        .dresp(dresp),
        .op(ex_mem_state.op),
        .addr(ex_mem_state.alu_result),
        .write_mem_data(ex_mem_state.write_mem_data),
        .read_mem_data(data),
        .awaiting(waiting)
    );

    is_write_reg is_write_reg_inst (
        .op(ex_mem_state.op),
        .write_reg(forward.reg_write_enable)
    );

    always_comb begin
        if (! mem_read && ! mem_write) begin
            // memory irrelevant, passdown alu value
            mem_wb_state.value = ex_mem_state.alu_result;

            // forward.reg_write_enable = 1;
            forward.reg_write_data = ex_mem_state.alu_result;
            forward.reg_dest_addr = ex_mem_state.inst[11:7];
        end else if (mem_read) begin
            mem_wb_state.value = data;

            forward.reg_write_enable = 1;
            forward.reg_write_data = data;
            forward.reg_dest_addr = ex_mem_state.inst[11:7];
        end else begin
            forward.reg_write_enable = 0;
        end
        
        mem_wb_state.inst = ex_mem_state.inst;
        mem_wb_state.inst_pc = ex_mem_state.inst_pc;

        mem_wb_state.valid = ex_mem_state.valid;
        mem_wb_state.op = ex_mem_state.op;
        mem_wb_state.jump = ex_mem_state.jump;
        mem_wb_state.inst_counter = ex_mem_state.inst_counter;

        ok = ! waiting;
        mem_wb_state.difftest_skip = (mem_read || mem_write) && ex_mem_state.alu_result[31] == 0;
    end

endmodule

`endif