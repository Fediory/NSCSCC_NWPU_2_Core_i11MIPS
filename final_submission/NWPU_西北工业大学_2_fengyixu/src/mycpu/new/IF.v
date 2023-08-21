`include "lib/defines.v"
module pipeline_IF(
    input clk,
	input reset,
    input eret_flush,
    input exception_flush,
    input inst_refetch_flush,
    input wait_flush        ,
    input wait_status       ,
    input ID_allowin,

    input predict_fail_flush,
    input branch_likely_clear,

    input                           IF_branch_ready     ,//可参考pre_IF_branch_ready
    input [31:0]                    IF_branch_pc        ,//可参考pre_IF_branch_pc
    input [31:0]                    icache_rdata        ,
    input                           icache_data_ok      ,
    input [`PRE_IF_TO_IF_WD-1:0]    pre_IF_to_IF_bus    ,
    input                           pre_IF_to_IF_valid  ,

    input                           ID_inst_refetch_o,
    input                           EXE_inst_refetch_o,
    input                           MEM0_inst_refetch_o,
    input                           MEM_inst_refetch_o,
    input                           WR_inst_refetch_o,

    input                           addr_error,
    input                           inst_req_busy,

    output                          IF_ID_valid,
	output [`IF_TO_ID_WD-1:0]       IF_to_ID_bus,
    output                          IF_predict_pc_dir,
    output [31:0]                   IF_btb_branch_pc,
    output                          IF_allowin 
    `ifdef VERILATOR
    ,
    output [31            : 0]      IF_inst_wire
    `endif                
);
    reg [31:0]  IF_inst_reg;
    reg         IF_inst_reg_valid;
    reg         IF_valid;
    wire [31:0] IF_inst_sent ;
    wire        IF_ready_go;
    reg         IF_bd_reg;
    wire        IF_bd;
    wire IF_hit;
    wire [1:0] IF_branch_type;
    wire [31:0]        IF_pc/*verilator public*/;
    (*MAX_FANOUT = 32 *)reg  [`PRE_IF_TO_IF_WD-1:0] IF_data;
    reg         IF_inst_discard;

    wire [`IF_EX_INFO-1:0] IF_exception_info;
    wire [31:0] IF_badvaddr;
    wire  [31:0] IF_inst /*verilator public*/;
    wire        flush = exception_flush | eret_flush | inst_refetch_flush | wait_flush | wait_status; 

     //TLB指令清空
    wire IF_inst_refetch =      ID_inst_refetch_o     | 
                                EXE_inst_refetch_o    |
                                MEM0_inst_refetch_o   | 
                                MEM_inst_refetch_o    |
                                WR_inst_refetch_o
                                ;

    reg inst_refetch; 
    always @(posedge clk ) begin
        if(reset)
            inst_refetch <= 1'b0;
        else if(IF_inst_refetch)
            inst_refetch <= 1'b1;
        else if(IF_allowin && pre_IF_to_IF_valid)
            inst_refetch <= 1'b0;
    end

    //未命中丢�?
    reg         IF_unhit_reg;
    wire        IF_unhit; 
    wire        IF_unhit_sent;  
    wire        branch_bubble_clear;
    wire        likely_delay_clear;
    assign branch_bubble_clear = ((IF_branch_ready) && !(IF_branch_pc + 32'h4 == IF_pc));
    assign likely_delay_clear = (branch_likely_clear &&(IF_branch_pc+ 32'h4 == IF_pc ));
    always@(posedge clk)
       if((reset | flush) | (ID_allowin && IF_ready_go))
          IF_unhit_reg <= 1'b0;
       else if(branch_bubble_clear | likely_delay_clear)
          IF_unhit_reg <= 1'b1;

    assign IF_unhit = ((ID_allowin && IF_ready_go) && (branch_bubble_clear || likely_delay_clear)
                       && !(flush)) ? 1'b1 :
                        IF_unhit_reg; 

    //取指�?
    assign IF_inst = (IF_unhit_sent) ? 32'b0 : icache_rdata;
    assign IF_unhit_sent = IF_bd | IF_unhit;
`ifdef VERILATOR
    assign IF_inst_wire = IF_inst;
`endif

    //使能判断信号
    always@(posedge clk)
	    if(reset | flush) 
	        IF_valid <= 1'b0;
	    else if(IF_allowin)
	        IF_valid <= pre_IF_to_IF_valid;


    assign IF_ready_go  = ((icache_data_ok | IF_inst_reg_valid) && !IF_inst_discard) | IF_exception_info[2] | IF_exception_info[1] | IF_exception_info[0];
	assign IF_allowin   = !IF_valid || IF_ready_go && ID_allowin;
	assign IF_ID_valid  = IF_valid && IF_ready_go;

    assign {
        IF_branch_type,
        IF_btb_branch_pc, 
        IF_bd,//72
        IF_predict_pc_dir,//71
        IF_hit,//70
        IF_badvaddr,//69
        IF_exception_info,//37
        IF_pc//32
    } =  IF_data;

    assign IF_to_ID_bus = { 
        IF_hit,//139
        IF_branch_type,//138
        IF_btb_branch_pc,//136
        IF_predict_pc_dir,//104
        inst_refetch | IF_inst_refetch,//103
        IF_unhit_sent,//102
        IF_badvaddr,//101
        IF_exception_info,//69
        IF_inst_sent,//64
        IF_pc //32
    };
    assign IF_inst_sent = (IF_inst_reg_valid & !IF_unhit_sent) ? IF_inst_reg:IF_inst;

    always@(posedge clk)
    if(reset | flush)
        IF_data <= 0;
	else if(IF_allowin && pre_IF_to_IF_valid)
	    IF_data <= pre_IF_to_IF_bus;

    always@(posedge clk)
        if(IF_ready_go & !ID_allowin & !IF_inst_reg_valid)
            IF_inst_reg <= IF_inst;

always@(posedge clk)
    if(IF_ready_go && !ID_allowin)
        IF_inst_reg_valid <= 1'b1;
    else if(ID_allowin | flush)
        IF_inst_reg_valid <= 1'b0;

        
    always@(posedge clk)
        if(reset)
            IF_inst_discard <= 1'b0;
        else if(icache_data_ok)
            IF_inst_discard <= 1'b0;
        else if(flush && inst_req_busy)
            IF_inst_discard <= 1'b1;


endmodule