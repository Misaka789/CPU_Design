// 文件名: ID_EX_Register.v
//`include "pipeline_reg.v"

module ID_EX_Register (
    input clk,
    input reset,

    // --- Inputs from ID Stage ---
    input [31:0] i_PC_plus_4,
    input [31:0] i_RD1,
    input [31:0] i_RD2,
    input [31:0] i_Imm,
    input [4:0]  i_rd,
    // Control Signals
    input        i_RegWrite,
    input        i_MemWrite,
    input        i_MemRead,
    input [1:0]  i_WDSel,
    input        i_ALUSrc,
    input [4:0]  i_ALUOp,

    // --- Outputs to EX Stage ---
    output [31:0] o_PC_plus_4,
    output [31:0] o_RD1,
    output [31:0] o_RD2,
    output [31:0] o_Imm,
    output [4:0]  o_rd,
    // Control Signals
    output        o_RegWrite,
    output        o_MemWrite,
    output        o_MemRead,
    output [1:0]  o_WDSel,
    output        o_ALUSrc,
    output [4:0]  o_ALUOp
);

    // Data Path Registers
    pipeline_reg #(.WIDTH(32)) pc_reg   (.clk(clk), .reset(reset), .d(i_PC_plus_4), .q(o_PC_plus_4));
    pipeline_reg #(.WIDTH(32)) rd1_reg  (.clk(clk), .reset(reset), .d(i_RD1),       .q(o_RD1));
    pipeline_reg #(.WIDTH(32)) rd2_reg  (.clk(clk), .reset(reset), .d(i_RD2),       .q(o_RD2));
    pipeline_reg #(.WIDTH(32)) imm_reg  (.clk(clk), .reset(reset), .d(i_Imm),       .q(o_Imm));
    pipeline_reg #(.WIDTH(5))  rd_addr_reg (.clk(clk), .reset(reset), .d(i_rd),        .q(o_rd));
    
    // Control Path Registers
    pipeline_reg #(.WIDTH(1)) regwrite_reg (.clk(clk), .reset(reset), .d(i_RegWrite), .q(o_RegWrite));
    pipeline_reg #(.WIDTH(1)) memwrite_reg (.clk(clk), .reset(reset), .d(i_MemWrite), .q(o_MemWrite));
    pipeline_reg #(.WIDTH(1)) memread_reg  (.clk(clk), .reset(reset), .d(i_MemRead),  .q(o_MemRead));
    pipeline_reg #(.WIDTH(2)) wdsel_reg    (.clk(clk), .reset(reset), .d(i_WDSel),    .q(o_WDSel));
    pipeline_reg #(.WIDTH(1)) alusrc_reg   (.clk(clk), .reset(reset), .d(i_ALUSrc),   .q(o_ALUSrc));
    pipeline_reg #(.WIDTH(5)) aluop_reg    (.clk(clk), .reset(reset), .d(i_ALUOp),    .q(o_ALUOp));
endmodule