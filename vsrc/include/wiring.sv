`ifndef __TEMP_STORAGE_SV
`define __TEMP_STORAGE_SV

`ifdef VERILATOR
`include "include/config.sv"
`include "include/common.sv"
`endif

import common::*;
package wiring;

    typedef struct packed {
        reg_addr reg_dest_addr;
        bool reg_write_enable;
        word_t reg_write_data;
    } reg_writer;

endpackage

`endif