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


module adder_tree(
    input         clk          ,
    input         reset        ,
    input         clean        ,
    input  [7:0]  inputs       ,
    output result
    );
wire [5:0] inter_result;
reg clean_delay,clean_delay_delay;

// then pass the input_h_trees to the bit serial tree adder
always@(posedge clk or posedge reset) 
begin
    if (reset) begin
        {clean_delay,clean_delay_delay} <= 'b0;
    end
    else begin
        clean_delay <= clean;
        clean_delay_delay <= clean_delay;
    end
end

adder part0(.clk(clk),.reset(reset),.clean(clean),.a(inputs[7]),.b(inputs[6]),.s(inter_result[3]));   
adder part1(.clk(clk),.reset(reset),.clean(clean),.a(inputs[5]),.b(inputs[4]),.s(inter_result[2]));   
adder part2(.clk(clk),.reset(reset),.clean(clean),.a(inputs[3]),.b(inputs[2]),.s(inter_result[1]));   
adder part3(.clk(clk),.reset(reset),.clean(clean),.a(inputs[1]),.b(inputs[0]),.s(inter_result[0]));   
adder part4(.clk(clk),.reset(reset),.clean(clean_delay),.a(inter_result[3]),.b(inter_result[2]),.s(inter_result[4]));   
adder part5(.clk(clk),.reset(reset),.clean(clean_delay),.a(inter_result[1]),.b(inter_result[0]),.s(inter_result[5]));   
adder part6(.clk(clk),.reset(reset),.clean(clean_delay_delay),.a(inter_result[4]),.b(inter_result[5]),.s(result));   

endmodule
