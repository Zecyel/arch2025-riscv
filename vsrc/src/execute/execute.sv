`ifndef __EX_SV
`define __EX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`include "src/execute/alu.sv"
`endif

module execute
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
(
    input id_ex id_ex_state,
    output ex_mem ex_mem_state,

    output reg_writer forward,

    output bool ok
);
    
    word_t alu_result;

    alu alu_inst (
        .immed(id_ex_state.immed),
        .reg1(id_ex_state.reg1_value),
        .reg2(id_ex_state.reg2_value),
        .op(id_ex_state.op),
        .result(alu_result)
    );

    always_comb begin        
        ex_mem_state.inst = id_ex_state.inst;
        ex_mem_state.inst_pc = id_ex_state.inst_pc;

        ex_mem_state.valid = id_ex_state.valid;

        forward.reg_dest_addr = id_ex_state.writer.reg_dest_addr;
        forward.reg_write_enable = id_ex_state.writer.reg_write_enable;
        forward.reg_write_data = alu_result;

        ex_mem_state.writer = forward;

        ok = 1;
    end

endmodule

`endif