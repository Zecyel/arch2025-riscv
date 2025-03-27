`ifndef __LOAD_INST_SV
`define __LOAD_INST_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module load_inst import common::*; (
    input ibus_resp_t iresp,
    input addr_t pc,
    input logic clk,
    input logic rst,
    input logic enable,

    output ibus_req_t ireq,
    output inst_t inst,
    output bool awaiting,
    output addr_t inst_pc,

    output bool valid
);

    bool waiting;
    addr_t last_pc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            waiting <= 0;
            ireq.valid <= 0;
            inst <= 'h0000_0000;
            inst_pc <= PCINIT;
            last_pc <= PCINIT;
            valid <= 0;
        end else if (! waiting & enable) begin
            // send the request
            ireq.valid <= 1;
            ireq.addr <= pc;
            waiting <= 1;
            last_pc <= pc;
            valid <= 0;
        end else if (iresp.addr_ok & iresp.data_ok) begin 
            ireq.valid <= 0;
            inst <= iresp.data;
            inst_pc <= last_pc;
            waiting <= 0;
            valid <= 1;
        end
    end

    assign awaiting = waiting;

endmodule

`endif