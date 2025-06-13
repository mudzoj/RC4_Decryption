`default_nettype none

module FSM_Shuffler(
    input logic clk,
    input logic rst,

    input logic [23:0] Secret_Key,
    input logic In_Start,
    input logic [7:0] q,
    input logic Finish_ack,

    output logic [7:0] data,
    output logic [7:0] Address,
    output logic Init_Finish,
    output logic wren
);

    enum logic[5:0]{
                  // {#ID, Init_Finish ,wr_en}
        IDLE =          {4'b0, 1'b0, 1'b0},
        START =         {4'd1, 1'b0, 1'b0},
        INC_I =         {4'd2, 1'b0, 1'b0},  
        //READ
        SEND_ADDR_I =   {4'd3, 1'b0, 1'b0},

        WAIT_ADDR_I =   {4'd4, 1'b0, 1'b0}, // TODO TEST

        COMPUTE_J =     {4'd5, 1'b0, 1'b0}, 
        SEND_ADDR_J =   {4'd6, 1'b0, 1'b0},

        WAIT_ADDR_J =   {4'd7, 1'b0, 1'b0}, // TODO TEST
        //WRITE
        SWAP_I =        {4'd8, 1'b0, 1'b0},
        SEND_SWAP_I =   {4'd9, 1'b0, 1'b1},
        WAIT_SWAP_I =   {4'd10, 1'b0, 1'b1},
        SWAP_J =        {4'd11, 1'b0, 1'b0},
        SEND_SWAP_J =   {4'd12, 1'b0, 1'b1},
        WAIT_SWAP_J =   {4'd13, 1'b0, 1'b1},
        DONE =          {4'd14, 1'b1, 1'b0}


    } state;

    logic [7:0] addr = 8'b0;
    logic [7:0] i = 8'b0;
    logic [7:0] j = 8'b0;
    logic [7:0] i_data = 8'b0;
    logic [7:0] j_data = 8'b0;
    logic [7:0] imod = 2'b0;

    assign wren = state[0];
    assign Init_Finish = state[1];
    assign Address = addr;
    
    always_ff@(posedge clk or posedge rst) begin
        if (rst)begin
            state<=IDLE;
            addr<= 8'b0;
            data <= 8'b0;
            i <= 8'b0;
            j <= 8'b0;
            i_data <= 8'b0;
            j_data <= 8'b0;
            imod <= 2'b0;
        end
        else begin
            case(state)
                IDLE:begin 
                    if (In_Start) state <= START;
                    addr<= 8'b0;
                    data <= 8'b0;
                    i <= 8'b0;
                    j <= 8'b0;
                    i_data <= 8'b0;
                    j_data <= 8'b0;
                    imod <= 2'b0;
                        end

                START:begin
                    state <= SEND_ADDR_I;
                end

                INC_I:begin 
                    i <= i + 8'd1;
                    state <= SEND_ADDR_I;
                end

            //READING
                SEND_ADDR_I:begin      
                    addr <= i; //retrieve s[i] 
                    state <= WAIT_ADDR_I; 
                end 
                
                WAIT_ADDR_I: begin
                    imod <= i%3;
                    state <= COMPUTE_J;
                end

                COMPUTE_J:begin  //next clk cycle q should hold address value at this point
                    i_data <= q;
                    if (imod == 0) j <= j + q + Secret_Key[23:16];
                    else if (imod == 1) j <= j + q + Secret_Key[15:8];
                    else j <= j + q + Secret_Key[7:0];
                    state <= SEND_ADDR_J;
                end

                SEND_ADDR_J:begin
                    addr <= j;
                    state <= WAIT_ADDR_J;
                end

                WAIT_ADDR_J: begin
                    state <= SWAP_I;
                end

            //WRITING
                SWAP_I: begin
                    j_data <= q;
                    addr <= i;
                    data <= q;
                    state <= SEND_SWAP_I;
                end

                SEND_SWAP_I: begin //wren HIGH
                    state <= SWAP_J;
                end


                // WAIT_SWAP_I: begin //wren HIGH, wait a clck cycle TODO take out maybe?
                //     state <= SWAP_J;
                // end

                SWAP_J: begin //wren LOW
                    addr <= j;
                    data <= i_data;
                    state <= SEND_SWAP_J;

                end
                SEND_SWAP_J: begin //wren HIGH
                    // state <= WAIT_SWAP_J;
                    if (i ==  8'd255)
                        state <= DONE;
                    else 
                        state <= INC_I;
                end

                // WAIT_SWAP_J: begin //wren HIGH, wait a clk cycle TODO take out maybe?
                //      if (i ==  8'd255)
                //         state <= DONE;
                //     else 
                //         state <= INC_I;
                   
                // end

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