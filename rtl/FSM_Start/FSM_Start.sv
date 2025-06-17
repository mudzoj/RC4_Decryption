`default_nettype none

module FSM_Start(
    input logic clk,
    input logic rst,

    output logic start
);

    enum logic[2:0]{
                // {#ID, start}
        IDLE =           {2'd0, 1'b0},//00 0
        SEND_START =     {2'd1, 1'b1},//01 1
        IDLE_START =     {2'd2, 1'b0} //10 0

    } state;

    assign start = state[0];

    always_ff @(posedge clk or posedge rst)begin
        if (rst) state<=IDLE;
        else begin
            case(state)
                
                IDLE: state<= SEND_START;
                SEND_START: state<= IDLE_START;
                default: state<=IDLE;
        
        endcase 
    
        end
    end

endmodule
`default_nettype wire