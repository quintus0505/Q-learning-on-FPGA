module button_edge(    //防止按开关抖动，目前没有用上
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
