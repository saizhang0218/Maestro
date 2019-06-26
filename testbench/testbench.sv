module testbench;

    // Inputs
    reg clk;
    reg reset;
    reg a;
    reg b;
    //reg cin;
    reg clean;
    // Outputs
    wire s;
    //wire cout;

    // Instantiate the Unit Under Test (UUT)
    adder uut (
        .clk(clk), 
        .reset(reset), 
        .a(a), 
        .b(b), 
        //.cin(cin), 
        .clean(clean), 
        .s(s) 
        //.cout(cout)
    );

//generate clock with 10 ns clock period.
    always
        #5 clk = ~clk;
        
    initial begin
        // Initialize Inputs
        clk = 1;
        reset = 0;
        a = 0;
        b = 0;
        //cin = 0;
        reset = 1;  
        clean = 1;
        #20;
        reset = 0;
        clean = 0;
        //add two 4 bit numbers, 1111 + 1101 = 11101
        a = 1; b = 1;  #10;
        a = 1; b = 0;  #10;
        a = 1; b = 1;  #10;
        a = 1; b = 1;  #10;
        a = 1; b = 1;  #270; 
        clean = 1;
        #10;
        clean = 0;
        //add two 5 bit numbers, 11011 + 10001 = 101101
        a = 1; b = 0;  #10;
        a = 0; b = 1;  #10;
        a = 1; b = 1;  #10;
        a = 1; b = 1;  #10;
        a = 0; b = 0;  #270;
        clean = 1;
        #10;

    end
      
endmodule
