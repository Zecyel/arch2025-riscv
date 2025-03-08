`ifndef __PARSE_OPERATION_SV
`define __PARSE_OPERATION_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module parse_operation
    import common::*;
    import instruction::*;
(
    input inst_t inst,
    output instruction_type op
);
    u7 opcode;
    u3 funct3;
    u7 funct7;

    always_comb begin

        opcode = inst[6:0];
        funct3 = inst[14:12];
        funct7 = inst[31:25];

        unique case (opcode)
            7'b0110011: case ({1'b0, funct3, 1'b0, funct7})
                'h000: op = ADD;
                'h020: op = SUB;
                'h700: op = AND;
                'h600: op = OR;
                'h400: op = XOR;
            endcase
            7'b0010011: case (funct3)
                'h0: op = ADDI;
                'h4: op = XORI;
                'h6: op = ORI;
                'h7: op = ANDI;
            endcase
            7'b0011011: case (funct3)
                'h0: op = ADDIW;
            endcase
            7'b0111011: case ({1'b0, funct3, 1'b0, funct7})
                'h000: op = ADDW;
                'h020: op = SUBW;
            endcase
            7'b0110111: op = LUI;
            7'b0010111: op = AUIPC;
            default: begin end
        endcase

    end

endmodule

`endif