`ifndef __COMBINED_WIRE_SV
`define __COMBINED_WIRE_SV

`ifdef VERILATOR
`include "include/config.sv"
`include "include/common.sv"
`endif

import common::*;
package combined_wire;

    typedef struct packed {
        reg_addr reg_dest_addr;
        bool reg_write_enable;
        word_t reg_write_data;
    } reg_writer;

endpackage

`endif