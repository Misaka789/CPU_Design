module HazardDetectionUnit (
    input        EX_MemRead,
    input  [4:0] EX_rd,

    input  [4:0] ID_rs1,
    input  [4:0] ID_rs2,
    output       PipelineStall
);

   // 满足 lw sw 冒险就需要停顿一个周期 然后会自动使用前递逻辑来处理
    
    wire hazard_on_rs1 = (EX_MemRead && (EX_rd != 5'b0) && (EX_rd == ID_rs1));
    wire hazard_on_rs2 = (EX_MemRead && (EX_rd != 5'b0) && (EX_rd == ID_rs2));

    assign PipelineStall = hazard_on_rs1 || hazard_on_rs2;

endmodule