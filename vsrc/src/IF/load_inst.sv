`ifndef __LOAD_INST_SV
`define __LOAD_INST_SV

module load_inst import common::*; (
	input ibus_resp_t iresp,
    input addr_t pc,
    input logic clk,
    input logic rst,

	output ibus_req_t ireq,
    output inst_t inst,
    output bool awaiting
);

    bool waiting;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            waiting <= 0;
            ireq.valid <= 0;
            inst <= 'h0000_0000_0000_0000;
        end else begin
            if (! waiting) begin
                ireq.valid <= 1;
                ireq.addr <= pc;
                waiting <= 1;
            end else begin
                if (iresp.addr_ok) begin
                    ireq.valid <= 0;
                    // if not data ok, throw an exception?
                end

                if (iresp.data_ok) begin
                    inst <= iresp.data;
                    waiting <= 0;
                end
            end
        end
    end

    assign awaiting = waiting;

endmodule

`endif