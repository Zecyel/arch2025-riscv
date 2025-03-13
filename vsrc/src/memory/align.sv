`ifndef __ALIGN_SV
`define __ALIGN_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/instruction.sv"
`endif

module read_align
    import common::*;
(
    input addr_t addr,
    input word_t data,
    input msize_t size,
    input bool zero_extend,

    output word_t raw_data
);
    /*
     * We propose there is no necessary for second access to memory
     * It should be handled by the compiler
     */
    
    word_t unextended_data; // stupid latch

    always_comb begin
        case (size)
            MSIZE1: begin
                unextended_data[7:0] = data[8*addr[2:0] +: 8];
                raw_data = zero_extend
                    ? { 56'b0, unextended_data[7:0] }
                    : { {56{unextended_data[7]}}, unextended_data[7:0] };
            end
            MSIZE2: begin
                unextended_data[15:0] = data[8*addr[2:0] +: 16];
                raw_data = zero_extend
                    ? { 48'b0, unextended_data[15:0] }
                    : { {48{unextended_data[15]}}, unextended_data[15:0] };
            end
            MSIZE4: begin
                unextended_data[31:0] = data[8*addr[2:0] +: 32];
                raw_data = zero_extend
                    ? { 32'b0, unextended_data[31:0] }
                    : { {32{unextended_data[31]}}, unextended_data[31:0] };
            end
            MSIZE8: begin
                unextended_data = data; // stupid latch
                raw_data = data;
            end
            default: begin
                unextended_data = 64'h1919810; // stupid latch
                raw_data = 64'h114514; // stupid typechecker
            end
        endcase
    end

endmodule

module write_align
    import common::*;
(
    input addr_t addr,
    input msize_t size,
    input word_t raw_data, // only the low 2*size bits are valid

    output strobe_t strobe,
    output word_t data
);
    /*
     * We propose there is no necessary for second access to memory
     * It should be handled by the compiler
     */

    u8 mask;

    always_comb begin
        case (size)
            MSIZE1: mask = 1;
            MSIZE2: mask = 3;
            MSIZE4: mask = 15;
            MSIZE8: mask = 255;
            default: mask = 255; // stupid typechecker
        endcase
        strobe = mask << addr[2:0];

        case (size)
            MSIZE1: data = raw_data << (8 * addr[2:0]);
            MSIZE2: data = raw_data << (8 * addr[2:0]);
            MSIZE4: data = raw_data << (8 * addr[2:0]);
            MSIZE8: data = raw_data;
            default: data = 64'h114514; // stupid typechecker
        endcase
    end

endmodule

module databus_pre_align
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    input addr_t addr,
    input word_t raw_data,

    output msize_t size,
    output strobe_t strobe,
    output word_t data
);
    strobe_t strobe_w;

    always_comb begin
        case (op)
            SB: size = MSIZE1;
            SH: size = MSIZE2;
            SW: size = MSIZE4;
            SD: size = MSIZE8;
            default: begin end
        endcase
    end

    write_align write_align_inst (
        .addr(addr),
        .size(size),
        .raw_data(raw_data),
        .strobe(strobe_w),
        .data(data)
    );

    always_comb begin
        case (op)
            SB, SH, SW, SD: strobe = strobe_w;
            LB, LH, LW, LBU, LHU, LD, LWU: strobe = 0;
        endcase
    end

endmodule

module databus_post_align
    import common::*;
    import instruction::*;
(
    input instruction_type op,
    input addr_t addr,
    input word_t data,
    output word_t raw_data
);

    msize_t size;
    bool zero_extend;

    always_comb begin
        case (op)
            LB, LBU: size = MSIZE1;
            LH, LHU: size = MSIZE2;
            LW, LWU: size = MSIZE4;
            LD: size = MSIZE8;
        endcase

        case (op)
            LB, LH, LW, LD: zero_extend = 0;
            LBU, LHU, LWU: zero_extend = 1;
        endcase
    end

    read_align read_align_inst (
        .addr(addr),
        .data(data),
        .size(size),
        .zero_extend(zero_extend),
        .raw_data(raw_data)
    );

endmodule

`endif