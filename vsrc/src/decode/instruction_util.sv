`ifndef __INSTRUCTION_UTIL_SV
`define __INSTRUCTION_UTIL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module is_write_reg
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool write_reg
);

    always_comb begin
        case (op)
            ADD, SUB, XOR, OR, AND,
            SLL, SRL, SRA, SLT, SLTU,
            ADDI, XORI, ORI, ANDI,
            SLLI, SRLI, SRAI, SLTI, SLTIU,
            ADDIW, ADDW, SUBW,
            SLLIW, SRLIW, SRAIW, SLLW, SRLW, SRAW,
            LB, LH, LW, LBU, LHU, LD, LWU,
            JAL, JALR,
            LUI, AUIPC,
            CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI: write_reg = 1;

            default: write_reg = 0;
        endcase
    end

endmodule

module is_arith // forwardable instructions
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool arith
);

    always_comb begin
        case (op)
            ADD, SUB, XOR, OR, AND,
            SLL, SRL, SRA, SLT, SLTU,
            ADDI, XORI, ORI, ANDI,
            SLLI, SRLI, SRAI, SLTI, SLTIU,
            ADDIW, ADDW, SUBW,
            SLLIW, SRLIW, SRAIW, SLLW, SRLW, SRAW,
            LUI: arith = 1;

            default: arith = 0;
        endcase
    end

endmodule

module is_stall
// also includes interruption
// stall module to be done
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool stall
);

    always_comb begin
        case (op)
            BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI: stall = 1;

            default: stall = 0;
        endcase
    end

endmodule

module is_stall_plain
// also includes interruption
// stall module to be done
    import common::*;
    import instruction::*;
(
    input inst_t inst,
    output bool stall
);

    always_comb begin
        case (inst[6:0])
            7'b1100011: stall = 1; // branch instructions
            7'b1101111: stall = 1; // jal
            7'b1100111: stall = 1; // jalr
            7'b1110011: stall = 1; // ecall, ebreak
            7'b1110011: stall = 1; // csr instructions
            default: stall = 0;
        endcase
    end

endmodule

module is_jump
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool jump
);

    always_comb begin
        case (op)
            BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR, ECALL, MRET: jump = 1;

            default: jump = 0;
        endcase
    end

endmodule

module is_memory
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool memory
);

    always_comb begin
        case (op)
            LB, LH, LW, LBU, LHU, LD, LWU,
            SB, SH, SW, SD: memory = 1;

            default: memory = 0;
        endcase
    end

endmodule

module is_memory_read
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool memory_read
);

    always_comb begin
        case (op)
            LB, LH, LW, LBU, LHU, LD, LWU: memory_read = 1;
            default: memory_read = 0;
        endcase
    end

endmodule

module is_csr
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool csr
);

    always_comb begin
        case (op)
            CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI: csr = 1;
            default: csr = 0;
        endcase
    end

endmodule

module is_csr_immed
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool csr_immed
);

    always_comb begin
        case (op)
            CSRRWI, CSRRSI, CSRRCI: csr_immed = 1;
            default: csr_immed = 0;
        endcase
    end

endmodule

module is_csr_plain
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool csr_plain
);

    always_comb begin
        case (op)
            CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI: csr_plain = 1;
            default: csr_plain = 0;
        endcase
    end

endmodule

`endif