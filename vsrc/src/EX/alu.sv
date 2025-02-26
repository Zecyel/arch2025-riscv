`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module alu import common::*; (
    input u12 immed,
    
    input word_t reg1,
    input word_t reg2,

    input alu_operation op,

    output word_t result
);
    always_comb begin
        word_t sign_extended_immed = {{52{immed[11]}}, immed};

        unique case (op)
            ADD: result = reg1 + reg2;
            SUB: result = reg1 - reg2;
            AND: result = reg1 & reg2;
            OR: result = reg1 | reg2;
            XOR: result = reg1 ^ reg2;
            ADDI: result = reg1 + sign_extended_immed;
            XORI: result = reg1 ^ sign_extended_immed;
            ORI: result = reg1 | sign_extended_immed;
            ANDI: result = reg1 & sign_extended_immed;
            ADDW: begin
                u32 unextended_result = $signed(reg1[31:0] + reg2[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SUBW: begin
                u32 unextended_result = $signed(reg1[31:0] - reg2[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            ADDIW: begin
                u32 unextended_result = $signed(reg1[31:0] + sign_extended_immed[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
        endcase

    end
endmodule


`endif