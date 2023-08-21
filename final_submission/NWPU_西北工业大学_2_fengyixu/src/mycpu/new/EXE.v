`include "lib/defines.v"
`define VITUAL 0
`define PHYSI  1
module pipeline_EXE(
    input                               clk                 ,
	input                               reset               ,
    input                               eret_flush          ,
    input                               exception_flush     ,
    input                               inst_refetch_flush  ,
    output                              predict_fail_flush  ,

    input                               wait_flush          ,
    input                               wait_status         ,


	input                               ID_EXE_valid        ,
    input                               MEM0_allowin        ,
	input [`READ_REGISTER-1:0]          EXE_read_register   ,
    input                               MEM0_is_ex          ,
    input                               MEM0_is_eret        ,
    input                               MEM0_valid          ,

    input                               MEM0_tlbp_hazard    ,
    input                               MEM_tlbp_hazard     ,
    input                               WR_tlbp_hazard      ,

    
	output                              EXE_MEM0_valid      ,   
	output                              EXE_allowin         , 
	
	output [`EXE_FORWARD_WD-1:0]        EXE_forward         ,
    output [`DIV_EXE_TO_MEM0_WD-1:0]    div_EXE_to_MEM0     ,
    output                              EXE_is_ex_o         ,
    output                              EXE_int_hazard      ,
    output						        EXE_inst_refetch_o  ,
    output                              EXE_is_tlbp         ,
    output                              pc_predict_fail     ,

    input                               s1_found            ,
    input                               s1_d                ,
    input                               s1_v                ,
    input  [`PFN_WD ]                   s1_pfn              , 
    output [`VPN2_WD]                   s1_vpn2             ,
    output                              s1_odd_page         ,

    //input regs
    input 						        ID_hit              ,
    input [1:0] 				        ID_branch_type      ,
    input                               ID_predict_pc_dir   ,
    input                               ID_inst_refetch     ,
    input                     	        ID_is_branch        ,
	input[`INST_TABLE_WD-1:0] 	        ID_inst_table       ,
	input[31:0]               	        ID_alu_src1         ,
	input[31:0]               	        ID_alu_src2         ,
	input[11:0]               	        ID_alu_control      ,
	input                     	        ID_add_sub_sign     ,
	input                     	        ID_ctrl_reg_write   ,
	input[4:0]                	        ID_write_reg        ,
	input                     	        ID_ctrl_write       ,
	input                     	        ID_hi_ctrl_write    ,
	input                     	        ID_lo_ctrl_write    ,
	input                     	        ID_cp0_write_en     ,
	input[7:0]                     	    ID_cp0_write_reg    ,
	input[`EX_INFO-1:0]       	        ID_exception_info   ,
	input[31:0]               	        ID_badvaddr         ,
	input[31:0]               	        ID_pc               ,
	input[31:0]               	        ID_rf_data          ,
    input                               ID_branch_hit       ,
    input[31:0]                         ID_branch_next_pc   ,
    input[31:0]                         ID_predict_pc       ,
    input                               ID_unhit            ,
    input[4:0]                          ID_cache_op         ,
    input                               ID_is_branch_likely ,
    input                               ID_branch_likely_hit,
    input                               ID_is_jr            ,
    input[31:0]                         ID_btb_branch_pc    ,
    
    //output regs
    output                              EXE_inst_refetch        ,
    output [`INST_TABLE_WD-1:0]         EXE_inst_table          , 
    output [31:0]                       EXE_pc/*verilator public*/,
    output [31:0]                       EXE_rf_data             ,
    output [31:0]                       EXE_alu_result          ,
    output [4:0]                        EXE_write_reg           ,
    output                              EXE_hi_ctrl_write       ,
    output                              EXE_lo_ctrl_write       ,
    output                              EXE_is_eret             ,
    output                              EXE_is_branch           ,
    output [31:0]                       EXE_badvaddr            ,
    output [`EX_INFO-1:0]               EXE_exception_info_o    ,
    output                              EXE_cp0_write_en        ,
    output [7:0]                        EXE_cp0_write_reg       ,
    output                              EXE_ctrl_write          ,
    output                              EXE_ctrl_reg_write      ,
    output                              EXE_unhit               , 
    output [4:0]                        EXE_cache_op            ,   
    
    output                              EXE_branch_hit          ,
    output [31:0]                       EXE_branch_next_pc      ,
    output                              EXE_branch_ready        ,
    output [31:0]                       EXE_branch_pc           ,
    output [31:0]                       EXE_predict_pc          ,
    output                              EXE_predict_wr          ,
    output                              branch_likely_clear     ,
    output                              EXE_branch_likely_hit   ,
    output 						        EXE_hit                 ,
    output [1:0] 				        EXE_branch_type         ,
    output                              EXE_is_return           ,
    output                              EXE_is_call             ,
    output                              EXE_is_branch_likely    ,

    output [65:0]                       EXE_mult_pro            ,
    output [31:0]                       EXE_paddr

    );
	//EXE状�?�机
    reg EXE_status;
    reg EXE_next_status;

    always @(posedge clk) begin
        if(reset || flush)
           EXE_status <= `VITUAL;
        else 
           EXE_status <= EXE_next_status;
    end

    always@(*)
         case (EXE_status)
            `VITUAL:  EXE_next_status = ((EXE_ins_load || EXE_is_store) && addr_is_mapped && EXE_valid) ? `PHYSI:`VITUAL;
            `PHYSI:   EXE_next_status = (EXE_ready_go) ?                    `VITUAL:`PHYSI;
             default:  EXE_next_status = `VITUAL;    
         endcase
    
    wire  EXE_ctrl_reg_write_o;

    //EXE寄存�??
    reg EXE_valid;
    reg [`ID_TO_EXE_WD-1:0] EXE_data;
    reg [3:0] data_sram_sel_word;
    reg [1:0] data_sram_sel_hword;
    reg div_busy;
    wire div_done;
    wire EXE_ready_go;
    wire EXE_is_cloz;

    //接受从ID来的数据
    wire [`EXE_EX_INFO-1:0]EXE_exception_info_i;
	wire [31:0] EXE_bus_in;
	wire [4:0]  EXE_reg_write_addr;
	wire [31:0] EXE_alu_src1;
	wire [31:0] EXE_alu_src2;
	wire [11:0] EXE_alu_control;

    wire EXE_add_sub_sign;

    wire [`EX_CLASS-1:0]  EXE_ex_class_i;
    wire [`EX_CLASS-1:0]  EXE_ex_class_o;

    //ALU
    wire        alu_overflow    ;  
    wire        alu_cout        ; 
    wire [31:0] EXE_alu_result_o;     

    //EXE输出
    wire [4:0] EXE_reg1;
    wire [4:0] EXE_reg2;
	reg  [1:0] sel_forward;

    //除法�??
    wire [63:0]     sign_m_axis_dout_tdata;
    wire            sign_m_axis_dout_tvalid;
    wire [63:0]     unsign_m_axis_dout_tdata;
    wire            unsign_m_axis_dout_tvalid;
    wire EXE_TLB_invalid_L ;
    wire EXE_TLB_invalid_S ;
    wire EXE_TLB_refill_L  ;
    wire EXE_TLB_refill_S  ;
    wire EXE_TLB_mod       ;
    wire trap_ge ;
	wire trap_geu;
    wire trap_lt ;
    wire trap_ltu;
    wire trap_eq ;
    wire trap_neq;
    

    alu alu_unit(
	.alu_control    (EXE_alu_control    ),
	.alu_src1       (EXE_alu_src1       ),
	.alu_src2       (EXE_alu_src2       ),
	.alu_result     (EXE_alu_result_o   ),
    .alu_overflow   (alu_overflow       ),
    .adder_cout     (alu_cout           ),
    .trap_lt        (trap_lt            ),
    .trap_ltu       (trap_ltu           ),
    .trap_ge        (trap_ge            ),
    .trap_geu       (trap_geu           ),
    .trap_eq        (trap_eq            ),
    .trap_neq       (trap_neq           )
	);	  
	  


    assign {
        EXE_reg1,
        EXE_reg2
        } = EXE_read_register;

    assign EXE_is_eret = EXE_inst_table[`ERET];
    
    wire EXE_leave = MEM0_allowin && EXE_MEM0_valid;
    //trap处理

    wire trap_ex = (EXE_inst_table[`TGE  ] & trap_ge) | 
                   (EXE_inst_table[`TGEI ] & trap_ge) | 
                   (EXE_inst_table[`TGEU ] & trap_geu) | 
                   (EXE_inst_table[`TGEIU] & trap_geu) | 
                   (EXE_inst_table[`TLT  ] & trap_lt)  | 
                   (EXE_inst_table[`TLTI ] & trap_lt)  | 
                   (EXE_inst_table[`TLTU ] & trap_ltu) | 
                   (EXE_inst_table[`TLTIU] & trap_ltu) | 
                   (EXE_inst_table[`TEQ  ] & trap_eq) | 
                   (EXE_inst_table[`TEQI ] & trap_eq) | 
                   (EXE_inst_table[`TNE  ] & trap_neq) | 
                   (EXE_inst_table[`TNEI ] & trap_neq);
    //例外处理
    wire EXE_is_ex_i;
	assign {
        EXE_is_ex_i,
        EXE_ex_class_i
    } = EXE_exception_info_i;

    wire flush = eret_flush | exception_flush | inst_refetch_flush | wait_flush | wait_status;
    wire overflow_ex = alu_overflow & EXE_add_sub_sign;
    assign EXE_is_ex_o = EXE_is_ex_i |
                         overflow_ex |
                         trap_ex     | 
                         EXE_TLB_invalid_L | 
                         EXE_TLB_invalid_S |
                         EXE_TLB_mod       |
                         EXE_TLB_refill_L  |
                         EXE_TLB_refill_S; 

    assign EXE_TLB_invalid_L = (EXE_TLB_invalid_L_t) && addr_is_mapped;
    assign EXE_TLB_invalid_S = (EXE_TLB_invalid_S_t) && addr_is_mapped;
    assign EXE_TLB_refill_L = (EXE_TLB_refill_L_t) && addr_is_mapped;
    assign EXE_TLB_refill_S = (EXE_TLB_refill_S_t) && addr_is_mapped;
    assign EXE_TLB_mod      = (EXE_TLB_mod_t) && addr_is_mapped;
  
    assign EXE_ex_class_o = {
                           EXE_ex_class_i[16],
                           trap_ex,
                           EXE_TLB_mod,
                           EXE_TLB_invalid_S,
                           EXE_TLB_invalid_L,     
                           EXE_ex_class_i[11],
                           EXE_TLB_refill_S,
                           EXE_TLB_refill_L,
                           EXE_ex_class_i[8:6],//9
                           2'b00,
                           EXE_ex_class_i[3],//4
                           overflow_ex,//3
                           EXE_ex_class_i[1:0] //2
                           };
    assign EXE_exception_info_o = {
         EXE_is_ex_o,
         EXE_ex_class_o
    };
    //tlb指令冲突
    //tlb指令冲突
	assign EXE_inst_refetch_o = (EXE_inst_table[`TLBWI] || EXE_inst_table[`TLBR] || EXE_inst_table[`CACHE] || EXE_inst_table[`TLBWR]) && EXE_valid;
    assign EXE_is_tlbp        = EXE_inst_table[`TLBP];
    wire   EXE_tlbp_stall     = EXE_is_tlbp && (MEM0_tlbp_hazard || MEM_tlbp_hazard || WR_tlbp_hazard);
    //握手
    wire div_data_ok;
    wire EXE_ready_go_tlbp = !(EXE_is_tlbp && EXE_tlbp_stall);
	assign EXE_allowin = !EXE_valid || EXE_ready_go && MEM0_allowin;
    //EXE_ready_go
    wire EXE_is_mult   = EXE_inst_table[`MULT] | EXE_inst_table[`MUL]| EXE_inst_table[`MADD] | EXE_inst_table[`MSUB] 
                       | EXE_inst_table[`MADDU]| EXE_inst_table[`MSUBU] | EXE_inst_table[`MULTU];
    wire EXE_mult_done = (EXE_is_mult && mult_done);
    wire EXE_is_div    = EXE_inst_table[`DIV] | EXE_inst_table[`DIVU];
    wire EXE_physic_go = (EXE_status == `PHYSI);
    assign div_done = (div_data_ok || div_busy) && (unsign_m_axis_dout_tvalid | sign_m_axis_dout_tvalid);
    assign EXE_virtual_go = (EXE_is_mult) ? mult_done:
                            (EXE_is_div)  ? div_done:
                            (EXE_is_tlbp) ? EXE_ready_go_tlbp:1'b1;
    assign EXE_ready_go = ((EXE_ins_load || EXE_is_store) && addr_is_mapped) ? EXE_physic_go:EXE_virtual_go;


	always@(posedge clk)
	    if(reset | flush)
	        EXE_valid <= 1'b0; 
	    else if(EXE_allowin)
	        EXE_valid <= ID_EXE_valid;
	  
	assign EXE_MEM0_valid = EXE_valid && EXE_ready_go;
    
    
    
    //分支预测失败
    //情况1：预测跳转成功，pc不发送更新请求，pc正常跳转
    //情况2：预测跳转失败，pc发�?�更新请求，前面三周期设为延迟槽清空，回归到原pc+4�??
    //情况3：预测不跳转成功，pc不发送更新，pc+4
    //预测4：预测不跳转失败，pc发�?�更新请求，前面三周期设为延迟槽清空，回归到跳转后的pc�??
    wire            EXE_predict_pc_dir;
    wire            EXE_predict_pc_fail;
    wire            EXE_is_jr;       
    assign EXE_predict_pc_fail = EXE_predict_pc_dir && EXE_is_jr && |(EXE_branch_next_pc ^ EXE_btb_branch_pc);
    assign pc_predict_fail = (EXE_predict_pc_dir ^ EXE_branch_hit) || EXE_predict_pc_fail;//情况2�??4
    assign predict_fail_flush = (EXE_predict_pc_dir && !EXE_branch_hit && EXE_is_branch);//仅情�??2
    assign EXE_branch_pc  = EXE_pc;
    assign EXE_branch_ready = (pc_predict_fail) && EXE_valid && EXE_is_branch;//预测失败后修改pc
    assign branch_likely_clear = (EXE_branch_likely_hit) && !EXE_is_branch_likely && EXE_valid;
    assign EXE_is_return = 1'b0;
    assign EXE_is_call   = 1'b0;
   //分支预测命中率测�??
//    reg [31:0] total_branch;
//    reg [31:0] branch_miss2;
//    always @(posedge clk ) begin
//        if(reset)
//            total_branch <= 0;
//        else if(EXE_is_branch && EXE_predict_wr)
//            total_branch <= total_branch + 1;
//    end

//    always @(posedge clk ) begin
//         if(reset)
//             branch_miss2 <= 0;
//         else if(EXE_branch_ready && EXE_predict_wr)
//             branch_miss2 <= branch_miss2 + 1;
//    end
    
    //分支预测写使能信�??
    reg [31:0] EXE_pc_old;
    wire predict_wr = EXE_pc_old != EXE_pc;
    assign EXE_predict_wr = predict_wr;
    always @(posedge clk ) begin
        if(reset)
            EXE_pc_old <= 0;
        else if(EXE_pc_old ^ EXE_pc)
            EXE_pc_old <= EXE_pc;
    end
     //虚实地址转换
     reg [31:0] EXE_alu_result_r;
     wire [31:0] EXE_paddr_t;
     wire [31:0] EXE_paddr_f;
     wire EXE_TLB_invalid_L_t;
     wire EXE_TLB_invalid_S_t;
     wire EXE_TLB_refill_L_t;
     wire EXE_TLB_refill_S_t;
     wire EXE_TLB_mod_t;
     wire EXE_is_cache = EXE_inst_table[`CACHE];
     wire EXE_ins_load = (|(EXE_inst_table[5:1])) | EXE_inst_table[`LWL] | EXE_inst_table[`LWR];
     wire EXE_is_store = EXE_inst_table[`SH] | EXE_inst_table[`SW] | EXE_inst_table[`SB] | EXE_inst_table[`SWL] | EXE_inst_table[`SWR];
     wire addr_is_mapped = (EXE_alu_result[31] == 1'b0)  || (EXE_alu_result[31:30] == 2'b11);
     wire addr_is_k0 = (EXE_alu_result[31:28] >= 4'h8) && (EXE_alu_result[31:28] <4'hA);
     wire addr_is_k1 = (EXE_alu_result[31:28] >= 4'hA) && (EXE_alu_result[31:28] <4'hC);
     assign EXE_paddr_f = (addr_is_k0 || addr_is_k1) ? {3'b0,EXE_alu_result[28:0]}:EXE_alu_result;
     assign EXE_paddr = (addr_is_mapped) ? EXE_paddr_t:EXE_paddr_f;
     TLB_MEM0_bridge tmb(
       .alu_result          (EXE_alu_result_r   ),
       .s1_vpn2             (s1_vpn2            ),
       .s1_d                (s1_d               ),
       .s1_v                (s1_v               ),
       .s1_odd_page         (s1_odd_page        ),
       .s1_found            (s1_found           ),
       .s1_pfn              (s1_pfn             ),
       .paddr               (EXE_paddr_t        ),
       .TLB_invalid_L       (EXE_TLB_invalid_L_t ),
       .TLB_invalid_S       (EXE_TLB_invalid_S_t ),
       .TLB_refill_L        (EXE_TLB_refill_L_t ),
       .TLB_refill_S        (EXE_TLB_refill_S_t  ),   
       .TLB_mod             (EXE_TLB_mod_t       ),
       .is_store            (EXE_is_store      ),
       .ins_load            (EXE_ins_load      ),
       .is_cache            (EXE_is_cache      )
    );

    always@(posedge clk)
    if(reset || flush) 
      EXE_alu_result_r <= 0;
    else if((EXE_is_store || EXE_ins_load) && addr_is_mapped)
      EXE_alu_result_r <= EXE_alu_result;
    //流水线寄存器
    wire EXE_wr = EXE_allowin & ID_EXE_valid;   
    EXE_reg exe_reg(
        .clk                          (clk),
        .reset                        (reset),
        .flush                        (flush),
        .EXE_wr                       (EXE_wr),
        //input reg signals
        .ID_hit					      (ID_hit),
	    .ID_branch_type			      (ID_branch_type),
        .ID_predict_pc_dir            (ID_predict_pc_dir),
        .ID_inst_refetch              (ID_inst_refetch),
        .ID_is_branch                 (ID_is_branch),          
        .ID_inst_table                (ID_inst_table),          
        .ID_alu_src1                  (ID_alu_src1),          
        .ID_alu_src2                  (ID_alu_src2),          
        .ID_alu_control               (ID_alu_control),          
        .ID_add_sub_sign              (ID_add_sub_sign),          
        .ID_ctrl_reg_write            (ID_ctrl_reg_write),              
        .ID_write_reg                 (ID_write_reg),      
        .ID_ctrl_write                (ID_ctrl_write),          
        .ID_hi_ctrl_write             (ID_hi_ctrl_write),          
        .ID_lo_ctrl_write             (ID_lo_ctrl_write),              
        .ID_cp0_write_en              (ID_cp0_write_en),          
        .ID_cp0_write_reg             (ID_cp0_write_reg),          
        .ID_exception_info            (ID_exception_info),              
        .ID_badvaddr                  (ID_badvaddr),      
        .ID_pc                        (ID_pc),  
        .ID_rf_data                   (ID_rf_data),  
        .ID_branch_hit                (ID_branch_hit),
        .ID_branch_next_pc            (ID_branch_next_pc    ),
        .ID_predict_pc                (ID_predict_pc        ),  
        .ID_unhit                     (ID_unhit             ),
        .ID_cache_op                  (ID_cache_op          ),
        .ID_is_branch_likely          (ID_is_branch_likely  ),
        .ID_branch_likely_hit         (ID_branch_likely_hit ),
        .ID_is_jr                     (ID_is_jr             ),
        //output reg signals  
        .EXE_hit                      (EXE_hit),
        .EXE_branch_type              (EXE_branch_type),
        .EXE_predict_pc_dir           (EXE_predict_pc_dir),
        .EXE_inst_refetch             (EXE_inst_refetch),
        .EXE_is_branch                (EXE_is_branch),          
        .EXE_inst_table               (EXE_inst_table),          
        .EXE_alu_src1                 (EXE_alu_src1),          
        .EXE_alu_src2                 (EXE_alu_src2),          
        .EXE_alu_control              (EXE_alu_control),          
        .EXE_add_sub_sign             (EXE_add_sub_sign),          
        .EXE_ctrl_reg_write           (EXE_ctrl_reg_write_o),              
        .EXE_write_reg                (EXE_write_reg),
        .EXE_ctrl_write               (EXE_ctrl_write),
        .EXE_hi_ctrl_write            (EXE_hi_ctrl_write),
        .EXE_lo_ctrl_write            (EXE_lo_ctrl_write),
        .EXE_cp0_write_en             (EXE_cp0_write_en),
        .EXE_cp0_write_reg            (EXE_cp0_write_reg),
        .EXE_exception_info           (EXE_exception_info_i),
        .EXE_badvaddr                 (EXE_badvaddr),
        .EXE_pc                       (EXE_pc),
        .EXE_rf_data                  (EXE_rf_data),
        .EXE_branch_hit               (EXE_branch_hit),
        .EXE_branch_next_pc           (EXE_branch_next_pc),
        .EXE_predict_pc               (EXE_predict_pc    ),
        .EXE_unhit                    (EXE_unhit         ),
        .EXE_cache_op                 (EXE_cache_op      ),
        .EXE_is_branch_likely         (EXE_is_branch_likely),
        .EXE_branch_likely_hit        (EXE_branch_likely_hit),
        .EXE_is_jr                    (EXE_is_jr            ),
        .EXE_btb_branch_pc            (EXE_btb_branch_pc    )
    );
    
    
	//前�??
	always@(*)
	 if(!EXE_valid)
	   sel_forward = 2'b00;
	 else begin
	   sel_forward[0] = (EXE_reg1 == EXE_write_reg && EXE_ctrl_reg_write);
	   sel_forward[1] = (EXE_reg2 == EXE_write_reg && EXE_ctrl_reg_write);
	 end 


    assign EXE_forward = {
        EXE_valid,
        EXE_inst_table[`MFC0],
        EXE_inst_table[`MFHI],
        EXE_inst_table[`MFLO],
        EXE_is_cloz,
        EXE_ins_load,
        sel_forward,
        EXE_alu_result
    };
	 
	 //乘法器EXE部分
    reg [2:0] mult_count;
    reg mult_busy;
    reg mult_done;

	wire [32:0] mult_x = (EXE_inst_table[`MULT] | EXE_inst_table[`MUL]| EXE_inst_table[`MADD] | EXE_inst_table[`MSUB])? {EXE_alu_src1[31],EXE_alu_src1}:{1'b0,EXE_alu_src1};
	wire [32:0] mult_y = (EXE_inst_table[`MULT] | EXE_inst_table[`MUL]| EXE_inst_table[`MADD] | EXE_inst_table[`MSUB])? {EXE_alu_src2[31],EXE_alu_src2}:{1'b0,EXE_alu_src2};
    
    multiplier m_s (
        .CLK(clk),
        .A(mult_x),
        .B(mult_y),
        .P(EXE_mult_pro)
    );



    always@(posedge clk)
     if(reset || flush) mult_count <= 3'b0;
     else if(EXE_wr) mult_count <= 3'd1;
     else if(mult_busy && mult_count != 0) mult_count <= mult_count - 1;

    always@(posedge clk)
     if(reset || flush) mult_busy <= 0;
     else if(mult_count == 0) mult_busy <= 0;
     else if(EXE_is_mult && !mult_done) mult_busy <= 1;

    always@(posedge clk)
     if(reset || flush) mult_done <= 0;
     else if(mult_busy && mult_count == 0) mult_done <= 1;
     else if(EXE_wr)    mult_done <= 0;
    //除法�??
    

    wire [31:0] sign_s_axis_divisor_tdata    = EXE_alu_src2;
    wire [31:0] sign_s_axis_dividend_tdata   = EXE_alu_src1;
    wire [31:0] unsign_s_axis_divisor_tdata  = EXE_alu_src2;
    wire [31:0] unsign_s_axis_dividend_tdata = EXE_alu_src1;
    wire sign_s_axis_divisor_tready, sign_s_axis_dividend_tready, unsign_s_axis_divisor_tready, unsign_s_axis_dividend_tready;

    wire sign_s_axis_dividend_tvalid   = (EXE_inst_table[`DIV]  & EXE_valid & !div_busy & !((MEM0_is_eret | MEM0_is_ex) & MEM0_valid) & !flush) ;
    wire sign_s_axis_divisor_tvalid    = (EXE_inst_table[`DIV]  & EXE_valid & !div_busy & !((MEM0_is_eret | MEM0_is_ex) & MEM0_valid) & !flush) ;
    wire unsign_s_axis_divisor_tvalid  = (EXE_inst_table[`DIVU] & EXE_valid & !div_busy & !((MEM0_is_eret | MEM0_is_ex) & MEM0_valid) & !flush) ;
    wire unsign_s_axis_dividend_tvalid = (EXE_inst_table[`DIVU] & EXE_valid & !div_busy & !((MEM0_is_eret | MEM0_is_ex) & MEM0_valid) & !flush) ;
    
    wire [63:0] div_pro = (sign_m_axis_dout_tvalid)? sign_m_axis_dout_tdata:
                     (unsign_m_axis_dout_tvalid)? unsign_m_axis_dout_tdata:64'b0;

    assign div_EXE_to_MEM0 = div_pro;

    reg div_wait, udiv_wait;
    always @(posedge clk ) begin
        if(reset)
            div_wait <= 1'b0;
        if((sign_s_axis_dividend_tvalid && sign_s_axis_divisor_tvalid) && (!sign_s_axis_divisor_tready && !sign_s_axis_dividend_tready))
            div_wait <= 1'b1;
        else if(div_wait && (sign_s_axis_divisor_tready && sign_s_axis_dividend_tready))
            div_wait <= 1'b0;
    end

    always @(posedge clk ) begin
        if(reset)
            udiv_wait <= 1'b0;
        if((unsign_s_axis_divisor_tvalid && unsign_s_axis_dividend_tvalid) && (!unsign_s_axis_dividend_tready && !unsign_s_axis_divisor_tready))
            udiv_wait <= 1'b1;
        else if(udiv_wait && (unsign_s_axis_divisor_tready && unsign_s_axis_dividend_tready))
            udiv_wait <= 1'b0;
    end

`ifndef VERILATOR
    div_sign d_s(
    .s_axis_divisor_tdata       (sign_s_axis_divisor_tdata),
    .s_axis_divisor_tvalid      (sign_s_axis_divisor_tvalid | div_wait),
    .s_axis_divisor_tready      (sign_s_axis_divisor_tready),
    .s_axis_dividend_tdata      (sign_s_axis_dividend_tdata),
    .s_axis_dividend_tvalid     (sign_s_axis_dividend_tvalid | div_wait),
    .s_axis_dividend_tready     (sign_s_axis_dividend_tready),
    .m_axis_dout_tdata          (sign_m_axis_dout_tdata),
    .m_axis_dout_tvalid         (sign_m_axis_dout_tvalid),
    .aclk                       (clk)
    );

    div_unsign d_us(
    .s_axis_divisor_tdata       (unsign_s_axis_divisor_tdata),
    .s_axis_divisor_tvalid      (unsign_s_axis_divisor_tvalid | udiv_wait),
    .s_axis_divisor_tready      (unsign_s_axis_divisor_tready),
    .s_axis_dividend_tdata      (unsign_s_axis_dividend_tdata),
    .s_axis_dividend_tvalid     (unsign_s_axis_dividend_tvalid | udiv_wait),
    .s_axis_dividend_tready     (unsign_s_axis_dividend_tready),
    .m_axis_dout_tdata          (unsign_m_axis_dout_tdata),
    .m_axis_dout_tvalid         (unsign_m_axis_dout_tvalid),
    .aclk                       (clk)
    );
`else
    assign sign_m_axis_dout_tvalid      = sign_s_axis_dividend_tvalid & sign_s_axis_divisor_tvalid;
    assign unsign_m_axis_dout_tvalid    = unsign_s_axis_dividend_tvalid & unsign_s_axis_divisor_tvalid;
    assign sign_m_axis_dout_tdata       = {$signed(sign_s_axis_dividend_tdata) / $signed(sign_s_axis_divisor_tdata), $signed(sign_s_axis_dividend_tdata) % $signed(sign_s_axis_divisor_tdata)};
    assign unsign_m_axis_dout_tdata     = {unsign_s_axis_dividend_tdata / unsign_s_axis_divisor_tdata,  unsign_s_axis_dividend_tdata % unsign_s_axis_divisor_tdata};
`endif
    
    //流水线暂�??
`ifndef VERILATOR
    assign div_data_ok = (sign_s_axis_dividend_tvalid & sign_s_axis_divisor_tvalid)|
                     (unsign_s_axis_dividend_tvalid & unsign_s_axis_divisor_tvalid);
    always@(posedge clk)
     if(reset)
       div_busy <= 1'b0;
     else if(div_data_ok)
       div_busy <= 1'b1;
     else if(unsign_m_axis_dout_tvalid | sign_m_axis_dout_tvalid)
       div_busy <= 1'b0;
`else
    always@(*) div_busy = 1'b0;
    assign div_data_ok = 1'b0;
    assign div_done = 1'b1;
`endif

     //中断冲突处理
	assign EXE_int_hazard = (EXE_cp0_write_en && (EXE_cp0_write_reg == 8'b01100000 || EXE_cp0_write_reg == 8'b01101000));

    //clo,clz计算
    assign       EXE_is_cloz     = EXE_inst_table[`CLO] || EXE_inst_table[`CLZ];
    wire         EXE_cloz_option = EXE_inst_table[`CLO];
    wire [31:0]  EXE_cloz_value  = EXE_alu_src1 ;
    wire [31:0]  EXE_cloz_count;

    clo_clz_count cloz(
        .option (EXE_cloz_option),
        .value  (EXE_cloz_value ),
        .count  (EXE_cloz_count )
    ); 
    wire do_move =((EXE_alu_src2 == 32'b0) && EXE_inst_table[`MOVZ]) || ((EXE_alu_src2 != 32'b0) && EXE_inst_table[`MOVN]);
    assign EXE_ctrl_reg_write = (EXE_inst_table[`MOVZ] || EXE_inst_table[`MOVN]) ? do_move: EXE_ctrl_reg_write_o;
    assign EXE_alu_result = 
                            EXE_is_cloz            ? EXE_cloz_count:
                            do_move                ? EXE_alu_src1:
                            EXE_alu_result_o;

    //movn,movz


endmodule
