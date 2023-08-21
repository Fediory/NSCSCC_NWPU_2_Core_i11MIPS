module hi_lo(
    input clk,
    input reset,
    input [31:0] hi_upgrade,
    input [31:0] lo_upgrade,
    input hi_ctr_write,
    input lo_ctr_write,
    output reg [31:0] hi_data,
    output reg [31:0] lo_data
    );

    always@(posedge clk)
     if(reset)
      hi_data <= 32'b0;
     else if(hi_ctr_write)
      hi_data <= hi_upgrade;
    
    always@(posedge clk)
     if(reset)
      lo_data <= 32'b0;
     else if(lo_ctr_write)
      lo_data <= lo_upgrade;

endmodule
