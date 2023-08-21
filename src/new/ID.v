`include "lib/defines.v"
module pipeline_ID(
        input clk,
		input reset,
		input eret_flush,
		input exception_flush,
		input inst_refetch_flush,
		input wait_status		,
		input wait_flush		,

		input branch_likely_clear,

        input           			EXE_allowin,
		input          				IF_ID_valid,
		input [`IF_TO_ID_WD-1:0]    IF_to_ID_bus,
		input [`EXE_FORWARD_WD-1:0] EXE_forward,
		input [`MEM0_FORWARD_WD-1:0]MEM0_forward,
		input [`MEM_FORWARD_WD-1:0] MEM_forward,
		input [`WR_FORWARD_WD-1:0]  WR_forward,
		input [`WR_TO_ID_WD-1:0]    WR_to_ID_bus,

		output						is_eret,
		output						is_ex,

		output          			ID_EXE_valid,
		output          			ID_allowin,
		output[`READ_REGISTER-1:0]  read_register,
		output						ID_int_hazard,
		output						ID_inst_refetch_o,

		output						ID_predict_pc_dir,
		output						ID_inst_refetch	 ,
        output                     	ID_is_branch     ,
		(*mark_debug = "true"*)output[`INST_TABLE_WD-1:0] 	ID_inst_table    ,
		output[31:0]               	ID_alu_src1      ,
		output[31:0]               	ID_alu_src2      ,
		output[11:0]               	ID_alu_control   ,
		output                     	ID_add_sub_sign  ,
		output                     	ID_ctrl_reg_write,
		output[4:0]                	ID_write_reg     ,
		output                     	ID_ctrl_write    ,
		output                     	ID_hi_ctrl_write ,
		output                     	ID_lo_ctrl_write ,
		output                     	ID_cp0_write_en  ,
		output[7:0]                 ID_cp0_write_reg ,
		output[`EX_INFO-1:0]       	ID_exception_info,
		output[31:0]               	ID_badvaddr      ,
		(*mark_debug = "true"*)output[31:0]               	ID_pc/*verilator public*/,
		(*mark_debug = "true"*)output[31:0]               	ID_rf_data       ,
		output 						ID_branch_hit	 ,
		output[31:0] 				ID_btb_branch_pc,
		output[31:0]				ID_predict_pc	 ,	
		output 						ID_unhit		 ,
		output[4:0] 				ID_cache_op		 ,
		output						ID_is_branch_likely,
		output 						ID_branch_likely_hit,
		output 						ID_hit,
    	output [1:0] 				ID_branch_type ,
		output     				    ID_is_jr	,
		output [31:0] 				ID_branch_next_pc
		`ifdef VERILATOR
		,
		output [31:0]				GPR [31:0]
		`endif
    );

    //ID寄存使能
	reg                    ID_valid;
    wire                   ID_ready_go;
    wire                   EXE_forward_occur;
	wire                   MEM0_forward_occur;
	wire                   MEM_forward_occur;
	wire 				   WR_forward_occur;
    wire                   load_hazard_occur;

    //接受数据
	(*mark_debug = "true"*)wire [31:0]            ID_inst;
	wire [31:0] 		   ID_inst_o;
	(*MAX_FANOUT = 32 *)reg  [`IF_TO_ID_WD-1:0]  ID_data;
	wire                   inst_refetch;
	wire 				   flush = exception_flush | eret_flush | inst_refetch_flush | wait_flush | wait_status;
	//译码
	wire [5:0]             op,func;
    wire [4:0]             rs,rt,rd,sa;
	wire [2:0]             sel;
    wire [15:0]            imm16;
    wire [31:0]            imm32s,imm32l;
    wire [25:0]            instr_index;
	wire [31:0]            sa32;
	wire [31:0]            imm32i;
    
    //内部数据通路
    wire [31:0]            ID_to_ctrl_bus1;
    wire [31:0]            ID_to_ctrl_bus2;
	wire [31:0]            ID_to_branch_bus1;
	wire [31:0]            ID_to_branch_bus2;
	wire [31:0]            ID_to_ctrl_bus;

    //寄存�?
    wire [3:0]             write_en;
    wire [31:0]            write_data;
    wire [31:0]            read_data1;
    wire [31:0]            read_data2;
    wire [4:0]             write_addr;
    wire [4:0]             read_addr1;
    wire [4:0]             read_addr2;

    //控制信号
    wire                   reg1_valid;
    wire                   reg2_valid;
	wire                   cp0_write_en;

    wire [2:0]             sel_rf_dst,sel_alu_src1;
	wire [3:0]             sel_alu_src2;
    wire [11:0]            alu_control;

	wire                   is_lb;
	wire                   is_sb;
	wire                   is_mul;
	wire                   is_lbu;
	wire                   is_lh;
	wire                   is_lhu;
	wire                   is_sh;
	wire                   mult_sign;
	wire                   is_div;
	wire                   div_sign;
	wire                   sel_bus;
	wire                   sel_mem_hi;
	wire                   sel_mem_lo;
	wire [`ID_EX_INFO-1:0] exception_info;
	wire                   add_sub_sign;
	wire                   break_ex;
	wire                   is_lw;
	wire                   is_sw;
	wire [3:0] 			   sel_nextpc;
	wire [3:0] 			   sel_nextpc_predict;
	wire 				   cpU_ex;

	



    //EXE传�??
	wire                   sel_cp0; 
	wire				   EXE_is_cloz;
	wire		           EXE_sel_cp0;
	wire  		           MEM_sel_cp0;
	wire     			   MEM_is_lwl_lwr;
	wire                   EXE_is_mul;
	wire 				   MEM0_is_mul;
	wire		           EXE_sel_mem_hi;
	wire	               EXE_sel_mem_lo;
	wire		           MEM0_sel_mem_hi;
	wire		           MEM0_sel_mem_lo;
    wire [31:0]            bus_in;
	wire [31:0]            ID_EXE_forward;
	wire [31:0]            ID_MEM0_forward;
	wire [31:0]            ID_MEM_forward;
	wire [31:0]            ID_WR_forward;
	wire [31:0]            ID_MEM_forward_branch;
	wire [31:0]            ID_EXE_forward_inner1;
	wire [31:0]            ID_MEM0_forward_inner1;
	reg  [31:0]            ID_MEM_forward_inner1;
	reg  [31:0]            ID_WR_forward_inner1 ;
	wire [31:0]            ID_EXE_forward_inner2;
	wire [31:0]            ID_MEM0_forward_inner2;
	reg  [31:0]            ID_MEM_forward_inner2;
	reg  [31:0]            ID_WR_forward_inner2 ;
	wire [3:0]             MEM_reg_write_en;
	wire                   WR_is_lwl_lwr;
	wire [1:0]             ID_sel_EXE_forward;
	wire [1:0]             ID_sel_MEM0_forward;
	wire [1:0]             ID_sel_MEM_forward;
	wire [1:0]             ID_sel_WR_forward;

	
    //PC选择
    wire [31:0]            npc1,npc2,npc3,npc4;
	wire                   ID_leave;

	//延迟�?
	wire ID_bd;
	wire [`IF_EX_INFO-1:0]      ID_IF_exception_info;
	wire 				        ID_IF_is_ex;
	wire [`PRE_IF_EX_INFO-2:0]	ID_IF_exception_class;
	reg 					    load_hazard_occur_reg;
	wire 	 			        reserved_inst_ex;


	assign ID_inst = (branch_likely_clear) ? 32'b0 : ID_inst_o;
    decoder de(
	.inst               (ID_inst            ),
	.imm32i             (imm32i             ),
	.sa32               (sa32               ),
	.instr_index        (instr_index        ),
	.Op                 (op                 ),
	.func               (func               ),
	.rs                 (rs                 ),
	.rt                 (rt                 ),
	.rd                 (rd                 ),
	.sa                 (sa                 ),
	.imm16              (imm16              ),
	.imm32s             (imm32s             ),
	.imm32l             (imm32l             ),
	.sel				(sel				)
	);


    regfile rf(
    .clk                (clk                ),
	.reset				(reset				),
    .write_en           (write_en           ),
	.write_data         (write_data         ),
	.write_addr         (write_addr         ),
	.read_addr1         (read_addr1         ),
	.read_addr2         (read_addr2         ),
	.read_data1         (read_data1         ),
	.read_data2         (read_data2         )
	`ifdef VERILATOR
	,
	.GPR				(GPR				)
	`endif
	);

    Control ctrl(
	.op                 (op                 ),
	.func               (func               ),
	.rs                 (rs                 ),
	.sa                 (sa                 ),
	.rt                 (rt                 ),
	.branch_likely_clear(branch_likely_clear),
	.ID_to_ctrl_bus1    (ID_to_branch_bus1  ),
	.ID_to_ctrl_bus2    (ID_to_branch_bus2  ),
	.alu_control        (ID_alu_control     ),
	.ctrl_write         (ID_ctrl_write      ),
	.ctrl_reg_write     (ID_ctrl_reg_write  ),
	.sel_rf_dst         (sel_rf_dst         ),
	.sel_alu_src1       (sel_alu_src1       ),
	.sel_alu_src2       (sel_alu_src2       ),
	.sel_nextpc         (sel_nextpc         ),
	.sel_nextpc_predict	(sel_nextpc_predict	),
	.reg1_valid         (reg1_valid         ),
	.reg2_valid         (reg2_valid         ),
	.hi_ctr_write		(ID_hi_ctrl_write   ),
	.lo_ctr_write		(ID_lo_ctrl_write   ),
	.sel_bus       		(sel_bus			),
	.cp0_write_en		(ID_cp0_write_en    ),
	.syscall_ex			(syscall_ex			),
	.break_ex			(break_ex			),
	.add_sub_sign		(ID_add_sub_sign	),
	.reserved_inst_ex	(reserved_inst_ex	),
	.is_branch			(ID_is_branch	    ),
	.ID_inst_table		(ID_inst_table		),
	.cache_op			(ID_cache_op		),
	.cpU_ex				(cpU_ex				),
	.is_jr				(ID_is_jr		    ),
	.b_branch_likely   	(ID_is_branch_likely),
	.branch_likely_hit  (ID_branch_likely_hit)
	);


    //数据拆解
	assign {ID_IF_is_ex,ID_IF_exception_class}=ID_IF_exception_info;
	assign ID_exception_info = {
		is_ex,
		cpU_ex,
		4'b0,
		ID_IF_exception_class[1],
		2'b0,
		ID_IF_exception_class[0],
		ID_IF_exception_class[3],
		reserved_inst_ex,
		2'b0,
		ID_IF_exception_class[2],
		1'b0,
		break_ex,
		syscall_ex
	};

	assign is_ex = reserved_inst_ex |syscall_ex | break_ex | ID_IF_is_ex | cpU_ex;

    assign read_register = {
        read_addr1,
        read_addr2
    };
	//branch指令处理
    assign ID_leave = ID_EXE_valid;

	assign ID_branch_hit = |(sel_nextpc[3:1]);
	assign ID_branch_next_pc = 
							   ({32{sel_nextpc[3]}} & npc4) |
							   ({32{sel_nextpc[2]}} & npc3) |
							   ({32{sel_nextpc[1]}} & npc2);

	assign ID_predict_pc =  
							({32{sel_nextpc_predict[3]}} & npc4) |
							({32{sel_nextpc_predict[2]}} & npc3) |
							({32{sel_nextpc_predict[1]}} & npc2);

    assign {
        EXE_valid,
		EXE_is_mul,
		EXE_sel_cp0,
		EXE_sel_mem_hi,
		EXE_sel_mem_lo,
		EXE_is_cloz,
        EXE_ins_load,
        ID_sel_EXE_forward,
        ID_EXE_forward
        } = EXE_forward;

	assign {
		MEM0_valid,
		MEM0_is_mul,
		MEM0_sel_cp0,
		MEM0_sel_mem_hi,
		MEM0_sel_mem_lo,
		MEM0_ins_load,
		ID_sel_MEM0_forward,
		ID_MEM0_forward
	} = MEM0_forward;

	assign {
		ID_MEM_forward_branch,
		MEM_data_req_busy,
		MEM_sel_mem_hi,
		MEM_sel_mem_lo,
		MEM_ins_load,
		MEM_is_lwl_lwr,
        MEM_valid,
		MEM_sel_cp0,
        MEM_reg_write_en,
        ID_sel_MEM_forward,
        ID_MEM_forward
        } = MEM_forward;

	assign {
        WR_valid,
		WR_is_lwl_lwr,
        ID_sel_WR_forward,
        ID_WR_forward
        } = WR_forward;


    //ALU传输
    assign ID_rf_data = (sel_bus)?ID_to_ctrl_bus1:ID_to_ctrl_bus2;

	assign ID_alu_src1     = ({32{sel_alu_src1[2]}} & sa32)  |
							 ({32{sel_alu_src1[1]}} & ID_pc) |
							 ({32{sel_alu_src1[0]}} & ID_to_ctrl_bus1);
							 
	assign ID_alu_src2	   = ({32{sel_alu_src2[3]}} & imm32l) |
							 ({32{sel_alu_src2[2]}} & 32'd8)  |
							 ({32{sel_alu_src2[1]}} & imm32s) |
							 ({32{sel_alu_src2[0]}} & ID_to_ctrl_bus2);
	 
	assign ID_to_ctrl_bus1 = 
                            (ID_sel_EXE_forward[0] & reg1_valid)  ?  ID_EXE_forward:
							(ID_sel_MEM0_forward[0] & reg1_valid) ?  ID_MEM0_forward:
		                    (ID_sel_MEM_forward[0] & reg1_valid)  ?  ID_MEM_forward:
				            (ID_sel_WR_forward[0] & reg1_valid)   ?  ID_WR_forward :read_data1;
		
	assign ID_to_ctrl_bus2 = 
                    (ID_sel_EXE_forward[1] & reg2_valid)  ?  ID_EXE_forward:
					(ID_sel_MEM0_forward[1] & reg2_valid) ?  ID_MEM0_forward:
				    (ID_sel_MEM_forward[1] & reg2_valid)  ?  ID_MEM_forward:
				    (ID_sel_WR_forward[1] & reg2_valid)   ?  ID_WR_forward :read_data2;
    
    assign ID_to_branch_bus1 = (ID_sel_MEM0_forward[0] & reg1_valid) ?  ID_MEM0_forward:
							   (ID_sel_MEM_forward[0]  & reg1_valid) ?  ID_MEM_forward_branch:
                               (ID_sel_WR_forward[0]   & reg1_valid) ?  ID_WR_forward :read_data1;
    

    assign ID_to_branch_bus2 = (ID_sel_MEM0_forward[1] & reg2_valid) ?  ID_MEM0_forward:
							   (ID_sel_MEM_forward[1] & reg2_valid)  ?  ID_MEM_forward_branch:
                               (ID_sel_WR_forward[1] & reg2_valid)   ?  ID_WR_forward :read_data2;
    //冲突处理
	wire EXE_hazard_occur;
	wire MEM_hazard_occur;
	wire MEM0_hazard_occur;
	wire WR_hazard_occur;
    assign ID_ready_go = !(load_hazard_occur) | flush;
	assign ID_allowin = !ID_valid || ID_ready_go && EXE_allowin;

    assign EXE_forward_occur = 
    EXE_valid && ((ID_sel_EXE_forward[0]&&reg1_valid )| (ID_sel_EXE_forward[1]&&reg2_valid));

	assign MEM0_forward_occur = 
	MEM0_valid && ((ID_sel_MEM0_forward[0]&&reg1_valid )| (ID_sel_MEM0_forward[1]&&reg2_valid));

	assign MEM_forward_occur = 
	MEM_valid && ((ID_sel_MEM_forward[0]&&reg1_valid)| (ID_sel_MEM_forward[1]&& reg2_valid));

	assign WR_forward_occur =
	WR_valid &&  ((ID_sel_WR_forward[0]&&reg1_valid)| (ID_sel_WR_forward[1]&& reg2_valid));

    assign load_hazard_occur = (EXE_hazard_occur | MEM0_hazard_occur | MEM_hazard_occur | MEM_hazard_occur_branch | WR_hazard_occur) && ID_valid;
	assign EXE_hazard_occur = (EXE_forward_occur && ((EXE_ins_load)|(EXE_sel_mem_hi)|(EXE_sel_mem_lo)|(EXE_sel_cp0)|(ID_is_branch)|(EXE_is_mul)|(EXE_is_cloz)));
	assign MEM0_hazard_occur = (MEM0_forward_occur && ((MEM0_ins_load)|(MEM0_sel_mem_hi)|(MEM0_is_mul)|(MEM0_sel_mem_lo)|(MEM0_sel_cp0)));
	assign MEM_hazard_occur = (MEM_forward_occur && ((MEM_sel_cp0)|(MEM_data_req_busy)|(MEM_is_lwl_lwr)));
	assign MEM_hazard_occur_branch = (MEM_forward_occur && ((MEM_sel_cp0)|(MEM_ins_load)|(MEM_sel_mem_hi) | (MEM_sel_mem_lo) | MEM_is_lwl_lwr)) && ID_is_branch;
	assign WR_hazard_occur = (WR_forward_occur && WR_is_lwl_lwr);
    //冲突处理状�?�控�?


    //流水线寄存器
    always@(posedge clk)
	    if(reset | flush)
	        ID_valid <= 1'b0;
	    else if(ID_allowin)       
	        ID_valid <= IF_ID_valid;

    always@(posedge clk)
	if(reset | flush)
        ID_data <= 0;
	else if(ID_allowin && IF_ID_valid)
	    ID_data <= IF_to_ID_bus;

    assign {
		ID_hit,
        ID_branch_type,
		ID_btb_branch_pc,
		ID_predict_pc_dir,//104
		inst_refetch,//103
		ID_unhit,
		ID_badvaddr,//101
		ID_IF_exception_info,//69
        ID_inst_o,//64
        ID_pc//32
        } = ID_data;
    assign ID_EXE_valid = ID_valid && ID_ready_go;

    //寄存�?
    assign {
        write_en,
        write_addr,
        write_data
        } = WR_to_ID_bus;
	assign read_addr1 = rs;
	assign read_addr2 = rt;

    //PC选择
    assign npc1 = ID_pc + `PC_INC;
    assign npc2 = npc1 + imm32i;
    assign npc3 = {npc1[31:28],instr_index,2'b00};
    assign npc4 = ID_to_branch_bus1;
	assign sel_nextpc_valid = ID_valid;

	//寄存器写入赋�?
	assign ID_write_reg = ({5{sel_rf_dst[2]}} &  5'd31	) |
	                      ({5{sel_rf_dst[1]}} &  rt		) |
						  ({5{sel_rf_dst[0]}} &  rd		);

	//cp0寄存器写入赋值
	assign ID_cp0_write_reg = {rd,sel};
    //中断冲突处理
	assign ID_int_hazard = (cp0_write_en && (ID_cp0_write_reg == 8'b01100000 || ID_cp0_write_reg == 8'b01101000));
	//tlb指令冲突
	assign ID_inst_refetch_o = (ID_inst_table[`TLBWI] || ID_inst_table[`TLBR] || ID_inst_table[`CACHE] || ID_inst_table[`TLBWR]) && ID_valid;
	assign ID_inst_refetch = inst_refetch;
endmodule
