/////////////////////////////////////////interface
interface counterIntf(input logic clk, reset);
    //declaring signals
    logic [3:0] addr;
    logic [7:0] data,currHour, currMin;
    logic [1:0] wc;
    logic motionDetected, env, alarmEn, enable;
endinterface

///////////////////////////////////////transaction class
class Transaction;
    // Declaring the transaction items
    rand logic [3:0] addr;
    rand logic [7:0] data, currHour, currMin;
    rand logic [1:0] wc;
    rand logic motionDetected, env, alarmEn;
    bit clk, reset, enable;

    constraint addr_constraint {
        addr inside {4'b0000, 4'b0101};
    }
    
    constraint data_constraint {
        if (addr == 4'b0000)
            data inside {[0:23]};
        else if (addr == 4'b0001)
            data inside {[0:59]};
    }
endclass

//////////////////////////////////////////////generator class
class generator;
    //declare transaction class
    rand Transaction trans;

    //declare mailbox
    mailbox gen2driv;  

    //repeat count
    int repeatCount;

    //event
    event ended;

    function new(mailbox gen2driv, event ended);
        this.gen2driv = gen2driv;
        this.ended = ended;
    endfunction

    task main();
        repeat(repeatCount) begin
        trans = new();
        if( !trans.randomize() ) $display("Gen:: trans randomization failed"); 
        gen2driv.put(trans);
        end
        ->ended;
    endtask
endclass

///////////////////////////////////////////driver class
class Driver;
    int no_transactions;
    virtual counterIntf intf;
    mailbox gen2driv;
    // logic clk, reset, env, alarmEn, motionDetected, enable;
    // logic [3:0] addr;
    // logic [1:0] wc;
    // logic [7:0] data, currHour, currMin, currSec;

    function new(virtual counterIntf intf, mailbox gen2driv);
        this.gen2driv = gen2driv;
        this.intf = intf;
    endfunction

    //reset task
   task reset();
        wait(intf.reset);
        $display("Resetting the counter");
        intf.enable <= 0;
        intf.addr <= 4'b0;
        intf.data <= 8'b0;
        intf.wc <= 2'b0;
        intf.currHour <= 8'b0;
        intf.currMin <= 8'b0;
        intf.alarmEn <= 0;
        intf.env <= 0;
        intf.motionDetected <= 0;
        wait(!intf.reset);
        $display("Counter reset complete");
    endtask



    task drive();
        forever begin 
            Transaction trans;
            intf.enable<= 0;
            gen2driv.get(trans);
            $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
            @(posedge intf.clk);
            intf.addr <= trans.addr;
            intf.enable <= trans.enable;
            intf.data <= trans.data;
            $display("\tADDR = %0d \tDATA = %0d",trans.addr,trans.data);
            @(posedge intf.clk);
            $display("-----------------------------------------");
            no_transactions++;
        end
    endtask
endclass

/////////////////////////////////////////////monitor class
class Monitor;
    int no_transactions;
    virtual counterIntf intf;
    mailbox gen2driv;    

    function new(virtual counterIntf intf, mailbox gen2driv);
        this.gen2driv = gen2driv;
        this.intf = intf;
    endfunction

            task monitor();
        forever begin
            Transaction trans;
            intf.enable<= 0;
            gen2driv.get(trans);
            @(posedge intf.clk);
            intf.enable <= trans.enable;
            intf.currMin <= trans.currMin;
            intf.currHour <= trans.currHour;            
            no_transactions++; 
        end
    endtask
endclass

//////////////////////////////////////////scoreboard class
class Scoreboard;
  logic alarmOut, light;
  logic [6:0] displayChar;

  function new(input logic alarmOut, light, displayChar);
    this.alarmOut = alarmOut;
    this.light = light;
    this.displayChar = displayChar;
  endfunction

  task compare();
    // Expected results
    logic expAlarmOut = 0;
    logic expLight = 1;
    logic [6:0] expDisplayChar = 7'b0;

    // Compare results
    @(posedge alarmOut, light, displayChar);
    if (alarmOut !== expAlarmOut)
      $display("Error expAlarmOut= %b, but got alarmOut= %b", expAlarmOut, alarmOut);
    if (light !== expLight)
      $display("Error expLight= %b, but got light= %b", expLight, light);
    if (displayChar !== expDisplayChar)
      $display("Error expDisplayChar= %b, but got displayChar= %b", expDisplayChar, displayChar);
  endtask
endclass

//////////////////////////////////////////environment class
class Environment;
    //declare handles
    generator gen;
    Driver driv;
    Monitor mon;
    mailbox gen2driv;
    event gen_ended;
    virtual counterIntf intf;

    //constructor
  function new(virtual counterIntf intf);
    //get the interface from test
    this.intf = intf;
    
    //creating the mailbox
    gen2driv = new();
    
    //creating generator and driver
    gen = new(gen2driv,gen_ended);
    driv = new(intf,gen2driv);
    // this.mon = new();
    mon = new(intf,gen2driv);
  endfunction

    //pretest
    task pretest();
        driv.reset();
    endtask

    //test
    task test();
    fork
        gen.main();
        driv.drive();
        mon.monitor();
    join_any
    endtask

    //posttest
    task post_test();
        wait(gen_ended.triggered);
        wait(gen.repeatCount == driv.no_transactions);
        wait(gen.repeatCount == mon.no_transactions);
    endtask 

    //run
    task run();
        pretest();
        test();
        post_test();
    endtask
endclass

///////////////////////////////////////////program
program test(counterIntf intf);
    Environment env;

    initial begin
        env = new(intf);
        env.gen.repeatCount = 10;
        env.run();
    end
endprogram

//////////////////////////////////////////main module test2.sv
module test2;
  // Signals
  bit clk, reset;
  counterIntf intf(clk, reset);
  test t1(intf);

  logic env, alarmEn, motionDetected, enable;
  logic [3:0] addr;
  logic [1:0] wc;
  logic [7:0] data;
  wire alarmOut, light;
  wire [6:0] displayChar;
  wire [7:0] countSec, countMin, countHr, currHour,currMin,alarmHr, alarmMin;

// Instantiate driver, monitor, and scoreboard
  //Driver driverInst;
  //Monitor monitorInst;
  Scoreboard scoreboardInst;

  // Instantiate main module
    main mainInst (
    .clk(intf.clk),
    .reset(intf.reset),
    .env(intf.env),
    .alarmEn(intf.alarmEn),
    .motionDetected(intf.motionDetected),
    .enable(enable),
    .addr(intf.addr),
    .wc(intf.wc),
    .data(intf.data),
    .currHour(intf.currHour),
    .currMin(intf.currMin),
    .alarmOut(alarmOut),
    .light(light),
    .displayChar(displayChar),
    .countSec(countSec),
    .countMin(countMin),
    .countHr(countHr),
    .alarmHr(alarmHr),
    .alarmMin(alarmMin)
  );


  // Clock generation
  always #5 clk = ~clk;

    // Connect driver, monitor, and scoreboard
  initial begin
	clk=0;
	enable=0;
	reset=1;
  	alarmEn=0;
	#20 reset=0;
  	enable=1;
	alarmEn=1;

$monitor("Time: %0d:%0d:%0d", countHr, countMin, countSec);
    //driverInst = new(clk, reset, env, alarmEn, motionDetected, enable, addr, wc, data, currHour, currMin, currSec);
    //monitorInst = new();
    scoreboardInst = new(alarmOut, light, displayChar);

    fork
      //driverInst.drive();
      //monitorInst.monitor();
      scoreboardInst.compare();
    join
    
  end
endmodule
