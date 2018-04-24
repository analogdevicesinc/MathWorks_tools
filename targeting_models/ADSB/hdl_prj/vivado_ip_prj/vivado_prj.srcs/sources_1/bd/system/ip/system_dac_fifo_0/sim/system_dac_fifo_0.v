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


// IP VLNV: analog.com:user:util_rfifo:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_dac_fifo_0 (
  din_rstn,
  din_clk,
  din_enable_0,
  din_valid_0,
  din_data_0,
  din_enable_1,
  din_valid_1,
  din_data_1,
  din_enable_2,
  din_valid_2,
  din_data_2,
  din_enable_3,
  din_valid_3,
  din_data_3,
  din_unf,
  dout_rst,
  dout_clk,
  dout_enable_0,
  dout_valid_0,
  dout_data_0,
  dout_enable_1,
  dout_valid_1,
  dout_data_1,
  dout_enable_2,
  dout_valid_2,
  dout_data_2,
  dout_enable_3,
  dout_valid_3,
  dout_data_3,
  dout_unf
);

input wire din_rstn;
input wire din_clk;
output wire din_enable_0;
output wire din_valid_0;
input wire [15 : 0] din_data_0;
output wire din_enable_1;
output wire din_valid_1;
input wire [15 : 0] din_data_1;
output wire din_enable_2;
output wire din_valid_2;
input wire [15 : 0] din_data_2;
output wire din_enable_3;
output wire din_valid_3;
input wire [15 : 0] din_data_3;
input wire din_unf;
input wire dout_rst;
input wire dout_clk;
input wire dout_enable_0;
input wire dout_valid_0;
output wire [15 : 0] dout_data_0;
input wire dout_enable_1;
input wire dout_valid_1;
output wire [15 : 0] dout_data_1;
input wire dout_enable_2;
input wire dout_valid_2;
output wire [15 : 0] dout_data_2;
input wire dout_enable_3;
input wire dout_valid_3;
output wire [15 : 0] dout_data_3;
output wire dout_unf;

  util_rfifo #(
    .NUM_OF_CHANNELS(4),
    .DIN_DATA_WIDTH(16),
    .DOUT_DATA_WIDTH(16),
    .DIN_ADDRESS_WIDTH(4)
  ) inst (
    .din_rstn(din_rstn),
    .din_clk(din_clk),
    .din_enable_0(din_enable_0),
    .din_valid_0(din_valid_0),
    .din_data_0(din_data_0),
    .din_enable_1(din_enable_1),
    .din_valid_1(din_valid_1),
    .din_data_1(din_data_1),
    .din_enable_2(din_enable_2),
    .din_valid_2(din_valid_2),
    .din_data_2(din_data_2),
    .din_enable_3(din_enable_3),
    .din_valid_3(din_valid_3),
    .din_data_3(din_data_3),
    .din_enable_4(),
    .din_valid_4(),
    .din_data_4(16'B0),
    .din_enable_5(),
    .din_valid_5(),
    .din_data_5(16'B0),
    .din_enable_6(),
    .din_valid_6(),
    .din_data_6(16'B0),
    .din_enable_7(),
    .din_valid_7(),
    .din_data_7(16'B0),
    .din_unf(din_unf),
    .dout_rst(dout_rst),
    .dout_clk(dout_clk),
    .dout_enable_0(dout_enable_0),
    .dout_valid_0(dout_valid_0),
    .dout_data_0(dout_data_0),
    .dout_enable_1(dout_enable_1),
    .dout_valid_1(dout_valid_1),
    .dout_data_1(dout_data_1),
    .dout_enable_2(dout_enable_2),
    .dout_valid_2(dout_valid_2),
    .dout_data_2(dout_data_2),
    .dout_enable_3(dout_enable_3),
    .dout_valid_3(dout_valid_3),
    .dout_data_3(dout_data_3),
    .dout_enable_4(1'B0),
    .dout_valid_4(1'B0),
    .dout_data_4(),
    .dout_enable_5(1'B0),
    .dout_valid_5(1'B0),
    .dout_data_5(),
    .dout_enable_6(1'B0),
    .dout_valid_6(1'B0),
    .dout_data_6(),
    .dout_enable_7(1'B0),
    .dout_valid_7(1'B0),
    .dout_data_7(),
    .dout_unf(dout_unf)
  );
endmodule
