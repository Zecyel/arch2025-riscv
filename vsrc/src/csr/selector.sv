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
    output csr_t csr_out
);

    always_comb begin
        unique case (csr_dest_addr)
            CSR_MSTATUS: csr_out = csr.mstatus;
            CSR_MTVEC: csr_out = csr.mtvec;
            CSR_MIP: csr_out = csr.mip;
            CSR_MIE: csr_out = csr.mie;
            CSR_MSCRATCH: csr_out = csr.mscratch;
            CSR_MCAUSE: csr_out = csr.mcause;
            CSR_MTVAL: csr_out = csr.mtval;
            CSR_MEPC: csr_out = csr.mepc;
            CSR_MCYCLE: csr_out = csr.mcycle;
            CSR_MHARTID: csr_out = csr.mhartid;
            CSR_SATP: csr_out = csr.satp;
            default: csr_out = 'h114514; // dummy value, to make verilog happy
        endcase
    end

endmodule

`endif