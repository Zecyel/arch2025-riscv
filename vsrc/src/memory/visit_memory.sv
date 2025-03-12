`ifndef __VISIT_MEMORY_SV
`define __VISIT_MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`include "src/memory/align.sv"
`endif

module visit_memory
    import common::*;
    import instruction::*;
(
    input logic clk,
    input logic rst,
    input logic enable,

    output dbus_req_t dreq,
    input dbus_resp_t dresp,

    input instruction_type op,
    input addr_t addr,
    input word_t write_mem_data,

    output word_t read_mem_data,
    output bool awaiting
);

    bool waiting;
    addr_t last_addr;
    instruction_type last_op;

    msize_t size;
    strobe_t strobe;
    word_t data, readout_data;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            waiting <= 0;
            dreq.valid <= 0;
        end else if (! waiting & enable) begin
            waiting <= 1;
            dreq.addr <= addr;
            dreq.size <= size;
            dreq.strobe <= strobe;
            dreq.data <= data;
            dreq.valid <= 1;
            last_addr <= addr;
            last_op <= op;
        end else if (dresp.addr_ok & dresp.data_ok) begin
            dreq.valid <= 0;
            waiting <= 0;
            readout_data <= dreq.data;
        end
    end

    databus_pre_align databus_pre_align_inst (
        .op(op),
        .addr(addr),
        .raw_data(write_mem_data),

        .size(size),
        .strobe(strobe),
        .data(data)
    );

    databus_post_align databus_post_align_inst (
        .op(last_op),
        .addr(last_addr),
        .data(readout_data),
        .raw_data(read_mem_data)
    );

    assign awaiting = waiting;

endmodule

`endif