`default_nettype none
module FSM_Init (
    input  logic CLOCK_50,        // Clock pin
    input  logic rst, In_Start,             // push button switches
    input logic Finish_ack,
    output logic  Init_Finish,
    output logic [7:0] Address,
    output logic wren
);
    enum logic[5:0]{
                  // {#ID, Init_Finish ,wr_en}
        IDLE = {4'd0, 1'b0, 1'b0},
        START = {4'd1, 1'b0, 1'b0},
        INC_ADDR = {4'd2, 1'b0, 1'b0},  //-> if overflow done. if not go to SEND_DATA
        SEND_DATA = {4'd3, 1'b0, 1'b1},// wren on 
        WAIT = {4'd4, 1'b0, 1'b1}, // wait for on eclock cycle 
        DONE = {4'd5, 1'b1, 1'b0}
    } state;

    logic [7:0] addr = 8'b0;

    assign wren = state[0];
    assign Init_Finish = state[1];
    assign Address = addr;
    
    always_ff@(posedge CLOCK_50 or posedge rst) begin
        if (rst)begin
            state<=IDLE;
            addr<= 8'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    if (In_Start) state <= START;
                    addr<= 8'b0;
						  end

                START:
                    state <= SEND_DATA;

                INC_ADDR:begin 
                    addr <= addr + 8'd1;
                    state <= SEND_DATA;
                    end

                SEND_DATA:
                    state <= WAIT; // wren on 

                WAIT: 
                    if (addr ==  8'd255)state <=DONE; // wait for on eclock cycle 
                    else state <= INC_ADDR;
              
                DONE:begin
                    if (Finish_ack) state <=IDLE;
                    else state <=DONE;
                end
                
                default: state<= IDLE;
            endcase
        end
	end
		  
endmodule 
`default_nettype wire