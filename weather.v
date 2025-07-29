module weather(
    input [1:0] wc,
    input reset, clk,
    output reg [6:0] displayChar
)

always @(*) begin
    case(wc)
        2'b00: displayChar = 7'b0111111; //sunny
        2'b01: displayChar = 7'b1101111; //cloudy
        2'b10: displayChar = 7'b1110010; //rainy
        2'b11: displayChar = 7'b1111001; //stormy
        default: displayChar = 7'b0000000; 
    endcase
end
endmodule
