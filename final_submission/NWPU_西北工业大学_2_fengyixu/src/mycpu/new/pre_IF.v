`include "lib/defines.v"
`define VIRTUAL 0
`define PHYSIC1 1
`define PHYSIC2 2
module pipeline_pre_IF(
    input clk,
	input reset,
    input eret_flush,
    input exception_flush,
    input inst_refetch_flush,
    input predict_fail_flush,
    input wait_flush        ,
    input wait_status       ,

    input IF_allowin,
    input has_int,

    input branch_likely_clear,
    input EXE_branch_likely_hit,
    input EXE_is_branch_likely,    

    input                           pre_IF_branch_hit,
    input [31:0]                    pre_IF_branch_next_pc,//跳转的目标地址
    input                           pre_IF_branch_ready,//从EXE传过来的信号，1表示分支指令跳转
    input [31:0]                    pre_IF_branch_pc,
    input                           IF_predict_pc_dir,
    input [31:0]                    IF_btb_branch_pc,
    input [31:0]                    EXE_predict_pc,
    input                           EXE_predict_wr,
    input                           EXE_is_branch,
    input 						    EXE_hit,
    input                           EXE_is_return,
    input                           EXE_is_call  ,
    input [1:0] 				    EXE_branch_type,
    input [31:0]                    WR_pc,

    input [31:0]                    WR_EPC_info,
    
    input                           icache_addr_ok,
    output                          icache_valid,
    output [19 :0]                  icache_tag,
    output [7  :0]                  icache_index,
    output [3  :0]                  icache_offset,
    output                          icache_uncached,

    output                          pre_IF_IF_valid,
	output [`PRE_IF_TO_IF_WD-1:0]   pre_IF_to_IF_bus,
    output                          addr_error,

    output  [`VPN2_WD]              s0_vpn2,
    output                          s0_odd_page,
    input                           s0_found,
    input   [`TLB_WD]               s0_index,
    input   [`PFN_WD]               s0_pfn,
    input   [`C_WD]                 s0_c,
    input                           s0_d,
    input                           s0_v,

    input  [31:0]        ex_addr,
    input  [2:0]         k0,

    input                icache_data_ok,
    output reg               inst_req_busy
);

	reg [31:0]           pre_IF_pc/*verilator public*/;
	wire [3:0]           pre_IF_sel_next_pc;

    wire [31:0] pre_IF_inst;
    wire [31:0] pre_IF_next_pc1;
    wire [31:0] pre_IF_next_pc2;
    wire [31:0] pre_IF_next_pc3;
    wire [31:0] pre_IF_next_pc4;
    wire [31:0] pre_IF_EPC;
    wire [31:0] pre_IF_badvaddr;

    reg         pre_IF_valid;
    reg  [31:0] next_pc_data; 
    wire        to_pre_IF_valid;

    wire        ID_leave;
    wire        pre_IF_bd;
    wire        pre_IF_ADEL;
    wire        pre_IF_is_ex;
    wire        pre_IF_TLB_refill_if ;
    wire        pre_IF_TLB_invalid_if ;
    wire [`PRE_IF_EX_INFO-1:0] pre_IF_exception_info;
    reg         bd_done;

    wire        pre_IF_ready_go;
    wire        pre_IF_allowin;

    //PC增加
    reg [31:0] pre_IF_next_pc_reg;
    reg        pre_IF_next_pc_reg_valid;

    //flush
    wire flush;
    assign flush = exception_flush | eret_flush | inst_refetch_flush | wait_status | wait_flush;
    //缓存next_pc，等待pc更新
    always@(posedge clk)
    if(reset | flush)
        pre_IF_next_pc_reg <= 32'b0;
    else if(pre_IF_branch_ready)
        if(predict_fail_flush)
            pre_IF_next_pc_reg <= pre_IF_branch_pc + 32'd8;
        else
            pre_IF_next_pc_reg <= pre_IF_branch_next_pc;

    always@(posedge clk)
        if((reset | flush) | (IF_allowin && pre_IF_ready_go))
            pre_IF_next_pc_reg_valid <= 1'b0;
        else if(pre_IF_branch_ready)
            pre_IF_next_pc_reg_valid <= 1'b1;

    //更新PC
    wire npc_valid;
    
    wire predict_pc_dir;
    assign npc_valid = to_pre_IF_valid && pre_IF_allowin;
    always@(posedge clk)
	    if(reset)
	        pre_IF_pc <= `PC_START;
        else if(eret_flush)
            pre_IF_pc <= pre_IF_EPC;
        else if(exception_flush)
            pre_IF_pc <= ex_addr;
        else if(inst_refetch_flush)
            pre_IF_pc <= WR_pc;
	    else if(npc_valid)
            pre_IF_pc <= (pre_IF_next_pc_reg_valid  ) ? pre_IF_next_pc_reg:
                         (pre_IF_branch_ready       ) ? (predict_fail_flush ? pre_IF_branch_pc + 32'H8 : pre_IF_branch_next_pc) :
                         (IF_predict_pc_dir         ) ? IF_btb_branch_pc:
                         pre_IF_next_pc1; 


    assign pre_IF_next_pc1 = pre_IF_pc + `PC_INC;
    
    //输出
    reg[31:0] pre_IF_pc_buffer;
    always @(posedge clk ) begin
        if(reset) 
          pre_IF_pc_buffer <= 32'b0;
        else if(pre_IF_status ==`VIRTUAL && addr_is_mapped)
          pre_IF_pc_buffer <= pre_IF_pc;
    end
    //虚实地址转换
    wire [31:0] pre_IF_paddr;
    wire [31:0] pre_IF_paddr_t;
    wire [31:0] pre_IF_paddr_f;
    wire addr_is_mapped = (pre_IF_pc[31] == 1'b0) | (pre_IF_pc[31:30] == 2'b11);
    wire addr_is_k01 = ((pre_IF_pc[31:28] >= 4'h8) && (pre_IF_pc[31:28] <4'hA))|
                       ((pre_IF_pc[31:28] >= 4'hA) && (pre_IF_pc[31:28] <4'hC));
    TLB_pre_IF_bridge Tpb(
        .pre_IF_pc              (pre_IF_pc_buffer)             ,
        .s0_vpn2                (s0_vpn2)               ,
        .s0_odd_page            (s0_odd_page)           ,
        .s0_found               (s0_found)              ,
        .s0_pfn                 (s0_pfn)                ,
        .s0_V                   (s0_v)                  ,
        .pre_IF_paddr           (pre_IF_paddr_t)          ,
        .is_TLB_refill          (pre_IF_TLB_refill_if_t)  ,
        .is_TLB_invalid         (pre_IF_TLB_invalid_if_t)
    );   
    assign pre_IF_paddr_f = (addr_is_k01) ? {3'b0,pre_IF_pc[28:0]}:pre_IF_pc;  

    //分支预测
    wire[31:0]  btb_branch_pc;
    wire pre_IF_hit;
    wire [1:0] pre_IF_branch_type;
    wire        predictor_rd = !pre_IF_bd;
    wire[31:0] EXE_branch_pc = pre_IF_branch_next_pc;
    branch_predictor BPU(
    .clk                (clk),
    .reset              (reset),

    .EXE_predict_result (pre_IF_branch_hit  ),
    .EXE_pc             (pre_IF_branch_pc   ),
    .EXE_branch_pc      (EXE_predict_pc     ),
    .EXE_is_branch      (EXE_is_branch      ),
	.EXE_predict_wr		(EXE_predict_wr		),
    .EXE_is_return      (EXE_is_return      ),
    .EXE_is_call        (EXE_is_call        ),
    .EXE_hit            (EXE_hit            ),
    .EXE_branch_type    (EXE_branch_type    ),

    .pre_IF_pc          (pre_IF_pc          ),
    .predictor_rd       (predictor_rd       ),
    .pre_IF_branch_pc   (btb_branch_pc      ),
    .predict_pc_dir     (predict_pc_dir     ),
    .pre_IF_hit         (pre_IF_hit         ),
    .pre_IF_branch_type (pre_IF_branch_type )
    );
   //paddr_buffer 
    reg [31:0] pre_IF_paddr_buffer;
    reg pre_IF_TLB_invalid_r;
    reg pre_IF_TLB_refill_r;
    always @(posedge clk ) begin
        if(reset) begin
          pre_IF_paddr_buffer <= 0;
          pre_IF_TLB_invalid_r <= 0;
          pre_IF_TLB_refill_r <= 0;
        end
        else if(pre_IF_status == `PHYSIC1) begin
          pre_IF_paddr_buffer <= pre_IF_paddr_t;
          pre_IF_TLB_invalid_r <= pre_IF_TLB_invalid_if_t;
          pre_IF_TLB_refill_r <= pre_IF_TLB_refill_if_t;
        end
    end

    assign pre_IF_paddr = (addr_is_mapped) ? pre_IF_paddr_buffer:pre_IF_paddr_f;
    //icache访问请求
    wire icache_valid_vitual = IF_allowin && !flush && !pre_IF_ADEL;
    wire icache_valid_physic = IF_allowin && (pre_IF_status == `PHYSIC2) && !flush && !pre_IF_TLB_invalid_r && !pre_IF_TLB_refill_r;

    //输出
    assign icache_valid     = (addr_is_mapped) ? icache_valid_physic:icache_valid_vitual;
    assign icache_tag       = pre_IF_paddr[31 : 12];
    assign icache_index     = pre_IF_pc[11: 4];
    assign icache_offset    = pre_IF_pc[3 : 0];
    assign icache_uncached  = pre_IF_pc[31:28] >= 4'HC || pre_IF_pc[31:28] < 4'H8 ? s0_c != 3'h3 :
                              pre_IF_pc[31:28] < 4'HC && pre_IF_pc[31:28]  >= 4'HA ? 1'b1 :
                              pre_IF_pc[31:28] >= 4'H8 && pre_IF_pc[31:28] <4'HA  ? k0 != 3'h3:
                              1'b0;
    //pre_IF_bd:为1时分支预测未命中，本条指令丢弃 bd_done:判断条件的中间变量
    wire        branch_bubble_clear;
    wire        likely_delay_clear;
    assign branch_bubble_clear = ((pre_IF_branch_ready) && !(pre_IF_branch_pc + 32'h4 == pre_IF_pc));
    assign likely_delay_clear = (branch_likely_clear &&(pre_IF_branch_pc+ 32'h4 == pre_IF_pc ));
    always@(posedge clk)
       if((reset | flush) | (IF_allowin && pre_IF_ready_go))
          bd_done <= 1'b0;
       else if(branch_bubble_clear | likely_delay_clear)
          bd_done <= 1'b1;

    assign pre_IF_bd =    IF_allowin && pre_IF_ready_go && (branch_bubble_clear || likely_delay_clear) &&
                        !(flush) ? 1'b1 :
                        bd_done;
    //使能判断信号
    always@(posedge clk)
	    if(reset | wait_flush | wait_status) 
	        pre_IF_valid <= 1'b0;
	    else if(pre_IF_allowin)
	        pre_IF_valid <= to_pre_IF_valid;

 //pre_IF_ready_go
    wire pre_IF_vitual_go;
    wire pre_IF_physic_go;

    assign pre_IF_vitual_go = (icache_addr_ok && icache_valid) || !icache_valid;
    assign pre_IF_physic_go = (pre_IF_status == `PHYSIC2) && pre_IF_vitual_go;

    assign pre_IF_ready_go = (addr_is_mapped) ? pre_IF_physic_go:pre_IF_vitual_go;
	assign pre_IF_allowin   = !pre_IF_valid || pre_IF_ready_go && IF_allowin;
	assign pre_IF_IF_valid  = pre_IF_valid && pre_IF_ready_go;
	assign to_pre_IF_valid  = !reset;


    assign pre_IF_EPC = WR_EPC_info;
    assign pre_IF_badvaddr = pre_IF_pc;

    

    //IF_地址_异常
   assign pre_IF_TLB_invalid_if = pre_IF_TLB_invalid_if_t && addr_is_mapped;
    assign pre_IF_TLB_refill_if  = pre_IF_TLB_refill_if_t && addr_is_mapped;
    assign pre_IF_ADEL = pre_IF_pc[1] || pre_IF_pc[0];
    assign pre_IF_is_ex = pre_IF_ADEL           | 
                          has_int               |
                          pre_IF_TLB_invalid_if | 
                          pre_IF_TLB_refill_if;

    assign addr_error =   pre_IF_ADEL           | 
                          pre_IF_TLB_invalid_if | 
                          pre_IF_TLB_refill_if;

                          
    assign pre_IF_exception_info = {
        pre_IF_is_ex,
        has_int,
        pre_IF_ADEL,
        pre_IF_TLB_invalid_if,
        pre_IF_TLB_refill_if
        };
    
    //pre_IF_to_IF_bus
    wire pre_IF_predict_pc_dir = predict_pc_dir;
    assign pre_IF_to_IF_bus = {
            pre_IF_branch_type,
            btb_branch_pc,
            pre_IF_bd,//72
            pre_IF_predict_pc_dir,//71
            pre_IF_hit,//70
            pre_IF_badvaddr,//69
            pre_IF_exception_info,//37
            pre_IF_pc//32
    };

    //状态转换
    reg[1:0] pre_IF_status;
    reg[1:0] pre_IF_next_status;

    always @(posedge clk ) begin
        if(reset || flush)
           pre_IF_status <= `VIRTUAL; 
        else begin
           pre_IF_status <= pre_IF_next_status;
        end
    end

    always @(*) begin
        case (pre_IF_status)
            `VIRTUAL: pre_IF_next_status = (addr_is_mapped) ? `PHYSIC1:`VIRTUAL;
            `PHYSIC1: pre_IF_next_status = `PHYSIC2;
            `PHYSIC2: pre_IF_next_status = (npc_valid) ? `VIRTUAL:`PHYSIC2;
            default: pre_IF_next_status = `VIRTUAL;
        endcase
    end
    //inst_req_busy
    always@(posedge clk) begin
       if(reset)
            inst_req_busy <= 1'b0;
       else if(icache_addr_ok && icache_valid)
            inst_req_busy <= 1'b1;
       else if(icache_data_ok)
            inst_req_busy <= 1'b0;
 
    end
endmodule