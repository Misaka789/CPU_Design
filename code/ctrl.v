// `include "ctrl_encode_def.v"

//123
module ctrl(Op, Funct7, Funct3, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel,DMType,MemRead
            );
            
   input  [6:0] Op;       // opcode
   input  [6:0] Funct7;    // funct7
   input  [2:0] Funct3;    // funct3
   input        Zero;
   
   output       MemRead;
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output [5:0] EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [2:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for A
	output [2:0] DMType;
   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   
  // r format
    wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
    wire i_add  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
    wire i_sub  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
    wire i_or   = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or 0000000 110
    wire i_and  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and 0000000 111
 

 // i format
   wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011

// i format
    wire itype_r  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011
    wire i_addi  =  itype_r& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // addi 000
    wire i_ori  =  itype_r& Funct3[2]& Funct3[1]&~Funct3[0]; // ori 110
	
 //jalr
	wire i_jalr =Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111

  // s format
   wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
   wire i_sw   =  stype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // sw 010

  // sb format
   wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
   wire i_beq  = sbtype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // beq
	
 // j format
   wire i_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111



// 开始补充缺失的指令 
 // u format
 wire utype = ~Op[6]& Op[5]& Op[4]& ~Op[3]& Op[2]& Op[1]& Op[0]; // lui 0110111
// 左移右移都是rtype 指令
 wire i_srli = itype_r& ~Funct7[6]& ~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; 
// funct3 101 funct7 全0

 wire i_slli = itype_r& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]&~Funct3[1]& Funct3[0];
 // funct3 001 funct7 全0

 wire i_sll =  rtype &~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]& Funct3[0];
 //0000000 001

 wire i_slt =  rtype& ~Funct7[6]& ~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]& Funct3[1]& ~Funct3[0];
 //0000000 010
 wire i_srai = itype_r & Funct3[2]& ~Funct3[1]& Funct3[0] 
 & ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0];  
 // funct3 101 funct7 0100000

 wire  i_srl = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]& Funct3[0];
 //0000000 101

 wire i_sra = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; 
 //0100000 101 

wire i_xori = itype_r& Funct3[2]& ~Funct3[1]&~Funct3[0]; // 100
wire i_xor = rtype &~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]&~Funct3[0];
//0000000 100

wire i_sltu = rtype  &~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]&Funct3[1]&Funct3[0]; //011
wire i_slti = itype_r & ~Funct3[2]& Funct3[1]&~Funct3[0]; //010
wire i_sltiu = itype_r & ~Funct3[2]& Funct3[1]& Funct3[0]; //011

// sb条件跳转指令的实现
wire i_bne = sbtype & (Funct3 == 3'b001);
wire i_blt = sbtype & (Funct3 == 3'b100);
wire i_bltu = sbtype & (Funct3 == 3'b110);
wire i_bgeu = sbtype & (Funct3 == 3'b111);

// 缺失的指令补充完毕

  // generate control signals
  assign RegWrite   = rtype | itype_r | i_jalr | i_jal | utype; // register write
  assign MemWrite   = stype;                           // memory write
  assign ALUSrc     = itype_r | stype | i_jal | i_jalr | utype;   // ALU B is from instruction immediate 1 : 立即数 0 : RD2
  assign MemRead    = ~Op[6]& ~Op[5]& ~Op[4]& ~Op[3]& ~Op[2]& Op[1]& Op[0];
  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  // 为立即数移位指令设计
  assign EXTOp[5] = i_slli | i_srai | i_srli; // 或者 itype_r && (Funct3 == 3'b001 || Funct3 == 3'b101);
  //assign EXTOp[4]    =  i_ori | i_andi | i_jalr;
  assign EXTOp[4]    = itype_r | i_ori | i_xori;  
  assign EXTOp[3]    = stype; 
  assign EXTOp[2]    = sbtype; 
  assign EXTOp[1]    = utype;   
  assign EXTOp[0]    = i_jal;         

  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_l;
  assign WDSel[1] = i_jal | i_jalr;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	3'b100
  assign NPCOp[0] = sbtype & Zero;
  assign NPCOp[1] = i_jal;    // 无条件跳转
	assign NPCOp[2]=  i_jalr;
  

 
	assign ALUOp[0] = itype_l|stype|i_addi|i_ori|i_add|i_or | utype | i_sll | i_slli | i_sra | i_srai | i_sltu | i_sltiu;
	assign ALUOp[1] = i_jalr|itype_l|stype|i_addi|i_add|i_and | i_sll | i_slli | i_slt | i_slti | i_sltu | i_sltiu;
	//assign ALUOp[2] = i_andi|i_and|i_ori|i_or|i_beq|i_sub;
	//assign ALUOp[3] = i_andi|i_and|i_ori|i_or;
	assign ALUOp[2] = i_and|i_ori|i_or|i_beq|i_sub | i_sll | i_slli | i_xor | i_xori ;
  assign ALUOp[3] = i_and|i_ori|i_or | i_sll | i_slli | i_xor | i_xori | i_slt | i_slti | i_sltu | i_sltiu;    
	assign ALUOp[4] = i_srli | i_srl | i_sra | i_srai;

// 后续需要添加DMType等指令类型


endmodule
