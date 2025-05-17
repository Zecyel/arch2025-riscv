`ifndef __RISCV_SV
`define __RISCV_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`include "include/combined_wire.sv"
`include "include/csr.sv"

`include "src/regs.sv"

`include "src/fetch/fetch.sv"
`include "src/decode/decoder.sv"
`include "src/execute/execute.sv"
`include "src/memory/memory.sv"
`include "src/writeback/writeback.sv"
`include "src/commit/commit.sv"
`include "src/csr/csr.sv"
`endif

module riscv
    import common::*;
    import temp_storage::*;
    import combined_wire::*;
    import csr_pkg::*;
(
    // cpu basics
    input logic clk,
    input logic rst,

    // bus signals
    output ibus_req_t ireq,
    input ibus_resp_t iresp,
    output dbus_req_t dreq,
    input dbus_resp_t dresp,

    // for DiffTest
    output word_t pc,
    output word_t [31:0] regs,
    output csr_pack csrs_out,
    output bool reg_write_enable,
    output reg_addr reg_dest_addr,
    output word_t reg_write_data,

    // output wb_commit wb_commit
    output bool valid,
    output inst_t inst,
    output addr_t inst_pc,
    output mode_t mode,

    // interrupts
    input logic trint,
    input logic swint,
    input logic exint,

    output bool difftest_skip,
    input bool skip
);

    if_id if_id_state, if_id_state_new;
    id_ex id_ex_state, id_ex_state_new;
    ex_mem ex_mem_state, ex_mem_state_new;
    mem_wb mem_wb_state, mem_wb_state_new;
    wb_commit wb_commit_state, wb_commit_state_new;

    bool fetch_ok, decoder_ok, execute_ok, memory_ok, writeback_ok, commit_ok;
    bool unified_ok;
    
    assign unified_ok = fetch_ok & decoder_ok & execute_ok & memory_ok & writeback_ok & commit_ok;

    reg_writer ex_forward, mem_forward, wb_forward;
    jump_writer jump;
    csr_writer csr_write;
    csr_pack csrs;

    assign csrs_out = csrs;

    mode_t pmode, new_pmode;
    assign mode = pmode;
    bool update_pmode;

    csr csr_inst (
        .clk(clk),
        .rst(rst),
        .csrs(csrs),
        .writer(csr_write),
        .pmode(pmode),
        .new_pmode(new_pmode),
        .update_pmode(update_pmode),
        .trint(trint),
        .swint(swint),
        .exint(exint)
    );

    always_comb begin
        reg_write_enable = wb_commit_state_new.writer.reg_write_enable & unified_ok;
        reg_dest_addr = wb_commit_state_new.writer.reg_dest_addr;
        reg_write_data = wb_commit_state_new.writer.reg_write_data;
    end

    word_t inst_counter;

    regs regs_inst (
        .clk(clk),
        .rst(rst),
        .reg_write_enable(reg_write_enable),
        .reg_dest_addr(reg_dest_addr),
        .reg_write_data(reg_write_data),
        .regs_value(regs)
    );

    fetch fetch_instance (
        .ireq(ireq),
        .iresp(iresp),
        .pc(pc),
        .clk(clk),
        .rst(rst),
        .enable(unified_ok),
        .if_id_state(if_id_state_new),
        .jump(jump),
        .inst_counter(inst_counter),
        .trint(trint),
        .swint(swint),
        .exint(exint),
        .priviledge_mode(pmode),
        .mstatus(csrs.mstatus),
        .mip(csrs.mip),
        .mie(csrs.mie),
        .ok(fetch_ok)
    );

    decoder decoder_instance (
        .if_id_state(if_id_state),
        .id_ex_state(id_ex_state_new),
        .regs_value(regs),
        .csr_values(csrs),

        .forward1(ex_forward),
        .forward2(mem_forward),
        .forward3(wb_forward),

        .trint(trint),
        .swint(swint),
        .exint(exint),
        
        .ok(decoder_ok)
    );

    execute execute_instance (
        .clk(clk),
        .id_ex_state(id_ex_state),
        .ex_mem_state(ex_mem_state_new),

        .forward(ex_forward),
        .forward1(mem_forward),
        .forward2(wb_forward),

        .ok(execute_ok)
    );

    memory memory_instance (
        .clk(clk),
        .rst(rst),
        .enable(unified_ok),
        .dreq(dreq),
        .dresp(dresp),
        .ex_mem_state(ex_mem_state),
        .mem_wb_state(mem_wb_state_new),
        .forward(mem_forward),
        .skip(skip),
        .ok(memory_ok)
    );

    writeback writeback_instance (
        .clk(clk),
        .rst(rst),
        .mem_wb_state(mem_wb_state),
        .wb_commit_state(wb_commit_state_new),
        .priviledge_mode(pmode),
        .mstatus(csrs.mstatus),
        .mip(csrs.mip),
        .mie(csrs.mie),
        .mtvec(csrs.mtvec),
        .forward(wb_forward),
        .csr(csr_write),
        .ok(writeback_ok)
    );

    commit commit_instance (
        .clk(clk),
        .rst(rst),
        .wb_commit_state(wb_commit_state),
        .valid(valid),
        .inst(inst),
        .inst_pc(inst_pc),
        .jump(jump),
        .difftest_skip(difftest_skip),
        .inst_counter(inst_counter),

        .ok(commit_ok)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // drink a cup of java ( also try brew! )
            // take on springboot
            // don't forget your redhat
            pmode <= 3;
        end else begin
            if (update_pmode) begin
                pmode <= new_pmode;
                // $display("pmode changed to %0d", new_pmode);
            end
            if (unified_ok) begin
                if_id_state <= if_id_state_new;
                id_ex_state <= id_ex_state_new;
                ex_mem_state <= ex_mem_state_new;
                mem_wb_state <= mem_wb_state_new;
                wb_commit_state <= wb_commit_state_new;
            end
        end
    end

endmodule


`endif