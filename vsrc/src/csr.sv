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

    input logic csr_write_enable,
    input u12 csr_addr,
    input csr_t csr_write_data,

    output csr_pack csr
);

    csr_pack csr_reg;

    assign csr = csr_reg;

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
        end else if (reg_write_enable) begin
            unique case (csr_addr)
                CSR_MSTATUS: csr_reg.mstatus <= csr_write_data & MSTATUS_MASK;
                CSR_MTVEC: csr_reg.mtvec <= csr_write_data & MTVEC_MASK;
                CSR_MIP: csr_reg.mip <= csr_write_data & MIP_MASK;
                CSR_MIE: csr_reg.mie <= csr_write_data;
                CSR_MSCRATCH: csr_reg.mscratch <= csr_write_data;
                CSR_MCAUSE: csr_reg.mcause <= csr_write_data;
                CSR_MTVAL: csr_reg.mtval <= csr_write_data;
                CSR_MEPC: csr_reg.mepc <= csr_write_data;
                CSR_MCYCLE: csr_reg.mcycle <= csr_write_data;
                CSR_MHARTID: csr_reg.mhartid <= csr_write_data;
                CSR_SATP: csr_reg.satp <= csr_write_data;
                default: begin end
            endcase
        end
    end

endmodule

module csr_selector (
    input csr_pack csr,
    input u12 csr_addr,
    output csr_t csr_out
);

    always_comb begin
        unique case (csr_addr)
            CSR_MSTATUS: csr_out = csr_reg.mstatus;
            CSR_MTVEC: csr_out = csr_reg.mtvec;
            CSR_MIP: csr_out = csr_reg.mip;
            CSR_MIE: csr_out = csr_reg.mie;
            CSR_MSCRATCH: csr_out = csr_reg.mscratch;
            CSR_MCAUSE: csr_out = csr_reg.mcause;
            CSR_MTVAL: csr_out = csr_reg.mtval;
            CSR_MEPC: csr_out = csr_reg.mepc;
            CSR_MCYCLE: csr_out = csr_reg.mcycle;
            CSR_MHARTID: csr_out = csr_reg.mhartid;
            CSR_SATP: csr_out = csr_reg.satp;
            default: csr_out = 'h114514; // dummy value, to make verilog happy
        endcase
    end

endmodule

`endif
