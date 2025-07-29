module motion(
    input reset, motionDetected,
    output reg alarmOut
);

reg alarmOutReset;

always @(*) begin
    alarmOut = (reset) ? alarmOutReset : motionDetected;
end

//connect reset value to mux select
always @(posedge reset) begin
    alarmOutReset <=0;
end
endmodule
