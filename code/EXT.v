// 文件名: EXT.v (使用独热码的最终版本)
`include "ctrl_encode_def.v"

module EXT(
    // 输入：只需要完整的指令和独热码控制信号
    input  [31:0] inst,
    input  [5:0]  EXTOp,

    // 输出：最终的32位立即数
    output reg [31:0] immout
);
    
    // 使用 case 语句，这在硬件上会被高效地实现
    always @(*) begin
        case(EXTOp)
           
            `EXT_CTRL_ITYPE: 
                immout = {{20{inst[31]}}, inst[31:20]};
            
            `EXT_CTRL_STYPE: 
                immout = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            
            `EXT_CTRL_BTYPE: 
                immout = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            
            `EXT_CTRL_UTYPE: 
                immout = {inst[31:12], 12'b0};

            `EXT_CTRL_JTYPE: 
                immout = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

            // 特殊的移位立即数，它是一个无符号的5位数
            `EXT_CTRL_ITYPE_SHAMT: 
                immout = {{27{1'b0}}, inst[24:20]};

            // 为了安全，提供一个默认值
       //     default: immout = 32'hdeadbeef;
        endcase
    end

endmodule


/* `include "ctrl_encode_def.v"
module EXT( 
	input [4:0] iimm_shamt,
    	input	[11:0]			iimm, //instr[31:20], 12 bits
	input	[11:0]			simm, //instr[31:25, 11:7], 12 bits
	input	[11:0]			bimm, //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	input	[19:0]			uimm,
	input	[19:0]			jimm,
	input	[5:0]			EXTOp,

	output	reg [31:0] 	       immout);

always  @(*)
	 case (EXTOp)
		`EXT_CTRL_ITYPE_SHAMT:   immout<={27'b0,iimm_shamt[4:0]};
		`EXT_CTRL_ITYPE:	immout <= {{(32  - 20){iimm[11]}}, iimm[11:0]};  // 32 - 12 -> 20
		`EXT_CTRL_STYPE:	immout <= {{(32-12){simm[11]}}, simm[11:0]};
		`EXT_CTRL_BTYPE:        immout <= {{(32-13){bimm[11]}}, bimm[11:0], 1'b0};
		`EXT_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0}; //???????????12??0
		`EXT_CTRL_JTYPE:	immout <= {{(32-21){jimm[19]}}, jimm[19:0], 1'b0};
		default:	        immout <= 32'b0;
	 endcase

       
endmodule
 */
