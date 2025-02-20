`ifndef __EX_SV
`define __EX_SV

`include "include/common.sv"
`include "include/temp_storage.sv"
`include "src/EX/alu.sv"

module execute
    import common::*;
    import temp_storage::*;
(
    // input logic clock,
    input id_ex id_ex_state,
    output ex_mem ex_mem_state
);
    
    alu alu_inst(
        .immed(id_ex_state.immed),
        .reg1(id_ex_state.reg1_value),
        .reg2(id_ex_in.reg2_value),
        .funct3(id_ex_in.funct3),
        .funct7(id_ex_in.funct7),
        .opcode(id_ex_in.opcode),
        .result(ex_mem_out.alu_result)
    );

    always_comb begin
        ex_mem_state.reg_dest_addr = id_ex_state.reg_dest_addr;
    end


endmodule

`endif