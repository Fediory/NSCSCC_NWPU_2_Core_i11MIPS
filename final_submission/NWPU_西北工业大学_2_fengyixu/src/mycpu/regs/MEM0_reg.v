`include "reg_defines.v"
module MEM0_reg(
    input clk,
    input reset,
    input flush,

    input MEM0_wr,
    //input reg signals
    input                       EXE_inst_refetch        ,
    input [`INST_TABLE_WD-1:0]  EXE_inst_table          , 
    input [31:0]                EXE_pc                  ,
    input [31:0]                EXE_rf_data             ,
    input [31:0]                EXE_alu_result          ,
    input [4:0]                 EXE_write_reg           ,
    input                       EXE_hi_ctrl_write       ,
    input                       EXE_lo_ctrl_write       ,
    input                       EXE_is_eret             ,
    input                       EXE_is_branch           ,
    input [31:0]                EXE_badvaddr            ,
    input [`EX_INFO-1:0]        EXE_exception_info      ,
    input                       EXE_cp0_write_en        ,
    input [7:0]                 EXE_cp0_write_reg       ,
    input                       EXE_ctrl_write          ,
    input                       EXE_ctrl_reg_write      ,
    input                       EXE_unhit               ,
    input [4:0]                 EXE_cache_op            ,
    input [65:0]                EXE_mult_pro            ,
    input [31:0]                EXE_paddr               ,
    //output reg signals
    output reg                       MEM0_inst_refetch  ,
    output reg [`INST_TABLE_WD-1:0]  MEM0_inst_table    ,
    output reg [31:0]                MEM0_pc            ,
    output reg [31:0]                MEM0_rf_data       ,
    output reg [31:0]                MEM0_alu_result    ,
    output reg [4:0]                 MEM0_write_reg     ,
    output reg                       MEM0_hi_ctrl_write ,
    output reg                       MEM0_lo_ctrl_write ,
    output reg                       MEM0_is_eret       ,
    output reg                       MEM0_is_branch     ,
    output reg [31:0]                MEM0_badvaddr      ,
    output reg [`EX_INFO-1:0]        MEM0_exception_info,
    output reg                       MEM0_cp0_write_en  ,
    output reg [7:0]                 MEM0_cp0_write_reg ,
    output reg                       MEM0_ctrl_write    ,
    output reg                       MEM0_ctrl_reg_write,
    output reg                       MEM0_unhit         ,
    output reg [4:0]                 MEM0_cache_op      ,
    output reg [65:0]                MEM0_mult_pro      ,
    output reg [31:0]                MEM0_paddr         
);
    always@(posedge clk)begin
        if(reset | flush)begin
            MEM0_inst_refetch   <= 0;
            MEM0_inst_table     <= 0;
            MEM0_pc             <= 0;
            MEM0_rf_data        <= 0;
            MEM0_alu_result     <= 0;
            MEM0_write_reg      <= 0;
            MEM0_hi_ctrl_write  <= 0;
            MEM0_lo_ctrl_write  <= 0;
            MEM0_is_eret        <= 0;
            MEM0_is_branch      <= 0;
            MEM0_badvaddr       <= 0;
            MEM0_exception_info <= 0;
            MEM0_cp0_write_en   <= 0;
            MEM0_cp0_write_reg  <= 0;
            MEM0_ctrl_write     <= 0;
            MEM0_ctrl_reg_write <= 0;
            MEM0_unhit          <= 0;
            MEM0_cache_op       <= 0;
            MEM0_mult_pro       <= 0;
            MEM0_paddr          <= 0;
        end
        else if(MEM0_wr) begin
            MEM0_inst_refetch   <= EXE_inst_refetch  ;
            MEM0_inst_table     <= EXE_inst_table    ;
            MEM0_pc             <= EXE_pc            ;
            MEM0_rf_data        <= EXE_rf_data       ;
            MEM0_alu_result     <= EXE_alu_result    ;
            MEM0_write_reg      <= EXE_write_reg     ;
            MEM0_hi_ctrl_write  <= EXE_hi_ctrl_write ;
            MEM0_lo_ctrl_write  <= EXE_lo_ctrl_write ;
            MEM0_is_eret        <= EXE_is_eret       ;
            MEM0_is_branch      <= EXE_is_branch     ;
            MEM0_badvaddr       <= EXE_badvaddr      ;
            MEM0_exception_info <= EXE_exception_info;
            MEM0_cp0_write_en   <= EXE_cp0_write_en  ;
            MEM0_cp0_write_reg  <= EXE_cp0_write_reg ;
            MEM0_ctrl_write     <= EXE_ctrl_write    ;
            MEM0_ctrl_reg_write <= EXE_ctrl_reg_write;
            MEM0_unhit          <= EXE_unhit         ;
            MEM0_cache_op       <= EXE_cache_op      ;
            MEM0_mult_pro       <= EXE_mult_pro      ;
            MEM0_paddr          <= EXE_paddr         ;
            end
    end

endmodule