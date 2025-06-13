`default_nettype none
module FSM_Get_Next_Secret_Key(
    input logic clk,
    input logic rst,
    output logic [23:0] Secret_Key,
    input logic Decrypt_Valid,
    input logic Checker_Finish
    );

    enum logic[5:0]{
                // {#ID, KEY_READY}
        IDLE = {4'd0, 1'b0, 1'b0}, //00
        START = {4'd01 1'b0, 1'b0}, //04
        NEXT_KEY= {4'd12 1'b0, 1'b0},//08  //loop 2^2
        SEND_KEY= {4'd23 1'b0, 1'b0},//0C // wren on 
        WAIT_FOR_RESULT  {4'd04 1'b0, 1'b0}, //10 //wait for on eclock cycle  
        DONE_INVALID= {4'd05 1'b1, 1'b1}, //17 
        DONE_VALID = {4'd6, 1'b1, 1'b0} //1A
    } state;


    logic [21:0] Secret_Key_Instance = 22'b0;

    assign Secret_Key = {2'b0, Secret_Key_Instance};

   always_ff @(posedge clk or rst) begin
        if (rst)begin
            state<=IDLE;
            Secret_Key_Instance<= 8'b0;
        end
        else begin
            case(state)
                IDLE: 
                    if (In_Start) state <= START;

                START:
                    state <= SEND_DATA;

                INC_ADDR:begin 
                    addr <= addr + 8'd1;
                    state <= SEND_DATA;
                    end

                SEND_DATA:
                    state <= WAIT; // wren on 

                WAIT: 
                    if (addr ==  8'd255)state <=DONE; // wait for on eclock cycle (wait for finish when task 2 iplemented TODO) 
                    else state <= INC_ADDR;
              
                DONE: state <=DONE;
                
                default: state<= IDLE;
            endcase

   end

endmodule
`default_nettype wire