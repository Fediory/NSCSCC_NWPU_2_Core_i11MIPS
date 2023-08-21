`include "tlb_defines.v"
module TLB_pre_IF_bridge(
        input [31:0] pre_IF_pc,
    
        output [`VPN2_WD]  s0_vpn2,
        output             s0_odd_page,
        input              s0_found,
        input [`PFN_WD]    s0_pfn,
        input              s0_V,

        output [31:0]     pre_IF_paddr,
        output            is_TLB_refill,
        output            is_TLB_invalid
    );
        wire [31:0] TLB_result;
        assign pre_IF_paddr   = TLB_result              ;
        assign s0_vpn2        = pre_IF_pc[31:13];
        assign s0_odd_page    = pre_IF_pc[12];
        assign TLB_result     = {s0_pfn,pre_IF_pc[11:0]};
        assign is_TLB_refill  = !s0_found;
        assign is_TLB_invalid =  s0_found && !s0_V;
        
endmodule
