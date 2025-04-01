`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module alu import common::*; (
    input word_t reg1,
    input word_t reg2,
    input word_t immed,
    
    input addr_t pc, // for auipc, bxx, jalr, jal, etc.
    output addr_t new_pc,
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
            AUIPC: result = pc + immed;

            JAL: begin
                result = pc + 4;
                new_pc = pc + immed;
            end

            JALR: begin
                result = pc + 4;
                new_pc = reg1 + immed;
            end

            BEQ, BNE, BLT, BGE, BLTU, BGEU: new_pc = pc + immed;
            SLL: result = reg1 << reg2[5:0];
            SRL: result = reg1 >> reg2[5:0];
            SRA: result = $signed(reg1) >>> reg2[5:0];
            SLLI: result = reg1 << immed[5:0];
            SRLI: result = reg1 >> immed[5:0];
            SRAI: result = $signed(reg1) >>> immed[5:0];
            SLT: result = $signed(reg1) < $signed(reg2) ? 1 : 0;
            SLTI: result = $signed(reg1) < $signed(immed) ? 1 : 0;
            SLTU: result = reg1 < reg2 ? 1 : 0;
            SLTIU: result = reg1 < immed ? 1 : 0;

            SLLW: begin
                u32 unextended_result = reg1[31:0] << reg2[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRLW: begin
                u32 unextended_result = reg1[31:0] >> reg2[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRAW: begin
                u32 unextended_result = $signed(reg1[31:0]) >>> reg2[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SLLIW: begin
                u32 unextended_result = reg1[31:0] << immed[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRLIW: begin
                u32 unextended_result = reg1[31:0] >> immed[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRAIW: begin
                u32 unextended_result = $signed(reg1[31:0]) >>> immed[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end

            default: begin end
        endcase

    end
endmodule


`endif