`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/11 22:34:23
// Design Name: 
// Module Name: random_num
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module random_num(
    input rst,    
    input clk,      /*clock signal*/
    input [7:0]seed,     
    output reg [7:0] rand_num  /*random number output*/
);

initial rand_num=seed;

always@(posedge clk)
begin
            rand_num[0] <= rand_num[7];
            rand_num[1] <= rand_num[28];
            rand_num[2] <= rand_num[12]^rand_num[23];
            rand_num[3] <= rand_num[9];
            rand_num[4] <= rand_num[3];
            rand_num[5] <= rand_num[5]^rand_num[31];
            rand_num[6] <= rand_num[14]^rand_num[19];
            rand_num[7] <= rand_num[30]^rand_num[8];    
            rand_num[8] <= rand_num[0];
            rand_num[9] <= rand_num[19]^rand_num[25];
            rand_num[10] <= rand_num[7];
            rand_num[11] <= rand_num[28];
            rand_num[12] <= rand_num[12]^rand_num[1];
            rand_num[13] <= rand_num[9]^rand_num[29];
            rand_num[14] <= rand_num[3];
            rand_num[15] <= rand_num[5];
            rand_num[16] <= rand_num[14]^rand_num[6];
            rand_num[17] <= rand_num[30];    
            rand_num[18] <= rand_num[0]^rand_num[11];
            rand_num[19] <= rand_num[19]^rand_num[26];  
            rand_num[20] <= rand_num[17]^rand_num[31];
            rand_num[21] <= rand_num[18];
            rand_num[22] <= rand_num[22]^rand_num[23];
            rand_num[23] <= rand_num[29];
            rand_num[24] <= rand_num[30];
            rand_num[25] <= rand_num[28];
            rand_num[26] <= rand_num[3]^rand_num[23];
            rand_num[27] <= rand_num[17]^rand_num[2];    
            rand_num[28] <= rand_num[5];
            rand_num[29] <= rand_num[28]^rand_num[15];
            rand_num[30] <= rand_num[17];
            rand_num[31] <= rand_num[29];       
end
endmodule
