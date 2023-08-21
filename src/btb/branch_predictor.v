`include "BPU_define.v"
module branch_predictor #(
	parameter DATA_WIDTH  = `DATA_WD,
	parameter LATENCY     = 0,
	parameter SIZE        = `BLOCK_WD, //指有多少块
	parameter MEMORY_SIZE = DATA_WIDTH * SIZE,
	parameter ADDR_WIDTH  = $clog2(SIZE)
) (
    input clk,
    input reset,
    
    //将EXE的分支判断结果传递进来，判断预测正确性
    input           EXE_predict_result  , 
    input [31:0]    EXE_pc              ,
    input [31:0]    EXE_branch_pc       ,
    input           EXE_predict_wr      ,
    input           EXE_is_branch       ,
    input           EXE_is_return       ,
    input           EXE_is_call         ,
    input 			EXE_hit             ,
    input [1:0] 	EXE_branch_type     ,    

    //被预测的PC与方向
    input [31:0]    pre_IF_pc           ,
    input           predictor_rd        ,
    output[31:0]    pre_IF_branch_pc    ,
    output          predict_pc_dir      ,
    output          pre_IF_hit          ,
    output[`TYPE_WD]pre_IF_branch_type
);

//EXE写声明
reg [`TAG_WD]       tag    ;
reg [`BRANCH_WD]    branch ;
reg [`TYPE_WD]      type   ;
reg valid;
reg ret;
// reg [`RAS_BRANCH] RAS [`RAS_WD];
// reg [`RAS_POINT]  RAS_top;
// wire [`RAS_POINT] RAS_top_sub1 = RAS_top + `TOP_SUB1;

//来自pre_IF级的pc
wire [`INDEX_WD]pre_pc_index = pre_IF_pc[`PC_INDEX];
wire [`TAG_WD]  pre_pc_tag   = pre_IF_pc[`PC_TAG];

//来自EXE级的pc
wire [`INDEX_WD]EXE_pc_index = EXE_pc[`PC_INDEX];
wire [`TAG_WD]  EXE_pc_tag   = EXE_pc[`PC_TAG];

//===============pre_IF跳转判断==================
//pre_IF读声明
wire rd_valid;
wire [`TAG_WD] rd_tag;
wire [`TYPE_WD] rd_type;
wire [`BRANCH_WD] rd_branch;
wire [`WR_WD] xpm_rd_data;
wire          rd_ret;
assign {
        rd_valid    ,
        rd_tag      ,
        rd_type     ,
        rd_branch
                } = xpm_rd_data;

//条件1：跳转表中存在该pc则为true
assign pre_IF_hit = rd_tag == pre_pc_tag;
wire hit = pre_IF_hit && rd_valid;

//条件2：pre_IF的pc值确定跳转，则为true
assign pre_IF_branch_type = 
                        // rd_ret ? 2'b00 : 
                        hit & predictor_rd ? rd_type : 2'b0;
wire pc_dir = rd_type[1];

//预测输出
assign pre_IF_branch_pc = 
                            // rd_ret ? RAS[RAS_top][`BRANCH_WD] : 
                            (hit & predictor_rd ? rd_branch : 32'b0);
assign predict_pc_dir   =   (hit & predictor_rd ? pc_dir : 1'b0);

//===================RAS=======================

// integer i;
// always @(posedge clk ) begin
//     if(reset)begin
//         RAS_top <= 0;
//         for(i = 0; i<`RAS_SIZE; i=i+1)begin
//             RAS[i] <= 0;
//         end 
//     end
//     else if(EXE_predict_wr)begin
//         if(EXE_is_call)begin
//             RAS[RAS_top][32] <= 1'b1;
//             RAS[RAS_top][`BRANCH_WD] <= EXE_branch_pc + 32'h8;
//             RAS_top <= RAS_top + 1;
//         end
//         else if(EXE_is_return)begin
//             RAS_top <= RAS_top_sub1;
//         end
//     end
// end

//===================BTB=======================
always @(*)begin
    if(EXE_hit)begin
        if(EXE_predict_result)begin
                case(EXE_branch_type)
                    `WEAKLY_NT  :   type <= `WEAKLY_T     ;
                    `WEAKLY_T   :   type <= `STRONGLY_T   ;
                    `STRONGLY_T :   type <= `STRONGLY_T   ;
                    `STRONGLY_NT:   type <= `WEAKLY_NT    ;
                    default     :   type <= `WEAKLY_NT    ;
                endcase
            end
            else begin
                case(EXE_branch_type)
                    `WEAKLY_NT  :   type <= `STRONGLY_NT  ;
                    `WEAKLY_T   :   type <= `WEAKLY_NT    ;
                    `STRONGLY_T :   type <= `WEAKLY_T     ;
                    `STRONGLY_NT:   type <= `STRONGLY_NT  ;
                    default     :   type <= `WEAKLY_NT    ;
                endcase
            end
        valid           <= 1'b1;
        tag             <= EXE_pc_tag;
        branch          <= EXE_branch_pc;
    end
    else begin
        valid           <= 1'b1;
        tag             <= EXE_pc_tag;
        if(EXE_predict_result)
            type        <= `WEAKLY_T;
        else
            type        <= `WEAKLY_NT;
        branch          <= EXE_branch_pc;
    end
end

wire [`WR_WD] xpm_wr_data ={
            valid       ,
            tag         ,
            type        ,
            branch 
                            };
wire xpm_wea = EXE_is_branch && EXE_predict_wr; //&& !(EXE_is_return);

// integer i;
// reg [`WR_WD] XPM [SIZE-1:0];
// always @(posedge clk ) begin
//     if(reset)
//         for(i = 0; i<SIZE; i=i+1)begin
//             XPM[i] <= 0;
//         end
//     else if(xpm_wea)
//         XPM[EXE_pc_index] <= xpm_wr_data;
// end
// assign {
//         rd_valid    ,
//         rd_tag      ,
//         rd_type     ,
//         rd_branch
//                 } = XPM[pre_pc_index];

xpm_memory_sdpram #(
      .ADDR_WIDTH_A(ADDR_WIDTH),               // DECIMAL
      .ADDR_WIDTH_B(ADDR_WIDTH),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(DATA_WIDTH),        // DECIMAL
      //.CASCADE_HEIGHT(0),             // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE("none"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("auto"),      // String distributed
      .MEMORY_SIZE(MEMORY_SIZE),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .READ_DATA_WIDTH_B(DATA_WIDTH),         // DECIMAL
      .READ_LATENCY_B(LATENCY),             // DECIMAL
      .READ_RESET_VALUE_B("0"),       // String
      //.RST_MODE_A("SYNC"),            // String
      //.RST_MODE_B("SYNC"),            // String
      //.SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(DATA_WIDTH),        // DECIMAL
      .WRITE_MODE_B("read_first")      // String
   )
   xpm_memory_sdpram_inst (
      .dbiterrb(),             // 1-bit output: Status signal to indicate double bit error occurrence
                                       // on the data output of port B.

      .doutb(xpm_rd_data),                   // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
      .sbiterrb(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                       // on the data output of port B.

      .addra(EXE_pc_index),            // ADDR_WIDTH_A-bit input: Address for port A write operations.
      .addrb(pre_pc_index),                   // ADDR_WIDTH_B-bit input: Address for port B read operations.
      .clka(clk),                     // 1-bit input: Clock signal for port A. Also clocks port B when
                                       // parameter CLOCKING_MODE is "common_clock".

      .clkb(clk),                     // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                       // "independent_clock". Unused when parameter CLOCKING_MODE is
                                       // "common_clock".

      .dina(xpm_wr_data),                     
      .ena(1'b1),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                       // cycles when write operations are initiated. Pipelined internally.

      .enb(1'b1),                       // 1-bit input: Memory enable signal for port B. Must be high on clock
                                       // cycles when read operations are initiated. Pipelined internally.

      .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .regceb(1'b0),                 // 1-bit input: Clock Enable for the last register stage on the output
                                       // data path.

      .rstb(reset),                     // 1-bit input: Reset signal for the final port B output register stage.
                                       // Synchronously resets output port doutb to the value specified by
                                       // parameter READ_RESET_VALUE_B.

      .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
      .wea(xpm_wea)                        
   );


endmodule
