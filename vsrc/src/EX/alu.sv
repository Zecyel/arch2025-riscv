`ifndef __ALU_SV
`define __ALU_SV

`include "include/common.sv"

module alu import common::*; (
    input u12 immed,
    
    input word_t reg1,
    input word_t reg2,

    input u3 funct3,
    input u7 funct7,
    input u7 opcode,

    output word_t result
);
    always_comb begin
        unique case (opcode)
            7'b0110011: begin
                case ({1'b0, funct3, 1'b0, funct7})
                    'h000: result = reg1 + reg2; // ADD
                    'h020: result = reg1 - reg2; // SUB
                    'h700: result = reg1 & reg2; // AND
                    'h600: result = reg1 | reg2; // OR
                    'h400: result = reg1 ^ reg2; // XOR
                endcase
            end

            7'b0010011: begin
                word_t sign_extended_immed = {{52{immed[11]}}, immed};
                case (funct3)
                    'h0: result = reg1 + sign_extended_immed; // ADDI
                    'h4: result = reg1 ^ sign_extended_immed; // XORI
                    'h6: result = reg1 | sign_extended_immed; // ORI
                    'h7: result = reg1 & sign_extended_immed; // ANDI
                endcase
            end

            7'b0011011: begin
                u32 sign_extended_immed = {{20{immed[11]}}, immed};
                u32 unextended_result;

                case (funct3)
                    'h0: unextended_result = $signed(reg1[31:0] + sign_extended_immed[31:0]); // ADDIW
                endcase
                result = {{32{unextended_result[31]}}, unextended_result};
            end

            7'b0111011: begin
                u32 unextended_result;
                case ({1'b0, funct3, 1'b0, funct7})
                    'h080: unextended_result = $signed(reg1[31:0] + reg2[31:0]); // ADDW
                    'h020: unextended_result = $signed(reg1[31:0] - reg2[31:0]); // SUBW
                endcase

                result = {{32{unextended_result[31]}}, unextended_result};
            end

            default: begin
                result = 'h1919810; // to make verilator happy
            end
        endcase

    end
endmodule


`endif