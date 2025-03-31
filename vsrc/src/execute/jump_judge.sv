`ifndef __JUMP_JUDEG_SV
`define __JUMP_JUDGE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module jump_judge
    import common::*;
(
    input instruction_type op,
    input word_t reg1,
    input word_t reg2,
    output bool do_jump
);

    always_comb begin
        case (op)
            JAL, JALR: do_jump = 1;
            BEQ: do_jump = reg1 == reg2;
            BNE: do_jump = reg1 != reg2;
            BLT: do_jump = $signed(reg1) < $signed(reg2);
            BGE: do_jump = $signed(reg1) >= $signed(reg2);
            BLTU: do_jump = reg1 < reg2;
            BGEU: do_jump = reg1 >= reg2;
            default: begin end
        endcase
    end

endmodule

`endif