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

    typedef struct packed {
        bool csr_write_enable;
        csr_t csr_write_data;
        csr_addr csr_dest_addr;
        // plain csr change above

        bool plain;
        bool ecall;
        bool ebreak;
        bool mret;
        addr_t pc;
    } csr_writer;

endpackage

`endif