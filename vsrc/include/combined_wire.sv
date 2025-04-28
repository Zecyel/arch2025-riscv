`ifndef __COMBINED_WIRE_SV
`define __COMBINED_WIRE_SV

`ifdef VERILATOR
`include "include/config.sv"
`include "include/common.sv"
`endif

import common::*;
package combined_wire;
    import common::*;

    typedef struct packed {
        reg_addr reg_dest_addr;
        bool reg_write_enable;
        word_t reg_write_data;
    } reg_writer;

    typedef struct packed {
        bool do_jump;
        bool jump_inst;
        addr_t dest_addr;

        word_t inst_counter;
    } jump_writer;

endpackage

`endif