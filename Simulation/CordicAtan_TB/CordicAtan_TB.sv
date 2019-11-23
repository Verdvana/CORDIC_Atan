`timescale 1ns/1ns

module CordicAtan_TB;

reg clk;
reg rst_n;

reg en;



reg signed [15:0] x;
reg signed [15:0] y;


wire [15:0] out_atan;

CORDIC #(
		.DATA_WIDTH(16),
		.CYCLES(3) 
)u_CORDIC(
		.clk(clk), 
		.rst_n(rst_n), 
		.en(en), 
		
		.x(x), 
		.y(y), 
		
		.out_atan(out_atan)
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
	en <= 0;
	x <= 16'd100;
	y <= 16'd20;
end
endtask

initial
begin
	task_sysinit;
	task_rst;
	#10;
	

	
	
	
	
	
	
	
end

endmodule
