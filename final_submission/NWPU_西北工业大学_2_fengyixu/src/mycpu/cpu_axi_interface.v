module cpu_axi_interface(
  input          clock,
  input          reset,
  input          icache_rd_req,
  input  [31:0]  icache_rd_addr,
  input  [2:0]   icache_rd_type,
  output         icache_rd_rdy,
  output         icache_ret_valid,
  output         icache_ret_last,
  output [31:0]  icache_ret_data,
  input          icache_wr_req,
  input  [2:0]   icache_wr_type,
  input  [31:0]  icache_wr_addr,
  input  [31:0]  icache_wr_data,
  input  [3:0]   icache_wr_wstrb,
  output         icache_wr_rdy,
  input          dcache_rd_req,
  input  [31:0]  dcache_rd_addr,
  input  [2:0]   dcache_rd_type,
  output         dcache_rd_rdy,
  output         dcache_ret_valid,
  output         dcache_ret_last,
  output [31:0]  dcache_ret_data,
  input          dcache_wr_req,
  input  [2:0]   dcache_wr_type,
  input  [31:0]  dcache_wr_addr,
  input  [127:0] dcache_wr_data,
  input  [3:0]   dcache_wr_wstrb,
  output         dcache_wr_rdy,
  output [3:0]   arid,
  output [31:0]  araddr,
  output [7:0]   arlen,
  output [2:0]   arsize,
  output [1:0]   arburst,
  output [1:0]   arlock,
  output [3:0]   arcache,
  output [2:0]   arprot,
  output         arvalid,
  input          arready,
  input  [3:0]   rid,
  input  [31:0]  rdata,
  input  [1:0]   rresp,
  input          rlast,
  input          rvalid,
  output         rready,
  output [3:0]   awid,
  output [31:0]  awaddr,
  output [7:0]   awlen,
  output [2:0]   awsize,
  output [1:0]   awburst,
  output [1:0]   awlock,
  output [3:0]   awcache,
  output [2:0]   awprot,
  output         awvalid,
  input          awready,
  output [3:0]   wid,
  output [31:0]  wdata,
  output [3:0]   wstrb,
  output         wlast,
  output         wvalid,
  input          wready,
  input  [3:0]   bid,
  input  [1:0]   bresp,
  input          bvalid,
  output         bready
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
  reg [1:0] rreq; // @[cpu_axi_bridge.scala 83:30]
  reg [2:0] rtype; // @[cpu_axi_bridge.scala 84:30]
  reg [31:0] raddr_r; // @[cpu_axi_bridge.scala 85:30]
  reg [1:0] wreq; // @[cpu_axi_bridge.scala 87:30]
  reg [2:0] wtype; // @[cpu_axi_bridge.scala 88:30]
  reg [31:0] waddr_r; // @[cpu_axi_bridge.scala 89:30]
  reg [3:0] wstrb_r; // @[cpu_axi_bridge.scala 90:30]
  reg [31:0] wdata_r_0; // @[cpu_axi_bridge.scala 91:30]
  reg [31:0] wdata_r_1; // @[cpu_axi_bridge.scala 91:30]
  reg [31:0] wdata_r_2; // @[cpu_axi_bridge.scala 91:30]
  reg [31:0] wdata_r_3; // @[cpu_axi_bridge.scala 91:30]
  wire  _adventure_T = wreq != 2'h0; // @[cpu_axi_bridge.scala 95:33]
  wire [27:0] _adventure_T_3 = waddr_r[31:4] ^ dcache_rd_addr[31:4]; // @[cpu_axi_bridge.scala 95:61]
  wire  _adventure_T_6 = dcache_rd_req & (wreq != 2'h0 & _adventure_T_3 == 28'h0); // @[cpu_axi_bridge.scala 95:24]
  wire [27:0] _adventure_T_10 = waddr_r[31:4] ^ icache_rd_addr[31:4]; // @[cpu_axi_bridge.scala 96:61]
  wire  _adventure_T_13 = icache_rd_req & (_adventure_T & _adventure_T_10 == 28'h0); // @[cpu_axi_bridge.scala 96:24]
  wire  adventure = _adventure_T_6 | _adventure_T_13; // @[Mux.scala 101:16]
  reg [1:0] rstate; // @[cpu_axi_bridge.scala 142:25]
  wire [1:0] _GEN_0 = icache_rd_req ? 2'h1 : 2'h0; // @[cpu_axi_bridge.scala 146:33 154:42 155:37]
  wire [1:0] _GEN_1 = icache_rd_req ? 2'h1 : rreq; // @[cpu_axi_bridge.scala 154:42 156:37 83:30]
  wire [31:0] _GEN_2 = icache_rd_req ? icache_rd_addr : raddr_r; // @[cpu_axi_bridge.scala 154:42 157:37 85:30]
  wire [2:0] _GEN_3 = icache_rd_req ? icache_rd_type : rtype; // @[cpu_axi_bridge.scala 154:42 158:37 84:30]
  wire  _GEN_10 = dcache_rd_req ? 1'h0 : icache_rd_req; // @[cpu_axi_bridge.scala 132:25 148:36]
  wire  _GEN_15 = ~adventure & dcache_rd_req; // @[cpu_axi_bridge.scala 137:25 147:29]
  wire  _GEN_16 = ~adventure & _GEN_10; // @[cpu_axi_bridge.scala 132:25 147:29]
  wire [2:0] _arsize_T_1 = rtype[2] ? 3'h2 : rtype; // @[cpu_axi_bridge.scala 168:39]
  wire [1:0] _arlen_T_1 = rtype[2] ? 2'h3 : 2'h0; // @[cpu_axi_bridge.scala 169:39]
  wire  _T_4 = rreq == 2'h1; // @[cpu_axi_bridge.scala 177:27]
  wire  _T_5 = rreq == 2'h2; // @[cpu_axi_bridge.scala 182:32]
  wire [31:0] _GEN_19 = rreq == 2'h2 ? rdata : 32'h0; // @[cpu_axi_bridge.scala 134:25 182:44 184:45]
  wire  _GEN_20 = rreq == 2'h2 & rlast; // @[cpu_axi_bridge.scala 135:25 182:44 185:45]
  wire [31:0] _GEN_22 = rreq == 2'h1 ? rdata : 32'h0; // @[cpu_axi_bridge.scala 129:25 177:39 179:45]
  wire  _GEN_23 = rreq == 2'h1 & rlast; // @[cpu_axi_bridge.scala 130:25 177:39 180:45]
  wire  _GEN_24 = rreq == 2'h1 ? 1'h0 : _T_5; // @[cpu_axi_bridge.scala 136:25 177:39]
  wire [31:0] _GEN_25 = rreq == 2'h1 ? 32'h0 : _GEN_19; // @[cpu_axi_bridge.scala 134:25 177:39]
  wire  _GEN_26 = rreq == 2'h1 ? 1'h0 : _GEN_20; // @[cpu_axi_bridge.scala 135:25 177:39]
  wire [1:0] _GEN_27 = rlast ? 2'h0 : rreq; // @[cpu_axi_bridge.scala 188:28 189:45 83:30]
  wire [1:0] _GEN_28 = rlast ? 2'h0 : 2'h2; // @[cpu_axi_bridge.scala 188:28 175:33 190:45]
  wire  _GEN_29 = rvalid & _T_4; // @[cpu_axi_bridge.scala 131:25 176:25]
  wire [31:0] _GEN_30 = rvalid ? _GEN_22 : 32'h0; // @[cpu_axi_bridge.scala 129:25 176:25]
  wire  _GEN_31 = rvalid & _GEN_23; // @[cpu_axi_bridge.scala 130:25 176:25]
  wire  _GEN_32 = rvalid & _GEN_24; // @[cpu_axi_bridge.scala 136:25 176:25]
  wire [31:0] _GEN_33 = rvalid ? _GEN_25 : 32'h0; // @[cpu_axi_bridge.scala 134:25 176:25]
  wire  _GEN_34 = rvalid & _GEN_26; // @[cpu_axi_bridge.scala 135:25 176:25]
  wire [1:0] _GEN_35 = rvalid ? _GEN_27 : rreq; // @[cpu_axi_bridge.scala 176:25 83:30]
  wire [1:0] _GEN_36 = rvalid ? _GEN_28 : 2'h2; // @[cpu_axi_bridge.scala 176:25 175:33]
  wire [31:0] _GEN_39 = 2'h2 == rstate ? _GEN_30 : 32'h0; // @[cpu_axi_bridge.scala 144:19 129:25]
  wire [31:0] _GEN_42 = 2'h2 == rstate ? _GEN_33 : 32'h0; // @[cpu_axi_bridge.scala 144:19 134:25]
  wire [1:0] _GEN_46 = 2'h1 == rstate ? rreq : 2'h0; // @[cpu_axi_bridge.scala 144:19 101:25 165:33]
  wire [31:0] _GEN_48 = 2'h1 == rstate ? raddr_r : 32'h0; // @[cpu_axi_bridge.scala 144:19 104:25 167:33]
  wire [2:0] _GEN_49 = 2'h1 == rstate ? _arsize_T_1 : 3'h0; // @[cpu_axi_bridge.scala 144:19 103:25 168:33]
  wire [1:0] _GEN_50 = 2'h1 == rstate ? _arlen_T_1 : 2'h0; // @[cpu_axi_bridge.scala 144:19 102:25 169:33]
  wire  _GEN_51 = 2'h1 == rstate ? 1'h0 : 2'h2 == rstate & _GEN_29; // @[cpu_axi_bridge.scala 144:19 131:25]
  wire [31:0] _GEN_52 = 2'h1 == rstate ? 32'h0 : _GEN_39; // @[cpu_axi_bridge.scala 144:19 129:25]
  wire  _GEN_53 = 2'h1 == rstate ? 1'h0 : 2'h2 == rstate & _GEN_31; // @[cpu_axi_bridge.scala 144:19 130:25]
  wire  _GEN_54 = 2'h1 == rstate ? 1'h0 : 2'h2 == rstate & _GEN_32; // @[cpu_axi_bridge.scala 144:19 136:25]
  wire [31:0] _GEN_55 = 2'h1 == rstate ? 32'h0 : _GEN_42; // @[cpu_axi_bridge.scala 144:19 134:25]
  wire  _GEN_56 = 2'h1 == rstate ? 1'h0 : 2'h2 == rstate & _GEN_34; // @[cpu_axi_bridge.scala 144:19 135:25]
  wire [1:0] _GEN_64 = 2'h0 == rstate ? 2'h0 : _GEN_46; // @[cpu_axi_bridge.scala 144:19 101:25]
  wire [1:0] _GEN_68 = 2'h0 == rstate ? 2'h0 : _GEN_50; // @[cpu_axi_bridge.scala 144:19 102:25]
  reg [1:0] wstate; // @[cpu_axi_bridge.scala 201:34]
  reg [3:0] wr_cnt; // @[cpu_axi_bridge.scala 202:34]
  reg [3:0] wlen_r; // @[cpu_axi_bridge.scala 203:34]
  wire [2:0] _GEN_151 = {{1'd0}, wreq}; // @[cpu_axi_bridge.scala 227:41]
  wire [2:0] _awid_T_1 = _GEN_151 + 3'h4; // @[cpu_axi_bridge.scala 227:41]
  wire [1:0] _awlen_T_1 = wtype[2] ? 2'h3 : 2'h0; // @[cpu_axi_bridge.scala 230:39]
  wire [2:0] _awsize_T_1 = wtype[2] ? 3'h2 : wtype; // @[cpu_axi_bridge.scala 232:39]
  wire [31:0] _GEN_86 = 2'h1 == wr_cnt[1:0] ? wdata_r_1 : wdata_r_0; // @[cpu_axi_bridge.scala 241:{33,33}]
  wire [31:0] _GEN_87 = 2'h2 == wr_cnt[1:0] ? wdata_r_2 : _GEN_86; // @[cpu_axi_bridge.scala 241:{33,33}]
  wire [31:0] _GEN_88 = 2'h3 == wr_cnt[1:0] ? wdata_r_3 : _GEN_87; // @[cpu_axi_bridge.scala 241:{33,33}]
  wire [3:0] _wstrb_T_1 = wtype[2] ? 4'hf : wstrb_r; // @[cpu_axi_bridge.scala 242:39]
  wire [3:0] _wr_cnt_T_1 = wr_cnt + 4'h1; // @[cpu_axi_bridge.scala 246:47]
  wire  _T_10 = wr_cnt == wlen_r; // @[cpu_axi_bridge.scala 248:34]
  wire [1:0] _GEN_89 = wr_cnt == wlen_r ? 2'h3 : wstate; // @[cpu_axi_bridge.scala 201:34 248:45 249:37]
  wire [3:0] _GEN_91 = wr_cnt == wlen_r ? 4'h0 : wlen_r; // @[cpu_axi_bridge.scala 203:34 248:45 251:37]
  wire [1:0] _GEN_92 = wr_cnt < wlen_r ? 2'h2 : _GEN_89; // @[cpu_axi_bridge.scala 244:38 245:37]
  wire [3:0] _GEN_93 = wr_cnt < wlen_r ? _wr_cnt_T_1 : wr_cnt; // @[cpu_axi_bridge.scala 202:34 244:38 246:37]
  wire  _GEN_94 = wr_cnt < wlen_r ? 1'h0 : _T_10; // @[cpu_axi_bridge.scala 126:25 244:38]
  wire [3:0] _GEN_95 = wr_cnt < wlen_r ? wlen_r : _GEN_91; // @[cpu_axi_bridge.scala 203:34 244:38]
  wire [1:0] _GEN_96 = wready ? _GEN_92 : wstate; // @[cpu_axi_bridge.scala 243:25 201:34]
  wire [3:0] _GEN_97 = wready ? _GEN_93 : wr_cnt; // @[cpu_axi_bridge.scala 243:25 202:34]
  wire  _GEN_98 = wready & _GEN_94; // @[cpu_axi_bridge.scala 126:25 243:25]
  wire [3:0] _GEN_99 = wready ? _GEN_95 : wlen_r; // @[cpu_axi_bridge.scala 243:25 203:34]
  wire [3:0] _GEN_154 = {{1'd0}, _awid_T_1}; // @[cpu_axi_bridge.scala 257:42]
  wire [1:0] _GEN_100 = bready & bvalid & bid == _GEN_154 ? 2'h0 : 2'h3; // @[cpu_axi_bridge.scala 256:25 257:59 258:29]
  wire [1:0] _GEN_101 = bready & bvalid & bid == _GEN_154 ? 2'h0 : wreq; // @[cpu_axi_bridge.scala 257:59 259:29 87:30]
  wire [3:0] _GEN_102 = bready & bvalid & bid == _GEN_154 ? 4'h0 : wlen_r; // @[cpu_axi_bridge.scala 257:59 260:29 203:34]
  wire [1:0] _GEN_103 = 2'h3 == wstate ? _GEN_100 : wstate; // @[cpu_axi_bridge.scala 209:19 201:34]
  wire [1:0] _GEN_104 = 2'h3 == wstate ? _GEN_101 : wreq; // @[cpu_axi_bridge.scala 209:19 87:30]
  wire [3:0] _GEN_105 = 2'h3 == wstate ? _GEN_102 : wlen_r; // @[cpu_axi_bridge.scala 209:19 203:34]
  wire [2:0] _GEN_106 = 2'h2 == wstate ? _awid_T_1 : 3'h0; // @[cpu_axi_bridge.scala 209:19 122:25 239:33]
  wire [31:0] _GEN_108 = 2'h2 == wstate ? _GEN_88 : 32'h0; // @[cpu_axi_bridge.scala 209:19 123:25 241:33]
  wire [3:0] _GEN_109 = 2'h2 == wstate ? _wstrb_T_1 : 4'h0; // @[cpu_axi_bridge.scala 209:19 124:25 242:33]
  wire [2:0] _GEN_116 = 2'h1 == wstate ? _awid_T_1 : 3'h0; // @[cpu_axi_bridge.scala 209:19 112:25 227:33]
  wire [31:0] _GEN_118 = 2'h1 == wstate ? waddr_r : 32'h0; // @[cpu_axi_bridge.scala 209:19 115:25 229:33]
  wire [1:0] _GEN_119 = 2'h1 == wstate ? _awlen_T_1 : 2'h0; // @[cpu_axi_bridge.scala 209:19 113:25 230:33]
  wire [2:0] _GEN_121 = 2'h1 == wstate ? _awsize_T_1 : 3'h0; // @[cpu_axi_bridge.scala 209:19 114:25 232:33]
  wire [2:0] _GEN_123 = 2'h1 == wstate ? 3'h0 : _GEN_106; // @[cpu_axi_bridge.scala 209:19 122:25]
  wire  _GEN_124 = 2'h1 == wstate ? 1'h0 : 2'h2 == wstate; // @[cpu_axi_bridge.scala 209:19 125:25]
  wire [31:0] _GEN_125 = 2'h1 == wstate ? 32'h0 : _GEN_108; // @[cpu_axi_bridge.scala 209:19 123:25]
  wire [3:0] _GEN_126 = 2'h1 == wstate ? 4'h0 : _GEN_109; // @[cpu_axi_bridge.scala 209:19 124:25]
  wire  _GEN_127 = 2'h1 == wstate ? 1'h0 : 2'h2 == wstate & _GEN_98; // @[cpu_axi_bridge.scala 209:19 126:25]
  wire [2:0] _GEN_139 = 2'h0 == wstate ? 3'h0 : _GEN_116; // @[cpu_axi_bridge.scala 209:19 112:25]
  wire [1:0] _GEN_142 = 2'h0 == wstate ? 2'h0 : _GEN_119; // @[cpu_axi_bridge.scala 209:19 113:25]
  wire [2:0] _GEN_146 = 2'h0 == wstate ? 3'h0 : _GEN_123; // @[cpu_axi_bridge.scala 209:19 122:25]
  assign icache_rd_rdy = 2'h0 == rstate & _GEN_16; // @[cpu_axi_bridge.scala 144:19 132:25]
  assign icache_ret_valid = 2'h0 == rstate ? 1'h0 : _GEN_51; // @[cpu_axi_bridge.scala 144:19 131:25]
  assign icache_ret_last = 2'h0 == rstate ? 1'h0 : _GEN_53; // @[cpu_axi_bridge.scala 144:19 130:25]
  assign icache_ret_data = 2'h0 == rstate ? 32'h0 : _GEN_52; // @[cpu_axi_bridge.scala 144:19 129:25]
  assign icache_wr_rdy = 1'h1; // @[cpu_axi_bridge.scala 205:25]
  assign dcache_rd_rdy = 2'h0 == rstate & _GEN_15; // @[cpu_axi_bridge.scala 144:19 137:25]
  assign dcache_ret_valid = 2'h0 == rstate ? 1'h0 : _GEN_54; // @[cpu_axi_bridge.scala 144:19 136:25]
  assign dcache_ret_last = 2'h0 == rstate ? 1'h0 : _GEN_56; // @[cpu_axi_bridge.scala 144:19 135:25]
  assign dcache_ret_data = 2'h0 == rstate ? 32'h0 : _GEN_55; // @[cpu_axi_bridge.scala 144:19 134:25]
  assign dcache_wr_rdy = 2'h0 == wstate; // @[cpu_axi_bridge.scala 209:19]
  assign arid = {{2'd0}, _GEN_64};
  assign araddr = 2'h0 == rstate ? 32'h0 : _GEN_48; // @[cpu_axi_bridge.scala 144:19 104:25]
  assign arlen = {{6'd0}, _GEN_68};
  assign arsize = 2'h0 == rstate ? 3'h0 : _GEN_49; // @[cpu_axi_bridge.scala 144:19 103:25]
  assign arburst = 2'h1; // @[cpu_axi_bridge.scala 105:25]
  assign arlock = 2'h0; // @[cpu_axi_bridge.scala 107:25]
  assign arcache = 4'h0; // @[cpu_axi_bridge.scala 108:25]
  assign arprot = 3'h0; // @[cpu_axi_bridge.scala 110:25]
  assign arvalid = 2'h0 == rstate ? 1'h0 : 2'h1 == rstate; // @[cpu_axi_bridge.scala 144:19 106:25]
  assign rready = 1'h1; // @[cpu_axi_bridge.scala 109:25]
  assign awid = {{1'd0}, _GEN_139};
  assign awaddr = 2'h0 == wstate ? 32'h0 : _GEN_118; // @[cpu_axi_bridge.scala 209:19 115:25]
  assign awlen = {{6'd0}, _GEN_142};
  assign awsize = 2'h0 == wstate ? 3'h0 : _GEN_121; // @[cpu_axi_bridge.scala 209:19 114:25]
  assign awburst = 2'h1; // @[cpu_axi_bridge.scala 116:25]
  assign awlock = 2'h0; // @[cpu_axi_bridge.scala 118:25]
  assign awcache = 4'h0; // @[cpu_axi_bridge.scala 119:25]
  assign awprot = 3'h0; // @[cpu_axi_bridge.scala 120:25]
  assign awvalid = 2'h0 == wstate ? 1'h0 : 2'h1 == wstate; // @[cpu_axi_bridge.scala 209:19 117:25]
  assign wid = {{1'd0}, _GEN_146};
  assign wdata = 2'h0 == wstate ? 32'h0 : _GEN_125; // @[cpu_axi_bridge.scala 209:19 123:25]
  assign wstrb = 2'h0 == wstate ? 4'h0 : _GEN_126; // @[cpu_axi_bridge.scala 209:19 124:25]
  assign wlast = 2'h0 == wstate ? 1'h0 : _GEN_127; // @[cpu_axi_bridge.scala 209:19 126:25]
  assign wvalid = 2'h0 == wstate ? 1'h0 : _GEN_124; // @[cpu_axi_bridge.scala 209:19 125:25]
  assign bready = 1'h1; // @[cpu_axi_bridge.scala 127:25]
  always @(posedge clock) begin
    if (reset) begin // @[cpu_axi_bridge.scala 83:30]
      rreq <= 2'h0; // @[cpu_axi_bridge.scala 83:30]
    end else if (2'h0 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
      if (~adventure) begin // @[cpu_axi_bridge.scala 147:29]
        if (dcache_rd_req) begin // @[cpu_axi_bridge.scala 148:36]
          rreq <= 2'h2; // @[cpu_axi_bridge.scala 150:37]
        end else begin
          rreq <= _GEN_1;
        end
      end
    end else if (!(2'h1 == rstate)) begin // @[cpu_axi_bridge.scala 144:19]
      if (2'h2 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
        rreq <= _GEN_35;
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 84:30]
      rtype <= 3'h0; // @[cpu_axi_bridge.scala 84:30]
    end else if (2'h0 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
      if (~adventure) begin // @[cpu_axi_bridge.scala 147:29]
        if (dcache_rd_req) begin // @[cpu_axi_bridge.scala 148:36]
          rtype <= dcache_rd_type; // @[cpu_axi_bridge.scala 152:37]
        end else begin
          rtype <= _GEN_3;
        end
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 85:30]
      raddr_r <= 32'h0; // @[cpu_axi_bridge.scala 85:30]
    end else if (2'h0 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
      if (~adventure) begin // @[cpu_axi_bridge.scala 147:29]
        if (dcache_rd_req) begin // @[cpu_axi_bridge.scala 148:36]
          raddr_r <= dcache_rd_addr; // @[cpu_axi_bridge.scala 151:37]
        end else begin
          raddr_r <= _GEN_2;
        end
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 87:30]
      wreq <= 2'h0; // @[cpu_axi_bridge.scala 87:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wreq <= 2'h2; // @[cpu_axi_bridge.scala 214:33]
      end
    end else if (!(2'h1 == wstate)) begin // @[cpu_axi_bridge.scala 209:19]
      if (!(2'h2 == wstate)) begin // @[cpu_axi_bridge.scala 209:19]
        wreq <= _GEN_104;
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 88:30]
      wtype <= 3'h0; // @[cpu_axi_bridge.scala 88:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wtype <= dcache_wr_type; // @[cpu_axi_bridge.scala 216:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 89:30]
      waddr_r <= 32'h0; // @[cpu_axi_bridge.scala 89:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        waddr_r <= dcache_wr_addr; // @[cpu_axi_bridge.scala 217:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 90:30]
      wstrb_r <= 4'h0; // @[cpu_axi_bridge.scala 90:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wstrb_r <= dcache_wr_wstrb; // @[cpu_axi_bridge.scala 218:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 91:30]
      wdata_r_0 <= 32'h0; // @[cpu_axi_bridge.scala 91:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wdata_r_0 <= dcache_wr_data[31:0]; // @[cpu_axi_bridge.scala 219:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 91:30]
      wdata_r_1 <= 32'h0; // @[cpu_axi_bridge.scala 91:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wdata_r_1 <= dcache_wr_data[63:32]; // @[cpu_axi_bridge.scala 220:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 91:30]
      wdata_r_2 <= 32'h0; // @[cpu_axi_bridge.scala 91:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wdata_r_2 <= dcache_wr_data[95:64]; // @[cpu_axi_bridge.scala 221:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 91:30]
      wdata_r_3 <= 32'h0; // @[cpu_axi_bridge.scala 91:30]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wdata_r_3 <= dcache_wr_data[127:96]; // @[cpu_axi_bridge.scala 222:33]
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 142:25]
      rstate <= 2'h0; // @[cpu_axi_bridge.scala 142:25]
    end else if (2'h0 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
      if (~adventure) begin // @[cpu_axi_bridge.scala 147:29]
        if (dcache_rd_req) begin // @[cpu_axi_bridge.scala 148:36]
          rstate <= 2'h1; // @[cpu_axi_bridge.scala 149:37]
        end else begin
          rstate <= _GEN_0;
        end
      end else begin
        rstate <= 2'h0; // @[cpu_axi_bridge.scala 146:33]
      end
    end else if (2'h1 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
      if (arready) begin // @[cpu_axi_bridge.scala 170:26]
        rstate <= 2'h2; // @[cpu_axi_bridge.scala 171:33]
      end else begin
        rstate <= 2'h1; // @[cpu_axi_bridge.scala 164:33]
      end
    end else if (2'h2 == rstate) begin // @[cpu_axi_bridge.scala 144:19]
      rstate <= _GEN_36;
    end
    if (reset) begin // @[cpu_axi_bridge.scala 201:34]
      wstate <= 2'h0; // @[cpu_axi_bridge.scala 201:34]
    end else if (2'h0 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (dcache_wr_req) begin // @[cpu_axi_bridge.scala 213:32]
        wstate <= 2'h1; // @[cpu_axi_bridge.scala 215:33]
      end else begin
        wstate <= 2'h0; // @[cpu_axi_bridge.scala 211:33]
      end
    end else if (2'h1 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      if (awready) begin // @[cpu_axi_bridge.scala 234:26]
        wstate <= 2'h2; // @[cpu_axi_bridge.scala 235:33]
      end else begin
        wstate <= 2'h1; // @[cpu_axi_bridge.scala 226:33]
      end
    end else if (2'h2 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
      wstate <= _GEN_96;
    end else begin
      wstate <= _GEN_103;
    end
    if (reset) begin // @[cpu_axi_bridge.scala 202:34]
      wr_cnt <= 4'h0; // @[cpu_axi_bridge.scala 202:34]
    end else if (!(2'h0 == wstate)) begin // @[cpu_axi_bridge.scala 209:19]
      if (2'h1 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
        wr_cnt <= 4'h0; // @[cpu_axi_bridge.scala 233:33]
      end else if (2'h2 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
        wr_cnt <= _GEN_97;
      end
    end
    if (reset) begin // @[cpu_axi_bridge.scala 203:34]
      wlen_r <= 4'h0; // @[cpu_axi_bridge.scala 203:34]
    end else if (!(2'h0 == wstate)) begin // @[cpu_axi_bridge.scala 209:19]
      if (2'h1 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
        wlen_r <= {{2'd0}, _awlen_T_1}; // @[cpu_axi_bridge.scala 231:33]
      end else if (2'h2 == wstate) begin // @[cpu_axi_bridge.scala 209:19]
        wlen_r <= _GEN_99;
      end else begin
        wlen_r <= _GEN_105;
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
  rreq = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  rtype = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  raddr_r = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  wreq = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  wtype = _RAND_4[2:0];
  _RAND_5 = {1{`RANDOM}};
  waddr_r = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  wstrb_r = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  wdata_r_0 = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  wdata_r_1 = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  wdata_r_2 = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  wdata_r_3 = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  rstate = _RAND_11[1:0];
  _RAND_12 = {1{`RANDOM}};
  wstate = _RAND_12[1:0];
  _RAND_13 = {1{`RANDOM}};
  wr_cnt = _RAND_13[3:0];
  _RAND_14 = {1{`RANDOM}};
  wlen_r = _RAND_14[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
