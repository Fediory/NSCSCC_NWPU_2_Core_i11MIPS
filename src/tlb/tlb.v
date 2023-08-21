`include "tlb_defines.v"

module tlb(
    input clk,
    input reset,


    //查找接口0
    input  [`VPN2_WD]   s0_vpn2,
    input               s0_odd_page,
    input  [`ASID_WD]   s0_asid,
    output              s0_found,
    output [`TLB_WD]    s0_index,
    output [`PFN_WD]    s0_pfn,
    output [`C_WD]      s0_c,
    output              s0_d,
    output              s0_v,


    //查找接口1
    input  [`VPN2_WD]   s1_vpn2,
    input               s1_odd_page,
    input  [`ASID_WD]   s1_asid,
    output              s1_found,
    output [`TLB_WD]    s1_index,
    output [`PFN_WD]    s1_pfn,
    output [`C_WD]      s1_c,
    output              s1_d,
    output              s1_v,


    //写
    input               we,
    input [`TLB_WD]     w_index,
    input [`VPN2_WD]    w_vpn2,
    input [`ASID_WD]    w_asid,
    input               w_g,
    input [`PFN_WD]     w_pfn0,
    input [`C_WD]       w_c0,
    input               w_d0,
    input               w_v0,
    input [`PFN_WD]     w_pfn1,
    input [`C_WD]       w_c1,
    input               w_d1,
    input               w_v1,
    input [`MASK_SIZE]  w_mask,


    //读
    input  [`TLB_WD]    r_index,
    output [`VPN2_WD]   r_vpn2,
    output [`ASID_WD]   r_asid,
    output              r_g,
    output [`PFN_WD]    r_pfn0,
    output [`C_WD]      r_c0,
    output              r_d0,
    output              r_v0,
    output [`PFN_WD]    r_pfn1,
    output [`C_WD]      r_c1,
    output              r_d1,
    output              r_v1,
    output [`MASK_SIZE] r_mask
);

reg [`VPN2_WD]      tlb_vpn2    [`TLB_SIZE];
reg [`ASID_WD]      tlb_asid    [`TLB_SIZE];
reg                 tlb_g       [`TLB_SIZE];
reg [`PFN_WD]       tlb_pfn0    [`TLB_SIZE];
reg [`C_WD]         tlb_c0      [`TLB_SIZE];
reg                 tlb_d0      [`TLB_SIZE];
reg                 tlb_v0      [`TLB_SIZE];
reg [`PFN_WD]       tlb_pfn1    [`TLB_SIZE];
reg [`C_WD]         tlb_c1      [`TLB_SIZE];
reg                 tlb_d1      [`TLB_SIZE];
reg                 tlb_v1      [`TLB_SIZE];
reg [`MASK_SIZE]    tlb_mask    [`TLB_SIZE];


//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////查找//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

wire [`TLB_SIZE]     s_match0   ;
wire [`TLB_SIZE]     s_match1   ;
wire [`MATCH_WD]     match_num0 ;
wire [`MATCH_WD]     match_num1 ;
reg  [`TLB_SIZE]     tlb_empty  ;

//结果输出1
assign s0_pfn = s0_odd_page ?  (tlb_pfn1[s0_index] & ~{4'b0,tlb_mask[s1_index]}) : (tlb_pfn0[s0_index] & ~{4'b0,tlb_mask[s1_index]});
assign s0_c   = s0_odd_page ?  tlb_c1[s0_index]   : tlb_c0[s0_index];
assign s0_d   = s0_odd_page ?  tlb_d1[s0_index]   : tlb_d0[s0_index];
assign s0_v   = s0_odd_page ?  tlb_v1[s0_index]   : tlb_v0[s0_index];

//结果输出2
assign s1_pfn = s1_odd_page ?  (tlb_pfn1[s1_index] & ~{4'b0,tlb_mask[s1_index]}) : (tlb_pfn0[s1_index] &  ~{4'b0,tlb_mask[s1_index]});
assign s1_c   = s1_odd_page ?  tlb_c1[s1_index]   : tlb_c0[s1_index];
assign s1_d   = s1_odd_page ?  tlb_d1[s1_index]   : tlb_d0[s1_index];
assign s1_v   = s1_odd_page ?  tlb_v1[s1_index]   : tlb_v0[s1_index];

//查找结果 
assign s_match0[ 0] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[0]}) ^ (tlb_vpn2[ 0] & ~{3'b0,tlb_mask[0]})) && (~|(s0_asid ^ tlb_asid[ 0]) || tlb_g[ 0]);
assign s_match0[ 1] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[1]}) ^ (tlb_vpn2[ 1] & ~{3'b0,tlb_mask[1]})) && (~|(s0_asid ^ tlb_asid[ 1]) || tlb_g[ 1]);
assign s_match0[ 2] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[2]}) ^ (tlb_vpn2[ 2] & ~{3'b0,tlb_mask[2]})) && (~|(s0_asid ^ tlb_asid[ 2]) || tlb_g[ 2]);
assign s_match0[ 3] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[3]}) ^ (tlb_vpn2[ 3] & ~{3'b0,tlb_mask[3]})) && (~|(s0_asid ^ tlb_asid[ 3]) || tlb_g[ 3]);
assign s_match0[ 4] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[4]}) ^ (tlb_vpn2[ 4] & ~{3'b0,tlb_mask[4]})) && (~|(s0_asid ^ tlb_asid[ 4]) || tlb_g[ 4]);
assign s_match0[ 5] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[5]}) ^ (tlb_vpn2[ 5] & ~{3'b0,tlb_mask[5]})) && (~|(s0_asid ^ tlb_asid[ 5]) || tlb_g[ 5]);
assign s_match0[ 6] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[6]}) ^ (tlb_vpn2[ 6] & ~{3'b0,tlb_mask[6]})) && (~|(s0_asid ^ tlb_asid[ 6]) || tlb_g[ 6]);
assign s_match0[ 7] = ~|((s0_vpn2 &  ~{3'b0,tlb_mask[7]}) ^ (tlb_vpn2[ 7] & ~{3'b0,tlb_mask[7]})) && (~|(s0_asid ^ tlb_asid[ 7]) || tlb_g[ 7]);
// assign s_match0[ 8] = (s0_vpn2 == (tlb_vpn2[ 8] & ~tlb_mask[8])) && ((s0_asid == tlb_asid[ 8]) || tlb_g[ 8]) && !tlb_empty[ 8];
// assign s_match0[ 9] = (s0_vpn2 == (tlb_vpn2[ 9] & ~tlb_mask[9])) && ((s0_asid == tlb_asid[ 9]) || tlb_g[ 9]) && !tlb_empty[ 9];
// assign s_match0[10] = (s0_vpn2 == (tlb_vpn2[ 10] & ~tlb_mask[10])) && ((s0_asid == tlb_asid[10]) || tlb_g[10]) && !tlb_empty[10];
// assign s_match0[11] = (s0_vpn2 == (tlb_vpn2[ 11] & ~tlb_mask[11])) && ((s0_asid == tlb_asid[11]) || tlb_g[11]) && !tlb_empty[11];
// assign s_match0[12] = (s0_vpn2 == (tlb_vpn2[ 12] & ~tlb_mask[12])) && ((s0_asid == tlb_asid[12]) || tlb_g[12]) && !tlb_empty[12];
// assign s_match0[13] = (s0_vpn2 == (tlb_vpn2[ 13] & ~tlb_mask[13])) && ((s0_asid == tlb_asid[13]) || tlb_g[13]) && !tlb_empty[13];
// assign s_match0[14] = (s0_vpn2 == (tlb_vpn2[ 14] & ~tlb_mask[14])) && ((s0_asid == tlb_asid[14]) || tlb_g[14]) && !tlb_empty[14];
// assign s_match0[15] = (s0_vpn2 == (tlb_vpn2[ 15] & ~tlb_mask[15])) && ((s0_asid == tlb_asid[15]) || tlb_g[15]) && !tlb_empty[15];

assign s_match1[ 0] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[0]}) ^ (tlb_vpn2[ 0] & ~{3'b0,tlb_mask[0]})) && (~|(s1_asid ^ tlb_asid[ 0]) || tlb_g[ 0]);
assign s_match1[ 1] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[1]}) ^ (tlb_vpn2[ 1] & ~{3'b0,tlb_mask[1]})) && (~|(s1_asid ^ tlb_asid[ 1]) || tlb_g[ 1]);
assign s_match1[ 2] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[2]}) ^ (tlb_vpn2[ 2] & ~{3'b0,tlb_mask[2]})) && (~|(s1_asid ^ tlb_asid[ 2]) || tlb_g[ 2]);
assign s_match1[ 3] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[3]}) ^ (tlb_vpn2[ 3] & ~{3'b0,tlb_mask[3]})) && (~|(s1_asid ^ tlb_asid[ 3]) || tlb_g[ 3]);
assign s_match1[ 4] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[4]}) ^ (tlb_vpn2[ 4] & ~{3'b0,tlb_mask[4]})) && (~|(s1_asid ^ tlb_asid[ 4]) || tlb_g[ 4]);
assign s_match1[ 5] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[5]}) ^ (tlb_vpn2[ 5] & ~{3'b0,tlb_mask[5]})) && (~|(s1_asid ^ tlb_asid[ 5]) || tlb_g[ 5]);
assign s_match1[ 6] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[6]}) ^ (tlb_vpn2[ 6] & ~{3'b0,tlb_mask[6]})) && (~|(s1_asid ^ tlb_asid[ 6]) || tlb_g[ 6]);
assign s_match1[ 7] = ~|((s1_vpn2 & ~{3'b0,tlb_mask[7]}) ^ (tlb_vpn2[ 7] & ~{3'b0,tlb_mask[7]})) && (~|(s1_asid ^ tlb_asid[ 7]) || tlb_g[ 7]);
// assign s_match1[ 8] = (s1_vpn2 == (tlb_vpn2[ 8] & ~tlb_mask[8])) && ((s1_asid == tlb_asid[ 8]) || tlb_g[ 8])&& !tlb_empty[ 8];
// assign s_match1[ 9] = (s1_vpn2 == (tlb_vpn2[ 9] & ~tlb_mask[9])) && ((s1_asid == tlb_asid[ 9]) || tlb_g[ 9])&& !tlb_empty[ 9];
// assign s_match1[10] = (s1_vpn2 == (tlb_vpn2[ 10] & ~tlb_mask[10])) && ((s1_asid == tlb_asid[10]) || tlb_g[10])&& !tlb_empty[10];
// assign s_match1[11] = (s1_vpn2 == (tlb_vpn2[ 11] & ~tlb_mask[11])) && ((s1_asid == tlb_asid[11]) || tlb_g[11])&& !tlb_empty[11];
// assign s_match1[12] = (s1_vpn2 == (tlb_vpn2[ 12] & ~tlb_mask[12])) && ((s1_asid == tlb_asid[12]) || tlb_g[12])&& !tlb_empty[12];
// assign s_match1[13] = (s1_vpn2 == (tlb_vpn2[ 13] & ~tlb_mask[13])) && ((s1_asid == tlb_asid[13]) || tlb_g[13])&& !tlb_empty[13];
// assign s_match1[14] = (s1_vpn2 == (tlb_vpn2[ 14] & ~tlb_mask[14])) && ((s1_asid == tlb_asid[14]) || tlb_g[14])&& !tlb_empty[14];
// assign s_match1[15] = (s1_vpn2 == (tlb_vpn2[ 15] & ~tlb_mask[15])) && ((s1_asid == tlb_asid[15]) || tlb_g[15])&& !tlb_empty[15];
//opt:查询结果
assign match_num0 = ({3{s_match0[0]}} & 3'd0) |
                    ({3{s_match0[1]}} & 3'd1) |
                    ({3{s_match0[2]}} & 3'd2) |
                    ({3{s_match0[3]}} & 3'd3) |
                    ({3{s_match0[4]}} & 3'd4) |
                    ({3{s_match0[5]}} & 3'd5) |
                    ({3{s_match0[6]}} & 3'd6) |
                    ({3{s_match0[7]}} & 3'd7) ;
assign match_num1 = ({3{s_match1[0]}} & 3'd0) |
                    ({3{s_match1[1]}} & 3'd1) |
                    ({3{s_match1[2]}} & 3'd2) |
                    ({3{s_match1[3]}} & 3'd3) |
                    ({3{s_match1[4]}} & 3'd4) |
                    ({3{s_match1[5]}} & 3'd5) |
                    ({3{s_match1[6]}} & 3'd6) |
                    ({3{s_match1[7]}} & 3'd7) ;

assign s0_index = match_num0;
assign s1_index = match_num1;

//是否命中
assign s0_found = !(s_match0 == 8'b0);
assign s1_found = !(s_match1 == 8'b0);

//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////写入//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
integer i;
always @(posedge clk) begin
    if(reset)
      for(i = 0; i < `TLBNUM; i = i+1)begin
        tlb_vpn2[i] <= 0;
        tlb_asid[i] <= 0;
        tlb_g[i]    <= 0;
        tlb_pfn0[i] <= 0;
        tlb_c0[i]   <= 0;
        tlb_d0[i]   <= 0;
        tlb_v0[i]   <= 0;
        tlb_pfn1[i] <= 0;
        tlb_c1[i]   <= 0;
        tlb_d1[i]   <= 0;
        tlb_v1[i]   <= 0;
        tlb_mask[i] <= 0;
      end
    else if(we) 
    begin
      tlb_vpn2[w_index] <= w_vpn2 & (~w_mask);
      tlb_asid[w_index] <= w_asid;
      tlb_g   [w_index] <= w_g;
      tlb_pfn0[w_index] <= w_pfn0 & (~w_mask);
      tlb_c0  [w_index] <= w_c0;
      tlb_d0  [w_index] <= w_d0;
      tlb_v0  [w_index] <= w_v0;
      tlb_pfn1[w_index] <= w_pfn1 & (~w_mask);
      tlb_c1  [w_index] <= w_c1;
      tlb_d1  [w_index] <= w_d1;
      tlb_v1  [w_index] <= w_v1;
      tlb_mask[w_index] <= w_mask;
    end
end

//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////读出//////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

assign r_vpn2 = tlb_vpn2 [r_index] & (~{3'b0,tlb_mask[r_index]});
assign r_asid = tlb_asid [r_index];
assign r_g    = tlb_g    [r_index];
assign r_pfn0 = tlb_pfn0 [r_index] & (~{4'b0,tlb_mask[r_index]});
assign r_c0   = tlb_c0   [r_index];
assign r_d0   = tlb_d0   [r_index];
assign r_v0   = tlb_v0   [r_index];
assign r_pfn1 = tlb_pfn1 [r_index] & (~{4'b0,tlb_mask[r_index]});
assign r_c1   = tlb_c1   [r_index];
assign r_d1   = tlb_d1   [r_index];
assign r_v1   = tlb_v1   [r_index];
assign r_mask = tlb_mask [r_index];


endmodule

