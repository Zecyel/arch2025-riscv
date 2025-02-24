`ifndef __LOAD_INST_SV
`define __LOAD_INST_SV

module load_inst import common::*; (
	input ibus_resp_t iresp,
    input addr_t pc,
    input logic clk,
    input logic rst,

	output ibus_req_t ireq,
    output inst_t inst,
    output bool awaiting,
    output bool inst_signal,
    output addr_t inst_pc
);

    bool waiting;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            waiting <= 0;
            ireq.valid <= 0;
            inst <= 'h0000_0000;
            inst_signal <= 0;
            inst_pc <= PCINIT;
        end else begin
            if (! waiting) begin
                ireq.valid <= 1;
                ireq.addr <= pc;
                waiting <= 1;
                inst_signal <= 0;
            end else begin
                if (iresp.addr_ok) begin
                    ireq.valid <= 0;
                    // if not data ok, throw an exception?
                end

                if (iresp.data_ok) begin
                    inst <= iresp.data;
                    inst_signal <= 1;
                    inst_pc <= ireq.addr;
                    waiting <= 0;
                end else begin
                    inst_signal <= 0;
                end
            end
        end
    end

    assign awaiting = waiting;

endmodule

`endif