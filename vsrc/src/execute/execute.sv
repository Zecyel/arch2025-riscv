`ifndef __EX_SV
`define __EX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "src/execute/alu.sv"
`endif

module execute
    import common::*;
    import temp_storage::*;
(
    input id_ex id_ex_state,
    output ex_mem ex_mem_state,

    output bool ok
);
    
    alu alu_inst (
        .immed(id_ex_state.immed),
        .reg1(id_ex_state.reg1_value),
        .reg2(id_ex_state.reg2_value),
        .op(id_ex_state.op),
        .result(ex_mem_state.alu_result)
    );

    always_comb begin
        ex_mem_state.reg_dest_addr = id_ex_state.reg_dest_addr;
        ex_mem_state.reg_write_enable = id_ex_state.reg_write_enable;
        
        ex_mem_state.inst = id_ex_state.inst;
        ex_mem_state.inst_pc = id_ex_state.inst_pc;

        ex_mem_state.valid = id_ex_state.valid;

        ok = 1;
    end

endmodule

`endif