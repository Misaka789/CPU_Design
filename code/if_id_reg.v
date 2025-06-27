// 文件名: IF_ID_Register.v
// `include "pipeline_reg.v" // 确保通用寄存器模块可用

module IF_ID_Register (
    input clk,
    input reset,

    // --- Inputs from IF Stage ---
    input [31:0] i_inst,        // The instruction fetched from memory
    input [31:0] i_PC_plus_4,   // The calculated PC+4 value

    // --- Outputs to ID Stage ---
    output [31:0] o_inst,       // The instruction passed to the ID stage
    output [31:0] o_PC_plus_4   // The PC+4 value passed to the ID stage
);

    // Instantiate a 32-bit register for the instruction
    pipeline_reg #(.WIDTH(32)) inst_reg (
        .clk(clk), 
        .reset(reset), 
        .d(i_inst), 
        .q(o_inst)
    );

    // Instantiate a 32-bit register for the PC+4 value
    pipeline_reg #(.WIDTH(32)) pc_reg (
        .clk(clk), 
        .reset(reset), 
        .d(i_PC_plus_4), 
        .q(o_PC_plus_4)
    );

endmodule