`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "src/fetch/load_inst.sv"
`endif

module fetch
    import common::*;
    import temp_storage::*;
(
    output ibus_req_t ireq,
    input ibus_resp_t iresp,

    output addr_t pc,
    input logic clk,
    input logic rst,
    input bool enable,

    output if_id if_id_state,
    output bool ok
);

    addr_t _pc;
    bool waiting;

    load_inst load_inst_inst (
        .ireq(ireq),
        .iresp(iresp),
        .pc(_pc),
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .inst(if_id_state.inst),
        .awaiting(waiting),
        .inst_pc(if_id_state.inst_pc),

        .valid(if_id_state.valid)
    );

    always_ff @(posedge rst or posedge clk) begin
        if (rst) begin
            _pc <= PCINIT;
        end else if (! waiting & enable) begin
            _pc <= _pc + 4;
        end
    end

    assign pc = _pc;
    assign ok = ! waiting;

endmodule

`endif