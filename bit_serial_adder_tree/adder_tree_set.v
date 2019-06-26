`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2019 03:48:43 PM
// Design Name: 
// Module Name: adder_tree_set
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


module adder_tree_set(
    input         clk          ,
    input         reset        ,
    input         enable       ,
    input  [7:0] input_h_trees7,input_h_trees6,input_h_trees5,input_h_trees4,input_h_trees3,input_h_trees2,input_h_trees1,input_h_trees0,   // assume there are 8 trees, each tree has 8 inputs
    output  result_en       ,
    output [7:0] result
    );
    
    wire clean;
    wire [7:0] result_en_indi;
    reg [4:0] counter;
    reg enable_delay, enable_delay2,enable_delay3;
    always@(posedge clk or posedge reset)    begin
        if(reset == 1) begin //active high reset
            counter <= 'b0;
            {enable_delay,enable_delay2,enable_delay3} <= 'b0;
        end
        else begin
            counter <= counter + (enable == 1'b1);
            enable_delay <= enable;
            enable_delay2 <= enable_delay;
            enable_delay3 <= enable_delay2;
        end
    end
    assign clean = (counter == 5'b11111);
    assign result_en = enable_delay3;
    
    adder_tree adder0(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[0],input_h_trees6[0],input_h_trees5[0],input_h_trees4[0],input_h_trees3[0],input_h_trees2[0],input_h_trees1[0],input_h_trees0[0]}),.result(result[0]));   
    adder_tree adder1(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[1],input_h_trees6[1],input_h_trees5[1],input_h_trees4[1],input_h_trees3[1],input_h_trees2[1],input_h_trees1[1],input_h_trees0[1]}),.result(result[1]));   
    adder_tree adder2(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[2],input_h_trees6[2],input_h_trees5[2],input_h_trees4[2],input_h_trees3[2],input_h_trees2[2],input_h_trees1[2],input_h_trees0[2]}),.result(result[2]));   
    adder_tree adder3(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[3],input_h_trees6[3],input_h_trees5[3],input_h_trees4[3],input_h_trees3[3],input_h_trees2[3],input_h_trees1[3],input_h_trees0[3]}),.result(result[3]));   
    adder_tree adder4(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[4],input_h_trees6[4],input_h_trees5[4],input_h_trees4[4],input_h_trees3[4],input_h_trees2[4],input_h_trees1[4],input_h_trees0[4]}),.result(result[4]));   
    adder_tree adder5(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[5],input_h_trees6[5],input_h_trees5[5],input_h_trees4[5],input_h_trees3[5],input_h_trees2[5],input_h_trees1[5],input_h_trees0[5]}),.result(result[5]));   
    adder_tree adder6(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[6],input_h_trees6[6],input_h_trees5[6],input_h_trees4[6],input_h_trees3[6],input_h_trees2[6],input_h_trees1[6],input_h_trees0[6]}),.result(result[6]));   
    adder_tree adder7(.clk(clk),.reset(reset),.clean(clean),.inputs({input_h_trees7[7],input_h_trees6[7],input_h_trees5[7],input_h_trees4[7],input_h_trees3[7],input_h_trees2[7],input_h_trees1[7],input_h_trees0[7]}),.result(result[7]));   

endmodule
