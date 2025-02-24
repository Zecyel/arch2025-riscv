`ifndef __TEMP_STORAGE_SV
`define __TEMP_STORAGE_SV

`include "include/config.sv"

import common::*;
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
        u3 funct3;
        u7 funct7;
        u7 opcode;

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