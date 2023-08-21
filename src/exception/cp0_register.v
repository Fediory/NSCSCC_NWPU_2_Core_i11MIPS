`include "cp0_defines.v"
`include "../tlb/tlb_defines.v"

module cp0_register(
    input clk                 ,
    input reset               ,
    input eret_flush          ,
    input [`WR_to_cp0_bus-1:0]  WR_to_cp0_bus,
   
    input [5:0]  ext_int_in,

    input         ID_int_hazard,
    input         EXE_int_hazard,
    input         MEM_int_hazard,
    input         WR_int_hazard,

    input              tlbp_write_en,
    input              tlbr_write_en,
    input [31:0]       tlbp_result,

    input [`VPN2_WD]   tlbr_vpn2,
    input [`ASID_WD]   tlbr_asid,
    input              tlbr_g,
    input [`PFN_WD]    tlbr_pfn0,
    input [`C_WD]      tlbr_c0,
    input              tlbr_d0,
    input              tlbr_v0,
    input [`PFN_WD]    tlbr_pfn1,
    input [`C_WD]      tlbr_c1,
    input              tlbr_d1,
    input              tlbr_v1,
    input [15:0]       tlbr_mask,

    output [`TLB_WD]     tlb_index,
    output               tlb_p,
    output [`TLB_WD]     tlb_random,
 
    output [`VPN2_WD]    tlbwi_vpn2,
    output [`ASID_WD]    tlbwi_asid,
    output               tlbwi_g,
    output [`PFN_WD]     tlbwi_pfn0,
    output [`C_WD]       tlbwi_c0,
    output               tlbwi_d0,
    output               tlbwi_v0,
    output [`PFN_WD]     tlbwi_pfn1,
    output [`C_WD]       tlbwi_c1,
    output               tlbwi_d1,
    output               tlbwi_v1,
    output [15:0]        tlbwi_mask,
    
    output [`VPN2_WD]    tlbp_vpn2,
    output [`ASID_WD]    tlbp_asid,
    

    output[31:0]         cp0_output_data,
    output[31:0]         WR_EPC_info,
    output               has_int,

    output[`ASID_WD]    s0_asid,
    output[`ASID_WD]    s1_asid,
    output[31:0    ]    ex_addr,

    output [2:0]         config_k0,
    output [31:0]        TagLo
    );
    //数据
    wire        op_mfc0      ;
    wire        is_ex        ;
    wire        WR_valid     ;
    wire        WR_bd        ;
    wire [`EX_CLASS-1:0] exception_class;
    wire [7:0]  cp0_addr     ;
    wire [31:0] cp0_next_data;
    wire [31:0] WR_pc;
    wire [4:0]  exception_excode;
    wire [31:0] WR_badvaddr;
    wire        count_eq_compare;
    wire        WR_bd_to_cp0;
    //异常分类
    assign{
      WR_bd,//126
      WR_badvaddr,//125
      WR_bd_to_cp0,//93
      WR_pc,//92
      exception_class,//60
      is_ex,//43
      op_mfc0,//42
      cp0_addr,//41
      WR_valid,//33
      cp0_next_data//32
    } = WR_to_cp0_bus;

    //译码
    wire reg_Status;
    wire reg_Cause ;
    wire reg_EPC   ;
    wire reg_Count ;
    wire reg_Compare;
    wire reg_Badvaddr;
    wire reg_Index;
    wire reg_EnrtyLo0;
    wire reg_EnrtyLo1;
    wire reg_EnrtyHi;
    wire reg_PRID;
    wire reg_ebase;
    wire reg_config;
    wire reg_config1;
    wire reg_random;
    wire reg_wired;
    wire reg_pagemask;
    wire reg_context;
    wire reg_TagLo;

    assign reg_Status   = (cp0_addr   == 8'b01100_000);
    assign reg_Cause    = (cp0_addr   == 8'b01101_000);
    assign reg_EPC      = (cp0_addr   == 8'b01110_000);
    assign reg_Count    = (cp0_addr   == 8'b01001_000);
    assign reg_Compare  = (cp0_addr   == 8'b01011_000);
    assign reg_Badvaddr = (cp0_addr   == 8'b01000_000);
    assign reg_Index    = (cp0_addr   == 8'b00000_000);
    assign reg_EnrtyLo0 = (cp0_addr   == 8'b00010_000);
    assign reg_EnrtyLo1 = (cp0_addr   == 8'b00011_000);
    assign reg_EnrtyHi  = (cp0_addr   == 8'b01010_000);
    assign reg_PRID     = (cp0_addr   == 8'b01111_000);
    assign reg_random   = (cp0_addr   == 8'b00001_000);
    assign reg_ebase    = (cp0_addr   == 8'b01111_001);
    assign reg_config   = (cp0_addr   == 8'b10000_000);
    assign reg_config1  = (cp0_addr   == 8'b10000_001);
    assign reg_wired    = (cp0_addr   == 8'b00110_000);
    assign reg_pagemask = (cp0_addr   == 8'b00101_000);
    assign reg_context  = (cp0_addr   == 8'b00100_000);
    assign reg_TagLo    = (cp0_addr   == 8'b11100_000);


    //异常识别
    wire exception_ADEL_if;
    wire exception_ADEL_mem;
    wire exception_overflow;
    wire exception_syscall;
    wire exception_break;
    wire exception_reserved_inst;
    wire exception_ADES;
    wire exception_int;
    wire exception_TLB_refill_if     ;
    wire exception_TLB_refill_data_L ;
    wire exception_TLB_refill_data_S ;
    wire exception_TLB_invalid_if    ;
    wire exception_TLB_invalid_data_L;
    wire exception_TLB_invalid_data_S;
    wire exception_TLB_mod           ;
    wire exception_TLB               ;
    wire exception_trap              ;
    wire exception_cpU               ;
  
    assign exception_syscall            = exception_class[0];
    assign exception_break              = exception_class[1];
    assign exception_overflow           = exception_class[2];
    assign exception_ADEL_if            = exception_class[3];
    assign exception_ADEL_mem           = exception_class[4];
    assign exception_ADES               = exception_class[5];
    assign exception_reserved_inst      = exception_class[6];
    assign exception_int                = exception_class[7];
    assign exception_TLB_refill_if      = exception_class[8];
    assign exception_TLB_refill_data_L  = exception_class[9];
    assign exception_TLB_refill_data_S  = exception_class[10];
    assign exception_TLB_invalid_if     = exception_class[11];
    assign exception_TLB_invalid_data_L = exception_class[12];
    assign exception_TLB_invalid_data_S = exception_class[13];
    assign exception_TLB_mod            = exception_class[14];
    assign exception_trap               = exception_class[15];
    assign exception_cpU                = exception_class[16];
    assign exception_TLB                = exception_TLB_refill_if |
                                          exception_TLB_refill_data_L|
                                          exception_TLB_refill_data_S|
                                          exception_TLB_invalid_if |
                                          exception_TLB_invalid_data_L|
                                          exception_TLB_invalid_data_S|
                                          exception_TLB_mod;
    //EXcode确定  
    assign exception_excode =  (exception_int)                ? 5'b00000:
                               (exception_ADEL_if)            ? 5'b00100:
                               (exception_TLB_refill_if)      ? 5'b00010:
                               (exception_TLB_invalid_if)     ? 5'b00010:
                               (exception_syscall)            ? 5'b01000:
                               (exception_break)              ? 5'b01001:
                               (exception_cpU  )              ? 5'b01011:
                               (exception_reserved_inst)      ? 5'b01010:
                               (exception_overflow)           ? 5'b01100:
                               (exception_trap    )           ? 5'b01101:
                               (exception_ADEL_mem)           ? 5'b00100:
                               (exception_ADES)               ? 5'b00101:
                               (exception_TLB_refill_data_L)  ? 5'b00010:
                               (exception_TLB_refill_data_S)  ? 5'b00011:
                               (exception_TLB_invalid_data_L) ? 5'b00010:
                               (exception_TLB_invalid_data_S) ? 5'b00011:
                               (exception_TLB_mod           ) ? 5'b00001:
                               5'b11111;
    //TLB异常处理
    wire is_TLB_refill,is_TLB_IF_refill,is_TLB_MEM_refill;
    assign is_TLB_refill = is_TLB_IF_refill | is_TLB_MEM_refill;
    assign is_TLB_IF_refill = !(exception_int) && !(exception_ADEL_if) && exception_TLB_refill_if;
    assign is_TLB_MEM_refill = !(exception_int) && !(exception_ADEL_if) && !exception_TLB_refill_if && !(exception_TLB_invalid_if) && 
                               !(exception_syscall) && !(exception_break) && !(exception_reserved_inst) && !(exception_overflow) && 
                               !(exception_ADEL_mem) && !(exception_ADES) && (exception_TLB_refill_data_L | exception_TLB_refill_data_S);
    //mfc0写使能
    wire mtc0_write_en;
    assign mtc0_write_en = WR_valid & op_mfc0 & !is_ex;
    //异常入口地址分配
    wire bev = cp0_status_bev;
    wire exl = cp0_status_exl;
    wire iv  = cp0_cause_iv;
    //wire [31:0] addr_miss     = {32{!bev&&!exl}} & `ADDR_REFILL
    //                          | {32{!bev&& exl}} & `ADDR_REFILL_EXL
    //                          | {32{ bev&&!exl}} & `ADDR_REFILL_BEV
    //                          | {32{ bev&& exl}} & `ADDR_REFILL_BEV_EXL;
    //wire [31:0] addr_intr     = {32{!bev&&!iv }} & `ADDR_INTR
    //                          | {32{!bev&& iv }} & `ADDR_INTR_IV
    //                          | {32{ bev&&!iv }} & `ADDR_INTR_BEV
    //                          | {32{ bev&& iv }} & `ADDR_INTR_BEV_IV;
    //wire [31:0] addr_other    = {32{!bev      }} & `ADDR_OTHER
    //                            | {32{ bev      }} & `ADDR_OTHER_BEV;
//
    //assign ex_addr = (has_int)       ? addr_intr:
    //                 (is_TLB_refill) ? addr_miss:
    //                                   addr_other;
    //ebase异常处理入口分配
    wire [31:0] ex_addr_base;
    reg  [31:0] ex_addr_offset;

    assign ex_addr_base   = (bev)           ? 32'hbfc00200 : cp0_ebase;
    always @(*) begin
      if(is_TLB_refill && !exl)
        ex_addr_offset = 32'h0;
      else if(has_int && iv) 
        ex_addr_offset = 32'h0000_0200;
      else              
        ex_addr_offset = 32'h0000_0180;
    end

    assign ex_addr = ex_addr_offset + ex_addr_base;
    //config寄存器
    wire          cp0_config_M;
    wire          cp0_config_be;
    wire[1:0]     cp0_config_at;
    wire[2:0]     cp0_config_ar;
    wire[2:0]     cp0_config_mt;
    reg [2:0]     cp0_config_k0;
    wire[31:0]         cp0_config;

    assign  cp0_config_M = 1'b1;
    assign  cp0_config_be = 1'b0;
    assign  cp0_config_at = 2'b0;
    assign  cp0_config_ar = 3'b0;
    assign  cp0_config_mt = 3'b1;
    
    always@(posedge clk)
      if(reset)
         cp0_config_k0 <= 3'h3;
      else if(mtc0_write_en && reg_config)
         cp0_config_k0 <= cp0_next_data[2:0];
       
    assign config_k0  = cp0_config_k0;
    assign cp0_config = {cp0_config_M,15'b0,cp0_config_be,cp0_config_at,cp0_config_ar,cp0_config_mt,4'b0,cp0_config_k0};
    //config1寄存器
    wire [31:0] cp0_config1;

    assign cp0_config1 = {
           1'b0,
           6'd7, // TLB entries = 16
           3'd2,
           3'd4,
           3'd1,
           3'd2,
           3'd4,
           3'd1,
           7'b0
       } ;     

    //EBase寄存器
    reg [31:0]  cp0_ebase;
    always @(posedge clk ) begin
      if(reset) 
          cp0_ebase <= 32'h8000_0000;
      else if(mtc0_write_en && reg_ebase)
          cp0_ebase[29:12] <= cp0_next_data[29:12];
    end
    //PRID寄存器
    reg [31:0] cp0_PRID /*verilator public*/;

    always@(posedge clk)
       if(reset)
        cp0_PRID <= 32'h0000_4220;

    //Status寄存器
    reg       cp0_status_bev;
    reg [7:0] cp0_status_im;
    reg       cp0_status_exl;
    reg       cp0_status_ie;
    reg       cp0_status_um;
    reg       cp0_status_erl; 
    reg       cp0_status_cu0; 
    wire[31:0]cp0_status  /*verilator public*/;
    always@(posedge clk)
      if(mtc0_write_en & reg_Status)
        cp0_status_cu0 <= cp0_next_data[28];

    always@(posedge clk)
      if(reset)
        cp0_status_bev <= 1'b1;
      else if(mtc0_write_en & reg_Status)
        cp0_status_bev <= cp0_next_data[22];

    always@(posedge clk)
      if(mtc0_write_en && reg_Status)
        cp0_status_im <= cp0_next_data[15:8];

    always @(posedge clk ) begin
      if(reset)
        cp0_status_um <= 1'b0;
      else if(mtc0_write_en & reg_Status) 
        cp0_status_um <= cp0_next_data[4];
    end

    // always @(posedge clk ) begin
    //   if(reset)
    //     cp0_status_erl <= 1'b1;
    //   else if(mtc0_write_en & reg_Status) 
    //     cp0_status_erl <= cp0_next_data[2];
    // end

    always@(posedge clk)
      if(reset)
        cp0_status_exl <= 1'b0;
      else if(is_ex && WR_valid) 
        cp0_status_exl <= 1'b1;
      else if(eret_flush)
        cp0_status_exl <= 1'b0;
      else if(mtc0_write_en & reg_Status)
        cp0_status_exl <= cp0_next_data[1];
      
    always@(posedge clk)
      if(reset)
       cp0_status_ie <= 1'b0;
      else if(mtc0_write_en & reg_Status) 
       cp0_status_ie <= cp0_next_data[0];   

    assign cp0_status = {3'b0,cp0_status_cu0,5'b0,cp0_status_bev,6'b0,cp0_status_im,3'b0,cp0_status_um,2'b0,cp0_status_exl,cp0_status_ie};
        
    //Cause寄存器
    reg [1:0]cp0_cause_ce;
    reg      cp0_cause_bd;
    reg      cp0_cause_ti;
    reg      cp0_cause_iv;
    reg [7:0]cp0_cause_ip;
    reg [4:0]cp0_cause_excode;
    wire [31:0] cp0_cause /*verilator public*/;

    always @(posedge clk ) begin
      if(reset)
       cp0_cause_ce <= 2'b0;
      else if(is_ex && exception_cpU)
       cp0_cause_ce <= 2'b1;
    end

    always@(posedge clk)
      if(reset) 
       cp0_cause_iv <= 1'b0;
      else if(mtc0_write_en && reg_Cause)
       cp0_cause_iv <= cp0_next_data[23];
    
    always@(posedge clk)
      if(reset)
        cp0_cause_bd <= 1'b0;
      else if(is_ex && !cp0_status_exl && WR_valid)
        cp0_cause_bd <= WR_bd_to_cp0;

    always@(posedge clk)
      if(reset)
        cp0_cause_ti <= 1'b0;
      else if(mtc0_write_en && reg_Compare)
        cp0_cause_ti <= 1'b0;
      else if(count_eq_compare)
        cp0_cause_ti <= 1'b1;

    always@(posedge clk)
      if(reset)
       cp0_cause_ip[7:2] <= 6'b0;
      else begin
       cp0_cause_ip[7] <= ext_int_in[5] | cp0_cause_ti;
       cp0_cause_ip[6:2] <= ext_int_in[4:0];
      end

    always@(posedge clk)
      if(reset)
       cp0_cause_ip[1:0] <= 2'b0;
      else if(mtc0_write_en && reg_Cause)
       cp0_cause_ip[1:0] <= cp0_next_data[9:8];

    always@(posedge clk)
      if(reset)
       cp0_cause_excode <= 5'b0;
      else if(is_ex && WR_valid)
       cp0_cause_excode <= exception_excode;

    assign cp0_cause = {cp0_cause_bd,cp0_cause_ti,cp0_cause_ce,4'b0,cp0_cause_iv,7'b0,cp0_cause_ip,1'b0,cp0_cause_excode,2'b0};

    //EPC寄存器
    reg [31:0] cp0_epc /*verilator public*/;
    always@(posedge clk)
      if(is_ex && !cp0_status_exl)
         cp0_epc <= WR_pc;
      else if(mtc0_write_en && reg_EPC)
         cp0_epc <= cp0_next_data;
    
    //BadVaddr寄存器
    reg [31:0] cp0_badvaddr;
    always@(posedge clk)
     if(WR_valid && is_ex && (exception_TLB |exception_ADEL_if | exception_ADEL_mem | exception_ADES))
       cp0_badvaddr <= WR_badvaddr;

    //count寄存器
    reg [31:0] cp0_count;
    reg        tick;

    always@(posedge clk)
      if(reset)
         tick <= 1'b0;
      else 
         tick <= ~tick;

    always@(posedge clk)
     if(reset)
        cp0_count <= 0;
     else if(mtc0_write_en && reg_Count) 
        cp0_count <= cp0_next_data;
     else if(tick)
        cp0_count <= cp0_count + 32'b1;

    //compare寄存器
    reg [31:0] cp0_Compare;
    always@(posedge clk)
     if(mtc0_write_en && reg_Compare)
       cp0_Compare <= cp0_next_data;

    //timer_int
      
   //=================cache================
    //TagLo寄存器
    reg [31:0] cp0_TagLo;

    always @(posedge clk ) begin
        if (reset) begin
           cp0_TagLo <= 32'b0;
        end
        else if(mtc0_write_en && reg_TagLo)
           cp0_TagLo <= cp0_next_data;
    end

    assign TagLo = cp0_TagLo;
    //=================TLB==================

    //tlbwi：将EntryHi、EntryLo中 记录的页表项内容写入Index域所指的那一项
    //tlbr：读出Index域中内容，写入EntryHi、EntryLo中
    //tlbp：使用EntryHi中的信息查询TLB。找到则Index写入，且p=0；否则p=1，Index任意。
    //tlbp与tlbr均写入cp0寄存器中，tlbwi写入tlb中
    //context
    reg [8:0]  cp0_context_ptebase;
    reg [18:0] cp0_context_badvpn2;
    
    wire [31:0] context = {
        cp0_context_ptebase, // 31:23
        cp0_context_badvpn2, // 22:4
        4'd0
    };
    
    always @(posedge clk) begin
        // PTEBase
        if(reset)                              cp0_context_ptebase <= 0;
        else if (mtc0_write_en && reg_context) cp0_context_ptebase <= cp0_next_data[31:23];
        // BadVPN2
        if(reset)                              cp0_context_badvpn2 <= 0;
        else if (WR_valid && is_ex && (exception_TLB |exception_ADEL_if | exception_ADEL_mem | exception_ADES)) cp0_context_badvpn2 <= WR_badvaddr[31:13];
    end
    //pagemark
    reg [11:0] cp0_pagemask_mask;
    wire[31:0] cp0_Pagemask;

    always @(posedge clk ) begin
         if(reset)
              cp0_pagemask_mask <= 0;
        //  else if(tlbr_write_en) 
              // cp0_pagemask_mask <= tlbr_mask;
        //  else if(mtc0_write_en && reg_pagemask)
              // cp0_pagemask_mask <= cp0_next_data[28:13];
    end
    assign cp0_Pagemask = {
        3'b0,
        cp0_pagemask_mask,
        13'b0
    };
    //Wired
    reg [`TLB_WD] cp0_Wired_wired;
    wire [31:0]   cp0_Wired = cp0_Wired_wired;
    always @(posedge clk ) begin
        if(reset) 
            cp0_Wired_wired <= 32'b0;
        else if(mtc0_write_en && reg_wired)
            cp0_Wired_wired <= cp0_next_data[`TLB_WD];
    end

    //Random
    reg  [`TLB_WD] cp0_Random_random;
    wire [31:0]    cp0_Random = {29'b0, cp0_Random_random};
    wire [`TLB_WD] next_random = cp0_Random_random + 1;
    assign tlb_random = cp0_Random_random;
    always @(posedge clk) begin
      if(reset || (mtc0_write_en && reg_wired))
           cp0_Random_random <= `TLBNUM - 1;
      else if(tlbr_write_en)
          cp0_Random_random <= (next_random < cp0_Wired_wired) ? cp0_Wired_wired : next_random;
      else 
          cp0_Random_random <= next_random;
    end


    //Index寄存器
    reg          cp0_Index_P;
    reg [`TLB_WD]    cp0_Index_index; 
    reg [31:0]   cp0_Index;

    always@(posedge clk)
      if(reset)
        cp0_Index_P <= 1'b0;
      else if(tlbp_write_en)
        cp0_Index_P <= tlbp_result[31];

    always@(posedge clk)
      if(reset)
        cp0_Index_index <= 4'b0;
      else if(mtc0_write_en && reg_Index)
        cp0_Index_index <= cp0_next_data[`TLB_WD];
      else if(tlbp_write_en)
        cp0_Index_index <= tlbp_result[`TLB_WD];

    always@(*)
      begin
        cp0_Index[`TLB_WD]  = cp0_Index_index;
        cp0_Index[30:`TLB_WT] = 28'b0;
        cp0_Index[31]   = cp0_Index_P;
      end


   //EntryHi寄存器
   reg [18:0]   cp0_EntryHi_VPN2;
   reg [7:0]    cp0_EntryHi_ASID;
   reg [31:0]   cp0_EntryHi;
   
  //asid
  assign s0_asid = cp0_EntryHi_ASID;
  assign s1_asid = cp0_EntryHi_ASID;

  always@(posedge clk)
    if(reset)
      cp0_EntryHi_VPN2 <= 19'b0;
    else if(mtc0_write_en && reg_EnrtyHi)
      cp0_EntryHi_VPN2 <= cp0_next_data[31:13];
    else if(is_ex && WR_valid && exception_TLB)
      cp0_EntryHi_VPN2 <= WR_badvaddr[31:13];
    else if(tlbr_write_en)
      cp0_EntryHi_VPN2 <= tlbr_vpn2;

  always@(posedge clk)
    if(reset)
      cp0_EntryHi_ASID <= 8'b0;
    else if(mtc0_write_en && reg_EnrtyHi)
      cp0_EntryHi_ASID <= cp0_next_data[7:0];
    else if(tlbr_write_en)
      cp0_EntryHi_ASID <= tlbr_asid;

  always@(*)
    begin
      cp0_EntryHi[31:13] = cp0_EntryHi_VPN2;
      cp0_EntryHi[12:8]  = 5'b0;
      cp0_EntryHi[7:0]   = cp0_EntryHi_ASID;
    end
  

   //EntryLo0寄存器
  reg [19:0]   cp0_EntryLo0_PFN0;
  reg [2:0]    cp0_EntryLo0_C0;
  reg          cp0_EntryLo0_D0;
  reg          cp0_EntryLo0_V0;
  reg          cp0_EntryLo0_G0;
  reg [31:0]   cp0_EntryLo0;

  always@(*)
    begin
      cp0_EntryLo0[31:26] = 6'b0;
      cp0_EntryLo0[25:6]  = cp0_EntryLo0_PFN0;
      cp0_EntryLo0[5:3]   = cp0_EntryLo0_C0;
      cp0_EntryLo0[2]     = cp0_EntryLo0_D0;
      cp0_EntryLo0[1]     = cp0_EntryLo0_V0;
      cp0_EntryLo0[0]     = cp0_EntryLo0_G0;
    end

  always@(posedge clk)
    if(reset)
      cp0_EntryLo0_PFN0 <= 20'b0;
    else if(mtc0_write_en && reg_EnrtyLo0)
      cp0_EntryLo0_PFN0 <= cp0_next_data[25:6];
    else if(tlbr_write_en)
      cp0_EntryLo0_PFN0 <= tlbr_pfn0;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo0_C0 <= 3'b0;
    else if(mtc0_write_en && reg_EnrtyLo0)
      cp0_EntryLo0_C0 <= cp0_next_data[5:3];
    else if(tlbr_write_en)
      cp0_EntryLo0_C0 <= tlbr_c0;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo0_D0 <= 1'b0;
    else if(mtc0_write_en && reg_EnrtyLo0)
      cp0_EntryLo0_D0 <= cp0_next_data[2];
    else if(tlbr_write_en)
      cp0_EntryLo0_D0 <= tlbr_d0;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo0_V0 <= 1'b0;
    else if(mtc0_write_en && reg_EnrtyLo0)
      cp0_EntryLo0_V0 <= cp0_next_data[1];
    else if(tlbr_write_en)
      cp0_EntryLo0_V0 <= tlbr_v0;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo0_G0 <= 1'b0;
    else if(mtc0_write_en && reg_EnrtyLo0)
      cp0_EntryLo0_G0 <= cp0_next_data[0];
    else if(tlbr_write_en)
      cp0_EntryLo0_G0 <= tlbr_g;

   //EntryLo1寄存器
   reg [19:0]   cp0_EntryLo1_PFN1;
   reg [5:3]    cp0_EntryLo1_C1;
   reg          cp0_EntryLo1_D1;
   reg          cp0_EntryLo1_V1;
   reg          cp0_EntryLo1_G1;
   reg [31:0]   cp0_EntryLo1;

  always@(*)
  begin
    cp0_EntryLo1[31:26] = 6'b0;
    cp0_EntryLo1[25:6]  = cp0_EntryLo1_PFN1;
    cp0_EntryLo1[5:3]   = cp0_EntryLo1_C1;
    cp0_EntryLo1[2]     = cp0_EntryLo1_D1;
    cp0_EntryLo1[1]     = cp0_EntryLo1_V1;
    cp0_EntryLo1[0]     = cp0_EntryLo1_G1;
  end

  always@(posedge clk)
    if(reset)
      cp0_EntryLo1_PFN1 <= 20'b0;
    else if(mtc0_write_en && reg_EnrtyLo1)
      cp0_EntryLo1_PFN1 <= cp0_next_data[25:6];
    else if(tlbr_write_en)
      cp0_EntryLo1_PFN1 <= tlbr_pfn1;//

  always@(posedge clk)
    if(reset)
      cp0_EntryLo1_C1 <= 3'b0;
    else if(mtc0_write_en && reg_EnrtyLo1)
      cp0_EntryLo1_C1 <= cp0_next_data[5:3];
    else if(tlbr_write_en)
      cp0_EntryLo1_C1 <= tlbr_c1;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo1_D1 <= 1'b0;
    else if(mtc0_write_en && reg_EnrtyLo1)
      cp0_EntryLo1_D1 <= cp0_next_data[2];
    else if(tlbr_write_en)
      cp0_EntryLo1_D1 <= tlbr_d1;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo1_V1 <= 1'b0;
    else if(mtc0_write_en && reg_EnrtyLo1)
      cp0_EntryLo1_V1 <= cp0_next_data[1];
    else if(tlbr_write_en)
      cp0_EntryLo1_V1 <= tlbr_v1;

  always@(posedge clk)
    if(reset)
      cp0_EntryLo1_G1 <= 1'b0;
    else if(mtc0_write_en && reg_EnrtyLo1)
      cp0_EntryLo1_G1 <= cp0_next_data[0];
    else if(tlbr_write_en)
      cp0_EntryLo1_G1 <= tlbr_g;

    //cp0寄存器输出

    assign cp0_output_data = ({32{reg_Cause}}     & cp0_cause      ) | 
                             ({32{reg_Status}}    & cp0_status     ) |
                             ({32{reg_EPC}}       & cp0_epc        ) |
                             ({32{reg_Count}}     & cp0_count      ) |
                             ({32{reg_Compare}}   & cp0_Compare    ) |
                             ({32{reg_Badvaddr}}  & cp0_badvaddr   ) |
                             ({32{reg_Index}}     & cp0_Index      ) |
                             ({32{reg_EnrtyHi}}   & cp0_EntryHi    ) |
                             ({32{reg_EnrtyLo0}}  & cp0_EntryLo0   ) |
                             ({32{reg_EnrtyLo1}}  & cp0_EntryLo1   ) |
                             ({32{reg_PRID}}      & cp0_PRID       ) |
                             ({32{reg_config}}    & cp0_config     ) |
                             ({32{reg_config1}}   & cp0_config1    ) |
                             ({32{reg_TagLo}}     & cp0_TagLo      ) |
                             ({32{reg_random}}    & cp0_Random     ) |
                             ({32{reg_wired}}     & cp0_Wired      ) |
                             ({32{reg_pagemask}}  & cp0_Pagemask   ) |
                             ({32{reg_context}}   & context        ) |
                             ({32{reg_ebase}}     & cp0_ebase      ) 
                             ;
     //cp0_TLB部分输出
    assign tlb_p      = cp0_Index_P;
    assign tlb_index  = cp0_Index_index;
    assign tlbwi_vpn2 = cp0_EntryHi_VPN2;
    assign tlbwi_asid = cp0_EntryHi_ASID;
    assign tlbwi_g    = cp0_EntryLo0_G0 && cp0_EntryLo1_G1;
    assign tlbwi_pfn0 = cp0_EntryLo0_PFN0;
    assign tlbwi_c0   = cp0_EntryLo0_C0;
    assign tlbwi_d0   = cp0_EntryLo0_D0;
    assign tlbwi_v0   = cp0_EntryLo0_V0;
    assign tlbwi_pfn1 = cp0_EntryLo1_PFN1;
    assign tlbwi_c1   = cp0_EntryLo1_C1;
    assign tlbwi_d1   = cp0_EntryLo1_D1;
    assign tlbwi_v1   = cp0_EntryLo1_V1;
    assign tlbp_vpn2  = cp0_EntryHi_VPN2;
    assign tlbp_asid  = cp0_EntryHi_ASID;
    assign tlbwi_mask = cp0_pagemask_mask;
      //count与compare比较

    assign count_eq_compare = (cp0_Compare == cp0_count);
    assign WR_EPC_info = cp0_epc;

    //中断
    assign has_int = ((cp0_cause_ip & cp0_status_im)!=8'h00) && cp0_status_ie && !cp0_status_exl;
    //中断冲突处理
    
endmodule
