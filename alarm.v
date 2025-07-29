module alarm(
input [7:0] currHour,currMin,currSec,
input reset,clk,
output reg alarmOut);
reg [7:0] alarmHour,alarmMin,alarmSec;
reg alarmEn;
reg [5:0] alarmTimer;

initial begin
alarmHour=8'b00000000;
alarmMin=8'b00000000;
alarmSec=8'b00000000;
alarmOut=1'b0;
alarmEn=1'b0;
end

always @(posedge reset) begin
if(reset) begin
	alarmHour<=8'b00000000;
	alarmMin<=8'b00000000;
	alarmSec<=8'b00000000;
	alarmOut<=1'b0;
	alarmEn<=1'b0;
	alarmTimer<=6'b0;
end
end

always @(posedge clk) begin
	if(alarmEn) begin
		if(alarmHour==currHour && alarmMin==currMin && alarmSec===currSec) begin
		if(alarmTimer<60) begin
			alarmTimer<=alarmTimer+1;
			alarmOut<=1'b1;
		end else begin
			alarmOut<=1'b0;
		end
	end else begin
	alarmTimer<=6'b0;
	alarmOut<=1'b0;
	end
	end else begin
	alarmTimer<=6'b0;
	alarmOut<=1'b0;
	end
end
endmodule