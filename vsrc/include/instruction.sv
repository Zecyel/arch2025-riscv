`ifndef __INSTRUCTION_SV
`define __INSTRUCTION_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;
package instruction;

    // all supported instructions
    typedef enum {
        NOP, // dummy value
        ADD, SUB, XOR, OR, AND,
        SLL, SRL, SRA, SLT, SLTU,
        ADDI, XORI, ORI, ANDI,
        SLLI, SRLI, SRAI, SLTI, SLTIU,
        ADDIW, ADDW, SUBW, // RV64I
        SLLIW, SRLIW, SRAIW, SLLW, SRLW, SRAW, // RV64I
        LB, LH, LW, LBU, LHU, SB, SH, SW,
        LD, LWU, SD, // RV64I
        BEQ, BNE, BLT, BGE, BLTU, BGEU, // not implemented
        JAL, JALR, // not implemented
        LUI,
        AUIPC,
        ECALL, EBREAK // not implemented (including decoder)
    } instruction_type;

endpackage

`endif