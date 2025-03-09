`ifndef __ARITH_DECODER_SV
`define __ARITH_DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module arith_decoder
    import common::*;
    import instruction::*;
(
    input inst_t inst,
    input instruction_type op,
    output word_t immed,

    output bool reg_write_enable
);
    always_comb begin

        unique case (op)
            ADD, SUB, AND, OR, XOR, ADDW, SUBW: immed = 0;
            ADDI, XORI, ORI, ANDI, ADDIW: immed = { {52{inst[31]}}, inst[31:20] };
            LUI, AUIPC: immed = { {32{inst[31]}}, inst[31:12], 12'b0 };
            default: begin end
        endcase

        unique case (op)
            ADD, SUB, AND, OR, XOR, ADDI, XORI, ORI, ANDI, ADDIW, ADDW, SUBW, LUI: reg_write_enable = 1;
            default: begin end
        endcase

    end

endmodule

`endif