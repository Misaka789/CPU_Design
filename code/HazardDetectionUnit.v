module HazardDetectionUnit (
    input        EX_MemRead,
    input  [4:0] EX_rd,

    input  [4:0] ID_rs1,
    input  [4:0] ID_rs2,
    input   valid,
    output       PipelineStall
);

   // 满足 lw use 冒险就需要停顿一个周�? 然后会自动使用前递�?�辑来处�?
    
    wire hazard_on_rs1 = (EX_MemRead && (EX_rd != 5'b0) && (EX_rd == ID_rs1));
    wire hazard_on_rs2 = (EX_MemRead && (EX_rd != 5'b0) && (EX_rd == ID_rs2));

    assign PipelineStall = valid ? (hazard_on_rs1 || hazard_on_rs2) : 1'b0;

endmodule