module light(
    input reset, clk, env,
    output reg light
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        light<=1;
    end else begin
        light <= (env?0:1);
    end
end
endmodule
