`ifndef __PARSE_INSTRUCTION_SV
`define __PARSE_INSTRUCTION_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module parse_instruction
    import common::*;
    import instruction::*;
(
    input inst_t inst,
    output instruction_type op
);
    u7 opcode;
    u3 funct3;
    u7 funct7;

    always_comb begin

        opcode = inst[6:0];
        funct3 = inst[14:12];
        funct7 = inst[31:25];

        unique case (opcode)
            7'b0110011: case ({1'b0, funct3, 1'b0, funct7})
                'h000: op = ADD;
                'h020: op = SUB;
                'h400: op = XOR;
                'h600: op = OR;
                'h700: op = AND;
                'h100: op = SLL; 
                'h500: op = SRL; 
                'h520: op = SRA; 
                'h200: op = SLT; 
                'h300: op = SLTU;
                default: op = NOP;
            endcase

            7'b0010011: case (funct3)
                'h0: op = ADDI;
                'h4: op = XORI;
                'h6: op = ORI;
                'h7: op = ANDI;
                'h1: if (funct7[6:3] == 'h0) op = SLLI;
                'h5: if (funct7[6:3] == 'h0) op = SRLI; else if (funct7[6:3] == 'h4) op = SRAI;
                'h2: op = SLTI;
                'h3: op = SLTIU;
                default: op = NOP;
            endcase

            7'b0011011: case (funct3)
                'h0: op = ADDIW;
                'h1: if (funct7 == 'h00) op = SLLIW;
                'h5: if (funct7 == 'h00) op = SRLIW; else if (funct7 == 'h20) op = SRAIW;
                default: op = NOP;
            endcase
            
            7'b0111011: case ({1'b0, funct3, 1'b0, funct7})
                'h000: op = ADDW;
                'h020: op = SUBW;
                'h100: op = SLLW;
                'h500: op = SRLW;
                'h520: op = SRAW;
                default: op = NOP;
            endcase

            7'b0000011: case (funct3)
                'h0: op = LB;
                'h1: op = LH;
                'h2: op = LW;
                'h3: op = LD;
                'h4: op = LBU;
                'h5: op = LHU;
                'h6: op = LWU;
                default: op = NOP;
            endcase

            7'b0100011: case (funct3)
                'h0: op = SB;
                'h1: op = SH;
                'h2: op = SW;
                'h3: op = SD;
                default: op = NOP;
            endcase

            7'b1100011: case (funct3)
                'h0: op = BEQ;
                'h1: op = BNE;
                'h4: op = BLT;
                'h5: op = BGE;
                'h6: op = BLTU;
                'h7: op = BGEU;
                default: op = NOP;
            endcase

            7'b1101111: op = JAL;
            7'b1100111: if (funct3 == 0) op = JALR;

            7'b0110111: op = LUI;
            7'b0010111: op = AUIPC;

            7'b1110011: case (funct3)
                'h0: begin
                    if (inst[31:20] == 12'b0) op = ECALL; // 00000073
                    else op = MRET; // 30200073
                end
                'h1: op = CSRRW;
                'h2: op = CSRRS;
                'h3: op = CSRRC;
                'h5: op = CSRRWI;
                'h6: op = CSRRSI;
                'h7: op = CSRRCI;
                default: op = NOP;
            endcase
            
            default: op = NOP;
        endcase

    end

endmodule

`endif