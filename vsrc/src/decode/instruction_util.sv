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
    output bool is_write
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
            LUI, AUIPC: is_write = 1;

            SB, SH, SW, SD,
            BEQ, BNE, BLT, BGE, BLTU, BGEU,
            ECALL, EBREAK: is_write = 0;
        endcase
    end

endmodule

`endif