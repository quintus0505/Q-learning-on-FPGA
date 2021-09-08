`timescale 1s/0.1s
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/10 20:34:22
// Design Name: 
// Module Name: sim2
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


module sim2();
reg clk;
reg button;
top sm(.clk(clk),.start(button));
initial clk = 0;
always #1 clk = ~clk;
initial 
    begin
        button=0;
        #20 button=1;
        #10000$finish;
    end
endmodule
