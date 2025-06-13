`default_nettype none
module FSM_Get_Key(
    input logic clk,
    input logic rst, Crack_Start,
    output logic [23:0] Secret_Key,
    input logic Key_Valid,
    input logic Checker_Finish,
    output logic Check_Ack,
    output logic Control_Start,
    output logic [9:0] LEDR
    );

    enum logic[5:0]{
                // {#ID, Control_Start, Check_Ack}
        IDLE =           {4'd0, 1'b0, 1'b0},//0000 0 0  :00
        START =          {4'd1, 1'b1, 1'b0},//0001 1 0  :06
        NEXT_KEY=        {4'd2, 1'b0, 1'b1},//0010 0 1  :09
        SEND_KEY=        {4'd3, 1'b1, 1'b0},//0011 1 0  :0E
        WAIT_FOR_RESULT= {4'd4, 1'b0, 1'b0},//0100 0 0  :10
        TRY_NEXT_KEY =   {4'd5, 1'b0, 1'b0},//0101 0 0  :14
        DONE_VALID =     {4'd6, 1'b0, 1'b0},//0110 0 0  :18
        DONE_INVALID =   {4'd7, 1'b0, 1'b0} //0111 0 0  :1C
    } state;


    logic [21:0] Secret_Key_Instance = 22'h0;
    logic [9:0] LED = 10'b0;

    assign Secret_Key = {2'b0, Secret_Key_Instance};  //2 MSB's will be 0
    assign Check_Ack = state[0];
    assign Control_Start = state[1];
    assign LEDR = LED;

   always_ff @(posedge clk or posedge rst) begin
        if (rst)begin
            LED <= 10'b0;
            Secret_Key_Instance<= 22'h0;
            state<=IDLE;
            
        end
        else begin
            case(state)
                IDLE: 
                    if (Crack_Start) state <= START;

                START:begin         //Control Start is HIGH
                    Secret_Key_Instance <= 22'h0;
                    state <= SEND_KEY;
						  end

                NEXT_KEY:begin 
                    Secret_Key_Instance <= Secret_Key_Instance + 8'd1;
                    state <= SEND_KEY;
                    end

                SEND_KEY:                   //CHECK_ACK is HIGH
                    state <= WAIT_FOR_RESULT;   

                WAIT_FOR_RESULT: 
                    if(Checker_Finish)
                        if(Key_Valid) state <= DONE_VALID;
                        else state <= TRY_NEXT_KEY;
                    
                TRY_NEXT_KEY:begin
                    if (Secret_Key_Instance ==  22'h3FFFFF)state <= DONE_INVALID; 
                    else state <= NEXT_KEY;
                end

                DONE_VALID:begin
                    LED <= 10'b1;
                    state <= DONE_VALID;
                end

                
                DONE_INVALID:begin
                    LED <= 10'b10;
                    state <= DONE_INVALID;
                end

                default: state <= IDLE;
            endcase
        end

   end

endmodule
`default_nettype wire