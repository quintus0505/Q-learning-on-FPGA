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
//music部分
input button_music,
output audio,
// hvsync_generator部分
output VGA_HS,
output VGA_VS,
//Nixie_tube_display
output  wire [7:0]id,    //数码管地址
output  wire [7:0]seg,    //数码显现
//RGB输出
output [3:0]VGA_R,
output [3:0]VGA_G, 
output [3:0]VGA_B
);
//分频
reg clk_50MHz;
reg clk_25MHz;
wire clk_100ms;
wire clk_10ms;
reg clk_20ms;
reg clk_40ms;
reg clk_200ms;
reg clk_400ms;
reg clk_200ms_2;
initial clk_50MHz=0;
initial clk_25MHz=0;
initial clk_20ms=0;
initial clk_40ms=0;
initial clk_200ms=0;
initial clk_400ms=0;


always@(posedge clk)  //50MHz分频
    clk_50MHz=~clk_50MHz;
    
always@(posedge clk_50MHz)  //25MHz分频
    clk_25MHz=~clk_25MHz;
    
reg [31:0] cnt_100ms;
initial cnt_100ms=0;

//always@(posedge clk)    //0.1s分频
//begin
//    if(cnt_100ms>'d10000000)
//        cnt_100ms<=0;
//    else
//        cnt_100ms<=cnt_100ms+1;
//end   

//assign clk_100ms=(cnt_100ms=='d10000000);    //得到0.1s的clk
//assign clk_10ms=(cnt_100ms=='d1000000||cnt_100ms=='d2000000||cnt_100ms=='d3000000||cnt_100ms=='d4000000||
//                  cnt_100ms=='d5000000||cnt_100ms=='d6000000||cnt_100ms=='d7000000||cnt_100ms=='d8000000||
//                  cnt_100ms=='d9000000||cnt_100ms=='d10000000);    //得到0.01s的clk
                  
                  
                  
//仿真测试使用

always@(posedge clk)    //0.1s分频
begin
    if(cnt_100ms>'d1000)
        cnt_100ms<=0;
    else
        cnt_100ms<=cnt_100ms+1;
end   

assign clk_100ms=(cnt_100ms=='d1000);    //得到0.1s的clk
assign clk_10ms=(cnt_100ms=='d100||cnt_100ms=='d200||cnt_100ms=='d300||cnt_100ms=='d400||
                  cnt_100ms=='d500||cnt_100ms=='d600||cnt_100ms=='d700||cnt_100ms=='d800||
                  cnt_100ms=='d900||cnt_100ms=='d1000);    //得到0.01s的clk

always@(posedge clk_10ms)  //0.02s分频
    clk_20ms=~clk_20ms;
    
always@(posedge clk_20ms)  //0.04s分频
    clk_40ms=~clk_40ms;
    
always@(posedge clk_100ms)  //0.2s分频
    clk_200ms=~clk_200ms;
    
always@(posedge clk_200ms)  //0.4s分频
    clk_400ms=~clk_400ms;    
    
//按键去抖动
//wire rst_edge;

//button_edge rst_part(.clk(clk),.button(rst),.button_edge(rst_edge));    //重置键去抖动

//music部分
music music_generator(.audio(audio),.button(button_music),.music_clk(clk));    //通过PWM输出音乐

//数码管显示部分
reg [4:0] state;     //记录当前state 
reg [13:0]episode;    //设定最大epispde为999，用10位储存
reg [13:0]success;    //设定最成功回合99，用7位储存
reg[2:0] action;        //选择action 
state_display display(
        .clk(clk),.state(state),
        .action(action),
        .episode(episode),
        .success(success),
        .id_out(id),.seg(seg)
    );
    
//assign id = 8'b1111_1110;
    
//hvsync_generator部分,用到25MHz的时钟
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

//环境建立
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
//学习效率和衰减系数以及epsilon
reg [3:0] learning_rate = 1;
reg [3:0] decay = 8;      //8/10
reg [7:0] epsilon=216;    //epsilon-greedy选择中的epsilon

//定义相关变量
reg[4:0] pre_state;     //记录下一个state，用于计算Q(s,a)

//16*4组位宽为15的寄存器
reg  signed[31:0] Q_left[0:15];    //记录每一个位置的Q值,因为有可能有负数，所以用signed reg 型
reg  signed[31:0] Q_up[0:15];    
reg  signed[31:0] Q_right[0:15];
reg  signed[31:0] Q_down[0:15];    
//回报Reward    
reg  signed[31:0] R[0:15];    //每一个state的reward

//这里使用了在数码管显示部分定义的以下变量
//reg [3:0]state
//reg [9:0]episode;    //设定最大epispde为999，用10位储存
//reg [6:0]success;    //设定最成功回合99，用7位储存
wire signed[31:0]maxQ;
reg signed[31:0] in_maxQ;
//比较四个方向Q的大小（有符号数无法)
reg [2:0] comp01;
reg [2:0] comp02;
reg [2:0] comp03;
reg [2:0] comp12;
reg [2:0] comp13;
reg [2:0] comp23;
//以下是比较四个方向Q的逻辑。如comp01表示方向0和方向1，comp01==1，方向0的Q小，comp01==2，两个Q相同，comp01==3，方向0的Q更大。
always@(posedge clk)
begin
    if(Q_left[state][31]==0&&Q_up[state][31]==0)
    begin
        if(Q_left[state][30:0]<Q_up[state][30:0]) comp01<=1;
        else if(Q_left[state][30:0]==Q_up[state][30:0]) comp01<=2;
        else comp01<=3;
    end    
    else if(Q_left[state][31]==1&&Q_up[state][31]==0)
        comp01<=1;
    else if(Q_left[state][31]==0&&Q_up[state][31]==1)
        comp01<=3;
    else
    begin
        if(Q_left[state][30:0]<Q_up[state][30:0]) comp01<=3;
        else if(Q_left[state][30:0]==Q_up[state][30:0]) comp01<=2;
        else comp01<=1;
    end
end

always@(posedge clk)
begin
    if(Q_left[state][31]==0&&Q_right[state][31]==0)
    begin
        if(Q_left[state][30:0]<Q_right[state][30:0]) comp02<=1;
        else if(Q_left[state][30:0]==Q_right[state][30:0]) comp02<=2;
        else comp02<=3;
    end    
    else if(Q_left[state][31]==1&&Q_right[state][31]==0)
        comp02<=1;
    else if(Q_left[state][31]==0&&Q_right[state][31]==1)
        comp02<=3;
    else
    begin
        if(Q_left[state][30:0]<Q_right[state][30:0]) comp02<=3;
        else if(Q_left[state][30:0]==Q_right[state][30:0]) comp02<=2;
        else comp02<=1;
    end
end

always@(posedge clk)
begin
    if(Q_left[state][31]==0&&Q_down[state][31]==0)
    begin
        if(Q_left[state][30:0]<Q_down[state][30:0]) comp03<=1;
        else if(Q_left[state][30:0]==Q_down[state][30:0]) comp03<=2;
        else comp03<=3;
    end    
    else if(Q_left[state][31]==1&&Q_down[state][31]==0)
        comp03<=1;
    else if(Q_left[state][31]==0&&Q_down[state][31]==1)
        comp03<=3;
    else
    begin
        if(Q_left[state][30:0]<Q_down[state][30:0]) comp03<=3;
        else if(Q_left[state][30:0]==Q_down[state][30:0]) comp03<=2;
        else comp03<=1;
    end
end

always@(posedge clk)
begin
    if(Q_up[state][31]==0&&Q_right[state][31]==0)
    begin
        if(Q_up[state][30:0]<Q_right[state][30:0]) comp12<=1;
        else if(Q_up[state][30:0]==Q_right[state][30:0]) comp12<=2;
        else comp12<=3;
    end    
    else if(Q_up[state][31]==1&&Q_right[state][31]==0)
        comp12<=1;
    else if(Q_up[state][31]==0&&Q_right[state][31]==1)
        comp12<=3;
    else
    begin
        if(Q_up[state][30:0]<Q_right[state][30:0]) comp12<=3;
        else if(Q_up[state][30:0]==Q_right[state][30:0]) comp12<=2;
        else comp12<=1;
    end
end

always@(posedge clk)
begin
    if(Q_up[state][31]==0&&Q_down[state][31]==0)
    begin
        if(Q_up[state][30:0]<Q_down[state][30:0]) comp13<=1;
        else if(Q_up[state][30:0]==Q_down[state][30:0]) comp13<=2;
        else comp13<=3;
    end    
    else if(Q_up[state][31]==1&&Q_down[state][31]==0)
        comp13<=1;
    else if(Q_up[state][31]==0&&Q_down[state][31]==1)
        comp13<=3;
    else
    begin
        if(Q_up[state][30:0]<Q_down[state][30:0]) comp13<=3;
        else if(Q_up[state][30:0]==Q_down[state][30:0]) comp13<=2;
        else comp13<=1;
    end
end

always@(posedge clk)
begin
    if(Q_right[state][31]==0&&Q_down[state][31]==0)
    begin
        if(Q_right[state][30:0]<Q_down[state][30:0]) comp23<=1;
        else if(Q_right[state][30:0]==Q_down[state][30:0]) comp23<=2;
        else comp23<=3;
    end    
    else if(Q_right[state][31]==1&&Q_down[state][31]==0)
        comp23<=1;
    else if(Q_right[state][31]==0&&Q_down[state][31]==1)
        comp23<=3;
    else
    begin
        if(Q_right[state][30:0]<Q_down[state][30:0]) comp23<=3;
        else if(Q_right[state][30:0]==Q_down[state][30:0]) comp23<=2;
        else comp23<=1;
    end
end
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//

//默认Q和R的值  
initial
begin
            state<=a;   
            pre_state<=a; 
            episode<=0;
            success<=0;
            in_maxQ<=0;
            //每一个state向左走的Q
            Q_left[0]<=-100;      Q_left[1]<=0;      Q_left[2]<=0;      Q_left[3]<=0;
            Q_left[4]<=-100;      Q_left[5]<=0;      Q_left[6]<=0;      Q_left[7]<=0;
            Q_left[8]<=-100;      Q_left[9]<=0;      Q_left[10]<=0;     Q_left[11]<=0;
            Q_left[12]<=-100;     Q_left[13]<=0;     Q_left[14]<=0;     Q_left[15]<=0;
           //每一个state向上走的Q
            Q_up[0]<=-100;      Q_up[1]<=-100;      Q_up[2]<=-100;      Q_up[3]<=-100;
            Q_up[4]<=0;      Q_up[5]<=0;      Q_up[6]<=0;      Q_up[7]<=0;
            Q_up[8]<=0;      Q_up[9]<=0;      Q_up[10]<=0;     Q_up[11]<=0;
            Q_up[12]<=0;     Q_up[13]<=0;     Q_up[14]<=0;     Q_up[15]<=0;
            //每一个state向右走dQ
            Q_right[0]<=0;      Q_right[1]<=0;      Q_right[2]<=0;      Q_right[3]<=-100;
            Q_right[4]<=0;      Q_right[5]<=0;      Q_right[6]<=0;      Q_right[7]<=-100;
            Q_right[8]<=0;      Q_right[9]<=0;      Q_right[10]<=0;     Q_right[11]<=-100;
            Q_right[12]<=0;     Q_right[13]<=0;     Q_right[14]<=0;     Q_right[15]<=-100; 
            //每一个state向下走的Q
            Q_down[0]<=0;      Q_down[1]<=0;      Q_down[2]<=0;      Q_down[3]<=0;
            Q_down[4]<=0;      Q_down[5]<=0;      Q_down[6]<=0;      Q_down[7]<=0;
            Q_down[8]<=0;      Q_down[9]<=0;      Q_down[10]<=0;     Q_down[11]<=0;
            Q_down[12]<=-100;     Q_down[13]<=-100;     Q_down[14]<=-100;     Q_down[15]<=-100;

            //每一个state的reward
            R[0]<=0;      R[1]<=0;      R[2]<=0;      R[3]<=0;
            R[4]<=0;      R[5]<=0;      R[6]<=-100;   R[7]<=0;
            R[8]<=0;      R[9]<=-100;   R[10]<=100000; R[11]<=0;
            R[12]<=0;     R[13]<=0;     R[14]<=0;     R[15]<=0;  
               
end 

//生成随机数部分
reg [9:0]rand_num;     //随机数
reg [9:0]rand;    //用于选择动作
initial rand_num=8'b1111_1111;
//random_num get_rand(.clk(clk_50MHz),.rst(rst),.seed(rand_num),.rand_num(rand));
always@(posedge clk_20ms)    //产生伪随机数
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
    rand<=rand_num;   //产生0到256的随机数
end

reg [4:0]show;   //仿真使用，监视状态
//选择动作部分
always@(posedge clk_20ms)      //设定每0.01s更新一次
if(!rst)
    action<=0;
else
begin
     //rand产生0到256的随机数
    if(Q_left[state]==Q_up[state]&&Q_left[state]==Q_right[state]&&Q_left[state]==Q_down[state])
    //如果每个action回报相同，随机选择action
        begin
            show<=0;
            if(rand<'d64)    action<=0;
            else if(rand<'d128)   action<=1;
            else if(rand<'d192)   action<=2;
            else //(rand<100) 
                  action<=3;  
        end
    //*****************************************************************************************************//
    else if //三个action回报一样，一个最小,随机在三个里面选
            ((Q_left[state]==Q_up[state]&&Q_left[state]==Q_right[state]&&comp03==3)   //只有下最小，其他都一样
           ||(Q_left[state]==Q_up[state]&&Q_left[state]==Q_down[state]&&comp02==3)   //只有右最小，其他都一样
           ||(Q_left[state]==Q_right[state]&&Q_left[state]==Q_down[state]&&comp01==3)   //只有上最小，其他都一样
           ||(Q_up[state]==Q_right[state]&&Q_up[state]==Q_down[state]&&comp03==1))  //只有左最小，其他都一样
    begin
        if(Q_left[state]==Q_up[state]&&Q_left[state]==Q_right[state]&&comp03==3)  //只有下最小，其他都一样
            begin
                show<=1;
                if(rand<'d77)    action<=0;
                else if(rand<'d154&&rand>='d77)   action<=1;
                else if(rand<'d231&&rand>='d154)   action<=2;
                else if(rand<'d256&&rand>='d231)action<=3;  
            end
        else if(Q_left[state]==Q_up[state]&&Q_left[state]==Q_down[state]&&comp02==3)   //只有右最小，其他都一样
            begin
                show<=2;
                if(rand<'d77)    action<=0;
                else if(rand<'d154&&rand>='d77)   action<=1;
                else if(rand<'d231&&rand>='d154)   action<=3;
                else if(rand<'d256&&rand>='d231)action<=2;   
            end 
        else if(Q_left[state]==Q_right[state]&&Q_left[state]==Q_down[state]&&comp01==3)  //只有上最小，其他都一样
            begin
                show<=3;
                if(rand<'d77)    action<=0;
                else if(rand<'d154&&rand>='d77)   action<=2;
                else if(rand<'d231&&rand>='d154)   action<=3;
                else if(rand<'d256&&rand>='d231)action<=1;  
            end 
        else if(Q_up[state]==Q_right[state]&&Q_up[state]==Q_down[state]&&comp03==1)           //只有左最小，其他都一样
            begin
                show<=4;
                if(rand<'d77)    action<=1;
                else if(rand<'d154&&rand>='d77)   action<=2;
                else if(rand<'d231&&rand>='d154)   action<=3;
                else if(rand<'d256&&rand>='d231)action<=0;  
            end 
    end
    //*****************************************************************************************************//
    else if     //两个aciton回报一样最大
           ((Q_left[state]==Q_up[state]&&comp02==3&&comp03==3)||   //左和上最大
            (Q_left[state]==Q_right[state]&&comp01==3&&comp03==3)||   //左和右最大 
            (Q_left[state]==Q_down[state]&&comp01==3&&comp02==3)||   //左和下最大 
            (Q_up[state]==Q_right[state]&&comp01==1&&comp13==3)||   //上和右最大  
            (Q_up[state]==Q_down[state]&&comp01==1&&comp12==3)||   //上和下最大 
            (Q_right[state]==Q_down[state]&&comp02==1&&comp12==1)   //右和下最大            
    )
    begin
        if(Q_left[state]==Q_up[state]&&comp02==3&&comp03==3)   //左和上最大
            begin
            show<=5;
                    if(rand<'d115)    action<=0;
                    else if(rand<'d230) action<=1;
                    else if(rand<'d243) action<=2; 
                    else action<=3;            
            end
        else if(Q_left[state]==Q_right[state]&&comp01==3&&comp03==3)  //左和右最大 
            begin
            show<=6;
                    if(rand<'d115)    action<=0;
                    else if(rand<'d230) action<=2;
                    else if(rand<'d243) action<=1; 
                    else action<=3;           
            end
        else if(Q_left[state]==Q_down[state]&&comp01==3&&comp02==3)  //左和下最大 
            begin
            show<=7;
                    if(rand<'d115)    action<=0;
                    else if(rand<'d230) action<=3;
                    else if(rand<'d243) action<=1; 
                    else action<=2;           
            end
        else if(Q_up[state]==Q_right[state]&&comp01==1&&comp13==3)   //上和右最大  
            begin
            show<=8;
                    if(rand<'d115)    action<=1;
                    else if(rand<'d230) action<=2;
                    else if(rand<'d243) action<=0; 
                    else action<=3;         
            end
        else if(Q_up[state]==Q_down[state]&&comp01==1&&comp12==3)   //上和下最大 
            begin
            show<=9;
                    if(rand<'d115)    action<=1;
                    else if(rand<'d230) action<=3;
                    else if(rand<'d243) action<=0; 
                    else action<=2;             
            end
        else if(Q_right[state]==Q_down[state]&&comp02==1&&comp12==1)   //右和下最大 
            begin
            show<=10;
                    if(rand<'d115)    action<=2;
                    else if(rand<'d230) action<=3;
                    else if(rand<'d243) action<=0; 
                    else action<=1;       
            end            
    end    
        //*****************************************************************************************************//
    else    //有最高回报的动作，epsilon-greedy选择
    begin
        if(rand<epsilon)
            begin
                if(comp01==3&&comp02==3&&comp03==3)
                begin
                    action<=0;
                    show<=11;
                end
                else if(comp01==1&&comp12==3&&comp13==3)
                begin
                    action<=1;
                    show<=12;
                end
                else if(comp02==1&&comp12==1&&comp23==3)
                begin
                    action<=2;
                    show<=13;
                end
                else if(comp03==1&&comp13==1&&comp23==1)
                begin
                    action<=3;
                    show<=14;
                end
            end
        else    //剩下一定概率随机选择
            begin
                if(rand<'d226)    action<=0;
                else if(rand<'d236)   action<=1;
                else if(rand<'d246)   action<=2; 
                else //(rand<100) 
                      action<=3; 
            end
    end
end

//get maxQ
always@(posedge clk_10ms)
begin
    
    if((comp01==3&&comp02==3&&comp03==3)||(comp01==3&&comp02==3&&comp03==2)||(comp01==3&&comp02==2&&comp03==3)||
    (comp01==2&&comp02==3&&comp03==3)||(comp01==3&&comp02==2&&comp03==2)||(comp01==2&&comp02==3&&comp03==2)||
    (comp01==2&&comp02==2&&comp03==3)||(comp01==2&&comp02==2&&comp03==2))
        in_maxQ<=Q_left[state];
    else if((comp01==1&&comp12==3&&comp13==3)||(comp01==1&&comp12==3&&comp13==2)||(comp01==1&&comp12==2&&comp13==3)||
    (comp01==2&&comp12==3&&comp13==3)||(comp01==1&&comp12==2&&comp13==2)||(comp01==2&&comp12==3&&comp13==2)||
    (comp01==2&&comp12==2&&comp13==3)||(comp01==2&&comp12==2&&comp13==2))
        in_maxQ<=Q_up[state];
    else if((comp02==1&&comp12==1&&comp23==3)||(comp02==1&&comp12==1&&comp23==2)||(comp02==1&&comp12==2&&comp23==3)||
    (comp02==2&&comp12==1&&comp23==3)||(comp02==1&&comp12==2&&comp23==2)||(comp02==2&&comp12==1&&comp23==2)||
    (comp02==2&&comp12==2&&comp23==3)||(comp02==2&&comp12==2&&comp23==2))
        in_maxQ<=Q_right[state];
    else 
        in_maxQ<=Q_down[state];
end

assign maxQ=in_maxQ;

//建立转移关系,更新QTabel
always@(posedge clk_200ms)    //设定每0.2s走一步。前面提供0.1s,0.2,0.4s来选择
begin
    if(!rst)   //如果重置
        begin    //Qtable初始状态
            state<=a;   
            pre_state<=a;
            episode<=0;
            success<=0; 
            in_maxQ<=0;
            //每一个state向左走的Q
            Q_left[0]<=-100;      Q_left[1]<=0;      Q_left[2]<=0;      Q_left[3]<=0;
            Q_left[4]<=-100;      Q_left[5]<=0;      Q_left[6]<=0;      Q_left[7]<=0;
            Q_left[8]<=-100;      Q_left[9]<=0;      Q_left[10]<=0;     Q_left[11]<=0;
            Q_left[12]<=-100;     Q_left[13]<=0;     Q_left[14]<=0;     Q_left[15]<=0;
           //每一个state向上走的Q
            Q_up[0]<=-100;      Q_up[1]<=-100;      Q_up[2]<=-100;      Q_up[3]<=-100;
            Q_up[4]<=0;      Q_up[5]<=0;      Q_up[6]<=0;      Q_up[7]<=0;
            Q_up[8]<=0;      Q_up[9]<=0;      Q_up[10]<=0;     Q_up[11]<=0;
            Q_up[12]<=0;     Q_up[13]<=0;     Q_up[14]<=0;     Q_up[15]<=0;
            //每一个state向右走dQ
            Q_right[0]<=0;      Q_right[1]<=0;      Q_right[2]<=0;      Q_right[3]<=-100;
            Q_right[4]<=0;      Q_right[5]<=0;      Q_right[6]<=0;      Q_right[7]<=-100;
            Q_right[8]<=0;      Q_right[9]<=0;      Q_right[10]<=0;     Q_right[11]<=-100;
            Q_right[12]<=0;     Q_right[13]<=0;     Q_right[14]<=0;     Q_right[15]<=-100; 
            //每一个state向下走的Q
            Q_down[0]<=0;      Q_down[1]<=0;      Q_down[2]<=0;      Q_down[3]<=0;
            Q_down[4]<=0;      Q_down[5]<=0;      Q_down[6]<=0;      Q_down[7]<=0;
            Q_down[8]<=0;      Q_down[9]<=0;      Q_down[10]<=0;     Q_down[11]<=0;
            Q_down[12]<=-100;     Q_down[13]<=-100;     Q_down[14]<=-100;     Q_down[15]<=-100;
            end
        /*a   b   c   d
          e   f   g   h
          i   j   k   l 
          m   n   o   p
        */
//****************************************************************************************************//
//***************************************************************************************************//
//**************************************************************************************************//
    else
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
               end 
    ////*state g*////
            else if(state==g)
                //掉入地狱
                begin
                    state<=a;
                    pre_state<=g; 
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
               end 
    ////*state j*////
            else if(state==j)
                begin
                //掉入地狱   
                    state<=a;
                    pre_state<=j; 
                    episode<=episode+1; 
                end 
    ////*state k*////
            else if(state==k)
                begin
                //成功
                    pre_state<=k;
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
               end             
                                     
        end
end

//更新Q值
always@(posedge clk_200ms)
    if(rst)   //如果重置
    begin
    ////*state a*////
           if(pre_state==a)
                begin
                    //更新Qtable
                    if/**/  (state==b)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                   *maxQ/10-Q_right[pre_state]);
                        end
                    if(state==e)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);  
                        end
                end
    ////*state b*////
           else if(pre_state==b)
                begin
                    //更新Qtable
                    if(state==a)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);  
                        end
                    if(state==c)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);   
                        end
                    if(state==f)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);    
                        end
               end 
    ////*state c*////
            else if(pre_state==c)
                begin
                    //更新Qtable
                    if(state==b)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);     
                        end
                    if(state==d)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);    
                        end
                    if(state==g)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);  
                        end
               end 
    ////*state d*////
            else if(pre_state==d)
                begin
                    //更新Qtable
                    if(state==c)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);     
                        end
                    if(state==h)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);   
                        end
               end                                      
    ////*state e*////
            else if(pre_state==e)
                begin
                    //更新Qtable
                    if(state==a)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);  
                        end
                    if(state==f)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);  
                        end
                    if(state==i)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);     
                        end
               end 
    ////*state f*////
            else if(pre_state==f)
                begin
                    //更新Qtable
                    if(state==e)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);    
                        end
                    if(state==b)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);  
                        end
                    if(state==g)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);  
                        end
                    if(state==j)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);   
                        end
               end 
    ////*state g*////
    ////*state h*////
            else if(pre_state==h)
                begin
                    //更新Qtable
                    if(state==g)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);   
                        end
                    if(state==d)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);  
                        end
                    if(state==l)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);     
                        end
               end
    ////*state i*////
            else if(pre_state==i)
                begin
                    if(state==e)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);  
                        end
                    if(state==j)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);     
                        end
                    if(state==m)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);     
                        end
               end 
    ////*state l*////
            else if(pre_state==l)
                begin
                    //更新Qtable
                    if(state==k)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);      
                        end
                    if(state==h)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);   
                        end
                    if(state==p)//下
                        begin
                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_down[pre_state]);  
                        end   
               end
    ////*state m*////
            else if(pre_state==m)
                begin
                    //更新Qtable
                    if(state==i)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);    
                        end
                    if(state==n)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);  
                        end
               end
    ////*state n*////
            else if(pre_state==n)
                begin
                    //更新Qtable
                    if(state==m)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);  
                        end
                    if(state==j)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);  
                        end
                    if(state==o)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);     
                        end
               end     
    ////*state o*////
            else if(pre_state==o)
                begin
                    if(state==n)//左
                        begin
                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);  
                        end
                    if(state==k)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);     
                        end
                    if(state==p)//右
                        begin
                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_right[pre_state]);  
                        end
               end  
    ////*state p*////
            else if(pre_state==p)
                begin
                    //更新Qtable
                    if(state==o)//左
                        begin
                            Q_left[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_left[pre_state]);   
                        end
                    if(state==l)//上
                        begin
                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
                                    *maxQ/10-Q_up[pre_state]);    
                        end
               end             
                                     
        end

//视频输出部分
wire border = ((CounterX[9:3]==10)||(CounterX[9:3]==24)||(CounterX[9:3]==39)||(CounterX[9:3]==54)||(CounterX[9:3]==69)
            ||(CounterY[8:3]==0)||(CounterY[8:3]==14)||(CounterY[8:3]==29)||(CounterY[8:3]==44)||(CounterY[8:3]==59)
           ) &&(CounterX[9:3]>=10)&&(CounterX[9:3]<=69); 
wire hell = (((CounterX[9:3]>39)&&(CounterX[9:3]<54)&&(CounterY[8:3]>14)&&(CounterY[8:3]<29))||
            ((CounterX[9:3]>24)&&(CounterX[9:3]<39)&&(CounterY[8:3]>29)&&(CounterY[8:3]<44)));          
wire gool = (((CounterX[9:3]==31)||(CounterX[9:3]==32))&&(CounterY[8:3]==17)||
             ((CounterX[9:3]==30)||(CounterX[9:3]==33))&&(CounterY[8:3]==18)|| 
             ((CounterX[9:3]==29)||(CounterX[9:3]==34))&&(CounterY[8:3]==19)||
             ((CounterX[9:3]==28)||(CounterX[9:3]==35))&&(CounterY[8:3]==20)||
             ((CounterX[9:3]==27)||(CounterX[9:3]==36))&&(CounterY[8:3]==21)|| 
             ((CounterX[9:3]==31)||(CounterX[9:3]==32))&&(CounterY[8:3]==26)||
             ((CounterX[9:3]==30)||(CounterX[9:3]==33))&&(CounterY[8:3]==25)|| 
             ((CounterX[9:3]==29)||(CounterX[9:3]==34))&&(CounterY[8:3]==24)||
             ((CounterX[9:3]==28)||(CounterX[9:3]==35))&&(CounterY[8:3]==23)||
             ((CounterX[9:3]==27)||(CounterX[9:3]==36))&&(CounterY[8:3]==22)); 
             
             
   
wire Red ;
wire Green ;
wire Blue ;

reg agent;
always@(posedge clk)
begin
   case(state)
      a:agent<=((CounterX[9:3]>=60)&&(CounterX[9:3]<=63))&&((CounterY[8:3]>=50)&&(CounterY[8:3]<=53));
      b:agent<=((CounterX[9:3]>=45)&&(CounterX[9:3]<=48))&&((CounterY[8:3]>=50)&&(CounterY[8:3]<=53));
      c:agent<=((CounterX[9:3]>=30)&&(CounterX[9:3]<=33))&&((CounterY[8:3]>=50)&&(CounterY[8:3]<=53));
      d:agent<=((CounterX[9:3]>=15)&&(CounterX[9:3]<=18))&&((CounterY[8:3]>=50)&&(CounterY[8:3]<=53));
      e:agent<=((CounterX[9:3]>=60)&&(CounterX[9:3]<=63))&&((CounterY[8:3]>=35)&&(CounterY[8:3]<=38));
      f:agent<=((CounterX[9:3]>=45)&&(CounterX[9:3]<=48))&&((CounterY[8:3]>=35)&&(CounterY[8:3]<=38));
      g:agent<=((CounterX[9:3]>=30)&&(CounterX[9:3]<=33))&&((CounterY[8:3]>=35)&&(CounterY[8:3]<=38));
      h:agent<=((CounterX[9:3]>=15)&&(CounterX[9:3]<=18))&&((CounterY[8:3]>=35)&&(CounterY[8:3]<=38));
      i:agent<=((CounterX[9:3]>=60)&&(CounterX[9:3]<=63))&&((CounterY[8:3]>=20)&&(CounterY[8:3]<=23));
      j:agent<=((CounterX[9:3]>=45)&&(CounterX[9:3]<=48))&&((CounterY[8:3]>=20)&&(CounterY[8:3]<=23));
      k:agent<=((CounterX[9:3]>=30)&&(CounterX[9:3]<=33))&&((CounterY[8:3]>=20)&&(CounterY[8:3]<=23));
      l:agent<=((CounterX[9:3]>=15)&&(CounterX[9:3]<=18))&&((CounterY[8:3]>=20)&&(CounterY[8:3]<=23));
      m:agent<=((CounterX[9:3]>=60)&&(CounterX[9:3]<=63))&&((CounterY[8:3]>=5)&&(CounterY[8:3]<=8));
      n:agent<=((CounterX[9:3]>=45)&&(CounterX[9:3]<=48))&&((CounterY[8:3]>=5)&&(CounterY[8:3]<=8));
      o:agent<=((CounterX[9:3]>=30)&&(CounterX[9:3]<=33))&&((CounterY[8:3]>=5)&&(CounterY[8:3]<=8));
      p:agent<=((CounterX[9:3]>=15)&&(CounterX[9:3]<=18))&&((CounterY[8:3]>=5)&&(CounterY[8:3]<=8));      
   endcase
end
assign Red = border||hell||gool;
assign Green = border||gool||agent;
assign Blue = border||agent;

assign  VGA_R = {4{Red}} & {4{inDisplayArea}};
assign  VGA_G = {4{Green}} & {4{inDisplayArea}};
assign  VGA_B = {4{Blue}} & {4{inDisplayArea}};

endmodule
                                 
