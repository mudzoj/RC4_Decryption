`default_nettype none

module tb_FSM_Init;

    logic CLOCK_50;
    logic rst;
    logic In_Start;
    logic Finish_ack;
    logic Init_Finish;
    logic [7:0] Address;
    logic wren;

    FSM_Init dut (
        .CLOCK_50(CLOCK_50),
        .rst(rst),
        .In_Start(In_Start),
        .Finish_ack(Finish_ack),
        .Init_Finish(Init_Finish),
        .Address(Address),
        .wren(wren)
    );

 
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50; 
    end


    initial begin
        rst = 1;
        In_Start = 0;
        Finish_ack = 0;

        // Hold reset for a few cycles
        #40;
        rst = 0;
        #20;

        // Trigger FSM with In_Start
        In_Start = 1;
        #20;
        In_Start = 0;

        // Wait for entire memory to be written
        wait (Init_Finish == 1);
        #20;

        Finish_ack = 1;
        #20;
        Finish_ack = 0;

        #100;
        $stop;
    end

endmodule

`default_nettype wire
