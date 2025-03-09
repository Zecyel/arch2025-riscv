`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module alu import common::*; (
    input word_t reg1,
    input word_t reg2,
    input word_t immed,

    input instruction_type op,

    output word_t result
);
    always_comb begin

        unique case (op)
            ADD: result = reg1 + reg2;
            SUB: result = reg1 - reg2;
            AND: result = reg1 & reg2;
            OR: result = reg1 | reg2;
            XOR: result = reg1 ^ reg2;
            ADDI: result = reg1 + immed;
            XORI: result = reg1 ^ immed;
            ORI: result = reg1 | immed;
            ANDI: result = reg1 & immed;
            ADDW: begin
                u32 unextended_result = $signed(reg1[31:0] + reg2[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SUBW: begin
                u32 unextended_result = $signed(reg1[31:0] - reg2[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            ADDIW: begin
                u32 unextended_result = $signed(reg1[31:0] + immed[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end

            LD, LB, LH, LW, LBU, LHU, LWU, SD, SB, SH, SW: result = reg1 + immed;

            LUI: result = immed;

            default: begin end
        endcase

    end
endmodule


`endif