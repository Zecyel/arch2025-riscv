`ifndef __CSR_SV
`define __CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`endif

module csr
    import common::*;
    import csr_pkg::*;
(
    input logic clk,
    input logic rst,

    input csr_pack new_csrs,
    input csr_mask mask,

    output csr_pack csrs
);

    csr_pack csr_reg;

    assign csrs = csr_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            csr_reg.mstatus <= 0;
            csr_reg.mtvec <= 0;
            csr_reg.mip <= 0;
            csr_reg.mie <= 0;
            csr_reg.mscratch <= 0;
            csr_reg.mcause <= 0;
            csr_reg.mtval <= 0;
            csr_reg.mepc <= 0;
            csr_reg.mcycle <= 0;
            csr_reg.mhartid <= 0;
            csr_reg.satp <= 0;
        end else begin
            if (mask.mstatus) csr_reg.mstatus <= new_csrs.mstatus & MSTATUS_MASK;
            if (mask.mtvec) csr_reg.mtvec <= new_csrs.mtvec & MTVEC_MASK;
            if (mask.mip) csr_reg.mip <= new_csrs.mip & MIP_MASK;
            if (mask.mie) csr_reg.mie <= new_csrs.mie;
            if (mask.mcycle) csr_reg.mcycle <= new_csrs.mcycle;
            else csr_reg.mcycle <= csr_reg.mcycle + 1;
            if (mask.mscratch) csr_reg.mscratch <= new_csrs.mscratch;
            if (mask.mcause) csr_reg.mcause <= new_csrs.mcause;
            if (mask.mtval) csr_reg.mtval <= new_csrs.mtval;
            if (mask.mepc) csr_reg.mepc <= new_csrs.mepc;
            if (mask.mcycle) csr_reg.mcycle <= new_csrs.mcycle;
            if (mask.mhartid) csr_reg.mhartid <= new_csrs.mhartid;
            if (mask.satp) csr_reg.satp <= new_csrs.satp;
        end
    end

endmodule

`endif
