`include "lib/defines.v"
module  pipeline_MEM0(
    input                               clk                 ,
	input                               reset               ,
    input                               EXE_MEM0_valid      ,
    input                               MEM_allowin         ,
    input                               eret_flush          ,
    input                               exception_flush     ,
    input                               wait_flush          ,
    input                               wait_status         ,
    input                               inst_refetch_flush  ,

    input                               dcache_addr_ok      ,
	input [`READ_REGISTER-1:0]          MEM0_read_register  ,

    input                               MEM_is_ex           ,
    input                               MEM_is_eret         ,
    input [`DIV_EXE_TO_MEM0_WD-1:0]     div_EXE_to_MEM0     ,
    input                               MEM_valid           ,
    input                               dcache_data_ok      ,

    output                              MEM0_tlbp_hazard    ,

    input  [`C_WD   ]                   s1_c                ,
    output                              MEM0_inst_refetch_o ,
    input                               MEM_inst_refetch    ,

    input                               EXE_inst_refetch        ,
    input [`INST_TABLE_WD-1:0]          EXE_inst_table          , 
    input [31:0]                        EXE_pc                  ,
    input [31:0]                        EXE_rf_data             ,
    input [31:0]                        EXE_alu_result          ,
    input [4:0]                         EXE_write_reg           ,
    input                               EXE_hi_ctrl_write       ,
    input                               EXE_lo_ctrl_write       ,
    input                               EXE_is_eret             ,
    input                               EXE_is_branch           ,
    input [31:0]                        EXE_badvaddr            ,
    input [`EX_INFO-1:0]                EXE_exception_info_o    ,
    input                               EXE_cp0_write_en        ,
    input [7:0]                         EXE_cp0_write_reg       ,
    input                               EXE_ctrl_write          ,
    input                               EXE_ctrl_reg_write      ,
    input                               EXE_unhit               ,
    input [4:0]                         EXE_cache_op            ,
    input [65:0]                        EXE_mult_pro            ,
    input [31:0]                        EXE_paddr               ,
     
    output                              MEM0_inst_refetch       ,
    output                              MEM0_MEM_valid          ,
    output                              MEM0_valid_to_EXE       ,
	output                              MEM0_allowin            , 
    output                              dcache_valid            ,
    output                              dcache_op               ,
	output reg [3:0]                    dcache_wstrb            ,
    output [19:0]                       dcache_tag              ,
    output [7:0]                        dcache_index            ,
    output [3:0]                        dcache_offset           ,
    output                              dcache_uncached         ,
    output [2:0]                        dcache_lstype           ,
	output [31:0]                       dcache_wdata            ,    
    output [`MEM0_TO_MEM_WD-1:0]        MEM0_to_MEM_bus         ,
	output [`MEM0_FORWARD_WD-1:0]       MEM0_forward            ,
	output [`MULTI_MEM0_TO_MEM_WD-1:0]  multi_MEM0_to_MEM       ,
    output reg [`DIV_EXE_TO_MEM0_WD-1:0]div_MEM0_to_MEM         ,
    output                              MEM0_is_ex              ,
    output                              MEM0_is_eret            ,
    output                              MEM0_int_hazard         ,
    output reg                          data_req_busy           ,
    
    output [`INST_TABLE_WD-1:0]         MEM0_inst_table          , 
    (*mark_debug = "true"*)output [31:0]                       MEM0_pc/*verilator public*/,
    output [31:0]                       MEM0_rf_data             ,
    output [31:0]                       MEM0_alu_result          ,
    output [4:0]                        MEM0_write_reg           ,
    output                              MEM0_hi_ctrl_write       ,
    output                              MEM0_lo_ctrl_write       ,
    output                              MEM0_is_branch           ,
    output [31:0]                       MEM0_badvaddr_o          ,
    output [`EX_INFO-1:0]               MEM0_exception_info_o    ,
    output                              MEM0_cp0_write_en        ,
    output [7:0]                        MEM0_cp0_write_reg       ,
    output                              MEM0_ctrl_write          ,
    output                              MEM0_ctrl_reg_write      ,
    output reg[1:0]                     MEM0_data_sram_sel_hword ,
    output reg[3:0]                     MEM0_data_sram_sel_word  ,  
    output                              MEM0_unhit               ,
    output [4:0]                        MEM0_cache_op            ,
    output [31:0]                       MEM0_cache_paddr         ,
    output [65:0]                       MEM0_mult_pro            ,

    input [2:0]                         k0
    );

   
    reg                             MEM0_valid;
    (*MAX_FANOUT = 32 *)reg [`MULTI_EXE_TO_MEM0_WD-1:0] multi_EXE_to_MEM0;
    // pipeline MEM0 数据传输
    wire [31:0]                MEM0_badvaddr_i      ;
    wire [`EX_INFO-1:0]        MEM0_exception_info_i;

    wire                    MEM0_ready_go;
    wire                    MEM0_to_MEM_valid;

    assign MEM0_MEM_valid = MEM0_valid && MEM0_ready_go;
    assign MEM0_valid_to_EXE = MEM0_valid;
    assign MEM0_ready_go = (dcache_valid && dcache_addr_ok) | !dcache_valid;
	assign MEM0_allowin = !MEM0_valid || MEM0_ready_go && MEM_allowin;

    wire [31:0] MEM0_paddr;
    wire flush = eret_flush | exception_flush | inst_refetch_flush | wait_status | wait_flush;
    wire MEM0_wr = MEM0_allowin & EXE_MEM0_valid;
	always@(posedge clk)
	    if(reset | flush)
	        MEM0_valid <= 1'b0; 
	    else if(MEM0_allowin)
	        MEM0_valid <= EXE_MEM0_valid;
	  
	always@(posedge clk)
    if(reset) begin
        div_MEM0_to_MEM <= 0;
    end
	else if(MEM0_allowin && EXE_MEM0_valid) begin
        div_MEM0_to_MEM <= div_EXE_to_MEM0;
    end




    //EXE传入数据
	wire                     MEM0_ins_load;
    reg  [1:0]               sel_forward;     

    


    //华莱士树
    wire [`EX_CLASS-1:0]     MEM0_ex_class;
    wire [`EX_CLASS-1:0]     EXE_MEM0_ex_class;
    wire                     EXE_MEM0_is_ex;


   


    reg        MEM0_mem_ADEL ;
    reg        MEM0_mem_ADES ;
    
    //
    MEM0_reg mem0_reg(
        .clk                            (clk),
        .reset                          (reset),
        .flush                          (flush),
        .MEM0_wr                        (MEM0_wr),

        .EXE_inst_refetch               (EXE_inst_refetch        ),
        .EXE_inst_table                 (EXE_inst_table          ),
        .EXE_pc                         (EXE_pc                  ),
        .EXE_rf_data                    (EXE_rf_data             ),
        .EXE_alu_result                 (EXE_alu_result          ),
        .EXE_write_reg                  (EXE_write_reg           ),
        .EXE_hi_ctrl_write              (EXE_hi_ctrl_write       ),
        .EXE_lo_ctrl_write              (EXE_lo_ctrl_write       ),
        .EXE_is_eret                    (EXE_is_eret             ),
        .EXE_is_branch                  (EXE_is_branch           ),
        .EXE_badvaddr                   (EXE_badvaddr            ),
        .EXE_exception_info             (EXE_exception_info_o    ),
        .EXE_cp0_write_en               (EXE_cp0_write_en        ),
        .EXE_cp0_write_reg              (EXE_cp0_write_reg       ),
        .EXE_ctrl_write                 (EXE_ctrl_write          ),
        .EXE_ctrl_reg_write             (EXE_ctrl_reg_write      ),
        .EXE_unhit                      (EXE_unhit               ),
        .EXE_cache_op                   (EXE_cache_op            ),
        .EXE_mult_pro                   (EXE_mult_pro            ),
        .EXE_paddr                      (EXE_paddr               ),


        .MEM0_inst_refetch              (MEM0_inst_refetch       ),
        .MEM0_inst_table                (MEM0_inst_table         ),
        .MEM0_pc                        (MEM0_pc                 ),
        .MEM0_rf_data                   (MEM0_rf_data            ),
        .MEM0_alu_result                (MEM0_alu_result         ),
        .MEM0_write_reg                 (MEM0_write_reg          ),
        .MEM0_hi_ctrl_write             (MEM0_hi_ctrl_write      ),
        .MEM0_lo_ctrl_write             (MEM0_lo_ctrl_write      ),
        .MEM0_is_eret                   (MEM0_is_eret            ),
        .MEM0_is_branch                 (MEM0_is_branch          ),
        .MEM0_badvaddr                  (MEM0_badvaddr_i         ),
        .MEM0_exception_info            (MEM0_exception_info_i   ),
        .MEM0_cp0_write_en              (MEM0_cp0_write_en       ),
        .MEM0_cp0_write_reg             (MEM0_cp0_write_reg      ),
        .MEM0_ctrl_write                (MEM0_ctrl_write         ),
        .MEM0_ctrl_reg_write            (MEM0_ctrl_reg_write     ),
        .MEM0_unhit                     (MEM0_unhit              ),
        .MEM0_cache_op                  (MEM0_cache_op           ),
        .MEM0_mult_pro                  (MEM0_mult_pro           ),
        .MEM0_paddr                     (MEM0_paddr              )
    );

  //数据前�??
    wire [4:0] MEM0_reg1 , MEM0_reg2;
    assign {
        MEM0_reg1,
        MEM0_reg2
        } = MEM0_read_register;

    assign MEM0_ins_load = (|(MEM0_inst_table[5:1])) | MEM0_inst_table[`LWL] | MEM0_inst_table[`LWR];

    assign MEM0_forward = {
        MEM0_valid,
        MEM0_inst_table[`MUL],
        MEM0_inst_table[`MFC0],
        MEM0_inst_table[`MFHI],
        MEM0_inst_table[`MFLO],
        MEM0_ins_load,
        sel_forward,
        MEM0_alu_result
    };
    

    always@(*)
	 if(!MEM0_valid)
	   sel_forward = 2'b00;
	 else begin
	   sel_forward[0] = (!(MEM0_reg1 ^ MEM0_write_reg) && MEM0_ctrl_reg_write) ;
	   sel_forward[1] = (!(MEM0_reg2 ^ MEM0_write_reg) && MEM0_ctrl_reg_write) ;
	 end 

    //dram
    wire [31:0] MEM0_mem_swl_in;
    wire [31:0] MEM0_mem_swr_in;
    assign MEM0_mem_swl_in = (MEM0_data_sram_sel_word[0]) ? {24'b0,MEM0_rf_data[31:24]}   : 
                             (MEM0_data_sram_sel_word[1]) ? {16'b0,MEM0_rf_data[31:16]}   :
                             (MEM0_data_sram_sel_word[2]) ? {8'b0,MEM0_rf_data[31:8]}     :
                             MEM0_rf_data[31:0];

    assign MEM0_mem_swr_in = (MEM0_data_sram_sel_word[0]) ?  MEM0_rf_data[31:0]           :
                             (MEM0_data_sram_sel_word[1]) ?  {MEM0_rf_data[23:0],8'b0}    :
                             (MEM0_data_sram_sel_word[2]) ?  {MEM0_rf_data[15:0],16'b0}   :
                             {MEM0_rf_data[7:0],24'b0};
    wire sram_en_judge;
    
	assign dcache_valid     = MEM_allowin && (MEM0_ins_load | MEM0_ctrl_write) &&(!(MEM0_is_ex | MEM0_is_eret | MEM0_inst_refetch))&& MEM0_valid && sram_en_judge;
    assign sram_en_judge    = !((MEM_is_eret | MEM_is_ex | MEM_inst_refetch) & MEM_valid) && !exception_flush && !eret_flush && !inst_refetch_flush;
    assign dcache_tag       = dcache_valid ? MEM0_paddr[31:12] : 20'b0;
    assign dcache_index     = MEM0_alu_result[11:4];
    assign dcache_offset    = MEM0_alu_result[3:0];

    assign dcache_op        = dcache_wstrb != 0;
    assign dcache_wdata     = MEM0_inst_table[`SB] ? {4{MEM0_rf_data[7:0]}}:
                              MEM0_inst_table[`SH] ? {2{MEM0_rf_data[15:0]}}:
                              MEM0_inst_table[`SWL] ? MEM0_mem_swl_in:
                              MEM0_inst_table[`SWR] ? MEM0_mem_swr_in:
                              MEM0_rf_data;
                
`ifndef VERILATOR                        
    assign dcache_uncached  = !dcache_valid ? 1'b0 :
                              MEM0_alu_result[31:28] >= 4'HC || MEM0_alu_result[31:28] < 4'H8  ? s1_c != 3'h3 :
                              MEM0_alu_result[31:28] < 4'HC && MEM0_alu_result[31:28]  >= 4'HA ? 1'b1 :
                              MEM0_alu_result[31:28] >= 4'H8 && MEM0_alu_result[31:28] < 4'HA ? k0 != 3'h3:
                               1'b0;

    assign dcache_lstype    = {MEM0_inst_table[`LW] | MEM0_inst_table[`SW]  | MEM0_inst_table[`LWL] | MEM0_inst_table[`LWR] | MEM0_inst_table[`SWL] | MEM0_inst_table[`SWR], 
                               MEM0_inst_table[`LH] | MEM0_inst_table[`LHU] | MEM0_inst_table[`SH], 
                               MEM0_inst_table[`LB] | MEM0_inst_table[`LBU] | MEM0_inst_table[`SB]
                               };

`else 
    assign dcache_uncached  = 1'b1;
`endif

    //独热�???
always@(*)
	if(MEM0_ctrl_write) begin
	    if(MEM0_inst_table[`SB]) begin
	        case(MEM0_alu_result[1:0])
	            2'b00:dcache_wstrb=4'b0001;
		        2'b01:dcache_wstrb=4'b0010;
		        2'b10:dcache_wstrb=4'b0100;
		        default:dcache_wstrb=4'b1000;
		    endcase
		end 
        else if(MEM0_inst_table[`SH])begin
            case(MEM0_alu_result[1:0])
                2'b00:dcache_wstrb   = 4'b0011;
                default:dcache_wstrb = 4'b1100;
            endcase
        end
        else if(MEM0_inst_table[`SWL]) begin
            case(MEM0_alu_result[1:0])
	            2'b00:dcache_wstrb=4'b0001;
		        2'b01:dcache_wstrb=4'b0011;
		        2'b10:dcache_wstrb=4'b0111;
		        default:dcache_wstrb=4'b1111;
            endcase
        end
        else if(MEM0_inst_table[`SWR]) begin
            case(MEM0_alu_result[1:0])
	            2'b00:dcache_wstrb=4'b1111;
		        2'b01:dcache_wstrb=4'b1110;
		        2'b10:dcache_wstrb=4'b1100;
		        default:dcache_wstrb=4'b1000;
            endcase
        end
        else
	        dcache_wstrb=4'hf;
	end
	else
	    dcache_wstrb=4'h0;
	   
	always@(*)
	    case(MEM0_alu_result[1:0])
		2'b00: MEM0_data_sram_sel_word = 4'b0001;
		2'b01: MEM0_data_sram_sel_word = 4'b0010;
		2'b10: MEM0_data_sram_sel_word = 4'b0100;
		2'b11: MEM0_data_sram_sel_word = 4'b1000;
		default:MEM0_data_sram_sel_word = 4'b0000;
	 endcase

    always@(*)
       case(MEM0_alu_result[1:0])
       2'b00:MEM0_data_sram_sel_hword = 2'b01;
       default:MEM0_data_sram_sel_hword = 2'b10;
    endcase

    assign MEM0_exception_info_o = {
         MEM0_is_ex,
         MEM0_ex_class
    };

    assign {
        EXE_MEM0_is_ex,
        EXE_MEM0_ex_class
    } = MEM0_exception_info_i;

    assign MEM0_is_ex = EXE_MEM0_is_ex     | 
                        MEM0_mem_ADES      |
                        MEM0_mem_ADEL      ;

    assign MEM0_ex_class = {
            EXE_MEM0_ex_class[16:6],
            MEM0_mem_ADES,
            MEM0_mem_ADEL,
            EXE_MEM0_ex_class[3:0]
    };



    //地址映射
    wire MEM0_is_cache = MEM0_inst_table[`CACHE];
    wire MEM0_is_store = MEM0_inst_table[`SH] | MEM0_inst_table[`SW] | MEM0_inst_table[`SB] | MEM0_inst_table[`SWL] | MEM0_inst_table[`SWR];
    assign MEM0_cache_paddr = MEM0_paddr;

    //MEM0_mem_ADES和MEM0_mem_ADEL处理
    always@(*)
        if(MEM0_ins_load) begin
              MEM0_mem_ADEL = (MEM0_inst_table[`LHU] & dcache_offset[0]!=0) | (MEM0_inst_table[`LH] & dcache_offset[0]!=0)|
                             ((MEM0_inst_table[`LW]) & dcache_offset[1:0]!=2'b0);
        end
        else    
              MEM0_mem_ADEL = 1'b0;

      always@(*)
        if(MEM0_ctrl_write) begin
            MEM0_mem_ADES = (MEM0_inst_table[`SH] & dcache_offset[0]!=0) | (MEM0_inst_table[`SW] & dcache_offset[1:0]!=2'b0);
        end
        else
             MEM0_mem_ADES = 1'b0;

    assign MEM0_badvaddr_o = (MEM0_exception_info_o[3] || MEM0_exception_info_o[8] || MEM0_exception_info_o[11]) ? MEM0_badvaddr_i : MEM0_alu_result;


    //中断冲突处理
	assign MEM0_int_hazard = (MEM0_cp0_write_en && (MEM0_cp0_write_reg == 8'b01100000 || MEM0_cp0_write_reg == 8'b01101000));
    //tlbp冲突
    assign MEM0_tlbp_hazard = (MEM0_cp0_write_en && (MEM0_cp0_write_reg == 8'b01010_000)) && MEM0_valid;


    //为了防止前�?�出错，�???要一个表示正在等待数据返回的信号
    
    always@(posedge clk) begin
       if(reset)
            data_req_busy <= 1'b0;
       else if(dcache_addr_ok && dcache_valid)
            data_req_busy <= 1'b1;
        else if(dcache_data_ok)
            data_req_busy <= 1'b0;
    end

    //tlb指令冲突
	assign MEM0_inst_refetch_o = (MEM0_inst_table[`TLBWI] || MEM0_inst_table[`TLBR] || MEM0_inst_table[`CACHE] || MEM0_inst_table[`TLBWR]) && MEM0_valid;
endmodule


