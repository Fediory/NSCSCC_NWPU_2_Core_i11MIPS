`include "tlb_defines.v"
module TLB_EXE_bridge(
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

        assign paddr =  TLB_result;              
        assign s1_vpn2 = alu_result[31:13];
        assign s1_odd_page = alu_result[12];
        assign TLB_result = {s1_pfn,alu_result[11:0]};
        assign TLB_invalid_L = s1_found && !s1_v && (ins_load | is_cache);
        assign TLB_invalid_S = s1_found && !s1_v && is_store;
        assign TLB_refill_L = !s1_found && (ins_load | is_cache);
        assign TLB_refill_S = !s1_found && is_store;
        assign TLB_mod      =  s1_found && s1_v && !s1_d && is_store;



endmodule
