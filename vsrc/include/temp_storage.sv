`ifndef __TEMP_STORAGE_SV
`define __TEMP_STORAGE_SV

`ifdef VERILATOR
`include "include/config.sv"
`include "include/instruction.sv"
`include "include/common.sv"
`endif

import common::*;
import instruction::*;

package temp_storage;

    typedef struct packed {
        bool inst_signal;
        inst_t inst;
        addr_t inst_pc;
    } if_id;

    typedef struct packed {
        word_t reg1_value;
        word_t reg2_value;
        u12 immed;
        alu_operation op;
        bool is_arith_inst; // reserved

        // Provide by Instruction Decoder
        // Injected by Write Back
        reg_addr reg_dest_addr;
        bool reg_write_enable;
        
        bool inst_signal;
        inst_t inst;
        addr_t inst_pc;
    } id_ex;

    typedef struct packed {
        word_t alu_result;

        // pass down 
        reg_addr reg_dest_addr;
        bool reg_write_enable;

        bool inst_signal;
        inst_t inst;
        addr_t inst_pc;
    } ex_mem;

    typedef struct packed {
        word_t reg_write_data;

        // pass down
        reg_addr reg_dest_addr;
        bool reg_write_enable;

        bool inst_signal;
        inst_t inst;
        addr_t inst_pc;
    } mem_wb;


endpackage

`endif