`include "reg_defines.v"
module MEM_reg(
    input clk,
    input reset,
    input flush,
    input MEM_wr,

    //input reg signals
    input                       MEM0_inst_refetch        ,
    input [`INST_TABLE_WD-1:0]  MEM0_inst_table          , 
    input [31:0]                MEM0_pc                  ,
    input [31:0]                MEM0_rf_data             ,
    input [31:0]                MEM0_alu_result          ,
    input [4:0]                 MEM0_write_reg           ,
    input                       MEM0_hi_ctrl_write       ,
    input                       MEM0_lo_ctrl_write       ,
    input                       MEM0_is_branch           ,
    input [31:0]                MEM0_badvaddr            ,
    input [`EX_INFO-1:0]        MEM0_exception_info      ,
    input                       MEM0_cp0_write_en        ,
    input [7:0]                 MEM0_cp0_write_reg       ,
    input                       MEM0_ctrl_write          ,
    input                       MEM0_ctrl_reg_write      ,
    input [1:0]                 MEM0_data_sram_sel_hword ,
    input [3:0]                 MEM0_data_sram_sel_word  ,
    input                       MEM0_unhit               ,
    input [4:0]                 MEM0_cache_op            ,
    input [31:0]                MEM0_cache_paddr         ,
    input [65:0]                MEM0_mult_pro            ,

    //output reg signals
    output reg                      MEM_inst_refetch        ,
    output reg[`INST_TABLE_WD-1:0]  MEM_inst_table          , 
    output reg[31:0]                MEM_pc                  ,
    output reg[31:0]                MEM_rf_data             ,
    output reg[31:0]                MEM_alu_result          ,
    output reg[4:0]                 MEM_write_reg           ,
    output reg                      MEM_hi_ctrl_write       ,
    output reg                      MEM_lo_ctrl_write       ,
    output reg                      MEM_is_branch           ,
    output reg[31:0]                MEM_badvaddr            ,
    output reg[`EX_INFO-1:0]        MEM_exception_info      ,
    output reg                      MEM_cp0_write_en        ,
    output reg[7:0]                 MEM_cp0_write_reg       ,
    output reg                      MEM_ctrl_write          ,
    output reg                      MEM_ctrl_reg_write      ,
    output reg[1:0]                 MEM_data_sram_sel_hword ,
    output reg[3:0]                 MEM_data_sram_sel_word  ,
    output reg                      MEM_unhit               ,
    output reg [4:0]                MEM_cache_op            ,
    output reg [31:0]               MEM_cache_paddr         ,
    output reg [63:0]               MEM_mult_pro
);
    always@(posedge clk)begin
        if(reset | flush)begin
            MEM_inst_refetch        <= 0;
            MEM_inst_table          <= 0;
            MEM_pc                  <= 0;
            MEM_rf_data             <= 0;
            MEM_alu_result          <= 0;
            MEM_write_reg           <= 0;
            MEM_hi_ctrl_write       <= 0;
            MEM_lo_ctrl_write       <= 0;
            MEM_is_branch           <= 0;
            MEM_badvaddr            <= 0;
            MEM_exception_info      <= 0;
            MEM_cp0_write_en        <= 0;
            MEM_cp0_write_reg       <= 0;
            MEM_ctrl_write          <= 0;
            MEM_ctrl_reg_write      <= 0;
            MEM_data_sram_sel_hword <= 0;
            MEM_data_sram_sel_word  <= 0;
            MEM_unhit               <= 0;
            MEM_cache_op            <= 0;
            MEM_cache_paddr         <= 0;
            MEM_mult_pro            <= 0;
        end
        else if(MEM_wr) begin
            MEM_inst_refetch        <= MEM0_inst_refetch        ;
            MEM_inst_table          <= MEM0_inst_table          ; 
            MEM_pc                  <= MEM0_pc                  ;
            MEM_rf_data             <= MEM0_rf_data             ;
            MEM_alu_result          <= MEM0_alu_result          ;
            MEM_write_reg           <= MEM0_write_reg           ;
            MEM_hi_ctrl_write       <= MEM0_hi_ctrl_write       ;
            MEM_lo_ctrl_write       <= MEM0_lo_ctrl_write       ;
            MEM_is_branch           <= MEM0_is_branch           ;
            MEM_badvaddr            <= MEM0_badvaddr            ;
            MEM_exception_info      <= MEM0_exception_info      ;
            MEM_cp0_write_en        <= MEM0_cp0_write_en        ;
            MEM_cp0_write_reg       <= MEM0_cp0_write_reg       ;
            MEM_ctrl_write          <= MEM0_ctrl_write          ;
            MEM_ctrl_reg_write      <= MEM0_ctrl_reg_write      ;
            MEM_data_sram_sel_hword <= MEM0_data_sram_sel_hword ;
            MEM_data_sram_sel_word  <= MEM0_data_sram_sel_word  ;
            MEM_unhit               <= MEM0_unhit               ;
            MEM_cache_op            <= MEM0_cache_op            ;
            MEM_cache_paddr         <= MEM0_cache_paddr         ;
            MEM_mult_pro            <= MEM0_mult_pro[63:0]      ;
        end
    end

endmodule