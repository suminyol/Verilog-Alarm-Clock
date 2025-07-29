module counter2(
input clk, reset, enable,
input [7:0] currHour, currMin,
output reg [7:0] countSec,countMin,countHr);

//define states
parameter idleState=2'b00;
parameter counterState=2'b01;
parameter resetState=2'b10;
parameter timerSetState=2'b11;

//state signals
reg [1:0] currState, nextState;

//fsm state transition and output logic
always @(posedge clk or posedge reset) begin
	if(reset) begin
	currState <= idleState;
	countSec<=8'b0;
	countMin<=8'b0;
	countHr<=8'b0;
	end else begin

	//state transition logic
	case(currState)
		idleState: begin
		if(enable) 
		nextState=counterState;
        //else if (timerSet)
		//nextState=timerSetState;
        else
        nextState=idleState;
		end 

		counterState: begin
        countSec <= countSec + 1;
        if (countSec == 59) begin
            countSec <= 0;
            countMin <= currMin + 1;
            if (countMin == 59) begin
                countMin <= 0;
                countHr <= currHour + 1;
                if (countHr == 23) begin
                    countHr <= 0;
                end
            end
        end
        end        

		resetState: begin
		nextState=resetState;
		end

		timerSetState: begin
        if(enable)
		nextState=counterState;
        else
        nextState=timerSetState;
		end

		default: nextState=idleState;
	endcase

	//state update
	currState<=nextState;
end
end
endmodule
	