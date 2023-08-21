// 定义常量
`define  PC_INC 32'h4 // PC增量

// 定义宽度
`define PRE_IF_TO_IF_WD 106
`define IF_TO_ID_WD  139
`define ID_TO_PRE_IF_BUS_WD  129
`define ID_TO_EXE_WD 226
`define EXE_TO_MEM0_WD 180
`define MEM0_TO_MEM_WD 181
`define MEM_TO_WB_WD 166
`define WR_TO_ID_WD  42
`define MULTI_EXE_TO_MEM0_WD 1714
`define MULTI_MEM0_TO_MEM_WD 658

`define READ_REGISTER 10

`define EXE_FORWARD_WD 40
`define MEM0_FORWARD_WD 39
`define MEM_FORWARD_WD 77
`define WR_FORWARD_WD 36
`define DIV_EXE_TO_MEM0_WD 64
`define DIV_MEM0_TO_MEM_WD 64

//定义异常宽度
`define PRE_IF_EX_INFO 5
`define IF_EX_INFO     5
`define ID_EX_INFO     18
`define EXE_EX_INFO    18
`define MEM0_EX_INFO   18
`define MEM_EX_INFO    18
`define WR_EX_INFO     18
`define EX_CLASS       17
`define WR_to_cp0_bus 126

//定义指令数量
`define NUM_INST 57
//定义TLB
`define TLBNUM 8
`define VPN2_WD 18:0
`define ASID_WD 7:0
`define PFN_WD 19:0
`define C_WD 2:0
`define TLB_WT $clog2(`TLBNUM)
`define MATCH_WD $clog2(`TLBNUM)-1:0
`define TLB_WD  $clog2(`TLBNUM)-1:0
`define TLB_SIZE `TLBNUM-1:0
`define MATCH_EN_WD `TLBNUM-1:0
`define MASK_SIZE     15:0

//定义PC值
`define PC_START 32'hBFBF_FFFC

//table
`define INST_TABLE_WD   52
`define ERET            0
`define LB              1
`define LW              2
`define LBU             3
`define LH              4
`define LHU             5
`define SH              6
`define SW              7
`define SB              8
`define DIV             9
`define DIVU            10
`define MULT            11
`define MULTU           12
`define MFHI            13
`define MFLO            14
`define MFC0            15
`define MUL             16
`define MADD            17
`define MADDU           18
`define MSUB            19
`define MSUBU           20
`define TLBP            21
`define TLBR            22
`define TLBWI           23
`define TGE             24
`define TGEI            25
`define TGEU            26
`define TGEIU           27
`define TLT             28
`define TLTI            29
`define TLTU            30
`define TLTIU           31  
`define TEQ             32
`define TEQI            33
`define TNE             34
`define TNEI            35
`define CLO             36
`define CLZ             37
`define MOVN            38
`define MOVZ            39
`define LWL             40
`define LWR             41
`define SWL             42
`define SWR             43
`define LL              44
`define SC              45
`define CACHE           46
`define WAIT            47
`define TLBWR           48
`define JAL             49
`define J               50
`define RET             51
`define EX_INFO         18

`define EX_INFO         18


// `define VERILATOR       1
