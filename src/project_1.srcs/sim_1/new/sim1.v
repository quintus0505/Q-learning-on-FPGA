`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/07 10:10:12
// Design Name: 
// Module Name: sim1
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


module sim1( );
reg button, clk;
top simtop(.rst(button),.clk(clk));
initial clk = 0;
always #1 clk = ~clk;
initial 
    begin
        button=0;
        #20 button=1;
        #1000000000$finish;
    end
endmodule
