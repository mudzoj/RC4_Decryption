`default_nettype none

module FSM_Shuffler_B(
    input logic clk,
    input logic rst,

    input logic Shuffle_B_Start,
    input logic Finish_ack,

    input logic [7:0] q_S, // working memory
    output logic [7:0] data_S,
    output logic [7:0] Address_S,
    
    input logic [7:0] q_D, // Decrypted RAM memory (output)
    output logic [7:0] data_D,
    output logic [7:0] Address_D,

    input logic [7:0] q_C, // Encypted msg (ROM)
    output logic [4:0] Address_C,

    output logic Shuffle_B_Finish,
    output logic wren_S,
    output logic wren_D
);

    enum logic[7:0]{
                  // {#ID, Init_Finish, wr_en_S, wr_en_D}
        IDLE =             {5'b0, 1'b0, 1'b0, 1'b0}, //00000 0 0 0 | HEX:  00
        START =            {5'd1, 1'b0, 1'b0, 1'b0}, //00001 0 0 0 | HEX: 08
        INC_K =            {5'd2, 1'b0, 1'b0, 1'b0}, //00010 0 0 0 | HEX: 10
        //READ - S RAM
        SEND_ADDR_I =      {5'd3, 1'b0, 1'b0, 1'b0}, //00011 0 0 0 | HEX: 18

        WAIT_ADDR_I =      {5'd4, 1'b0, 1'b0, 1'b0}, //00100 0 0 0 | HEX: 20

        COMPUTE_J =        {5'd5, 1'b0, 1'b0, 1'b0}, //00101 0 0 0 | HEX: 28
        SEND_ADDR_J =      {5'd6, 1'b0, 1'b0, 1'b0}, //00110 0 0 0 | HEX: 30

        WAIT_ADDR_J =      {5'd7, 1'b0, 1'b0, 1'b0}, //00111 0 0 0 | HEX: 38
        //WRITE - S RAM
        SWAP_I =           {5'd8, 1'b0, 1'b0, 1'b0}, //01000 0 0 0 | HEX: 40
        SEND_SWAP_I =      {5'd9, 1'b0, 1'b1, 1'b0}, //01001 0 1 0 | HEX: 4A
        SWAP_J =           {5'd10, 1'b0, 1'b0, 1'b0}, //01010 0 0 0 | HEX: 50
        SEND_SWAP_J =      {5'd11, 1'b0, 1'b1, 1'b0}, //01011 0 1 0 | HEX: 5A 
        WAIT_SWAP_J =      {5'd12, 1'b0, 1'b0, 1'b0}, //01100 0 0 0 | HEX: 60
        
        //READING - S RAM and C RAM
        SEND_ADDR_F_K =    {5'd13, 1'b0, 1'b0, 1'b0}, //01101 0 0 0 | HEX: 68
        WAIT_ADDR_F_K =    {5'd14, 1'b0, 1'b0, 1'b0}, //01110 0 0 0 | HEX: 70

        //WRITING - DECRYPT RAM
        COMPUTE_DECRYPT =  {5'd15, 1'b0, 1'b0, 1'b0}, //01111 0 0 0 | HEX: 78 
        SEND_ADDR_K =      {5'd16, 1'b0, 1'b0, 1'b1}, //10000 0 0 1 | HEX: 81
        CHECK_VAL_K =      {5'd17, 1'b0, 1'b0, 1'b0}, //10001 0 0 0 | HEX: 88
        DONE =             {5'd18, 1'b1, 1'b0, 1'b0} //10010 1 0 0  | HEX: 94



    } state;

    logic [7:0] addr_S = 8'b0;
    logic [7:0] addr_C = 8'b0;
    logic [7:0] addr_D = 8'b0;

    logic [7:0] i = 8'b0;
    logic [7:0] j = 8'b0;
    logic [7:0] k = 8'b0;
    logic [7:0] i_data = 8'b0;
    logic [7:0] j_data = 8'b0;


    logic [7:0] f = 8'b0;

    assign wren_D = state[0];
    assign wren_S = state[1];
    assign Shuffle_B_Finish = state[2];
    assign Address_S = addr_S;
    assign Address_C = addr_C;
    assign Address_D = addr_D;
    
    always_ff@(posedge clk or posedge rst) begin
        if (rst)begin
            state<=IDLE;
            addr_S<= 8'b0;
            addr_C <= 8'b0;
            addr_D <= 8'b0;
            i <= 8'b0;
            j <= 8'b0;
            k <= 8'b0;
            i_data <= 8'b0;
            j_data <= 8'b0;
            f <= 8'b0;
        end
        else begin
            case(state)
                IDLE:begin 
                    if (Shuffle_B_Start) state <= START;
                end

                START:begin
                    i <= i + 8'd1; 
                    state <= SEND_ADDR_I;
                end

                INC_K:begin 
                    k <= k + 8'd1;
                    i <= i + 8'd1; 
                    state <= SEND_ADDR_I;
                end

            //READING - S RAM
                SEND_ADDR_I:begin      
                    addr_S <= i; //retrieve s[i+i] 
                    state <= WAIT_ADDR_I; 
                end 
                
                WAIT_ADDR_I: begin
                    state <= COMPUTE_J;
                end

                COMPUTE_J:begin  //next clk cycle q should hold address value at this point
                    i_data <= q_S;
                    j <= j + q_S;
                    state <= SEND_ADDR_J;
                end

                SEND_ADDR_J:begin
                    addr_S <= j;
                    state <= WAIT_ADDR_J;
                end

                WAIT_ADDR_J: begin
                    state <= SWAP_I;
                end

            //WRITING - S RAM
                SWAP_I: begin
                    j_data <= q_S;
                    addr_S <= i;
                    data_S <= q_S;
                    state <= SEND_SWAP_I;
                end

                SEND_SWAP_I: begin //wren_S HIGH
                    state <= SWAP_J;
                end


                SWAP_J: begin //wren_S LOW
                    addr_S <= j;
                    data_S <= i_data;
                    state <= SEND_SWAP_J;

                end
                SEND_SWAP_J: begin //wren_S HIGH
                    // state <= WAIT_SWAP_J;
                    state <= WAIT_SWAP_J;
                end

                WAIT_SWAP_J: begin //wren_S LOW
                    f <= i_data + j_data;
                    state <= SEND_ADDR_F_K;
                end
            //READING - S RAM and C RAM
                SEND_ADDR_F_K: begin //wren_S LOW 
                    addr_S <= f;
                    addr_C <= k;
                    state <= WAIT_ADDR_F_K;
                end

                WAIT_ADDR_F_K: begin
                    state <= COMPUTE_DECRYPT;
                end

            //WRITING - DECRYPT RAM
                COMPUTE_DECRYPT:begin  //wren_d LOW
                    data_D <= q_S ^ q_C; // f_data XOR encrypted_input[k]
                    addr_D <= k;
                    state <= SEND_ADDR_K;
                end
                SEND_ADDR_K: begin //wren_D HIGH
                    state <= CHECK_VAL_K;
                end

                CHECK_VAL_K: begin //WREN_D LOW
                if (k ==  8'd31)  //
                        state <= DONE;
                    else 
                        state <= INC_K;
                end
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