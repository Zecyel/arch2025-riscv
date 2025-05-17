`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/temp_storage.sv"
`endif

module fetch
    import common::*;
    import temp_storage::*;
(
    output ibus_req_t ireq,
    input ibus_resp_t iresp,

    output addr_t pc,
    input logic clk,
    input logic rst,
    input bool enable,

    input jump_writer jump,
    input word_t inst_counter,

    // interrupts
    input logic trint,
    input logic swint,
    input logic exint,
    input mode_t priviledge_mode,

    output if_id if_id_state,
    output bool ok
);

    addr_t _pc;
    bool waiting;

    addr_t last_pc;
    bool stall;

    word_t current_inst_counter;
    word_t stall_awokener;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset the state
            _pc <= PCINIT - 4;
            waiting <= 0;
            last_pc <= PCINIT - 4;
            stall <= 0;
            ireq.valid <= 0;
            ireq.addr <= 'h0000_0000;
            if_id_state.inst <= 'h0000_0000;
            if_id_state.inst_pc <= PCINIT;
            if_id_state.valid <= 1;

            current_inst_counter <= 0;

            if_id_state.trap.trap_valid <= 0;
            if_id_state.trap.trap_code <= 0;
        end else if (! waiting & enable) begin
            if (! stall || inst_counter == stall_awokener) begin
                stall <= 0; // clear the stall flag
                if (trint || swint || exint) begin
                    if_id_state.trap.trap_valid <= 1;
                    if (swint) begin
                        if_id_state.trap.trap_code <= 3;
                    end else if (trint) begin
                        if_id_state.trap.trap_code <= 7;
                    end else if (exint) begin
                        if_id_state.trap.trap_code <= 11;
                    end else begin
                        if_id_state.trap.is_exception <= 0; // dummy
                    end

                    current_inst_counter <= current_inst_counter + 1;
                    if_id_state.inst <= 0; // send a fake nop
                    stall <= 1; // stall the next instruction
                    stall_awokener <= current_inst_counter + 1;
                    if_id_state.valid <= 0;
                    if_id_state.inst_counter <= current_inst_counter + 1;

                end else if (jump.do_jump == 1 && jump.jump_inst == 1 && jump.dest_addr[1:0] != 0 || _pc[1:0] != 0) begin
                    // $display("pc unalign met");
                    if_id_state.trap.trap_valid <= 1;
                    if_id_state.trap.trap_code <= 0; // pc unaligned
                    if_id_state.trap.is_exception <= 1;

                    current_inst_counter <= current_inst_counter + 1;
                    if_id_state.inst <= 0; // send a fake nop
                    stall <= 1; // stall the next instruction
                    stall_awokener <= current_inst_counter + 1;
                    if_id_state.valid <= 0;
                    if_id_state.inst_counter <= current_inst_counter + 1;
                    if_id_state.inst_pc <= 114514; // no body cares. for better debugging experience
                end else begin
                    if_id_state.trap.trap_valid <= 0;
                    if_id_state.trap.trap_code <= 0;
                    if_id_state.trap.is_exception <= 0;
                    if (jump.do_jump & jump.jump_inst) begin
                        // jump to the target addr
                        _pc <= jump.dest_addr;

                        // send the request
                        ireq.valid <= 1;
                        ireq.addr <= jump.dest_addr;
                        waiting <= 1;
                        last_pc <= jump.dest_addr;
                        if_id_state.valid <= 0;
                    end else begin
                        // send the request
                        ireq.valid <= 1;
                        ireq.addr <= _pc + 4;
                        waiting <= 1;
                        last_pc <= _pc + 4;
                        if_id_state.valid <= 0;

                        // increase the PC
                        _pc <= _pc + 4;
                    end
                end
            end else begin
                // awaiting for the stall flag
                // ignore the instruction bus
                if_id_state.valid <= 0;
                if_id_state.inst <= 0;
                if_id_state.trap.trap_valid <= 0;
                if_id_state.trap.trap_code <= 0;
                if_id_state.trap.is_exception <= 0;
            end
        end else if (iresp.addr_ok & iresp.data_ok) begin 
            current_inst_counter <= current_inst_counter + 1;

            ireq.valid <= 0;
            if_id_state.inst <= iresp.data;

            if (iresp.data[6:0] == 7'b1100011 || iresp.data[6:0] == 7'b1101111 || iresp.data[6:0] == 7'b1100111
                || iresp.data[6:0] == 7'b0000011 || iresp.data[6:0] == 7'b0100011 || iresp.data[6:0] == 7'b1110011) begin
                stall <= 1; // stall the next instruction
                stall_awokener <= current_inst_counter + 1;
            end else begin
                stall <= 0;
            end
            if_id_state.inst_pc <= last_pc;
            waiting <= 0;
            if_id_state.valid <= 1;
            if_id_state.inst_counter <= current_inst_counter + 1;
            if_id_state.trap.trap_valid <= 0;
            if_id_state.trap.trap_code <= 0;
            if_id_state.trap.is_exception <= 0;
        end
    end

    assign pc = _pc;
    assign ok = ! waiting;

endmodule

`endif