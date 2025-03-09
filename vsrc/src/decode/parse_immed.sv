`ifndef __PARSE_IMMED_SV
`define __PARSE_IMMED_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module parse_immed
    import common::*;
(
    input inst_t inst,
    output word_t immed // msb-extends
);

    parameter R_TYPE = 0;
    parameter I_TYPE = 1;
    parameter S_TYPE = 2;
    parameter B_TYPE = 3;
    parameter U_TYPE = 4;
    parameter J_TYPE = 5;

    u7 opcode;
    u3 inst_fmt_type;
    
    always_comb begin
        opcode = inst[6:0];

        unique case (opcode)
            7'b0110011: inst_fmt_type = R_TYPE;
            7'b0111011: inst_fmt_type = R_TYPE;
            7'b0010011: inst_fmt_type = I_TYPE;
            7'b0000011: inst_fmt_type = I_TYPE;
            7'b1100111: inst_fmt_type = I_TYPE;
            7'b1110011: inst_fmt_type = I_TYPE;
            7'b0011011: inst_fmt_type = I_TYPE;
            7'b0100011: inst_fmt_type = S_TYPE;
            7'b1100011: inst_fmt_type = B_TYPE;
            7'b0110111: inst_fmt_type = U_TYPE;
            7'b0010111: inst_fmt_type = U_TYPE;
            7'b1101111: inst_fmt_type = J_TYPE;

            default: begin end
        endcase

        case (inst_fmt_type)
            R_TYPE: immed = 0;
            I_TYPE: immed = { {52{inst[31]}}, inst[31:20] };
            S_TYPE: immed = { {52{inst[31]}}, inst[31:25], inst[11:7] };
            B_TYPE: immed = { {52{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8] };
            U_TYPE: immed = { {32{inst[31]}}, inst[31:12], 12'b0 };
            J_TYPE: immed = { {44{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21] };
        endcase
    end

endmodule

`endif