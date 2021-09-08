-makelib ies_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../project_1.srcs/sources_1/ip/clk_wiz_12MHz/clk_wiz_12MHz_clk_wiz.v" \
  "../../../../project_1.srcs/sources_1/ip/clk_wiz_12MHz/clk_wiz_12MHz.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

