module button_edge(    //��ֹ�����ض�����Ŀǰû������
input clk,
input button,
output button_redge);
reg button_r1,button_r2;

always@(posedge clk)
     button_r1 <= button;
always@(posedge clk)
     button_r2 <= button_r1;
assign button_redge = button_r1 & (~button_r2);
    endmodule
