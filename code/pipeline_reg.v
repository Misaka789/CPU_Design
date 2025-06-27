// pipeline_reg.v
module pipeline_reg #(
    parameter WIDTH = 32
) (
    input               clk,
    input               reset,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

    always @(posedge clk , posedge reset) begin
        if (reset) begin
            q <= {WIDTH{1'b0}};
        end else begin
            q <= d;
        end
    end

endmodule