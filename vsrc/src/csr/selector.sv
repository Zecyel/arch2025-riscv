`ifndef __SELECTOR_SV
`define __SELECTOR_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`endif

module csr_selector
    import common::*;
    import csr_pkg::*;
(
    input csr_pack csr,
    input csr_addr csr_dest_addr,
    output csr_t csr_out,
    output csr_mask mask
);

    always_comb begin
        unique case (csr_dest_addr)
            CSR_MSTATUS: begin
                csr_out = csr.mstatus;
                mask = 1;
            end
            CSR_MTVEC: begin
                csr_out = csr.mtvec;
                mask = 2;
            end
            CSR_MIP: begin
                csr_out = csr.mip;
                mask = 4;
            end
            CSR_MIE: begin
                csr_out = csr.mie;
                mask = 4;
            end
            CSR_MSCRATCH: begin
                csr_out = csr.mscratch;
                mask = 8;
            end
            CSR_MCAUSE: begin
                csr_out = csr.mcause;
                mask = 'h10;
            end
            CSR_MTVAL: begin
                csr_out = csr.mtval;
                mask = 'h20;
            end
            CSR_MEPC: begin
                csr_out = csr.mepc;
                mask = 'h40;
            end
            CSR_MCYCLE: begin
                csr_out = csr.mcycle;
                mask = 'h80;
            end
            CSR_MHARTID: begin
                csr_out = csr.mhartid;
                mask = 'h100;
            end
            CSR_SATP: begin
                csr_out = csr.satp;
                mask = 'h200;
            end
            default: begin
                csr_out = 'h114514; // dummy value, to make verilog happy
                mask = 0;
            end
        endcase
    end

endmodule

`endif