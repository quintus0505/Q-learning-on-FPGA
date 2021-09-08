`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/08 10:50:37
// Design Name: 
// Module Name: top
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


module top(
input clk,
input rst,
input start,
//music����
input button_music,
output audio,
// hvsync_generator����
output VGA_HS,
output VGA_VS,
//Nixie_tube_display
output  wire [7:0]id,    //����ܵ�ַ
output  wire [7:0]seg,    //��������
//RGB���
output [3:0]VGA_R,
output [3:0]VGA_G, 
output [3:0]VGA_B
);
//��Ƶ
reg clk_50MHz;
reg clk_25MHz;
wire clk_100ms;
wire clk_10ms;
reg clk_20ms;
reg clk_200ms;
reg clk_400ms;
initial clk_50MHz=0;
initial clk_25MHz=0;
initial clk_20ms=0;
initial clk_200ms=0;
initial clk_400ms=0;

always@(posedge clk)  //50MHz��Ƶ
    clk_50MHz=~clk_50MHz;
    
always@(posedge clk_50MHz)  //25MHz��Ƶ
    clk_25MHz=~clk_25MHz;
    
reg [31:0] cnt_100ms;
initial cnt_100ms=0;

always@(posedge clk)
begin
    if(rst)
        cnt_100ms <= 32'd0;
    else if(cnt_100ms>10000000)
        cnt_100ms <= 32'd0;
    else
        cnt_100ms <= cnt_100ms + 32'd1;
end
assign clk_100ms = (cnt_100ms == 32'd10000000); //�õ�0.1s��clk


assign clk_10ms=(cnt_100ms==32'd1000000||cnt_100ms==32'd2000000||cnt_100ms==32'd3000000||cnt_100ms==32'd4000000||
                  cnt_100ms==32'd5000000||cnt_100ms==32'd6000000||cnt_100ms==32'd7000000||cnt_100ms==32'd8000000||
                  cnt_100ms==32'd9000000||cnt_100ms==32'd10000000);    //�õ�0.01s��clk

//always@(posedge clk)
//begin
//    if(rst)
//        cnt_100ms <= 32'd0;
//    else if(cnt_100ms>1000)
//        cnt_100ms <= 32'd0;
//    else
//        cnt_100ms <= cnt_100ms + 32'd1;
//end
//assign clk_100ms = (cnt_100ms == 32'd1000); //�õ�0.1s��clk


//assign clk_10ms=(cnt_100ms==32'd100||cnt_100ms==32'd200||cnt_100ms==32'd300||cnt_100ms==32'd400||
//                  cnt_100ms==32'd500||cnt_100ms==32'd600||cnt_100ms==32'd700||cnt_100ms==32'd800||
//                  cnt_100ms==32'd900||cnt_100ms==32'd1000);    //�õ�0.01s��clk
                  
                  
always@(posedge clk_10ms)  //0.02s��Ƶ
    clk_20ms=~clk_20ms;
    
always@(posedge clk)  //0.2s��Ƶ
    if(clk_100ms)
        clk_200ms=~clk_200ms;
    
always@(posedge clk_200ms)  //0.4s��Ƶ
    clk_400ms=~clk_400ms;    
    
//����ȥ����
//wire rst_edge;

//button_edge rst_part(.clk(clk),.button(rst),.button_edge(rst_edge));    //���ü�ȥ����

//music����
music music_generator(.audio(audio),.button(button_music),.music_clk(clk));    //ͨ��PWM�������

//�������ʾ����
reg [3:0] state;     //��¼��ǰstate 
reg [9:0]episode;    //�趨���epispdeΪ999����10λ����
reg [6:0]success;    //�趨��ɹ��غ�99����7λ����
reg [1:0] action;
state_display display(
        .clk(clk),.state(state),
        .action(action),
        .episode(episode),
        .success(success),
        .id_out(id),.seg(seg)
    );
    
//assign id = 8'b1111_1110;
//reg [7:0]seg_;
//reg [6:0]in;
//reg [6:0]rand;    //���������
//always@(posedge clk_100ms) 
//begin
//    in<=action;
//    if(in==0)    seg_<=8'b11000000;
//    else if(in=='d1) seg_<=8'b11111001;
//    else if(in=='d2) seg_<=8'b10100100;
//    else if(in=='d3) seg_<=8'b10110000;  
//    else if(in=='d4) seg_<=8'b10011001;
//    else if(in=='d5) seg_<=8'b10010010;
//    else if(in=='d6) seg_<=8'b10000010;
//    else if(in=='d7) seg_<=8'b11111000;
//    else if(in=='d8) seg_<=8'b10000000;
//    else if(in=='d9) seg_<=8'b10010000;
//    else if(in=='d10) seg_<=8'b10001000;
//    else if(in=='d11) seg_<=8'b10000011;
//    else if(in=='d12) seg_<=8'b11000110;
//    else if(in=='d13) seg_<=8'b10100001;
//    else if(in=='d14) seg_<=8'b10000110;
//    else  seg_<=8'b10001110;  
    
//    seg<=seg_;    
//end

//hvsync_generator����,�õ�25MHz��ʱ��
wire inDisplayArea;
wire [11:0] CounterX;
wire [11:0] CounterY;
hvsync_generator vga0(
		.pixel_clk(clk_25MHz),
		.h_fporch (16),
		.h_sync   (96), 
		.h_bporch (48),		
		.v_fporch (10),
		.v_sync   (10),
		.v_bporch (33),
		.vga_hs   (VGA_HS),
		.vga_vs   (VGA_VS),
		.vga_blank(inDisplayArea),
		.CounterY(CounterY),
		.CounterX(CounterX) 
	);

//��������
//state
parameter a = 0;  parameter i = 8;
parameter b = 1;  parameter j = 9;
parameter c = 2;  parameter k = 10;
parameter d = 3;  parameter l = 11;
parameter e = 4;  parameter m = 12;
parameter f = 5;  parameter n = 13;
parameter g = 6;  parameter o = 14;
parameter h = 7;  parameter p = 15;
//action 
parameter left = 0;
parameter up = 1;
parameter right = 2;
parameter down = 3;
//ѧϰЧ�ʺ�˥��ϵ���Լ�epsilon
parameter learning_rate = 0.01;
parameter decay = 0.9;
parameter epsilon=192;    //epsilon-greedyѡ���е�epsilon

//������ر���
reg[3:0] pre_state;     //��¼��һ��state�����ڼ���Q(s,a)
//16*4��λ��Ϊ15�ļĴ���
reg signed [14:0] Q_left[0:15];    //��¼ÿһ��λ�õ�Qֵ,��Ϊ�п����и�����������signed reg ��
reg signed [14:0] Q_up[0:15];    
reg signed [14:0] Q_right[0:15];
reg signed [14:0] Q_down[0:15];    
//�ر�Reward    
reg signed [14:0] R[0:15];    //ÿһ��state��reward
//����ʹ�������������ʾ���ֶ�������±���
//reg [3:0]state
//reg [9:0]episode;    //�趨���epispdeΪ999����10λ����
//reg [6:0]success;    //�趨��ɹ��غ�99����7λ����

//���������ֵ����
function [14:0]max;
input [14:0]q1,q2,q3,q4;
    begin
        if(q1>=q2) max=q1;
        else max=q2;
        if(q3>max) max=q3;
        if(q4>max) max=q4;
    end
endfunction

//�������Qֵ����
function[14:0]nextQ;  
input [14:0]Qstate_left;
input [14:0]Qstate_up;
input [14:0]Qstate_right;
input [14:0]Qstate_down;
input [14:0]Qpre_state;
input [14:0]R;
    begin
            nextQ=Qpre_state+learning_rate*(R+decay
            *max(Qstate_left,Qstate_up,Qstate_right,Qstate_down)
            -Qpre_state);
    end  
endfunction        

//�õ����ر�����
function [1:0]best_action;
input [14:0]Qstate_left;
input [14:0]Qstate_up;
input [14:0]Qstate_right;
input [14:0]Qstate_down;
    begin
        if(Qstate_left>Qstate_up&&Qstate_left>Qstate_right&&Qstate_left>Qstate_down)   best_action=0;    //�����߻ر����
        else if(Qstate_up>Qstate_left&&Qstate_up>Qstate_right&&Qstate_up>Qstate_down)    best_action=1;    //�����߻ر����
        else if(Qstate_right>Qstate_left&&Qstate_right>Qstate_up&&Qstate_right>Qstate_down)    best_action=2;    //�����߻ر����
        else//(Qstate_down>Qstate_left&&Qstate_down>Qstate_up&&Qstate_down>Qstate_right)
            best_action=3;    //�����߻ر����
    end
endfunction 

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//

//Ĭ��Q��R��ֵ  
initial
begin
            state<=a;   
            pre_state<=a; 
            episode<=0;
            success<=0;
            //ÿһ��state�����ߵ�Q
            Q_left[0]<=0;      Q_left[1]<=0;      Q_left[2]<=0;      Q_left[3]<=0;
            Q_left[4]<=0;      Q_left[5]<=0;      Q_left[6]<=0;      Q_left[7]<=0;
            Q_left[8]<=0;      Q_left[9]<=0;      Q_left[10]<=0;     Q_left[11]<=0;
            Q_left[12]<=0;     Q_left[13]<=0;     Q_left[14]<=0;     Q_left[15]<=0;
           //ÿһ��state�����ߵ�Q
            Q_up[0]<=0;      Q_up[1]<=0;      Q_up[2]<=0;      Q_up[3]<=0;
            Q_up[4]<=0;      Q_up[5]<=0;      Q_up[6]<=0;      Q_up[7]<=0;
            Q_up[8]<=0;      Q_up[9]<=0;      Q_up[10]<=0;     Q_up[11]<=0;
            Q_up[12]<=0;     Q_up[13]<=0;     Q_up[14]<=0;     Q_up[15]<=0;
            //ÿһ��state������dQ
            Q_right[0]<=0;      Q_right[1]<=0;      Q_right[2]<=0;      Q_right[3]<=0;
            Q_right[4]<=0;      Q_right[5]<=0;      Q_right[6]<=0;      Q_right[7]<=0;
            Q_right[8]<=0;      Q_right[9]<=0;      Q_right[10]<=0;     Q_right[11]<=0;
            Q_right[12]<=0;     Q_right[13]<=0;     Q_right[14]<=0;     Q_right[15]<=0; 
            //ÿһ��state�����ߵ�Q
            Q_down[0]<=0;      Q_down[1]<=0;      Q_down[2]<=0;      Q_down[3]<=0;
            Q_down[4]<=0;      Q_down[5]<=0;      Q_down[6]<=0;      Q_down[7]<=0;
            Q_down[8]<=0;      Q_down[9]<=0;      Q_down[10]<=0;     Q_down[11]<=0;
            Q_down[12]<=0;     Q_down[13]<=0;     Q_down[14]<=0;     Q_down[15]<=0;
            //ÿһ��state��reward
            R[0]<=0;      R[1]<=0;      R[2]<=0;      R[3]<=0;
            R[4]<=0;      R[5]<=0;      R[6]<=-10000; R[7]<=0;
            R[8]<=0;      R[9]<=-10000; R[10]<=10000; R[11]<=0;
            R[12]<=0;     R[13]<=0;     R[14]<=0;     R[15]<=0;  
               
end 
//�������������
reg [7:0]rand_num;     //�����
reg [7:0]rand;    //����ѡ����
initial rand_num=8'b1111_0010;
always@(posedge clk_25MHz)    //����α�����
begin
            rand_num[0] <= rand_num[7];
            rand_num[1] <= rand_num[0];
            rand_num[2] <= rand_num[1];
            rand_num[3] <= rand_num[2];
            rand_num[4] <= rand_num[3]^rand_num[7];
            rand_num[5] <= rand_num[4]^rand_num[7];
            rand_num[6] <= rand_num[5]^rand_num[7];
            rand_num[7] <= rand_num[6];       
end

always@(posedge clk_50MHz)
begin
    rand<=rand_num;   //����0��256�������
end

//ѡ��������
always@(posedge clk_200ms)      //�趨ÿ0.02s����һ��
if(rst||start==0)
    action<=0;
else
begin
     //rand����0��256�������
    if(Q_left[state]==Q_up[state]&&Q_left[state]==Q_right[state]&&Q_left[state]==Q_down[state])
    //���ÿ��action�ر���ͬ�����ѡ��action
        begin
            if(rand<'d64)    action<=0;
            else if(rand<'d128)   action<=1;
            else if(rand<'d192)   action<=2;
            else //(rand<100) 
                  action<=3;  
        end
    //*****************************************************************************************************//
    else if //����action�ر�һ����һ����С,�������������ѡ
            ((Q_left[state]==Q_up[state]&&Q_left[state]==Q_right[state]&&Q_left[state]>Q_down[state])   //ֻ������С��������һ��
           ||(Q_left[state]==Q_up[state]&&Q_left[state]==Q_down[state]&&Q_left[state]>Q_right[state])   //ֻ������С��������һ��
           ||(Q_left[state]==Q_right[state]&&Q_left[state]==Q_down[state]&&Q_left[state]>Q_up[state])   //ֻ������С��������һ��
           ||(Q_up[state]==Q_right[state]&&Q_up[state]==Q_down[state]&&Q_up[state]>Q_left[state]))  //ֻ������С��������һ��
    begin
        if(Q_left[state]==Q_up[state]&&Q_left[state]==Q_right[state]&&Q_left[state]>Q_down[state])  //ֻ������С��������һ��
            begin
                if(rand<'d86)    action<=0;
                else if(rand<'d171)   action<=1;
                else  action<=2;  
            end
        else if(Q_left[state]==Q_up[state]&&Q_left[state]==Q_down[state]&&Q_left[state]>Q_right[state])   //ֻ������С��������һ��
            begin
                if(rand<'d86)    action<=0;
                else if(rand<'d171)   action<=1;
                else  action<=3;  
            end 
        else if(Q_left[state]==Q_right[state]&&Q_left[state]==Q_down[state]&&Q_left[state]>Q_up[state])   //ֻ������С��������һ��
            begin
                if(rand<'d86)    action<=0;
                else if(rand<'d171)   action<=2;
                else  action<=3;  
            end 
        else           //ֻ������С��������һ��
            begin
                if(rand<'d86)    action<=1;
                else if(rand<'d171)   action<=2;
                else  action<=3;  
            end 
    end
    //*****************************************************************************************************//
    else if     //����aciton�ر�һ�����
           ((Q_left[state]==Q_up[state]&&Q_left[state]>Q_right[state]&&Q_left[state]>Q_down[state])||   //��������
            (Q_left[state]==Q_right[state]&&Q_left[state]>Q_up[state]&&Q_left[state]>Q_down[state])||   //�������� 
            (Q_left[state]==Q_down[state]&&Q_left[state]>Q_up[state]&&Q_left[state]>Q_right[state])||   //�������� 
            (Q_up[state]==Q_right[state]&&Q_up[state]>Q_left[state]&&Q_up[state]>Q_down[state])||   //�Ϻ������  
            (Q_up[state]==Q_down[state]&&Q_up[state]>Q_left[state]&&Q_up[state]>Q_right[state])||   //�Ϻ������ 
            (Q_right[state]==Q_down[state]&&Q_right[state]>Q_left[state]&&Q_right[state]>Q_up[state])   //�Һ������            
    )
    begin
        if(Q_left[state]==Q_up[state]&&Q_left[state]>Q_right[state]&&Q_left[state]>Q_down[state])   //��������
            begin
                    if(rand<'d128)    action<=0;
                    else  action<=1;            
            end
        else if(Q_left[state]==Q_right[state]&&Q_left[state]>Q_up[state]&&Q_left[state]>Q_down[state])  //�������� 
            begin
                    if(rand<'d128)    action<=0;
                    else  action<=2;            
            end
        else if(Q_left[state]==Q_down[state]&&Q_left[state]>Q_up[state]&&Q_left[state]>Q_right[state])   //�������� 
            begin
                    if(rand<'d128)    action<=0;
                    else  action<=3;            
            end
        else if(Q_up[state]==Q_right[state]&&Q_up[state]>Q_left[state]&&Q_up[state]>Q_down[state])   //�Ϻ������  
            begin
                    if(rand<'d128)    action<=1;
                    else  action<=2;            
            end
        else if(Q_up[state]==Q_down[state]&&Q_up[state]>Q_left[state]&&Q_up[state]>Q_right[state])   //�Ϻ������ 
            begin
                    if(rand<'d128)    action<=1;
                    else  action<=3;            
            end
        else    //�Һ������ 
            begin
                    if(rand<'d128)    action<=2;
                    else  action<=3;            
            end            
    end    
        //*****************************************************************************************************//
    else    //����߻ر��Ķ�����epsilon-greedyѡ��
    begin
        if(rand<epsilon)
            begin
                action<=best_action(Q_left[state],Q_up[state],Q_right[state],Q_down[state]);
            end
        else    //ʣ��һ���������ѡ��
            begin
                if(rand<'d208)    action<=0;
                else if(rand<'d224)   action<=1;
                else if(rand<'d240)   action<=2;
                else //(rand<100) 
                      action<=3; 
            end
    end
end

//����ת�ƹ�ϵ,����QTabel
always@(posedge clk)    //�趨ÿ0.2s��һ����ǰ���ṩ0.1s,0.2,0.4s��ѡ��
begin
    if(rst)   //�������
        begin    //Qtable��ʼ״̬
            state<=a;   
            pre_state<=a;
            episode<=0;
            success<=0; 
            //ÿһ��state�����ߵ�Q
            Q_left[0]<=0;      Q_left[1]<=0;      Q_left[2]<=0;      Q_left[3]<=0;
            Q_left[4]<=0;      Q_left[5]<=0;      Q_left[6]<=0;      Q_left[7]<=0;
            Q_left[8]<=0;      Q_left[9]<=0;      Q_left[10]<=0;     Q_left[11]<=0;
            Q_left[12]<=0;     Q_left[13]<=0;     Q_left[14]<=0;     Q_left[15]<=0;
           //ÿһ��state�����ߵ�Q
            Q_up[0]<=0;      Q_up[1]<=0;      Q_up[2]<=0;      Q_up[3]<=0;
            Q_up[4]<=0;      Q_up[5]<=0;      Q_up[6]<=0;      Q_up[7]<=0;
            Q_up[8]<=0;      Q_up[9]<=0;      Q_up[10]<=0;     Q_up[11]<=0;
            Q_up[12]<=0;     Q_up[13]<=0;     Q_up[14]<=0;     Q_up[15]<=0;
            //ÿһ��state������dQ
            Q_right[0]<=0;      Q_right[1]<=0;      Q_right[2]<=0;      Q_right[3]<=0;
            Q_right[4]<=0;      Q_right[5]<=0;      Q_right[6]<=0;      Q_right[7]<=0;
            Q_right[8]<=0;      Q_right[9]<=0;      Q_right[10]<=0;     Q_right[11]<=0;
            Q_right[12]<=0;     Q_right[13]<=0;     Q_right[14]<=0;     Q_right[15]<=0; 
            //ÿһ��state�����ߵ�Q
            Q_down[0]<=0;      Q_down[1]<=0;      Q_down[2]<=0;      Q_down[3]<=0;
            Q_down[4]<=0;      Q_down[5]<=0;      Q_down[6]<=0;      Q_down[7]<=0;
            Q_down[8]<=0;      Q_down[9]<=0;      Q_down[10]<=0;     Q_down[11]<=0;
            Q_down[12]<=0;     Q_down[13]<=0;     Q_down[14]<=0;     Q_down[15]<=0;
        end 
        /*a   b   c   d
          e   f   g   h
          i   j   k   l 
          m   n   o   p
        */
end
//****************************************************************************************************//
//***************************************************************************************************//
//**************************************************************************************************//
always@(posedge clk_200ms)    //�趨ÿ0.2s��һ����ǰ���ṩ0.1s,0.2,0.4s��ѡ��
begin
    if(start)
        begin
    ////*state a*////
           if(state==a)
                begin
                    pre_state<=a;
                    case(action)
                        left:begin  state<=a;   end
                        up:begin    state<=a;   end
                        right:begin state<=b;   end
                        down:begin  state<=e;   end
                    endcase
                    //����Qtable
                    if(state==b)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );   
                        end
                    if(state==e)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
                end
    ////*state b*////
           else if(state==b)
                begin
                    pre_state<=b;
                    case(action)
                        left:begin  state<=a;   end
                        up:begin    state<=b;   end
                        right:begin state<=c;   end
                        down:begin  state<=f;   end
                    endcase
                    //����Qtable
                    if(state==a)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==c)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
                    if(state==f)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end 
    ////*state c*////
            else if(state==c)
                begin
                    pre_state<=c;
                    case(action)
                        left:begin  state<=b;   end
                        up:begin    state<=c;   end
                        right:begin state<=d;   end
                        down:begin  state<=g;   end
                    endcase
                    //����Qtable
                    if(state==b)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==d)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
                    if(state==g)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end 
    ////*state d*////
            else if(state==d)
                begin
                    pre_state<=d;
                    case(action)
                        left:begin  state<=c;   end
                        up:begin    state<=d;   end
                        right:begin state<=d;   end
                        down:begin  state<=h;   end
                    endcase
                    //����Qtable
                    if(state==c)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==h)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end                                      
    ////*state e*////
            else if(state==e)
                begin
                    pre_state<=e;
                    case(action)
                        left:begin  state<=e;   end
                        up:begin    state<=a;   end
                        right:begin state<=f;   end
                        down:begin  state<=i;   end
                    endcase
                    //����Qtable
                    if(state==a)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==f)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
                    if(state==i)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end 
    ////*state f*////
            else if(state==f)
                begin
                    pre_state<=f;
                    case(action)
                        left:begin  state<=e;   end
                        up:begin    state<=b;   end
                        right:begin state<=g;   end
                        down:begin  state<=j;   end
                    endcase
                    //����Qtable
                    if(state==e)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==b)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==g)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
                    if(state==j)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end 
    ////*state g*////
            else if(state==g)
                //�������
                begin
                    state<=a;
                    pre_state<=a; 
                    episode<=episode+1; 
                end
    ////*state h*////
            else if(state==h)
                begin
                    pre_state<=h;
                    case(action)
                        left:begin  state<=g;   end
                        up:begin    state<=d;   end
                        right:begin state<=h;   end
                        down:begin  state<=l;   end
                    endcase
                    //����Qtable
                    if(state==g)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==d)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==l)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end
    ////*state i*////
            else if(state==i)
                begin
                    pre_state<=i;
                    case(action)
                        left:begin  state<=i;   end
                        up:begin    state<=e;   end
                        right:begin state<=j;   end
                        down:begin  state<=m;   end
                    endcase
                    //����Qtable
                    if(state==e)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==j)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
                    if(state==m)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end
               end 
    ////*state j*////
            else if(state==j)
                begin
                //�������   
                    state<=a;
                    pre_state<=a; 
                    episode<=episode+1; 
                end 
    ////*state k*////
            else if(state==k)
                begin
                //�ɹ�
                    pre_state<=a;
                    state<=a;
                    episode<=episode+1; 
                    success<=success+1;
                end
    ////*state l*////
            else if(state==l)
                begin
                    pre_state<=l;
                    case(action)
                        left:begin  state<=k;   end
                        up:begin    state<=h;   end
                        right:begin state<=l;   end
                        down:begin  state<=p;   end
                    endcase
                    //����Qtable
                    if(state==k)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==h)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==p)//��
                        begin
                            Q_down[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_down[pre_state],
                            R[state]
                            );    
                        end   
               end
    ////*state m*////
            else if(state==m)
                begin
                    pre_state<=m;
                    case(action)
                        left:begin  state<=m;   end
                        up:begin    state<=i;   end
                        right:begin state<=n;   end
                        down:begin  state<=m;   end
                    endcase
                    //����Qtable
                    if(state==i)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==n)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
               end
    ////*state n*////
            else if(state==n)
                begin
                    pre_state<=n;
                    case(action)
                        left:begin  state<=m;   end
                        up:begin    state<=j;   end
                        right:begin state<=o;   end
                        down:begin  state<=n;   end
                    endcase
                    //����Qtable
                    if(state==m)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==j)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==o)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
               end     
    ////*state o*////
            else if(state==o)
                begin
                    pre_state<=o;
                    case(action)
                        left:begin  state<=n;   end
                        up:begin    state<=k;   end
                        right:begin state<=p;   end
                        down:begin  state<=o;   end
                    endcase
                    //����Qtable
                    if(state==n)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==k)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
                    if(state==p)//��
                        begin
                            Q_right[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_right[pre_state],
                            R[state]
                            );    
                        end
               end  
    ////*state p*////
            else if(state==p)
                begin
                    pre_state<=p;
                    case(action)
                        left:begin  state<=o;   end
                        up:begin    state<=l;   end
                        right:begin state<=p;   end
                        down:begin  state<=p;   end
                    endcase
                    //����Qtable
                    if(state==o)//��
                        begin
                            Q_left[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_left[pre_state],
                            R[state]
                            );    
                        end
                    if(state==l)//��
                        begin
                            Q_up[pre_state]<=nextQ(
                            Q_left[state],Q_up[state],Q_right[state],Q_down[state],
                            Q_up[pre_state],
                            R[state]
                            );    
                        end
               end             
                                     
        end
end

endmodule