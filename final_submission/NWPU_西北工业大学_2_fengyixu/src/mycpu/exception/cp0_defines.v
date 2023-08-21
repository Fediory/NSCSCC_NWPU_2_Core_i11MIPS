`define PRE_IF_EX_INFO 5
`define IF_EX_INFO     5
`define ID_EX_INFO     18
`define EXE_EX_INFO    18
`define MEM0_EX_INFO   18
`define MEM_EX_INFO    18
`define WR_EX_INFO     18
`define EX_CLASS       17
`define WR_to_cp0_bus 126

//异常入口地址
`define ADDR_REFILL          32'h8000_0000
`define ADDR_REFILL_EXL      32'h8000_0180
`define ADDR_REFILL_BEV      32'hbfc0_0200
`define ADDR_REFILL_BEV_EXL  32'hbfc0_0380
`define ADDR_INTR            32'h8000_0180
`define ADDR_INTR_IV         32'h8000_0200
`define ADDR_INTR_BEV        32'hbfc0_0380
`define ADDR_INTR_BEV_IV     32'hbfc0_0400
`define ADDR_OTHER           32'h8000_0180
`define ADDR_OTHER_BEV       32'hbfc0_0380