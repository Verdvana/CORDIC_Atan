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
//
//Version	Modified History
//V1.0		输入第一象限直角坐标，通过最高8次迭代，求出反正切角，精度为1°。
//
//V1.1		输入的坐标扩大到四个象限，并且为了提高精度需要提前左移N位，这样得出的结果也是左移N位的。
//				迭代次数最高24次。
//				精度<0.05°
//				求出的角度范围为0-360°。
//-----------------------------------------------------------------------------------


module CordicAtan #(
		parameter 	DATA_WIDTH = 32,					//输入数据宽度
						EXPAND_BIT = 16,					//输入放大左移位数
						CYCLES	  = 5  					//迭代次数：最多迭代2**CYCLES次
)(
		input 									clk, 		//时钟
		input 									rst_n, 	//异步复位
		
		input signed  [DATA_WIDTH-1:0]	x, y, 	//输入坐标（有符号）
		
		output									valid,	//输出有效
		output        [DATA_WIDTH-1:0] 	atan		//求得反正切值
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
	
	reg signed  [DATA_WIDTH-1:0]	x_cycles, y_cycles;	//迭代中间变量寄存器
	reg         [DATA_WIDTH-1:0]	z;							//旋转角度寄存器
	reg									valid_r;					//输出有效寄存器
	
	wire        [DATA_WIDTH-1:0] 	z_w;						//ROM中角度数据

	
	always_ff@(posedge clk or negedge rst_n) begin
	
		if(!rst_n) begin
		
			x_cycles <= '0;
			y_cycles <= '0;
			z			<= 0;
			valid_r  <= 0;
			
		end
		
		else begin
		
			if(cnt_cycles=='0) begin			//第0个循环，输入数据初始化
				
				case ({x[DATA_WIDTH-1],y[DATA_WIDTH-1]})		//判断象限
				
					2'b00: begin										//1象限
					
								x_cycles <= x;
								y_cycles <= y;
								z			<= '0;
								
					end
					
					2'b10: begin										//2象限
					
								x_cycles <= y;
								y_cycles <= -x;
								z			<= (90 << (EXPAND_BIT)) ;
					
					end
					
					2'b11: begin										//3象限
					
								x_cycles <= -x;
								y_cycles <= -y;
								z			<= (180 << (EXPAND_BIT)) ;
					
					end
					
					2'b01: begin										//4象限
					
								x_cycles <= -y;
								y_cycles <= x;
								z			<= (270 << (EXPAND_BIT)) ;
					
					end
					
				endcase	
		
				valid_r  <= 0;
			
			end
			
			else begin
			
				if(y_cycles == '0) begin		//如果y坐标为0即为迭代完毕，数据保持不变	
					
					x_cycles <= x_cycles;
					y_cycles <= y_cycles;
					z			<= z ;
					valid_r  <= 1;
				
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
	assign valid = valid_r;				//输出有效
	assign atan = valid_r ? z : 'z;	//反正切角
	
	//======================================================
	//Intel 1-Port ROM 
	//存储atan(θ)=2^(-i)中的θ
	
	ROM_Atan	ROM_Atan_inst (
	.address ( cnt_cycles ),	//地址
	.clock ( clk ),				//时钟
	.q ( z_w )						//数据
	);	
			


endmodule 