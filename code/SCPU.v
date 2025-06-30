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
    output [31:0] Data_out,   // 写入dm 的数据 根据DMType 的类型来决定其数值

    // Debug Ports
    input  [4:0] reg_sel,
    output [31:0] reg_data,
    output [2:0]  dm_type
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

// 流水线寄存器控制单元
wire  if_valid,if_id_valid , id_ex_valid , ex_mem_valid, mem_wb_valid;
wire id_ex_flush = 1'b0 ,ex_mem_flush = 1'b0 , mem_wb_flush = 1'b0;
assign if_valid = 1'b1;//(ID_Zero == 1'b1) ? 1'b0 : 1'b1;

// 这里注意不能只看ID_Zero 因为ID_Zero只能反映条件跳转指令, 还需要考虑无条件跳转指令
    wire [2:0] ID_NPCOp;
wire if_id_flush  = (ID_NPCOp == `NPC_PLUS4) ? 1'b0 : 1'b1;
//assign id_ex_flush = (ID_Zero == 1'b1) ? 1'b1 : 1'b0;

/* wire if_id_allowin, id_ex_allowin, ex_mem_allowin, mem_wb_alloin;
wire if_id_to_id_ex_valid , id_ex_to_ex_mem_valid , ex_mem_to_mem_wb_valid , mem_wb_to_wb_valid;
wire if_id_flush , id_ex_flush, ex_mem_flush , mem_wb_flush;
wire if_id_stall , pc_stall;
wire if_id_ready_go = 1'b1;
wire id_ex_ready_go = 1'b1;
wire ex_mem_ready_go = 1'b1;
wire mem_wb_ready_go = 1'b1; 
wire wb_stage_ready_go = 1'b1;
wire wb_stage_allow_downstream = 1'b1;
assign mem_wb_allowin = !mem_wb_valid || (wb_stage_ready_go && wb_stage_allow_downstream);
assign ex_mem_allowin = !ex_mem_valid || (mem_wb_ready_go && mem_wb_allowin);
assign id_ex_allowin = !id_ex_valid || (ex_ready_go && ex_mem_allowin);
assign if_id_allowin = (!if_id_valid || (if_id_ready_go && id_ex_allowin)) && !if_id_stall;
assign pc_allowin = if_id_allowin && !pc_stall;
assign if_to_if_id_valid = 1'b1;

// IF/ID向ID/EX发送的valid
assign if_id_to_id_ex_valid = if_id_valid && if_id_ready_go;

// ID/EX向EX/MEM发送的valid
assign id_ex_to_ex_mem_valid = id_ex_valid && id_ex_ready_go;

// EX/MEM向MEM/WB发送的valid
assign ex_mem_to_mem_wb_valid = ex_mem_valid && ex_mem_ready_go;

// MEM/WB向WB发送的valid
assign mem_wb_to_wb_valid = mem_wb_valid && mem_wb_ready_go;
 */



// --- IF/ID Valid Register Update ---
/* always @(posedge clk or posedge rst) begin
    if (rst) if_id_valid <= 1'b0;
    else if (if_id_flush) if_id_valid <= 1'b0; // 冲刷
    else if (if_id_allowin) if_id_valid <= if_to_if_id_valid;
end

// --- ID/EX Valid Register Update ---
always @(posedge clk or posedge rst) begin
    if (rst) id_ex_valid <= 1'b0;
    else if (id_ex_flush) id_ex_valid <= 1'b0; // 冲刷
    else if (id_ex_allowin) id_ex_valid <= if_id_to_id_ex_valid;
end */

// ... 对 ex_mem_valid 和 mem_wb_valid 进行类似的操作 ...


    // 
    // Stage 1: IF (Instruction Fetch)
    // 
    wire [31:0] NPC, IF_PC_plus_4;
    PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out));
    // 修改这里来实现NPC的跳转
    wire [31:0] ID_Imm;
    wire [31:0] EX_ALU_in_B, EX_ALU_out;
    wire [31:0] ID_RD1, ID_RD2;
    wire [2:0] EX_NPCOp; 
    assign NPC = (ID_NPCOp == `NPC_PLUS4) ? PC_out + 32'd4 :
                 (ID_NPCOp == `NPC_BRANCH) ? ID_PC + ID_Imm :
                 (ID_NPCOp == `NPC_JUMP)   ? ID_PC + ID_Imm :
                 (ID_NPCOp == `NPC_JALR)   ? ID_RD1 + ID_Imm :
                 PC_out + 32'd4; 

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
        .i_valid(if_valid),
        .flush(if_id_flush),
        .o_valid(if_id_valid),
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
    wire [2:0] EX_DMType;
    wire [2:0] MEM_DMType;

    ctrl U_ctrl(
        .Op(ID_inst[6:0]), .Funct7(ID_inst[31:25]), .Funct3(ID_inst[14:12]), .Zero(ID_Zero), // Zero connected later
        .RegWrite(ID_RegWrite), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead), .NPCOp(ID_NPCOp), .DMType(ID_DMType),
        .WDSel(ID_WDSel), .ALUSrc(ID_ALUSrc), .ALUOp(ID_ALUOp), .EXTOp(ID_EXTOp), .GPRSel(ID_GPRSel)
    );

    EXT U_EXT(.inst(ID_inst), .EXTOp(ID_EXTOp), .immout(ID_Imm));  // 组合逻辑可以看做是瞬时完成
    

    wire [31:0] WB_Write_Data;
    wire WB_RegWrite_final = mem_wb_valid ? WB_RegWrite : 1'b0;
    RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(WB_RegWrite_final), .A1(ID_rs1), .A2(ID_rs2), .A3(WB_rd), .WD(WB_Write_Data),
		.RD1(ID_RD1), .RD2(ID_RD2)
        //.reg_sel(reg_sel), .reg_data(reg_data)
	);
        
        // 在这个阶段进行跳转的判断
        comparator U_comparator(.Funct3(ID_inst[14:12]) , .Op(ID_inst[6:0]), .RD1(ID_RD1), .RD2(ID_RD2) ,.Zero(ID_Zero));

    // 添加流水线寄存器控制单元的信号  来解决控制冒险以及数据冒险

//  添加前递单元来解决数据冒险
wire [1:0]ForwardA ; 
wire [1:0]ForwardB ;
// 从EX 寄存器转发: 10  从MEM 阶段来转发:  01   不使用转发: 00
// --- Forwarding logic for ALU input A ---
assign ForwardA = (EX_RegWrite && (EX_rd != 0) && (EX_rd == ID_rs1)) ? `from_ex :
                  (MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == ID_rs1)) ? `from_mem :
                  (WB_RegWrite && (WB_rd != 0) &&(WB_rd == ID_rs1)) ? `from_wb :
                  `from_if;
assign ForwardB = (EX_RegWrite && (EX_rd != 0) && (EX_rd == ID_rs2)) ? `from_ex :
                  (MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == ID_rs2)) ? `from_mem :
                   (WB_RegWrite && (WB_rd != 0) &&(WB_rd == ID_rs2)) ? `from_wb :
                  `from_if;

wire [31:0] ID_RD1_final = (ForwardA == `from_ex) ? EX_ALU_out : (ForwardA == `from_mem)? MEM_ALU_out  : (ForwardA == `from_wb) ? WB_Write_Data: ID_RD1;
wire [31:0] ID_RD2_final = (ForwardB == `from_ex) ? EX_ALU_out : (ForwardB == `from_mem)? MEM_ALU_out : (ForwardB == `from_wb) ? WB_Write_Data:ID_RD2;


//  添加前递单元来解决数据冒险
    // 
    // Pipeline Register: ID/EX
    // 
    ID_EX_Register U_ID_EX_REG (
        .clk(clk), .reset(reset),
        .i_PC_plus_4(ID_PC_plus_4), .i_RD1(ID_RD1_final), .i_RD2(ID_RD2_final), .i_Imm(ID_Imm), .i_rd(ID_rd), .flush(id_ex_flush),
        .i_RegWrite(ID_RegWrite), .i_MemWrite(ID_MemWrite), .i_MemRead(ID_MemRead), .i_valid(if_id_valid),
        .i_WDSel(ID_WDSel), .i_ALUSrc(ID_ALUSrc), .i_ALUOp(ID_ALUOp), .i_NPCOp(ID_NPCOp), .i_PC(ID_PC), .i_DMType(ID_DMType),
        .o_PC_plus_4(EX_PC_plus_4), .o_RD1(EX_RD1), .o_RD2(EX_RD2), .o_Imm(EX_Imm), .o_rd(EX_rd),
        .o_RegWrite(EX_RegWrite), .o_MemWrite(EX_MemWrite), .o_MemRead(EX_MemRead), .o_valid(id_ex_valid),
        .o_WDSel(EX_WDSel), .o_ALUSrc(EX_ALUSrc), .o_ALUOp(EX_ALUOp),.o_NPCOp(EX_NPCOp),.o_PC(EX_PC), .o_DMType(EX_DMType)
    );
    
    //
    // Stage 3: EX (Execute)
    // 
  
    wire        EX_Zero;
    assign EX_ALU_in_B = EX_ALUSrc ? EX_Imm : EX_RD2; // Forwarding will modify this
    alu U_alu(.A(EX_RD1), .B(EX_ALU_in_B), .ALUOp(EX_ALUOp), .C(EX_ALU_out), .Zero(EX_Zero) , .PC(EX_PC));

    // 
    // Pipeline Register: EX/MEM
    // 
    EX_MEM_Register U_EX_MEM_REG (
        .clk(clk), .reset(reset),
        .i_ALU_out(EX_ALU_out), .i_Store_Data(EX_RD2), .i_rd(EX_rd), .i_PC_plus_4(EX_PC_plus_4), .i_valid(id_ex_valid), .flush(ex_mem_flush),
        .i_RegWrite(EX_RegWrite), .i_MemWrite(EX_MemWrite), .i_MemRead(EX_MemRead), .i_WDSel(EX_WDSel), .i_DMType(EX_DMType),
        .o_ALU_out(MEM_ALU_out), .o_Store_Data(MEM_Store_Data), .o_rd(MEM_rd), .o_PC_plus_4(MEM_PC_plus_4), .o_valid(ex_mem_valid),
        .o_RegWrite(MEM_RegWrite), .o_MemWrite(MEM_MemWrite), .o_MemRead(MEM_MemRead), .o_WDSel(MEM_WDSel) , .o_DMType(MEM_DMType)
    );
    
    // 
    // Stage 4: MEM (Memory Access)
    // 给流水线寄存器添加valid信号之后这里需要 进行修改
    assign Addr_out = MEM_ALU_out;
    assign Data_out = MEM_Store_Data;
    assign mem_w = ex_mem_valid ? MEM_MemWrite : 1'b0;
    //assign mem_w    = MEM_MemWrite;
    assign dm_type = MEM_DMType;
    // 根据DMType 来选择需要写入dm 的数据


    // 
    // Pipeline Register: MEM/WB
    // 
    MEM_WB_Register U_MEM_WB_REG (
        .clk(clk), .reset(reset),
        .i_Read_Data(Data_in), .i_ALU_out(MEM_ALU_out), .i_rd(MEM_rd), .i_PC_plus_4(MEM_PC_plus_4),
        .i_RegWrite(MEM_RegWrite), .i_WDSel(MEM_WDSel), .i_valid(ex_mem_valid), .flush(mem_wb_flush),
        .o_Read_Data(WB_Read_Data), .o_ALU_out(WB_ALU_out), .o_rd(WB_rd), .o_PC_plus_4(WB_PC_plus_4),
        .o_RegWrite(WB_RegWrite), .o_WDSel(WB_WDSel), .o_valid(mem_wb_valid)
    );
    
    // 
    // Stage 5: WB (Write Back)
    // 
    assign WB_Write_Data = (WB_WDSel == `WDSel_FromPC)  ? WB_PC_plus_4 :
                           (WB_WDSel == `WDSel_FromMEM) ? WB_Read_Data :
                                                           WB_ALU_out;


 // RF debug 
 always @(posedge clk) begin
        $display("r[00-07]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", 0,  U_RF.rf[1],  U_RF.rf[2],  U_RF.rf[3],  U_RF.rf[4],  U_RF.rf[5],  U_RF.rf[6],  U_RF.rf[7]);
        $display("r[08-15]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X",  U_RF.rf[8],  U_RF.rf[9],  U_RF.rf[10],  U_RF.rf[11],  U_RF.rf[12],  U_RF.rf[13],  U_RF.rf[14],  U_RF.rf[15]);
        $display("r[16-23]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X",  U_RF.rf[16],  U_RF.rf[17],  U_RF.rf[18],  U_RF.rf[19],  U_RF.rf[20],  U_RF.rf[21],  U_RF.rf[22],  U_RF.rf[23]);
        $display("r[24-31]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X",  U_RF.rf[24],  U_RF.rf[25],  U_RF.rf[26],  U_RF.rf[27],  U_RF.rf[28],  U_RF.rf[29],  U_RF.rf[30],  U_RF.rf[31]);
       // $display("r[%2d] = 0x%8X,", , );
 end
endmodule