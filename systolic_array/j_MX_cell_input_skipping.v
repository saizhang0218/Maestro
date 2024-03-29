module j_MX_cell_input_skipping #(
  parameter DEFAULT_SHARED_WEIGHT = 8'h01            ,
  parameter DATA_WIDTH            = 2                ,
  parameter DATA_MUL_W            = clog2(DATA_WIDTH)
) (
  input                        clk               , // clock signal
  input       [DATA_WIDTH-1:0] dataflow_in       , // two input dataflows
  input       [DATA_MUL_W-1:0] dataflow_select   , // select signal of the dataflow
  input                        reset             ,
  input       [DATA_WIDTH-1:0 ]    zero_inputs_in, // for these 8 input flows, which are zero, 1 means the input is zero
  input  wire                  control1          ,
  input  wire sel_in,
  input  wire [           3:0] clr_and_plus_one_i,
  input  wire [           3:0] serial_end_i      ,
  input  wire                  update_w_i        ,
  input  wire [           3:0] mac_en_i          ,
  output  wire sel_out, 
  output wire [           3:0] result_final      , // output of MX_cell
  output wire [DATA_WIDTH-1:0] dataflow_out      , // two output dataflows
  output wire [DATA_WIDTH-1:0] zero_inputs_out      , // two output dataflows
  output reg  [           3:0] clr_and_plus_one_o,
  output wire [           3:0] serial_end_o      ,
  //output wire [           3:0] result, // output of MX_cell
  output reg                   update_w_o        ,
  output reg  [           3:0] mac_en_o          ,
  input  wire [           3:0] accumulation_in     // accumulation flow
);

function [31:0] clog2 (input [31:0] x);
    reg [31:0] x_tmp;
    begin
            x_tmp = x-1;
            for(clog2=0; x_tmp>0; clog2=clog2+1) begin
                x_tmp = x_tmp >> 1;
            end
    end
endfunction

// first generate the gated clock signal
wire [3:0] gated;
wire [3:0] clk_gated;
wire [3:0] accumulation_in_delay;
wire [           3:0] result; // output of MX_cell
reg [3:0] turn_off;    // determine whether the input at the MX_cell is zero or not
reg [   3:0] accumulation_in_reg, gated_reg;
assign clk_gated[3] = ~gated[3] & clk;
assign clk_gated[2] = ~gated[2] & clk;
assign clk_gated[1] = ~gated[1] & clk;
assign clk_gated[0] = ~gated[0] & clk;
assign accumulation_in_delay[3:0] = accumulation_in_reg[3:0];
assign result_final[3] = gated_reg[3] & accumulation_in_delay[3] | ~gated_reg[3] & result[3];
assign result_final[2] = gated_reg[2] & accumulation_in_delay[2] | ~gated_reg[2] & result[2];
assign result_final[1] = gated_reg[1] & accumulation_in_delay[1] | ~gated_reg[1] & result[1];
assign result_final[0] = gated_reg[0] & accumulation_in_delay[0] | ~gated_reg[0] & result[0];

reg [1:0] sel;
always @(posedge clk) begin : delay_accumulation
  if(reset) begin
    accumulation_in_reg <= 'b0;
    gated_reg = 4'b0;
    //sel <= 2'b0;
    turn_off <= 4'b0;   
    gated_reg <= 4'b0;
  end else begin
    accumulation_in_reg <= accumulation_in;
    gated_reg <= gated;
  end
end



// this is to replace the control signal for clear1

// assign the control signal 
// 2-to-1 multiplexer
// this is to replace the control signal for clear1

wire data_mux_in = dataflow_in[dataflow_select];
wire zero_input = zero_inputs_in[dataflow_select]; 

wire [3:0] data_in;
reg reg1, reg2;

always @(posedge clk) begin : proc_mac_en_o
  if(reset) begin
    mac_en_o <= 0;
  end else begin
    mac_en_o <= mac_en_i;
  end
end

assign data_in[0] = ((({reg2, reg1} == 2'b00) & ~clr_and_plus_one_i[1] & ~clr_and_plus_one_i[2] & ~clr_and_plus_one_i[3]) | clr_and_plus_one_i[0]) & data_mux_in;
assign data_in[1] = ((({reg2, reg1} == 2'b01) & ~clr_and_plus_one_i[2] & ~clr_and_plus_one_i[3] & ~clr_and_plus_one_i[0]) | clr_and_plus_one_i[1]) & data_mux_in;
assign data_in[2] = ((({reg2, reg1} == 2'b10) & ~clr_and_plus_one_i[3] & ~clr_and_plus_one_i[0] & ~clr_and_plus_one_i[1]) | clr_and_plus_one_i[2]) & data_mux_in;
assign data_in[3] = ((({reg2, reg1} == 2'b11) & ~clr_and_plus_one_i[0] & ~clr_and_plus_one_i[1] & ~clr_and_plus_one_i[2]) | clr_and_plus_one_i[3]) & data_mux_in;

wire [1:0] reg_cnt_nxt = {reg2, reg1} + 2'b01;
wire       reg_cnt_en  = (|clr_and_plus_one_i);

always @(posedge clk) begin : proc_reg
  if(reset) begin
    {reg2, reg1} <= 2'b11;
  end else if(reg_cnt_en) begin
    {reg2, reg1} <= reg_cnt_nxt;
  end
end

always @ (sel_in or update_w_i) begin
    if (update_w_i == 1'b1) begin
       sel <= 'b0;
    end
    else if (~reset) begin
       sel <= sel + 1'b1;
    end
end


always @ (sel) begin
   if(~reset) begin
   case (sel)
       2'b10 : begin
           turn_off[0] <= zero_input;
       end
       2'b11 : begin
           turn_off[1] <= zero_input;
       end
       2'b00 : begin
           turn_off[2] <= zero_input;
       end
       2'b01 : begin
           turn_off[3] <= zero_input;
       end
   endcase
   end
end


reg [7:0] shared_W;

generate
  if(DATA_WIDTH == 1) begin: g_shift_weight
    always @(posedge clk)
      if(reset) begin
        shared_W <= DEFAULT_SHARED_WEIGHT;
      end else if(update_w_i) begin
        shared_W <= {dataflow_in[0], shared_W[7:1]};
      end
  end 
  else if(DATA_WIDTH == 2) begin
    always @(posedge clk)
      if(reset) begin
        shared_W <= DEFAULT_SHARED_WEIGHT;
      end else if(update_w_i) begin
        shared_W <= {dataflow_in[1:0], shared_W[7:2]};
      end
  end
  else if(DATA_WIDTH == 4) begin
    always @(posedge clk)
      if(reset) begin
        shared_W <= DEFAULT_SHARED_WEIGHT;
      end else if(update_w_i) begin
        shared_W <= {dataflow_in[3:0], shared_W[7:4]};
      end
  end
  else if(DATA_WIDTH == 8) begin
    always @(posedge clk)
      if(reset) begin
        shared_W <= DEFAULT_SHARED_WEIGHT;
      end else if(update_w_i) begin
        shared_W <= {dataflow_in[7:0]};
      end
  end
endgenerate

///////////////////////////////////////////////////////////////////////////
// depends on whether share_W is 0, change the gated signal to 1 accordingly
assign gated[0] = (shared_W == 8'b00000000)|turn_off[0];
assign gated[1] = (shared_W == 8'b00000000)|turn_off[1];
assign gated[2] = (shared_W == 8'b00000000)|turn_off[2];
assign gated[3] = (shared_W == 8'b00000000)|turn_off[3];

////////////////////////////////////////////////////////////////////////////


// the four adders in the MX cell
j_mac #(.WEIGHT_RESET_VAL(DEFAULT_SHARED_WEIGHT), .SHARED_W(1)) mac1(.clk(clk_gated[0]), .shared_W(shared_W), .update_w(1'b0), .mac_en(mac_en_i[0]), .control1(control1),.reset(reset),.plus_one(clr_and_plus_one_i[0]),.clear_accu_control(clr_and_plus_one_i[0]),.accumulation(accumulation_in[0]),.dataflow_in(data_in[0]),.result(result[0]));
j_mac #(.WEIGHT_RESET_VAL(DEFAULT_SHARED_WEIGHT), .SHARED_W(1)) mac2(.clk(clk_gated[1]), .shared_W(shared_W), .update_w(1'b0), .mac_en(mac_en_i[1]), .control1(control1),.reset(reset),.plus_one(clr_and_plus_one_i[1]),.clear_accu_control(clr_and_plus_one_i[1]),.accumulation(accumulation_in[1]),.dataflow_in(data_in[1]),.result(result[1]));
j_mac #(.WEIGHT_RESET_VAL(DEFAULT_SHARED_WEIGHT), .SHARED_W(1)) mac3(.clk(clk_gated[2]), .shared_W(shared_W), .update_w(1'b0), .mac_en(mac_en_i[2]), .control1(control1),.reset(reset),.plus_one(clr_and_plus_one_i[2]),.clear_accu_control(clr_and_plus_one_i[2]),.accumulation(accumulation_in[2]),.dataflow_in(data_in[2]),.result(result[2]));
j_mac #(.WEIGHT_RESET_VAL(DEFAULT_SHARED_WEIGHT), .SHARED_W(1)) mac4(.clk(clk_gated[3]), .shared_W(shared_W), .update_w(1'b0), .mac_en(mac_en_i[3]), .control1(control1),.reset(reset),.plus_one(clr_and_plus_one_i[3]),.clear_accu_control(clr_and_plus_one_i[3]),.accumulation(accumulation_in[3]),.dataflow_in(data_in[3]),.result(result[3]));

reg  [DATA_WIDTH-1:0] dataflow_out_tmp;
reg  [DATA_WIDTH-1:0] zero_inputs_out_tmp;
reg  sel_out_tmp;
// direct the dataflow out
always@(posedge clk) begin
  if(reset) begin
    dataflow_out_tmp       <= {(DATA_WIDTH){1'b0}};
    zero_inputs_out_tmp    <= {(DATA_WIDTH){1'b0}};
    clr_and_plus_one_o     <= 4'b0;
    update_w_o             <= 1'b0;
    sel_out_tmp <=1'b0;
    // don't use serial end, it is too cost to many FF
    //serial_end_o           <= 4'b0;
  end else begin
    dataflow_out_tmp       <= dataflow_in; // transfer a single bit of the dataflow
    zero_inputs_out_tmp    <= zero_inputs_in;
    clr_and_plus_one_o     <= clr_and_plus_one_i;
    update_w_o             <= update_w_i;
    sel_out_tmp <= sel_in;
    //serial_end_o           <= serial_end_i;
  end
end

assign serial_end_o = 4'b0;
assign dataflow_out = update_w_o ? shared_W : dataflow_out_tmp;
assign zero_inputs_out = update_w_o ? {(DATA_WIDTH){1'b0}} : zero_inputs_out_tmp;
assign sel_out = update_w_o ? {1'b0} : sel_out_tmp;

// this is for the control of the de_sel signals, as well as for the plus_one signal
endmodule


