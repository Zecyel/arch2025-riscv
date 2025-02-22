`ifndef __FETCH_SV
`define __FETCH_SV

`include "include/common.sv"
`include "include/temp_storage.sv"
`include "src/IF/load_inst.sv"

module fetch
    import common::*;
    import temp_storage::*;
(
    output ibus_req_t ireq,
    input ibus_resp_t iresp,

    output addr_t pc,
    input logic clk,
    input logic rst,

    output if_id if_id_state
);

    addr_t _pc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            _pc <= PCINIT;
        end else begin
            _pc <= _pc + 4;
        end
    end

    load_inst load_inst_inst (
        .ireq(ireq),
        .iresp(iresp),
        .pc(_pc),
        .clk(clk),
        .rst(rst),
        .inst(if_id_state.inst)
    );

    assign pc = _pc;

endmodule

`endif