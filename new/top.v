`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2019 02:26:31 PM
// Design Name: 
// Module Name: adder_tree
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input         clk          ,
    input         reset        ,
    input  [7:0] control       , // this is the select signal for each outputs of the systolic arrays
    input  [8-1:0] output_sa0,output_sa1,output_sa2,output_sa3,output_sa4,output_sa5,output_sa6,output_sa7,
    //input  [31:0] added_const, multi_const,
    output [7:0] result
    );
wire [7:0] input_h_trees0,input_h_trees1,input_h_trees2,input_h_trees3,input_h_trees4,input_h_trees5,input_h_trees6,input_h_trees7;
wire [7:0] result_inter0,result_inter1,result_inter2,result_inter3;
assign input_h_trees0 = output_sa0 & {(8){control[0]}};
assign input_h_trees1 = output_sa1 & {(8){control[1]}};
assign input_h_trees2 = output_sa2 & {(8){control[2]}};
assign input_h_trees3 = output_sa3 & {(8){control[3]}};
assign input_h_trees4 = output_sa4 & {(8){control[4]}};
assign input_h_trees5 = output_sa5 & {(8){control[5]}};
assign input_h_trees6 = output_sa6 & {(8){control[6]}};
assign input_h_trees7 = output_sa7 & {(8){control[7]}};
// then pass the input_h_trees to the bit serial tree adder
/*
always@(posedge clk or posedge reset)
begin
    if(reset == 1) begin //active high reset
        input_h_trees0,input_h_trees1,input_h_trees2,input_h_trees3,input_h_trees4,input_h_trees5,input_h_trees6,input_h_trees7;
    end else begin

    end 
end
*/
adder_tree_set set0(.clk(clk),.reset(reset),.input_h_trees7(input_h_trees7),.input_h_trees6(input_h_trees6),.input_h_trees5(input_h_trees5),.input_h_trees4(input_h_trees4),.input_h_trees3(input_h_trees3),.input_h_trees2(input_h_trees2),.input_h_trees1(input_h_trees1),.input_h_trees0(input_h_trees0),.result(result));   
//adder_tree_set set1(.clk(clk),.reset(reset),.inputs7(input_h_trees7),.inputs6(input_h_trees6),.inputs5(input_h_trees5),.inputs4(input_h_trees4),.inputs3(input_h_trees3),.inputs2(input_h_trees2),.inputs1(input_h_trees1),.inputs0(input_h_trees0),.result(result_inter0));   
//adder_tree_set set2(.clk(clk),.reset(reset),.inputs7(input_h_trees7),.inputs6(input_h_trees6),.inputs5(input_h_trees5),.inputs4(input_h_trees4),.inputs3(input_h_trees3),.inputs2(input_h_trees2),.inputs1(input_h_trees1),.inputs0(input_h_trees0),.result(result_inter0));   
//adder_tree_set set3(.clk(clk),.reset(reset),.inputs7(input_h_trees7),.inputs6(input_h_trees6),.inputs5(input_h_trees5),.inputs4(input_h_trees4),.inputs3(input_h_trees3),.inputs2(input_h_trees2),.inputs1(input_h_trees1),.inputs0(input_h_trees0),.result(result_inter0));   


endmodule
