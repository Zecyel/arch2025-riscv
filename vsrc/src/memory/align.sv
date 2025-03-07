`ifndef __ALIGN_SV
`define __ALIGN_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

module read_align
    import common::*;
(
    input addr_t addr,
    input msize_t size,
    input word_t aligned_data,
    input bool zero_extend,

    output word_t data
);
    /*
     * We propose there is no necessary for second access to memory
     * It should be handled by the compiler
     */
    always_comb begin
        unique case (size)
            2'b00: begin
                u8 unextended_data = aligned_data[8*addr[2:0] +: 8];
                data = zero_extend
                    ? {{24{unextended_data[7]}}, unextended_data}
                    : unextended_data;
            end
            2'b01: begin
                u16 unextended_data = aligned_data[8*addr[2:0] +: 16];
                data = zero_extend
                    ? {{16{unextended_data[15]}}, unextended_data}
                    : unextended_data;
            end
            2'b10: begin
                u32 unextended_data = aligned_data[8*addr[2:0] +: 32];
                data = zero_extend
                    ? {{32{unextended_data[31]}}, unextended_data}
                    : unextended_data;
            end
            2'b11: data = aligned_data;
        endcase
    end

endmodule

module write_align
    import common::*;
(
    input addr_t addr,
    input msize_t size,
    input word_t data, // only the low 2*size bits are valid

    output strobe_t strobe,
    output word_t aligned_data
);
    /*
     * We propose there is no necessary for second access to memory
     * It should be handled by the compiler
     */

    always_comb begin
        strobe = 1 << addr[2:0];

        unique case (size)
            2'b00: aligned_data = data << (8 * addr[2:0]);
            2'b01: aligned_data = data << (8 * addr[2:0]);
            2'b10: aligned_data = data << (8 * addr[2:0]);
            2'b11: aligned_data = data;
        endcase
    end


endmodule

`endif