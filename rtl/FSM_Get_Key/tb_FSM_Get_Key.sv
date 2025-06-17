`default_nettype none

module tb_FSM_Get_Key;


    parameter BEGIN_SEARCH = 22'd0;
    parameter END_SEARCH = 22'd5;


    logic clk;
    logic rst;
    logic Crack_Start;
    logic Key_Valid;
    logic Checker_Finish;

    logic [23:0] Secret_Key;
    logic Check_Ack;
    logic Control_Start;
    logic Valid_Key_Found;
    logic [1:0] LEDR;

  
    FSM_Get_Key #(
        .BEGIN_SEARCH(BEGIN_SEARCH),
        .END_SEARCH(END_SEARCH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .Crack_Start(Crack_Start),
        .Secret_Key(Secret_Key),
        .Key_Valid(Key_Valid),
        .Checker_Finish(Checker_Finish),
        .Check_Ack(Check_Ack),
        .Control_Start(Control_Start),
        .Valid_Key_Found(Valid_Key_Found),
        .LEDR(LEDR)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // Stimulus
    initial begin
        // Initialize
        rst = 1;
        Crack_Start = 0;
        Key_Valid = 0;
        Checker_Finish = 0;

        // Hold reset
        #40;
        rst = 0;
        #20;

        // Start cracking
        Crack_Start = 1;
        #20;
        Crack_Start = 0;

        // Simulate a few failed keys
        repeat (3) begin
            #80; Checker_Finish = 1; #20; Checker_Finish = 0;
            #20; // let FSM proceed
        end

        // Simulate a successful key
        Key_Valid = 1;
        #40; Checker_Finish = 1; #20; Checker_Finish = 0;
        Key_Valid = 0;

        #100;

        $stop;
    end

endmodule

`default_nettype wire
