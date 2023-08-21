`include "reg_defines.v"
module EXE_reg(
    input clk,
    input reset,
    input flush,

    input EXE_wr,
    //input reg signals
    input 						        ID_hit              ,
    input [1:0] 				        ID_branch_type      ,
    input                               ID_predict_pc_dir,
    input                               ID_inst_refetch,
    input                               ID_is_branch,
    input   [`INST_TABLE_WD-1:0]        ID_inst_table,
  
    input   [31:0]                      ID_alu_src1   ,
    input   [31:0]                      ID_alu_src2   ,
    input   [11:0]                      ID_alu_control,
    input                               ID_add_sub_sign,
  
    input                               ID_ctrl_reg_write,
    input   [4:0]                       ID_write_reg,
    input                               ID_ctrl_write,
    input                               ID_hi_ctrl_write,
    input                               ID_lo_ctrl_write,  
    input                               ID_cp0_write_en,
    input  [7:0]                        ID_cp0_write_reg,

  
    input   [`EX_INFO-1:0]              ID_exception_info,   
    input   [31:0]                      ID_badvaddr,

    input   [31:0]                      ID_pc,
    input   [31:0]                      ID_rf_data,
    input                               ID_branch_hit,
    input   [31:0]                      ID_branch_next_pc,
    input   [31:0]                      ID_predict_pc,
    input                               ID_unhit,
    input   [4:0]                       ID_cache_op,

    input                               ID_is_branch_likely,
    input                               ID_branch_likely_hit,
    input                               ID_is_jr            ,
    input   [31:0]                      ID_btb_branch_pc    ,
    //output reg signals
    output reg						      EXE_hit         ,
    output reg[1:0] 				      EXE_branch_type ,
    output reg                            EXE_predict_pc_dir,
    output reg                            EXE_inst_refetch,
    output reg                            EXE_is_branch,
    output reg[`INST_TABLE_WD-1:0]        EXE_inst_table,

    output reg[31:0]                      EXE_alu_src1   ,
    output reg[31:0]                      EXE_alu_src2   ,
    output reg[11:0]                      EXE_alu_control,
    output reg                            EXE_add_sub_sign,

    output reg                            EXE_ctrl_reg_write,
    output reg[4:0]                       EXE_write_reg,
    output reg                            EXE_ctrl_write,
    output reg                            EXE_hi_ctrl_write,
    output reg                            EXE_lo_ctrl_write,  
    output reg                            EXE_cp0_write_en,
    output reg[7:0]                       EXE_cp0_write_reg,

    output reg[`EX_INFO-1:0]              EXE_exception_info,   
    output reg[31:0]                      EXE_badvaddr,

    output reg[31:0]                      EXE_pc,
    output reg[31:0]                      EXE_rf_data,

    output reg                            EXE_branch_hit,
    output reg[31:0]                      EXE_branch_next_pc,
    output reg[31:0]                      EXE_predict_pc,

    output reg                            EXE_unhit,
    output reg [4:0]                      EXE_cache_op,
    output reg                            EXE_is_branch_likely,

    output reg                            EXE_branch_likely_hit,
    output reg                            EXE_is_jr            ,
    output reg [31:0]                     EXE_btb_branch_pc   

);
    always@(posedge clk)begin
        if(reset | flush)begin
            EXE_hit              <= 0;
            EXE_branch_type      <= 0;
            EXE_predict_pc_dir   <= 0;
            EXE_inst_refetch     <= 0;
            EXE_is_branch        <= 0;
            EXE_inst_table       <= 0;
            EXE_alu_src1         <= 0;
            EXE_alu_src2         <= 0;
            EXE_alu_control      <= 0;
            EXE_add_sub_sign     <= 0;
            EXE_ctrl_reg_write   <= 0;   
            EXE_write_reg        <= 0;
            EXE_ctrl_write       <= 0;
            EXE_hi_ctrl_write    <= 0;   
            EXE_lo_ctrl_write    <= 0;
            EXE_cp0_write_en     <= 0;
            EXE_cp0_write_reg    <= 0;   
            EXE_exception_info   <= 0;   
            EXE_badvaddr         <= 0; 
            EXE_pc               <= 0;
            EXE_rf_data          <= 0;
            EXE_branch_hit       <= 0;
            EXE_branch_next_pc   <= 0;
            EXE_predict_pc       <= 0;
            EXE_unhit            <= 0;
            EXE_cache_op         <= 0;
            EXE_is_branch_likely <= 0;
            EXE_branch_likely_hit <= 0;
            EXE_is_jr             <= 0;
            EXE_btb_branch_pc     <= 0;
        end
        else if(EXE_wr) begin
            EXE_hit              <= ID_hit            ;
            EXE_branch_type      <= ID_branch_type    ;
            EXE_predict_pc_dir   <= ID_predict_pc_dir ;
            EXE_inst_refetch     <= ID_inst_refetch   ;
            EXE_is_branch        <= ID_is_branch      ;
            EXE_inst_table       <= ID_inst_table     ;
            EXE_alu_src1         <= ID_alu_src1       ;
            EXE_alu_src2         <= ID_alu_src2       ;
            EXE_alu_control      <= ID_alu_control    ;
            EXE_add_sub_sign     <= ID_add_sub_sign   ;
            EXE_ctrl_reg_write   <= ID_ctrl_reg_write ;
            EXE_write_reg        <= ID_write_reg      ;
            EXE_ctrl_write       <= ID_ctrl_write     ;
            EXE_hi_ctrl_write    <= ID_hi_ctrl_write  ;
            EXE_lo_ctrl_write    <= ID_lo_ctrl_write  ;
            EXE_cp0_write_en     <= ID_cp0_write_en   ;
            EXE_cp0_write_reg    <= ID_cp0_write_reg  ;
            EXE_exception_info   <= ID_exception_info ;
            EXE_badvaddr         <= ID_badvaddr       ;
            EXE_pc               <= ID_pc             ;
            EXE_rf_data          <= ID_rf_data        ;
            EXE_branch_hit       <= ID_branch_hit     ;
            EXE_branch_next_pc   <= ID_branch_next_pc ;
            EXE_predict_pc       <= ID_predict_pc     ;
            EXE_unhit            <= ID_unhit          ;
            EXE_cache_op         <= ID_cache_op       ;
            EXE_is_branch_likely <= ID_is_branch_likely;
            EXE_branch_likely_hit <= ID_branch_likely_hit;
            EXE_is_jr            <= ID_is_jr         ;
            EXE_btb_branch_pc    <= ID_btb_branch_pc ;
        end
    end

endmodule