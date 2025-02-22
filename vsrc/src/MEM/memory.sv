`ifndef __MEMORY_SV
`define __MEMORY_SV

`include "include/common.sv"
`include "include/temp_storage.sv"

module memory
    import common::*;
    import temp_storage::*;
(
    input ex_mem ex_mem_state,
    output mem_wb mem_wb_state
);
    always_comb begin
        mem_wb_state.reg_dest_addr = ex_mem_state.reg_dest_addr;
        mem_wb_state.reg_write_enable = ex_mem_state.reg_write_enable;
        mem_wb_state.reg_write_data = ex_mem_state.alu_result;
    end

endmodule

`endif