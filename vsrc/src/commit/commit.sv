`ifndef __COMMIT_SV
`define __COMMIT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`endif

module commit
    import common::*;
    import temp_storage::*;
(
    input wb_commit wb_commit_state,
    input logic enable,

    output logic valid,
    output inst_t inst,
    output addr_t inst_pc
);

    always_comb begin
        valid = wb_commit_state.valid & enable;
        inst = wb_commit_state.inst;
        inst_pc = wb_commit_state.inst_pc;
    end

endmodule

`endif