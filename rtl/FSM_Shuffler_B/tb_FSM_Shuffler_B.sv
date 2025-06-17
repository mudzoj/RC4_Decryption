`default_nettype none

module tb_FSM_Shuffler_B;

    logic clk, rst;
    logic Shuffle_B_Start, Finish_ack;
    logic Shuffle_B_Finish;
    logic wren_S, wren_D;

    logic [7:0] q_S, data_S, Address_S;
    logic [7:0] q_D, data_D, Address_D;
    logic [7:0] q_C;
    logic [4:0] Address_C;

    logic [7:0] state;

    FSM_Shuffler_B dut (
        .clk(clk),
        .rst(rst),
        .Shuffle_B_Start(Shuffle_B_Start),
        .Finish_ack(Finish_ack),
        .q_S(q_S),
        .data_S(data_S),
        .Address_S(Address_S),
        .q_D(q_D),
        .data_D(data_D),
        .Address_D(Address_D),
        .q_C(q_C),
        .Address_C(Address_C),
        .Shuffle_B_Finish(Shuffle_B_Finish),
        .wren_S(wren_S),
        .wren_D(wren_D),
        .states(state)
    );

 
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Manual driver for simulated memory (ROM/RAM)
    always_ff @(posedge clk) begin
        // ROM
        case (Address_C)
            0: q_C <= 8'hAA;
            1: q_C <= 8'hBB;
            default: q_C <= 8'h00;
        endcase

        // RAM: q_S depends on Address_S 
        case (Address_S)
            0: q_S <= 8'h11;   // s[i=0]
            0 + 8'h11: q_S <= 8'h22; // s[j] when j = j + s[i]
            1: q_S <= 8'h33;   // 2nd i
            0 + 8'h33: q_S <= 8'h44; // s[j] on 2nd round
            default: q_S <= 8'h00;
        endcase
    end


    initial begin
       
        rst = 1;
        Shuffle_B_Start = 0;
        Finish_ack = 0;

        #12 rst = 0;
        #10 Shuffle_B_Start = 1;
        #10 Shuffle_B_Start = 0;

        // Let FSM run through 2 iterations
        #500;


        Finish_ack = 1;
        #10 Finish_ack = 0;

        #50;
        $stop;
    end

endmodule

`default_nettype wire
