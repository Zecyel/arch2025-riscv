`ifndef __LOAD_INST_SV
`define __LOAD_INST_SV

module load_inst import common::*; (
	input ibus_resp_t iresp,
    input addr_t pc,
    input logic clk,
    input logic rst,

	output ibus_req_t ireq,
    output word_t inst
)

    bool waiting;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            waiting <= 0;
            ireq.valid <= 0;
            inst <= 'h0000_0000_0000_0000; // nop instruction
        end else begin
            inst <= 'h0000_0000_0000_0000; // insert a nop
            if (! waiting) begin
                ireq.valid <= 1;
                ireq.addr <= pc;
                waiting <= 1;
            end else begin
                if (iresp.addr_ok) begin
                    ireq.valid <= 0;
                end

                if (iresp.data_ok) begin
                    inst <= iresp.data;
                    waiting <= 0;
                end
            end
        end
    end

endmodule

`endif