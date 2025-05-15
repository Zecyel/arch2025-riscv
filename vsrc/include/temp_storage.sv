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
    import common::*;
    import instruction::*;
    import combined_wire::*;
    typedef struct packed {
        inst_t inst;
        addr_t inst_pc;
        bool valid;

        word_t inst_counter;
        trap_t trap;
    } if_id;

    typedef struct packed {
        // for forwarding
        reg_addr reg1_addr;
        reg_addr reg2_addr;

        word_t reg1_value;
        word_t reg2_value;
        word_t immed; // sign extended

        csr_t csr_value;
        csr_t mtvec;
        csr_t mepc;
        
        instruction_type op;
        inst_t inst;
        addr_t inst_pc;
        bool valid;

        word_t inst_counter;
        trap_t trap;
    } id_ex;

    typedef struct packed {
        word_t alu_result;
        word_t write_mem_data;

        jump_writer jump;
        instruction_type op;
        inst_t inst;
        addr_t inst_pc;
        bool valid;
        csr_writer csr;

        word_t inst_counter;
        trap_t trap;
    } ex_mem;

    typedef struct packed {
        word_t value; // from alu or memory

        jump_writer jump;
        instruction_type op;
        inst_t inst;
        addr_t inst_pc;
        bool valid;
        csr_writer csr;

        word_t inst_counter;
        trap_t trap;
        bool difftest_skip;
    } mem_wb;

    typedef struct packed {
        reg_writer writer; // for difftest

        jump_writer jump;
        inst_t inst;
        addr_t inst_pc;
        bool valid;
        csr_writer csr; // maybe?
        
        bool difftest_skip;
        trap_t trap;
        word_t inst_counter;
    } wb_commit;


endpackage

`endif