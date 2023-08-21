`include "lib/defines.v"

module regfile(
    input         clk,
    input         reset,
    input  [ 4:0] read_addr1,
    output [31:0] read_data1,
    input  [ 4:0] read_addr2,
    output [31:0] read_data2,
    input  [3:0]  write_en,       //HIGH valid
    input  [ 4:0] write_addr,
    input  [31:0] write_data
    `ifdef VERILATOR
    ,
    output [31:0] GPR [31:0]
    `endif
);

reg [31:0] reg_array [31:0];

`ifdef VERILATOR
    assign GPR = reg_array;
`endif

//judge write_addr!=5'b0
wire write_reg_valid;
assign write_reg_valid =    (write_addr[4] | write_addr[3]) |
                            (write_addr[2] | write_addr[1]) |
                            write_addr[0];

//judge read_addr1 != 5'b0
wire read_addr1_valid;
assign read_addr1_valid =   (read_addr1[4] | read_addr1[3]) |
                            (read_addr1[2] | read_addr1[1]) |
                            read_addr1[0];

//judge read_addr2 != 5'b0
wire read_addr2_valid;
assign read_addr2_valid =   (read_addr2[4] | read_addr2[3]) |
                            (read_addr2[2] | read_addr2[1]) |
                            read_addr2[0];

//写寄存器
integer i;
always @(posedge clk) begin
    if(reset)
    for(i = 0; i<32; i=i+1)
        reg_array[i] <= 32'b0;
    else if (write_reg_valid) begin
        if(write_en[1])
            reg_array[write_addr][15: 8] <= write_data[15: 8];
        if(write_en[2])
            reg_array[write_addr][23:16] <= write_data[23:16];
        if(write_en[0])
            reg_array[write_addr][ 7: 0] <= write_data[ 7: 0];
        if(write_en[3])
            reg_array[write_addr][31:24] <= write_data[31:24];
    end
end 

//读寄存器
assign read_data1 = read_addr1_valid ? reg_array[read_addr1] : 32'b0;
assign read_data2 = read_addr2_valid ? reg_array[read_addr2] : 32'b0;

endmodule