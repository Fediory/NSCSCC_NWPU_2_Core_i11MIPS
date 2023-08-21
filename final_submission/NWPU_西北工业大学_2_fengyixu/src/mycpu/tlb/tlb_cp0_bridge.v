`include "tlb_defines.v"
module tlb_cp0_bridge (
    input                 is_tlbp,
    input                 is_tlbr,
    input                 is_tlbwi,
    input                 is_tlbwr,

    //tlbp
    input [`VPN2_WD]      tlbp_vpn2,
    input [`ASID_WD]      tlbp_asid,
    output[31:0]          tlbp_result,

    input clk,
    input reset,

    //写
    input [`TLB_WD]     w_random,
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
    input[`TLB_WD]      tlbr_index,
    output [`VPN2_WD]   tlbr_vpn2,
    output [`ASID_WD]   tlbr_asid,
    output              tlbr_g,
    output [`PFN_WD]    tlbr_pfn0,
    output [`C_WD]      tlbr_c0,
    output              tlbr_d0,
    output              tlbr_v0,
    output [`PFN_WD]    tlbr_pfn1,
    output [`C_WD]      tlbr_c1,
    output              tlbr_d1,
    output              tlbr_v1,
    output [`MASK_SIZE] tlbr_mask,

    //查找端口0
    input [`VPN2_WD]     s0_vpn2,
    input                s0_odd_page,
    input [`ASID_WD]     s0_asid,
    output               s0_found,
    output [`TLB_WD]     s0_index,
    output [`PFN_WD]     s0_pfn,
    output [`C_WD]       s0_c,
    output               s0_d,
    output               s0_v,

    //查找端口1（输入输出）
    input [`VPN2_WD]    s1_vpn2_mem,
    input               s1_odd_page_mem,
    input [`ASID_WD]    s1_asid_mem,
    output              s1_found,
    output [`TLB_WD]    s1_index,
    output [`PFN_WD]    s1_pfn,
    output [`C_WD]      s1_c,
    output              s1_d,
    output              s1_v

);  

    //tlbwr
    wire [`TLB_WD] wr_index = (is_tlbwr) ? w_random:w_index;
    //查找端口1（TLB）
    wire [`VPN2_WD] s1_vpn2;
    wire            s1_odd_page;
    wire [`ASID_WD] s1_asid;

    //tlb与mem查找
    wire            tlb_found ;
    wire[27:0]      tlb_blank ;
    wire[2:0]       tlbp_index;
    assign s1_vpn2 = (is_tlbp) ? tlbp_vpn2:s1_vpn2_mem;
    assign s1_asid = (is_tlbp) ? tlbp_asid:s1_asid_mem;
    assign s1_odd_page = s1_odd_page_mem;
    assign tlbp_result = {
        tlb_found,
        tlb_blank,
        tlbp_index
        };
    assign tlb_found = !s1_found;
    assign tlb_blank = 28'b0;
    assign tlbp_index = s1_found ? s1_index : 3'b0;

    //tlbr
    wire [`TLB_WD]      r_index;
    wire [`VPN2_WD]     r_vpn2;
    wire [`ASID_WD]     r_asid;
    wire                r_g;
    wire [`PFN_WD]      r_pfn0;
    wire [`C_WD]        r_c0;
    wire                r_d0;
    wire                r_v0;
    wire [`PFN_WD]      r_pfn1;
    wire [`C_WD]        r_c1;
    wire                r_d1;
    wire                r_v1;
    wire [`MASK_SIZE]   r_mask;
    assign r_index  =  tlbr_index      ;
    assign tlbr_vpn2   =  r_vpn2       ;
    assign tlbr_asid   =  r_asid       ;
    assign tlbr_g      =  r_g          ;
    assign tlbr_pfn0   =  r_pfn0       ;
    assign tlbr_c0     =  r_c0         ;
    assign tlbr_d0     =  r_d0         ;
    assign tlbr_v0     =  r_v0         ;
    assign tlbr_pfn1   =  r_pfn1       ;
    assign tlbr_c1     =  r_c1         ;
    assign tlbr_d1     =  r_d1         ;
    assign tlbr_v1	   =  r_v1         ;
    assign tlbr_mask   =  r_mask       ;

    //tlb写使能信号
    wire wen = is_tlbwi || is_tlbwr; 

    tlb 		TLB(
	.clk					(clk				),
    .reset                  (reset              ),

	.s0_vpn2				(s0_vpn2			),
	.s0_odd_page			(s0_odd_page		),
	.s0_asid				(s0_asid			),
	.s0_found				(s0_found			),
	.s0_index				(s0_index			),
	.s0_pfn					(s0_pfn				),
	.s0_c					(s0_c				),
	.s0_d					(s0_d				),
	.s0_v					(s0_v				),

	.s1_vpn2				(s1_vpn2			),
	.s1_odd_page			(s1_odd_page		),
	.s1_asid				(s1_asid			),
	.s1_found				(s1_found			),
	.s1_index				(s1_index			),
	.s1_pfn  				(s1_pfn  			),
	.s1_c    				(s1_c    			),
	.s1_d    				(s1_d    			),
	.s1_v    				(s1_v    			),

	.we     				(wen        	    ),
	.w_index				(wr_index			),
	.w_vpn2 				(w_vpn2 			),
	.w_asid 				(w_asid 			),
	.w_g    				(w_g    			),
	.w_pfn0 				(w_pfn0 			),
	.w_c0   				(w_c0   			),
	.w_d0   				(w_d0   			),
	.w_v0   				(w_v0   			),
	.w_pfn1 				(w_pfn1 			),
	.w_c1   				(w_c1   			),
	.w_d1   				(w_d1   			),
	.w_v1   				(w_v1   			),
    .w_mask                 (w_mask             ),

	.r_index  				(r_index			),
	.r_vpn2   				(r_vpn2 			),
	.r_asid   				(r_asid 			),
	.r_g      				(r_g    			),
	.r_pfn0   				(r_pfn0 			),
	.r_c0     				(r_c0   			),
	.r_d0     				(r_d0   			),
	.r_v0     				(r_v0   			),
	.r_pfn1   				(r_pfn1 			),
	.r_c1     				(r_c1   			),
	.r_d1     				(r_d1   			),
	.r_v1					(r_v1			    ),
    .r_mask                 (r_mask             )
	);
    
endmodule