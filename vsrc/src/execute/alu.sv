`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module alu
    import common::*;
    import instruction::*;
(
    input word_t op1,
    input word_t op2,
    input word_t immed,
    
    input addr_t pc, // for auipc, bxx, jalr, jal, etc.
    output addr_t new_pc,

    input csr_t csr, // for csr instructions
    output csr_t new_csr,
    input instruction_type op,

    output word_t result
);
    always_comb begin

        unique case (op)
            ADD: result = op1 + op2;
            SUB: result = op1 - op2;
            AND: result = op1 & op2;
            OR: result = op1 | op2;
            XOR: result = op1 ^ op2;
            ADDI: result = op1 + immed;
            XORI: result = op1 ^ immed;
            ORI: result = op1 | immed;
            ANDI: result = op1 & immed;
            ADDW: begin
                u32 unextended_result = $signed(op1[31:0] + op2[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SUBW: begin
                u32 unextended_result = $signed(op1[31:0] - op2[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            ADDIW: begin
                u32 unextended_result = $signed(op1[31:0] + immed[31:0]);
                result = {{32{unextended_result[31]}}, unextended_result};
            end

            LD, LB, LH, LW, LBU, LHU, LWU, SD, SB, SH, SW: result = op1 + immed;

            LUI: result = immed;
            AUIPC: result = pc + immed;

            JAL: begin
                result = pc + 4;
                new_pc = pc + immed;
            end

            JALR: begin
                result = pc + 4;
                new_pc = op1 + immed;
            end

            BEQ, BNE, BLT, BGE, BLTU, BGEU: new_pc = pc + immed;
            SLL: result = op1 << op2[5:0];
            SRL: result = op1 >> op2[5:0];
            SRA: result = $signed(op1) >>> op2[5:0];
            SLLI: result = op1 << immed[5:0];
            SRLI: result = op1 >> immed[5:0];
            SRAI: result = $signed(op1) >>> immed[5:0];
            SLT: result = $signed(op1) < $signed(op2) ? 1 : 0;
            SLTI: result = $signed(op1) < $signed(immed) ? 1 : 0;
            SLTU: result = op1 < op2 ? 1 : 0;
            SLTIU: result = op1 < immed ? 1 : 0;

            SLLW: begin
                u32 unextended_result = op1[31:0] << op2[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRLW: begin
                u32 unextended_result = op1[31:0] >> op2[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRAW: begin
                u32 unextended_result = $signed(op1[31:0]) >>> op2[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SLLIW: begin
                u32 unextended_result = op1[31:0] << immed[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRLIW: begin
                u32 unextended_result = op1[31:0] >> immed[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end
            SRAIW: begin
                u32 unextended_result = $signed(op1[31:0]) >>> immed[4:0];
                result = {{32{unextended_result[31]}}, unextended_result};
            end

            CSRRW, CSRRWI: begin
                new_csr = op1;
                result = csr;
            end
            CSRRS, CSRRSI: begin
                new_csr = op1 | csr;
                result = csr;
            end
            CSRRC, CSRRCI: begin
                new_csr = csr & ~op1;
                result = csr;
            end

            default: begin end
        endcase

    end
endmodule


`endif