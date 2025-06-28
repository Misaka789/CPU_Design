
module comparator (Op,Funct3,RD1,RD2,Zero);
    input [6:0] Op;
    input [2:0] Funct3;
    input signed[31:0] RD1;
    input signed[31:0] RD2;
    output Zero;
wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
wire i_beq  = sbtype& (Funct3 == 3'b000); // beq
wire i_bne = sbtype & (Funct3 == 3'b001);
wire i_blt = sbtype & (Funct3 == 3'b100);
wire i_bltu = sbtype & (Funct3 == 3'b110);
wire i_bgeu = sbtype & (Funct3 == 3'b111);
wire i_bge = sbtype & (Funct3 == 3'b101);

assign Zero =  (i_beq & (RD1 == RD2)) || (i_bne & (RD1!=RD2)) ||(i_blt & (RD1 < RD2)) 
|| (i_bltu & ($unsigned(RD1) < $unsigned(RD2))) ||(i_bge & (RD1 >= RD2)) || (i_bgeu & ($unsigned(RD1) >= $unsigned(RD2)));

endmodule