`include "tlb_defines.v"
module TLB_MEM0_bridge(
    input [31:0] alu_result,

    output [`VPN2_WD]  s1_vpn2,
    output             s1_odd_page,
    input              s1_found,
    input              s1_d,
    input              s1_v,
    input [`PFN_WD]    s1_pfn,

    input              is_store,
    input              ins_load,
    input              is_cache,

    output [31:0]      paddr,
    output             TLB_invalid_L,
    output             TLB_invalid_S,
    output             TLB_refill_L,
    output             TLB_refill_S,
    output             TLB_mod
    );

        wire [31:0] TLB_result;
        wire        is_mapped;
        wire        is_k0,is_k1;

        assign paddr =  is_mapped         ? TLB_result               :
                        (is_k0 || is_k1)  ? {3'b0, alu_result[28:0]} :
                                            alu_result               ;
        assign s1_vpn2 = alu_result[31:13];
        assign s1_odd_page = alu_result[12];
        assign is_mapped = (alu_result[31] == 1'b0) | (alu_result[31:30] == 2'b11);
        assign TLB_result = {s1_pfn,alu_result[11:0]};
        assign TLB_invalid_L = s1_found && !s1_v && is_mapped && (ins_load || is_cache);
        assign TLB_invalid_S = s1_found && !s1_v && is_mapped && is_store;
        assign TLB_refill_L = !s1_found && is_mapped && (ins_load || is_cache);
        assign TLB_refill_S = !s1_found && is_mapped && is_store;
        assign TLB_mod      =  s1_found && s1_v && !s1_d && is_store && is_mapped;
        assign is_k0        =  (alu_result[31:28] >= 4'h8) && (alu_result[31:28] <4'hA);
        assign is_k1        =  (alu_result[31:28] >= 4'hA) && (alu_result[31:28] <4'hC);



endmodule
