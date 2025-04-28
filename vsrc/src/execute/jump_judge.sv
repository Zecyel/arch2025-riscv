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
    input word_t op1,
    input word_t op2,
    output bool do_jump
);

    always_comb begin
        case (op)
            JAL, JALR: do_jump = 1;
            BEQ: do_jump = op1 == op2;
            BNE: do_jump = op1 != op2;
            BLT: do_jump = $signed(op1) < $signed(op2);
            BGE: do_jump = $signed(op1) >= $signed(op2);
            BLTU: do_jump = op1 < op2;
            BGEU: do_jump = op1 >= op2;
            default: begin end
        endcase
    end

endmodule

`endif