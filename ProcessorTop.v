
`include "ProgramCounter.v"
`include "InstructionMem.v"
`include "SignExtend.v"
`include "Shifter.v"
`include "DataMem.v"
`include "ControlLogic.v"
`include "Adder.v"
`include "Alu_Top.v"
`include "RegisterFile.v"

module ProcessorTop(
	clk,
	rst_n
    );

input clk;
input rst_n;

wire [31:0] ctrl_in_address;
wire [31:0] out_address;
wire [31:0] addr_incr;
wire [31:0] address_plus_4;
wire [31:0] branch_addr_offset;
wire [31:0] branch_address;
wire [31:0] instrn;
wire ctrl_write_en;
wire final_write_en;
wire [4:0] ctrl_write_addr;
wire [31:0] ctrl_regwrite_data;
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] sign_ext_out;
wire [31:0] ctrl_aluin2;
wire [31:0] alu_result;
wire zero_out;
wire [31:0] datamem_read_data;

assign addr_incr = (!rst_n) ? 32'd0 : 32'd4;
assign final_write_en = (!rst_n) ? 1'b0 : ctrl_write_en;

Program_Counter prg_cntr (
.clk (clk),
.rst_n (rst_n),
.in_address (ctrl_in_address),
.out_address (out_address)	
);

Adder adder_next_addr (
.in1 (out_address),
.in2 (addr_incr),
.out (address_plus_4)
);

Adder adder_branch_addr (
.in1 (address_plus_4),
.in2 (branch_addr_offset),
.out (branch_address)
);

InstructionMem instr_mem (
.instrn_address (out_address),
.instrn (instrn[31:0])
);

RegisterFile regfile (
.clk (clk),
.rst_n (rst_n),
.read_addr1 (instrn[25:21]),
.read_addr2 (instrn[20:16]), 
.write_en   (final_write_en),
.write_addr (ctrl_write_addr),
.write_data (ctrl_regwrite_data),
.read_data1 (read_data1),
.read_data2 (read_data2)
);

SignExtend sign_ext (
.bits16_in (instrn[15:0]),
.bits32_out (sign_ext_out)
);

Shifter shifter (
.indata (sign_ext_out),
.shift_amt (2'd2),
.shift_left (1'b1),
.outdata (branch_addr_offset)
);

Alu_Top alu (
.opcode (instrn[31:26]),
.func_field (instrn[5:0]),
.A (read_data1),
.B (ctrl_aluin2),
.result (alu_result),
.zero (zero_out)
);

DataMem data_mem (
.clk		(clk),
.address (alu_result),
.write_en (ctrl_datamem_write_en),
.write_data (read_data2),
.read_data (datamem_read_data)
);

ControlLogic ctrl_logic (
.instrn			  (instrn),
.instrn_opcode   (instrn[31:26]),
.address_plus_4  (address_plus_4),
.branch_address  (branch_address),
.ctrl_in_address (ctrl_in_address),
.alu_result      (alu_result),
.zero_out        (zero_out),
.ctrl_write_en   (ctrl_write_en),
.ctrl_write_addr (ctrl_write_addr),
.read_data2      (read_data2),
.sign_ext_out    (sign_ext_out),
.ctrl_aluin2     (ctrl_aluin2),
.ctrl_datamem_write_en (ctrl_datamem_write_en),
.datamem_read_data (datamem_read_data),
.ctrl_regwrite_data (ctrl_regwrite_data)
);

endmodule