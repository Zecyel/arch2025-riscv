`ifndef __EX_SV
`define __EX_SV

`include "include/common.sv"
`include "include/temp_storage.sv"
`include "src/EX/alu.sv"

module execute
    import common::*;
    import temp_storage::*;
(
    input logic clk,

    input id_ex id_ex_state,
    output ex_mem ex_mem_state
);
    
    alu alu_inst (
        .immed(id_ex_state.immed),
        .reg1(id_ex_state.reg1_value),
        .reg2(id_ex_state.reg2_value),
        .funct3(id_ex_state.funct3),
        .funct7(id_ex_state.funct7),
        .opcode(id_ex_state.opcode),
        .result(ex_mem_state.alu_result)
    );

    always_comb begin
        ex_mem_state.reg_dest_addr = id_ex_state.reg_dest_addr;
        ex_mem_state.reg_write_enable = id_ex_state.reg_write_enable;
        
        ex_mem_state.inst_signal = id_ex_state.inst_signal;
        ex_mem_state.inst = id_ex_state.inst;
        ex_mem_state.inst_pc = id_ex_state.inst_pc;
    end

endmodule

`endif