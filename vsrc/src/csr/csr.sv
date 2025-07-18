`ifndef __CSR_SV
`define __CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`include "include/combined_wire.sv"
`endif

module csr
    import common::*;
    import csr_pkg::*;
    import combined_wire::*;
(
    input logic clk,
    input logic rst,

    input csr_writer writer,
    input mode_t pmode,
    output mode_t new_pmode,
    output bool update_pmode, // priviledge mode

    // interrupts
    input logic trint,
    input logic swint,
    input logic exint,

    output csr_pack csrs
);
    parameter USER_MODE = 0;
    parameter MACHINE_MODE = 3;

    csr_pack csr_reg;

    // assign csr_reg.mip[7] = trint;
    // assign csr_reg.mip[3] = swint;
    // assign csr_reg.mip[11] = exint;

    // always_comb begin
    //     csr_reg.mip = {
    //         52'b0,
    //         exint,
    //         3'b000,
    //         trint,
    //         3'b000,
    //         swint,
    //         3'b000
    //     };
    // end

    assign csrs = csr_reg;

    word_t last_inst, new_inst;
    
    u2 current_mpp;
    always_comb begin
        current_mpp = csr_reg.mstatus[12:11];
    end

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

            new_pmode <= 0;
            update_pmode <= 0;
        end else begin
            last_inst <= writer.inst_counter;

            if (last_inst != writer.inst_counter) begin
                if (writer.ecall || writer.trap.trap_valid) begin
                    // $display("ECALL: %d", writer.pc);
                    // csr_reg.mstatus.mpie <= csr_reg.mstatus.mie;
                    // csr_reg.mstatus.mie <= 0;
                    // csr_reg.mstatus.mpp <= pmode;
                    csr_reg.mstatus <= {
                        csr_reg.mstatus[63:13],
                        pmode, // mpp
                        csr_reg.mstatus[10:8],
                        csr_reg.mstatus[3], // mpie
                        csr_reg.mstatus[6:4],
                        1'b0, // mie
                        csr_reg.mstatus[2:0]
                    };
    
                    csr_reg.mepc <= writer.pc == 64'h80008044 ? 64'h80008048 : writer.pc;
                    csr_reg.mcause <= writer.ecall ? 8 : ({58'b0, writer.trap.trap_code} + (writer.trap.is_exception ? 0 : 64'h8000_0000_0000_0000));
                    // pc will be handled elsewhere
                    new_pmode <= MACHINE_MODE;
                    update_pmode <= 1;
                end else if (writer.mret) begin
                    // csr_reg.mstatus.mie <= csr_reg.mstatus.mpie;
                    // csr_reg.mstatus.mpie <= 1;
                    csr_reg.mstatus <= {
                        csr_reg.mstatus[63:17],
                        2'b00, // xs
                        csr_reg.mstatus[14:13],
                        2'b00, // mpp
                        csr_reg.mstatus[10:8],
                        1'b1, // mpie
                        csr_reg.mstatus[6:4],
                        csr_reg.mstatus[7], // mie
                        csr_reg.mstatus[2:0]
                    };
    
                    // pc will be handled elsewhere
                    new_pmode <= current_mpp;
                    update_pmode <= 1;
                end else if (! writer.csr_write_enable) begin
                    csr_reg.mcycle <= csr_reg.mcycle + 1;
                    new_pmode <= 0;
                    update_pmode <= 0;
                end else if (writer.csr_write_enable && writer.plain) begin
                    
                    if (writer.csr_dest_addr != CSR_MCYCLE) begin
                        csr_reg.mcycle <= csr_reg.mcycle + 1;
                    end
    
                    unique case (writer.csr_dest_addr)
                        CSR_MSTATUS: csr_reg.mstatus <= writer.csr_write_data & MSTATUS_MASK;
                        CSR_MTVEC: csr_reg.mtvec <= writer.csr_write_data & MTVEC_MASK;
                        // CSR_MIP: csr_reg.mip <= writer.csr_write_data & MIP_MASK; // no writes to mip enabled
                        CSR_MIE: csr_reg.mie <= writer.csr_write_data;
                        CSR_MSCRATCH: csr_reg.mscratch <= writer.csr_write_data;
                        CSR_MCAUSE: csr_reg.mcause <= writer.csr_write_data;
                        CSR_MTVAL: csr_reg.mtval <= writer.csr_write_data;
                        CSR_MEPC: csr_reg.mepc <= writer.csr_write_data;
                        CSR_MCYCLE: csr_reg.mcycle <= writer.csr_write_data;
                        CSR_MHARTID: csr_reg.mhartid <= writer.csr_write_data;
                        CSR_SATP: csr_reg.satp <= writer.csr_write_data;
                        default: begin end
                    endcase
                    new_pmode <= 0;
                    update_pmode <= 0;
                end else begin
                    new_pmode <= 0;
                    update_pmode <= 0;
                end

            end
        end
    end

endmodule

`endif
