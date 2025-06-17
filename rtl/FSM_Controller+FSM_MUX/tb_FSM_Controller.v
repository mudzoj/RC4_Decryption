`default_nettype none

module tb_FSM_Controller;


    logic clk;
    logic Controller_Start;
    logic Finish_ack;
    logic Init_Finish;
    logic Shuffle_A_Finish;
    logic Shuffle_B_Finish;
    logic Decrypt_Finish;
    logic Decrypt_Valid;
    logic rst;

    logic Init_Start;
    logic Shuffle_A_Start;
    logic Shuffle_B_Start;
    logic Decrypt_Start;
    logic Decrypt_done;
    logic Key_Valid;
    logic [2:0] Mem_sel;

    FSM_Controller dut (
        .clk(clk),
        .Controller_Start(Controller_Start),
        .Finish_ack(Finish_ack),
        .Init_Finish(Init_Finish),
        .Shuffle_A_Finish(Shuffle_A_Finish),
        .Shuffle_B_Finish(Shuffle_B_Finish),
        .Decrypt_Finish(Decrypt_Finish),
        .Decrypt_Valid(Decrypt_Valid),
        .Init_Start(Init_Start),
        .Shuffle_A_Start(Shuffle_A_Start),
        .Shuffle_B_Start(Shuffle_B_Start),
        .Decrypt_Start(Decrypt_Start),
        .Decrypt_done(Decrypt_done),
        .Key_Valid(Key_Valid),
        .Mem_sel(Mem_sel),
        .rst(rst)
    );


    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
  
        rst = 1;
        Controller_Start = 0;
        Finish_ack = 0;
        Init_Finish = 0;
        Shuffle_A_Finish = 0;
        Shuffle_B_Finish = 0;
        Decrypt_Finish = 0;
        Decrypt_Valid = 0;

        // Hold reset
        #40;
        rst = 0;
        #20;

        // Start controller
        Controller_Start = 1;
        #20;
        Controller_Start = 0;

        // Go through INIT
        #40;
        Init_Finish = 1;
        #20;
        Init_Finish = 0;

        // Go through SHUFFLE A
        #40;
        Shuffle_A_Finish = 1;
        #20;
        Shuffle_A_Finish = 0;

        // Go through SHUFFLE B
        #40;
        Shuffle_B_Finish = 1;
        #20;
        Shuffle_B_Finish = 0;

        // Go through DECRYPT
        #40;
        Decrypt_Valid = 1;      // simulate successful decryption
        Decrypt_Finish = 1;
        #20;
        Decrypt_Finish = 0;
        Decrypt_Valid = 0;

        // Done state
        #40;
        Finish_ack = 1;
        #20;
        Finish_ack = 0;

        #50;
        $stop;
    end

endmodule

`default_nettype wire
