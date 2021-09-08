`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/14 13:19:07
// Design Name: 
// Module Name: music
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


module buffer_music ( audio , music_clk ,button);

output    audio;
input     music_clk;
input     button;
  
reg  [23:0]   counter4Hz,
              counter1MHz,
              counter6MHz;
reg  [13:0]  count,origin;
reg  audiof;

reg   clk_6MHz,
      clk_4Hz;
reg   clk_1MHz;
reg  [4:0]  j;
reg  [7:0]  len;

//assign audio=audiof ;  //控制开关
assign audio= button? audiof : 1'b1 ;//控制开关

  always @(posedge music_clk)              //6MHz分频   开发板晶振为100MHz 
  begin
     if(counter6MHz==8)
      begin
          counter6MHz=0;
          clk_6MHz=~clk_6MHz;
      end
      else
      begin
          counter6MHz=counter6MHz+1;
     // end
                end
  end
//  
//  
//  
  always @(posedge music_clk)                 //4Hz分频  
  begin
    //  if(counter4Hz==2500000)     
   if(counter4Hz==12500000)         //100M/4/2
      begin
          counter4Hz=0;
          clk_4Hz=~clk_4Hz;
      end
      else
      begin
          counter4Hz=counter4Hz+1;
      end
  end
  
  
  always @(posedge clk_6MHz)
  begin
      if(count==16383)    
      begin
          count=origin;
          audiof=~audiof;
      end
      else
          count=count+1;
  end
  
  
  always @(posedge clk_4Hz)       
  begin
       case(j)
      'd0:origin='b0;
      'd1:origin='d4916;  //low
      'd2:origin='d6168;
      'd3:origin='d7281;
      'd4:origin='d7791;
      'd5:origin='d8730;
      'd6:origin='d9565;
      'd7:origin='d10310;
      'd8:origin='d010647;  //middle
      'd9:origin='d011272;
      'd10:origin='d011831;
      'd11:origin='d012087;
      'd12:origin='d012556;
      'd13:origin='d012974;
      'd14:origin='d013346;
      'd15:origin='d13516;  //high
      'd16:origin='d13829;
     'd17:origin='d14108;
      'd18:origin='d11535;
      'd19:origin='d14470;
      'd20:origin='d14678;
      'd21:origin='d14864;
      default:origin='d011111;
     endcase             
  end

always @(posedge clk_4Hz)  
begin
      if(len==115)
         len=0;
     else
         len=len+1;
     case(len)
      0:j=8;
      1:j=8;
      2:j=8;
      3:j=8;
      4:j=9;
      5:j=9;
      6:j=9;
      7:j=9;
      8:j=10;
      9:j=10;
      10:j=10;
      11:j=10;
      12:j=8;
      13:j=8;
      14:j=8;
      15:j=8;
      16:j=8;
      17:j=8;
      18:j=8;
      19:j=8;
      20:j=9;
      21:j=9;
      22:j=9;
      23:j=9;
      24:j=10;
      25:j=10;
      26:j=10;
      27:j=10;
      28:j=8;
      29:j=8;
      30:j=8;
      31:j=8;
      32:j=10;
      33:j=10;
      34:j=10;
      35:j=10;
      36:j=11;
      37:j=11;
      38:j=11;
      39:j=11;
      40:j=12;
      41:j=12;
      42:j=12;
      43:j=12;
      44:j=12;
      45:j=12;
      46:j=12;
      47:j=12;
      48:j=10;
      49:j=10;
      50:j=10;
      51:j=10;
      52:j=11;
      53:j=11;
      54:j=11;
      55:j=11;
      56:j=12;
      57:j=12;
      58:j=12;
      59:j=12;
      
      60:j=12;
      61:j=12;
      62:j=13;
      63:j=13;
      64:j=12;
      65:j=12;
      66:j=11;
      67:j=11;
      68:j=10;
      69:j=10;
      70:j=10;
      71:j=10;
      72:j=8;
      73:j=8;
      74:j=8;
      75:j=8;
      
      76:j=12;
      77:j=12;
      78:j=13;
      79:j=13;
      80:j=12;
      81:j=12;
      82:j=11;
      83:j=11;
      84:j=10;
      85:j=10;
      86:j=10;
      87:j=10;
      88:j=8;
      89:j=8;
      90:j=8;
      91:j=8;
      
      92:j=10;
      93:j=10;
      94:j=10;
      95:j=10;  
      96:j=5;
      97:j=5;
      98:j=5; 
      99:j=5;
      100:j=8;
      101:j=8;
      102:j=8;
      103:j=8;
      
      104:j=10;
      105:j=10;
      106:j=10;
      107:j=10;  
      108:j=5;
      109:j=5;
      110:j=5; 
      111:j=5;
      112:j=8;
      113:j=8;
      114:j=8;
      115:j=8;
            
endcase
                 
end
endmodule
