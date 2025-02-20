`ifndef __DECODER_SV
`define __DECODER_SV

`include "include/common.sv"

module decoder import common::*; (
    input u32 instu,

    output u12 immed,
    output u3 funct3,
    output u7 funct7,
    output u7 opcode,
    output reg_addr reg1_addr,
    output reg_addr reg2_addr,
    output reg_addr reg_dest_addr
)

    always_comb begin
        opcode = instu[6:0];
        funct3 = instu[14:12];
        funct7 = instu[31:25];
        if (opcode == 7'b0010011) begin
            immed = instu[31:20];
        end;
        reg1_addr = instu[19:15];
        reg2_addr = instu[24:20];
        reg_dest_addr = instu[11:7];
    end

endmodule

`endif