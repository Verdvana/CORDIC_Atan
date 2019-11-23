//------------------------------------------------------------------------------
//
//Module Name:					CordicAtan.v
//Department:					Xidian University
//Function Description:	   直角坐标求反正切值
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana		Verdvana		Verdvana		  			2019-11-23
//
//-----------------------------------------------------------------------------------


module CordicAtan #(
		parameter 	DATA_WIDTH = 16,					//输入数据宽度
						CYCLES	  = 3  					//迭代次数：最多迭代2**CYCLES次
)(
		input 									clk, 		//时钟
		input 									rst_n, 	//异步复位
		input 									en, 		//使能
		
		input signed  [DATA_WIDTH-1:0]	x, y, 	//输入坐标（有符号）
		
		output signed [DATA_WIDTH-1:0] 	out_atan	//求得反正切值
); 


	parameter DATA_NUM = 2**CYCLES;

	//=====================================================
	//迭代计数器:最多迭代2**CYCLES次
	
	reg [CYCLES-1:0] 		cnt_cycles;
	
	always_ff@(posedge clk or negedge rst_n) begin
		
		if(!rst_n) 
			cnt_cycles <= '0;
		
		else
			cnt_cycles <= cnt_cycles + 1;
	
	end
	
	
	//=====================================================
	//迭代循环
	
	reg signed [DATA_WIDTH-1:0]	x_cycles, y_cycles;	//迭代中间变量
	reg  [DATA_WIDTH-1:0]			z;							//旋转角度
	wire [DATA_NUM-1:0] 				z_w;						//ROM中角度数据
	
	always_ff@(posedge clk or negedge rst_n) begin
	
		if(!rst_n) begin
		
			x_cycles <= '0;
			y_cycles <= '0;
			z			<= 0;
			
		end
		
		else begin
		
			if(cnt_cycles=='0) begin			//第0个循环，输入数据初始化
				
				x_cycles <= x;
				y_cycles <= y;
				z			<= '0 ;
			
			end
			
			else begin
			
				if(y_cycles == '0) begin		//如果y坐标为0即为迭代完毕，数据保持不变	
					
					x_cycles <= x_cycles;
					y_cycles <= y_cycles;
					z			<= z ;
				
				end
			
				else if(y_cycles[DATA_WIDTH-1] == 0) begin	//如果y左边大于0，继续正向旋转（顺时针）
					
					x_cycles <= x_cycles + (y_cycles>>>(cnt_cycles-1));
					y_cycles <= y_cycles - (x_cycles>>>(cnt_cycles-1));
					z			<= z + z_w;
					
				end
				
				else begin												//如果y左边小于0，反向旋转（逆时针）
					
					x_cycles <= x_cycles + ((-y_cycles)>>>(cnt_cycles-1));
					y_cycles <= y_cycles + (x_cycles>>>(cnt_cycles-1));
					z			<= z - z_w;
					
				end			
				
			end
		
		end
		
	end
	
	
	//======================================================
	//反正切角度输出
	
	assign out_atan = z;
	
	//======================================================
	//Intel 1-Port ROM 
	//存储atan(θ)=2^(-i)中的θ
	
	ROM_Atan	ROM_Atan_inst (
	.address ( cnt_cycles ),	//地址
	.clock ( clk ),				//时钟
	.q ( z_w )						//数据
	);	
			


endmodule 