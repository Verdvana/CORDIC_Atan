`timescale 1ns/1ns

module CordicAtan_TB;

reg clk;
reg rst_n;


reg signed [31:0] x;
reg signed [31:0] y;


wire [31:0] atan;

CORDIC #(
		.DATA_WIDTH(32),
		.EXPAND_BIT(16),
		.CYCLES(5) 
)u_CORDIC(
		.clk(clk), 
		.rst_n(rst_n), 
		
		.x(x), 
		.y(y), 
		
		.atan(atan)
); 

initial begin

	clk = 0;
	forever #(10) 
	clk = ~clk;
	
end

task task_rst;
begin
	rst_n <= 0;
	repeat(2)@(negedge clk);
	rst_n <= 1;
end
endtask

task task_sysinit;
begin
	x <= 32'd655360;
	y <= -32'd1310720;
end
endtask

initial
begin
	task_sysinit;
	task_rst;
	#10;
	

	
	
	
	
	
	
	
end

endmodule
