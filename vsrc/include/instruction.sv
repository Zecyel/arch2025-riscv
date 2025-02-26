`ifndef __INSTRUCTION_SV
`define __INSTRUCTION_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;
package instruction;

    typedef enum { 
        ADD, SUB, AND, OR, XOR,
        ADDI, XORI, ORI, ANDI,
        ADDIW, ADDW, SUBW
    } alu_operation;

endpackage

`endif