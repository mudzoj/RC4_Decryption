module Key_Selecter (
  input  logic         clk,
  input  logic         reset_n,

  // Core 1
  input  logic         Valid_Key_Found_cracker1,
  input  logic [23:0]  Secret_Key_Cracker_1,

  // Core 2
  input  logic         Valid_Key_Found_cracker2,
  input  logic [23:0]  Secret_Key_Cracker_2,

  // Core 3
  input  logic         Valid_Key_Found_cracker3,
  input  logic [23:0]  Secret_Key_Cracker_3,

  // Core 4
  input  logic         Valid_Key_Found_cracker4,
  input  logic [23:0]  Secret_Key_Cracker_4,

  // Selected outputs
  output logic [23:0]  Secret_Key_Selected,
  output logic [3:0]   Valid_Key_Found_rst
);

  always_comb begin
    // Default: no key found
    Secret_Key_Selected      = Secret_Key_Cracker_1;
    Valid_Key_Found_rst = 4'b0;

    // Priority encoder: Core1 → Core2 → Core3 → Core4
    if (Valid_Key_Found_cracker1) begin
      Valid_Key_Found_rst = 4'b1110;
      Secret_Key_Selected      = Secret_Key_Cracker_1;
    end
    else if (Valid_Key_Found_cracker2) begin
      Valid_Key_Found_rst = 4'b1101;
      Secret_Key_Selected      = Secret_Key_Cracker_2;
    end
    else if (Valid_Key_Found_cracker3) begin
      Valid_Key_Found_rst = 4'b1011;
      Secret_Key_Selected      = Secret_Key_Cracker_3;
    end
    else if (Valid_Key_Found_cracker4) begin
      Valid_Key_Found_rst = 4'b0111;
      Secret_Key_Selected      = Secret_Key_Cracker_4;
    end
  end
endmodule