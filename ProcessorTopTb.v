`include "ProcessorTop.v"

module ProcessorTopTb;

// Inputs
reg clk;
reg rst_n;

// Instantiate the Unit Under Test (UUT)
ProcessorTop uut (
	.clk(clk), 
	.rst_n(rst_n)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("ProcessorTopTb.vcd");
    $dumpvars(0, ProcessorTopTb);
	clk = 1'b1;
	rst_n = 1'b0;
	#30
	rst_n = 1'b1;
	#70	
	$finish;
end
      
endmodule