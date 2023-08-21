`include "lib/defines.v"
`include "lib/cache_define.v"

module mycpu_top(
	    input [5:0]ext_int,
        input aclk,
        input aresetn,

		//axi
		//ar
		output [3 :0] 	arid         ,
		output [31:0] 	araddr       ,
		output [7 :0] 	arlen        ,
		output [2 :0] 	arsize       ,
		output [1 :0] 	arburst      ,
		output [1 :0] 	arlock       ,
		output [3 :0] 	arcache      ,
		output [2 :0] 	arprot       ,
		output        	arvalid      ,
		input         	arready      ,
		//r           	
		input  [3 :0] 	rid          ,
		input  [31:0] 	rdata        ,
		input  [1 :0] 	rresp        ,
		input         	rlast        ,
		input         	rvalid       ,
		output        	rready       ,
		//aw          	
		output [3 :0] 	awid         ,
		output [31:0] 	awaddr       ,
		output [7 :0] 	awlen        ,
		output [2 :0] 	awsize       ,
		output [1 :0] 	awburst      ,
		output [1 :0] 	awlock       ,
		output [3 :0] 	awcache      ,
		output [2 :0] 	awprot       ,
		output        	awvalid      ,
		input         	awready      ,
		//w          	
		output [3 :0] 	wid          ,
		output [31:0] 	wdata        ,
		output [3 :0] 	wstrb        ,
		output        	wlast        ,
		output        	wvalid       ,
		input         	wready       ,
		//b           
		input  [3 :0] 	bid          ,
		input  [1 :0] 	bresp        ,
		input         	bvalid       ,
		output        	bready       ,

		//debug
		output [31:0]   debug_wb_pc,
		output [3:0]    debug_wb_rf_wen,
		output [4:0]    debug_wb_rf_wnum,
		output [31:0]   debug_wb_rf_wdata
    );

    //定义重置
    reg reset;
    always@(*) reset = ~aresetn;

	wire clk;
	assign clk = aclk;
	//cp0输出
	wire [2:0]	k0;
	wire [31:0] TagLo;

	//定义刷新
	wire eret_flush;
	wire exception_flush;
	wire predict_fail_flush;

    //流水线输入使�???
	wire ID_allowin;
	wire EXE_allowin;
	wire MEM0_allowin;
	wire MEM_allowin;
	wire WR_allowin;
	

    //寄存器写使能
	wire pre_IF_IF_valid;
    wire IF_ID_valid;
	wire ID_EXE_valid;
	wire EXE_MEM0_valid;
	wire MEM0_MEM_valid;
	wire MEM_WR_valid;

    //前�??
	wire [`EXE_FORWARD_WD-1:0]     EXE_forward;
	wire [`MEM0_FORWARD_WD-1:0]    MEM0_forward;
	wire [`MEM_FORWARD_WD-1:0]     MEM_forward;
	wire [`WR_FORWARD_WD-1:0]     WR_forward;

    //读寄存器
	wire [`READ_REGISTER-1:0]   read_register;
	wire [3:0] sel_nextpc;

    //数据传�??
	wire [`PRE_IF_TO_IF_WD-1:0] 		pre_IF_to_IF_bus;
	wire [`IF_TO_ID_WD-1:0]     		IF_to_ID_bus;
    wire [`ID_TO_PRE_IF_BUS_WD-1:0]     ID_to_pre_IF_bus;
	wire [`ID_TO_EXE_WD-1:0]    		ID_to_EXE_bus;
	wire [`EXE_TO_MEM0_WD-1:0]    		EXE_to_MEM0_bus;
	wire [`MEM0_TO_MEM_WD-1:0]    		MEM0_to_MEM_bus;
	wire [`MEM_TO_WB_WD-1:0]    		MEM_to_WR_bus;
	wire [`WR_TO_ID_WD-1:0]     		WR_to_ID_bus;
	
    //华莱士树乘法  
	wire [`MULTI_EXE_TO_MEM0_WD-1:0] multi_EXE_to_MEM0;
	wire [`MULTI_MEM0_TO_MEM_WD-1:0] multi_MEM0_to_MEM;

	//除法�???
	wire [`DIV_EXE_TO_MEM0_WD-1:0]  div_EXE_to_MEM0;
	wire [`DIV_MEM0_TO_MEM_WD-1:0]  div_MEM0_to_MEM;

	//cp0
	wire [31:0] cp0_output_data;
	wire [`WR_to_cp0_bus-1:0] WR_to_cp0_bus;
	wire [31:0] WR_EPC_info;
	wire 		EXE_is_ex;
	wire		EXE_is_eret;			
	wire  		MEM_is_ex;
	wire 		MEM_is_eret;
	wire        WR_is_ex;   
	wire 		WR_is_eret;
	wire [4:0] 	WR_cache_op;
	wire [31:0] WR_cache_paddr;
	wire [1:0]  WR_cache_target;
	wire		WR_cache_op_done;
	
	wire		has_int;	
	
	wire		IF_allowin;	
	wire 		IF_ID_is_branch;	
	wire 		pre_IF_sel_next_pc_valid;
	wire		MEM_valid_to_MEM0;

	wire [31:0] ex_addr;

	//MEM0
	wire		MEM0_valid	   	   ;
	wire		MEM0_is_ex         ;
	wire		MEM0_is_eret       ;
	wire		MEM0_int_hazard    ;

	wire		data_req_busy      ;

	//tlb指令冲突
	wire				ID_inst_refetch_o	;
	wire				EXE_inst_refetch_o	;
	wire				MEM0_inst_refetch_o	;
	wire				MEM_inst_refetch_o	;
	wire				WR_inst_refetch_o	;
	wire				ID_inst_refetch		;
	wire				EXE_inst_refetch	;
	wire				MEM0_inst_refetch	;
	wire				MEM_inst_refetch	;
	wire				WR_inst_refetch		;

	
	//类sram流水线控�???
	wire [31:0] ID_pre_IF_pc ;
	//中断冲突处理
	wire ID_int_hazard;
    wire EXE_int_hazard;	
    wire MEM_int_hazard;	
    wire WR_int_hazard;
	

	wire 				MEM_is_mtc0			;
	wire				WR_is_mtc0			;
	wire [31:0]			WR_pc				;
	wire				addr_error			;


	//icache
	wire [`TAG_WIDTH-1   : 0]   icache_tag   	;
	wire [`INDEX_WIDTH-1 : 0] 	icache_index 	;
	wire [`OFFSET_WIDTH-1: 0]	icache_offset	;
	wire 						icache_op		;
	wire						icache_valid	;
	wire [3				 : 0]   icache_wstrb	;
	wire [31			 : 0]	icache_wdata	;
	wire 						icache_addr_ok	;
	wire						icache_data_ok	;
	wire [31			 : 0]	icache_rdata	;
	wire						icache_uncached ;

	wire 						icache_rd_req	;
	wire [2				 : 0]	icache_rd_type  ;
	wire [31			 : 0]	icache_rd_addr	;
	wire 						icache_rd_rdy	;
	wire 						icache_ret_valid;
	wire						icache_ret_last	;
	wire [31			 : 0]	icache_ret_data ;
	wire						icache_op_done	;	//cache inst
	

	//dcache
	wire [`TAG_WIDTH-1   : 0]   dcache_tag   	;
	wire [`INDEX_WIDTH-1 : 0] 	dcache_index 	;
	wire [`OFFSET_WIDTH-1: 0]	dcache_offset	;
	wire 						dcache_op		;
	wire						dcache_valid	;
	wire [3				 : 0]   dcache_wstrb	;
	wire [31			 : 0]	dcache_wdata	;
	wire 						dcache_addr_ok	;
	wire						dcache_data_ok	;
	wire [31			 : 0]	dcache_rdata	;
	wire						dcache_uncached ;
	wire [2				 : 0]	dcache_lstype	;

	wire 						dcache_rd_req	;
	wire [2				 : 0]	dcache_rd_type  ;
	wire [31			 : 0]	dcache_rd_addr	;
	wire 						dcache_rd_rdy	;
	wire 						dcache_ret_valid;
	wire						dcache_ret_last	;
	wire [31			 : 0]	dcache_ret_data ;
	wire						dcache_op_done  ;	//cache inst
	

	wire 						dcache_wr_req		;
	wire [127			 : 0]	dcache_wr_data		;
	wire [3				 : 0]	dcache_wr_type  	;
	wire [31			 : 0]	dcache_wr_addr		;
	wire [3				 : 0]	dcache_wr_wstrb		;


	wire					    dcache_wr_rdy		;

	`ifdef VERILATOR
	wire [31			 : 0]	GPR [31:0]		;
	wire [31			 : 0]	IF_inst_wire	;
	`endif

	//测试信号
	wire	[31:0]				dcache_count_miss  ;
	wire	[31:0]				icache_count_miss  ;
	wire	[31:0]				dcache_count_cached;
	wire	[31:0]				icache_count_cached;

	wire          i_dcache_rd_req     ;
	wire [31:0]   i_dcache_rd_addr    ;
	wire [2 :0]   i_dcache_rd_type    ;
	wire          i_dcache_wr_req     ;
	wire [2 :0]   i_dcache_wr_type    ;
	wire [31:0]   i_dcache_wr_addr    ;
	wire[127:0]   i_dcache_wr_data    ;
	wire [3 :0]   i_dcache_wr_wstrb   ;
	wire          i_dcache_wr_uncached;

	wire          o_dcache_rd_req     ;
	wire [31:0]   o_dcache_rd_addr    ;
	wire [2 :0]   o_dcache_rd_type    ;
	wire          o_dcache_wr_req     ;
	wire [2 :0]   o_dcache_wr_type    ;
	wire [31:0]   o_dcache_wr_addr    ;
	wire[127:0]   o_dcache_wr_data    ;
	wire [3 :0]   o_dcache_wr_wstrb   ;
	wire          o_dcache_wr_uncached;
//wait状�?�判�?
	wire 	 wait_wake;
	wire     wait_flush;
	reg      wait_status;

	always @(posedge clk ) begin
		if(reset)
		   wait_status <= 0;
		else if (wait_flush)
		   wait_status <= 1;
		else if(wait_wake)
		   wait_status <= 0;
	end

	assign wait_wake = has_int;


	cpu_axi_interface cpu_axi_interface_bridge(
	  .clock                (aclk               ),
	  .reset               	(!aresetn           ),

	  .icache_rd_req		(icache_rd_req		),
	  .icache_rd_addr		(icache_rd_addr		),
	  .icache_rd_type		(icache_rd_type		),
	  .icache_rd_rdy		(icache_rd_rdy		),
	  .icache_ret_valid		(icache_ret_valid	),
	  .icache_ret_last		(icache_ret_last	),
	  .icache_ret_data		(icache_ret_data	),
	  .icache_wr_req		(icache_wr_req		),
	  .icache_wr_type		(icache_wr_type		),
	  .icache_wr_addr		(icache_wr_addr		),
	  .icache_wr_data		(icache_wr_data		),
	  .icache_wr_wstrb		(icache_wr_wstrb	),
	  .icache_wr_rdy		(icache_wr_rdy		),

	  //data sram-like 
	  .dcache_rd_req		(dcache_rd_req		),
	  .dcache_rd_addr		(dcache_rd_addr		),			
	  .dcache_rd_type		(dcache_rd_type		),	
	  .dcache_rd_rdy		(dcache_rd_rdy		),	
	  .dcache_ret_valid		(dcache_ret_valid	),
	  .dcache_ret_last		(dcache_ret_last	),
	  .dcache_ret_data		(dcache_ret_data	),
	  .dcache_wr_req		(dcache_wr_req		),
	  .dcache_wr_type		(dcache_wr_type		),
	  .dcache_wr_addr		(dcache_wr_addr		),
	  .dcache_wr_data		(dcache_wr_data		),
	  .dcache_wr_wstrb		(dcache_wr_wstrb	),
	  .dcache_wr_rdy		(dcache_wr_rdy		),

	  //axi
	  //ar
	  .arid   				(arid   			),
	  .araddr 				(araddr 			),
	  .arlen  				(arlen  			),
	  .arsize 				(arsize 			),
	  .arburst				(arburst			),
	  .arlock 				(arlock 			),
	  .arcache				(arcache			),
	  .arprot 				(arprot 			),
	  .arvalid				(arvalid			),
	  .arready				(arready			),

	  //r
	  .rid   				(rid   				),
	  .rdata 				(rdata 				),
	  .rresp 				(rresp 				),
	  .rlast 				(rlast 				),
	  .rvalid				(rvalid				),
	  .rready				(rready				),

	  //aw
	  .awid   				(awid   			),
	  .awaddr 				(awaddr 			),
	  .awlen  				(awlen  			),
	  .awsize 				(awsize 			),
	  .awburst				(awburst			),
	  .awlock 				(awlock 			),
	  .awcache				(awcache			),
	  .awprot 				(awprot 			),
	  .awvalid				(awvalid			),
	  .awready				(awready			),

	  //w
	  .wid   				(wid   				),
	  .wdata 				(wdata 				),
	  .wstrb 				(wstrb 				),
	  .wlast 				(wlast 				),
	  .wvalid				(wvalid				),
	  .wready				(wready				),

	  //b
	  .bid   				(bid   				),
	  .bresp 				(bresp 				),
	  .bvalid				(bvalid				),
	  .bready				(bready				)
	);		

	wire[`VPN2_WD]		s0_vpn2;
	wire          	    s0_odd_page;
	wire[`ASID_WD]      s0_asid;
	wire          	    s0_found;
	wire[`TLB_WD] 	    s0_index;
	wire[`PFN_WD] 	    s0_pfn;
	wire[`C_WD]   	    s0_c;
	wire          	    s0_d;
	wire          	    s0_v;		
    wire                    	 ID_is_branch    ;
	wire 						 branch_hit      ;	
	wire [31:0]				     branch_next_pc  ;	
	wire 						 branch_ready	 ;
	wire [31:0]					 branch_pc		 ;	
	wire                         EXE_is_branch   ;
	wire 						 pc_predict_fail ;
	wire [31:0]					 EXE_predict_pc	 ;
	wire 						 EXE_predict_wr	 ;
	wire [31:0]					 IF_btb_branch_pc;	
	wire						 IF_predict_pc_dir;
	wire     				     branch_likely_clear;
	wire 						 EXE_hit;
    wire [1:0] 					 EXE_branch_type;
	wire                         EXE_is_return;
    wire                         EXE_is_call  ;
	wire 						EXE_branch_likely_hit;	
	wire 						EXE_is_branch_likely;
	wire						inst_req_busy ;
	pipeline_pre_IF pre_IF_stage(
	  .clk                  (clk                ),
	  .reset                (reset              ),
	  .eret_flush			(eret_flush			),
	  .exception_flush		(exception_flush	),
	  .inst_refetch_flush	(inst_refetch_flush	),
	  .predict_fail_flush	(predict_fail_flush	),

	  .WR_pc				(WR_pc				),
	  .EXE_is_branch       	(EXE_is_branch      ),
	  .EXE_hit              (EXE_hit			),
      .EXE_branch_type      (EXE_branch_type	),
	  .IF_allowin           (IF_allowin         ),
	  .has_int				(has_int			),
	  .WR_EPC_info			(WR_EPC_info		),
	  .icache_addr_ok		(icache_addr_ok		),
	  .icache_data_ok		(icache_data_ok		),
	  .icache_valid 		(icache_valid		),
	  .icache_tag			(icache_tag			),
	  .icache_index 		(icache_index		),
	  .icache_offset 		(icache_offset		),
	  .icache_uncached		(icache_uncached	),		
	  .pre_IF_IF_valid		(pre_IF_IF_valid	),
	  .pre_IF_to_IF_bus		(pre_IF_to_IF_bus	),
	  .addr_error			(addr_error			),

	  .wait_flush			(wait_flush			),
	  .wait_status			(wait_status		),

	  .branch_likely_clear	(branch_likely_clear),
	  .EXE_branch_likely_hit(EXE_branch_likely_hit),

	  //tlb
	  .s0_vpn2    			(s0_vpn2			),
	  .s0_odd_page			(s0_odd_page		),
	  .s0_found   			(s0_found			),
	  .s0_index   			(s0_index			),
	  .s0_pfn     			(s0_pfn				),
	  .s0_c       			(s0_c				),
	  .s0_d       			(s0_d				),
	  .s0_v			        (s0_v				),
	  .ex_addr				(ex_addr			),

	  .pre_IF_branch_hit	(branch_hit			),
	  .pre_IF_branch_next_pc(branch_next_pc		),
	  .pre_IF_branch_ready	(branch_ready		),
	  .pre_IF_branch_pc		(branch_pc			),
	  .EXE_predict_pc		(EXE_predict_pc		),
	  .EXE_predict_wr		(EXE_predict_wr		),
	  .IF_predict_pc_dir	(IF_predict_pc_dir	),
	  .IF_btb_branch_pc		(IF_btb_branch_pc	),
	  .EXE_is_return        (EXE_is_return      ),
      .EXE_is_call          (EXE_is_call        ),
	  .EXE_is_branch_likely	(EXE_is_branch_likely),

	  //k0
	  .k0					(k0),
	  .inst_req_busy 		(inst_req_busy		)
	);


	icache inst_cache(
		.clock				(clk				),
		.reset				(reset				),
		.valid 				(icache_valid		),
		.op 				(0					),		//icache doesn't write
		.index 				(icache_index		),
		.tag 				(icache_tag			),
		.offset 			(icache_offset		),
		.addr_ok 			(icache_addr_ok 	),
		.data_ok 			(icache_data_ok 	),
		.rdata 				(icache_rdata 		),
		.uncached 			(icache_uncached	),
		.rd_req 			(icache_rd_req 		),
		.rd_type 			(icache_rd_type 	),
		.rd_addr 			(icache_rd_addr 	),
		.rd_rdy 			(icache_rd_rdy 		),
		.ret_valid 			(icache_ret_valid 	),
		.ret_last 			(icache_ret_last 	),
		.ret_data 			(icache_ret_data 	),
		.cache_op_en		(WR_cache_target[0]	),
		.cache_op			(WR_cache_op[4:2]	),
		.cache_tag			(WR_cache_paddr[31:12]),
		.cache_index		(WR_cache_paddr[11:4]),
		.cache_offset		(WR_cache_paddr[ 3:0]),
		.tag_input			(TagLo				),
		// .tag_output			()
		.cache_op_done		(icache_op_done		)
	);

    pipeline_IF IF_stage(   
	  .clk                  (clk                ),
	  .reset                (reset              ),
	  .eret_flush			(eret_flush			),
	  .exception_flush		(exception_flush	),

	  .wait_flush			(wait_flush			),
	  .wait_status			(wait_status		),

	  .branch_likely_clear	(branch_likely_clear),
	  .inst_req_busy		(inst_req_busy		),

	  //tlb_refetch
	  .ID_inst_refetch_o	(ID_inst_refetch_o	),
	  .EXE_inst_refetch_o	(EXE_inst_refetch_o	),
	  .MEM0_inst_refetch_o  (MEM0_inst_refetch_o),
	  .MEM_inst_refetch_o	(MEM_inst_refetch_o	),
	  .WR_inst_refetch_o	(WR_inst_refetch_o	),
	  .inst_refetch_flush	(inst_refetch_flush	),
	  
	  .icache_rdata	        (icache_rdata	    ),
	  .icache_data_ok		(icache_data_ok     ),
	  .ID_allowin           (ID_allowin         ),
	  .IF_allowin           (IF_allowin         ),
	  .IF_ID_valid          (IF_ID_valid        ),
	  .IF_to_ID_bus         (IF_to_ID_bus       ),
	  .pre_IF_to_IF_bus		(pre_IF_to_IF_bus  	),
	  .pre_IF_to_IF_valid	(pre_IF_IF_valid    ),
	  .addr_error			(addr_error			),
`ifdef VERILATOR
	  .IF_inst_wire			(IF_inst_wire		),
`endif
	  .IF_branch_ready		(branch_ready		),
	  .IF_branch_pc			(branch_pc			),
	  .IF_predict_pc_dir	(IF_predict_pc_dir	),
	  .IF_btb_branch_pc		(IF_btb_branch_pc	)
	  );

	//ID_stage
	wire 						 ID_predict_pc_dir;	
	wire[`INST_TABLE_WD-1:0]	 ID_inst_table   ;
	wire[31:0]              	 ID_alu_src1     ;
	wire[31:0]              	 ID_alu_src2     ;
	wire[11:0]              	 ID_alu_control  ;
	wire                    	 ID_add_sub_sign ;
	wire                    	 ID_ctrl_reg_writ;
	wire[4:0]               	 ID_write_reg    ;
	wire                    	 ID_ctrl_write   ;
	wire                    	 ID_hi_ctrl_write;
	wire                    	 ID_lo_ctrl_write;
	wire                    	 ID_cp0_write_en ;
	wire[7:0]                    ID_cp0_write_reg;
	wire[`EX_INFO-1:0]      	 ID_exception_info;
	wire[31:0]              	 ID_badvaddr     ;
	wire[31:0]              	 ID_pc           ;
	wire[31:0]              	 ID_rf_data      ;
	wire 					     ID_branch_hit   ;
	wire [31:0] 				 ID_branch_next_pc;
	wire [31:0]					 ID_predict_pc	 ;	
	wire 						 ID_unhit;	
	wire [4:0]					 ID_cache_op;
	wire						 ID_likely_pc	;
	wire 						 ID_is_branch_likely;
	wire 						 ID_branch_likely_hit;
	wire 						 ID_hit;
    wire [1:0] 					 ID_branch_type;
	wire [31:0] 			     ID_btb_branch_pc;
	wire  						 ID_is_jr;
	`ifdef VERILATOR
	wire [31:0]					 GPR [31:0]		 ;
	`endif

    pipeline_ID ID_stage(
	 .clk                   (clk                ),
	 .reset                 (reset              ),
	 .eret_flush			(eret_flush			),
	 .exception_flush		(exception_flush	),
	 .inst_refetch_flush	(inst_refetch_flush	),
	 .ID_inst_refetch_o		(ID_inst_refetch_o	),

	 .wait_flush			(wait_flush			),
	 .wait_status			(wait_status		),

	 .branch_likely_clear  	(branch_likely_clear),

	 .IF_ID_valid           (IF_ID_valid        ),
	 .EXE_allowin           (EXE_allowin        ),
	 .WR_to_ID_bus          (WR_to_ID_bus       ),
	 .ID_EXE_valid          (ID_EXE_valid       ),
	 .ID_allowin            (ID_allowin         ),
	 .IF_to_ID_bus			(IF_to_ID_bus		),
	 .read_register         (read_register      ),
	 .EXE_forward           (EXE_forward        ),
	 .MEM_forward           (MEM_forward        ),
	 .MEM0_forward			(MEM0_forward		),
	 .WR_forward            (WR_forward         ),
	 .is_ex				    (ID_is_ex			),
	 .is_eret			    (ID_is_eret			),
	 .ID_int_hazard			(ID_int_hazard		),
	 
	 .ID_predict_pc_dir		(ID_predict_pc_dir	),
	 .ID_inst_refetch		(ID_inst_refetch	),
	 .ID_is_branch    		(ID_is_branch    	),
	 .ID_inst_table   		(ID_inst_table   	),
	 .ID_alu_src1     		(ID_alu_src1     	),
	 .ID_alu_src2     		(ID_alu_src2     	),
	 .ID_alu_control  		(ID_alu_control  	),
	 .ID_add_sub_sign 		(ID_add_sub_sign 	),
	 .ID_ctrl_reg_write		(ID_ctrl_reg_write	),
	 .ID_write_reg    		(ID_write_reg    	),
	 .ID_ctrl_write   		(ID_ctrl_write   	),
	 .ID_hi_ctrl_write		(ID_hi_ctrl_write	),
	 .ID_lo_ctrl_write		(ID_lo_ctrl_write	),
	 .ID_cp0_write_en 		(ID_cp0_write_en 	),
	 .ID_cp0_write_reg		(ID_cp0_write_reg	),
	 .ID_exception_info		(ID_exception_info	),
	 .ID_badvaddr     		(ID_badvaddr     	),
	 .ID_pc           		(ID_pc           	),
	 .ID_rf_data      		(ID_rf_data      	),
	 .ID_branch_hit			(ID_branch_hit		),
	 .ID_branch_next_pc		(ID_branch_next_pc	),
	 .ID_predict_pc			(ID_predict_pc		),
	 .ID_unhit 				(ID_unhit 			),
	 .ID_cache_op 			(ID_cache_op 		),
	 .ID_is_branch_likely	(ID_is_branch_likely),
	 .ID_branch_likely_hit	(ID_branch_likely_hit),
	 .ID_hit				(ID_hit				),
	 .ID_branch_type		(ID_branch_type		),
	 .ID_is_jr 				(ID_is_jr			),
	 .ID_btb_branch_pc		(ID_btb_branch_pc	)
	 `ifdef VERILATOR
	 ,
	 .GPR					(GPR				)
	 `endif
	 );
	 
	wire[`VPN2_WD]					  s1_vpn2;
	wire          	    			  s1_odd_page;
	wire[`ASID_WD]      			  s1_asid;
	wire          	    			  s1_found;
	wire[`TLB_WD] 	    			  s1_index;
	wire[`PFN_WD] 	    			  s1_pfn;
	wire[`C_WD]   	    			  s1_c;
	wire          	    			  s1_d;
	wire          	    			  s1_v;	
	wire                              EXE_is_ex_o;
	wire 							   EXE_is_tlbp	  		   ;	 
	wire [`INST_TABLE_WD-1:0]          EXE_inst_table          ;
    wire [31:0]                        EXE_pc                  ;
    wire [31:0]                        EXE_rf_data             ;
    wire [31:0]                        EXE_alu_result          ;
    wire [4:0]                         EXE_write_reg           ;
    wire                               EXE_hi_ctrl_write       ;
    wire                               EXE_lo_ctrl_write       ;
    
    wire [31:0]                        EXE_badvaddr            ;
    wire [`EX_INFO-1:0]                EXE_exception_info_o    ;
    wire                               EXE_cp0_write_en        ;
    wire [7:0]                         EXE_cp0_write_reg       ;
    wire                               EXE_ctrl_write          ;
    wire                               EXE_ctrl_reg_write      ;
	wire 							   EXE_unhit   			   ;
	wire [4:0]						   EXE_cache_op			   ;
	wire [65:0]						   EXE_mult_pro 		   ;
	wire [31:0]						   EXE_paddr			   ;
	pipeline_EXE EXE_stage(
	.clk               		(clk               	),
	.reset             		(reset             	),
	.eret_flush        		(eret_flush        	),
	.exception_flush   		(exception_flush   	),
	.inst_refetch_flush		(inst_refetch_flush	),
	.predict_fail_flush		(predict_fail_flush	),
	.EXE_inst_refetch_o		(EXE_inst_refetch_o	),

	.branch_likely_clear	(branch_likely_clear),
	.EXE_branch_likely_hit	(EXE_branch_likely_hit),

	.wait_flush				(wait_flush			),
	.wait_status			(wait_status		),
	
	.ID_EXE_valid      		(ID_EXE_valid      	),
	.MEM0_allowin      		(MEM0_allowin      	),
	.EXE_MEM0_valid			(EXE_MEM0_valid		),
	.EXE_read_register 		(read_register 		),
	.MEM0_is_ex        		(MEM0_is_ex        	),
	.MEM0_is_eret      		(MEM0_is_eret      	),
	.MEM0_valid        		(MEM0_valid        	),
	.EXE_allowin       		(EXE_allowin       	),

	.EXE_forward       		(EXE_forward       	),
	.div_EXE_to_MEM0   		(div_EXE_to_MEM0   	),
	.EXE_is_ex_o         	(EXE_is_ex_o        ),
	.EXE_int_hazard    		(EXE_int_hazard    	),
	.EXE_is_tlbp			(EXE_is_tlbp		),
	.pc_predict_fail		(pc_predict_fail	),

	.MEM0_tlbp_hazard		(MEM0_tlbp_hazard	),
	.MEM_tlbp_hazard		(MEM_tlbp_hazard	),
	.WR_tlbp_hazard			(WR_tlbp_hazard		),

		//tlb
	.s1_found            	(s1_found            	),
	.s1_d                	(s1_d                	),
	.s1_v                	(s1_v                	),
	.s1_pfn              	(s1_pfn              	),
	.s1_vpn2             	(s1_vpn2             	),
	.s1_odd_page         	(s1_odd_page         	),
	
	//regs
	.ID_hit					(ID_hit				),
	.ID_branch_type			(ID_branch_type		),
	.ID_predict_pc_dir		(ID_predict_pc_dir	),
	.ID_inst_refetch		(ID_inst_refetch	),
	.ID_is_branch    		(ID_is_branch    	),
	.ID_inst_table   		(ID_inst_table   	),
	.ID_alu_src1     		(ID_alu_src1     	),
	.ID_alu_src2     		(ID_alu_src2     	),
	.ID_alu_control  		(ID_alu_control  	),
	.ID_add_sub_sign 		(ID_add_sub_sign 	),
	.ID_ctrl_reg_write		(ID_ctrl_reg_write	),
	.ID_write_reg    		(ID_write_reg    	),
	.ID_ctrl_write   		(ID_ctrl_write   	),
	.ID_hi_ctrl_write		(ID_hi_ctrl_write	),
	.ID_lo_ctrl_write		(ID_lo_ctrl_write	),
	.ID_cp0_write_en 		(ID_cp0_write_en 	),
	.ID_cp0_write_reg		(ID_cp0_write_reg	),
	.ID_exception_info		(ID_exception_info	),
	.ID_badvaddr     		(ID_badvaddr     	),
	.ID_pc           		(ID_pc           	),
	.ID_rf_data      		(ID_rf_data      	),
	.ID_branch_hit			(ID_branch_hit		),
	.ID_branch_next_pc		(ID_branch_next_pc	),
	.ID_predict_pc			(ID_predict_pc		),
	.ID_unhit 				(ID_unhit 			),
	.ID_cache_op			(ID_cache_op 		),
	.ID_is_branch_likely	(ID_is_branch_likely),
	.ID_branch_likely_hit	(ID_branch_likely_hit),
	.ID_is_jr 				(ID_is_jr			 ),
	.ID_btb_branch_pc		(ID_btb_branch_pc    ),

	.EXE_inst_refetch		(EXE_inst_refetch	 ),
	.EXE_inst_table      	(EXE_inst_table      ),
	.EXE_pc              	(EXE_pc              ),
	.EXE_rf_data         	(EXE_rf_data         ),
	.EXE_alu_result      	(EXE_alu_result      ),
	.EXE_write_reg       	(EXE_write_reg       ),
	.EXE_hi_ctrl_write   	(EXE_hi_ctrl_write   ),
	.EXE_lo_ctrl_write   	(EXE_lo_ctrl_write   ),
	.EXE_is_eret         	(EXE_is_eret         ),
	.EXE_is_branch       	(EXE_is_branch       ),
	.EXE_badvaddr        	(EXE_badvaddr        ),
	.EXE_exception_info_o	(EXE_exception_info_o),
	.EXE_cp0_write_en    	(EXE_cp0_write_en    ),
	.EXE_cp0_write_reg   	(EXE_cp0_write_reg   ),
	.EXE_ctrl_write      	(EXE_ctrl_write      ),
	.EXE_ctrl_reg_write  	(EXE_ctrl_reg_write  ),
	.EXE_unhit 				(EXE_unhit 			 ),
	.EXE_cache_op			(EXE_cache_op	     ),

	.EXE_branch_hit 		(branch_hit			 ),
	.EXE_branch_next_pc		(branch_next_pc		 ),
	.EXE_branch_ready		(branch_ready		 ),
	.EXE_branch_pc			(branch_pc			 ),
	.EXE_predict_pc			(EXE_predict_pc		 ),
	.EXE_predict_wr			(EXE_predict_wr		 ),
	.EXE_hit                (EXE_hit			 ),
    .EXE_branch_type        (EXE_branch_type	 ),
	.EXE_is_return      	(EXE_is_return       ),
    .EXE_is_call        	(EXE_is_call         ),
	.EXE_is_branch_likely	(EXE_is_branch_likely),
	.EXE_mult_pro			(EXE_mult_pro 		 ),
	.EXE_paddr				(EXE_paddr			 )
	);  


	wire [`INST_TABLE_WD-1:0]  MEM0_inst_table        ;
    wire [31:0]                MEM0_pc                ;
    wire [31:0]                MEM0_rf_data           ;
    wire [31:0]                MEM0_alu_result        ;
    wire [4:0]                 MEM0_write_reg         ;
    wire                       MEM0_hi_ctrl_write     ;
    wire                       MEM0_lo_ctrl_write     ;
    wire                       MEM0_is_branch         ;
    wire [31:0]                MEM0_badvaddr_o        ;
    wire [`EX_INFO-1:0]        MEM0_exception_info_o  ;
    wire                       MEM0_cp0_write_en      ;
    wire [7:0]                 MEM0_cp0_write_reg     ;
    wire                       MEM0_ctrl_write        ;
    wire                       MEM0_ctrl_reg_write    ;
    wire [1:0]              MEM0_data_sram_sel_hword  ;
    wire [3:0]              MEM0_data_sram_sel_word   ; 
	wire 					MEM0_unhit 				  ;
	wire [4:0]				MEM0_cache_op			  ;
	wire [31:0]				MEM0_cache_paddr	      ;
	wire [65:0] 			MEM0_mult_pro			  ;
	pipeline_MEM0 MEM0_stage(
	.clk					(clk					),            
	.reset               	(reset               	),
	.EXE_MEM0_valid      	(EXE_MEM0_valid      	),
	.MEM_allowin         	(MEM_allowin         	),
	.eret_flush          	(eret_flush          	),
	.exception_flush     	(exception_flush     	),
	.inst_refetch_flush		(inst_refetch_flush		),
	.MEM0_inst_refetch_o    (MEM0_inst_refetch_o	),

	.wait_flush				(wait_flush				),
	.wait_status			(wait_status			),

	.dcache_addr_ok   		(dcache_addr_ok		   	),
	.MEM0_read_register  	(read_register  		),

	.MEM0_tlbp_hazard		(MEM0_tlbp_hazard		),

	.MEM_is_ex           	(MEM_is_ex           	),
	.MEM_is_eret         	(MEM_is_eret         	),
	.div_EXE_to_MEM0     	(div_EXE_to_MEM0     	),
	.MEM_valid           	(MEM_valid_to_MEM0      ),
	.dcache_data_ok			(dcache_data_ok			),

	.MEM0_MEM_valid      	(MEM0_MEM_valid      	),
	.MEM0_valid_to_EXE		(MEM0_valid				),
	.MEM0_allowin        	(MEM0_allowin        	),
	.dcache_valid        	(dcache_valid        	),
	.dcache_op 		      	(dcache_op		       	),
	.dcache_wstrb			(dcache_wstrb			),
	.dcache_index			(dcache_index			),
	.dcache_tag 			(dcache_tag				),
	.dcache_offset 			(dcache_offset			),
	.dcache_uncached		(dcache_uncached		),
	.dcache_wdata			(dcache_wdata			),
	.dcache_lstype			(dcache_lstype			),
	.MEM0_forward        	(MEM0_forward        	),
	.multi_MEM0_to_MEM   	(multi_MEM0_to_MEM   	),
	.div_MEM0_to_MEM     	(div_MEM0_to_MEM     	),
	.MEM0_is_ex          	(MEM0_is_ex          	),
	.MEM0_is_eret        	(MEM0_is_eret        	),
	.MEM0_int_hazard     	(MEM0_int_hazard     	),
	.data_req_busy			(data_req_busy			),


	.s1_c					(s1_c					),

	.MEM_inst_refetch		(MEM_inst_refetch		),

	//reg
	.EXE_inst_refetch		(EXE_inst_refetch	 	),
	.EXE_inst_table      	(EXE_inst_table      	),
	.EXE_pc              	(EXE_pc              	),
	.EXE_rf_data         	(EXE_rf_data         	),
	.EXE_alu_result      	(EXE_alu_result      	),
	.EXE_write_reg       	(EXE_write_reg       	),
	.EXE_hi_ctrl_write   	(EXE_hi_ctrl_write   	),
	.EXE_lo_ctrl_write   	(EXE_lo_ctrl_write   	),
	.EXE_is_eret         	(EXE_is_eret         	),
	.EXE_is_branch       	(EXE_is_branch       	),
	.EXE_badvaddr        	(EXE_badvaddr        	),
	.EXE_exception_info_o	(EXE_exception_info_o	),
	.EXE_cp0_write_en    	(EXE_cp0_write_en    	),
	.EXE_cp0_write_reg   	(EXE_cp0_write_reg   	),
	.EXE_ctrl_write      	(EXE_ctrl_write      	),
	.EXE_ctrl_reg_write  	(EXE_ctrl_reg_write  	),
	.EXE_unhit 				(EXE_unhit 				),
	.EXE_cache_op			(EXE_cache_op			),
	.EXE_mult_pro			(EXE_mult_pro			),
	.EXE_paddr				(EXE_paddr				),

	.MEM0_inst_refetch		(MEM0_inst_refetch		),
	.MEM0_inst_table      	(MEM0_inst_table        ),
	.MEM0_pc              	(MEM0_pc                ),
	.MEM0_rf_data         	(MEM0_rf_data           ),
	.MEM0_alu_result      	(MEM0_alu_result        ),
	.MEM0_write_reg       	(MEM0_write_reg         ),
	.MEM0_hi_ctrl_write   	(MEM0_hi_ctrl_write     ),
	.MEM0_lo_ctrl_write   	(MEM0_lo_ctrl_write     ),
	.MEM0_is_branch       	(MEM0_is_branch         ),
	.MEM0_badvaddr_o      	(MEM0_badvaddr_o        ),
	.MEM0_exception_info_o	(MEM0_exception_info_o  ),
	.MEM0_cp0_write_en    	(MEM0_cp0_write_en      ),
	.MEM0_cp0_write_reg   	(MEM0_cp0_write_reg     ),
	.MEM0_ctrl_write      	(MEM0_ctrl_write        ),
	.MEM0_ctrl_reg_write  	(MEM0_ctrl_reg_write    ),
	.MEM0_data_sram_sel_hword(MEM0_data_sram_sel_hword),
	.MEM0_data_sram_sel_word(MEM0_data_sram_sel_word),
	.MEM0_unhit 			(MEM0_unhit 			),
	.MEM0_cache_op			(MEM0_cache_op			),
	.MEM0_cache_paddr		(MEM0_cache_paddr		),
	.MEM0_mult_pro			(MEM0_mult_pro			),
	
	.k0 					(k0						)
	);

	dcache data_cache(
	.clock					(clk					),
	.reset					(reset					),
	.valid 					(dcache_valid			),
	.op 					(dcache_op				),		
	.index 					(dcache_index			),
	.tag 					(dcache_tag				),
	.offset 				(dcache_offset			),
	.lstype 				(dcache_lstype			),
	.wstrb 					(dcache_wstrb			),
	.wdata 					(dcache_wdata 			),
	.addr_ok 				(dcache_addr_ok 		),
	.data_ok 				(dcache_data_ok 		),
	.rdata 					(dcache_rdata 			),
	.uncached 				(dcache_uncached		),
	.rd_req 				(dcache_rd_req 			),
	.rd_type 				(dcache_rd_type 		),
	.rd_addr 				(dcache_rd_addr 		),
	.rd_rdy 				(dcache_rd_rdy 			),
	.ret_valid 				(dcache_ret_valid 		),
	.ret_last 				(dcache_ret_last 		),
	.ret_data 				(dcache_ret_data 		),
	.wr_req 				(dcache_wr_req 			),
	.wr_type 				(dcache_wr_type 		),
	.wr_addr 				(dcache_wr_addr 		),
	.wr_wstrb 				(dcache_wr_wstrb		),
	.wr_data 				(dcache_wr_data 		),
	.wr_rdy 				(dcache_wr_rdy			),
	.cache_op_en			(WR_cache_target[1]		),
	.cache_op				(WR_cache_op[4:2]		),
	.cache_tag				(WR_cache_paddr[31:12]	),
	.cache_index			(WR_cache_paddr[11:4]	),
	.cache_offset			(WR_cache_paddr[3:0]	),
	.tag_input				(TagLo					),
	// .tag_output				(						),
	.cache_op_done			(dcache_op_done			)
	);

	wire [`INST_TABLE_WD-1:0] MEM_inst_table         ;
	wire [31:0]               MEM_pc                 ;
	wire [31:0]               MEM_rf_data            ;
	wire [31:0]               MEM_alu_result         ;
	wire [31:0]               MEM_busW_inner         ;
	wire [31:0]               MEM_badvaddr           ;
	wire                      MEM_cp0_write_en       ;
	wire [7:0]                MEM_cp0_write_reg      ;
	wire [`EX_INFO-1:0]       MEM_exception_info     ;
	wire                      MEM_is_branch          ;
	wire [4:0]                MEM_write_reg          ;
	wire [3:0]                MEM_reg_write_en       ;
	wire            		  MEM_unhit 		     ;
	wire [4:0]				  MEM_cache_op 			 ;
	wire [31:0]				  MEM_cache_paddr	     ;
	pipeline_MEM MEM_stage(
	.clk                	(clk                	),
	.reset              	(reset              	),
	.eret_flush         	(eret_flush         	),
	.exception_flush    	(exception_flush    	),
	.inst_refetch_flush		(inst_refetch_flush		),

	.wait_flush				(wait_flush				),
	.wait_status			(wait_status			),

	.dcache_data_ok		  	(dcache_data_ok		  	),
	.WR_allowin         	(WR_allowin         	),
	.MEM0_MEM_valid     	(MEM0_MEM_valid     	),
	.MEM_read_register  	(read_register  		),
	
	.dcache_rdata	    	(dcache_rdata	    	),
	.div_MEM0_to_MEM    	(div_MEM0_to_MEM    	),
	.WR_is_ex           	(WR_is_ex           	),
	.MEM_allowin        	(MEM_allowin        	),
	.MEM_WR_valid       	(MEM_WR_valid       	),
	.MEM_forward        	(MEM_forward        	),
	.MEM_is_ex          	(MEM_is_ex          	),
	.MEM_is_eret        	(MEM_is_eret        	),
	.MEM_is_mtc0        	(MEM_is_mtc0        	),
	.MEM_valid_to_MEM0  	(MEM_valid_to_MEM0  	),
	.MEM_int_hazard			(MEM_int_hazard			),
	.data_req_busy			(data_req_busy			),

	.MEM_tlbp_hazard		(MEM_tlbp_hazard		),
	.MEM_inst_refetch_o 	(MEM_inst_refetch_o		),
	//reg
	.MEM0_inst_refetch		(MEM0_inst_refetch		),
	.MEM0_inst_table      	(MEM0_inst_table        ),
	.MEM0_pc              	(MEM0_pc                ),
	.MEM0_rf_data         	(MEM0_rf_data           ),
	.MEM0_alu_result      	(MEM0_alu_result        ),
	.MEM0_write_reg       	(MEM0_write_reg         ),
	.MEM0_hi_ctrl_write   	(MEM0_hi_ctrl_write     ),
	.MEM0_lo_ctrl_write   	(MEM0_lo_ctrl_write     ),
	.MEM0_is_branch       	(MEM0_is_branch         ),
	.MEM0_badvaddr_o      	(MEM0_badvaddr_o        ),
	.MEM0_exception_info_o	(MEM0_exception_info_o  ),
	.MEM0_cp0_write_en    	(MEM0_cp0_write_en      ),
	.MEM0_cp0_write_reg   	(MEM0_cp0_write_reg     ),
	.MEM0_ctrl_write      	(MEM0_ctrl_write        ),
	.MEM0_ctrl_reg_write  	(MEM0_ctrl_reg_write    ),
	.MEM0_data_sram_sel_hword(MEM0_data_sram_sel_hword),
	.MEM0_data_sram_sel_word(MEM0_data_sram_sel_word),
	.MEM0_unhit 			(MEM0_unhit 			),
	.MEM0_cache_op			(MEM0_cache_op			),
	.MEM0_cache_paddr		(MEM0_cache_paddr		),
	.MEM0_mult_pro			(MEM0_mult_pro			),

	.MEM_inst_refetch		(MEM_inst_refetch		),
	.MEM_inst_table    		(MEM_inst_table    		),
	.MEM_pc            		(MEM_pc            		),
	.MEM_rf_data       		(MEM_rf_data       		),
	.MEM_alu_result    		(MEM_alu_result    		),
	.MEM_busW_inner    		(MEM_busW_inner    		),
	.MEM_badvaddr      		(MEM_badvaddr      		),
	.MEM_cp0_write_en  		(MEM_cp0_write_en  		),
	.MEM_cp0_write_reg 		(MEM_cp0_write_reg 		),
	.MEM_exception_info		(MEM_exception_info		),
	.MEM_is_branch     		(MEM_is_branch     		),
	.MEM_write_reg     		(MEM_write_reg     		),
	.MEM_reg_write_en  		(MEM_reg_write_en  		),
	.MEM_unhit 				(MEM_unhit      		),
	.MEM_cache_op			(MEM_cache_op			),
	.MEM_cache_paddr		(MEM_cache_paddr		)
	);
	
	wire				WR_is_tlbr	  		;
	wire				WR_is_tlbwi	  		;
	wire 				WR_is_tlbwr		    ;
	assign	WR_cache_op_done	= WR_cache_target[0] ? icache_op_done :
								  WR_cache_target[1] ? dcache_op_done : 
								  WR_cache_op[1:0] == 2'b10 || WR_cache_op[1:0] == 2'b11 ? 1'b1 :
								  1'b0;

	pipeline_WR WR_stage(
	.clk                    (clk                	),
	.reset                  (reset              	),
	.eret_flush				(eret_flush				),
	.exception_flush		(exception_flush		),
	.inst_refetch_flush		(inst_refetch_flush		),
	.WR_inst_refetch_o		(WR_inst_refetch_o		),
	.WR_allowin             (WR_allowin         	),
	.MEM_WR_valid           (MEM_WR_valid       	),
	.WR_to_ID_bus           (WR_to_ID_bus       	),
	.debug_wb_pc            (debug_wb_pc        	),
	.debug_wb_rf_wen        (debug_wb_rf_wen    	),
	.debug_wb_rf_wnum       (debug_wb_rf_wnum   	),
	.debug_wb_rf_wdata      (debug_wb_rf_wdata  	),
	.WR_forward             (WR_forward         	),
	.WR_read_register       (read_register      	),
	.WR_to_cp0_bus			(WR_to_cp0_bus			),
	.cp0_output_data		(cp0_output_data		),
	.WR_is_ex				(WR_is_ex				),
	.WR_int_hazard			(WR_int_hazard			),
	.WR_pc					(WR_pc					),

	.wait_flush				(wait_flush				),
	.wait_status			(wait_status			),

	.WR_tlbp_hazard			(WR_tlbp_hazard			),

	.MEM_inst_refetch		(MEM_inst_refetch		),
	.MEM_inst_table    		(MEM_inst_table    		),
	.MEM_pc            		(MEM_pc            		),
	.MEM_rf_data       		(MEM_rf_data       		),
	.MEM_alu_result    		(MEM_alu_result    		),
	.MEM_busW_inner    		(MEM_busW_inner    		),
	.MEM_badvaddr      		(MEM_badvaddr      		),
	.MEM_cp0_write_en  		(MEM_cp0_write_en  		),
	.MEM_cp0_write_reg 		(MEM_cp0_write_reg 		),
	.MEM_exception_info		(MEM_exception_info		),
	.MEM_is_branch     		(MEM_is_branch     		),
	.MEM_write_reg     		(MEM_write_reg     		),
	.MEM_reg_write_en  		(MEM_reg_write_en  		),
	.MEM_unhit 				(MEM_unhit 				),
	.MEM_cache_op			(MEM_cache_op			),
	.MEM_cache_paddr		(MEM_cache_paddr		),
	
	.WR_is_tlbr				(WR_is_tlbr				),
	.WR_is_tlbwi			(WR_is_tlbwi			),
	.WR_is_tlbwr			(WR_is_tlbwr			),

	.WR_cache_op_o			(WR_cache_op			),
	.WR_cache_paddr_o		(WR_cache_paddr			),
	.WR_cache_target_o		(WR_cache_target		),
	.cache_op_done    		(WR_cache_op_done		)
	);


	//tlb接口						
	wire[`TLB_WD]       w_index		  		;
	wire[`VPN2_WD]      w_vpn2		  		;
	wire[`ASID_WD]      w_asid		  		;
	wire                w_g	          		;
	wire[`PFN_WD]       w_pfn0		  		;
	wire[`C_WD]         w_c0	      		;
	wire                w_d0	      		;
	wire                w_v0		  		;
	wire[`PFN_WD]       w_pfn1		  		;
	wire[`C_WD]         w_c1		  		;
	wire                w_d1		  		;
	wire                w_v1		  		;
	wire [`MASK_SIZE] 	w_mask				;
	wire[`TLB_WD]       r_index		  		; 	
	wire[`VPN2_WD]      r_vpn2		  		; 	
	wire[`ASID_WD]      r_asid		  		; 	
	wire                r_g    	      		; 	
	wire[`PFN_WD]       r_pfn0		  		; 	
	wire[`C_WD]         r_c0		  		; 	
	wire                r_d0		  		; 	
	wire                r_v0		  		; 	
	wire[`PFN_WD]       r_pfn1		  		; 	
	wire[`C_WD]         r_c1		  		; 	
	wire                r_d1		  		; 	
	wire                r_v1		  		;
	wire [`MASK_SIZE]   r_mask			    ;
	wire 				tlb_p		  		;
	wire[`TLB_WD]		tlb_index	  		;	
	wire[`TLB_WD]		tlb_random			;
	
	wire[`VPN2_WD]		tlbp_vpn2	  		;
	wire[`ASID_WD]		tlbp_asid	  		;

	wire 				cp0_EntryHi_changed	;		
	wire [31:0]         tlbp_result			;

	



	cp0_register cp0(
	.clk					(clk				),
	.reset					(reset				),
	.eret_flush             (eret_flush			),
	.WR_to_cp0_bus			(WR_to_cp0_bus		),
	.ext_int_in				(ext_int        	),
	.cp0_output_data		(cp0_output_data	),
	.WR_EPC_info			(WR_EPC_info		),
	.has_int				(has_int			),
	.ID_int_hazard			(ID_int_hazard		),
	.EXE_int_hazard			(EXE_int_hazard		),
	.MEM_int_hazard			(MEM_int_hazard		),
	.WR_int_hazard			(WR_int_hazard		),
	.ex_addr				(ex_addr			),
	
	//input tlb read
	.tlbr_vpn2    			(r_vpn2  			),
	.tlbr_asid    			(r_asid  			),
	.tlbr_g       			(r_g     			),
	.tlbr_pfn0    			(r_pfn0  			),  
	.tlbr_c0      			(r_c0    			),
	.tlbr_d0	  			(r_d0    			),
	.tlbr_v0	  			(r_v0    			),
	.tlbr_pfn1    			(r_pfn1  			),
	.tlbr_c1	  			(r_c1    			),
	.tlbr_d1	  			(r_d1    			),
	.tlbr_v1	  			(r_v1				),
	.tlbr_mask				(r_mask				),
	
	//output tlb index
	.tlb_index				(tlb_index			),
	.tlb_p					(tlb_p				),
	.tlb_random				(tlb_random			),
	
	//output tlb write
	.tlbwi_vpn2				(w_vpn2				),
	.tlbwi_asid				(w_asid				),
	.tlbwi_g				(w_g   				),
	.tlbwi_pfn0				(w_pfn0				),
	.tlbwi_c0				(w_c0  				),
	.tlbwi_d0				(w_d0  				),
	.tlbwi_v0				(w_v0  				),
	.tlbwi_pfn1				(w_pfn1				),
	.tlbwi_c1				(w_c1  				),
	.tlbwi_d1				(w_d1  				),
	.tlbwi_v1				(w_v1  				),
	.tlbwi_mask				(w_mask				),
	
	//output tlbp
	.tlbp_vpn2				(tlbp_vpn2			),
	.tlbp_asid				(tlbp_asid			),
	.tlbp_result        	(tlbp_result      	),

	//cp0-tlb write enable
	.tlbp_write_en			(EXE_is_tlbp		),
	.tlbr_write_en			(WR_is_tlbr			),

	//asid output
	.s0_asid				(s0_asid			),
	.s1_asid				(s1_asid			),
	//k0
	.config_k0				(k0					),
	//TagLo
	.TagLo					(TagLo				)
	);


	tlb_cp0_bridge tlb_cp0_bridge(
	.is_tlbp				(EXE_is_tlbp		),
	.is_tlbr				(WR_is_tlbr			),
	.is_tlbwi				(WR_is_tlbwi		),
	.is_tlbwr 				(WR_is_tlbwr		),
	//tlbp
    .tlbp_vpn2				(tlbp_vpn2			),
    .tlbp_asid				(tlbp_asid			),
    .tlbp_result        	(tlbp_result      	),
	
	.clk					(clk				),
	.reset					(reset				),

	.w_random				(tlb_random			),

	.w_index				(tlb_index			),
	.w_vpn2 				(w_vpn2 			),
	.w_asid 				(w_asid 			),
	.w_g    				(w_g    			),
	.w_pfn0 				(w_pfn0 			),
	.w_c0   				(w_c0   			),
	.w_d0   				(w_d0   			),
	.w_v0   				(w_v0   			),
	.w_pfn1 				(w_pfn1 			),
	.w_c1   				(w_c1   			),
	.w_d1   				(w_d1   			),
	.w_v1   				(w_v1   			),
	.w_mask					(w_mask				),
	//�?
	.tlbr_index				(tlb_index			),
	.tlbr_vpn2   			(r_vpn2 			),
	.tlbr_asid   			(r_asid 			),
	.tlbr_g      			(r_g    			),
	.tlbr_pfn0   			(r_pfn0 			),
	.tlbr_c0     			(r_c0   			),
	.tlbr_d0     			(r_d0   			),
	.tlbr_v0     			(r_v0   			),
	.tlbr_pfn1   			(r_pfn1 			),
	.tlbr_c1     			(r_c1   			),
	.tlbr_d1     			(r_d1   			),
	.tlbr_v1				(r_v1			    ),
	.tlbr_mask				(r_mask				),
	//查找端口0
	.s0_vpn2    			(s0_vpn2			),
 	.s0_odd_page			(s0_odd_page		),
 	.s0_found   			(s0_found			),
 	.s0_index   			(s0_index			),
 	.s0_pfn     			(s0_pfn			    ),
 	.s0_c       			(s0_c				),
 	.s0_d       			(s0_d				),
 	.s0_v			        (s0_v				),
	.s0_asid				(s0_asid			),
	//查找端口1
	.s1_vpn2_mem    		(s1_vpn2   			),
	.s1_odd_page_mem		(s1_odd_page    	),
	.s1_asid_mem    		(s1_asid        	),
	.s1_found       		(s1_found       	),
	.s1_index       		(s1_index       	),
	.s1_pfn         		(s1_pfn         	),
	.s1_c			 		(s1_c			 	),
	.s1_d			 		(s1_d			 	),
	.s1_v					(s1_v				)
    );

`ifdef VERILATOR
	sim sim_(
		.clk				(clk				),
		.IF_pc				(IF_to_ID_bus[31:0] ),
		.IF_inst			(IF_inst_wire		),
		.WR_pc				(WR_pc				),
		.GPR				(GPR				),
		.unknown_inst_flag  (0					)
	);
`endif

endmodule
