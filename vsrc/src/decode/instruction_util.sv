`ifndef __INSTRUCTION_UTIL_SV
`define __INSTRUCTION_UTIL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module is_write_reg
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool write_reg
);

    always_comb begin
        case (op)
            ADD, SUB, XOR, OR, AND,
            SLL, SRL, SRA, SLT, SLTU,
            ADDI, XORI, ORI, ANDI,
            SLLI, SRLI, SRAI, SLTI, SLTIU,
            ADDIW, ADDW, SUBW,
            SLLIW, SRLIW, SRAIW, SLLW, SRLW, SRAW,
            LB, LH, LW, LBU, LHU, LD, LWU,
            JAL, JALR,
            LUI, AUIPC: write_reg = 1;

            default: write_reg = 0;
        endcase
    end

endmodule

module is_arith
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool arith
);

    always_comb begin
        case (op)
            ADD, SUB, XOR, OR, AND,
            SLL, SRL, SRA, SLT, SLTU,
            ADDI, XORI, ORI, ANDI,
            SLLI, SRLI, SRAI, SLTI, SLTIU,
            ADDIW, ADDW, SUBW,
            SLLIW, SRLIW, SRAIW, SLLW, SRLW, SRAW,
            LUI: arith = 1;

            default: arith = 0;
        endcase
    end

endmodule

module is_memory
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool memory
);

    always_comb begin
        case (op)
            LB, LH, LW, LBU, LHU, LD, LWU,
            SB, SH, SW, SD: memory = 1;

            default: memory = 0;
        endcase
    end

endmodule

module is_memory_read
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    output bool memory_read
);

    always_comb begin
        case (op)
            LB, LH, LW, LBU, LHU, LD, LWU: memory_read = 1;
            default: memory_read = 0;
        endcase
    end

endmodule

`endif