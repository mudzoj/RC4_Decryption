`default_nettype none

module FSM_Controller(
    input logic clk, 
    input logic Controller_Start, Finish_ack,
    input logic Init_Finish,Shuffle_A_Finish,Shuffle_B_Finish,Decrypt_Finish, Decrypt_Valid,
    output logic Init_Start,Shuffle_A_Start,Shuffle_B_Start,Decrypt_Start, Decrypt_done, Key_Valid,
    output logic [2:0] Mem_sel,
    input logic rst
);
	
    enum logic[7:0]{
        IDLE = 8'b0000_0000,
        INIT_START = 8'b0000_0001,
        INIT_WAIT = 8'b0001_0000,
        SHUFFLEA_START = 8'b0010_0010,
        SHUFFLEA_WAIT = 8'b0011_0000,
        SHUFFLEB_START = 8'b0100_0100,
        SHUFFLEB_WAIT = 8'b0101_0000,
        DECRYPT_START = 8'b0110_1000,
        DECRYPT_WAIT = 8'b0111_0000,
        DONE = 8'b1000_0000
    } state;
	assign Init_Start = state[0];
    assign Shuffle_A_Start = state[1];
    assign Shuffle_B_Start = state[2];
    assign Decrypt_Start = state[3];
    assign Mem_sel = state[6:4];
    assign Decrypt_done = state[7];

	always_ff@(posedge clk) begin
        if (rst) begin 
            state<=IDLE;
            Key_Valid<=1'b0;
        end
        else case(state)
        IDLE: if (Controller_Start) state<= INIT_START;
            else state<= IDLE;

        INIT_START: state<=INIT_WAIT;
        INIT_WAIT: if (Init_Finish) state<= SHUFFLEA_START;
                    else state<= INIT_WAIT;

        SHUFFLEA_START: state<= SHUFFLEA_WAIT;
        SHUFFLEA_WAIT: if (Shuffle_A_Finish) state<= SHUFFLEB_START;
                    else state<= SHUFFLEA_WAIT;

        SHUFFLEB_START: state<=SHUFFLEB_WAIT;
        SHUFFLEB_WAIT: if (Shuffle_B_Finish) state<= DECRYPT_START;
                    else state<= SHUFFLEB_WAIT; 

        DECRYPT_START: state<= DECRYPT_WAIT; 
        DECRYPT_WAIT: if (Decrypt_Finish) begin
                    state<= DONE;
                    Key_Valid<=Decrypt_Valid;
            end
                    else state<= DECRYPT_WAIT;  

        DONE: if (Finish_ack) begin
            Key_Valid<=1'b0;
            state <=IDLE;
            end
            else state <=DONE;

        default: state<=IDLE;
        endcase
	end

endmodule
`default_nettype wire