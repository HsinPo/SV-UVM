module top;
  logic clk;
  logic [7:0] counter;


  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    counter = 0;
    repeat (10) @(posedge clk) begin
      counter = counter + 1;
    end
    
    $display("Test Finished!");
    $finish;
  end
endmodule