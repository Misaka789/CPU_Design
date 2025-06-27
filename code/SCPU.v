`include "ctrl_encode_def.v"
// `include` a lot of modules is not necessary if they are all in the project folder
// But it's a good practice to include the definitions file.

module SCPU(
    input      clk,
    input      reset,
    input [31:0]  inst_in,
    input [31:0]  Data_in,
    
    // Core Outputs
    output    mem_w,
    output [31:0] PC_out,
    output [31:0] Addr_out,
    output [31:0] Data_out,

    // Debug Ports
    input  [4:0] reg_sel,
    output [31:0] reg_data
);

    // =========================================================================
    // I. Wires Between Pipeline Stages
    // =========================================================================
    
    // --- IF/ID Wires ---
    wire [31:0] ID_inst;
    wire [31:0] ID_PC_plus_4;
    wire [31:0] ID_PC;

    // --- ID/EX Wires ---
    wire [31:0] EX_PC_plus_4, EX_RD1, EX_RD2, EX_Imm;
    wire [4:0]  EX_rd;
    wire        EX_RegWrite, EX_MemWrite, EX_MemRead, EX_ALUSrc;
    wire [1:0]  EX_WDSel;
    wire [4:0]  EX_ALUOp;
    wire [31:0] EX_PC;

    // --- EX/MEM Wires ---
    wire [31:0] MEM_PC_plus_4, MEM_ALU_out, MEM_Store_Data;
    wire [4:0]  MEM_rd;
    wire        MEM_RegWrite, MEM_MemWrite, MEM_MemRead;
    wire [1:0]  MEM_WDSel;
    wire[31:0]  MEM_PC;

    // --- MEM/WB Wires ---
    wire [31:0] WB_PC_plus_4, WB_Read_Data, WB_ALU_out;
    wire [4:0]  WB_rd;
    wire        WB_RegWrite;
    wire [1:0]  WB_WDSel;

    // =========================================================================
    // II. The Five-Stage Pipeline
    // =========================================================================

    // 
    // Stage 1: IF (Instruction Fetch)
    // 
    wire [31:0] NPC, IF_PC_plus_4;

    PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out));
    // 修改这里来实现NPC的跳转
    wire [31:0] ID_Imm;
    wire [2:0] ID_NPCOp;
    wire [31:0] EX_ALU_in_B, EX_ALU_out;
    wire [31:0] ID_RD1, ID_RD2;
    wire [2:0] EX_NPCOp; 
    assign NPC = (ID_NPCOp == `NPC_PLUS4) ? PC_out + 32'd4 :
                 (ID_NPCOp == `NPC_BRANCH) ? ID_PC + ID_Imm :
                 (ID_NPCOp == `NPC_JUMP)   ? ID_PC + ID_Imm :
                 (ID_NPCOp == `NPC_JALR)   ? ID_RD1 + ID_Imm :
                 PC_out + 32'd4; // default case to avoid latches
// PC 控制逻辑
// In EX stage
    //NPC U_NPC(.NPCOp(ID_NPCOp),.IMM(ID_Imm),.PC(PC_out) ,.NPC(NPC), .aluout(ID_Imm));
    //NPC U_NPC(.NPCOp(ID_NPCOp), .IMM(ID_Imm) , .PC(ID_PC_plus_4 - 32'd4), .NPC(NPC) ,.aluout(ID_RD1 + ID_Imm)); // 组合逻辑 
    assign IF_PC_plus_4 = PC_out + 32'd4;
    //assign NPC = IF_PC_plus_4; // 这里只是简单的设置为PC + 4 不考虑跳转语句 

    // 
    // Pipeline Register: IF/ID
    // 
    IF_ID_Register U_IF_ID_REG (
        .clk(clk), .reset(reset),
        .i_inst(inst_in), 
        .i_PC_plus_4(IF_PC_plus_4),
        .i_PC(PC_out),
        .o_inst(ID_inst), 
        .o_PC_plus_4(ID_PC_plus_4),
        .o_PC(ID_PC)
    );

    // 
    // Stage 2: ID (Instruction Decode & Register Fetch)
    // 
    wire [4:0] ID_rs1 = ID_inst[19:15]; // 解析指令中包含的数据
    wire [4:0] ID_rs2 = ID_inst[24:20];
    wire [4:0] ID_rd  = ID_inst[11:7];
    wire ID_RegWrite, ID_MemWrite, ID_MemRead, ID_ALUSrc;   // 声明信号
    wire [1:0] ID_WDSel;
    wire [4:0] ID_ALUOp;
    wire [5:0] ID_EXTOp;
    wire [2:0] ID_DMType;
    wire [1:0] ID_GPRSel;
 

    ctrl U_ctrl(
        .Op(ID_inst[6:0]), .Funct7(ID_inst[31:25]), .Funct3(ID_inst[14:12]), .Zero(ID_Zero), // Zero connected later
        .RegWrite(ID_RegWrite), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead), .NPCOp(ID_NPCOp),// .DMType(ID_DmType),
        .WDSel(ID_WDSel), .ALUSrc(ID_ALUSrc), .ALUOp(ID_ALUOp), .EXTOp(ID_EXTOp), .GPRSel(ID_GPRSel)
    );

    EXT U_EXT(.inst(ID_inst), .EXTOp(ID_EXTOp), .immout(ID_Imm));  // 组合逻辑可以看做是瞬时完成
    

    wire [31:0] WB_Write_Data;
    RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(WB_RegWrite), .A1(ID_rs1), .A2(ID_rs2), .A3(WB_rd), .WD(WB_Write_Data),
		.RD1(ID_RD1), .RD2(ID_RD2)
        //.reg_sel(reg_sel), .reg_data(reg_data)
	);
        
        // 在这个阶段进行跳转的判断
        //wire ID_Zero;
        assign ID_Zero = ID_RD1 == ID_RD2;  // 在ID阶段进行判断是否相等, 如果相等那么可以进行跳转 branch 

    // 
    // Pipeline Register: ID/EX
    // 
    ID_EX_Register U_ID_EX_REG (
        .clk(clk), .reset(reset),
        .i_PC_plus_4(ID_PC_plus_4), .i_RD1(ID_RD1), .i_RD2(ID_RD2), .i_Imm(ID_Imm), .i_rd(ID_rd),
        .i_RegWrite(ID_RegWrite), .i_MemWrite(ID_MemWrite), .i_MemRead(ID_MemRead),
        .i_WDSel(ID_WDSel), .i_ALUSrc(ID_ALUSrc), .i_ALUOp(ID_ALUOp), .i_NPCOp(ID_NPCOp), .i_PC(ID_PC),
        .o_PC_plus_4(EX_PC_plus_4), .o_RD1(EX_RD1), .o_RD2(EX_RD2), .o_Imm(EX_Imm), .o_rd(EX_rd),
        .o_RegWrite(EX_RegWrite), .o_MemWrite(EX_MemWrite), .o_MemRead(EX_MemRead),
        .o_WDSel(EX_WDSel), .o_ALUSrc(EX_ALUSrc), .o_ALUOp(EX_ALUOp),.o_NPCOp(EX_NPCOp),.o_PC(EX_PC)
    );
    
    //
    // Stage 3: EX (Execute)
    // 
  
    wire        EX_Zero;

    assign EX_ALU_in_B = EX_ALUSrc ? EX_Imm : EX_RD2; // Forwarding will modify this
    alu U_alu(.A(EX_RD1), .B(EX_ALU_in_B), .ALUOp(EX_ALUOp), .C(EX_ALU_out), .Zero(EX_Zero));

    // 
    // Pipeline Register: EX/MEM
    // 
    EX_MEM_Register U_EX_MEM_REG (
        .clk(clk), .reset(reset),
        .i_ALU_out(EX_ALU_out), .i_Store_Data(EX_RD2), .i_rd(EX_rd), .i_PC_plus_4(EX_PC_plus_4),
        .i_RegWrite(EX_RegWrite), .i_MemWrite(EX_MemWrite), .i_MemRead(EX_MemRead), .i_WDSel(EX_WDSel),
        .o_ALU_out(MEM_ALU_out), .o_Store_Data(MEM_Store_Data), .o_rd(MEM_rd), .o_PC_plus_4(MEM_PC_plus_4),
        .o_RegWrite(MEM_RegWrite), .o_MemWrite(MEM_MemWrite), .o_MemRead(MEM_MemRead), .o_WDSel(MEM_WDSel)
    );
    
    // 
    // Stage 4: MEM (Memory Access)
    // 
    assign Addr_out = MEM_ALU_out;
    assign Data_out = MEM_Store_Data;
    assign mem_w    = MEM_MemWrite;

    // 
    // Pipeline Register: MEM/WB
    // 
    MEM_WB_Register U_MEM_WB_REG (
        .clk(clk), .reset(reset),
        .i_Read_Data(Data_in), .i_ALU_out(MEM_ALU_out), .i_rd(MEM_rd), .i_PC_plus_4(MEM_PC_plus_4),
        .i_RegWrite(MEM_RegWrite), .i_WDSel(MEM_WDSel),
        .o_Read_Data(WB_Read_Data), .o_ALU_out(WB_ALU_out), .o_rd(WB_rd), .o_PC_plus_4(WB_PC_plus_4),
        .o_RegWrite(WB_RegWrite), .o_WDSel(WB_WDSel)
    );
    
    // 
    // Stage 5: WB (Write Back)
    // 
    assign WB_Write_Data = (WB_WDSel == `WDSel_FromPC)  ? WB_PC_plus_4 :
                           (WB_WDSel == `WDSel_FromMEM) ? WB_Read_Data :
                                                           WB_ALU_out;
endmodule