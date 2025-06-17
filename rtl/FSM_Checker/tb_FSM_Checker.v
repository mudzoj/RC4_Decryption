`default_nettype none

module tb_FSM_Checker;

    logic CLOCK_50;
    logic rst;
    logic Checker_Start;
    logic Finish_ack;
    logic [7:0] q_D;
    logic Checker_Finish;
    logic [7:0] Address;
    logic Decrypt_Valid;

    FSM_Checker dut (
        .CLOCK_50(CLOCK_50),
        .rst(rst),
        .Checker_Start(Checker_Start),
        .Finish_ack(Finish_ack),
        .q_D(q_D),
        .Checker_Finish(Checker_Finish),
        .Address(Address),
        .Decrypt_Valid(Decrypt_Valid)
    );

    // Clock generator
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Stimulus
    initial begin
        // Initialize signals
        rst = 1;
        Checker_Start = 0;
        Finish_ack = 0;
        q_D = "a";

        // Hold reset for some time
        #50;
        rst = 0;
        #40;

        // Start FSM
        Checker_Start = 1;
        #20;
        Checker_Start = 0;

        // Apply valid characters
        q_D = "a";
        #20;
        #20;
        #20;
        q_D = "f";
        #20;
        #20;
        #20;
        q_D = "z"; 
        #20;
        #20;
        #20;
        q_D = " ";
        #20;
        #20;
        #20;

        // Apply invalid character
        q_D = "2";
        #20;
        #20;
        #20;

        #80;
        // Acknowledge and reset
        Finish_ack = 1;
        #20;
        Finish_ack = 0;

        #50;
        $stop;
    end

endmodule

`default_nettype wire
