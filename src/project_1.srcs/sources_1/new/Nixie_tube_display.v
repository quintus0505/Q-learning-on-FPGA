`timescale 1s/0.1s
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/08 23:21:32
// Design Name: 
// Module Name: Nixie_tube_display
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


module state_display(
input clk,
input [3:0] state,    
input [9:0] episode,
input [6:0] success,  
input [1:0] action,     
output  wire [7:0]id_out,    //数码管地址
output  wire [7:0]seg    //数码显现
    );
reg [7:0]seg_;
reg [31:0] cnt,cnt2;   //计数
reg [3:0] in;         //用于输入寄存器
wire pulse_1000hz;    //分频千分之一
wire pulse_200hz;     //分频两百分之一
reg [3:0] episode_1,episode_2,episode_3,success_1,success_2;
//success的个，十位，success为成功回合数
 //episode的个，十，百，位,episode为总训练回合
reg [7:0]id_in;
initial
begin
    cnt=0;cnt2=0;in=0;
    episode_1=0;
    episode_2=0;
    episode_3=0;
    success_1=0;
    success_2=0;
    id_in=8'b1111_1110;
end
always@(posedge clk)    //转换success和episode到10进制
if(pulse_200hz)
    begin
        episode_3<=episode/100;
        episode_2<=episode/10-episode_3*10;
        episode_1<=episode-episode_2*10-episode_3*100;
        success_2<=success/10;
        success_1<=success-success_2*10;
    end


always@(posedge clk)    //分频以用于转换success和episode
begin
    if(cnt>200)
        cnt <= 10'd0;
    else
        cnt <= cnt + 10'd1;
end

assign pulse_200hz= (cnt == 10'd200);

always@(posedge clk)    //分频以用于数码管显示
begin
    if(cnt2>10000)
        cnt2 <= 'd0;
    else
        cnt2 <= cnt2 + 'd1;
end

assign pulse_1000hz= (cnt2 == 'd10000); 

always@(posedge clk)    //数码管显示部分
begin
    if(pulse_1000hz)
    begin
        if(id_in== 8'b1111_1110)         begin id_in<=8'b1111_1011; in<=episode_1; end
        else if(id_in==8'b1111_1011)    begin id_in<=8'b1111_0111; in<=episode_2; end
        else if(id_in==8'b1111_0111)    begin id_in<=8'b1110_1111; in<=episode_3; end
        else if(id_in==8'b1110_1111)    begin id_in<=8'b1011_1111; in<=success_1; end
        else if(id_in==8'b1011_1111)    begin id_in<=8'b0111_1111; in<=success_2; end
        else  begin id_in<=8'b1111_1110;  in<=state; end   
    end
end   

assign id_out=id_in;
//dist_mem_gen_0 dist_men_gen_model0(.a(in),.spo(seg));  //运用储存器，输出数码管的显示 
always@(posedge clk) 
begin
    if(in==0)    seg_<=8'b11000000;
    else if(in=='d1) seg_<=8'b11111001;
    else if(in=='d2) seg_<=8'b10100100;
    else if(in=='d3) seg_<=8'b10110000;  
    else if(in=='d4) seg_<=8'b10011001;
    else if(in=='d5) seg_<=8'b10010010;
    else if(in=='d6) seg_<=8'b10000010;
    else if(in=='d7) seg_<=8'b11111000;
    else if(in=='d8) seg_<=8'b10000000;
    else if(in=='d9) seg_<=8'b10010000;
    else if(in=='d10) seg_<=8'b10001000;
    else if(in=='d11) seg_<=8'b10000011;
    else if(in=='d12) seg_<=8'b11000110;
    else if(in=='d13) seg_<=8'b10100001;
    else if(in=='d14) seg_<=8'b10000110;
    else  seg_<=8'b10001110;      
end

assign seg=seg_;
endmodule

