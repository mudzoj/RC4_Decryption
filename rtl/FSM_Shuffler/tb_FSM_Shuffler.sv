`default_nettype none

module tb_FSM_Shuffler;

    logic clk;
    logic rst;
    logic [23:0] Secret_Key;
    logic In_Start;
    logic [7:0] q;
    logic Finish_ack;

    logic [7:0] data;
    logic [7:0] Address;
    logic Init_Finish;
    logic wren;

    FSM_Shuffler dut (
        .clk(clk),
        .rst(rst),
        .Secret_Key(Secret_Key),
        .In_Start(In_Start),
        .q(q),
        .Finish_ack(Finish_ack),
        .data(data),
        .Address(Address),
        .Init_Finish(Init_Finish),
        .wren(wren),
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end


    always_ff @(posedge clk) begin
        case (Address)
            8'd0: q <= 8'h12;  
            8'd18: q <= 8'hA4; 
            8'd1: q <= 8'h34;  
            8'd88: q <= 8'hB2; 
            default: q <= 8'h00;
        endcase
    end


    initial begin
        rst = 1;
        In_Start = 0;
        Finish_ack = 0;
        Secret_Key = 24'hCAFEB0;

        #25 rst = 0;
        #20;

        // Begin FSM
        In_Start = 1;
        #20 In_Start = 0;

        #600;

        // Send Finish_ack to return to IDLE
        Finish_ack = 1;
        #20 Finish_ack = 0;

        #100;
        $stop;
    end

endmodule

`default_nettype wire
