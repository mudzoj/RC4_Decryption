// fsm_mux.sv - SystemVerilog multiplexer for selecting FSM output based on Mem_sel

module FSM_MUX #(
    parameter WIDTH = 8 // width of each FSM output bus
)(
    input  logic [2:0]             Mem_sel,        // select one of eight FSMs
    
    input  logic init_wren,
    input  logic [WIDTH-1:0]       init_data,
    input  logic [WIDTH-1:0]       init_Address,

    input  logic shuffleA_wren,
    input  logic [WIDTH-1:0]       shuffleA_data,
    input  logic [WIDTH-1:0]       shuffleA_Address,

    input  logic shuffleB_wren,
    input  logic [WIDTH-1:0]       shuffleB_data,
    input  logic [WIDTH-1:0]       shuffleB_Address,

    input  logic decrypt_wren,
    input  logic [WIDTH-1:0]       decrypt_data,
    input  logic [WIDTH-1:0]       decrypt_Address,

    output  logic selected_wren,
    output logic [WIDTH-1:0]       selected_data,
    output logic [WIDTH-1:0]       selected_Address
);

    // Local parameters for each Mem_sel value
    localparam INIT_START_IDX      = 3'd0;
    localparam INIT_WAIT_IDX       = 3'd1;
    localparam SHUFFLEA_START_IDX  = 3'd2;
    localparam SHUFFLEA_WAIT_IDX   = 3'd3;
    localparam SHUFFLEB_START_IDX  = 3'd4;
    localparam SHUFFLEB_WAIT_IDX   = 3'd5;
    localparam DECRYPT_START_IDX   = 3'd6;
    localparam DECRYPT_WAIT_IDX    = 3'd7;

    // Combinational multiplexer
    always_comb begin
        case (Mem_sel)
            INIT_START_IDX:begin
                selected_wren = init_wren;
                selected_data = init_data;
                selected_Address= init_Address;
            end
            INIT_WAIT_IDX:begin
                selected_wren = init_wren;
                selected_data = init_data;
                selected_Address= init_Address;
            end
            SHUFFLEA_START_IDX:begin
                selected_wren = shuffleA_wren;
                selected_data = shuffleA_data;
                selected_Address= shuffleA_Address;
            end
            SHUFFLEA_WAIT_IDX:begin
                selected_wren = shuffleA_wren;
                selected_data = shuffleA_data;
                selected_Address= shuffleA_Address;
            end
            SHUFFLEB_START_IDX:begin
                selected_wren = shuffleB_wren;
                selected_data = shuffleB_data;
                selected_Address= shuffleB_Address;
            end
            SHUFFLEB_WAIT_IDX:begin
                selected_wren = shuffleB_wren;
                selected_data = shuffleB_data;
                selected_Address= shuffleB_Address;
            end
            DECRYPT_START_IDX:begin
                selected_wren = decrypt_wren;
                selected_data = decrypt_data;
                selected_Address= decrypt_Address;
            end
            DECRYPT_WAIT_IDX:begin
                selected_wren = decrypt_wren;
                selected_data = decrypt_data;
                selected_Address= decrypt_Address;
            end
            default:begin
                selected_wren = '0;
                selected_data = '0;
                selected_Address= '0;
            end // safe default
        endcase
    end

endmodule
