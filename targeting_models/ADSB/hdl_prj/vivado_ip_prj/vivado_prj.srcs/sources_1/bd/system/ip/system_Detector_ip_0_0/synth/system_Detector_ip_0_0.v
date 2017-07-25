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


// IP VLNV: analog.com:ip:Detector_ip:1.0
// IP Revision: 1707241334

(* X_CORE_INFO = "Detector_ip,Vivado 2016.2" *)
(* CHECK_LICENSE_TYPE = "system_Detector_ip_0_0,Detector_ip,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_Detector_ip_0_0 (
  IPCORE_CLK,
  IPCORE_RESETN,
  sys_wfifo_0_dma_wdata,
  sys_wfifo_1_dma_wdata,
  AXI4_Lite_ACLK,
  AXI4_Lite_ARESETN,
  AXI4_Lite_AWADDR,
  AXI4_Lite_AWVALID,
  AXI4_Lite_WDATA,
  AXI4_Lite_WSTRB,
  AXI4_Lite_WVALID,
  AXI4_Lite_BREADY,
  AXI4_Lite_ARADDR,
  AXI4_Lite_ARVALID,
  AXI4_Lite_RREADY,
  dut_data_valid,
  dut_data_0,
  dut_data_1,
  AXI4_Lite_AWREADY,
  AXI4_Lite_WREADY,
  AXI4_Lite_BRESP,
  AXI4_Lite_BVALID,
  AXI4_Lite_ARREADY,
  AXI4_Lite_RDATA,
  AXI4_Lite_RRESP,
  AXI4_Lite_RVALID
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 IPCORE_CLK CLK" *)
input wire IPCORE_CLK;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 IPCORE_RESETN RST" *)
input wire IPCORE_RESETN;
input wire [15 : 0] sys_wfifo_0_dma_wdata;
input wire [15 : 0] sys_wfifo_1_dma_wdata;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 AXI4_Lite_signal_clock CLK" *)
input wire AXI4_Lite_ACLK;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 AXI4_Lite_signal_reset RST" *)
input wire AXI4_Lite_ARESETN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite AWADDR" *)
input wire [15 : 0] AXI4_Lite_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite AWVALID" *)
input wire AXI4_Lite_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite WDATA" *)
input wire [31 : 0] AXI4_Lite_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite WSTRB" *)
input wire [3 : 0] AXI4_Lite_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite WVALID" *)
input wire AXI4_Lite_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite BREADY" *)
input wire AXI4_Lite_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite ARADDR" *)
input wire [15 : 0] AXI4_Lite_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite ARVALID" *)
input wire AXI4_Lite_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite RREADY" *)
input wire AXI4_Lite_RREADY;
output wire dut_data_valid;
output wire [15 : 0] dut_data_0;
output wire [15 : 0] dut_data_1;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite AWREADY" *)
output wire AXI4_Lite_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite WREADY" *)
output wire AXI4_Lite_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite BRESP" *)
output wire [1 : 0] AXI4_Lite_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite BVALID" *)
output wire AXI4_Lite_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite ARREADY" *)
output wire AXI4_Lite_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite RDATA" *)
output wire [31 : 0] AXI4_Lite_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite RRESP" *)
output wire [1 : 0] AXI4_Lite_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI4_Lite RVALID" *)
output wire AXI4_Lite_RVALID;

  Detector_ip inst (
    .IPCORE_CLK(IPCORE_CLK),
    .IPCORE_RESETN(IPCORE_RESETN),
    .sys_wfifo_0_dma_wdata(sys_wfifo_0_dma_wdata),
    .sys_wfifo_1_dma_wdata(sys_wfifo_1_dma_wdata),
    .AXI4_Lite_ACLK(AXI4_Lite_ACLK),
    .AXI4_Lite_ARESETN(AXI4_Lite_ARESETN),
    .AXI4_Lite_AWADDR(AXI4_Lite_AWADDR),
    .AXI4_Lite_AWVALID(AXI4_Lite_AWVALID),
    .AXI4_Lite_WDATA(AXI4_Lite_WDATA),
    .AXI4_Lite_WSTRB(AXI4_Lite_WSTRB),
    .AXI4_Lite_WVALID(AXI4_Lite_WVALID),
    .AXI4_Lite_BREADY(AXI4_Lite_BREADY),
    .AXI4_Lite_ARADDR(AXI4_Lite_ARADDR),
    .AXI4_Lite_ARVALID(AXI4_Lite_ARVALID),
    .AXI4_Lite_RREADY(AXI4_Lite_RREADY),
    .dut_data_valid(dut_data_valid),
    .dut_data_0(dut_data_0),
    .dut_data_1(dut_data_1),
    .AXI4_Lite_AWREADY(AXI4_Lite_AWREADY),
    .AXI4_Lite_WREADY(AXI4_Lite_WREADY),
    .AXI4_Lite_BRESP(AXI4_Lite_BRESP),
    .AXI4_Lite_BVALID(AXI4_Lite_BVALID),
    .AXI4_Lite_ARREADY(AXI4_Lite_ARREADY),
    .AXI4_Lite_RDATA(AXI4_Lite_RDATA),
    .AXI4_Lite_RRESP(AXI4_Lite_RRESP),
    .AXI4_Lite_RVALID(AXI4_Lite_RVALID)
  );
endmodule
