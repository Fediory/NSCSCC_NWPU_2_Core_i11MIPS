module decoder(
        input  [31:0]   inst,

        output [31:0]   imm32i,
        output [31:0]   sa32,
        output [25:0]   instr_index,
        output [5:0]    Op,
        output [5:0]    func,
        output [4:0]    rs,
        output [4:0]    rt,
        output [4:0]    rd,
        output [4:0]    sa,
        output [15:0]   imm16,
	    output [31:0]   imm32s,
	    output [31:0]   imm32l,
        output [2:0]    sel
    );
    
	assign imm32s = {{16{imm16[15]}},imm16[15:0]};
	
	assign imm32l = {{16{1'b0}},imm16[15:0]};

    assign imm32i = {{14{imm16[15]}},imm16,2'b00};
     
    assign sa32 = {{27{1'b0}},sa};
    
    assign instr_index = inst[25:0];
    
    assign Op = inst[31:26];
    
    assign func = inst[5:0];

    assign rs = inst[25:21];

    assign rt = inst[20:16];
    
    assign rd = inst[15:11];
    
    assign sa = inst[10:6];
    
    assign imm16 = inst[15:0];

    assign sel = inst[2:0];
endmodule
