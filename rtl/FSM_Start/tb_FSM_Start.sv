`default_nettype none

module tb_FSM_Start;

  logic clk;
  logic rst;
  logic start;

  FSM_Start dut (
    .clk(clk),
    .rst(rst),
    .start(start)
  );

  always #5 clk = ~clk;


  initial begin

    clk = 0;
    rst = 1;
    #10;


    rst = 0;
    #10;


    repeat (7) begin
      #10;

    end

    $finish;
  end

endmodule
`default_nettype wire
