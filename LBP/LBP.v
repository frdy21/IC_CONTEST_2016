//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 	2016 IC CONTEST
// 	Project	:	 Local Binary E ncoder
// 	Author	: 	Zheng-Wei Hong (td2100106@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 	File Name	:	LBP.v
// 	Module Name	:	LBP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`timescale 1ns/10ps

module LBP(  clk,reset,gray_addr,gray_req,gray_ready,gray_data,lbp_addr,lbp_valid,lbp_data,finish );

input		clk;
input		reset;
input		gray_ready;
input		[7:0]		gray_data;

output	gray_req;
output	lbp_valid;
output	finish;
output	[7:0]		lbp_data;
output	[13:0]		gray_addr;
output	[13:0]		lbp_addr;

reg                 finish;
reg                 gray_req;
reg					lbp_valid;
reg		[2:0]		current_state;
reg		[2:0]	    next_state;
reg		[7:0]		LBP_MEMORY_BIT	[0:7];
reg		[7:0]		LBP_MEMORY	[0:9];
reg     [7:0]       lbp_data;
reg		[8:0]		lbp_data_tmp;
reg     [13:0]      gray_addr;
reg     [13:0]      lbp_addr;
reg     [13:0]      gray_addr_const;
reg     [13:0]      gray_addr_zero;

integer i;

parameter	state0=3'd0;
parameter	state1=3'd1;
parameter	state2=3'd2;
parameter	state3=3'd3;
parameter	state4=3'd4;

/*	FINITE STATE MACHINE	*/

always@(	posedge clk	or	posedge reset	)
		begin
				if(	reset	)
						current_state	<=	state0;
				else
						current_state	<=	next_state;
		end

always@(*)
		begin
				case(	current_state	)
						state0:next_state	<=	(	gray_ready	==	1'd0 )?state0:state1;
						state1:next_state	<=	(	gray_req	==	1'd1	)?state1:state2;
						state2:next_state	<=	(	lbp_data_tmp	==	9'd256	)?state2:state3;
						state3:next_state	<=	(	lbp_addr	==	14'd16253	)?state4:state0;
						state4:next_state	<=	(	finish	==	1'd0	)?state4:state0;
						default:
						begin
						      next_state  <=  state0;
						end
				endcase
		end

/*	INITIIALIZATION	*/

always@(	posedge clk	or	posedge reset	)
		begin
				if(	reset	)
						begin
								gray_req	<=	1'd1;
								
						end
				else
						begin
								case(	state0	)
										state0:
												if(	gray_ready	==	1'd1	&&	LBP_MEMORY[8]	==	8'd0	)
														begin
																gray_req	<=	1'd1;
														end
												else
														begin
																gray_req	<=	1'd0;
														end
								default:
										begin
												gray_req	<=	1'd0;
												
										end
								endcase
						end
		end

/*	READ DATA	*/

always@(	posedge clk	or	posedge reset	)
		begin
				if(	reset	)
						begin
								gray_addr_const	<=	14'd129;
								for(i=0;i<10;i=i+1)
										begin
												LBP_MEMORY[i]	<=	8'd0;
										end
						end
				else 
						begin
								case(	current_state	)
								state1:
										if(	LBP_MEMORY[0]	==	8'd0   )
												begin
														gray_addr	=	gray_addr_const	-	14'd129;
														LBP_MEMORY[0]	=	gray_data;
												end
										else if(	LBP_MEMORY[1]	==	8'd0 )
												begin
														gray_addr	=	gray_addr_const	-	14'd128;
														LBP_MEMORY[1]	=	gray_data;
												end
										else if(	LBP_MEMORY[2]	==	8'd0)
												begin
														gray_addr	=	gray_addr_const	-	14'd127;
														LBP_MEMORY[2]	=	gray_data;
												end
										else if(	LBP_MEMORY[3]	==	8'd0)
												begin
														gray_addr	=	gray_addr_const	-	14'd1;
														LBP_MEMORY[3]	=	gray_data;
												end
										else if(	LBP_MEMORY[4]	==	8'd0)
												begin
														gray_addr	=	gray_addr_const;
														LBP_MEMORY[4]	=	gray_data;
												end
										else if(	LBP_MEMORY[5]	==	8'd0)
												begin
														gray_addr	=	gray_addr_const	+	14'd1;
														LBP_MEMORY[5]	=	gray_data;
												end
										else if(	LBP_MEMORY[6]	==	8'd0 )	
												begin
														gray_addr	=	gray_addr_const	+	14'd127;
														LBP_MEMORY[6]	=	gray_data;
												end
										else if(	LBP_MEMORY[7]	==	8'd0 )
												begin
														gray_addr	=	gray_addr_const	+	14'd128;
														LBP_MEMORY[7]	=	gray_data;
												end
										else if(	LBP_MEMORY[8]	==	8'd0 )
												begin
														gray_addr	=	gray_addr_const	+	14'd129;
														LBP_MEMORY[8]	=	gray_data;
												end
										else if(	LBP_MEMORY[9]	==	8'd0 )
												begin
														gray_addr	=	gray_addr_const	+	14'd129;
														LBP_MEMORY[9]	=	gray_data;
												end
										else if(	gray_addr_const	!=	14'd16254	&&	(	(	gray_addr_const	+	14'd2	)	%	128	)	==	14'd0	)
												begin
														gray_addr_const	=	gray_addr_const	+14'd3;
												end
										else
												begin
														gray_addr_const	=	gray_addr_const	+14'd1;
												end
								default:
										begin
												for(i=0;i<10;i=i+1)
														begin
																LBP_MEMORY[i]	<=	8'd0;		
														end
										end
								endcase
						end
		end

/*	COMPUTATION	*/

always@(	posedge clk	or	posedge reset	)
		begin
				if(	reset	)
						begin
								lbp_data_tmp	<=	9'd256;
								LBP_MEMORY_BIT[0]	<=	8'd0;
								LBP_MEMORY_BIT[1]	<=	8'd0;
								LBP_MEMORY_BIT[2]	<=	8'd0;
								LBP_MEMORY_BIT[3]	<=	8'd0;
								LBP_MEMORY_BIT[4]	<=	8'd0;
								LBP_MEMORY_BIT[5]	<=	8'd0;
								LBP_MEMORY_BIT[6]	<=	8'd0;
								LBP_MEMORY_BIT[7]	<=	8'd0;

						end
				else
						begin
								case(	current_state	)
								state2:
										if(	lbp_data_tmp	==	9'd256	)
												begin
														LBP_MEMORY_BIT[0] = (LBP_MEMORY[5]<LBP_MEMORY[1] || LBP_MEMORY[5]==LBP_MEMORY[1])?8'd1:8'd0;
														LBP_MEMORY_BIT[1] = (LBP_MEMORY[5]<LBP_MEMORY[2] || LBP_MEMORY[5]==LBP_MEMORY[2])?8'd1:8'd0;
														LBP_MEMORY_BIT[2] = (LBP_MEMORY[5]<LBP_MEMORY[3] || LBP_MEMORY[5]==LBP_MEMORY[3])?8'd1:8'd0;
														LBP_MEMORY_BIT[3] = (LBP_MEMORY[5]<LBP_MEMORY[4] || LBP_MEMORY[5]==LBP_MEMORY[4])?8'd1:8'd0;
														LBP_MEMORY_BIT[4] = (LBP_MEMORY[5]<LBP_MEMORY[6] || LBP_MEMORY[5]==LBP_MEMORY[6])?8'd1:8'd0;
														LBP_MEMORY_BIT[5] = (LBP_MEMORY[5]<LBP_MEMORY[7] || LBP_MEMORY[5]==LBP_MEMORY[7])?8'd1:8'd0;
														LBP_MEMORY_BIT[6] = (LBP_MEMORY[5]<LBP_MEMORY[8] || LBP_MEMORY[5]==LBP_MEMORY[8])?8'd1:8'd0;
														LBP_MEMORY_BIT[7] = (LBP_MEMORY[5]<LBP_MEMORY[9] || LBP_MEMORY[5]==LBP_MEMORY[9])?8'd1:8'd0;
														lbp_data_tmp	=	LBP_MEMORY_BIT[0]+LBP_MEMORY_BIT[1]*2+LBP_MEMORY_BIT[2]*4+LBP_MEMORY_BIT[3]*8+LBP_MEMORY_BIT[4]*16+LBP_MEMORY_BIT[5]*32+LBP_MEMORY_BIT[6]*64+LBP_MEMORY_BIT[7]*128;
												end
										else
												begin
														lbp_data_tmp	<=		lbp_data_tmp;
												end
								default:
										begin
												lbp_data_tmp	<=	9'd256;
										end
								endcase
						end
		end
		
/*	OUTPUT	*/

always@(	posedge clk	or	posedge reset	)
		begin
				if(	reset	)
						begin
								lbp_data	<=	8'd0;
						end
				else
						begin
								case(	current_state	)
								state3:
										if(	lbp_valid	)
												begin
													lbp_data	<=	lbp_data_tmp[7:0];
													lbp_addr	<=	(	(gray_addr_const	-	14'd1)	%	128	==	14'd0	)?gray_addr_const	-	14'd3:gray_addr_const	-	14'd1;
												end
										else
												begin
														lbp_data	<=	lbp_data;
												end
								default:
										begin
												lbp_data	<=	lbp_data;
										end
								endcase
						end
		end
		
/*	LBP_VALID	*/

always@(	posedge clk 	or	posedge reset	)
		begin
				if(	reset	)
						begin
								lbp_valid	<=	1'd0;
						end
				else if(	gray_req	==	1'd0)
						begin
								lbp_valid	<= 1'd1;
						end
		end
		
/*	FINISH	*/

always@(	posedge clk	or	posedge reset	)
		begin
				if(	reset	)
						begin
								finish	<=	1'd0;
						end
				else
						begin
								case(	current_state	)
								state4:
										if(	lbp_addr	==	14'd16254	)
												finish	<=	1'd1;
										else
												finish	<=	finish;
								default:
										begin
												finish	<=	finish;
										end
								endcase
						end
		end
		
endmodule