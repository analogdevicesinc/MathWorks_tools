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


// IP VLNV: analog.com:user:axi_gpreg:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_axi_gpreg_0 (
  up_gp_ioenb_0,
  up_gp_out_0,
  up_gp_in_0,
  up_gp_ioenb_1,
  up_gp_out_1,
  up_gp_in_1,
  up_gp_ioenb_2,
  up_gp_out_2,
  up_gp_in_2,
  up_gp_ioenb_3,
  up_gp_out_3,
  up_gp_in_3,
  s_axi_aclk,
  s_axi_aresetn,
  s_axi_awvalid,
  s_axi_awaddr,
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
  s_axi_arready,
  s_axi_rvalid,
  s_axi_rdata,
  s_axi_rresp,
  s_axi_rready,
  s_axi_awprot,
  s_axi_arprot
);

output wire [31 : 0] up_gp_ioenb_0;
output wire [31 : 0] up_gp_out_0;
input wire [31 : 0] up_gp_in_0;
output wire [31 : 0] up_gp_ioenb_1;
output wire [31 : 0] up_gp_out_1;
input wire [31 : 0] up_gp_in_1;
output wire [31 : 0] up_gp_ioenb_2;
output wire [31 : 0] up_gp_out_2;
input wire [31 : 0] up_gp_in_2;
output wire [31 : 0] up_gp_ioenb_3;
output wire [31 : 0] up_gp_out_3;
input wire [31 : 0] up_gp_in_3;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
input wire s_axi_aclk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire s_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
input wire s_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
input wire [31 : 0] s_axi_awaddr;
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
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *)
input wire [2 : 0] s_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *)
input wire [2 : 0] s_axi_arprot;

  axi_gpreg #(
    .ID(0),
    .NUM_OF_IO(4),
    .NUM_OF_CLK_MONS(0),
    .BUF_ENABLE_0(1),
    .BUF_ENABLE_1(1),
    .BUF_ENABLE_2(1),
    .BUF_ENABLE_3(1),
    .BUF_ENABLE_4(1),
    .BUF_ENABLE_5(1),
    .BUF_ENABLE_6(1),
    .BUF_ENABLE_7(1)
  ) inst (
    .up_gp_ioenb_0(up_gp_ioenb_0),
    .up_gp_out_0(up_gp_out_0),
    .up_gp_in_0(up_gp_in_0),
    .up_gp_ioenb_1(up_gp_ioenb_1),
    .up_gp_out_1(up_gp_out_1),
    .up_gp_in_1(up_gp_in_1),
    .up_gp_ioenb_2(up_gp_ioenb_2),
    .up_gp_out_2(up_gp_out_2),
    .up_gp_in_2(up_gp_in_2),
    .up_gp_ioenb_3(up_gp_ioenb_3),
    .up_gp_out_3(up_gp_out_3),
    .up_gp_in_3(up_gp_in_3),
    .up_gp_ioenb_4(),
    .up_gp_out_4(),
    .up_gp_in_4(32'B0),
    .up_gp_ioenb_5(),
    .up_gp_out_5(),
    .up_gp_in_5(32'B0),
    .up_gp_ioenb_6(),
    .up_gp_out_6(),
    .up_gp_in_6(32'B0),
    .up_gp_ioenb_7(),
    .up_gp_out_7(),
    .up_gp_in_7(32'B0),
    .d_clk_0(1'B0),
    .d_clk_1(1'B0),
    .d_clk_2(1'B0),
    .d_clk_3(1'B0),
    .d_clk_4(1'B0),
    .d_clk_5(1'B0),
    .d_clk_6(1'B0),
    .d_clk_7(1'B0),
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
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
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rready(s_axi_rready),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_arprot(s_axi_arprot)
  );
endmodule
