`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`include "src/riscv.sv"
`endif

module core
    import common::*;
    import csr_pkg::*;
(
    input  logic       clk, reset,
    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp,
    input  logic       trint, swint, exint,

    output csr_t satp,
    output mode_t priviledge_mode,
    input bool skip
);
    
    word_t [31:0] regs;
    csr_pack csrs;
    addr_t pc;

    bool reg_write_enable;
    u5 reg_dest_addr;
    word_t reg_write_data;

    bool delayed_reg_write_enable;
    u5 delayed_reg_dest_addr;
    word_t delayed_reg_write_data;

    bool valid;
    inst_t inst;
    addr_t inst_pc;
    mode_t mode;

    assign satp = csrs.satp;
    assign priviledge_mode = mode;
    
    logic manual_reset_signal;
    bool reseted;

    bool difftest_skip;
    
    always_ff @(posedge reset or posedge clk) begin
        if (reset) begin
            reseted <= 0;
            manual_reset_signal <= 0;
        end else begin
            if (reseted) begin
                manual_reset_signal <= 0;
            end else begin
                manual_reset_signal <= 1;
                reseted <= 1;
            end
        end
    end

    riscv riscv_inst (
        // cpu basics
        .clk(clk),
        .rst(manual_reset_signal),
        
        // bus signals
        .ireq(ireq),
        .iresp(iresp),
        .dreq(dreq),
        .dresp(dresp),

        // for DiffTest
        .pc(pc), // the pc of to-be-executed instruction
        .regs(regs),
        .csrs_out(csrs),
        .reg_write_enable(reg_write_enable),
        .reg_dest_addr(reg_dest_addr),
        .reg_write_data(reg_write_data),
        .valid(valid),
        .inst(inst),
        .inst_pc(inst_pc), // the pc of the finished instruction
        .mode(mode),
        .difftest_skip(difftest_skip),

        // external interrupts
        .trint(trint),
        .swint(swint),
        .exint(exint),
        .skip(skip)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            delayed_reg_write_enable <= 0;
            delayed_reg_dest_addr <= 0;
            delayed_reg_write_data <= 0;
        end else begin
            delayed_reg_write_enable <= reg_write_enable;
            delayed_reg_dest_addr <= reg_dest_addr;
            delayed_reg_write_data <= reg_write_data;
        end
    end

`ifdef VERILATOR
    DifftestInstrCommit DifftestInstrCommit(
        .clock              (clk),
        .coreid             (csrs.mhartid[7:0]),
        .index              (0),
        .valid              (valid),
        .pc                 (inst_pc),
        .instr              (inst),
        .skip               (difftest_skip),
        .isRVC              (0),
        .scFailed           (0),
        .wen                (delayed_reg_write_enable),
        .wdest              ({3'b000, delayed_reg_dest_addr}), // to make kooWZ happy
        .wdata              (delayed_reg_write_data)
    );

    DifftestArchIntRegState DifftestArchIntRegState (
        .clock              (clk),
        .coreid             (csrs.mhartid[7:0]),
        .gpr_0              (regs[0]),
        .gpr_1              (regs[1]),
        .gpr_2              (regs[2]),
        .gpr_3              (regs[3]),
        .gpr_4              (regs[4]),
        .gpr_5              (regs[5]),
        .gpr_6              (regs[6]),
        .gpr_7              (regs[7]),
        .gpr_8              (regs[8]),
        .gpr_9              (regs[9]),
        .gpr_10             (regs[10]),
        .gpr_11             (regs[11]),
        .gpr_12             (regs[12]),
        .gpr_13             (regs[13]),
        .gpr_14             (regs[14]),
        .gpr_15             (regs[15]),
        .gpr_16             (regs[16]),
        .gpr_17             (regs[17]),
        .gpr_18             (regs[18]),
        .gpr_19             (regs[19]),
        .gpr_20             (regs[20]),
        .gpr_21             (regs[21]),
        .gpr_22             (regs[22]),
        .gpr_23             (regs[23]),
        .gpr_24             (regs[24]),
        .gpr_25             (regs[25]),
        .gpr_26             (regs[26]),
        .gpr_27             (regs[27]),
        .gpr_28             (regs[28]),
        .gpr_29             (regs[29]),
        .gpr_30             (regs[30]),
        .gpr_31             (regs[31])
    );

    DifftestTrapEvent DifftestTrapEvent(
        .clock              (clk),
        .coreid             (csrs.mhartid[7:0]),
        .valid              (0),
        .code               (0),
        .pc                 (0),
        .cycleCnt           (0),
        .instrCnt           (0)
    );

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (csrs.mhartid[7:0]),
		.priviledgeMode     (mode),
		.mstatus            (csrs.mstatus),
		.sstatus            (csrs.mstatus & SSTATUS_MASK),
		.mepc               (csrs.mepc),
		.sepc               (0),
		.mtval              (csrs.mtval),
		.stval              (0),
		.mtvec              (csrs.mtvec),
		.stvec              (0),
		.mcause             (csrs.mcause),
		.scause             (0),
		.satp               (csrs.satp),
		.mip                (csrs.mip),
		.mie                (csrs.mie),
		.mscratch           (csrs.mscratch),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif