module tb_bit_serial_adder_tree;

	logic       clk                     ;
	logic       reset                   ;
	logic       clean                   ;
	logic       [7:0] inputs           = 'b0;
    wire        result                  ;

	int         time_cnt           = 0  ;
	reg   [1:0] mac_en_dly         = 'b0;

    adder_tree  i_mac (
            .clk               (clk             ),
            .reset             (reset           ),
            .clean             (clean           ),
            .inputs             (inputs    ),
            .result             (result        )
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
	    inputs[var_index] = data;
		@(posedge clk);
	endtask : put_data_i

	task automatic get_result_bit(output logic result_o);
		@(posedge clk);
		result_o = result;
		//$display($stime, "timer = %d, result_o = %b", time_cnt, result_o);
	endtask : get_result_bit
	
	
	task automatic put_clean(input clean_in);
		clean     = clean_in;
		@(posedge clk);
	endtask : put_clean
	
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

	task automatic shift_clean();
		for (int i = 0; i < 32; i++) begin
			if(i == 31)                   put_clean(.clean_in(1'b1));
			else                          put_clean(.clean_in(1'b0));
		end
	endtask : shift_clean

	task automatic get_result(output logic [31:0] result_o);	 
		for (int i = 0; i < 32; i = i+1) begin
	        get_result_bit(.result_o(result_o[i]));
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
	int result_queue[$];

	initial begin
		int  check_result = 0;
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
        put_clean(.clean_in(1'b1));
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
		    		 	shift_clean();
		    		    shift_input_in(.input_var(input_a),.index(0));
		    		    shift_input_in(.input_var(input_b),.index(1));
		    		    shift_input_in(.input_var(input_a),.index(2));
                        shift_input_in(.input_var(input_b),.index(3));			
		    		    shift_input_in(.input_var(input_b),.index(4));
                        shift_input_in(.input_var(input_b),.index(5));
                        shift_input_in(.input_var(input_b),.index(6));
                        shift_input_in(.input_var(input_a),.index(7));    
		    		 join
		    		 $display(" %4d + %4d + %4d + %4d + %4d + %4d + %4d + %4d = %4d", input_a, input_b, input_a, input_b, input_b, input_b, input_b, input_a, (input_a + input_b) * 4);
		    		 golden_mac = input_a + input_b + input_a + input_b + input_b + input_b + input_b + input_a;
		    		 //$display($stime, " push check=%d", golden_mac);
		    		 check_queue.push_back(golden_mac);
		    		 //get_result(check_result);
                     //$display($stime, " result=%d", check_result);
		    	end
		    end
		    end
        join_any
 
 
 		
            begin
                forever begin
                    //get_result(check_result,indicator_in,indicator_out);
                    //$display(" indicator_in=%d, indicator_out=%d", indicator_in, indicator_out);
                    //indicator_in = indicator_out;
                    get_result(check_result);
                    result_queue.push_back(check_result);
                    if((result_queue.size() != 0) && (check_queue.size() != 0)) begin
                        int pop_result;
                        int pop_check;
                        pop_result = result_queue.pop_front();
                        pop_check  = check_queue.pop_front();
                        $display($stime, " pop check=%d, result=%d", pop_check, pop_result);
                        check_32(pop_check, pop_result);
                    end else begin
                        get_clk;
                    end
                end
            end
            
            
            /*
            begin
                forever begin
                    if((result_queue.size() != 0) && (check_queue.size() != 0)) begin
                        int pop_result;
                        int pop_check;
                        pop_result = result_queue.pop_front();
                        pop_check  = check_queue.pop_front();
                        $display($stime, " pop check=%d, result=%d", pop_check, pop_result);
                        check_32(pop_check, pop_result);
                    end else begin
                        get_clk;
                    end
                end
            end
            */
               
		get_clk();
		$finish;
	end

endmodule