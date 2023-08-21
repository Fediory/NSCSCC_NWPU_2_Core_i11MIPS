module MaxPeriodFibonacciLFSR(
  input   clock,
  input   reset,
  output  io_out_0,
  output  io_out_1,
  output  io_out_2,
  output  io_out_3,
  output  io_out_4,
  output  io_out_5,
  output  io_out_6,
  output  io_out_7,
  output  io_out_8,
  output  io_out_9,
  output  io_out_10,
  output  io_out_11,
  output  io_out_12,
  output  io_out_13,
  output  io_out_14,
  output  io_out_15
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
`endif // RANDOMIZE_REG_INIT
  reg  state_0; // @[PRNG.scala 55:49]
  reg  state_1; // @[PRNG.scala 55:49]
  reg  state_2; // @[PRNG.scala 55:49]
  reg  state_3; // @[PRNG.scala 55:49]
  reg  state_4; // @[PRNG.scala 55:49]
  reg  state_5; // @[PRNG.scala 55:49]
  reg  state_6; // @[PRNG.scala 55:49]
  reg  state_7; // @[PRNG.scala 55:49]
  reg  state_8; // @[PRNG.scala 55:49]
  reg  state_9; // @[PRNG.scala 55:49]
  reg  state_10; // @[PRNG.scala 55:49]
  reg  state_11; // @[PRNG.scala 55:49]
  reg  state_12; // @[PRNG.scala 55:49]
  reg  state_13; // @[PRNG.scala 55:49]
  reg  state_14; // @[PRNG.scala 55:49]
  reg  state_15; // @[PRNG.scala 55:49]
  wire  _T_2 = state_15 ^ state_13 ^ state_12 ^ state_10; // @[LFSR.scala 15:41]
  assign io_out_0 = state_0; // @[PRNG.scala 78:10]
  assign io_out_1 = state_1; // @[PRNG.scala 78:10]
  assign io_out_2 = state_2; // @[PRNG.scala 78:10]
  assign io_out_3 = state_3; // @[PRNG.scala 78:10]
  assign io_out_4 = state_4; // @[PRNG.scala 78:10]
  assign io_out_5 = state_5; // @[PRNG.scala 78:10]
  assign io_out_6 = state_6; // @[PRNG.scala 78:10]
  assign io_out_7 = state_7; // @[PRNG.scala 78:10]
  assign io_out_8 = state_8; // @[PRNG.scala 78:10]
  assign io_out_9 = state_9; // @[PRNG.scala 78:10]
  assign io_out_10 = state_10; // @[PRNG.scala 78:10]
  assign io_out_11 = state_11; // @[PRNG.scala 78:10]
  assign io_out_12 = state_12; // @[PRNG.scala 78:10]
  assign io_out_13 = state_13; // @[PRNG.scala 78:10]
  assign io_out_14 = state_14; // @[PRNG.scala 78:10]
  assign io_out_15 = state_15; // @[PRNG.scala 78:10]
  always @(posedge clock) begin
    state_0 <= reset | _T_2; // @[PRNG.scala 55:{49,49}]
    if (reset) begin // @[PRNG.scala 55:49]
      state_1 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_1 <= state_0;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_2 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_2 <= state_1;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_3 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_3 <= state_2;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_4 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_4 <= state_3;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_5 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_5 <= state_4;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_6 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_6 <= state_5;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_7 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_7 <= state_6;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_8 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_8 <= state_7;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_9 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_9 <= state_8;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_10 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_10 <= state_9;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_11 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_11 <= state_10;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_12 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_12 <= state_11;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_13 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_13 <= state_12;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_14 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_14 <= state_13;
    end
    if (reset) begin // @[PRNG.scala 55:49]
      state_15 <= 1'h0; // @[PRNG.scala 55:49]
    end else begin
      state_15 <= state_14;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  state_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  state_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  state_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  state_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  state_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  state_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  state_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  state_8 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  state_9 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  state_10 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  state_11 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  state_12 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  state_13 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  state_14 = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  state_15 = _RAND_15[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module icache(
  input         clock,
  input         reset,
  input         valid,
  input         op,
  input  [7:0]  index,
  input  [19:0] tag,
  input  [3:0]  offset,
  output        addr_ok,
  output        data_ok,
  output [31:0] rdata,
  input         uncached,
  output        rd_req,
  output [2:0]  rd_type,
  output [31:0] rd_addr,
  input         rd_rdy,
  input         ret_valid,
  input         ret_last,
  input  [31:0] ret_data,
  input         cache_op_en,
  input  [2:0]  cache_op,
  input  [19:0] cache_tag,
  input  [7:0]  cache_index,
  input  [3:0]  cache_offset,
  input  [20:0] tag_input,
  output [20:0] tag_output,
  output        cache_op_done,
  output        hit
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
`endif // RANDOMIZE_REG_INIT
  wire [7:0] tagv_ram_addra; // @[icache.scala 68:49]
  wire  tagv_ram_clka; // @[icache.scala 68:49]
  wire [20:0] tagv_ram_dina; // @[icache.scala 68:49]
  wire [20:0] tagv_ram_douta; // @[icache.scala 68:49]
  wire  tagv_ram_wea; // @[icache.scala 68:49]
  wire [7:0] tagv_ram_1_addra; // @[icache.scala 68:49]
  wire  tagv_ram_1_clka; // @[icache.scala 68:49]
  wire [20:0] tagv_ram_1_dina; // @[icache.scala 68:49]
  wire [20:0] tagv_ram_1_douta; // @[icache.scala 68:49]
  wire  tagv_ram_1_wea; // @[icache.scala 68:49]
  wire [7:0] data_ram_addra; // @[icache.scala 69:65]
  wire  data_ram_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_1_addra; // @[icache.scala 69:65]
  wire  data_ram_1_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_1_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_1_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_1_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_2_addra; // @[icache.scala 69:65]
  wire  data_ram_2_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_2_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_2_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_2_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_3_addra; // @[icache.scala 69:65]
  wire  data_ram_3_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_3_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_3_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_3_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_4_addra; // @[icache.scala 69:65]
  wire  data_ram_4_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_4_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_4_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_4_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_5_addra; // @[icache.scala 69:65]
  wire  data_ram_5_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_5_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_5_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_5_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_6_addra; // @[icache.scala 69:65]
  wire  data_ram_6_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_6_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_6_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_6_wea; // @[icache.scala 69:65]
  wire [7:0] data_ram_7_addra; // @[icache.scala 69:65]
  wire  data_ram_7_clka; // @[icache.scala 69:65]
  wire [31:0] data_ram_7_dina; // @[icache.scala 69:65]
  wire [31:0] data_ram_7_douta; // @[icache.scala 69:65]
  wire [3:0] data_ram_7_wea; // @[icache.scala 69:65]
  wire  LFSR_result_prng_clock; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_reset; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_0; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_1; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_2; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_3; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_4; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_5; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_6; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_7; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_8; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_9; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_10; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_11; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_12; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_13; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_14; // @[PRNG.scala 91:22]
  wire  LFSR_result_prng_io_out_15; // @[PRNG.scala 91:22]
  wire  _cacheOperation_T_1 = 3'h0 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_3 = 3'h1 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_5 = 3'h2 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_7 = 3'h3 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_9 = 3'h4 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_11 = 3'h5 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_13 = 3'h6 == cache_op; // @[Lookup.scala 31:38]
  wire  _cacheOperation_T_20 = _cacheOperation_T_7 ? 1'h0 : _cacheOperation_T_9 | _cacheOperation_T_11; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_21 = _cacheOperation_T_5 ? 1'h0 : _cacheOperation_T_20; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_22 = _cacheOperation_T_3 ? 1'h0 : _cacheOperation_T_21; // @[Lookup.scala 34:39]
  wire  cacheOperation_0 = _cacheOperation_T_1 | _cacheOperation_T_22; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_36 = _cacheOperation_T_3 ? 1'h0 : _cacheOperation_T_5; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_40 = _cacheOperation_T_9 ? 1'h0 : _cacheOperation_T_11 | _cacheOperation_T_13; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_41 = _cacheOperation_T_7 ? 1'h0 : _cacheOperation_T_40; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_42 = _cacheOperation_T_5 ? 1'h0 : _cacheOperation_T_41; // @[Lookup.scala 34:39]
  wire  _cacheOperation_T_43 = _cacheOperation_T_3 ? 1'h0 : _cacheOperation_T_42; // @[Lookup.scala 34:39]
  wire  cacheOperation_3 = _cacheOperation_T_1 | _cacheOperation_T_43; // @[Lookup.scala 34:39]
  wire  cacheOperation_4 = _cacheOperation_T_1 | (_cacheOperation_T_3 | _cacheOperation_T_5); // @[Lookup.scala 34:39]
  reg  cacheInst_r; // @[icache.scala 46:38]
  reg  invalidate; // @[icache.scala 47:38]
  reg  loadTag; // @[icache.scala 48:38]
  reg  storeTag; // @[icache.scala 49:38]
  reg  writeBack; // @[icache.scala 50:38]
  reg  indexOnly; // @[icache.scala 51:38]
  wire  _fill_T = ~indexOnly; // @[icache.scala 54:24]
  wire  fill = ~indexOnly & invalidate & writeBack; // @[icache.scala 54:48]
  reg  req_op; // @[icache.scala 73:34]
  reg  req_uncached; // @[icache.scala 74:34]
  reg [3:0] req_offset; // @[icache.scala 75:34]
  reg [7:0] req_set; // @[icache.scala 76:34]
  reg [19:0] req_tag; // @[icache.scala 77:34]
  reg [2:0] state; // @[icache.scala 109:34]
  reg  refillIDX_r; // @[icache.scala 113:34]
  wire [7:0] LFSR_result_lo = {LFSR_result_prng_io_out_7,LFSR_result_prng_io_out_6,LFSR_result_prng_io_out_5,
    LFSR_result_prng_io_out_4,LFSR_result_prng_io_out_3,LFSR_result_prng_io_out_2,LFSR_result_prng_io_out_1,
    LFSR_result_prng_io_out_0}; // @[PRNG.scala 95:17]
  wire [7:0] LFSR_result_hi = {LFSR_result_prng_io_out_15,LFSR_result_prng_io_out_14,LFSR_result_prng_io_out_13,
    LFSR_result_prng_io_out_12,LFSR_result_prng_io_out_11,LFSR_result_prng_io_out_10,LFSR_result_prng_io_out_9,
    LFSR_result_prng_io_out_8}; // @[PRNG.scala 95:17]
  reg [15:0] LFSR_result; // @[icache.scala 116:34]
  reg [1:0] wr_cnt; // @[icache.scala 117:34]
  wire [2:0] _state_T = uncached ? 3'h2 : 3'h1; // @[icache.scala 143:29]
  wire  _GEN_2 = valid ? op : req_op; // @[icache.scala 142:30 145:24 73:34]
  wire [19:0] _GEN_4 = valid ? tag : req_tag; // @[icache.scala 142:30 147:25 77:34]
  wire [7:0] _GEN_5 = valid ? index : req_set; // @[icache.scala 142:30 148:25 76:34]
  wire [3:0] _GEN_6 = valid ? offset : req_offset; // @[icache.scala 142:30 149:28 75:34]
  wire  _GEN_7 = valid ? uncached : req_uncached; // @[icache.scala 142:30 150:30 74:34]
  wire [7:0] _GEN_11 = cache_op_en ? cache_index : _GEN_5; // @[icache.scala 124:30 128:33]
  wire  _GEN_18 = cache_op_en ? 1'h0 : valid; // @[icache.scala 124:30 99:25]
  wire [20:0] tagv_0_douta = tagv_ram_douta; // @[icache.scala 68:{42,42}]
  wire  _T_5 = tagv_0_douta[19:0] == req_tag & tagv_0_douta[20]; // @[icache.scala 161:57]
  wire  _hit_T = ~req_uncached; // @[icache.scala 162:36]
  wire [31:0] data_0_0_douta = data_ram_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] data_0_1_douta = data_ram_1_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] _GEN_23 = 2'h1 == req_offset[3:2] ? data_0_1_douta : data_0_0_douta; // @[icache.scala 163:{33,33}]
  wire [31:0] data_0_2_douta = data_ram_2_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] _GEN_24 = 2'h2 == req_offset[3:2] ? data_0_2_douta : _GEN_23; // @[icache.scala 163:{33,33}]
  wire [31:0] data_0_3_douta = data_ram_3_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] _GEN_25 = 2'h3 == req_offset[3:2] ? data_0_3_douta : _GEN_24; // @[icache.scala 163:{33,33}]
  wire  _GEN_27 = _fill_T ? 1'h0 : refillIDX_r; // @[icache.scala 113:34 169:37 170:37]
  wire  _data_ok_T = ~cacheInst_r; // @[icache.scala 172:36]
  wire  _GEN_28 = tagv_0_douta[19:0] == req_tag & tagv_0_douta[20] & ~req_uncached; // @[icache.scala 161:78 162:33 97:25]
  wire [31:0] _GEN_29 = tagv_0_douta[19:0] == req_tag & tagv_0_douta[20] ? _GEN_25 : 32'h7777; // @[icache.scala 161:78 163:33 98:25]
  wire  _GEN_31 = tagv_0_douta[19:0] == req_tag & tagv_0_douta[20] ? _GEN_27 : refillIDX_r; // @[icache.scala 113:34 161:78]
  wire  _GEN_32 = tagv_0_douta[19:0] == req_tag & tagv_0_douta[20] & ~cacheInst_r; // @[icache.scala 100:25 161:78 172:33]
  wire [20:0] tagv_1_douta = tagv_ram_1_douta; // @[icache.scala 68:{42,42}]
  wire  _T_11 = tagv_1_douta[19:0] == req_tag & tagv_1_douta[20]; // @[icache.scala 161:57]
  wire [31:0] data_1_0_douta = data_ram_4_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] data_1_1_douta = data_ram_5_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] _GEN_34 = 2'h1 == req_offset[3:2] ? data_1_1_douta : data_1_0_douta; // @[icache.scala 163:{33,33}]
  wire [31:0] data_1_2_douta = data_ram_6_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] _GEN_35 = 2'h2 == req_offset[3:2] ? data_1_2_douta : _GEN_34; // @[icache.scala 163:{33,33}]
  wire [31:0] data_1_3_douta = data_ram_7_douta; // @[icache.scala 69:{58,58}]
  wire [31:0] _GEN_36 = 2'h3 == req_offset[3:2] ? data_1_3_douta : _GEN_35; // @[icache.scala 163:{33,33}]
  wire  _GEN_38 = _fill_T | _GEN_31; // @[icache.scala 169:37 170:37]
  wire  _GEN_39 = tagv_1_douta[19:0] == req_tag & tagv_1_douta[20] ? ~req_uncached : _GEN_28; // @[icache.scala 161:78 162:33]
  wire [31:0] _GEN_40 = tagv_1_douta[19:0] == req_tag & tagv_1_douta[20] ? _GEN_36 : _GEN_29; // @[icache.scala 161:78 163:33]
  wire  _GEN_43 = tagv_1_douta[19:0] == req_tag & tagv_1_douta[20] ? ~cacheInst_r : _GEN_32; // @[icache.scala 161:78 172:33]
  wire [2:0] _state_T_1 = storeTag ? 3'h4 : 3'h0; // @[Mux.scala 101:16]
  wire [2:0] _state_T_2 = loadTag ? 3'h4 : _state_T_1; // @[Mux.scala 101:16]
  wire [2:0] _state_T_3 = invalidate ? 3'h4 : _state_T_2; // @[Mux.scala 101:16]
  wire [2:0] _state_T_4 = invalidate ? 3'h4 : 3'h0; // @[Mux.scala 101:16]
  wire [2:0] _GEN_44 = hit ? _state_T_4 : 3'h0; // @[icache.scala 186:31 187:33 199:37]
  wire  _GEN_45 = hit ? 1'h0 : 1'h1; // @[icache.scala 186:31 55:21 192:37]
  wire  _GEN_46 = hit & cacheInst_r; // @[icache.scala 186:31 193:37 46:38]
  wire  _GEN_47 = hit & invalidate; // @[icache.scala 186:31 194:37 47:38]
  wire  _GEN_48 = hit & indexOnly; // @[icache.scala 186:31 195:37 51:38]
  wire  _GEN_49 = hit & writeBack; // @[icache.scala 186:31 196:37 50:38]
  wire  _GEN_50 = hit & storeTag; // @[icache.scala 186:31 197:37 49:38]
  wire  _GEN_51 = hit & loadTag; // @[icache.scala 186:31 198:37 48:38]
  wire [2:0] _GEN_52 = fill ? 3'h2 : _GEN_44; // @[icache.scala 183:33 184:33]
  wire  _GEN_53 = fill ? 1'h0 : _GEN_45; // @[icache.scala 183:33 55:21]
  wire  _GEN_54 = fill ? cacheInst_r : _GEN_46; // @[icache.scala 183:33 46:38]
  wire  _GEN_55 = fill ? invalidate : _GEN_47; // @[icache.scala 183:33 47:38]
  wire  _GEN_56 = fill ? indexOnly : _GEN_48; // @[icache.scala 183:33 51:38]
  wire  _GEN_57 = fill ? writeBack : _GEN_49; // @[icache.scala 183:33 50:38]
  wire  _GEN_58 = fill ? storeTag : _GEN_50; // @[icache.scala 183:33 49:38]
  wire  _GEN_59 = fill ? loadTag : _GEN_51; // @[icache.scala 183:33 48:38]
  wire [2:0] _GEN_60 = indexOnly ? _state_T_3 : _GEN_52; // @[icache.scala 177:32 178:33]
  wire  _GEN_61 = indexOnly ? 1'h0 : _GEN_53; // @[icache.scala 177:32 55:21]
  wire  _GEN_62 = indexOnly ? cacheInst_r : _GEN_54; // @[icache.scala 177:32 46:38]
  wire  _GEN_63 = indexOnly ? invalidate : _GEN_55; // @[icache.scala 177:32 47:38]
  wire  _GEN_64 = indexOnly ? indexOnly : _GEN_56; // @[icache.scala 177:32 51:38]
  wire  _GEN_65 = indexOnly ? writeBack : _GEN_57; // @[icache.scala 177:32 50:38]
  wire  _GEN_66 = indexOnly ? storeTag : _GEN_58; // @[icache.scala 177:32 49:38]
  wire  _GEN_67 = indexOnly ? loadTag : _GEN_59; // @[icache.scala 177:32 48:38]
  wire [2:0] _GEN_68 = valid ? _state_T : 3'h0; // @[icache.scala 206:13 207:33 223:23]
  wire [2:0] _GEN_70 = ~hit ? 3'h2 : _GEN_68; // @[icache.scala 202:28 203:33]
  wire  _GEN_71 = ~hit ? 1'h0 : valid; // @[icache.scala 202:28 99:25]
  wire  _GEN_73 = ~hit ? req_uncached : _GEN_7; // @[icache.scala 202:28 74:34]
  wire  _GEN_74 = ~hit ? req_op : _GEN_2; // @[icache.scala 202:28 73:34]
  wire [19:0] _GEN_75 = ~hit ? req_tag : _GEN_4; // @[icache.scala 202:28 77:34]
  wire [7:0] _GEN_76 = ~hit ? req_set : _GEN_5; // @[icache.scala 202:28 76:34]
  wire [3:0] _GEN_77 = ~hit ? req_offset : _GEN_6; // @[icache.scala 202:28 75:34]
  wire  _GEN_79 = cacheInst_r & _GEN_61; // @[icache.scala 176:30 55:21]
  wire  _GEN_86 = cacheInst_r ? 1'h0 : _GEN_71; // @[icache.scala 176:30 99:25]
  wire [7:0] _GEN_91 = cacheInst_r ? req_set : _GEN_76; // @[icache.scala 176:30 76:34]
  wire  _T_19 = ~tagv_1_douta[20]; // @[icache.scala 229:22]
  wire  _GEN_95 = ~tagv_1_douta[20] | ~tagv_0_douta[20]; // @[icache.scala 229:41 230:41]
  wire  _GEN_98 = _T_5 ? 1'h0 : _T_19; // @[icache.scala 235:76 237:41]
  wire  _GEN_99 = _T_11 | (_T_5 | _GEN_95); // @[icache.scala 235:76 236:41]
  wire  _GEN_100 = _T_11 | _GEN_98; // @[icache.scala 235:76 237:41]
  wire  _GEN_348 = 3'h1 == state ? 1'h0 : 3'h2 == state & _GEN_99; // @[icache.scala 122:18 119:25]
  wire  refillHit = 3'h0 == state ? 1'h0 : _GEN_348; // @[icache.scala 122:18 119:25]
  wire  _GEN_101 = ~refillHit ? LFSR_result[0] : _GEN_100; // @[icache.scala 240:29 241:41]
  wire  _rd_req_T_2 = req_op & req_uncached | fill ? 1'h0 : 1'h1; // @[icache.scala 248:35]
  wire [2:0] _rd_type_T = req_uncached ? 3'h2 : 3'h4; // @[icache.scala 249:35]
  wire [31:0] _rd_addr_T = {req_tag,req_set,req_offset}; // @[Cat.scala 33:92]
  wire [31:0] _rd_addr_T_1 = {req_tag,req_set,4'h0}; // @[Cat.scala 33:92]
  wire [31:0] _rd_addr_T_2 = req_uncached ? _rd_addr_T : _rd_addr_T_1; // @[icache.scala 250:35]
  wire [2:0] _GEN_102 = rd_rdy ? 3'h4 : 3'h3; // @[icache.scala 251:25 247:29 252:29]
  wire  _T_34 = _hit_T & _data_ok_T | fill; // @[icache.scala 257:49]
  wire [1:0] _wr_cnt_T_1 = wr_cnt + 2'h1; // @[icache.scala 261:71]
  wire  _GEN_422 = ~refillIDX_r; // @[icache.scala 262:{61,61} 92:33]
  wire  _GEN_423 = 2'h0 == wr_cnt; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_103 = ~refillIDX_r & 2'h0 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire  _GEN_425 = 2'h1 == wr_cnt; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_104 = ~refillIDX_r & 2'h1 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire  _GEN_427 = 2'h2 == wr_cnt; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_105 = ~refillIDX_r & 2'h2 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire  _GEN_429 = 2'h3 == wr_cnt; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_106 = ~refillIDX_r & 2'h3 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_107 = refillIDX_r & 2'h0 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_108 = refillIDX_r & 2'h1 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_109 = refillIDX_r & 2'h2 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire [31:0] _GEN_110 = refillIDX_r & 2'h3 == wr_cnt ? ret_data : 32'h0; // @[icache.scala 262:{61,61} 92:33]
  wire [3:0] _GEN_111 = _GEN_422 & _GEN_423 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_112 = _GEN_422 & _GEN_425 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_113 = _GEN_422 & _GEN_427 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_114 = _GEN_422 & _GEN_429 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_115 = refillIDX_r & _GEN_423 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_116 = refillIDX_r & _GEN_425 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_117 = refillIDX_r & _GEN_427 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [3:0] _GEN_118 = refillIDX_r & _GEN_429 ? 4'hf : 4'h0; // @[icache.scala 263:{61,61} 93:33]
  wire [20:0] _tagv_dina_T = {1'h1,req_tag}; // @[Cat.scala 33:92]
  wire [20:0] _GEN_121 = ~refillIDX_r ? _tagv_dina_T : 21'h0; // @[icache.scala 269:{61,61} 86:25]
  wire [20:0] _GEN_122 = refillIDX_r ? _tagv_dina_T : 21'h0; // @[icache.scala 269:{61,61} 86:25]
  wire [2:0] _GEN_123 = ret_last ? 3'h1 : 3'h4; // @[icache.scala 265:21 256:41 266:61]
  wire  _GEN_124 = ret_last & _GEN_422; // @[icache.scala 265:21 87:25]
  wire  _GEN_125 = ret_last & refillIDX_r; // @[icache.scala 265:21 87:25]
  wire [20:0] _GEN_126 = ret_last ? _GEN_121 : 21'h0; // @[icache.scala 265:21 86:25]
  wire [20:0] _GEN_127 = ret_last ? _GEN_122 : 21'h0; // @[icache.scala 265:21 86:25]
  wire [1:0] _GEN_128 = ret_valid ? _wr_cnt_T_1 : wr_cnt; // @[icache.scala 260:17 117:34 261:61]
  wire [31:0] _GEN_129 = ret_valid ? _GEN_103 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_130 = ret_valid ? _GEN_104 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_131 = ret_valid ? _GEN_105 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_132 = ret_valid ? _GEN_106 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_133 = ret_valid ? _GEN_107 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_134 = ret_valid ? _GEN_108 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_135 = ret_valid ? _GEN_109 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [31:0] _GEN_136 = ret_valid ? _GEN_110 : 32'h0; // @[icache.scala 260:17 92:33]
  wire [3:0] _GEN_137 = ret_valid ? _GEN_111 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_138 = ret_valid ? _GEN_112 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_139 = ret_valid ? _GEN_113 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_140 = ret_valid ? _GEN_114 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_141 = ret_valid ? _GEN_115 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_142 = ret_valid ? _GEN_116 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_143 = ret_valid ? _GEN_117 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [3:0] _GEN_144 = ret_valid ? _GEN_118 : 4'h0; // @[icache.scala 260:17 93:33]
  wire [2:0] _GEN_145 = ret_valid ? _GEN_123 : 3'h4; // @[icache.scala 260:17 256:41]
  wire  _GEN_146 = ret_valid & _GEN_124; // @[icache.scala 260:17 87:25]
  wire  _GEN_147 = ret_valid & _GEN_125; // @[icache.scala 260:17 87:25]
  wire [20:0] _GEN_148 = ret_valid ? _GEN_126 : 21'h0; // @[icache.scala 260:17 86:25]
  wire [20:0] _GEN_149 = ret_valid ? _GEN_127 : 21'h0; // @[icache.scala 260:17 86:25]
  wire  _T_36 = ret_valid & ret_last; // @[icache.scala 274:32]
  wire [31:0] _GEN_151 = _T_36 ? ret_data : 32'h7777; // @[icache.scala 275:17 277:61 98:25]
  wire [2:0] _GEN_152 = _T_36 ? 3'h0 : 3'h4; // @[icache.scala 275:17 256:41 278:61]
  wire [20:0] _GEN_154 = loadTag ? tagv_0_douta : 21'h0; // @[icache.scala 285:30 286:61 56:21]
  wire [20:0] _GEN_155 = storeTag ? tag_input : 21'h0; // @[icache.scala 288:31 289:61 86:25]
  wire [20:0] _GEN_158 = ~refillIDX_r ? 21'h0 : _GEN_155; // @[icache.scala 301:{71,71}]
  wire [20:0] _GEN_159 = refillIDX_r ? 21'h0 : _GEN_155; // @[icache.scala 301:{71,71}]
  wire  _GEN_160 = _GEN_422 | storeTag; // @[icache.scala 302:{71,71}]
  wire  _GEN_161 = refillIDX_r | storeTag; // @[icache.scala 302:{71,71}]
  wire [20:0] _GEN_162 = indexOnly ? 21'h0 : _GEN_158; // @[icache.scala 295:36 296:61]
  wire  _GEN_163 = indexOnly | _GEN_160; // @[icache.scala 295:36 297:61]
  wire [20:0] _GEN_164 = indexOnly ? 21'h0 : _GEN_159; // @[icache.scala 295:36 298:61]
  wire  _GEN_165 = indexOnly | _GEN_161; // @[icache.scala 295:36 299:61]
  wire [20:0] _GEN_166 = invalidate ? _GEN_162 : _GEN_155; // @[icache.scala 294:33]
  wire  _GEN_167 = invalidate ? _GEN_163 : storeTag; // @[icache.scala 294:33]
  wire [20:0] _GEN_168 = invalidate ? _GEN_164 : _GEN_155; // @[icache.scala 294:33]
  wire  _GEN_169 = invalidate ? _GEN_165 : storeTag; // @[icache.scala 294:33]
  wire  _GEN_170 = _data_ok_T & _T_36; // @[icache.scala 100:25 273:36]
  wire [31:0] _GEN_171 = _data_ok_T ? _GEN_151 : 32'h7777; // @[icache.scala 273:36 98:25]
  wire [2:0] _GEN_172 = _data_ok_T ? _GEN_152 : 3'h0; // @[icache.scala 273:36 283:61]
  wire  _GEN_174 = _data_ok_T ? 1'h0 : 1'h1; // @[icache.scala 273:36 55:21 284:61]
  wire [20:0] _GEN_175 = _data_ok_T ? 21'h0 : _GEN_154; // @[icache.scala 273:36 56:21]
  wire [20:0] _GEN_176 = _data_ok_T ? 21'h0 : _GEN_166; // @[icache.scala 273:36 86:25]
  wire  _GEN_177 = _data_ok_T ? 1'h0 : _GEN_167; // @[icache.scala 273:36 87:25]
  wire [20:0] _GEN_178 = _data_ok_T ? 21'h0 : _GEN_168; // @[icache.scala 273:36 86:25]
  wire  _GEN_179 = _data_ok_T ? 1'h0 : _GEN_169; // @[icache.scala 273:36 87:25]
  wire  _GEN_180 = _data_ok_T & cacheInst_r; // @[icache.scala 273:36 46:38 305:61]
  wire  _GEN_181 = _data_ok_T & invalidate; // @[icache.scala 273:36 47:38 306:61]
  wire  _GEN_182 = _data_ok_T & indexOnly; // @[icache.scala 273:36 51:38 307:61]
  wire  _GEN_183 = _data_ok_T & writeBack; // @[icache.scala 273:36 50:38 308:61]
  wire  _GEN_184 = _data_ok_T & storeTag; // @[icache.scala 273:36 49:38 309:61]
  wire  _GEN_185 = _data_ok_T & loadTag; // @[icache.scala 273:36 48:38 310:61]
  wire [1:0] _GEN_186 = _T_34 ? _GEN_128 : wr_cnt; // @[icache.scala 258:13 117:34]
  wire [31:0] _GEN_187 = _T_34 ? _GEN_129 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_188 = _T_34 ? _GEN_130 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_189 = _T_34 ? _GEN_131 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_190 = _T_34 ? _GEN_132 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_191 = _T_34 ? _GEN_133 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_192 = _T_34 ? _GEN_134 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_193 = _T_34 ? _GEN_135 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [31:0] _GEN_194 = _T_34 ? _GEN_136 : 32'h0; // @[icache.scala 258:13 92:33]
  wire [3:0] _GEN_195 = _T_34 ? _GEN_137 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_196 = _T_34 ? _GEN_138 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_197 = _T_34 ? _GEN_139 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_198 = _T_34 ? _GEN_140 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_199 = _T_34 ? _GEN_141 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_200 = _T_34 ? _GEN_142 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_201 = _T_34 ? _GEN_143 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [3:0] _GEN_202 = _T_34 ? _GEN_144 : 4'h0; // @[icache.scala 258:13 93:33]
  wire [2:0] _GEN_203 = _T_34 ? _GEN_145 : _GEN_172; // @[icache.scala 258:13]
  wire  _GEN_204 = _T_34 ? _GEN_146 : _GEN_177; // @[icache.scala 258:13]
  wire  _GEN_205 = _T_34 ? _GEN_147 : _GEN_179; // @[icache.scala 258:13]
  wire [20:0] _GEN_206 = _T_34 ? _GEN_148 : _GEN_176; // @[icache.scala 258:13]
  wire [20:0] _GEN_207 = _T_34 ? _GEN_149 : _GEN_178; // @[icache.scala 258:13]
  wire  _GEN_208 = _T_34 ? 1'h0 : _GEN_170; // @[icache.scala 258:13 100:25]
  wire [31:0] _GEN_209 = _T_34 ? 32'h7777 : _GEN_171; // @[icache.scala 258:13 98:25]
  wire  _GEN_211 = _T_34 ? 1'h0 : _GEN_174; // @[icache.scala 258:13 55:21]
  wire [20:0] _GEN_212 = _T_34 ? 21'h0 : _GEN_175; // @[icache.scala 258:13 56:21]
  wire  _GEN_213 = _T_34 ? cacheInst_r : _GEN_180; // @[icache.scala 258:13 46:38]
  wire  _GEN_214 = _T_34 ? invalidate : _GEN_181; // @[icache.scala 258:13 47:38]
  wire  _GEN_215 = _T_34 ? indexOnly : _GEN_182; // @[icache.scala 258:13 51:38]
  wire  _GEN_216 = _T_34 ? writeBack : _GEN_183; // @[icache.scala 258:13 50:38]
  wire  _GEN_217 = _T_34 ? storeTag : _GEN_184; // @[icache.scala 258:13 49:38]
  wire  _GEN_218 = _T_34 ? loadTag : _GEN_185; // @[icache.scala 258:13 48:38]
  wire [2:0] _GEN_219 = 3'h4 == state ? _GEN_203 : state; // @[icache.scala 122:18 109:34]
  wire [1:0] _GEN_220 = 3'h4 == state ? _GEN_186 : wr_cnt; // @[icache.scala 122:18 117:34]
  wire [31:0] _GEN_221 = 3'h4 == state ? _GEN_187 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_222 = 3'h4 == state ? _GEN_188 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_223 = 3'h4 == state ? _GEN_189 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_224 = 3'h4 == state ? _GEN_190 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_225 = 3'h4 == state ? _GEN_191 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_226 = 3'h4 == state ? _GEN_192 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_227 = 3'h4 == state ? _GEN_193 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_228 = 3'h4 == state ? _GEN_194 : 32'h0; // @[icache.scala 122:18 92:33]
  wire [3:0] _GEN_229 = 3'h4 == state ? _GEN_195 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_230 = 3'h4 == state ? _GEN_196 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_231 = 3'h4 == state ? _GEN_197 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_232 = 3'h4 == state ? _GEN_198 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_233 = 3'h4 == state ? _GEN_199 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_234 = 3'h4 == state ? _GEN_200 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_235 = 3'h4 == state ? _GEN_201 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_236 = 3'h4 == state ? _GEN_202 : 4'h0; // @[icache.scala 122:18 93:33]
  wire [20:0] _GEN_239 = 3'h4 == state ? _GEN_206 : 21'h0; // @[icache.scala 122:18 86:25]
  wire [20:0] _GEN_240 = 3'h4 == state ? _GEN_207 : 21'h0; // @[icache.scala 122:18 86:25]
  wire [31:0] _GEN_242 = 3'h4 == state ? _GEN_209 : 32'h7777; // @[icache.scala 122:18 98:25]
  wire [20:0] _GEN_245 = 3'h4 == state ? _GEN_212 : 21'h0; // @[icache.scala 122:18 56:21]
  wire  _GEN_246 = 3'h4 == state ? _GEN_213 : cacheInst_r; // @[icache.scala 122:18 46:38]
  wire  _GEN_247 = 3'h4 == state ? _GEN_214 : invalidate; // @[icache.scala 122:18 47:38]
  wire  _GEN_248 = 3'h4 == state ? _GEN_215 : indexOnly; // @[icache.scala 122:18 51:38]
  wire  _GEN_249 = 3'h4 == state ? _GEN_216 : writeBack; // @[icache.scala 122:18 50:38]
  wire  _GEN_250 = 3'h4 == state ? _GEN_217 : storeTag; // @[icache.scala 122:18 49:38]
  wire  _GEN_251 = 3'h4 == state ? _GEN_218 : loadTag; // @[icache.scala 122:18 48:38]
  wire [2:0] _GEN_252 = 3'h3 == state ? _GEN_102 : _GEN_219; // @[icache.scala 122:18]
  wire  _GEN_253 = 3'h3 == state & _rd_req_T_2; // @[icache.scala 122:18 101:25 248:29]
  wire [2:0] _GEN_254 = 3'h3 == state ? _rd_type_T : 3'h0; // @[icache.scala 122:18 102:25 249:29]
  wire [31:0] _GEN_255 = 3'h3 == state ? _rd_addr_T_2 : 32'h0; // @[icache.scala 122:18 103:25 250:29]
  wire [1:0] _GEN_256 = 3'h3 == state ? wr_cnt : _GEN_220; // @[icache.scala 122:18 117:34]
  wire [31:0] _GEN_257 = 3'h3 == state ? 32'h0 : _GEN_221; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_258 = 3'h3 == state ? 32'h0 : _GEN_222; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_259 = 3'h3 == state ? 32'h0 : _GEN_223; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_260 = 3'h3 == state ? 32'h0 : _GEN_224; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_261 = 3'h3 == state ? 32'h0 : _GEN_225; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_262 = 3'h3 == state ? 32'h0 : _GEN_226; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_263 = 3'h3 == state ? 32'h0 : _GEN_227; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_264 = 3'h3 == state ? 32'h0 : _GEN_228; // @[icache.scala 122:18 92:33]
  wire [3:0] _GEN_265 = 3'h3 == state ? 4'h0 : _GEN_229; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_266 = 3'h3 == state ? 4'h0 : _GEN_230; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_267 = 3'h3 == state ? 4'h0 : _GEN_231; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_268 = 3'h3 == state ? 4'h0 : _GEN_232; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_269 = 3'h3 == state ? 4'h0 : _GEN_233; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_270 = 3'h3 == state ? 4'h0 : _GEN_234; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_271 = 3'h3 == state ? 4'h0 : _GEN_235; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_272 = 3'h3 == state ? 4'h0 : _GEN_236; // @[icache.scala 122:18 93:33]
  wire  _GEN_273 = 3'h3 == state ? 1'h0 : 3'h4 == state & _GEN_204; // @[icache.scala 122:18 87:25]
  wire  _GEN_274 = 3'h3 == state ? 1'h0 : 3'h4 == state & _GEN_205; // @[icache.scala 122:18 87:25]
  wire [20:0] _GEN_275 = 3'h3 == state ? 21'h0 : _GEN_239; // @[icache.scala 122:18 86:25]
  wire [20:0] _GEN_276 = 3'h3 == state ? 21'h0 : _GEN_240; // @[icache.scala 122:18 86:25]
  wire  _GEN_277 = 3'h3 == state ? 1'h0 : 3'h4 == state & _GEN_208; // @[icache.scala 122:18 100:25]
  wire [31:0] _GEN_278 = 3'h3 == state ? 32'h7777 : _GEN_242; // @[icache.scala 122:18 98:25]
  wire  _GEN_280 = 3'h3 == state ? 1'h0 : 3'h4 == state & _GEN_211; // @[icache.scala 122:18 55:21]
  wire [20:0] _GEN_281 = 3'h3 == state ? 21'h0 : _GEN_245; // @[icache.scala 122:18 56:21]
  wire  _GEN_282 = 3'h3 == state ? cacheInst_r : _GEN_246; // @[icache.scala 122:18 46:38]
  wire  _GEN_283 = 3'h3 == state ? invalidate : _GEN_247; // @[icache.scala 122:18 47:38]
  wire  _GEN_284 = 3'h3 == state ? indexOnly : _GEN_248; // @[icache.scala 122:18 51:38]
  wire  _GEN_285 = 3'h3 == state ? writeBack : _GEN_249; // @[icache.scala 122:18 50:38]
  wire  _GEN_286 = 3'h3 == state ? storeTag : _GEN_250; // @[icache.scala 122:18 49:38]
  wire  _GEN_287 = 3'h3 == state ? loadTag : _GEN_251; // @[icache.scala 122:18 48:38]
  wire  _GEN_349 = 3'h1 == state ? 1'h0 : 3'h2 == state & _GEN_101; // @[icache.scala 122:18 120:25]
  wire  refillIDX = 3'h0 == state ? 1'h0 : _GEN_349; // @[icache.scala 122:18 120:25]
  wire  _GEN_293 = 3'h2 == state ? 1'h0 : _GEN_253; // @[icache.scala 122:18 101:25]
  wire [2:0] _GEN_294 = 3'h2 == state ? 3'h0 : _GEN_254; // @[icache.scala 122:18 102:25]
  wire [31:0] _GEN_295 = 3'h2 == state ? 32'h0 : _GEN_255; // @[icache.scala 122:18 103:25]
  wire [31:0] _GEN_297 = 3'h2 == state ? 32'h0 : _GEN_257; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_298 = 3'h2 == state ? 32'h0 : _GEN_258; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_299 = 3'h2 == state ? 32'h0 : _GEN_259; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_300 = 3'h2 == state ? 32'h0 : _GEN_260; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_301 = 3'h2 == state ? 32'h0 : _GEN_261; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_302 = 3'h2 == state ? 32'h0 : _GEN_262; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_303 = 3'h2 == state ? 32'h0 : _GEN_263; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_304 = 3'h2 == state ? 32'h0 : _GEN_264; // @[icache.scala 122:18 92:33]
  wire [3:0] _GEN_305 = 3'h2 == state ? 4'h0 : _GEN_265; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_306 = 3'h2 == state ? 4'h0 : _GEN_266; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_307 = 3'h2 == state ? 4'h0 : _GEN_267; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_308 = 3'h2 == state ? 4'h0 : _GEN_268; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_309 = 3'h2 == state ? 4'h0 : _GEN_269; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_310 = 3'h2 == state ? 4'h0 : _GEN_270; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_311 = 3'h2 == state ? 4'h0 : _GEN_271; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_312 = 3'h2 == state ? 4'h0 : _GEN_272; // @[icache.scala 122:18 93:33]
  wire  _GEN_313 = 3'h2 == state ? 1'h0 : _GEN_273; // @[icache.scala 122:18 87:25]
  wire  _GEN_314 = 3'h2 == state ? 1'h0 : _GEN_274; // @[icache.scala 122:18 87:25]
  wire [20:0] _GEN_315 = 3'h2 == state ? 21'h0 : _GEN_275; // @[icache.scala 122:18 86:25]
  wire [20:0] _GEN_316 = 3'h2 == state ? 21'h0 : _GEN_276; // @[icache.scala 122:18 86:25]
  wire  _GEN_317 = 3'h2 == state ? 1'h0 : _GEN_277; // @[icache.scala 122:18 100:25]
  wire [31:0] _GEN_318 = 3'h2 == state ? 32'h7777 : _GEN_278; // @[icache.scala 122:18 98:25]
  wire  _GEN_320 = 3'h2 == state ? 1'h0 : _GEN_280; // @[icache.scala 122:18 55:21]
  wire [20:0] _GEN_321 = 3'h2 == state ? 21'h0 : _GEN_281; // @[icache.scala 122:18 56:21]
  wire [31:0] _GEN_329 = 3'h1 == state ? _GEN_40 : _GEN_318; // @[icache.scala 122:18]
  wire  _GEN_332 = 3'h1 == state ? _GEN_43 : _GEN_317; // @[icache.scala 122:18]
  wire  _GEN_334 = 3'h1 == state ? _GEN_79 : _GEN_320; // @[icache.scala 122:18]
  wire  _GEN_341 = 3'h1 == state & _GEN_86; // @[icache.scala 122:18 99:25]
  wire [7:0] _GEN_346 = 3'h1 == state ? _GEN_91 : req_set; // @[icache.scala 122:18 76:34]
  wire  _GEN_350 = 3'h1 == state ? 1'h0 : _GEN_293; // @[icache.scala 122:18 101:25]
  wire [2:0] _GEN_351 = 3'h1 == state ? 3'h0 : _GEN_294; // @[icache.scala 122:18 102:25]
  wire [31:0] _GEN_352 = 3'h1 == state ? 32'h0 : _GEN_295; // @[icache.scala 122:18 103:25]
  wire [31:0] _GEN_354 = 3'h1 == state ? 32'h0 : _GEN_297; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_355 = 3'h1 == state ? 32'h0 : _GEN_298; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_356 = 3'h1 == state ? 32'h0 : _GEN_299; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_357 = 3'h1 == state ? 32'h0 : _GEN_300; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_358 = 3'h1 == state ? 32'h0 : _GEN_301; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_359 = 3'h1 == state ? 32'h0 : _GEN_302; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_360 = 3'h1 == state ? 32'h0 : _GEN_303; // @[icache.scala 122:18 92:33]
  wire [31:0] _GEN_361 = 3'h1 == state ? 32'h0 : _GEN_304; // @[icache.scala 122:18 92:33]
  wire [3:0] _GEN_362 = 3'h1 == state ? 4'h0 : _GEN_305; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_363 = 3'h1 == state ? 4'h0 : _GEN_306; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_364 = 3'h1 == state ? 4'h0 : _GEN_307; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_365 = 3'h1 == state ? 4'h0 : _GEN_308; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_366 = 3'h1 == state ? 4'h0 : _GEN_309; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_367 = 3'h1 == state ? 4'h0 : _GEN_310; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_368 = 3'h1 == state ? 4'h0 : _GEN_311; // @[icache.scala 122:18 93:33]
  wire [3:0] _GEN_369 = 3'h1 == state ? 4'h0 : _GEN_312; // @[icache.scala 122:18 93:33]
  wire  _GEN_370 = 3'h1 == state ? 1'h0 : _GEN_313; // @[icache.scala 122:18 87:25]
  wire  _GEN_371 = 3'h1 == state ? 1'h0 : _GEN_314; // @[icache.scala 122:18 87:25]
  wire [20:0] _GEN_372 = 3'h1 == state ? 21'h0 : _GEN_315; // @[icache.scala 122:18 86:25]
  wire [20:0] _GEN_373 = 3'h1 == state ? 21'h0 : _GEN_316; // @[icache.scala 122:18 86:25]
  wire [20:0] _GEN_374 = 3'h1 == state ? 21'h0 : _GEN_321; // @[icache.scala 122:18 56:21]
  tagv_ram tagv_ram ( // @[icache.scala 68:49]
    .addra(tagv_ram_addra),
    .clka(tagv_ram_clka),
    .dina(tagv_ram_dina),
    .douta(tagv_ram_douta),
    .wea(tagv_ram_wea)
  );
  tagv_ram tagv_ram_1 ( // @[icache.scala 68:49]
    .addra(tagv_ram_1_addra),
    .clka(tagv_ram_1_clka),
    .dina(tagv_ram_1_dina),
    .douta(tagv_ram_1_douta),
    .wea(tagv_ram_1_wea)
  );
  data_ram data_ram ( // @[icache.scala 69:65]
    .addra(data_ram_addra),
    .clka(data_ram_clka),
    .dina(data_ram_dina),
    .douta(data_ram_douta),
    .wea(data_ram_wea)
  );
  data_ram data_ram_1 ( // @[icache.scala 69:65]
    .addra(data_ram_1_addra),
    .clka(data_ram_1_clka),
    .dina(data_ram_1_dina),
    .douta(data_ram_1_douta),
    .wea(data_ram_1_wea)
  );
  data_ram data_ram_2 ( // @[icache.scala 69:65]
    .addra(data_ram_2_addra),
    .clka(data_ram_2_clka),
    .dina(data_ram_2_dina),
    .douta(data_ram_2_douta),
    .wea(data_ram_2_wea)
  );
  data_ram data_ram_3 ( // @[icache.scala 69:65]
    .addra(data_ram_3_addra),
    .clka(data_ram_3_clka),
    .dina(data_ram_3_dina),
    .douta(data_ram_3_douta),
    .wea(data_ram_3_wea)
  );
  data_ram data_ram_4 ( // @[icache.scala 69:65]
    .addra(data_ram_4_addra),
    .clka(data_ram_4_clka),
    .dina(data_ram_4_dina),
    .douta(data_ram_4_douta),
    .wea(data_ram_4_wea)
  );
  data_ram data_ram_5 ( // @[icache.scala 69:65]
    .addra(data_ram_5_addra),
    .clka(data_ram_5_clka),
    .dina(data_ram_5_dina),
    .douta(data_ram_5_douta),
    .wea(data_ram_5_wea)
  );
  data_ram data_ram_6 ( // @[icache.scala 69:65]
    .addra(data_ram_6_addra),
    .clka(data_ram_6_clka),
    .dina(data_ram_6_dina),
    .douta(data_ram_6_douta),
    .wea(data_ram_6_wea)
  );
  data_ram data_ram_7 ( // @[icache.scala 69:65]
    .addra(data_ram_7_addra),
    .clka(data_ram_7_clka),
    .dina(data_ram_7_dina),
    .douta(data_ram_7_douta),
    .wea(data_ram_7_wea)
  );
  MaxPeriodFibonacciLFSR LFSR_result_prng ( // @[PRNG.scala 91:22]
    .clock(LFSR_result_prng_clock),
    .reset(LFSR_result_prng_reset),
    .io_out_0(LFSR_result_prng_io_out_0),
    .io_out_1(LFSR_result_prng_io_out_1),
    .io_out_2(LFSR_result_prng_io_out_2),
    .io_out_3(LFSR_result_prng_io_out_3),
    .io_out_4(LFSR_result_prng_io_out_4),
    .io_out_5(LFSR_result_prng_io_out_5),
    .io_out_6(LFSR_result_prng_io_out_6),
    .io_out_7(LFSR_result_prng_io_out_7),
    .io_out_8(LFSR_result_prng_io_out_8),
    .io_out_9(LFSR_result_prng_io_out_9),
    .io_out_10(LFSR_result_prng_io_out_10),
    .io_out_11(LFSR_result_prng_io_out_11),
    .io_out_12(LFSR_result_prng_io_out_12),
    .io_out_13(LFSR_result_prng_io_out_13),
    .io_out_14(LFSR_result_prng_io_out_14),
    .io_out_15(LFSR_result_prng_io_out_15)
  );
  assign addr_ok = 3'h0 == state ? _GEN_18 : _GEN_341; // @[icache.scala 122:18]
  assign data_ok = 3'h0 == state ? 1'h0 : _GEN_332; // @[icache.scala 122:18 100:25]
  assign rdata = 3'h0 == state ? 32'h7777 : _GEN_329; // @[icache.scala 122:18 98:25]
  assign rd_req = 3'h0 == state ? 1'h0 : _GEN_350; // @[icache.scala 122:18 101:25]
  assign rd_type = 3'h0 == state ? 3'h0 : _GEN_351; // @[icache.scala 122:18 102:25]
  assign rd_addr = 3'h0 == state ? 32'h0 : _GEN_352; // @[icache.scala 122:18 103:25]
  assign tag_output = 3'h0 == state ? 21'h0 : _GEN_374; // @[icache.scala 122:18 56:21]
  assign cache_op_done = 3'h0 == state ? 1'h0 : _GEN_334; // @[icache.scala 122:18 55:21]
  assign hit = 3'h0 == state ? 1'h0 : 3'h1 == state & _GEN_39; // @[icache.scala 122:18 97:25]
  assign tagv_ram_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign tagv_ram_clka = clock; // @[icache.scala 68:42 85:25]
  assign tagv_ram_dina = 3'h0 == state ? 21'h0 : _GEN_372; // @[icache.scala 122:18 86:25]
  assign tagv_ram_wea = 3'h0 == state ? 1'h0 : _GEN_370; // @[icache.scala 122:18 87:25]
  assign tagv_ram_1_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign tagv_ram_1_clka = clock; // @[icache.scala 68:42 85:25]
  assign tagv_ram_1_dina = 3'h0 == state ? 21'h0 : _GEN_373; // @[icache.scala 122:18 86:25]
  assign tagv_ram_1_wea = 3'h0 == state ? 1'h0 : _GEN_371; // @[icache.scala 122:18 87:25]
  assign data_ram_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_dina = 3'h0 == state ? 32'h0 : _GEN_354; // @[icache.scala 122:18 92:33]
  assign data_ram_wea = 3'h0 == state ? 4'h0 : _GEN_362; // @[icache.scala 122:18 93:33]
  assign data_ram_1_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_1_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_1_dina = 3'h0 == state ? 32'h0 : _GEN_355; // @[icache.scala 122:18 92:33]
  assign data_ram_1_wea = 3'h0 == state ? 4'h0 : _GEN_363; // @[icache.scala 122:18 93:33]
  assign data_ram_2_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_2_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_2_dina = 3'h0 == state ? 32'h0 : _GEN_356; // @[icache.scala 122:18 92:33]
  assign data_ram_2_wea = 3'h0 == state ? 4'h0 : _GEN_364; // @[icache.scala 122:18 93:33]
  assign data_ram_3_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_3_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_3_dina = 3'h0 == state ? 32'h0 : _GEN_357; // @[icache.scala 122:18 92:33]
  assign data_ram_3_wea = 3'h0 == state ? 4'h0 : _GEN_365; // @[icache.scala 122:18 93:33]
  assign data_ram_4_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_4_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_4_dina = 3'h0 == state ? 32'h0 : _GEN_358; // @[icache.scala 122:18 92:33]
  assign data_ram_4_wea = 3'h0 == state ? 4'h0 : _GEN_366; // @[icache.scala 122:18 93:33]
  assign data_ram_5_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_5_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_5_dina = 3'h0 == state ? 32'h0 : _GEN_359; // @[icache.scala 122:18 92:33]
  assign data_ram_5_wea = 3'h0 == state ? 4'h0 : _GEN_367; // @[icache.scala 122:18 93:33]
  assign data_ram_6_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_6_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_6_dina = 3'h0 == state ? 32'h0 : _GEN_360; // @[icache.scala 122:18 92:33]
  assign data_ram_6_wea = 3'h0 == state ? 4'h0 : _GEN_368; // @[icache.scala 122:18 93:33]
  assign data_ram_7_addra = 3'h0 == state ? _GEN_11 : _GEN_346; // @[icache.scala 122:18]
  assign data_ram_7_clka = clock; // @[icache.scala 69:58 91:33]
  assign data_ram_7_dina = 3'h0 == state ? 32'h0 : _GEN_361; // @[icache.scala 122:18 92:33]
  assign data_ram_7_wea = 3'h0 == state ? 4'h0 : _GEN_369; // @[icache.scala 122:18 93:33]
  assign LFSR_result_prng_clock = clock;
  assign LFSR_result_prng_reset = reset;
  always @(posedge clock) begin
    if (reset) begin // @[icache.scala 46:38]
      cacheInst_r <= 1'h0; // @[icache.scala 46:38]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        cacheInst_r <= cache_op_en; // @[icache.scala 129:33]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        cacheInst_r <= _GEN_62;
      end
    end else if (!(3'h2 == state)) begin // @[icache.scala 122:18]
      cacheInst_r <= _GEN_282;
    end
    if (reset) begin // @[icache.scala 47:38]
      invalidate <= 1'h0; // @[icache.scala 47:38]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        invalidate <= cacheOperation_0; // @[icache.scala 130:33]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        invalidate <= _GEN_63;
      end
    end else if (!(3'h2 == state)) begin // @[icache.scala 122:18]
      invalidate <= _GEN_283;
    end
    if (reset) begin // @[icache.scala 48:38]
      loadTag <= 1'h0; // @[icache.scala 48:38]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        if (_cacheOperation_T_1) begin // @[Lookup.scala 34:39]
          loadTag <= 1'h0;
        end else begin
          loadTag <= _cacheOperation_T_3;
        end
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        loadTag <= _GEN_67;
      end
    end else if (!(3'h2 == state)) begin // @[icache.scala 122:18]
      loadTag <= _GEN_287;
    end
    if (reset) begin // @[icache.scala 49:38]
      storeTag <= 1'h0; // @[icache.scala 49:38]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        if (_cacheOperation_T_1) begin // @[Lookup.scala 34:39]
          storeTag <= 1'h0;
        end else begin
          storeTag <= _cacheOperation_T_36;
        end
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        storeTag <= _GEN_66;
      end
    end else if (!(3'h2 == state)) begin // @[icache.scala 122:18]
      storeTag <= _GEN_286;
    end
    if (reset) begin // @[icache.scala 50:38]
      writeBack <= 1'h0; // @[icache.scala 50:38]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        writeBack <= cacheOperation_3; // @[icache.scala 133:33]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        writeBack <= _GEN_65;
      end
    end else if (!(3'h2 == state)) begin // @[icache.scala 122:18]
      writeBack <= _GEN_285;
    end
    if (reset) begin // @[icache.scala 51:38]
      indexOnly <= 1'h0; // @[icache.scala 51:38]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        indexOnly <= cacheOperation_4; // @[icache.scala 134:33]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        indexOnly <= _GEN_64;
      end
    end else if (!(3'h2 == state)) begin // @[icache.scala 122:18]
      indexOnly <= _GEN_284;
    end
    if (reset) begin // @[icache.scala 73:34]
      req_op <= 1'h0; // @[icache.scala 73:34]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (!(cache_op_en)) begin // @[icache.scala 124:30]
        if (valid) begin // @[icache.scala 142:30]
          req_op <= op; // @[icache.scala 145:24]
        end
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (!(cacheInst_r)) begin // @[icache.scala 176:30]
        req_op <= _GEN_74;
      end
    end
    if (reset) begin // @[icache.scala 74:34]
      req_uncached <= 1'h0; // @[icache.scala 74:34]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        req_uncached <= 1'h0; // @[icache.scala 126:33]
      end else if (valid) begin // @[icache.scala 142:30]
        req_uncached <= uncached; // @[icache.scala 150:30]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (!(cacheInst_r)) begin // @[icache.scala 176:30]
        req_uncached <= _GEN_73;
      end
    end
    if (reset) begin // @[icache.scala 75:34]
      req_offset <= 4'h0; // @[icache.scala 75:34]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (!(cache_op_en)) begin // @[icache.scala 124:30]
        if (valid) begin // @[icache.scala 142:30]
          req_offset <= offset; // @[icache.scala 149:28]
        end
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (!(cacheInst_r)) begin // @[icache.scala 176:30]
        req_offset <= _GEN_77;
      end
    end
    if (reset) begin // @[icache.scala 76:34]
      req_set <= 8'h0; // @[icache.scala 76:34]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        req_set <= cache_index; // @[icache.scala 128:33]
      end else if (valid) begin // @[icache.scala 142:30]
        req_set <= index; // @[icache.scala 148:25]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (!(cacheInst_r)) begin // @[icache.scala 176:30]
        req_set <= _GEN_76;
      end
    end
    if (reset) begin // @[icache.scala 77:34]
      req_tag <= 20'h0; // @[icache.scala 77:34]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        req_tag <= cache_tag; // @[icache.scala 127:33]
      end else if (valid) begin // @[icache.scala 142:30]
        req_tag <= tag; // @[icache.scala 147:25]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (!(cacheInst_r)) begin // @[icache.scala 176:30]
        req_tag <= _GEN_75;
      end
    end
    if (reset) begin // @[icache.scala 109:34]
      state <= 3'h0; // @[icache.scala 109:34]
    end else if (3'h0 == state) begin // @[icache.scala 122:18]
      if (cache_op_en) begin // @[icache.scala 124:30]
        state <= 3'h1; // @[icache.scala 125:33]
      end else if (valid) begin // @[icache.scala 142:30]
        state <= _state_T; // @[icache.scala 143:23]
      end
    end else if (3'h1 == state) begin // @[icache.scala 122:18]
      if (cacheInst_r) begin // @[icache.scala 176:30]
        state <= _GEN_60;
      end else begin
        state <= _GEN_70;
      end
    end else if (3'h2 == state) begin // @[icache.scala 122:18]
      state <= 3'h3; // @[icache.scala 227:37]
    end else begin
      state <= _GEN_252;
    end
    if (reset) begin // @[icache.scala 113:34]
      refillIDX_r <= 1'h0; // @[icache.scala 113:34]
    end else if (!(3'h0 == state)) begin // @[icache.scala 122:18]
      if (3'h1 == state) begin // @[icache.scala 122:18]
        if (tagv_1_douta[19:0] == req_tag & tagv_1_douta[20]) begin // @[icache.scala 161:78]
          refillIDX_r <= _GEN_38;
        end else begin
          refillIDX_r <= _GEN_31;
        end
      end else if (3'h2 == state) begin // @[icache.scala 122:18]
        refillIDX_r <= refillIDX; // @[icache.scala 243:37]
      end
    end
    LFSR_result <= {LFSR_result_hi,LFSR_result_lo}; // @[PRNG.scala 95:17]
    if (reset) begin // @[icache.scala 117:34]
      wr_cnt <= 2'h0; // @[icache.scala 117:34]
    end else if (!(3'h0 == state)) begin // @[icache.scala 122:18]
      if (!(3'h1 == state)) begin // @[icache.scala 122:18]
        if (!(3'h2 == state)) begin // @[icache.scala 122:18]
          wr_cnt <= _GEN_256;
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  cacheInst_r = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  invalidate = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  loadTag = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  storeTag = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  writeBack = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  indexOnly = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  req_op = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  req_uncached = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  req_offset = _RAND_8[3:0];
  _RAND_9 = {1{`RANDOM}};
  req_set = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  req_tag = _RAND_10[19:0];
  _RAND_11 = {1{`RANDOM}};
  state = _RAND_11[2:0];
  _RAND_12 = {1{`RANDOM}};
  refillIDX_r = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  LFSR_result = _RAND_13[15:0];
  _RAND_14 = {1{`RANDOM}};
  wr_cnt = _RAND_14[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
