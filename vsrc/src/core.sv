`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

`include "src/riscv.sv"

module core import common::*; (
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	
	word_t [31:0] regs;
	word_t pc;

	bool write_regs_enable;
	u5 write_reg_addr;
	word_t write_reg_data;
	
	riscv riscv_inst (
		// cpu basics
		.clk(clk),
		.rst(reset),
		
		// bus signals
		.ireq(ireq),
		.iresp(iresp),

		// for DiffTest
		.pc(pc),
		.regs(regs),
		.write_regs_enable(write_regs_enable),
		.write_reg_addr(write_reg_addr),
		.write_reg_data(write_reg_data)
	);

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (1'b1),
		.pc                 (pc), // where to set PCINIT?
		.instr              (0),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (write_regs_enable),
		.wdest              (write_reg_addr),
		.wdata              (write_reg_data)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
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
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0 /* mstatus & 64'h800000030001e000 */),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif