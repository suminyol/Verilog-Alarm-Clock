module memory(
    input [7:0] data,
    input [3:0] addr,
    input clk, reset,
    output reg alarmEn, 
    output reg [7:0] alarmHr, alarmMin,
    output reg [7:0] currHour, currMin);

    reg [7:0] ram [0:7]; 

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            alarmHr <= 8'b00000000;
            alarmMin <= 8'b00000000;
            alarmEn <= 1'b0;
            currHour <= 8'b00000000;
            currMin <= 8'b00000000;
        end else begin
              ram[addr] <= data;
        end
    
     alarmHr <= ram[2];
     alarmMin<= ram[3];
     alarmEn <= ram[5];
     currHour<= ram[0];
     currMin <= ram[1];

end
endmodule