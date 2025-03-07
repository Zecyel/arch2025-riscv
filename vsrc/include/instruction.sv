`ifndef __INSTRUCTION_SV
`define __INSTRUCTION_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;
package instruction;

    // all supported instructions
    typedef enum { 
        ADD, SUB, AND, OR, XOR,
        ADDI, XORI, ORI, ANDI,
        ADDIW, ADDW, SUBW,
        LUI, AUIPC
    } instruction_type;

endpackage

`endif