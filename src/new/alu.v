module alu(
        input  [11:0] alu_control,
        input  [31:0] alu_src1,
        input  [31:0] alu_src2,
        output [31:0] alu_result,
        output        alu_overflow,
        output        adder_cout,
        output        trap_lt,
        output        trap_ltu,
        output        trap_ge,
        output        trap_geu,
        output        trap_eq,
        output        trap_neq
    );
    wire op_add;
    wire op_sub;
    wire op_and;
    // wire op_mult;
    wire op_or;
    wire op_xor;
    wire op_sll;
    wire op_srl;
    wire op_sra;
    wire op_slt;
    wire op_lui;
	wire op_sltu;
    wire op_nor;
    
    assign op_add = alu_control[0];
     
    assign op_sub = alu_control[1];
     
    assign op_and = alu_control[2];

    assign op_or = alu_control[3];

    assign op_xor = alu_control[4];
     
    assign op_sll = alu_control[5];
      
    assign op_srl = alu_control[6];
      
    assign op_sra = alu_control[7];
      
    assign op_slt = alu_control[8];
  
    assign op_lui = alu_control[9];
	
	assign op_sltu = alu_control[10];
	
	assign op_nor = alu_control[11];
      
      wire [31:0] add_sub_result;
      wire[31:0] and_result;
      wire[31:0] or_result;
      wire[31:0] xor_result;
      wire [31:0] sll_result;
      wire [31:0] srl_result;
      wire [31:0] sra_result;
      wire[31:0] slt_result;
      wire [31:0] lui_result;
	  wire [31:0] sltu_result;
	  wire [31:0] nor_result;
      
	  //assign mult_pro = $signed(alu_src1) * $signed(alu_src2);
	  //assign mult_result = mult_pro[31:0];
      assign lui_result = {alu_src2[15:0],16'b0};
      assign and_result = alu_src1 & alu_src2;
      assign or_result = alu_src1 | alu_src2;
      assign xor_result = alu_src1 ^ alu_src2;
	  assign nor_result = ~or_result;
       
      wire [31:0] adder_a;
      wire [31:0] adder_b;
      wire [31:0] adder_result;
      wire adder_cin;
      

      assign adder_a = alu_src1;
      assign adder_b = (op_sub | op_slt|op_sltu) ? ~(alu_src2):alu_src2;
	  assign adder_cin =(op_sub | op_slt|op_sltu )? 1'b1:1'b0;
	  assign {adder_cout,adder_result}=adder_a+adder_b+adder_cin;
      assign  add_sub_result = adder_result;
         
	assign slt_result[31:1] = 31'b0;
	assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31])
                        | (~(alu_src1[31] ^ alu_src2[31]) & adder_result[31]);
						
	assign sltu_result[31:1] = 31'b0;
    assign sltu_result[0]    = ~adder_cout;
         
       
       
       wire [31:0] shift_src = op_sll ? {
        alu_src2[0],    alu_src2[1],    alu_src2[2],    alu_src2[3], 
        alu_src2[4],    alu_src2[5],    alu_src2[6],    alu_src2[7],
        alu_src2[8],    alu_src2[9],    alu_src2[10],   alu_src2[11],   
        alu_src2[12],   alu_src2[13],   alu_src2[14],   alu_src2[15],   
        alu_src2[16],   alu_src2[17],   alu_src2[18],   alu_src2[19], 
        alu_src2[20],   alu_src2[21],   alu_src2[22],   alu_src2[23], 
        alu_src2[24],   alu_src2[25],   alu_src2[26],   alu_src2[27],
        alu_src2[28],   alu_src2[29],   alu_src2[30],   alu_src2[31]  
       } : alu_src2;
       wire [31:0] shift_result = shift_src >> alu_src1[4:0];
       wire [31:0] sra_mask = ~(32'hffff_ffff >> alu_src1[4:0]);
       assign srl_result = shift_result;
       assign sra_result = ({32{alu_src2[31]}} & sra_mask) | shift_result;
       assign sll_result = 
       {
        shift_result[0],    shift_result[1],    shift_result[2],    shift_result[3], 
        shift_result[4],    shift_result[5],    shift_result[6],    shift_result[7],
        shift_result[8],    shift_result[9],    shift_result[10],   shift_result[11],   
        shift_result[12],   shift_result[13],   shift_result[14],   shift_result[15],   
        shift_result[16],   shift_result[17],   shift_result[18],   shift_result[19], 
        shift_result[20],   shift_result[21],   shift_result[22],   shift_result[23], 
        shift_result[24],   shift_result[25],   shift_result[26],   shift_result[27],
        shift_result[28],   shift_result[29],   shift_result[30],   shift_result[31]  
       };

       
        
       assign alu_result = ({32{op_add|op_sub}} & add_sub_result)
                        |  ({32{op_slt       }} & slt_result)
                        |  ({32{op_and       }} & and_result)
                        |  ({32{op_or        }} & or_result)
                        |  ({32{op_xor       }} & xor_result)
                        |  ({32{op_lui       }} & lui_result)
                        |  ({32{op_sll       }} & sll_result)
                        |  ({32{op_srl       }} & srl_result)
				        |  ({32{op_sra       }} & sra_result)
				        |  ({32{op_sltu      }} & sltu_result)
				        |  ({32{op_nor       }} & nor_result);

      assign alu_overflow = (op_add & alu_src1[31] & alu_src2[31] & !alu_result[31]) |
                            (op_add & !alu_src1[31] & !alu_src2[31] & alu_result[31]) |
                            (op_sub & !alu_src1[31] & alu_src2[31] & alu_result[31]) | 
                            (op_sub & alu_src1[31] & !alu_src2[31] & !alu_result[31]) ; 

      assign trap_ge  = !trap_lt;
      assign trap_geu = !trap_ltu;
      assign trap_lt  = slt_result[0];
      assign trap_ltu = sltu_result[0];
      assign trap_eq  = alu_src1 == alu_src2;
      assign trap_neq = ~trap_eq;
endmodule
