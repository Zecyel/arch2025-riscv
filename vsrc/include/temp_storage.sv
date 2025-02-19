`ifndef __TEMP_STORAGE_SV
`define __TEMP_STORAGE_SV

`include "include/config.sv"

import common::*;
package temp_storage;

    typedef struct packed {
        reg_addr reg1_addr;
        reg_addr reg2_addr;
        
    } if_id;

    typedef struct packed {
        word_t reg1_value;
        word_t reg2_value;
        u12 immed;
        u3 funct3;
        u7 funct7;
    } id_ex;

    typedef struct packed {
        word_t alu_result;
    } ex_mem;

    typedef struct packed {

    } mem_wb;


endpackage

`endif