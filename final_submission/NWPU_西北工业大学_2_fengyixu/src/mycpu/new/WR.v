`include "lib/defines.v"
`define OTHER 0
`define INCACHE1 1
`define INCACHE2 2
module pipeline_WR(
    input clk,
	input reset,
	input                       MEM_WR_valid,
	input [`READ_REGISTER-1:0]  WR_read_register,
	input [31:0]				cp0_output_data,

	output 						WR_tlbp_hazard,

    output                      WR_allowin,
	output [31:0]               debug_wb_pc,
	output [3:0]                debug_wb_rf_wen,
	output [4:0]                debug_wb_rf_wnum,
	output [31:0]               debug_wb_rf_wdata,
    output [`WR_TO_ID_WD-1:0]   WR_to_ID_bus,
	output [`WR_FORWARD_WD-1:0] WR_forward  ,
	output [`WR_to_cp0_bus-1:0] WR_to_cp0_bus,
	output 						eret_flush,
	output 						exception_flush,
	output						WR_is_ex,
	output						WR_int_hazard,
	output                      inst_refetch_flush,
	output						WR_inst_refetch_o,
	output						WR_is_tlbr,
	output						WR_is_tlbwi,
	output 						WR_is_tlbwr,
	output[31:0]                WR_pc/*verilator public*/,


    input                           MEM_inst_refetch       ,
    input [`INST_TABLE_WD-1:0]      MEM_inst_table         , 
    input [31:0]                    MEM_pc                 ,
    input [31:0]                    MEM_rf_data            ,
    input [31:0]                    MEM_alu_result         ,
    input [31:0]                    MEM_busW_inner         ,
	input [31:0]                    MEM_badvaddr           ,
    input                           MEM_cp0_write_en       ,
    input [7:0]                     MEM_cp0_write_reg      ,
    input [`EX_INFO-1:0]            MEM_exception_info     ,
    input                           MEM_is_branch          ,
    input [4:0]                     MEM_write_reg          ,
    input [3:0]                     MEM_reg_write_en       ,	
	input 							MEM_unhit			   ,
	input [4:0] 					MEM_cache_op		   ,
	input 							MEM_crefetch		   ,
	input [31:0]					MEM_cache_paddr		   ,

	output 							wait_flush			   ,
	input 							wait_status			   ,

	output [4:0]     				WR_cache_op_o		   ,//cache opcode
	output [31:0]					WR_cache_paddr_o	   ,//physical address for cache
	output [1:0]					WR_cache_target_o	   ,
	input 							cache_op_done   //cache完成信号
    );
	wire						   WR_inst_refetch		;
	wire [`INST_TABLE_WD-1:0]      WR_inst_table        ; 
    wire [31:0]                    WR_rf_data           ;
    wire [31:0]                    WR_alu_result        ;
    wire [31:0]                    WR_busW_inner        ;
    wire [31:0]                    WR_badvaddr          ;
    wire                           WR_cp0_write_en      ;
    wire [7:0]                     WR_cp0_write_reg     ;
    wire [`EX_INFO-1:0]            WR_exception_info    ;
    wire                           WR_is_branch         ;
    wire [4:0]                     WR_write_reg         ;
    wire [3:0]                     WR_reg_write_en      ; 
	wire						   WR_unhit				;
	wire [4:0] 					   WR_cache_op			;
	wire [31:0] 				   WR_cache_paddr 		;
    reg WR_valid/*verilator public*/;
    wire WR_ready_go;
	wire flush = exception_flush | eret_flush | inst_refetch_flush | wait_flush | wait_status;
	wire [3:0] WR_reg_write_en_inner;
	wire [4:0] WR_Rw;
	wire [31:0] WR_busW;

	wire WR_is_eret;
	wire [31:0] WR_bus_in;
	wire WR_ctr_RegWr;
    wire [4 :0] rf_waddr;
    wire [31:0] rf_wdata;
	

    wire [4:0] WR_Ra,WR_Rb;
	reg  [1:0] sel_forward;
	
    wire WR_bd /*verilator public*/;
	assign WR_bd = WR_unhit;
	//WR_status
	reg [1:0]WR_status;
	reg [1:0]WR_next_status;

	always @(posedge clk ) begin
		if(reset || flush)  
		   WR_status <= `OTHER;
		else 
		   WR_status <= WR_next_status;
	end
	
	always @(*) begin
		case(WR_status)
		   `OTHER: WR_next_status = (WR_is_cache && WR_valid) ? `INCACHE1:`OTHER;
		   `INCACHE1: WR_next_status = (cache_op_done) ? `INCACHE2:`INCACHE1;
		   `INCACHE2: WR_next_status = `OTHER;
		   default:WR_next_status = `OTHER;
		endcase
	end

	//数据拆分
	wire [1:0] WR_cache_target;
	wire WR_wr = WR_allowin && MEM_WR_valid;
	assign WR_reg_write_en_inner = (flush |!WR_valid) ? 4'b0 : WR_reg_write_en;
	assign WR_cache_target	= (WR_is_cache && WR_status == `INCACHE1) ? (
		WR_cache_op_r[1:0] == 2'b00 ? 2'b01 : 	//icache
		WR_cache_op_r[1:0] == 2'b01 ? 2'b10 :	//dcache
		2'b00
	) : 2'b00;

	//cache inst buffer
	reg [4:0] WR_cache_op_r;
	reg [31:0]WR_cache_paddr_r;
	always @(posedge clk ) begin
		if(reset | flush)  begin
		  WR_cache_op_r <= 0;
		  WR_cache_paddr_r <= 0;
		end
		else if(WR_is_cache && WR_valid) begin
		  WR_cache_op_r <= WR_cache_op;
		  WR_cache_paddr_r <= WR_cache_paddr;
		end
	end
	assign WR_cache_paddr_o = WR_cache_paddr_r;
	assign WR_cache_op_o    = WR_cache_op_r;
	assign WR_cache_target_o = WR_cache_target;
//WR_reg
	WR_reg wr_reg(
	.clk			(clk),
	.reset			(reset),
	.flush			(flush),
	.WR_wr			(WR_wr),

	.MEM_inst_refetch		(MEM_inst_refetch		),
	.MEM_inst_table         (MEM_inst_table         ),
	.MEM_pc                 (MEM_pc                 ),
	.MEM_rf_data            (MEM_rf_data            ),
	.MEM_alu_result         (MEM_alu_result         ),
	.MEM_busW_inner         (MEM_busW_inner         ),
	.MEM_badvaddr         	(MEM_badvaddr         	),
	.MEM_cp0_write_en       (MEM_cp0_write_en       ),
	.MEM_cp0_write_reg      (MEM_cp0_write_reg      ),
	.MEM_exception_info     (MEM_exception_info     ),
	.MEM_is_branch          (MEM_is_branch          ),
	.MEM_write_reg          (MEM_write_reg          ),
	.MEM_reg_write_en       (MEM_reg_write_en       ),
	.MEM_unhit 				(MEM_unhit 				),
	.MEM_cache_op			(MEM_cache_op 			),
	.MEM_cache_paddr		(MEM_cache_paddr		),

	.WR_inst_refetch		(WR_inst_refetch		),
	.WR_inst_table          (WR_inst_table          ),
	.WR_pc                  (WR_pc                  ),
	.WR_rf_data             (WR_rf_data             ),
	.WR_alu_result          (WR_alu_result          ),
	.WR_busW_inner          (WR_busW_inner          ),
	.WR_badvaddr         	(WR_badvaddr         	),
	.WR_cp0_write_en        (WR_cp0_write_en        ),
	.WR_cp0_write_reg       (WR_cp0_write_reg       ),
	.WR_exception_info      (WR_exception_info      ),
	.WR_is_branch           (WR_is_branch           ),
	.WR_write_reg           (WR_write_reg           ),
	.WR_reg_write_en        (WR_reg_write_en        ),
	.WR_unhit 				(WR_unhit 				),
	.WR_cache_op			(WR_cache_op			),
	.WR_cache_paddr			(WR_cache_paddr  		)
	);

	assign inst_refetch_flush = WR_inst_refetch && WR_valid;
    assign {
        WR_Ra,
        WR_Rb
        } = WR_read_register;
    wire WR_is_lwl_lwr = WR_inst_table[`LWL] || WR_inst_table[`LWR];
    assign WR_forward = {
        WR_valid,
		WR_is_lwl_lwr,
        sel_forward,
        rf_wdata
    };

    assign WR_ready_go = (WR_inst_table[`CACHE] ) ? (WR_status == `INCACHE2):1'b1;
	assign WR_allowin = !WR_valid || WR_ready_go;
	
	always@(posedge clk)
	    if(reset | flush)
	        WR_valid <= 1'b0;
	    else if(WR_allowin)
	        WR_valid <= MEM_WR_valid;
	
	  
	assign debug_wb_pc = WR_pc;
	assign debug_wb_rf_wen = WR_reg_write_en_inner;
	assign debug_wb_rf_wnum = rf_waddr;
	assign debug_wb_rf_wdata = rf_wdata;
    
    assign WR_to_ID_bus = {WR_reg_write_en_inner,rf_waddr,rf_wdata};
	assign rf_waddr = WR_write_reg;
	assign rf_wdata = WR_inst_table[`MFC0] ? cp0_output_data : WR_busW_inner;
	
	always@(*)
	 if(!WR_valid)
	   sel_forward = 2'b00;
	 else begin
	   sel_forward[0] = (|(!(WR_Ra ^ WR_write_reg)) && |(WR_reg_write_en)) ;
	   sel_forward[1] = (|(!(WR_Rb ^ WR_write_reg)) && |(WR_reg_write_en)) ;
	 end 

	//生成bd信号
	wire WR_bd_to_cp0;
	reg [31:0] branch_inst_pc;

    //传�?�给cp0
	wire [`EX_CLASS-1:0] exception_class;
	wire [31:0] 		 WR_pc_sent;
	assign {
		WR_is_ex,
		exception_class
	} = WR_exception_info;
 
	assign WR_to_cp0_bus = {
		1'b0,
		WR_badvaddr,
		WR_bd_to_cp0,
		WR_pc_sent,
		exception_class,
		WR_is_ex,
		WR_cp0_write_en,
		WR_cp0_write_reg,
		WR_valid	   ,
		WR_rf_data
	};
	 
	//刷新信号
	assign eret_flush = WR_inst_table[`ERET] && WR_valid;
	assign exception_flush = WR_is_ex && WR_valid;
	

	always@(posedge clk)
	    if(reset | flush)
		  branch_inst_pc <= 32'b0;
		else if(WR_is_branch)
		  branch_inst_pc <= WR_pc;

	assign WR_bd_to_cp0 = (WR_pc == branch_inst_pc + 32'h4);
	assign WR_pc_sent = (WR_bd_to_cp0 | WR_unhit) ? branch_inst_pc:WR_pc; 	
	
	//中断冲突处理
	assign WR_int_hazard = (WR_cp0_write_en && (WR_cp0_write_reg == 8'b01100000 || WR_cp0_write_reg == 8'b01101000));

	//tlbp冒险
	assign WR_tlbp_hazard = (WR_cp0_write_en && (WR_cp0_write_reg == 8'b01010_000)) && WR_valid;
	//tlb指令冲突
	assign WR_inst_refetch_o = (WR_inst_table[`TLBWI] || WR_inst_table[`TLBR] || WR_inst_table[`CACHE] || WR_inst_table[`TLBWR]) && WR_valid;
	assign WR_is_tlbr = WR_inst_table[`TLBR] && WR_valid;
	assign WR_is_tlbwi = WR_inst_table[`TLBWI] && WR_valid;
	assign WR_is_tlbwr = WR_inst_table[`TLBWR] && WR_valid;
	//WR_cache
	wire WR_is_cache = WR_inst_table[`CACHE];//cache inst flag

	//wait指令
	assign wait_flush = WR_inst_table[`WAIT] && WR_valid;



endmodule
