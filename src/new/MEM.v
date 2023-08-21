`include "lib/defines.v"
module pipeline_MEM(
    input                               clk                 ,  
	input                               reset               ,
    input                               eret_flush          ,
    input                               exception_flush     ,
    input                               wait_flush          ,
    input                               wait_status         ,
    input                               inst_refetch_flush  ,
    input                               dcache_data_ok      ,
    input                              	WR_allowin          ,
	input                              	MEM0_MEM_valid      ,
	input [`READ_REGISTER-1:0]         	MEM_read_register   ,

    input [31:0]                       	dcache_rdata        ,
    input [`DIV_MEM0_TO_MEM_WD-1:0]     div_MEM0_to_MEM     ,
    input                               WR_is_ex            ,
    input                               data_req_busy       ,

	output                              MEM_allowin         ,
    output                              MEM_WR_valid        ,
	output [`MEM_FORWARD_WD-1:0]        MEM_forward         ,
    output                              MEM_is_ex           ,
    output                              MEM_is_eret         ,
    output                              MEM_is_mtc0         ,
    output                              MEM_valid_to_MEM0   ,
    output                              MEM_int_hazard      ,
    output                              MEM_tlbp_hazard     ,
    output                              MEM_inst_refetch_o  ,
    //regs
    input                       MEM0_inst_refetch        ,
    input [`INST_TABLE_WD-1:0]  MEM0_inst_table          , 
    input [31:0]                MEM0_pc                  ,
    input [31:0]                MEM0_rf_data             ,
    input [31:0]                MEM0_alu_result          ,
    input [4:0]                 MEM0_write_reg           ,
    input                       MEM0_hi_ctrl_write       ,
    input                       MEM0_lo_ctrl_write       ,
    input                       MEM0_is_branch           ,
    input [31:0]                MEM0_badvaddr_o          ,
    input [`EX_INFO-1:0]        MEM0_exception_info_o    ,
    input                       MEM0_cp0_write_en        ,
    input [7:0]                 MEM0_cp0_write_reg       ,
    input                       MEM0_ctrl_write          ,
    input                       MEM0_ctrl_reg_write      ,
    input [1:0]                 MEM0_data_sram_sel_hword ,
    input [3:0]                 MEM0_data_sram_sel_word  ,
    input                       MEM0_unhit               ,
    input [4:0]                 MEM0_cache_op           ,
    input [31:0]                MEM0_cache_paddr        ,
    input [65:0]                MEM0_mult_pro           ,

    output                      MEM_inst_refetch       ,
    output [`INST_TABLE_WD-1:0] MEM_inst_table         ,
    (*mark_debug = "true"*)output [31:0]               MEM_pc/*verilator public*/,
    output [31:0]               MEM_rf_data            ,
    output [31:0]               MEM_alu_result         ,
    output [31:0]               MEM_busW_inner         ,
    output [31:0]               MEM_badvaddr           ,
    output                      MEM_cp0_write_en       ,
    output [7:0]                MEM_cp0_write_reg      ,
    output [`EX_INFO-1:0]       MEM_exception_info     ,
    output                      MEM_is_branch          ,
    output [4:0]                MEM_write_reg          ,
    output reg[3:0]             MEM_reg_write_en       ,
    output                      MEM_unhit              ,
    output [4:0]                MEM_cache_op           ,
    output [31:0]               MEM_cache_paddr
    );

	//流水�???
    reg MEM_valid;
    wire MEM_ready_go;
	//乘法器mem部分
	
    //控制信号

   wire                       MEM_hi_ctrl_write       ;
   wire                       MEM_lo_ctrl_write       ;
   
   wire                       MEM_ctrl_write          ;
   wire                       MEM_ctrl_reg_write      ;
   wire [1:0]                 MEM_data_sram_sel_hword ;
   wire [3:0]                 MEM_data_sram_sel_word  ;
    
    wire [4:0]              MEM_reg_write_addr;
    wire                    MEM_leave;

	//访存信号
    wire [31:0]             busW_inner; 
	wire [31:0]             MEM_word_data;
	wire [7:0]              MEM_byte_data;
    wire [15:0]             MEM_hword_data;

	//冲突解决
    wire [4:0]              MEM_Ra,MEM_Rb;
	reg  [1:0]              sel_forward;
     
	//hi_lo寄存�??? 
	wire [31:0]             hi_upgrade;
	wire [31:0]             lo_upgrade;
	wire [31:0]             hi_data;
	wire [31:0]             lo_data;

    reg [63:0]              MEM_div_pro;
    wire[63:0]              MEM_mult_pro;
    wire                    hi_ctr_write_en;
    wire                    lo_ctr_write_en;

       
	
	assign flush = eret_flush | exception_flush | inst_refetch_flush | wait_flush | wait_status;
    assign MEM_wr = MEM_allowin && MEM0_MEM_valid;
    //数据拆分
    assign MEM_is_eret = MEM_inst_table[`ERET];
    MEM_reg mem_reg(
    .clk                        (clk),
    .reset                      (reset),
    .flush                      (flush),
    .MEM_wr                     (MEM_wr),

    .MEM0_inst_refetch          (MEM0_inst_refetch       ),
    .MEM0_inst_table            (MEM0_inst_table         ),
    .MEM0_pc                    (MEM0_pc                 ),
    .MEM0_rf_data               (MEM0_rf_data            ),
    .MEM0_alu_result            (MEM0_alu_result         ),
    .MEM0_write_reg             (MEM0_write_reg          ),
    .MEM0_hi_ctrl_write         (MEM0_hi_ctrl_write      ),
    .MEM0_lo_ctrl_write         (MEM0_lo_ctrl_write      ),
    .MEM0_is_branch             (MEM0_is_branch          ),
    .MEM0_badvaddr              (MEM0_badvaddr_o         ),
    .MEM0_exception_info        (MEM0_exception_info_o   ),
    .MEM0_cp0_write_en          (MEM0_cp0_write_en       ),
    .MEM0_cp0_write_reg         (MEM0_cp0_write_reg      ),
    .MEM0_ctrl_write            (MEM0_ctrl_write         ),
    .MEM0_ctrl_reg_write        (MEM0_ctrl_reg_write     ),
    .MEM0_data_sram_sel_hword   (MEM0_data_sram_sel_hword),
    .MEM0_data_sram_sel_word    (MEM0_data_sram_sel_word ),
    .MEM0_unhit                 (MEM0_unhit              ),
    .MEM0_cache_op              (MEM0_cache_op           ),
    .MEM0_cache_paddr           (MEM0_cache_paddr        ),
    .MEM0_mult_pro              (MEM0_mult_pro           ),

    .MEM_inst_refetch           (MEM_inst_refetch        ),
    .MEM_inst_table             (MEM_inst_table          ),
    .MEM_pc                     (MEM_pc                  ),
    .MEM_rf_data                (MEM_rf_data             ),
    .MEM_alu_result             (MEM_alu_result          ),
    .MEM_write_reg              (MEM_write_reg           ),
    .MEM_hi_ctrl_write          (MEM_hi_ctrl_write       ),
    .MEM_lo_ctrl_write          (MEM_lo_ctrl_write       ),
    .MEM_is_branch              (MEM_is_branch           ),
    .MEM_badvaddr               (MEM_badvaddr            ),
    .MEM_exception_info         (MEM_exception_info      ),
    .MEM_cp0_write_en           (MEM_cp0_write_en        ),
    .MEM_cp0_write_reg          (MEM_cp0_write_reg       ),
    .MEM_ctrl_write             (MEM_ctrl_write          ),
    .MEM_ctrl_reg_write         (MEM_ctrl_reg_write      ),
    .MEM_data_sram_sel_hword    (MEM_data_sram_sel_hword ),
    .MEM_data_sram_sel_word     (MEM_data_sram_sel_word  ),
    .MEM_unhit                  (MEM_unhit               ),
    .MEM_cache_paddr            (MEM_cache_paddr         ),
    .MEM_cache_op               (MEM_cache_op            ),
    .MEM_mult_pro               (MEM_mult_pro            )
    );
    


    assign {
        MEM_Ra,
        MEM_Rb
    } = MEM_read_register;

    
	//乘法�???

	//hi_lo寄存�???
	hi_lo h_l(
		.clk(clk),
		.reset(reset),
		.hi_upgrade(hi_upgrade),
		.lo_upgrade(lo_upgrade),
		.hi_ctr_write(hi_ctr_write_en),
		.lo_ctr_write(lo_ctr_write_en),
		.hi_data(hi_data),
		.lo_data(lo_data)
	);

    wire [63:0] MEM_madd_pro = {hi_data,lo_data} + MEM_mult_pro;
    wire [63:0] MEM_msub_pro = {hi_data,lo_data} - MEM_mult_pro;
    assign hi_ctr_write_en = MEM_hi_ctrl_write & !flush & !MEM_is_ex &!MEM_is_eret && !MEM_inst_refetch && MEM_valid;
    assign lo_ctr_write_en = MEM_lo_ctrl_write & !flush & !MEM_is_ex &!MEM_is_eret && !MEM_inst_refetch && MEM_valid;

    assign hi_upgrade = (MEM_inst_table[`MULT] || MEM_inst_table[`MULTU])  ? MEM_mult_pro[63:32]:
                        (MEM_inst_table[`DIV]  || MEM_inst_table[`DIVU])   ? MEM_div_pro[31:0]:
                        (MEM_inst_table[`MADD] || MEM_inst_table[`MADDU])  ? MEM_madd_pro[63:32]:
                        (MEM_inst_table[`MSUB] || MEM_inst_table[`MSUBU])  ? MEM_msub_pro[63:32]:
                        MEM_rf_data;

    assign lo_upgrade = (MEM_inst_table[`MULT] || MEM_inst_table[`MULTU])  ? MEM_mult_pro[31:0]:
                        (MEM_inst_table[`DIV]  || MEM_inst_table[`DIVU])   ? MEM_div_pro[63:32]:
                        (MEM_inst_table[`MADD] || MEM_inst_table[`MADDU])  ? MEM_madd_pro[31:0]:
                        (MEM_inst_table[`MSUB] || MEM_inst_table[`MSUBU] )  ? MEM_msub_pro[31:0]:
                        MEM_rf_data;


	//流水�???
	assign MEM_ready_go = (data_req_busy) ? dcache_data_ok:1'b1;
	assign MEM_allowin = !MEM_valid || MEM_ready_go && WR_allowin;
	
	always@(posedge clk)
	    if(reset | flush)
	        MEM_valid <= 1'b0;
	    else if(MEM_allowin)
	        MEM_valid <= MEM0_MEM_valid;
	  
	always@(posedge clk)
        if(reset)begin
            MEM_div_pro <= 0;
        end
	    else if(MEM_wr) begin
            MEM_div_pro <= div_MEM0_to_MEM;
	    end

    assign MEM_WR_valid = MEM_valid && MEM_ready_go;
    assign MEM_is_mtc0 = MEM_cp0_write_en;
	//访存
    wire [31:0]   MEM_lwordl_data,MEM_lwordr_data;

    assign MEM_lwordl_data = ({32{MEM_data_sram_sel_word[3]}} & dcache_rdata)                           |
                             ({32{MEM_data_sram_sel_word[2]}} & {dcache_rdata[23:0],MEM_rf_data[7:0]})  |
                             ({32{MEM_data_sram_sel_word[1]}} & {dcache_rdata[15:0],MEM_rf_data[15:0]}) |
                             ({32{MEM_data_sram_sel_word[0]}} & {dcache_rdata[7:0],MEM_rf_data[23:0]});

    assign MEM_lwordr_data = ({32{MEM_data_sram_sel_word[3]}} & {24'b0,dcache_rdata[31:24]})             |
                             ({32{MEM_data_sram_sel_word[2]}} & {16'b0,dcache_rdata[31:16]})             |
                             ({32{MEM_data_sram_sel_word[1]}} & {8'b0,dcache_rdata[31:8]})               |
                             ({32{MEM_data_sram_sel_word[0]}} & dcache_rdata);


    assign busW_inner_sel = !((|(MEM_inst_table[5:1])) | (|(MEM_inst_table[14:13])) | MEM_inst_table[`LWL] | MEM_inst_table[`LWR] | MEM_inst_table[`MUL]);
    assign MEM_busW_inner = ({32{MEM_inst_table[`MFHI]}} & hi_data) |
                            ({32{MEM_inst_table[`MFLO]}} & lo_data) |
                            ({32{MEM_inst_table[`MUL ]}} & MEM_mult_pro[31:0]) |
                            ({32{MEM_inst_table[`LW  ]}} & MEM_word_data) |
                            ({32{MEM_inst_table[`LB  ]}} & {{24{MEM_byte_data[7]}},MEM_byte_data}) |
                            ({32{MEM_inst_table[`LBU ]}} & {24'b0,MEM_byte_data}) |
                            ({32{MEM_inst_table[`LH  ]}} & {{16{MEM_hword_data[15]}},MEM_hword_data}) |
                            ({32{MEM_inst_table[`LHU ]}} & {16'b0,MEM_hword_data}) |
                            ({32{MEM_inst_table[`LWL ]}} & MEM_lwordl_data) |
                            ({32{MEM_inst_table[`LWR ]}} & MEM_lwordr_data) |
                            ({32{busW_inner_sel       }} & MEM_alu_result);

    assign MEM_byte_data  = ({8{MEM_data_sram_sel_word[3]}} & dcache_rdata[31:24]) |
                            ({8{MEM_data_sram_sel_word[2]}} & dcache_rdata[23:16]) |
                            ({8{MEM_data_sram_sel_word[1]}} & dcache_rdata[15: 8]) |
                            ({8{MEM_data_sram_sel_word[0]}} & dcache_rdata[ 7: 0]) ;


    assign MEM_hword_data = ({16{MEM_data_sram_sel_hword[1]}} & dcache_rdata[31:16]) |
                            ({16{MEM_data_sram_sel_hword[0]}} & dcache_rdata[15: 0]);
	assign MEM_word_data = dcache_rdata;
    always@(*)
        if(MEM_inst_table[`LWL])
            begin
        if(MEM_data_sram_sel_word[3])
            MEM_reg_write_en = 4'b1111;
        else if(MEM_data_sram_sel_word[2])
            MEM_reg_write_en = 4'b1110;
        else if(MEM_data_sram_sel_word[1])
            MEM_reg_write_en = 4'b1100;
        else if(MEM_data_sram_sel_word[0])
            MEM_reg_write_en = 4'b1000;
        else 
            MEM_reg_write_en = 4'b0000;
            end
        else if(MEM_inst_table[`LWR])
            begin
        if(MEM_data_sram_sel_word[3])
            MEM_reg_write_en = 4'b0001;
        else if(MEM_data_sram_sel_word[2])
            MEM_reg_write_en = 4'b0011;
        else if(MEM_data_sram_sel_word[1])
            MEM_reg_write_en = 4'b0111;
        else if(MEM_data_sram_sel_word[0])
            MEM_reg_write_en = 4'b1111;
        else 
            MEM_reg_write_en = 4'b0000;
            end
        else 
            MEM_reg_write_en = {4{MEM_ctrl_reg_write}};


	//前�??
    wire   data_req_busy_forward; 
	always@(*)
	    if(!MEM_valid)
	        sel_forward = 2'b00;
	    else begin
	        sel_forward[0] = (!(MEM_Ra ^ MEM_write_reg) && MEM_ctrl_reg_write);
	        sel_forward[1] = (!(MEM_Rb ^ MEM_write_reg) && MEM_ctrl_reg_write);
	    end 
    wire MEM_is_load = |(MEM_inst_table[5:1]);
    wire MEM_is_lwl_lwr = (MEM_inst_table[`LWL] | MEM_inst_table[`LWR]);
    assign MEM_forward = {
        MEM_alu_result,//45+32=77
        data_req_busy_forward,
        MEM_inst_table[`MFHI],
        MEM_inst_table[`MFLO],
        MEM_is_load,
        MEM_is_lwl_lwr,
        MEM_valid,
        MEM_inst_table[`MFC0],
        MEM_reg_write_en,
        sel_forward,
        MEM_busW_inner
        };
     
    assign data_req_busy_forward = data_req_busy && !dcache_data_ok;
    assign MEM_valid_to_MEM0 = MEM_valid;

    //中断冲突处理
	assign MEM_int_hazard = (MEM_cp0_write_en && (MEM_cp0_write_reg == 8'b01100000 || MEM_cp0_write_reg == 8'b01101000));

    //tlbp冒险
    assign MEM_tlbp_hazard = (MEM_cp0_write_en && (MEM_cp0_write_reg == 8'b01010_000)) && MEM_valid;
    //MEM级异常处�???
    assign MEM_is_ex = MEM_exception_info[`EX_INFO-1];

    //tlb指令冲突
	assign MEM_inst_refetch_o = (MEM_inst_table[`TLBWI] || MEM_inst_table[`TLBR] || MEM_inst_table[`CACHE] || MEM_inst_table[`TLBWR]) && MEM_valid;
endmodule
