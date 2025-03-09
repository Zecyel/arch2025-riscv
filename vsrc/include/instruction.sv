`ifndef __INSTRUCTION_SV
`define __INSTRUCTION_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;
package instruction;

    // all supported instructions
    typedef enum { 
        ADD, SUB, XOR, OR, AND,
        SLL, SRL, SRA, SLT, SLTU, // not implemented
        ADDI, XORI, ORI, ANDI,
        SLLI, SRLI, SRAI, SLTI, SLTIU, // not implemented
        ADDIW, ADDW, SUBW, // RV64I
        SLLIW, SRLIW, SRAIW, SLLW, SRLW, SRAW, // RV64I, not implemented
        LB, LH, LW, LBU, LHU, SB, SH, SW,
        LD, LWU, SD, // RV64I
        BEQ, BNE, BLT, BGE, BLTU, BGEU, // not implemented
        JAL, JALR, // not implemented
        LUI,
        AUIPC, // not implemented
        ECALL, EBREAK // not implemented (including decoder)
    } instruction_type;

endpackage

`endif