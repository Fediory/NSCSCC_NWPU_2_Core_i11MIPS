//block size
`define WIDTH       8
`define INDEX_WD    `WIDTH-1:0
`define BLOCK_WD    2 ** `WIDTH

//tag and index
`define PC_TAG      31:`WIDTH+2
`define TAG_SIZE    30-`WIDTH
`define TAG_WD      `TAG_SIZE-1 : 0
`define PC_INDEX    `WIDTH+1:2

//type
`define WEAKLY_NT   2'b00
`define WEAKLY_T    2'b10
`define STRONGLY_T  2'b11
`define STRONGLY_NT 2'b01
`define TYPE_INIT   2'b00
`define TYPE_SIZE   2
`define TYPE_WD     `TYPE_SIZE-1 : 0

//branch
`define BRANCH_SIZE 32
`define BRANCH_WD   `BRANCH_SIZE-1 : 0

//xpm wr and rd width
`define DATA_WD     `BRANCH_SIZE + `TAG_SIZE + `TYPE_SIZE + 1
`define WR_WD       `DATA_WD-1 : 0

//RAS
`define RAS_SIZE    8
`define TOP_SUB1    `RAS_SIZE-1
`define RAS_WD      `RAS_SIZE-1 : 0
`define RAS_POINT   $clog2(`RAS_SIZE)-1:0
`define RAS_BRANCH  32:0
