// 文件名: IF_ID_Register.v
// `include "pipeline_reg.v" // 确保通用寄存器模块可用

module IF_ID_Register (
    input clk,
    input reset,

    // --- Inputs from IF Stage ---
    input [31:0] i_inst,        // The instruction fetched from memory
    input [31:0] i_PC_plus_4,   // The calculated PC+4 value
    input [31:0] i_PC,
    input   i_valid,
    input   flush,
    input   stall,

    // --- Outputs to ID Stage ---
    output   [31:0] o_inst,       // The instruction passed to the ID stage
    output  [31:0] o_PC_plus_4,   // The PC+4 value passed to the ID stage
    output  [31:0] o_PC,
    output         o_valid
);

        reg valid_reg ;
        assign o_valid = (stall == 1'b1) ? 1'b0 : valid_reg;   // 如果需要停顿, 那么下一个寄存器得到的数据的有效位为0

         always@(posedge clk or posedge reset) begin 
            if(reset) begin 
                valid_reg <= 1'b0;
            end
            else if (flush) begin 
                valid_reg <= 1'b0;
            end 
            else if (stall) begin 
                valid_reg <= valid_reg;             // 如果阻塞那么不需要更新数据和有效位, 
            end 
            else begin valid_reg <= i_valid;end
        end 

 /*    wire [31:0] inst_d_output;
    wire [31:0] pc_plus_4_d_ouput;
    wire [31:0] pc_d_putput;

    assign   o_inst     = stall ?  inst_d_output      : i_inst;
    assign  o_PC_plus_4 = stall ?  pc_plus_4_d_output: i_PC_plus_4;
    assign   o_PC      = stall ?   pc_d_output      : i_PC;
 */
    wire [31:0] next_inst;
    wire [31:0] next_pc_plus_4;
    wire [31:0] next_pc;

    // --- MUX 实现数据锁存与冲刷 ---
    // 逻辑: flush 优先级高于 stall
    // 1. 如果 flush，则下一条指令是 NOP。
    // 2. 如果不 flush 但 stall，则下一条指令是当前指令 (o_inst)。
    // 3. 如果既不 flush 也不 stall，则下一条指令是新指令 (i_inst)。
    assign next_inst      = (stall ? o_inst      : i_inst);
    assign next_pc_plus_4 = (stall ? o_PC_plus_4 : i_PC_plus_4);
    assign next_pc        = (stall ? o_PC        : i_PC);


    // Instantiate a 32-bit register for the instruction
 pipeline_reg #(.WIDTH(32)) inst_reg (
        .clk(clk),
        .reset(reset),
        .d(next_inst),      // 使用 MUX 的输出作为输入
        .q(o_inst)
    );

    pipeline_reg #(.WIDTH(32)) pc_reg (
        .clk(clk),
        .reset(reset),
        .d(next_pc_plus_4), // 使用 MUX 的输出作为输入
        .q(o_PC_plus_4)
    );

    pipeline_reg #(.WIDTH(32)) pc_reg_inst ( // 模块实例名不能重复
        .clk(clk),
        .reset(reset),
        .d(next_pc),        // 使用 MUX 的输出作为输入
        .q(o_PC)
    );


/* 
    pipeline_reg #(.WIDTH(32)) inst_reg (
        .clk(clk), 
        .reset(reset), 
        .d(i_inst), 
        .q(inst_d_output)
    );

    // Instantiate a 32-bit register for the PC+4 value
    pipeline_reg #(.WIDTH(32)) pc_reg (
        .clk(clk), 
        .reset(reset), 
        .d(i_PC_plus_4), 
        .q(pc_plus_4_d_ouput)
    );
    pipeline_reg #(.WIDTH(32)) pc (
        .clk(clk), 
        .reset(reset), 
        .d(i_PC), 
        .q(pc_d_putput)
    );
 */
endmodule