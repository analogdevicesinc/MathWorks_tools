// (c) Copyright 1995-2017 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: analog.com:user:axi_ad9361:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_axi_ad9361_0 (
  rx_clk_in_p,
  rx_clk_in_n,
  rx_frame_in_p,
  rx_frame_in_n,
  rx_data_in_p,
  rx_data_in_n,
  tx_clk_out_p,
  tx_clk_out_n,
  tx_frame_out_p,
  tx_frame_out_n,
  tx_data_out_p,
  tx_data_out_n,
  enable,
  txnrx,
  dac_sync_in,
  dac_sync_out,
  tdd_sync,
  tdd_sync_cntr,
  delay_clk,
  l_clk,
  clk,
  rst,
  adc_enable_i0,
  adc_valid_i0,
  adc_data_i0,
  adc_enable_q0,
  adc_valid_q0,
  adc_data_q0,
  adc_enable_i1,
  adc_valid_i1,
  adc_data_i1,
  adc_enable_q1,
  adc_valid_q1,
  adc_data_q1,
  adc_dovf,
  adc_dunf,
  adc_r1_mode,
  dac_enable_i0,
  dac_valid_i0,
  dac_data_i0,
  dac_enable_q0,
  dac_valid_q0,
  dac_data_q0,
  dac_enable_i1,
  dac_valid_i1,
  dac_data_i1,
  dac_enable_q1,
  dac_valid_q1,
  dac_data_q1,
  dac_dovf,
  dac_dunf,
  dac_r1_mode,
  s_axi_aclk,
  s_axi_aresetn,
  s_axi_awvalid,
  s_axi_awaddr,
  s_axi_awprot,
  s_axi_awready,
  s_axi_wvalid,
  s_axi_wdata,
  s_axi_wstrb,
  s_axi_wready,
  s_axi_bvalid,
  s_axi_bresp,
  s_axi_bready,
  s_axi_arvalid,
  s_axi_araddr,
  s_axi_arprot,
  s_axi_arready,
  s_axi_rvalid,
  s_axi_rdata,
  s_axi_rresp,
  s_axi_rready,
  up_enable,
  up_txnrx,
  up_dac_gpio_in,
  up_dac_gpio_out,
  up_adc_gpio_in,
  up_adc_gpio_out
);

input wire rx_clk_in_p;
input wire rx_clk_in_n;
input wire rx_frame_in_p;
input wire rx_frame_in_n;
input wire [5 : 0] rx_data_in_p;
input wire [5 : 0] rx_data_in_n;
output wire tx_clk_out_p;
output wire tx_clk_out_n;
output wire tx_frame_out_p;
output wire tx_frame_out_n;
output wire [5 : 0] tx_data_out_p;
output wire [5 : 0] tx_data_out_n;
output wire enable;
output wire txnrx;
input wire dac_sync_in;
output wire dac_sync_out;
input wire tdd_sync;
output wire tdd_sync_cntr;
input wire delay_clk;
output wire l_clk;
input wire clk;
output wire rst;
output wire adc_enable_i0;
output wire adc_valid_i0;
output wire [15 : 0] adc_data_i0;
output wire adc_enable_q0;
output wire adc_valid_q0;
output wire [15 : 0] adc_data_q0;
output wire adc_enable_i1;
output wire adc_valid_i1;
output wire [15 : 0] adc_data_i1;
output wire adc_enable_q1;
output wire adc_valid_q1;
output wire [15 : 0] adc_data_q1;
input wire adc_dovf;
input wire adc_dunf;
output wire adc_r1_mode;
output wire dac_enable_i0;
output wire dac_valid_i0;
input wire [15 : 0] dac_data_i0;
output wire dac_enable_q0;
output wire dac_valid_q0;
input wire [15 : 0] dac_data_q0;
output wire dac_enable_i1;
output wire dac_valid_i1;
input wire [15 : 0] dac_data_i1;
output wire dac_enable_q1;
output wire dac_valid_q1;
input wire [15 : 0] dac_data_q1;
input wire dac_dovf;
input wire dac_dunf;
output wire dac_r1_mode;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
input wire s_axi_aclk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire s_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
input wire s_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
input wire [31 : 0] s_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *)
input wire [2 : 0] s_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
output wire s_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
input wire s_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
input wire [31 : 0] s_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *)
input wire [3 : 0] s_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
output wire s_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
output wire s_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
output wire [1 : 0] s_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
input wire s_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
input wire s_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
input wire [31 : 0] s_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *)
input wire [2 : 0] s_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
output wire s_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
output wire s_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31 : 0] s_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1 : 0] s_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire s_axi_rready;
input wire up_enable;
input wire up_txnrx;
input wire [31 : 0] up_dac_gpio_in;
output wire [31 : 0] up_dac_gpio_out;
input wire [31 : 0] up_adc_gpio_in;
output wire [31 : 0] up_adc_gpio_out;

  axi_ad9361 #(
    .ID(0),
    .MODE_1R1T(0),
    .DEVICE_TYPE(0),
    .TDD_DISABLE(0),
    .CMOS_OR_LVDS_N(0),
    .ADC_DATAPATH_DISABLE(0),
    .ADC_USERPORTS_DISABLE(0),
    .ADC_DATAFORMAT_DISABLE(0),
    .ADC_DCFILTER_DISABLE(0),
    .ADC_IQCORRECTION_DISABLE(0),
    .DAC_IODELAY_ENABLE(1),
    .DAC_DATAPATH_DISABLE(0),
    .DAC_DDS_DISABLE(0),
    .DAC_USERPORTS_DISABLE(0),
    .DAC_IQCORRECTION_DISABLE(0),
    .IO_DELAY_GROUP("dev_if_delay_group")
  ) inst (
    .rx_clk_in_p(rx_clk_in_p),
    .rx_clk_in_n(rx_clk_in_n),
    .rx_frame_in_p(rx_frame_in_p),
    .rx_frame_in_n(rx_frame_in_n),
    .rx_data_in_p(rx_data_in_p),
    .rx_data_in_n(rx_data_in_n),
    .rx_clk_in(1'B0),
    .rx_frame_in(1'B0),
    .rx_data_in(12'B0),
    .tx_clk_out_p(tx_clk_out_p),
    .tx_clk_out_n(tx_clk_out_n),
    .tx_frame_out_p(tx_frame_out_p),
    .tx_frame_out_n(tx_frame_out_n),
    .tx_data_out_p(tx_data_out_p),
    .tx_data_out_n(tx_data_out_n),
    .tx_clk_out(),
    .tx_frame_out(),
    .tx_data_out(),
    .enable(enable),
    .txnrx(txnrx),
    .dac_sync_in(dac_sync_in),
    .dac_sync_out(dac_sync_out),
    .tdd_sync(tdd_sync),
    .tdd_sync_cntr(tdd_sync_cntr),
    .delay_clk(delay_clk),
    .l_clk(l_clk),
    .clk(clk),
    .rst(rst),
    .adc_enable_i0(adc_enable_i0),
    .adc_valid_i0(adc_valid_i0),
    .adc_data_i0(adc_data_i0),
    .adc_enable_q0(adc_enable_q0),
    .adc_valid_q0(adc_valid_q0),
    .adc_data_q0(adc_data_q0),
    .adc_enable_i1(adc_enable_i1),
    .adc_valid_i1(adc_valid_i1),
    .adc_data_i1(adc_data_i1),
    .adc_enable_q1(adc_enable_q1),
    .adc_valid_q1(adc_valid_q1),
    .adc_data_q1(adc_data_q1),
    .adc_dovf(adc_dovf),
    .adc_dunf(adc_dunf),
    .adc_r1_mode(adc_r1_mode),
    .dac_enable_i0(dac_enable_i0),
    .dac_valid_i0(dac_valid_i0),
    .dac_data_i0(dac_data_i0),
    .dac_enable_q0(dac_enable_q0),
    .dac_valid_q0(dac_valid_q0),
    .dac_data_q0(dac_data_q0),
    .dac_enable_i1(dac_enable_i1),
    .dac_valid_i1(dac_valid_i1),
    .dac_data_i1(dac_data_i1),
    .dac_enable_q1(dac_enable_q1),
    .dac_valid_q1(dac_valid_q1),
    .dac_data_q1(dac_data_q1),
    .dac_dovf(dac_dovf),
    .dac_dunf(dac_dunf),
    .dac_r1_mode(dac_r1_mode),
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awready(s_axi_awready),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rready(s_axi_rready),
    .up_enable(up_enable),
    .up_txnrx(up_txnrx),
    .up_dac_gpio_in(up_dac_gpio_in),
    .up_dac_gpio_out(up_dac_gpio_out),
    .up_adc_gpio_in(up_adc_gpio_in),
    .up_adc_gpio_out(up_adc_gpio_out)
  );
endmodule
