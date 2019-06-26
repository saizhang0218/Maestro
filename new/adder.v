//serial adder for N bits. Note that we dont have to mention N here. 
module adder 
    (   input clk,reset,clean,  //clock and reset
        input a,b,  //note that cin is used for only first iteration.
        output reg s  //note that s comes out at every clock cycle and cout is valid only for last clock cycle.
        );

reg c;

always@(posedge clk or posedge reset)
begin
    if(reset == 1) begin //active high reset
        s <= 0;
        c <= 0;
    end
    else if (clean==1) begin
        c <= 0;
    end 
    else begin
        s <= a ^ b ^ c;  //SUM
        c <= (a & b) | (c & b) | (a & c);  //CARRY
    end 
end

endmodule 