//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2019/12/13 14:59:31
//// Design Name: 
//// Module Name: renewQ
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module renewQ(
//input clk,
//input rst,
//input [4:0]in_state,
//input [4:0]in_pre_state,
//input [2:0]action,

//);
//reg [4:0] state;
//reg [4:0] pre_state;
//parameter a = 0;  parameter i = 8;
//parameter b = 1;  parameter j = 9;
//parameter c = 2;  parameter k = 10;
//parameter d = 3;  parameter l = 11;
//parameter e = 4;  parameter m = 12;
//parameter f = 5;  parameter n = 13;
//parameter g = 6;  parameter o = 14;
//parameter h = 7;  parameter p = 15;

//parameter left = 0;
//parameter up = 1;
//parameter right = 2;
//parameter down = 3;

//always@(posedge clk)
//    if(!rst)   //�������

//    begin
//    ////*state a*////
//           if(pre_state==a)
//                begin
//                    //����Qtable
//                    if/**/  (state==b)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);  
//                        end
//                    if(state==e)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);  
//                        end
//                end
//    ////*state b*////
//           else if(pre_state==b)
//                begin
//                    //����Qtable
//                    if(state==a)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);  
//                        end
//                    if(state==c)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);   
//                        end
//                    if(state==f)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);    
//                        end
//               end 
//    ////*state c*////
//            else if(pre_state==c)
//                begin
//                    //����Qtable
//                    if(state==b)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);     
//                        end
//                    if(state==d)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);    
//                        end
//                    if(state==g)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);  
//                        end
//               end 
//    ////*state d*////
//            else if(pre_state==d)
//                begin
//                    //����Qtable
//                    if(state==c)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);     
//                        end
//                    if(state==h)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);   
//                        end
//               end                                      
//    ////*state e*////
//            else if(pre_state==e)
//                begin
//                    //����Qtable
//                    if(state==a)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);  
//                        end
//                    if(state==f)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);  
//                        end
//                    if(state==i)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);     
//                        end
//               end 
//    ////*state f*////
//            else if(pre_state==f)
//                begin
//                    //����Qtable
//                    if(state==e)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);    
//                        end
//                    if(state==b)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);  
//                        end
//                    if(state==g)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);  
//                        end
//                    if(state==j)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);   
//                        end
//               end 
//    ////*state g*////
//    ////*state h*////
//            else if(pre_state==h)
//                begin
//                    //����Qtable
//                    if(state==g)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);   
//                        end
//                    if(state==d)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);  
//                        end
//                    if(state==l)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);     
//                        end
//               end
//    ////*state i*////
//            else if(pre_state==i)
//                begin
//                    if(state==e)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);  
//                        end
//                    if(state==j)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);     
//                        end
//                    if(state==m)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);     
//                        end
//               end 
//    ////*state l*////
//            else if(pre_state==l)
//                begin
//                    //����Qtable
//                    if(state==k)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);      
//                        end
//                    if(state==h)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);   
//                        end
//                    if(state==p)//��
//                        begin
//                            Q_down[pre_state]<=Q_down[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_down[pre_state]);  
//                        end   
//               end
//    ////*state m*////
//            else if(pre_state==m)
//                begin
//                    //����Qtable
//                    if(state==i)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);    
//                        end
//                    if(state==n)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);  
//                        end
//               end
//    ////*state n*////
//            else if(pre_state==n)
//                begin
//                    //����Qtable
//                    if(state==m)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);  
//                        end
//                    if(state==j)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);  
//                        end
//                    if(state==o)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);     
//                        end
//               end     
//    ////*state o*////
//            else if(pre_state==o)
//                begin
//                    if(state==n)//��
//                        begin
//                            Q_left[pre_state]<=Q_left[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);  
//                        end
//                    if(state==k)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);     
//                        end
//                    if(state==p)//��
//                        begin
//                            Q_right[pre_state]<=Q_right[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_right[pre_state]);  
//                        end
//               end  
//    ////*state p*////
//            else if(pre_state==p)
//                begin
//                    //����Qtable
//                    if(state==o)//��
//                        begin
//                            Q_left[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_left[pre_state]);   
//                        end
//                    if(state==l)//��
//                        begin
//                            Q_up[pre_state]<=Q_up[pre_state]+learning_rate*(R[state]+decay
//                                    *maxQ-Q_up[pre_state]);    
//                        end
//               end             
                                     
//        end
//endmodule
