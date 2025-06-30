// 文件名: MEM_WB_Register.v
//`include "pipeline_reg.v"

module MEM_WB_Register (
    input clk,
    input reset,

    // --- Inputs from MEM Stage ---
    input [31:0] i_Read_Data, // This is Data_in from top module
    input [31:0] i_ALU_out,
    input [4:0]  i_rd,
    input [31:0] i_PC_plus_4,
    // Control Signals
    input        i_RegWrite,
    input [1:0]  i_WDSel,
    input        i_valid,
    input        flush,
    output       o_valid,
    

    // --- Outputs to WB Stage ---
    output [31:0] o_Read_Data,
    output [31:0] o_ALU_out,
    output [4:0]  o_rd,
    output [31:0] o_PC_plus_4,
    // Control Signals
    output        o_RegWrite,
    output [1:0]  o_WDSel
);


        reg valid_reg ;
        assign o_valid = valid_reg;
        always@(posedge clk or posedge reset) begin 
            if(reset) begin 
                valid_reg <= 1'b0;
            end
            else if (flush) begin 
                valid_reg <= 1'b0;
            end else begin valid_reg <= i_valid;end
        end

    // Data Path Registers
    pipeline_reg #(.WIDTH(32)) read_data_reg (.clk(clk), .reset(reset), .d(i_Read_Data), .q(o_Read_Data));
    pipeline_reg #(.WIDTH(32)) alu_out_reg   (.clk(clk), .reset(reset), .d(i_ALU_out),   .q(o_ALU_out));
    pipeline_reg #(.WIDTH(5))  rd_addr_reg   (.clk(clk), .reset(reset), .d(i_rd),        .q(o_rd));
    pipeline_reg #(.WIDTH(32)) pc_reg        (.clk(clk), .reset(reset), .d(i_PC_plus_4),  .q(o_PC_plus_4));
    
    // Control Path Registers
    pipeline_reg #(.WIDTH(1)) regwrite_reg (.clk(clk), .reset(reset), .d(i_RegWrite), .q(o_RegWrite));
    pipeline_reg #(.WIDTH(2)) wdsel_reg    (.clk(clk), .reset(reset), .d(i_WDSel),    .q(o_WDSel));

endmodule