`include "reg_defines.v"
module WR_reg(
    input clk,
    input reset,
    input flush,
    input WR_wr,

    //input reg signals
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
    input                           MEM_unhit              ,
    input [4:0]                     MEM_cache_op           ,
    input                           MEM_crefetch           ,
    input [31:0]                    MEM_cache_paddr              ,

    //output reg signals
    output reg                      WR_inst_refetch        ,
    output reg [`INST_TABLE_WD-1:0] WR_inst_table          , 
    output reg [31:0]               WR_pc                  ,
    output reg [31:0]               WR_rf_data             ,
    output reg [31:0]               WR_alu_result          ,
    output reg [31:0]               WR_busW_inner          ,
    output reg [31:0]               WR_badvaddr            ,
    output reg                      WR_cp0_write_en        ,
    output reg [7:0]                WR_cp0_write_reg       ,
    output reg [`EX_INFO-1:0]       WR_exception_info      ,
    output reg                      WR_is_branch           ,
    output reg [4:0]                WR_write_reg           ,
    output reg [3:0]                WR_reg_write_en        ,
    output reg                      WR_unhit               ,
    output reg [4:0]                WR_cache_op            ,
    output reg                      WR_crefetch            ,
    output reg [31:0]               WR_cache_paddr          
);
    always@(posedge clk)begin
        if(reset | flush)begin
            WR_inst_refetch        <= 0;
            WR_inst_table          <= 0;
            WR_pc                  <= 0;
            WR_rf_data             <= 0;
            WR_alu_result          <= 0;
            WR_busW_inner          <= 0;
            WR_badvaddr            <= 0;
            WR_cp0_write_en        <= 0;
            WR_cp0_write_reg       <= 0;
            WR_exception_info      <= 0;
            WR_is_branch           <= 0;
            WR_write_reg           <= 0;
            WR_reg_write_en        <= 0;
            WR_unhit               <= 0;
            WR_cache_op            <= 0;
            WR_crefetch            <= 0;
            WR_cache_paddr         <= 0;
        end
        else if(WR_wr) begin
            WR_inst_refetch        <= MEM_inst_refetch        ;
            WR_inst_table          <= MEM_inst_table          ;
            WR_pc                  <= MEM_pc                  ;
            WR_rf_data             <= MEM_rf_data             ;
            WR_alu_result          <= MEM_alu_result          ;
            WR_busW_inner          <= MEM_busW_inner          ;
            WR_badvaddr            <= MEM_badvaddr            ;
            WR_cp0_write_en        <= MEM_cp0_write_en        ;
            WR_cp0_write_reg       <= MEM_cp0_write_reg       ;
            WR_exception_info      <= MEM_exception_info      ;
            WR_is_branch           <= MEM_is_branch           ;
            WR_write_reg           <= MEM_write_reg           ;
            WR_reg_write_en        <= MEM_reg_write_en        ;
            WR_unhit               <= MEM_unhit               ;
            WR_cache_op            <= MEM_cache_op            ;
            WR_crefetch            <= MEM_crefetch            ;           
            WR_cache_paddr         <= MEM_cache_paddr         ;
         end
    end

endmodule