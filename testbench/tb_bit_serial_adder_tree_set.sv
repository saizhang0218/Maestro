module tb_bit_serial_adder_tree_set;

	logic       clk                     ;
	logic       reset                   ;
	logic       enable                  ;
	logic       [7:0] inputs7           = 'b0;
	logic       [7:0] inputs6           = 'b0;
	logic       [7:0] inputs5           = 'b0;
	logic       [7:0] inputs4           = 'b0;
	logic       [7:0] inputs3           = 'b0;
	logic       [7:0] inputs2           = 'b0;
	logic       [7:0] inputs1           = 'b0;
	logic       [7:0] inputs0           = 'b0;
	wire        result_en                    ;
    wire        [7:0] result                 ;

	int         time_cnt           = 0  ;
	reg   [1:0] mac_en_dly         = 'b0;

    adder_tree_set  i_mac (
            .clk               (clk             ),
            .reset             (reset           ),
            .enable            (enable          ),
            .input_h_trees7    (inputs7    ),
            .input_h_trees6    (inputs6    ),
            .input_h_trees5    (inputs5    ),
            .input_h_trees4    (inputs4    ),
            .input_h_trees3    (inputs3    ),
            .input_h_trees2    (inputs2    ),
            .input_h_trees1    (inputs1    ),
            .input_h_trees0    (inputs0    ),
            .result_en         (result_en  ),
            .result            (result     )
     );

	initial begin
	  $dumpfile("test.vcd");
	  $dumpvars;
	end

	initial begin
		clk = 1;
		forever #5 clk = ~clk;
	end

	initial begin
		reset = 1'b0;
		enable = 1'b0;
		@(posedge clk);
		reset = 1'b1;
		@(posedge clk);
		reset = 1'b0;
	end

	// serial part
	task automatic get_clk();
		@(posedge clk);
	endtask : get_clk


	task automatic put_data_i(input data, input int var_index);
	    if(var_index == 0) begin inputs0[7:0] = {(8){data}};  end
	    if(var_index == 1) begin inputs1[7:0] = {(8){data}};  end
	    if(var_index == 2) begin inputs2[7:0] = {(8){data}};  end
	    if(var_index == 3) begin inputs3[7:0] = {(8){data}};  end
	    if(var_index == 4) begin inputs4[7:0] = {(8){data}};  end
	    if(var_index == 5) begin inputs5[7:0] = {(8){data}};  end
	    if(var_index == 6) begin inputs6[7:0] = {(8){data}};  end
	    if(var_index == 7) begin inputs7[7:0] = {(8){data}};  end
		@(posedge clk);
	endtask : put_data_i

	task automatic get_result_bit(output logic result_0,output logic result_1,output logic result_2,output logic result_3,output logic result_4,output logic result_5,output logic result_6,output logic result_7);
		@(posedge clk);
		result_0 = result[0];
		result_1 = result[1];
		result_2 = result[2];
		result_3 = result[3];
		result_4 = result[4];
		result_5 = result[5];
		result_6 = result[6];
		result_7 = result[7];
		//$display($stime, "timer = %d, result_o = %b", time_cnt, result_o);
	endtask : get_result_bit
	
	
	task automatic put_reset(input reset_in);
        reset     = reset_in;
        @(posedge clk);
    endtask : put_reset
    
	task automatic shift_input_in(input logic [7:0] input_var, input int index);
        for (int i = 0; i < 8; i++) begin
            put_data_i(.data(input_var[i]), .var_index(index));
        end
        for (int i = 8; i < 32; i++) begin
            put_data_i(.data(input_var[7]), .var_index(index));
        end
    endtask : shift_input_in

	task automatic shift_enable(input int input_bit);
	    if(input_bit == 1) begin
		    for (int i = 0; i < 32; i++) begin
		    	put_enable(.enable_in(1'b1));
		    end
		end
	    if(input_bit == 0) begin
            for (int i = 0; i < 32; i++) begin
                put_enable(.enable_in(1'b0));
            end
        end		
	endtask : shift_enable

	task automatic put_enable(input enable_in);
		enable     = enable_in;
		@(posedge clk);
	endtask : put_enable
	
	task automatic get_result(output logic [31:0] result_0,output logic [31:0] result_1,output logic [31:0] result_2,output logic [31:0] result_3,output logic [31:0] result_4,output logic [31:0] result_5,output logic [31:0] result_6,output logic [31:0] result_7);	 
		for (int i = 0; i < 32; i = i+1) begin
	        get_result_bit(.result_0(result_0[i]),.result_1(result_1[i]),.result_2(result_2[i]),.result_3(result_3[i]),.result_4(result_4[i]),.result_5(result_5[i]),.result_6(result_6[i]),.result_7(result_7[i]));
			//$display($stime, " get result bit %d = %b", i, result_o[i]);
	    end
	endtask : get_result

	task automatic check_32(input logic [31:0] golden, input logic [31:0] check_result, input string err_msg="");
		if(golden !== check_result) begin
			$error($stime, " Error golden %d != got %d", golden, check_result);
			$finish;
		end
		else begin
			$display($stime, " (golden) %d == (result) %d", golden, check_result);
		end
	endtask : check_32


	int check_queue[$];
	int result_queue0[$];
	int result_queue1[$];
	int result_queue2[$];
	int result_queue3[$];
	int result_queue4[$];
	int result_queue5[$];
	int result_queue6[$];
	int result_queue7[$];

	initial begin
		int  check_result0 = 0;
		int  check_result1 = 0;
		int  check_result2 = 0;
		int  check_result3 = 0;
		int  check_result4 = 0;
		int  check_result5 = 0;
		int  check_result6 = 0;
		int  check_result7 = 0;
		int  new_w;
		int  new_data;
		logic [7:0] low_w;
		logic [7:0] low_data;
		int  golden_mac = 0;
		int indicator_in = 0;
		int indicator_out = 0;
        int input_a;
        int input_b;
        put_reset(.reset_in(1'b1));
        //put_clean(.clean_in(1'b1));
		#100;
		get_clk();



        fork
            begin
               #20;
            end
            begin
		    for(input_a=-10; input_a<10; input_a++) begin
		    	for(input_b=-10; input_b<10; input_b++) begin
		    		 //input_a = -10;
		    		 //input_b = -10;
		    		 fork
		    		    put_reset(.reset_in(1'b0));
		    		 	shift_enable(.input_bit(1));
		    		    shift_input_in(.input_var(input_a),.index(0));
		    		    shift_input_in(.input_var(input_b),.index(1));
		    		    shift_input_in(.input_var(input_a),.index(2));
                        shift_input_in(.input_var(input_b),.index(3));			
		    		    shift_input_in(.input_var(input_b),.index(4));
                        shift_input_in(.input_var(input_b),.index(5));
                        shift_input_in(.input_var(input_b),.index(6));
                        shift_input_in(.input_var(input_a),.index(7));    
		    		 join
		    		 $display(" %4d + %4d + %4d + %4d + %4d + %4d + %4d + %4d = %4d", input_a, input_b, input_a, input_b, input_b, input_b, input_b, input_a, input_a + input_b + input_a + input_b + input_b + input_b + input_b + input_a);
		    		 golden_mac = input_a + input_b + input_a + input_b + input_b + input_b + input_b + input_a;
		    		 //$display($stime, " push check=%d", golden_mac);
		    		 check_queue.push_back(golden_mac);
		    		 //get_result(check_result);
                     //$display($stime, " result=%d", check_result);
		    	end
		    end
		    shift_enable(.input_bit(0));
		    end
        join_any
 
            begin
                forever begin
                    //get_result(check_result,indicator_in,indicator_out);
                    //$display(" indicator_in=%d, indicator_out=%d", indicator_in, indicator_out);
                    //indicator_in = indicator_out;
                    get_result(check_result0,check_result1,check_result2,check_result3,check_result4,check_result5,check_result6,check_result7);
                    result_queue0.push_back(check_result0);
                    result_queue1.push_back(check_result1);
                    result_queue2.push_back(check_result2);
                    result_queue3.push_back(check_result3);
                    result_queue4.push_back(check_result4);
                    result_queue5.push_back(check_result5);
                    result_queue6.push_back(check_result6);
                    result_queue7.push_back(check_result7);
                    if((result_queue0.size() != 0) && (check_queue.size() != 0)) begin
                        int pop_result;
                        int pop_check;
                        pop_result = result_queue0.pop_front();
                        pop_check  = check_queue.pop_front();
                        $display($stime, " pop check=%d, result=%d", pop_check, pop_result);
                        check_32(pop_check, pop_result);
                    end else begin
                        get_clk;
                    end
                end
            end
                           
		get_clk();
		$finish;
	end

endmodule