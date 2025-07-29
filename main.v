module main(
input clk,reset,env, alarmEn,motionDetected,enable,
input [3:0] addr,
input [1:0] wc,
input [7:0] data, 
output alarmOut, light,
output [6:0] displayChar,
output [7:0] countMin, countSec, countHr,currHour,currMin,alarmHr, alarmMin);

//submodule instantiation
alarm alarmInst(
.currHour(currHour),
.currMin(currMin),
.clk(clk),
.reset(reset),
.alarmOut(alarmOut));

motion motionInst(
.reset(reset),
.motionDetected(motionDetected),
.alarmOut(alarmOut));

weather weatherInst(
.wc(wc),
.reset(reset),
.clk(clk),
.displayChar(displayChar));

light lightInst(
.env(env),
.reset(reset),
.clk(clk),
.light(light));

counter2 counterInst(
.clk(clk),
.reset(reset),
.enable(enable),
.countSec(countSec),
.countMin(countMin),
.countHr(countHr),
.currHour(currHour),
.currMin(currMin));

memory memoryInst(
.reset(reset),
.data(data),
.addr(addr),
.clk(clk),
.alarmEn(alarmEn),
.alarmHr(alarmHr),
.alarmMin(alarmMin),
.currHour(currHour),
.currMin(currMin));

//signals and variables
reg setTime,en;
wire alarmMatch;
reg cState, nState;

//FSM states
parameter idleState=2'b00;
parameter alarmModeState=2'b01;
parameter setTimeState=2'b10;

//default values
//initial begin 
//cState=idleState;
//enable=1'b0;
//setTime=1'b0;
//end

//FSM state transition and output logic
always @(posedge clk or posedge reset) begin
	if(reset) begin
	cState<=idleState;
	end else begin

	case(cState)
		idleState: begin
		if(alarmEn)begin
            nState=alarmModeState;
            en <= 1;
            setTime <= 0;
		end else if(setTime) begin
            nState=setTimeState;
            en <= 0;
            setTime <= 1;
		end else begin 
            nState=idleState;
		end end

		alarmModeState: begin
		if(alarmEn) begin
            nState=idleState;
            en <= 0;
            setTime <= 0;
		end else if(setTime) begin
            nState=setTimeState;
            en <= 0;
            setTime <= 1;
		end else begin
            nState=alarmModeState;
		end end

		setTimeState: begin
		if(alarmEn) begin 
            nState=alarmModeState;
            en <= 1;
            setTime <= 0;
		end else if (setTime) begin
            nState=idleState;
            en <= 0;
            setTime <= 1;
		end else begin 
            nState=setTimeState;
		end end

		default: nState=idleState;
	endcase
	cState<=nState;
    end
end
endmodule