`include "lib/defines.v"

module Control(
		input [5:0] 		op,
		input [5:0] 		func,
		input [4:0] 		rs,
		input [4:0] 		sa,
		input [4:0] 		rt,
		input [31:0] 		ID_to_ctrl_bus1,
		input [31:0] 		ID_to_ctrl_bus2,

		output [11:0] 	    alu_control,
		output 			    ctrl_write,
		output 			    ctrl_reg_write,
		output [2:0] 	    sel_rf_dst,
		output [2:0] 	    sel_alu_src1,
		output [3:0] 	    sel_alu_src2,
		output [3:0] 	    sel_nextpc,
		output [3:0] 	    sel_nextpc_predict,
		output 			    reg1_valid,
		output 			    reg2_valid,
		output			    hi_ctr_write,
		output 			    lo_ctr_write,
		output 			    sel_bus,
		output 			    sel_mem_hi,
		output			    sel_mem_lo,
		output  		    cp0_write_en,
		output 			    sel_cp0,
		output			    syscall_ex,
		output			    break_ex,
		output 			    add_sub_sign,
		output			    reserved_inst_ex,
		output 			    is_branch,
        output              is_jr,

        output[`INST_TABLE_WD-1:0]              ID_inst_table,
        output [4:0]        cache_op,
        output              cpU_ex,

        output              b_branch_likely,
        output              branch_likely_hit,
        
        output              branch_likely_clear
    );
    
    //===============译码======================
    
    reg is_sa_0;
    always @(*) begin
        case(sa)
            5'b00000: is_sa_0 = 1;
            default: is_sa_0 = 0;
        endcase
    end
    reg is_rt_0;
    always @(*) begin
        case(rt)
            5'b00000: is_rt_0 = 1;
            default: is_rt_0 = 0;
        endcase
    end
    reg is_op_0, is_op_1, is_op_16, is_op_28;
    always @(*) begin
        case(op)
            6'b000000: begin is_op_0 = 1; is_op_1 = 0; is_op_16 = 0; is_op_28 = 0; end
            6'b000001: begin is_op_0 = 0; is_op_1 = 1; is_op_16 = 0; is_op_28 = 0; end
            6'b010000: begin is_op_0 = 0; is_op_1 = 0; is_op_16 = 1; is_op_28 = 0; end
            6'b011100: begin is_op_0 = 0; is_op_1 = 0; is_op_16 = 0; is_op_28 = 1; end
            default: begin is_op_0 = 0; is_op_1 =0; is_op_16 = 0; is_op_28 = 0;end
        endcase
    end
    reg [4:0] rs_d;
    always @(*) begin
        case(rs)
            5'b00000: rs_d = 5'b00001;
            5'b00100: rs_d = 5'b00010;
            5'b00101: rs_d = 5'b00100;
            5'b01110: rs_d = 5'b01000;
            5'b10000: rs_d = 5'b10000;
            default:  rs_d = 5'b0;
        endcase
    end
    //指令集1：30条
    wire inst_sll       = is_op_0 && rs_d[0] && func == 0;
    wire inst_movft     = is_op_0 && is_sa_0 && func == 1;
    wire inst_srl       = is_op_0 && rs_d[0] && func == 2;
    wire inst_sra       = is_op_0 && rs_d[0] && func == 3;
    wire inst_sllv      = is_op_0 && is_sa_0 && func == 4;
    wire inst_srlv      = is_op_0 && is_sa_0 && func == 6;
    wire inst_srav      = is_op_0 && is_sa_0 && func == 7;
    wire inst_jr        = is_op_0 && is_rt_0 && is_sa_0 && func == 8;
    wire inst_jalr      = is_op_0 && is_rt_0 && is_sa_0 && func == 9;
    wire inst_movz      = is_op_0 && is_sa_0 && func == 10;
    wire inst_movn      = is_op_0 && is_sa_0 && func == 11;
    wire inst_syscall   = is_op_0 && func == 12;
    wire inst_break     = is_op_0 && func == 13;
    wire inst_sync      = (is_op_0 && rs_d[0]) && (is_rt_0 && func == 15);
    wire inst_mfhi      = (is_op_0 && rs_d[0]) && (is_rt_0 && is_sa_0) && func == 16;
    wire inst_mthi      = (is_op_0 && is_rt_0) && (is_sa_0 && func == 17);
    wire inst_mflo      = (is_op_0 && rs_d[0]) && (is_rt_0 && is_sa_0) && func == 18;
    wire inst_mtlo      = (is_op_0 && is_rt_0) && (is_sa_0 && func == 19);
    wire inst_mult      = is_op_0 && is_sa_0 && func == 24;
    wire inst_multu     = is_op_0 && is_sa_0 && func == 25;
    wire inst_div       = is_op_0 && is_sa_0 && func == 26;
    wire inst_divu      = is_op_0 && is_sa_0 && func == 27;
    wire inst_add       = is_op_0 && is_sa_0 && func == 32;
    wire inst_addu      = is_op_0 && is_sa_0 && func == 33;
    wire inst_sub       = is_op_0 && is_sa_0 && func == 34;
    wire inst_subu      = is_op_0 && is_sa_0 && func == 35;
    wire inst_and       = is_op_0 && is_sa_0 && func == 36;
    wire inst_or        = is_op_0 && is_sa_0 && func == 37;
    wire inst_xor       = is_op_0 && is_sa_0 && func == 38;
    wire inst_nor       = is_op_0 && is_sa_0 && func == 39;
    //指令集2：30条
    wire inst_slt       = is_op_0 && is_sa_0 && func == 42;
    wire inst_sltu      = is_op_0 && is_sa_0 && func == 43;
    wire inst_tge       = is_op_0 && func == 48;
    wire inst_tgeu      = is_op_0 && func == 49;
    wire inst_tlt       = is_op_0 && func == 50;
    wire inst_tltu      = is_op_0 && func == 51;
    wire inst_teq       = is_op_0 && func == 52;
    wire inst_tne       = is_op_0 && func == 54;
    wire inst_bltz      = is_op_1 && is_rt_0;
    wire inst_bgez      = is_op_1 && rt == 1;
    wire inst_tgei      = is_op_1 && rt == 8;
    wire inst_tgeiu     = is_op_1 && rt == 9;
    wire inst_tlti      = is_op_1 && rt == 10;
    wire inst_tltiu     = is_op_1 && rt == 11;
    wire inst_teqi      = is_op_1 && rt == 12;
    wire inst_tnei      = is_op_1 && rt == 14;
    wire inst_bltzl     = is_op_1 && rt == 2;
    wire inst_bgezl     = is_op_1 && rt == 3;
    wire inst_bltzal    = is_op_1 && rt == 16;
    wire inst_bgezal    = is_op_1 && rt == 17;
    wire inst_bltzall   = is_op_1 && rt == 18;
    wire inst_bgezall   = is_op_1 && rt == 19;
    wire inst_j         = (op == 2);
    wire inst_jal       = (op == 3);
    wire inst_beq       = (op == 4);
    wire inst_bne       = (op == 5);
    wire inst_blez      = (op == 6) && is_rt_0;
    wire inst_bgtz      = (op == 7) && is_rt_0;
    wire inst_addi      = (op == 8);
    wire inst_addiu     = (op == 9);
    //指令集3：30条
    wire inst_slti      = (op == 10);
    wire inst_sltiu     = (op == 11);
    wire inst_andi      = (op == 12);
    wire inst_ori       = (op == 13);
    wire inst_xori      = (op == 14);
    wire inst_lui       = (op == 15);
    wire inst_mfc0      = (is_op_16 && rs_d[0] ) && (is_sa_0 && func[5:3] == 3'b000);
    wire inst_mtc0      = (is_op_16 && rs_d[1] ) && (is_sa_0 && func[5:3] == 3'b000);
    wire inst_tlbr      = (is_op_16 && rs_d[4]) && (is_rt_0 && is_sa_0) && func == 1;
    wire inst_tlbwi     = (is_op_16 && rs_d[4]) && (is_rt_0 && is_sa_0) && func == 2;
    wire inst_tlbwr     = (is_op_16 && rs_d[4]) && (is_rt_0 && is_sa_0) && func == 6;
    wire inst_tlbp      = (is_op_16 && rs_d[4]) && (is_rt_0 && is_sa_0) && func == 8;
    wire inst_eret      = (is_op_16 && rs_d[4]) && (is_rt_0 && is_sa_0) && func == 24;
    wire inst_wait      = is_op_16 && rs_d[2] && func == 32;
    wire inst_cop1      = (op == 17) && !rs_d[3]; 
    wire inst_beql      = (op == 20);
    wire inst_bnel      = (op == 21);
    wire inst_blezl     = (op == 22) && is_rt_0;
    wire inst_bgtzl     = (op == 23) && is_rt_0;
    wire inst_madd      = is_op_28 && is_sa_0 && func == 0;
    wire inst_maddu     = is_op_28 && is_sa_0 && func == 1;
    wire inst_mul       = is_op_28 && is_sa_0 && func == 2;
    wire inst_msub      = is_op_28 && is_sa_0 && func == 4;
    wire inst_msubu     = is_op_28 && is_sa_0 && func == 5;
    wire inst_clz       = is_op_28 && is_sa_0 && func == 32;
    wire inst_clo       = is_op_28 && is_sa_0 && func == 33;
    wire inst_lb        = (op == 32);
    wire inst_lh        = (op == 33);
    wire inst_lwl       = (op == 34);
    wire inst_lw        = (op == 35);
    //指令集4：15条
    wire inst_lbu       = (op == 36);
    wire inst_lhu       = (op == 37);
    wire inst_lwr       = (op == 38);
    wire inst_sb        = (op == 40);
    wire inst_sh        = (op == 41);
    wire inst_swl       = (op == 42);
    wire inst_sw        = (op == 43);
    wire inst_swr       = (op == 46);
    wire inst_cache     = (op == 47);
    wire inst_ll        = (op == 48);
    wire inst_lwc1      = (op == 49);
    wire inst_pref      = (op == 51);
    wire inst_ldc1      = (op == 53);
    wire inst_sc        = (op == 56);
    wire inst_swc1      = (op == 57);
    wire inst_sdc1      = (op == 61);
    //===============cache_op==================
    assign cache_op = rt;
    //===============控制======================
    //指令集
    wire [25:0] inst_conclu1 = {    inst_sll    ,
                                    inst_srl    ,
                                    inst_sra    ,
                                    inst_sllv   ,
                                    inst_srlv   ,
                                    inst_srav   ,
                                    inst_jr     ,
                                    inst_jalr   ,
                                    inst_syscall,
                                    inst_break  ,
                                    inst_mfhi   ,
                                    inst_mthi   ,
                                    inst_mflo   ,
                                    inst_mtlo   ,
                                    inst_mult   ,
                                    inst_multu  ,
                                    inst_div    ,
                                    inst_divu   ,
                                    inst_add    ,
                                    inst_addu   ,
                                    inst_sub    ,
                                    inst_subu   ,
                                    inst_and    ,
                                    inst_or     ,
                                    inst_xor    ,
                                    inst_nor    };
    wire reserved_inst_ex1 = !(|inst_conclu1) ;

    wire [19:0] inst_conclu2 = {    inst_slt    ,
                                    inst_sltu   ,
                                    inst_bltz   ,
                                    inst_bgez   ,
                                    inst_bltzal ,
                                    inst_bgezal ,
                                    inst_j      ,
                                    inst_jal    ,
                                    inst_beq    ,
                                    inst_bne    ,
                                    inst_blez   ,
                                    inst_bgtz   ,
                                    inst_addi   ,
                                    inst_addiu  ,
                                    inst_madd   ,
                                    inst_maddu  ,
                                    inst_msub   ,
                                    inst_msubu  ,
                                    inst_sync   ,
                                    inst_pref
                                     };
    wire reserved_inst_ex2 = !(|inst_conclu2);

    wire [24:0] inst_conclu3 = {    inst_slti   ,
                                    inst_sltiu  ,
                                    inst_andi   ,
                                    inst_ori    ,
                                    inst_xori   ,
                                    inst_lui    ,
                                    inst_mfc0   ,
                                    inst_mtc0   ,
                                    inst_eret   ,
                                    inst_mul    ,
                                    inst_lb     ,
                                    inst_lh     ,
                                    inst_lw     ,
                                    inst_tge    ,
                                    inst_tgei   ,
                                    inst_tgeu   ,
                                    inst_tgeiu  ,
                                    inst_tlt    ,
                                    inst_tlti   , 
                                    inst_tltu   ,
                                    inst_tltiu  ,
                                    inst_teq    ,
                                    inst_teqi   ,
                                    inst_tne    ,
                                    inst_tnei 
                                    };
    wire reserved_inst_ex3 = !(|inst_conclu3);

    wire [24:0] inst_conclu4 = {    inst_lbu    ,
                                    inst_lhu    ,
                                    inst_sb     ,
                                    inst_sh     ,
                                    inst_sw     ,
                                    inst_clo    ,
                                    inst_clz    ,
                                    inst_movn   ,
                                    inst_movz   ,
                                    inst_lwl    ,
                                    inst_lwr    ,
                                    inst_swl    ,
                                    inst_swr    ,
                                    inst_cache  ,
                                    inst_tlbp   ,
                                    inst_tlbr   ,
                                    inst_tlbwi  ,
                                    inst_wait   ,
                                    inst_movft  ,
                                    inst_cop1   ,
                                    inst_lwc1   ,
                                    inst_ldc1   ,
                                    inst_swc1   ,
                                    inst_sdc1   ,
                                    inst_tlbwr  
                                    };
    wire reserved_inst_ex4 = !(|inst_conclu4);

    wire [1:0] inst_conclu5 = {
                    inst_beql,
                    inst_bnel
    };
    wire reserved_inst_ex5 = !(|inst_conclu5);
    //cpU异常
    assign cpU_ex = inst_movft||inst_cop1||inst_lwc1||inst_ldc1||inst_swc1||inst_sdc1;
    assign is_jr = inst_jr || inst_jalr;
    //指令不存在异常
    assign reserved_inst_ex =   (reserved_inst_ex1 &
                                reserved_inst_ex2) &
                                (reserved_inst_ex3 &
                                reserved_inst_ex4  &
                                reserved_inst_ex5);

    //异常信号
    assign  syscall_ex  = inst_syscall;
    assign  break_ex    = inst_break;
    
    //hi_lo寄存器信号
    assign  sel_bus         = (inst_mthi | inst_mtlo);
    assign  hi_ctr_write    = ((inst_mult | inst_multu) | 
                               (inst_div  | inst_divu)  | 
                               inst_mthi) | ((inst_madd   |
                               inst_msub)  | (inst_maddu  |
                               inst_msubu));
	assign  lo_ctr_write    = ((inst_mult | inst_multu) | 
                               (inst_div  | inst_divu)  | 
                               inst_mtlo) | ((inst_madd   |
                               inst_msub)  | (inst_maddu  |
                               inst_msubu));

    //加减法信号
    assign  add_sub_sign = (inst_add | inst_addi | inst_sub);

    //通用寄存器访问信号
    assign  reg1_valid = !(	((inst_sll |inst_mfc0)	|
	    				    (inst_mtc0| inst_sra)) 	| 
	    				    ((inst_srl | inst_j) 	| 
	    				    (inst_jal |inst_mfhi))	| 
	    				   ( (inst_mflo|inst_pref)   |
                            (inst_sync)) | (inst_tlbp)|
                            (inst_tlbr)  | (inst_tlbwi) | (inst_wait)
	    			    ) | (|rs);
    assign  reg2_valid = !(	(((inst_addi|inst_mfc0)  	| 
	    				    (inst_addiu|inst_slti)) 	| 
	    				    ((inst_sltiu|inst_mthi) 	|
	    				    (inst_mtlo|inst_andi)))  	|
	    				    (((inst_mfhi|inst_mflo)  	| 
	    				    (inst_lui | inst_ori))  	| 
	    				    ((inst_xori | inst_j)   	| 
	    				    (inst_jal | inst_jr)))   	|
	    				    (((inst_lb|inst_lw)	   		|  
	    				    (inst_lbu | inst_lh))   	| 
	    				    (inst_lhu))|((inst_lwl)      |
                            (inst_lwr)) |
                            ((inst_sync | inst_pref)     |
                            (inst_clo  | inst_clz))     |
                            (inst_cache) | (inst_tlbp) |
                            (inst_tlbr) | (inst_tlbwi) | (inst_wait)| (inst_tgei)|(inst_tgeiu) | (inst_tlti) | (inst_tltiu) |
                            (inst_teqi) | (inst_tnei)
	    			    ) | (|rt);
    assign  ctrl_reg_write = ~( (((inst_sw |inst_sh)  | 
                                (inst_beq|inst_mtc0))|
                                ((inst_mthi|inst_mtlo)|
                                (inst_sb|inst_bne)))|
                                (((inst_j|inst_jr)|
                                (inst_bgez|inst_bgtz))|
                                ((inst_blez|inst_bltz)|
                                (inst_mult|inst_multu)))|
                                ((inst_madd|inst_maddu) |
                                (inst_msub|inst_msubu)) |
                                ((inst_pref|inst_sync)   |
                                (inst_tge  |inst_tgei))  |
                                ((inst_tgeu |inst_tgeiu) |
                                (inst_tlt  |inst_tlti))  |
                                ((inst_tltu |inst_tltiu) |
                                (inst_teq  |inst_teqi))  |
                               ( (inst_tne  |inst_tnei)   |
                                (inst_swl  |inst_swr ))  |
                                (inst_cache | inst_tlbp) |
                                (inst_tlbr  | inst_tlbwi) |
                                (inst_wait |inst_beql) |
                                (inst_bnel) | (inst_tlbwr)
                            );
	 //movn,movz
     
    
    //访存信号
    assign  ctrl_write  =   (inst_sw | inst_sb | inst_sh| inst_swl | inst_swr);

    //CP0控制信号
	assign  cp0_write_en = inst_mtc0;
	assign  sel_cp0		 = inst_mfc0;

    //跳转控制信号
    wire con_neq =  | (ID_to_ctrl_bus1 ^ ID_to_ctrl_bus2);
    wire con_eq  =  !con_neq;
    wire con_neqz =  | (ID_to_ctrl_bus1);
    wire con_eqz = !con_neqz;
	assign  is_branch = ((inst_beq | inst_bne)      | 
					     (inst_j   | inst_jal))     | 
					    ((inst_jalr| inst_jr)       | 
					    (inst_bgez | inst_bgezal))  | 
					    ((inst_blez | inst_bltz)    | 
					    (inst_bltzal | inst_bgtz))  | branch_likely_hit;

	assign  b_branch =  (inst_beq & con_eq)      |
				        (inst_bne & con_neq)     |
				        ((inst_bgez|inst_bgezal) & (!ID_to_ctrl_bus1[31]))  |
				        (inst_bgtz & (!ID_to_ctrl_bus1[31] & con_neqz))|
				        (inst_blez & (ID_to_ctrl_bus1[31] | con_eqz))|
				        ((inst_bltz|inst_bltzal) & ID_to_ctrl_bus1[31]);

    assign  b_branch_likely = (inst_beql & con_eq) | 
                              (inst_bnel & con_neq);

    assign branch_likely_hit = (inst_beql) | inst_bnel;

    //condition 
 
    //=============独热码选择器================
    //branch_likely
    
    //控制nextpc	
    wire sel_nextpc_predict_ctrl1 = ((inst_beq | inst_bne) | (inst_bgez|inst_bgezal)) | ((inst_bgtz | inst_blez) | (inst_bltz|inst_bltzal)) | branch_likely_hit;
	assign sel_nextpc_predict = sel_nextpc_predict_ctrl1    ? 4'b0010  :
                                (inst_jal | inst_j  )       ? 4'b0100  :
                                (inst_jr  | inst_jalr)      ? 4'b1000  :
                                                              4'b0001  ;
    assign sel_nextpc = (b_branch | b_branch_likely)        ?4'b0010  :
                        (inst_jal | inst_j  )               ?4'b0100  :
                        (inst_jr  | inst_jalr)              ?4'b1000  :
                                                             4'b0001  ;

    //控制ALU运算
    //alu_src1
    wire sel_alu_src1_ctrl1 = 
            (inst_jal | inst_jalr) | 
            (inst_bgezal | inst_bltzal);
    
    wire sel_alu_src1_ctrl2 = 
            inst_sll | inst_srl |inst_sra;
    
    wire sel_alu_src1_ctrl3 =
            ((  (inst_beq | inst_bne)  | 
                (inst_jr  |inst_mfhi)) |
            (   (inst_mtc0|inst_mfc0)  |
                (inst_mflo|inst_mthi)))|
            ((  (inst_mtlo|inst_lui)   | 
                (inst_bgez|inst_bgtz)) | 
            (   (inst_blez|inst_bltz)  | inst_j)
            );

    assign sel_alu_src1 =   sel_alu_src1_ctrl1  ?   3'b010:
                            sel_alu_src1_ctrl2  ?   3'b100:
                            sel_alu_src1_ctrl3  ?   3'b000:
                                                    3'b001;

    //alu_src2
	wire sel_alu_src2_ctrl1 =
            ((inst_addiu|inst_sw)       | 
            (inst_sb    |inst_sh))      | 
            ((inst_lui  | inst_addi)    | 
            (inst_slti  | inst_sltiu))  |
            ((inst_lw | inst_lb)        | 
            (inst_lh | inst_lhu))       | 
            ((inst_lbu | inst_tgei)     |
            (inst_tgeiu|inst_tlti))     |
            ((inst_tltiu|inst_teqi)     |
            (inst_tnei)) | ((inst_lwl)   |
            (inst_lwr))   | ((inst_swl)   |
            (inst_swr)) | inst_cache;
    
    wire sel_alu_src2_ctrl2 = 
            (inst_jal | inst_jalr)  |
            (inst_bgezal|inst_bltzal);

    wire sel_alu_src2_ctrl3 = sel_alu_src1_ctrl3;
 
    wire sel_alu_src2_ctrl4 = inst_andi | inst_ori |inst_xori;
	
    assign sel_alu_src2 =   sel_alu_src2_ctrl1  ?   4'b0010:
                            sel_alu_src2_ctrl2  ?   4'b0100:
                            sel_alu_src2_ctrl3  ?   4'b0000:
                            sel_alu_src2_ctrl4  ?   4'b1000:
                                                    4'b0001;

    //alu_control
    wire alu_control_ctrl1 =
            (((inst_addu  |   inst_addiu)| 
            (inst_lw      |   inst_sw))  |
            ((inst_lbu    |   inst_lh)   |
            (inst_lhu     |   inst_sh))) |
            (((inst_jal   |  inst_bgezal)|
            (inst_bltzal  |  inst_add))  | 
            ((inst_addi   |  inst_jalr)  |
            (inst_sb      |  inst_lb)))  |
            (((inst_lwl     |  inst_lwr)) |
            ((inst_swl     |  inst_swr))) | inst_cache  ;

    wire  alu_control_ctrl2 = 
             (inst_sub  | inst_subu)|
            ((inst_pref|inst_sync)   |
            (inst_tge  |inst_tgei))  |
            ((inst_tgeu |inst_tgeiu) |
            (inst_tlt  |inst_tlti))  |
            ((inst_tltu |inst_tltiu) |
            (inst_teq  |inst_teqi))  |
            (inst_tne  |inst_tnei)  ;

    
    assign alu_control =    alu_control_ctrl1     ?   12'b000000000001:
                            alu_control_ctrl2     ?   12'b000000000010:
                            (inst_and|inst_andi)  ?   12'b000000000100:
                            (inst_or | inst_ori)  ?   12'b000000001000:
                            (inst_xor|inst_xori)  ?   12'b000000010000:
                            (inst_sll|inst_sllv)  ?   12'b000000100000:
                            (inst_srl|inst_srlv)  ?   12'b000001000000:
                            (inst_sra|inst_srav)  ?   12'b000010000000:
                            (inst_slt|inst_slti)  ?   12'b000100000000:
                            (inst_lui            )?   12'b001000000000:
                            (inst_sltu|inst_sltiu)?   12'b010000000000:
                            (inst_nor            )?   12'b100000000000:
                                                      12'b0;
	
        
    //选择寄存器堆写地址 
    wire sel_rf_dst_ctrl1 =
            (((inst_addiu   |   inst_lw)    |
            (inst_mfc0      |   inst_lbu))  | 
            ((inst_lh       |   inst_lhu)   | 
            (inst_lui       |   inst_addi)))|  
            (((inst_andi    |   inst_ori)     | 
            (inst_xori      |   inst_lb ))    | 
            (inst_slti      |   inst_sltiu))  |
            (inst_lwl       |   inst_lwr   )
            ;
    
    wire sel_rf_dst_ctrl2 =
            inst_jal | inst_bltzal | inst_bgezal;

         
    assign sel_rf_dst =     sel_rf_dst_ctrl1    ?   3'b010:
                            sel_rf_dst_ctrl2    ?   3'b100:
                                                    3'b001;	

    assign ID_inst_table[`ERET ]  = inst_eret;
    assign ID_inst_table[`LB   ]  = inst_lb;
    assign ID_inst_table[`LW   ]  = inst_lw;
    assign ID_inst_table[`LBU  ]  = inst_lbu;
    assign ID_inst_table[`LH   ]  = inst_lh;
    assign ID_inst_table[`LHU  ]  = inst_lhu;
    assign ID_inst_table[`SH   ]  = inst_sh;
    assign ID_inst_table[`SW   ]  = inst_sw;
    assign ID_inst_table[`SB   ]  = inst_sb;
    assign ID_inst_table[`DIV  ]  = inst_div;
    assign ID_inst_table[`DIVU ]  = inst_divu;
    assign ID_inst_table[`MULT ]  = inst_mult;
    assign ID_inst_table[`MULTU]  = inst_multu;
    assign ID_inst_table[`MFHI ]  = inst_mfhi;
    assign ID_inst_table[`MFLO ]  = inst_mflo;
    assign ID_inst_table[`MFC0 ]  = inst_mfc0;
    assign ID_inst_table[`MUL  ]  = inst_mul;
    assign ID_inst_table[`MADD ]  = inst_madd;
    assign ID_inst_table[`MADDU]  = inst_maddu;
    assign ID_inst_table[`MSUB ]  = inst_msub;
    assign ID_inst_table[`MSUBU]  = inst_msubu;
    assign ID_inst_table[`TLBP ]  = inst_tlbp;
    assign ID_inst_table[`TLBR ]  = inst_tlbr;
    assign ID_inst_table[`TLBWI]  = inst_tlbwi;
    assign ID_inst_table[`TGE  ]  = inst_tge ;
    assign ID_inst_table[`TGEI ]  = inst_tgei ;
    assign ID_inst_table[`TGEU ]  = inst_tgeu ;
    assign ID_inst_table[`TGEIU]  = inst_tgeiu;
    assign ID_inst_table[`TLT  ]  = inst_tlt ;
    assign ID_inst_table[`TLTI ]  = inst_tlti ;
    assign ID_inst_table[`TLTU ]  = inst_tltu ;
    assign ID_inst_table[`TLTIU]  = inst_tltiu;
    assign ID_inst_table[`TEQ  ]  = inst_teq ;
    assign ID_inst_table[`TEQI ]  = inst_teqi ;
    assign ID_inst_table[`TNE  ]  = inst_tne ;
    assign ID_inst_table[`TNEI ]  = inst_tnei ;
    assign ID_inst_table[`CLO  ]  = inst_clo ;
    assign ID_inst_table[`CLZ  ]  = inst_clz ; 
    assign ID_inst_table[`MOVN ]  = inst_movn;
    assign ID_inst_table[`MOVZ ]  = inst_movz;
    assign ID_inst_table[`LWL ]   = inst_lwl;
    assign ID_inst_table[`LWR ]   = inst_lwr;
    assign ID_inst_table[`SWL ]   = inst_swl;
    assign ID_inst_table[`SWR ]   = inst_swr;
    assign ID_inst_table[`LL  ]   = inst_ll;
    assign ID_inst_table[`SC  ]   = inst_sc;
    assign ID_inst_table[`CACHE]  = inst_cache;
    assign ID_inst_table[`WAIT]   = inst_wait;
    assign ID_inst_table[`TLBWR]  = inst_tlbwr;
    assign ID_inst_table[`JAL]    = inst_jal;
    assign ID_inst_table[`J]      = inst_j;
    assign ID_inst_table[`RET]    = inst_jr;

endmodule
