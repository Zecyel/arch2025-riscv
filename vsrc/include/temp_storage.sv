`ifndef __TEMP_STORAGE_SV
`define __TEMP_STORAGE_SV

`ifdef VERILATOR
`include "include/config.sv"
`include "include/instruction.sv"
`include "include/common.sv"
`include "include/combined_wire.sv"
`endif

import common::*;
import instruction::*;
import combined_wire::*;
package temp_storage;

    typedef struct packed {
        inst_t inst;
        addr_t inst_pc;

        bool valid;
    } if_id;

    typedef struct packed {
        // for forwarding
        reg_addr reg1_addr;
        reg_addr reg2_addr;

        word_t reg1_value;
        word_t reg2_value;
        u12 immed;
        alu_operation op;
        bool is_arith_inst; // reserved

        reg_writer writer;

        inst_t inst;
        addr_t inst_pc;

        bool valid;
    } id_ex;

    typedef struct packed {
        reg_writer writer;

        inst_t inst;
        addr_t inst_pc;
        
        bool valid;
    } ex_mem;

    typedef struct packed {
        reg_writer writer;

        inst_t inst;
        addr_t inst_pc;

        bool valid;
    } mem_wb;

    typedef struct packed {
        reg_writer writer;

        inst_t inst;
        addr_t inst_pc;

        bool valid;
    } wb_commit;


endpackage

`endif