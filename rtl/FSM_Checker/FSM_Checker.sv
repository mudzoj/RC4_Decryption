`default_nettype none
module FSM_Checker (
    input  logic CLOCK_50,        // Clock pin
    input  logic rst, Checker_Start,Finish_ack,             // push button switches
    input logic [7:0] q_D,
    output logic  Checker_Finish,
    output logic [7:0] Address,
    output logic Decrypt_Valid
);
    enum logic[5:0]{
                  // {#ID, Init_Finish , Valid}
        IDLE = {4'd0, 1'b0, 1'b0}, //00
        START = {4'd1, 1'b0, 1'b0}, //04
        INC_ADDR = {4'd2, 1'b0, 1'b0},//08  //loop 32 times (0-31)
        CHECK_DATA = {4'd3, 1'b0, 1'b0},//0C // wren on 
        WAIT = {4'd4, 1'b0, 1'b0}, //10 //wait for on eclock cycle  
        DONE_VALID = {4'd5, 1'b1, 1'b1}, //17 
        DONE_INVALID = {4'd6, 1'b1, 1'b0} //1A
    } state;

    logic [7:0] addr = 8'b0;

    assign Decrypt_Valid = state[0];
    assign Checker_Finish = state[1];
    assign Address = addr;
    
    always_ff@(posedge CLOCK_50 or posedge rst) begin
        if (rst)begin
            state<=IDLE;
            addr<= 8'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    addr<= 8'b0;
                    if (Checker_Start) state <= START;
                end
                START:
                    state <= CHECK_DATA;

                INC_ADDR:begin 
                    addr <= addr + 8'd1;
                    state <= CHECK_DATA;
                    end

                CHECK_DATA: 
                     if ((q_D >= 8'd97 && q_D <= 8'd122) || (q_D == 8'd32))
                        state <= WAIT;
                    else
                        state <= DONE_INVALID;


                WAIT: 
                    if (addr ==  8'd31)state <=DONE_VALID;  
                    else state <= INC_ADDR;
              
                DONE_VALID: 
                    if (Finish_ack) state <=IDLE;
                    else state <=DONE_VALID;
                
                DONE_INVALID: 
                    if (Finish_ack) state <=IDLE;
                    else state <=DONE_INVALID;
                
                
                default: state<= IDLE;
            endcase
        end
	end
		  
endmodule 
`default_nettype wire