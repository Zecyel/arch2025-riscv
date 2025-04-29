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
    input csr_addr csr_dest_addr,
    input csr_t csr_write_data,

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
        end else if (csr_write_enable) begin
            unique case (csr_dest_addr)
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
