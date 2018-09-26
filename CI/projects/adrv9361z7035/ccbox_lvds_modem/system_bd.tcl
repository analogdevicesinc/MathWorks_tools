
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z035ifbg676-2L
}


# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ddr [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr ]
  set fixed_io [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 fixed_io ]
  set i2s [ create_bd_intf_port -mode Master -vlnv analog.com:interface:i2s_rtl:1.0 i2s ]
  set iic_main [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_main ]

  # Create ports
  set enable [ create_bd_port -dir O enable ]
  set gpio_i [ create_bd_port -dir I -from 63 -to 0 gpio_i ]
  set gpio_o [ create_bd_port -dir O -from 63 -to 0 gpio_o ]
  set gpio_t [ create_bd_port -dir O -from 63 -to 0 gpio_t ]
  set gps_pps [ create_bd_port -dir I gps_pps ]
  set i2s_mclk [ create_bd_port -dir O -type clk i2s_mclk ]
  set otg_vbusoc [ create_bd_port -dir I otg_vbusoc ]
  set ps_intr_00 [ create_bd_port -dir I -type intr ps_intr_00 ]
  set ps_intr_01 [ create_bd_port -dir I -type intr ps_intr_01 ]
  set ps_intr_02 [ create_bd_port -dir I -type intr ps_intr_02 ]
  set ps_intr_03 [ create_bd_port -dir I -type intr ps_intr_03 ]
  set ps_intr_04 [ create_bd_port -dir I -type intr ps_intr_04 ]
  set ps_intr_05 [ create_bd_port -dir I -type intr ps_intr_05 ]
  set ps_intr_06 [ create_bd_port -dir I -type intr ps_intr_06 ]
  set ps_intr_07 [ create_bd_port -dir I -type intr ps_intr_07 ]
  set ps_intr_08 [ create_bd_port -dir I -type intr ps_intr_08 ]
  set ps_intr_15 [ create_bd_port -dir I -type intr ps_intr_15 ]
  set rx_clk_in_n [ create_bd_port -dir I rx_clk_in_n ]
  set rx_clk_in_p [ create_bd_port -dir I rx_clk_in_p ]
  set rx_data_in_n [ create_bd_port -dir I -from 5 -to 0 rx_data_in_n ]
  set rx_data_in_p [ create_bd_port -dir I -from 5 -to 0 rx_data_in_p ]
  set rx_frame_in_n [ create_bd_port -dir I rx_frame_in_n ]
  set rx_frame_in_p [ create_bd_port -dir I rx_frame_in_p ]
  set spi0_clk_i [ create_bd_port -dir I spi0_clk_i ]
  set spi0_clk_o [ create_bd_port -dir O spi0_clk_o ]
  set spi0_csn_0_o [ create_bd_port -dir O spi0_csn_0_o ]
  set spi0_csn_1_o [ create_bd_port -dir O spi0_csn_1_o ]
  set spi0_csn_2_o [ create_bd_port -dir O spi0_csn_2_o ]
  set spi0_csn_i [ create_bd_port -dir I spi0_csn_i ]
  set spi0_sdi_i [ create_bd_port -dir I spi0_sdi_i ]
  set spi0_sdo_i [ create_bd_port -dir I spi0_sdo_i ]
  set spi0_sdo_o [ create_bd_port -dir O spi0_sdo_o ]
  set spi1_clk_i [ create_bd_port -dir I spi1_clk_i ]
  set spi1_clk_o [ create_bd_port -dir O spi1_clk_o ]
  set spi1_csn_0_o [ create_bd_port -dir O spi1_csn_0_o ]
  set spi1_csn_1_o [ create_bd_port -dir O spi1_csn_1_o ]
  set spi1_csn_2_o [ create_bd_port -dir O spi1_csn_2_o ]
  set spi1_csn_i [ create_bd_port -dir I spi1_csn_i ]
  set spi1_sdi_i [ create_bd_port -dir I spi1_sdi_i ]
  set spi1_sdo_i [ create_bd_port -dir I spi1_sdo_i ]
  set spi1_sdo_o [ create_bd_port -dir O spi1_sdo_o ]
  set tdd_sync_i [ create_bd_port -dir I tdd_sync_i ]
  set tdd_sync_o [ create_bd_port -dir O tdd_sync_o ]
  set tdd_sync_t [ create_bd_port -dir O tdd_sync_t ]
  set tx_clk_out_n [ create_bd_port -dir O tx_clk_out_n ]
  set tx_clk_out_p [ create_bd_port -dir O tx_clk_out_p ]
  set tx_data_out_n [ create_bd_port -dir O -from 5 -to 0 tx_data_out_n ]
  set tx_data_out_p [ create_bd_port -dir O -from 5 -to 0 tx_data_out_p ]
  set tx_frame_out_n [ create_bd_port -dir O tx_frame_out_n ]
  set tx_frame_out_p [ create_bd_port -dir O tx_frame_out_p ]
  set txnrx [ create_bd_port -dir O txnrx ]
  set up_enable [ create_bd_port -dir I up_enable ]
  set up_txnrx [ create_bd_port -dir I up_txnrx ]

  # Create instance: axi_ad9361, and set properties
  set axi_ad9361 [ create_bd_cell -type ip -vlnv analog.com:user:axi_ad9361:1.0 axi_ad9361 ]
  set_property -dict [ list \
CONFIG.ADC_DATAFORMAT_DISABLE {0} \
CONFIG.ADC_DATAPATH_DISABLE {0} \
CONFIG.ADC_DCFILTER_DISABLE {0} \
CONFIG.ADC_IQCORRECTION_DISABLE {0} \
CONFIG.ADC_USERPORTS_DISABLE {0} \
CONFIG.CMOS_OR_LVDS_N {0} \
CONFIG.DAC_DATAPATH_DISABLE {0} \
CONFIG.DAC_DDS_DISABLE {0} \
CONFIG.DAC_IODELAY_ENABLE {0} \
CONFIG.DAC_IQCORRECTION_DISABLE {0} \
CONFIG.DAC_USERPORTS_DISABLE {0} \
CONFIG.ID {0} \
CONFIG.MODE_1R1T {0} \
CONFIG.PPS_RECEIVER_ENABLE {1} \
CONFIG.TDD_DISABLE {0} \
 ] $axi_ad9361

  # Create instance: axi_ad9361_adc_dma, and set properties
  set axi_ad9361_adc_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_adc_dma ]
  set_property -dict [ list \
CONFIG.AXI_SLICE_DEST {false} \
CONFIG.AXI_SLICE_SRC {false} \
CONFIG.CYCLIC {false} \
CONFIG.DMA_2D_TRANSFER {false} \
CONFIG.DMA_DATA_WIDTH_SRC {64} \
CONFIG.DMA_TYPE_DEST {0} \
CONFIG.DMA_TYPE_SRC {2} \
CONFIG.SYNC_TRANSFER_START {true} \
 ] $axi_ad9361_adc_dma

  # Create instance: axi_ad9361_adc_dma1, and set properties
  set axi_ad9361_adc_dma1 [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_adc_dma1 ]
  set_property -dict [ list \
CONFIG.AXI_SLICE_DEST {false} \
CONFIG.AXI_SLICE_SRC {false} \
CONFIG.CYCLIC {false} \
CONFIG.DMA_2D_TRANSFER {false} \
CONFIG.DMA_DATA_WIDTH_SRC {64} \
CONFIG.DMA_TYPE_DEST {0} \
CONFIG.DMA_TYPE_SRC {2} \
CONFIG.SYNC_TRANSFER_START {true} \
 ] $axi_ad9361_adc_dma1

  # Create instance: axi_ad9361_dac_dma, and set properties
  set axi_ad9361_dac_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_dac_dma ]
  set_property -dict [ list \
CONFIG.AXI_SLICE_DEST {true} \
CONFIG.AXI_SLICE_SRC {false} \
CONFIG.CYCLIC {true} \
CONFIG.DMA_2D_TRANSFER {false} \
CONFIG.DMA_DATA_WIDTH_DEST {64} \
CONFIG.DMA_TYPE_DEST {2} \
CONFIG.DMA_TYPE_SRC {0} \
 ] $axi_ad9361_dac_dma

  # Create instance: axi_ad9361_dac_dma1, and set properties
  set axi_ad9361_dac_dma1 [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_dac_dma1 ]
  set_property -dict [ list \
CONFIG.AXI_SLICE_DEST {true} \
CONFIG.AXI_SLICE_SRC {false} \
CONFIG.CYCLIC {true} \
CONFIG.DMA_2D_TRANSFER {false} \
CONFIG.DMA_DATA_WIDTH_DEST {64} \
CONFIG.DMA_TYPE_DEST {2} \
CONFIG.DMA_TYPE_SRC {0} \
 ] $axi_ad9361_dac_dma1

  # Create instance: axi_ad9361_dac_fifo, and set properties
  set axi_ad9361_dac_fifo [ create_bd_cell -type ip -vlnv analog.com:user:util_rfifo:1.0 axi_ad9361_dac_fifo ]
  set_property -dict [ list \
CONFIG.DIN_ADDRESS_WIDTH {4} \
CONFIG.DIN_DATA_WIDTH {16} \
CONFIG.DOUT_DATA_WIDTH {16} \
 ] $axi_ad9361_dac_fifo

  # Create instance: axi_cpu_interconnect, and set properties
  set axi_cpu_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_cpu_interconnect ]
  set_property -dict [ list \
CONFIG.NUM_MI {8} \
 ] $axi_cpu_interconnect

  # Create instance: axi_hp0_interconnect, and set properties
  set axi_hp0_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp0_interconnect ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {1} \
 ] $axi_hp0_interconnect

  # Create instance: axi_hp1_interconnect, and set properties
  set axi_hp1_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp1_interconnect ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {1} \
 ] $axi_hp1_interconnect

  # Create instance: axi_hp2_interconnect, and set properties
  set axi_hp2_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp2_interconnect ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {1} \
 ] $axi_hp2_interconnect

  # Create instance: axi_hp3_interconnect, and set properties
  set axi_hp3_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp3_interconnect ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {1} \
 ] $axi_hp3_interconnect

  # Create instance: axi_i2s_adi, and set properties
  set axi_i2s_adi [ create_bd_cell -type ip -vlnv analog.com:user:axi_i2s_adi:1.0 axi_i2s_adi ]
  set_property -dict [ list \
CONFIG.DMA_TYPE {1} \
CONFIG.S_AXI_ADDRESS_WIDTH {16} \
 ] $axi_i2s_adi

  # Create instance: axi_iic_main, and set properties
  set axi_iic_main [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_main ]
  set_property -dict [ list \
CONFIG.IIC_BOARD_INTERFACE {Custom} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_iic_main

  # Create instance: sys_audio_clkgen, and set properties
  set sys_audio_clkgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 sys_audio_clkgen ]
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS {50.0} \
CONFIG.CLKOUT1_JITTER {327.996} \
CONFIG.CLKOUT1_PHASE_ERROR {264.435} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.288} \
CONFIG.MMCM_CLKFBOUT_MULT_F {44.375} \
CONFIG.MMCM_CLKIN1_PERIOD {5.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {80.250} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {9} \
CONFIG.PRIM_SOURCE {No_buffer} \
CONFIG.RESET_PORT {resetn} \
CONFIG.RESET_TYPE {ACTIVE_LOW} \
CONFIG.USE_LOCKED {false} \
CONFIG.USE_PHASE_ALIGNMENT {false} \
CONFIG.USE_RESET {true} \
 ] $sys_audio_clkgen

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS.VALUE_SRC {DEFAULT} \
CONFIG.CLKOUT1_JITTER.VALUE_SRC {DEFAULT} \
CONFIG.CLKOUT1_PHASE_ERROR.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKFBOUT_MULT_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN1_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN2_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_COMPENSATION.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_DIVCLK_DIVIDE.VALUE_SRC {DEFAULT} \
CONFIG.RESET_PORT.VALUE_SRC {DEFAULT} \
 ] $sys_audio_clkgen

  # Create instance: sys_concat_intc, and set properties
  set sys_concat_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 sys_concat_intc ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {16} \
 ] $sys_concat_intc

  # Create instance: sys_logic_inv, and set properties
  set sys_logic_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 sys_logic_inv ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
 ] $sys_logic_inv

  # Create instance: sys_ps7, and set properties
  set sys_ps7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 sys_ps7 ]
  set_property -dict [ list \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
CONFIG.PCW_CAN0_CAN0_IO {<Select>} \
CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN0_GRP_CLK_IO {<Select>} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN1_CAN1_IO {<Select>} \
CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN1_GRP_CLK_IO {<Select>} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_CLK0_FREQ {100000000} \
CONFIG.PCW_CLK1_FREQ {200000000} \
CONFIG.PCW_CLK2_FREQ {200000000} \
CONFIG.PCW_CLK3_FREQ {10000000} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {800} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_3 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3 {<Select>} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET0_RESET_ENABLE {1} \
CONFIG.PCW_ENET0_RESET_IO {MIO 8} \
CONFIG.PCW_ENET1_ENET1_IO {EMIO} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
CONFIG.PCW_ENET1_GRP_MDIO_IO {<Select>} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET1_RESET_ENABLE {1} \
CONFIG.PCW_ENET1_RESET_IO {MIO 51} \
CONFIG.PCW_ENET_RESET_ENABLE {1} \
CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
CONFIG.PCW_ENET_RESET_SELECT {Separate reset pins} \
CONFIG.PCW_EN_4K_TIMER {0} \
CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_EN_CLK2_PORT {1} \
CONFIG.PCW_EN_EMIO_ENET1 {1} \
CONFIG.PCW_EN_EMIO_GPIO {1} \
CONFIG.PCW_EN_EMIO_SPI0 {1} \
CONFIG.PCW_EN_EMIO_SPI1 {1} \
CONFIG.PCW_EN_ENET0 {1} \
CONFIG.PCW_EN_ENET1 {1} \
CONFIG.PCW_EN_QSPI {1} \
CONFIG.PCW_EN_RST1_PORT {1} \
CONFIG.PCW_EN_RST2_PORT {1} \
CONFIG.PCW_EN_SDIO0 {1} \
CONFIG.PCW_EN_SPI0 {1} \
CONFIG.PCW_EN_SPI1 {1} \
CONFIG.PCW_EN_UART0 {1} \
CONFIG.PCW_EN_UART1 {1} \
CONFIG.PCW_EN_USB0 {1} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
CONFIG.PCW_FCLK_CLK1_BUF {TRUE} \
CONFIG.PCW_FCLK_CLK2_BUF {TRUE} \
CONFIG.PCW_FCLK_CLK3_BUF {FALSE} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.0} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200.0} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200.0} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
CONFIG.PCW_FPGA_FCLK2_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C0_GRP_INT_IO {<Select>} \
CONFIG.PCW_I2C0_I2C0_IO {<Select>} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C0_RESET_ENABLE {0} \
CONFIG.PCW_I2C0_RESET_IO {<Select>} \
CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C1_GRP_INT_IO {<Select>} \
CONFIG.PCW_I2C1_I2C1_IO {<Select>} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_IO {<Select>} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
CONFIG.PCW_I2C_RESET_ENABLE {1} \
CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
CONFIG.PCW_I2C_RESET_SELECT {<Select>} \
CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_IRQ_F2P_MODE {REVERSE} \
CONFIG.PCW_MIO_0_DIRECTION {inout} \
CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_0_SLEW {slow} \
CONFIG.PCW_MIO_10_DIRECTION {inout} \
CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_10_SLEW {slow} \
CONFIG.PCW_MIO_11_DIRECTION {inout} \
CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_11_SLEW {slow} \
CONFIG.PCW_MIO_12_DIRECTION {inout} \
CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_12_SLEW {slow} \
CONFIG.PCW_MIO_13_DIRECTION {inout} \
CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_13_PULLUP {enabled} \
CONFIG.PCW_MIO_13_SLEW {slow} \
CONFIG.PCW_MIO_14_DIRECTION {in} \
CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_14_PULLUP {enabled} \
CONFIG.PCW_MIO_14_SLEW {slow} \
CONFIG.PCW_MIO_15_DIRECTION {out} \
CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_15_PULLUP {enabled} \
CONFIG.PCW_MIO_15_SLEW {slow} \
CONFIG.PCW_MIO_16_DIRECTION {out} \
CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_16_PULLUP {enabled} \
CONFIG.PCW_MIO_16_SLEW {slow} \
CONFIG.PCW_MIO_17_DIRECTION {out} \
CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_17_PULLUP {enabled} \
CONFIG.PCW_MIO_17_SLEW {slow} \
CONFIG.PCW_MIO_18_DIRECTION {out} \
CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_18_PULLUP {enabled} \
CONFIG.PCW_MIO_18_SLEW {slow} \
CONFIG.PCW_MIO_19_DIRECTION {out} \
CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_19_PULLUP {enabled} \
CONFIG.PCW_MIO_19_SLEW {slow} \
CONFIG.PCW_MIO_1_DIRECTION {out} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} \
CONFIG.PCW_MIO_20_DIRECTION {out} \
CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_20_PULLUP {enabled} \
CONFIG.PCW_MIO_20_SLEW {slow} \
CONFIG.PCW_MIO_21_DIRECTION {out} \
CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_21_PULLUP {enabled} \
CONFIG.PCW_MIO_21_SLEW {slow} \
CONFIG.PCW_MIO_22_DIRECTION {in} \
CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_22_PULLUP {enabled} \
CONFIG.PCW_MIO_22_SLEW {slow} \
CONFIG.PCW_MIO_23_DIRECTION {in} \
CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_23_PULLUP {enabled} \
CONFIG.PCW_MIO_23_SLEW {slow} \
CONFIG.PCW_MIO_24_DIRECTION {in} \
CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_24_PULLUP {enabled} \
CONFIG.PCW_MIO_24_SLEW {slow} \
CONFIG.PCW_MIO_25_DIRECTION {in} \
CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_25_PULLUP {enabled} \
CONFIG.PCW_MIO_25_SLEW {slow} \
CONFIG.PCW_MIO_26_DIRECTION {in} \
CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_26_PULLUP {enabled} \
CONFIG.PCW_MIO_26_SLEW {slow} \
CONFIG.PCW_MIO_27_DIRECTION {in} \
CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_27_PULLUP {enabled} \
CONFIG.PCW_MIO_27_SLEW {slow} \
CONFIG.PCW_MIO_28_DIRECTION {inout} \
CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_28_PULLUP {enabled} \
CONFIG.PCW_MIO_28_SLEW {slow} \
CONFIG.PCW_MIO_29_DIRECTION {in} \
CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_29_PULLUP {enabled} \
CONFIG.PCW_MIO_29_SLEW {slow} \
CONFIG.PCW_MIO_2_DIRECTION {inout} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_2_PULLUP {disabled} \
CONFIG.PCW_MIO_2_SLEW {slow} \
CONFIG.PCW_MIO_30_DIRECTION {out} \
CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_30_PULLUP {enabled} \
CONFIG.PCW_MIO_30_SLEW {slow} \
CONFIG.PCW_MIO_31_DIRECTION {in} \
CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_31_PULLUP {enabled} \
CONFIG.PCW_MIO_31_SLEW {slow} \
CONFIG.PCW_MIO_32_DIRECTION {inout} \
CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_32_PULLUP {enabled} \
CONFIG.PCW_MIO_32_SLEW {slow} \
CONFIG.PCW_MIO_33_DIRECTION {inout} \
CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_33_PULLUP {enabled} \
CONFIG.PCW_MIO_33_SLEW {slow} \
CONFIG.PCW_MIO_34_DIRECTION {inout} \
CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_34_PULLUP {enabled} \
CONFIG.PCW_MIO_34_SLEW {slow} \
CONFIG.PCW_MIO_35_DIRECTION {inout} \
CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_35_PULLUP {enabled} \
CONFIG.PCW_MIO_35_SLEW {slow} \
CONFIG.PCW_MIO_36_DIRECTION {in} \
CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_36_PULLUP {enabled} \
CONFIG.PCW_MIO_36_SLEW {slow} \
CONFIG.PCW_MIO_37_DIRECTION {inout} \
CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_37_PULLUP {enabled} \
CONFIG.PCW_MIO_37_SLEW {slow} \
CONFIG.PCW_MIO_38_DIRECTION {inout} \
CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_38_PULLUP {enabled} \
CONFIG.PCW_MIO_38_SLEW {slow} \
CONFIG.PCW_MIO_39_DIRECTION {inout} \
CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_39_PULLUP {enabled} \
CONFIG.PCW_MIO_39_SLEW {slow} \
CONFIG.PCW_MIO_3_DIRECTION {inout} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_3_PULLUP {disabled} \
CONFIG.PCW_MIO_3_SLEW {slow} \
CONFIG.PCW_MIO_40_DIRECTION {inout} \
CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_40_PULLUP {enabled} \
CONFIG.PCW_MIO_40_SLEW {slow} \
CONFIG.PCW_MIO_41_DIRECTION {inout} \
CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_41_PULLUP {enabled} \
CONFIG.PCW_MIO_41_SLEW {slow} \
CONFIG.PCW_MIO_42_DIRECTION {inout} \
CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_42_PULLUP {enabled} \
CONFIG.PCW_MIO_42_SLEW {slow} \
CONFIG.PCW_MIO_43_DIRECTION {inout} \
CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_43_PULLUP {enabled} \
CONFIG.PCW_MIO_43_SLEW {slow} \
CONFIG.PCW_MIO_44_DIRECTION {inout} \
CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_44_PULLUP {enabled} \
CONFIG.PCW_MIO_44_SLEW {slow} \
CONFIG.PCW_MIO_45_DIRECTION {inout} \
CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_45_PULLUP {enabled} \
CONFIG.PCW_MIO_45_SLEW {slow} \
CONFIG.PCW_MIO_46_DIRECTION {inout} \
CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_46_PULLUP {enabled} \
CONFIG.PCW_MIO_46_SLEW {slow} \
CONFIG.PCW_MIO_47_DIRECTION {inout} \
CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_47_PULLUP {enabled} \
CONFIG.PCW_MIO_47_SLEW {slow} \
CONFIG.PCW_MIO_48_DIRECTION {out} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_48_PULLUP {enabled} \
CONFIG.PCW_MIO_48_SLEW {slow} \
CONFIG.PCW_MIO_49_DIRECTION {in} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_49_PULLUP {enabled} \
CONFIG.PCW_MIO_49_SLEW {slow} \
CONFIG.PCW_MIO_4_DIRECTION {inout} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_4_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {slow} \
CONFIG.PCW_MIO_50_DIRECTION {in} \
CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_50_PULLUP {enabled} \
CONFIG.PCW_MIO_50_SLEW {slow} \
CONFIG.PCW_MIO_51_DIRECTION {out} \
CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_51_PULLUP {enabled} \
CONFIG.PCW_MIO_51_SLEW {slow} \
CONFIG.PCW_MIO_52_DIRECTION {out} \
CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_52_PULLUP {enabled} \
CONFIG.PCW_MIO_52_SLEW {slow} \
CONFIG.PCW_MIO_53_DIRECTION {inout} \
CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_53_PULLUP {enabled} \
CONFIG.PCW_MIO_53_SLEW {slow} \
CONFIG.PCW_MIO_5_DIRECTION {inout} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_5_PULLUP {disabled} \
CONFIG.PCW_MIO_5_SLEW {slow} \
CONFIG.PCW_MIO_6_DIRECTION {out} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_6_PULLUP {disabled} \
CONFIG.PCW_MIO_6_SLEW {slow} \
CONFIG.PCW_MIO_7_DIRECTION {out} \
CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_7_PULLUP {disabled} \
CONFIG.PCW_MIO_7_SLEW {slow} \
CONFIG.PCW_MIO_8_DIRECTION {out} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_8_PULLUP {disabled} \
CONFIG.PCW_MIO_8_SLEW {slow} \
CONFIG.PCW_MIO_9_DIRECTION {inout} \
CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_MIO_9_SLEW {slow} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#USB Reset#ENET Reset#GPIO#GPIO#GPIO#GPIO#GPIO#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO#GPIO#UART 1#UART 1#SD 0#ENET Reset#Enet 0#Enet 0} \
CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#reset#reset#gpio[9]#gpio[10]#gpio[11]#gpio[12]#gpio[13]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#gpio[46]#gpio[47]#tx#rx#cd#reset#mdc#mdio} \
CONFIG.PCW_NAND_CYCLES_T_AR {1} \
CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
CONFIG.PCW_NAND_CYCLES_T_RC {11} \
CONFIG.PCW_NAND_CYCLES_T_REA {1} \
CONFIG.PCW_NAND_CYCLES_T_RR {1} \
CONFIG.PCW_NAND_CYCLES_T_WC {11} \
CONFIG.PCW_NAND_CYCLES_T_WP {1} \
CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
CONFIG.PCW_NAND_GRP_D8_IO {<Select>} \
CONFIG.PCW_NAND_NAND_IO {<Select>} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_CS0_T_CEOE {1} \
CONFIG.PCW_NOR_CS0_T_PC {1} \
CONFIG.PCW_NOR_CS0_T_RC {11} \
CONFIG.PCW_NOR_CS0_T_TR {1} \
CONFIG.PCW_NOR_CS0_T_WC {11} \
CONFIG.PCW_NOR_CS0_T_WP {1} \
CONFIG.PCW_NOR_CS0_WE_TIME {0} \
CONFIG.PCW_NOR_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_CS1_T_PC {1} \
CONFIG.PCW_NOR_CS1_T_RC {11} \
CONFIG.PCW_NOR_CS1_T_TR {1} \
CONFIG.PCW_NOR_CS1_T_WC {11} \
CONFIG.PCW_NOR_CS1_T_WP {1} \
CONFIG.PCW_NOR_CS1_WE_TIME {0} \
CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
CONFIG.PCW_NOR_GRP_A25_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_INT_IO {<Select>} \
CONFIG.PCW_NOR_NOR_IO {<Select>} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.121} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.130} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.131} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.141} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {0.039} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {0.017} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {0.018} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.004} \
CONFIG.PCW_PACKAGE_NAME {fbg676} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_PJTAG_PJTAG_IO {<Select>} \
CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_IO1_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_SS1_IO {<Select>} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 50} \
CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD0_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
CONFIG.PCW_SD0_GRP_WP_IO {<Select>} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
CONFIG.PCW_SD1_GRP_CD_ENABLE {0} \
CONFIG.PCW_SD1_GRP_CD_IO {<Select>} \
CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD1_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD1_GRP_WP_ENABLE {0} \
CONFIG.PCW_SD1_GRP_WP_IO {<Select>} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SD1_SD1_IO {<Select>} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS1_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS2_IO {EMIO} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE {1} \
CONFIG.PCW_SPI1_GRP_SS0_IO {EMIO} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE {1} \
CONFIG.PCW_SPI1_GRP_SS1_IO {EMIO} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE {1} \
CONFIG.PCW_SPI1_GRP_SS2_IO {EMIO} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {EMIO} \
CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {6} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_16BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_2BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_32BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_4BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_8BIT_IO {<Select>} \
CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TRACE_TRACE_IO {<Select>} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TTC0_TTC0_IO {<Select>} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TTC1_TTC1_IO {<Select>} \
CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART0_BAUD_RATE {115200} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART0_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
CONFIG.PCW_UART1_BAUD_RATE {115200} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART1_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
CONFIG.PCW_UIPARAM_DDR_AL {0} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
CONFIG.PCW_UIPARAM_DDR_BL {8} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.264} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.265} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.330} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.330} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
CONFIG.PCW_UIPARAM_DDR_CL {7} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {137.1865} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {137.1865} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {137.1865} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {137.1865} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
CONFIG.PCW_UIPARAM_DDR_CWL {6} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {97.9265} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {119.8725} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {119.076} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {140.8255} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.053} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.059} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.065} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.066} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {104.762} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {122.158} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {124.95} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {143.8565} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
CONFIG.PCW_UIPARAM_DDR_T_RC {48.75} \
CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 7} \
CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB1_RESET_ENABLE {0} \
CONFIG.PCW_USB1_RESET_IO {<Select>} \
CONFIG.PCW_USB1_USB1_IO {<Select>} \
CONFIG.PCW_USB_RESET_ENABLE {1} \
CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
CONFIG.PCW_USE_CROSS_TRIGGER {0} \
CONFIG.PCW_USE_DMA0 {1} \
CONFIG.PCW_USE_DMA1 {1} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.PCW_USE_S_AXI_HP1 {1} \
CONFIG.PCW_USE_S_AXI_HP2 {1} \
CONFIG.PCW_USE_S_AXI_HP3 {1} \
CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_WDT_WDT_IO {<Select>} \
 ] $sys_ps7

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_CAN0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_GRP_CLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_GRP_CLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_CAN1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_GRP_CLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_GRP_CLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK0_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK1_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK2_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK3_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_GRP_MDIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_ENET1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_GRP_MDIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_4K_TIMER.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_ENET1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_GPIO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_SPI0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_SPI1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_ENET0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_ENET1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_QSPI.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SDIO0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SPI0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SPI1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_UART0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_UART1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_USB0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK0_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK1_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK2_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK3_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA_FCLK0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA_FCLK1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA_FCLK2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_MIO_GPIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_GRP_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_I2C0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_GRP_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_GRP_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_I2C1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_IOPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_TREE_PERIPHERALS.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_TREE_SIGNALS.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_AR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_CLR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_REA.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_RR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_GRP_D8_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_GRP_D8_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_NAND_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_A25_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_A25_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_NOR_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PJTAG_PJTAG_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PLL_BYPASSMODE_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_IO1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_QSPI_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_POW_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_POW_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_WP_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_WP_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_SD0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_CD_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_CD_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_POW_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_POW_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_WP_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_WP_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_SD1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS2_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS2_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP0_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP1_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP3_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_16BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_16BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_2BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_2BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_32BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_32BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_4BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_4BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_8BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_8BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_INTERNAL_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_TRACE_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_TTC0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_TTC1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_BAUD_RATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_GRP_FULL_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_BAUD_RATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_GRP_FULL_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_UART1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_AL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CWL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ECC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_FAW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RCD.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_USB0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_USB1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USE_CROSS_TRIGGER.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_WDT_IO.VALUE_SRC {DEFAULT} \
 ] $sys_ps7

  # Create instance: sys_ps7_ENET1_GMII_RX_CLK_GND, and set properties
  set sys_ps7_ENET1_GMII_RX_CLK_GND [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 sys_ps7_ENET1_GMII_RX_CLK_GND ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {1} \
 ] $sys_ps7_ENET1_GMII_RX_CLK_GND

  # Create instance: sys_ps7_ENET1_GMII_TX_CLK_GND, and set properties
  set sys_ps7_ENET1_GMII_TX_CLK_GND [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 sys_ps7_ENET1_GMII_TX_CLK_GND ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {1} \
 ] $sys_ps7_ENET1_GMII_TX_CLK_GND

  # Create instance: sys_rstgen, and set properties
  set sys_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen ]
  set_property -dict [ list \
CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen

  # Create instance: util_ad9361_adc_fifo, and set properties
  set util_ad9361_adc_fifo [ create_bd_cell -type ip -vlnv analog.com:user:util_wfifo:1.0 util_ad9361_adc_fifo ]
  set_property -dict [ list \
CONFIG.DIN_ADDRESS_WIDTH {4} \
CONFIG.DIN_DATA_WIDTH {16} \
CONFIG.DOUT_DATA_WIDTH {16} \
CONFIG.NUM_OF_CHANNELS {4} \
 ] $util_ad9361_adc_fifo

  # Create instance: util_ad9361_adc_pack, and set properties
  set util_ad9361_adc_pack [ create_bd_cell -type ip -vlnv analog.com:user:util_cpack:1.0 util_ad9361_adc_pack ]
  set_property -dict [ list \
CONFIG.CHANNEL_DATA_WIDTH {16} \
CONFIG.NUM_OF_CHANNELS {4} \
 ] $util_ad9361_adc_pack

  # Create instance: util_ad9361_dac_upack, and set properties
  set util_ad9361_dac_upack [ create_bd_cell -type ip -vlnv analog.com:user:util_upack:1.0 util_ad9361_dac_upack ]
  set_property -dict [ list \
CONFIG.CHANNEL_DATA_WIDTH {16} \
CONFIG.NUM_OF_CHANNELS {4} \
 ] $util_ad9361_dac_upack

  # Create instance: util_ad9361_divclk, and set properties
  set util_ad9361_divclk [ create_bd_cell -type ip -vlnv analog.com:user:util_clkdiv:1.0 util_ad9361_divclk ]

  # Create instance: util_ad9361_divclk_reset, and set properties
  set util_ad9361_divclk_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 util_ad9361_divclk_reset ]

  # Create instance: util_ad9361_divclk_sel, and set properties
  set util_ad9361_divclk_sel [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 util_ad9361_divclk_sel ]
  set_property -dict [ list \
CONFIG.C_SIZE {2} \
 ] $util_ad9361_divclk_sel

  # Create instance: util_ad9361_divclk_sel_concat, and set properties
  set util_ad9361_divclk_sel_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 util_ad9361_divclk_sel_concat ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {2} \
 ] $util_ad9361_divclk_sel_concat

  # Create instance: util_ad9361_tdd_sync, and set properties
  set util_ad9361_tdd_sync [ create_bd_cell -type ip -vlnv analog.com:user:util_tdd_sync:1.0 util_ad9361_tdd_sync ]
  set_property -dict [ list \
CONFIG.TDD_SYNC_PERIOD {10000000} \
 ] $util_ad9361_tdd_sync

  # Create instance: util_mux_0, and set properties
  set util_mux_0 [ create_bd_cell -type ip -vlnv analog.com:user:util_mux:1.0 util_mux_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_cpu_interconnect/S00_AXI] [get_bd_intf_pins sys_ps7/M_AXI_GP0]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_ad9361_adc_dma/m_dest_axi] [get_bd_intf_pins axi_hp1_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_3 [get_bd_intf_pins axi_ad9361_dac_dma/m_src_axi] [get_bd_intf_pins axi_hp2_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_4 [get_bd_intf_pins axi_ad9361_adc_dma1/m_dest_axi] [get_bd_intf_pins axi_hp0_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_ad9361_dac_dma1_m_src_axi [get_bd_intf_pins axi_ad9361_dac_dma1/m_src_axi] [get_bd_intf_pins axi_hp3_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M00_AXI [get_bd_intf_pins axi_cpu_interconnect/M00_AXI] [get_bd_intf_pins axi_iic_main/S_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M01_AXI [get_bd_intf_pins axi_ad9361/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M02_AXI [get_bd_intf_pins axi_ad9361_adc_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M03_AXI [get_bd_intf_pins axi_ad9361_dac_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M03_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M04_AXI [get_bd_intf_pins axi_cpu_interconnect/M04_AXI] [get_bd_intf_pins axi_i2s_adi/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M05_AXI [get_bd_intf_pins axi_ad9361_adc_dma1/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M05_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M06_AXI [get_bd_intf_pins axi_ad9361_dac_dma1/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M06_AXI]
  connect_bd_intf_net -intf_net axi_hp0_interconnect_M00_AXI [get_bd_intf_pins axi_hp0_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_hp1_interconnect_M00_AXI [get_bd_intf_pins axi_hp1_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP1]
  connect_bd_intf_net -intf_net axi_hp2_interconnect_M00_AXI [get_bd_intf_pins axi_hp2_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP2]
  connect_bd_intf_net -intf_net axi_hp3_interconnect_M00_AXI [get_bd_intf_pins axi_hp3_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP3]
  connect_bd_intf_net -intf_net axi_i2s_adi_dma_req_rx [get_bd_intf_pins axi_i2s_adi/dma_req_rx] [get_bd_intf_pins sys_ps7/DMA1_REQ]
  connect_bd_intf_net -intf_net axi_i2s_adi_dma_req_tx [get_bd_intf_pins axi_i2s_adi/dma_req_tx] [get_bd_intf_pins sys_ps7/DMA0_REQ]
  connect_bd_intf_net -intf_net axi_i2s_adi_i2s [get_bd_intf_ports i2s] [get_bd_intf_pins axi_i2s_adi/i2s]
  connect_bd_intf_net -intf_net axi_iic_main_IIC [get_bd_intf_ports iic_main] [get_bd_intf_pins axi_iic_main/IIC]
  connect_bd_intf_net -intf_net sys_ps7_DDR [get_bd_intf_ports ddr] [get_bd_intf_pins sys_ps7/DDR]
  connect_bd_intf_net -intf_net sys_ps7_DMA0_ACK [get_bd_intf_pins axi_i2s_adi/dma_ack_tx] [get_bd_intf_pins sys_ps7/DMA0_ACK]
  connect_bd_intf_net -intf_net sys_ps7_DMA1_ACK [get_bd_intf_pins axi_i2s_adi/dma_ack_rx] [get_bd_intf_pins sys_ps7/DMA1_ACK]
  connect_bd_intf_net -intf_net sys_ps7_FIXED_IO [get_bd_intf_ports fixed_io] [get_bd_intf_pins sys_ps7/FIXED_IO]

  # Create port connections
  connect_bd_net -net CombinedT_ip_0_axi_ad9361_dac_data_i0 [get_bd_pins util_mux_0/in1_4] [get_bd_pins util_mux_0/in1_6]
  connect_bd_net -net CombinedT_ip_0_axi_ad9361_dac_data_q0 [get_bd_pins util_mux_0/in1_5] [get_bd_pins util_mux_0/in1_7]
  connect_bd_net -net CombinedT_ip_0_axi_ad9361_dac_fifo_valid [get_bd_pins util_mux_0/in1_0] [get_bd_pins util_mux_0/in1_1] [get_bd_pins util_mux_0/in1_2] [get_bd_pins util_mux_0/in1_3]
  connect_bd_net -net CombinedT_ip_0_validRx [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_1] [get_bd_pins util_ad9361_adc_pack/adc_valid_2] [get_bd_pins util_ad9361_adc_pack/adc_valid_3]
  connect_bd_net -net M07_ARESETN_1 [get_bd_pins axi_cpu_interconnect/M07_ARESETN] [get_bd_pins util_ad9361_divclk_reset/interconnect_aresetn]
  connect_bd_net -net axi_ad9361_adc_data_i0 [get_bd_pins axi_ad9361/adc_data_i0] [get_bd_pins util_ad9361_adc_fifo/din_data_0]
  connect_bd_net -net axi_ad9361_adc_data_i1 [get_bd_pins axi_ad9361/adc_data_i1] [get_bd_pins util_ad9361_adc_fifo/din_data_2]
  connect_bd_net -net axi_ad9361_adc_data_q0 [get_bd_pins axi_ad9361/adc_data_q0] [get_bd_pins util_ad9361_adc_fifo/din_data_1]
  connect_bd_net -net axi_ad9361_adc_data_q1 [get_bd_pins axi_ad9361/adc_data_q1] [get_bd_pins util_ad9361_adc_fifo/din_data_3]
  connect_bd_net -net axi_ad9361_adc_dma1_irq [get_bd_pins axi_ad9361_adc_dma1/irq] [get_bd_pins sys_concat_intc/In10]
  connect_bd_net -net axi_ad9361_adc_dma_fifo_wr_overflow [get_bd_pins axi_ad9361_adc_dma/fifo_wr_overflow] [get_bd_pins util_ad9361_adc_fifo/dout_ovf]
  connect_bd_net -net axi_ad9361_adc_dma_irq [get_bd_pins axi_ad9361_adc_dma/irq] [get_bd_pins sys_concat_intc/In13]
  connect_bd_net -net axi_ad9361_adc_enable_i0 [get_bd_pins axi_ad9361/adc_enable_i0] [get_bd_pins util_ad9361_adc_fifo/din_enable_0]
  connect_bd_net -net axi_ad9361_adc_enable_i1 [get_bd_pins axi_ad9361/adc_enable_i1] [get_bd_pins util_ad9361_adc_fifo/din_enable_2]
  connect_bd_net -net axi_ad9361_adc_enable_q0 [get_bd_pins axi_ad9361/adc_enable_q0] [get_bd_pins util_ad9361_adc_fifo/din_enable_1]
  connect_bd_net -net axi_ad9361_adc_enable_q1 [get_bd_pins axi_ad9361/adc_enable_q1] [get_bd_pins util_ad9361_adc_fifo/din_enable_3]
  connect_bd_net -net axi_ad9361_adc_r1_mode [get_bd_pins axi_ad9361/adc_r1_mode] [get_bd_pins util_ad9361_divclk_sel_concat/In0]
  connect_bd_net -net axi_ad9361_adc_valid_i0 [get_bd_pins axi_ad9361/adc_valid_i0] [get_bd_pins util_ad9361_adc_fifo/din_valid_0]
  connect_bd_net -net axi_ad9361_adc_valid_i1 [get_bd_pins axi_ad9361/adc_valid_i1] [get_bd_pins util_ad9361_adc_fifo/din_valid_2]
  connect_bd_net -net axi_ad9361_adc_valid_q0 [get_bd_pins axi_ad9361/adc_valid_q0] [get_bd_pins util_ad9361_adc_fifo/din_valid_1]
  connect_bd_net -net axi_ad9361_adc_valid_q1 [get_bd_pins axi_ad9361/adc_valid_q1] [get_bd_pins util_ad9361_adc_fifo/din_valid_3]
  connect_bd_net -net axi_ad9361_dac_dma1_irq [get_bd_pins axi_ad9361_dac_dma1/irq] [get_bd_pins sys_concat_intc/In9]
  connect_bd_net -net axi_ad9361_dac_dma_fifo_rd_dout [get_bd_pins axi_ad9361_dac_dma/fifo_rd_dout] [get_bd_pins util_ad9361_dac_upack/dac_data]
  connect_bd_net -net axi_ad9361_dac_dma_irq [get_bd_pins axi_ad9361_dac_dma/irq] [get_bd_pins sys_concat_intc/In12]
  connect_bd_net -net axi_ad9361_dac_enable_i0 [get_bd_pins axi_ad9361/dac_enable_i0] [get_bd_pins axi_ad9361_dac_fifo/dout_enable_0]
  connect_bd_net -net axi_ad9361_dac_enable_i1 [get_bd_pins axi_ad9361/dac_enable_i1] [get_bd_pins axi_ad9361_dac_fifo/dout_enable_2]
  connect_bd_net -net axi_ad9361_dac_enable_q0 [get_bd_pins axi_ad9361/dac_enable_q0] [get_bd_pins axi_ad9361_dac_fifo/dout_enable_1]
  connect_bd_net -net axi_ad9361_dac_enable_q1 [get_bd_pins axi_ad9361/dac_enable_q1] [get_bd_pins axi_ad9361_dac_fifo/dout_enable_3]
  connect_bd_net -net axi_ad9361_dac_fifo_din_enable_0 [get_bd_pins axi_ad9361_dac_fifo/din_enable_0] [get_bd_pins util_ad9361_dac_upack/dac_enable_0]
  connect_bd_net -net axi_ad9361_dac_fifo_din_enable_1 [get_bd_pins axi_ad9361_dac_fifo/din_enable_1] [get_bd_pins util_ad9361_dac_upack/dac_enable_1]
  connect_bd_net -net axi_ad9361_dac_fifo_din_enable_2 [get_bd_pins axi_ad9361_dac_fifo/din_enable_2] [get_bd_pins util_ad9361_dac_upack/dac_enable_2]
  connect_bd_net -net axi_ad9361_dac_fifo_din_enable_3 [get_bd_pins axi_ad9361_dac_fifo/din_enable_3] [get_bd_pins util_ad9361_dac_upack/dac_enable_3]
  connect_bd_net -net axi_ad9361_dac_fifo_din_valid_0 [get_bd_pins axi_ad9361_dac_fifo/din_valid_0] [get_bd_pins util_ad9361_dac_upack/dac_valid_0]
  connect_bd_net -net axi_ad9361_dac_fifo_din_valid_1 [get_bd_pins axi_ad9361_dac_fifo/din_valid_1] [get_bd_pins util_ad9361_dac_upack/dac_valid_1]
  connect_bd_net -net axi_ad9361_dac_fifo_din_valid_2 [get_bd_pins axi_ad9361_dac_fifo/din_valid_2] [get_bd_pins util_ad9361_dac_upack/dac_valid_2]
  connect_bd_net -net axi_ad9361_dac_fifo_din_valid_3 [get_bd_pins axi_ad9361_dac_fifo/din_valid_3] [get_bd_pins util_ad9361_dac_upack/dac_valid_3]
  connect_bd_net -net axi_ad9361_dac_fifo_dout_data_0 [get_bd_pins axi_ad9361/dac_data_i0] [get_bd_pins axi_ad9361_dac_fifo/dout_data_0]
  connect_bd_net -net axi_ad9361_dac_fifo_dout_data_1 [get_bd_pins axi_ad9361/dac_data_q0] [get_bd_pins axi_ad9361_dac_fifo/dout_data_1]
  connect_bd_net -net axi_ad9361_dac_fifo_dout_data_2 [get_bd_pins axi_ad9361/dac_data_i1] [get_bd_pins axi_ad9361_dac_fifo/dout_data_2]
  connect_bd_net -net axi_ad9361_dac_fifo_dout_data_3 [get_bd_pins axi_ad9361/dac_data_q1] [get_bd_pins axi_ad9361_dac_fifo/dout_data_3]
  connect_bd_net -net axi_ad9361_dac_fifo_dout_unf [get_bd_pins axi_ad9361/dac_dunf] [get_bd_pins axi_ad9361_dac_fifo/dout_unf]
  connect_bd_net -net axi_ad9361_dac_r1_mode [get_bd_pins axi_ad9361/dac_r1_mode] [get_bd_pins util_ad9361_divclk_sel_concat/In1]
  connect_bd_net -net axi_ad9361_dac_valid_i0 [get_bd_pins axi_ad9361/dac_valid_i0] [get_bd_pins axi_ad9361_dac_fifo/dout_valid_0]
  connect_bd_net -net axi_ad9361_dac_valid_i1 [get_bd_pins axi_ad9361/dac_valid_i1] [get_bd_pins axi_ad9361_dac_fifo/dout_valid_2]
  connect_bd_net -net axi_ad9361_dac_valid_q0 [get_bd_pins axi_ad9361/dac_valid_q0] [get_bd_pins axi_ad9361_dac_fifo/dout_valid_1]
  connect_bd_net -net axi_ad9361_dac_valid_q1 [get_bd_pins axi_ad9361/dac_valid_q1] [get_bd_pins axi_ad9361_dac_fifo/dout_valid_3]
  connect_bd_net -net axi_ad9361_enable [get_bd_ports enable] [get_bd_pins axi_ad9361/enable]
  connect_bd_net -net axi_ad9361_gps_pps_irq [get_bd_pins axi_ad9361/gps_pps_irq] [get_bd_pins sys_concat_intc/In11]
  connect_bd_net -net axi_ad9361_l_clk [get_bd_pins axi_ad9361/clk] [get_bd_pins axi_ad9361/l_clk] [get_bd_pins axi_ad9361_dac_fifo/dout_clk] [get_bd_pins util_ad9361_adc_fifo/din_clk] [get_bd_pins util_ad9361_divclk/clk]
  connect_bd_net -net axi_ad9361_rst [get_bd_pins axi_ad9361/rst] [get_bd_pins axi_ad9361_dac_fifo/dout_rst] [get_bd_pins util_ad9361_adc_fifo/din_rst]
  connect_bd_net -net axi_ad9361_tdd_sync_cntr [get_bd_ports tdd_sync_t] [get_bd_pins axi_ad9361/tdd_sync_cntr] [get_bd_pins util_ad9361_tdd_sync/sync_mode]
  connect_bd_net -net axi_ad9361_tx_clk_out_n [get_bd_ports tx_clk_out_n] [get_bd_pins axi_ad9361/tx_clk_out_n]
  connect_bd_net -net axi_ad9361_tx_clk_out_p [get_bd_ports tx_clk_out_p] [get_bd_pins axi_ad9361/tx_clk_out_p]
  connect_bd_net -net axi_ad9361_tx_data_out_n [get_bd_ports tx_data_out_n] [get_bd_pins axi_ad9361/tx_data_out_n]
  connect_bd_net -net axi_ad9361_tx_data_out_p [get_bd_ports tx_data_out_p] [get_bd_pins axi_ad9361/tx_data_out_p]
  connect_bd_net -net axi_ad9361_tx_frame_out_n [get_bd_ports tx_frame_out_n] [get_bd_pins axi_ad9361/tx_frame_out_n]
  connect_bd_net -net axi_ad9361_tx_frame_out_p [get_bd_ports tx_frame_out_p] [get_bd_pins axi_ad9361/tx_frame_out_p]
  connect_bd_net -net axi_ad9361_txnrx [get_bd_ports txnrx] [get_bd_pins axi_ad9361/txnrx]
  connect_bd_net -net axi_iic_main_iic2intc_irpt [get_bd_pins axi_iic_main/iic2intc_irpt] [get_bd_pins sys_concat_intc/In14]
  connect_bd_net -net gpio_i_1 [get_bd_ports gpio_i] [get_bd_pins sys_ps7/GPIO_I]
  connect_bd_net -net gps_pps_1 [get_bd_ports gps_pps] [get_bd_pins axi_ad9361/gps_pps]
  connect_bd_net -net otg_vbusoc_1 [get_bd_ports otg_vbusoc] [get_bd_pins sys_logic_inv/Op1]
  connect_bd_net -net ps_intr_00_1 [get_bd_ports ps_intr_00] [get_bd_pins sys_concat_intc/In0]
  connect_bd_net -net ps_intr_01_1 [get_bd_ports ps_intr_01] [get_bd_pins sys_concat_intc/In1]
  connect_bd_net -net ps_intr_02_1 [get_bd_ports ps_intr_02] [get_bd_pins sys_concat_intc/In2]
  connect_bd_net -net ps_intr_03_1 [get_bd_ports ps_intr_03] [get_bd_pins sys_concat_intc/In3]
  connect_bd_net -net ps_intr_04_1 [get_bd_ports ps_intr_04] [get_bd_pins sys_concat_intc/In4]
  connect_bd_net -net ps_intr_05_1 [get_bd_ports ps_intr_05] [get_bd_pins sys_concat_intc/In5]
  connect_bd_net -net ps_intr_06_1 [get_bd_ports ps_intr_06] [get_bd_pins sys_concat_intc/In6]
  connect_bd_net -net ps_intr_07_1 [get_bd_ports ps_intr_07] [get_bd_pins sys_concat_intc/In7]
  connect_bd_net -net ps_intr_08_1 [get_bd_ports ps_intr_08] [get_bd_pins sys_concat_intc/In8]
  connect_bd_net -net ps_intr_15_1 [get_bd_ports ps_intr_15] [get_bd_pins sys_concat_intc/In15]
  connect_bd_net -net rx_clk_in_n_1 [get_bd_ports rx_clk_in_n] [get_bd_pins axi_ad9361/rx_clk_in_n]
  connect_bd_net -net rx_clk_in_p_1 [get_bd_ports rx_clk_in_p] [get_bd_pins axi_ad9361/rx_clk_in_p]
  connect_bd_net -net rx_data_in_n_1 [get_bd_ports rx_data_in_n] [get_bd_pins axi_ad9361/rx_data_in_n]
  connect_bd_net -net rx_data_in_p_1 [get_bd_ports rx_data_in_p] [get_bd_pins axi_ad9361/rx_data_in_p]
  connect_bd_net -net rx_frame_in_n_1 [get_bd_ports rx_frame_in_n] [get_bd_pins axi_ad9361/rx_frame_in_n]
  connect_bd_net -net rx_frame_in_p_1 [get_bd_ports rx_frame_in_p] [get_bd_pins axi_ad9361/rx_frame_in_p]
  connect_bd_net -net spi0_clk_i_1 [get_bd_ports spi0_clk_i] [get_bd_pins sys_ps7/SPI0_SCLK_I]
  connect_bd_net -net spi0_csn_i_1 [get_bd_ports spi0_csn_i] [get_bd_pins sys_ps7/SPI0_SS_I]
  connect_bd_net -net spi0_sdi_i_1 [get_bd_ports spi0_sdi_i] [get_bd_pins sys_ps7/SPI0_MISO_I]
  connect_bd_net -net spi0_sdo_i_1 [get_bd_ports spi0_sdo_i] [get_bd_pins sys_ps7/SPI0_MOSI_I]
  connect_bd_net -net spi1_clk_i_1 [get_bd_ports spi1_clk_i] [get_bd_pins sys_ps7/SPI1_SCLK_I]
  connect_bd_net -net spi1_csn_i_1 [get_bd_ports spi1_csn_i] [get_bd_pins sys_ps7/SPI1_SS_I]
  connect_bd_net -net spi1_sdi_i_1 [get_bd_ports spi1_sdi_i] [get_bd_pins sys_ps7/SPI1_MISO_I]
  connect_bd_net -net spi1_sdo_i_1 [get_bd_ports spi1_sdo_i] [get_bd_pins sys_ps7/SPI1_MOSI_I]
  connect_bd_net -net sys_200m_clk [get_bd_pins axi_ad9361/delay_clk] [get_bd_pins sys_audio_clkgen/clk_in1] [get_bd_pins sys_ps7/FCLK_CLK1]
  connect_bd_net -net sys_audio_clkgen_clk_out1 [get_bd_ports i2s_mclk] [get_bd_pins axi_i2s_adi/data_clk_i] [get_bd_pins sys_audio_clkgen/clk_out1]
  connect_bd_net -net sys_concat_intc_dout [get_bd_pins sys_concat_intc/dout] [get_bd_pins sys_ps7/IRQ_F2P]
  connect_bd_net -net sys_cpu_clk [get_bd_pins axi_ad9361/s_axi_aclk] [get_bd_pins axi_ad9361_adc_dma/m_dest_axi_aclk] [get_bd_pins axi_ad9361_adc_dma/s_axi_aclk] [get_bd_pins axi_ad9361_adc_dma1/m_dest_axi_aclk] [get_bd_pins axi_ad9361_adc_dma1/s_axi_aclk] [get_bd_pins axi_ad9361_dac_dma/m_src_axi_aclk] [get_bd_pins axi_ad9361_dac_dma/s_axi_aclk] [get_bd_pins axi_ad9361_dac_dma1/m_src_axi_aclk] [get_bd_pins axi_ad9361_dac_dma1/s_axi_aclk] [get_bd_pins axi_cpu_interconnect/ACLK] [get_bd_pins axi_cpu_interconnect/M00_ACLK] [get_bd_pins axi_cpu_interconnect/M01_ACLK] [get_bd_pins axi_cpu_interconnect/M02_ACLK] [get_bd_pins axi_cpu_interconnect/M03_ACLK] [get_bd_pins axi_cpu_interconnect/M04_ACLK] [get_bd_pins axi_cpu_interconnect/M05_ACLK] [get_bd_pins axi_cpu_interconnect/M06_ACLK] [get_bd_pins axi_cpu_interconnect/S00_ACLK] [get_bd_pins axi_hp0_interconnect/ACLK] [get_bd_pins axi_hp0_interconnect/M00_ACLK] [get_bd_pins axi_hp0_interconnect/S00_ACLK] [get_bd_pins axi_hp1_interconnect/ACLK] [get_bd_pins axi_hp1_interconnect/M00_ACLK] [get_bd_pins axi_hp1_interconnect/S00_ACLK] [get_bd_pins axi_hp2_interconnect/ACLK] [get_bd_pins axi_hp2_interconnect/M00_ACLK] [get_bd_pins axi_hp2_interconnect/S00_ACLK] [get_bd_pins axi_hp3_interconnect/ACLK] [get_bd_pins axi_hp3_interconnect/M00_ACLK] [get_bd_pins axi_hp3_interconnect/S00_ACLK] [get_bd_pins axi_i2s_adi/dma_req_rx_aclk] [get_bd_pins axi_i2s_adi/dma_req_tx_aclk] [get_bd_pins axi_i2s_adi/s_axi_aclk] [get_bd_pins axi_iic_main/s_axi_aclk] [get_bd_pins sys_ps7/DMA0_ACLK] [get_bd_pins sys_ps7/DMA1_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0] [get_bd_pins sys_ps7/M_AXI_GP0_ACLK] [get_bd_pins sys_ps7/S_AXI_HP0_ACLK] [get_bd_pins sys_ps7/S_AXI_HP1_ACLK] [get_bd_pins sys_ps7/S_AXI_HP2_ACLK] [get_bd_pins sys_ps7/S_AXI_HP3_ACLK] [get_bd_pins sys_rstgen/slowest_sync_clk] [get_bd_pins util_ad9361_tdd_sync/clk]
  connect_bd_net -net sys_cpu_reset [get_bd_pins sys_rstgen/peripheral_reset]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins axi_ad9361/s_axi_aresetn] [get_bd_pins axi_ad9361_adc_dma/m_dest_axi_aresetn] [get_bd_pins axi_ad9361_adc_dma/s_axi_aresetn] [get_bd_pins axi_ad9361_adc_dma1/m_dest_axi_aresetn] [get_bd_pins axi_ad9361_adc_dma1/s_axi_aresetn] [get_bd_pins axi_ad9361_dac_dma/m_src_axi_aresetn] [get_bd_pins axi_ad9361_dac_dma/s_axi_aresetn] [get_bd_pins axi_ad9361_dac_dma1/m_src_axi_aresetn] [get_bd_pins axi_ad9361_dac_dma1/s_axi_aresetn] [get_bd_pins axi_cpu_interconnect/ARESETN] [get_bd_pins axi_cpu_interconnect/M00_ARESETN] [get_bd_pins axi_cpu_interconnect/M01_ARESETN] [get_bd_pins axi_cpu_interconnect/M02_ARESETN] [get_bd_pins axi_cpu_interconnect/M03_ARESETN] [get_bd_pins axi_cpu_interconnect/M04_ARESETN] [get_bd_pins axi_cpu_interconnect/M05_ARESETN] [get_bd_pins axi_cpu_interconnect/M06_ARESETN] [get_bd_pins axi_cpu_interconnect/S00_ARESETN] [get_bd_pins axi_hp0_interconnect/ARESETN] [get_bd_pins axi_hp0_interconnect/M00_ARESETN] [get_bd_pins axi_hp0_interconnect/S00_ARESETN] [get_bd_pins axi_hp1_interconnect/ARESETN] [get_bd_pins axi_hp1_interconnect/M00_ARESETN] [get_bd_pins axi_hp1_interconnect/S00_ARESETN] [get_bd_pins axi_hp2_interconnect/ARESETN] [get_bd_pins axi_hp2_interconnect/M00_ARESETN] [get_bd_pins axi_hp2_interconnect/S00_ARESETN] [get_bd_pins axi_hp3_interconnect/ARESETN] [get_bd_pins axi_hp3_interconnect/M00_ARESETN] [get_bd_pins axi_hp3_interconnect/S00_ARESETN] [get_bd_pins axi_i2s_adi/dma_req_rx_rstn] [get_bd_pins axi_i2s_adi/dma_req_tx_rstn] [get_bd_pins axi_i2s_adi/s_axi_aresetn] [get_bd_pins axi_iic_main/s_axi_aresetn] [get_bd_pins sys_audio_clkgen/resetn] [get_bd_pins sys_rstgen/peripheral_aresetn] [get_bd_pins util_ad9361_divclk_reset/ext_reset_in] [get_bd_pins util_ad9361_tdd_sync/rstn]
  connect_bd_net -net sys_logic_inv_Res [get_bd_pins sys_logic_inv/Res] [get_bd_pins sys_ps7/USB0_VBUS_PWRFAULT]
  connect_bd_net -net sys_ps7_ENET1_GMII_RX_CLK_GND_dout [get_bd_pins sys_ps7/ENET1_GMII_RX_CLK] [get_bd_pins sys_ps7_ENET1_GMII_RX_CLK_GND/dout]
  connect_bd_net -net sys_ps7_ENET1_GMII_TX_CLK_GND_dout [get_bd_pins sys_ps7/ENET1_GMII_TX_CLK] [get_bd_pins sys_ps7_ENET1_GMII_TX_CLK_GND/dout]
  connect_bd_net -net sys_ps7_FCLK_RESET0_N [get_bd_pins sys_ps7/FCLK_RESET0_N] [get_bd_pins sys_rstgen/ext_reset_in]
  connect_bd_net -net sys_ps7_GPIO_O [get_bd_ports gpio_o] [get_bd_pins sys_ps7/GPIO_O]
  connect_bd_net -net sys_ps7_GPIO_T [get_bd_ports gpio_t] [get_bd_pins sys_ps7/GPIO_T]
  connect_bd_net -net sys_ps7_SPI0_MOSI_O [get_bd_ports spi0_sdo_o] [get_bd_pins sys_ps7/SPI0_MOSI_O]
  connect_bd_net -net sys_ps7_SPI0_SCLK_O [get_bd_ports spi0_clk_o] [get_bd_pins sys_ps7/SPI0_SCLK_O]
  connect_bd_net -net sys_ps7_SPI0_SS1_O [get_bd_ports spi0_csn_1_o] [get_bd_pins sys_ps7/SPI0_SS1_O]
  connect_bd_net -net sys_ps7_SPI0_SS2_O [get_bd_ports spi0_csn_2_o] [get_bd_pins sys_ps7/SPI0_SS2_O]
  connect_bd_net -net sys_ps7_SPI0_SS_O [get_bd_ports spi0_csn_0_o] [get_bd_pins sys_ps7/SPI0_SS_O]
  connect_bd_net -net sys_ps7_SPI1_MOSI_O [get_bd_ports spi1_sdo_o] [get_bd_pins sys_ps7/SPI1_MOSI_O]
  connect_bd_net -net sys_ps7_SPI1_SCLK_O [get_bd_ports spi1_clk_o] [get_bd_pins sys_ps7/SPI1_SCLK_O]
  connect_bd_net -net sys_ps7_SPI1_SS1_O [get_bd_ports spi1_csn_1_o] [get_bd_pins sys_ps7/SPI1_SS1_O]
  connect_bd_net -net sys_ps7_SPI1_SS2_O [get_bd_ports spi1_csn_2_o] [get_bd_pins sys_ps7/SPI1_SS2_O]
  connect_bd_net -net sys_ps7_SPI1_SS_O [get_bd_ports spi1_csn_0_o] [get_bd_pins sys_ps7/SPI1_SS_O]
  connect_bd_net -net tdd_sync_i_1 [get_bd_ports tdd_sync_i] [get_bd_pins util_ad9361_tdd_sync/sync_in]
  connect_bd_net -net up_enable_1 [get_bd_ports up_enable] [get_bd_pins axi_ad9361/up_enable]
  connect_bd_net -net up_txnrx_1 [get_bd_ports up_txnrx] [get_bd_pins axi_ad9361/up_txnrx]
  connect_bd_net -net util_ad9361_adc_fifo_din_ovf [get_bd_pins axi_ad9361/adc_dovf] [get_bd_pins util_ad9361_adc_fifo/din_ovf]
  connect_bd_net -net util_ad9361_adc_fifo_dout_enable_0 [get_bd_pins util_ad9361_adc_fifo/dout_enable_0] [get_bd_pins util_ad9361_adc_pack/adc_enable_0]
  connect_bd_net -net util_ad9361_adc_fifo_dout_enable_1 [get_bd_pins util_ad9361_adc_fifo/dout_enable_1] [get_bd_pins util_ad9361_adc_pack/adc_enable_1]
  connect_bd_net -net util_ad9361_adc_fifo_dout_enable_2 [get_bd_pins util_ad9361_adc_fifo/dout_enable_2] [get_bd_pins util_ad9361_adc_pack/adc_enable_2]
  connect_bd_net -net util_ad9361_adc_fifo_dout_enable_3 [get_bd_pins util_ad9361_adc_fifo/dout_enable_3] [get_bd_pins util_ad9361_adc_pack/adc_enable_3]
  connect_bd_net -net util_ad9361_adc_pack_adc_data [get_bd_pins axi_ad9361_adc_dma/fifo_wr_din] [get_bd_pins util_ad9361_adc_pack/adc_data]
  connect_bd_net -net util_ad9361_adc_pack_adc_sync [get_bd_pins axi_ad9361_adc_dma/fifo_wr_sync] [get_bd_pins util_ad9361_adc_pack/adc_sync]
  connect_bd_net -net util_ad9361_adc_pack_adc_valid [get_bd_pins axi_ad9361_adc_dma/fifo_wr_en] [get_bd_pins util_ad9361_adc_pack/adc_valid]
  connect_bd_net -net util_ad9361_dac_upack_dac_data_0 [get_bd_pins util_ad9361_dac_upack/dac_data_0] [get_bd_pins util_mux_0/in0_4]
  connect_bd_net -net util_ad9361_dac_upack_dac_data_1 [get_bd_pins util_ad9361_dac_upack/dac_data_1] [get_bd_pins util_mux_0/in0_5]
  connect_bd_net -net util_ad9361_dac_upack_dac_data_2 [get_bd_pins util_ad9361_dac_upack/dac_data_2] [get_bd_pins util_mux_0/in0_6]
  connect_bd_net -net util_ad9361_dac_upack_dac_data_3 [get_bd_pins util_ad9361_dac_upack/dac_data_3] [get_bd_pins util_mux_0/in0_7]
  connect_bd_net -net util_ad9361_dac_upack_dac_valid [get_bd_pins axi_ad9361_dac_dma/fifo_rd_en] [get_bd_pins util_ad9361_dac_upack/dac_valid]
  connect_bd_net -net util_ad9361_dac_upack_dac_valid_out_0 [get_bd_pins util_ad9361_dac_upack/dac_valid_out_0] [get_bd_pins util_mux_0/in0_0]
  connect_bd_net -net util_ad9361_dac_upack_dac_valid_out_1 [get_bd_pins util_ad9361_dac_upack/dac_valid_out_1] [get_bd_pins util_mux_0/in0_1]
  connect_bd_net -net util_ad9361_dac_upack_dac_valid_out_2 [get_bd_pins util_ad9361_dac_upack/dac_valid_out_2] [get_bd_pins util_mux_0/in0_2]
  connect_bd_net -net util_ad9361_dac_upack_dac_valid_out_3 [get_bd_pins util_ad9361_dac_upack/dac_valid_out_3] [get_bd_pins util_mux_0/in0_3]
  connect_bd_net -net util_ad9361_divclk_clk_out [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins axi_ad9361_adc_dma1/fifo_wr_clk] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_clk] [get_bd_pins axi_ad9361_dac_dma1/fifo_rd_clk] [get_bd_pins axi_ad9361_dac_fifo/din_clk] [get_bd_pins axi_cpu_interconnect/M07_ACLK] [get_bd_pins util_ad9361_adc_fifo/dout_clk] [get_bd_pins util_ad9361_adc_pack/adc_clk] [get_bd_pins util_ad9361_dac_upack/dac_clk] [get_bd_pins util_ad9361_divclk/clk_out] [get_bd_pins util_ad9361_divclk_reset/slowest_sync_clk]
  connect_bd_net -net util_ad9361_divclk_reset_peripheral_aresetn [get_bd_pins axi_ad9361_dac_fifo/din_rstn] [get_bd_pins util_ad9361_adc_fifo/dout_rstn] [get_bd_pins util_ad9361_divclk_reset/peripheral_aresetn]
  connect_bd_net -net util_ad9361_divclk_reset_peripheral_reset [get_bd_pins util_ad9361_adc_pack/adc_rst] [get_bd_pins util_ad9361_divclk_reset/peripheral_reset]
  connect_bd_net -net util_ad9361_divclk_sel_Res [get_bd_pins util_ad9361_divclk/clk_sel] [get_bd_pins util_ad9361_divclk_sel/Res]
  connect_bd_net -net util_ad9361_divclk_sel_concat_dout [get_bd_pins util_ad9361_divclk_sel/Op1] [get_bd_pins util_ad9361_divclk_sel_concat/dout]
  connect_bd_net -net util_ad9361_tdd_sync_sync_out [get_bd_ports tdd_sync_o] [get_bd_pins axi_ad9361/tdd_sync] [get_bd_pins util_ad9361_tdd_sync/sync_out]
  connect_bd_net -net util_mux_0_out_0 [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0] [get_bd_pins util_mux_0/out_0]
  connect_bd_net -net util_mux_0_out_1 [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_1] [get_bd_pins util_mux_0/out_1]
  connect_bd_net -net util_mux_0_out_2 [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_2] [get_bd_pins util_mux_0/out_2]
  connect_bd_net -net util_mux_0_out_3 [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_3] [get_bd_pins util_mux_0/out_3]
  connect_bd_net -net util_mux_0_out_4 [get_bd_pins axi_ad9361_dac_fifo/din_data_0] [get_bd_pins util_mux_0/out_4]
  connect_bd_net -net util_mux_0_out_5 [get_bd_pins axi_ad9361_dac_fifo/din_data_1] [get_bd_pins util_mux_0/out_5]
  connect_bd_net -net util_mux_0_out_6 [get_bd_pins axi_ad9361_dac_fifo/din_data_2] [get_bd_pins util_mux_0/out_6]
  connect_bd_net -net util_mux_0_out_7 [get_bd_pins axi_ad9361_dac_fifo/din_data_3] [get_bd_pins util_mux_0/out_7]

	connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_data_0] [get_bd_pins util_ad9361_adc_fifo/dout_data_0]
	connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_data_1] [get_bd_pins util_ad9361_adc_fifo/dout_data_1]
	connect_bd_net [get_bd_pins util_ad9361_adc_fifo/dout_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_0]
  
  # Create address segments
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces axi_ad9361_adc_dma/m_dest_axi] [get_bd_addr_segs sys_ps7/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_sys_ps7_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces axi_ad9361_adc_dma1/m_dest_axi] [get_bd_addr_segs sys_ps7/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_sys_ps7_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces axi_ad9361_dac_dma/m_src_axi] [get_bd_addr_segs sys_ps7/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_sys_ps7_HP2_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces axi_ad9361_dac_dma1/m_src_axi] [get_bd_addr_segs sys_ps7/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_sys_ps7_HP3_DDR_LOWOCM
  create_bd_addr_seg -range 0x00001000 -offset 0x7C440000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361_adc_dma1/s_axi/axi_lite] SEG_axi_ad9361_adc_dma1_axi_lite
  create_bd_addr_seg -range 0x00001000 -offset 0x7C460000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361_dac_dma1/s_axi/axi_lite] SEG_axi_ad9361_dac_dma1_axi_lite
  create_bd_addr_seg -range 0x00010000 -offset 0x79020000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361/s_axi/axi_lite] SEG_data_axi_ad9361
  create_bd_addr_seg -range 0x00001000 -offset 0x7C400000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361_adc_dma/s_axi/axi_lite] SEG_data_axi_ad9361_adc_dma
  create_bd_addr_seg -range 0x00001000 -offset 0x7C420000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361_dac_dma/s_axi/axi_lite] SEG_data_axi_ad9361_dac_dma
  create_bd_addr_seg -range 0x00010000 -offset 0x77600000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_i2s_adi/s_axi/axi_lite] SEG_data_axi_i2s_adi
  create_bd_addr_seg -range 0x00001000 -offset 0x41600000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_iic_main/S_AXI/Reg] SEG_data_axi_iic_main
  
  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port rx_clk_in_p -pg 1 -y 260 -defaultsOSRD
preplace port enable -pg 1 -y 210 -defaultsOSRD
preplace port spi0_sdi_i -pg 1 -y 3040 -defaultsOSRD
preplace port spi1_csn_1_o -pg 1 -y 2520 -defaultsOSRD
preplace port spi0_csn_2_o -pg 1 -y 2340 -defaultsOSRD
preplace port fixed_io -pg 1 -y 2140 -defaultsOSRD
preplace port tx_frame_out_n -pg 1 -y 150 -defaultsOSRD
preplace port rx_frame_in_n -pg 1 -y 280 -defaultsOSRD
preplace port tdd_sync_o -pg 1 -y 1510 -defaultsOSRD
preplace port up_txnrx -pg 1 -y 1680 -defaultsOSRD
preplace port ps_intr_00 -pg 1 -y 2670 -defaultsOSRD
preplace port tx_clk_out_n -pg 1 -y 110 -defaultsOSRD
preplace port up_enable -pg 1 -y 1660 -defaultsOSRD
preplace port ps_intr_01 -pg 1 -y 2690 -defaultsOSRD
preplace port spi1_sdi_i -pg 1 -y 3120 -defaultsOSRD
preplace port spi1_csn_i -pg 1 -y 3100 -defaultsOSRD
preplace port tx_frame_out_p -pg 1 -y 130 -defaultsOSRD
preplace port rx_frame_in_p -pg 1 -y 300 -defaultsOSRD
preplace port ps_intr_02 -pg 1 -y 2710 -defaultsOSRD
preplace port spi0_clk_o -pg 1 -y 2200 -defaultsOSRD
preplace port spi0_csn_i -pg 1 -y 3020 -defaultsOSRD
preplace port tx_clk_out_p -pg 1 -y 90 -defaultsOSRD
preplace port i2s_mclk -pg 1 -y 40 -defaultsOSRD
preplace port ps_intr_03 -pg 1 -y 2730 -defaultsOSRD
preplace port ps_intr_15 -pg 1 -y 2970 -defaultsOSRD
preplace port spi1_sdo_i -pg 1 -y 3140 -defaultsOSRD
preplace port ps_intr_04 -pg 1 -y 2750 -defaultsOSRD
preplace port spi1_clk_i -pg 1 -y 3080 -defaultsOSRD
preplace port spi0_sdo_i -pg 1 -y 3060 -defaultsOSRD
preplace port otg_vbusoc -pg 1 -y 2610 -defaultsOSRD
preplace port tdd_sync_t -pg 1 -y 270 -defaultsOSRD
preplace port ps_intr_05 -pg 1 -y 2770 -defaultsOSRD
preplace port iic_main -pg 1 -y 1820 -defaultsOSRD
preplace port ddr -pg 1 -y 2120 -defaultsOSRD
preplace port gps_pps -pg 1 -y 1640 -defaultsOSRD
preplace port ps_intr_06 -pg 1 -y 2790 -defaultsOSRD
preplace port spi0_csn_1_o -pg 1 -y 2320 -defaultsOSRD
preplace port tdd_sync_i -pg 1 -y 1530 -defaultsOSRD
preplace port ps_intr_07 -pg 1 -y 2810 -defaultsOSRD
preplace port spi1_csn_0_o -pg 1 -y 2500 -defaultsOSRD
preplace port spi0_csn_0_o -pg 1 -y 2300 -defaultsOSRD
preplace port ps_intr_08 -pg 1 -y 2830 -defaultsOSRD
preplace port i2s -pg 1 -y 20 -defaultsOSRD
preplace port rx_clk_in_n -pg 1 -y 240 -defaultsOSRD
preplace port spi1_sdo_o -pg 1 -y 2440 -defaultsOSRD
preplace port spi0_clk_i -pg 1 -y 3000 -defaultsOSRD
preplace port txnrx -pg 1 -y 230 -defaultsOSRD
preplace port spi1_clk_o -pg 1 -y 2400 -defaultsOSRD
preplace port spi1_csn_2_o -pg 1 -y 2540 -defaultsOSRD
preplace port spi0_sdo_o -pg 1 -y 2240 -defaultsOSRD
preplace portBus rx_data_in_p -pg 1 -y 320 -defaultsOSRD
preplace portBus gpio_o -pg 1 -y 2080 -defaultsOSRD
preplace portBus gpio_t -pg 1 -y 2100 -defaultsOSRD
preplace portBus tx_data_out_n -pg 1 -y 190 -defaultsOSRD
preplace portBus gpio_i -pg 1 -y 2560 -defaultsOSRD
preplace portBus tx_data_out_p -pg 1 -y 170 -defaultsOSRD
preplace portBus rx_data_in_n -pg 1 -y 340 -defaultsOSRD
preplace inst util_mux_0 -pg 1 -lvl 4 -y 1110 -defaultsOSRD
preplace inst axi_i2s_adi -pg 1 -lvl 12 -y 2190 -defaultsOSRD
preplace inst util_ad9361_tdd_sync -pg 1 -lvl 11 -y 1510 -defaultsOSRD
preplace inst axi_hp2_interconnect -pg 1 -lvl 10 -y 2040 -defaultsOSRD
preplace inst axi_ad9361 -pg 1 -lvl 8 -y 450 -defaultsOSRD
preplace inst axi_hp0_interconnect -pg 1 -lvl 9 -y 2270 -defaultsOSRD
preplace inst axi_hp3_interconnect -pg 1 -lvl 9 -y 2520 -defaultsOSRD
preplace inst sys_ps7_ENET1_GMII_RX_CLK_GND -pg 1 -lvl 11 -y 2870 -defaultsOSRD
preplace inst util_ad9361_divclk_sel_concat -pg 1 -lvl 1 -y 1460 -defaultsOSRD
preplace inst sys_logic_inv -pg 1 -lvl 1 -y 2610 -defaultsOSRD
preplace inst axi_iic_main -pg 1 -lvl 11 -y 1840 -defaultsOSRD
preplace inst axi_ad9361_adc_dma1 -pg 1 -lvl 8 -y 1560 -defaultsOSRD
preplace inst axi_ad9361_adc_dma -pg 1 -lvl 8 -y 1130 -defaultsOSRD
preplace inst sys_concat_intc -pg 1 -lvl 10 -y 2820 -defaultsOSRD
preplace inst sys_audio_clkgen -pg 1 -lvl 2 -y 1590 -defaultsOSRD
preplace inst sys_ps7_ENET1_GMII_TX_CLK_GND -pg 1 -lvl 11 -y 2950 -defaultsOSRD
preplace inst axi_ad9361_dac_dma1 -pg 1 -lvl 8 -y 2630 -defaultsOSRD
preplace inst axi_ad9361_dac_dma -pg 1 -lvl 8 -y 2250 -defaultsOSRD
preplace inst util_ad9361_divclk_reset -pg 1 -lvl 5 -y 1540 -defaultsOSRD
preplace inst util_ad9361_divclk_sel -pg 1 -lvl 2 -y 1460 -defaultsOSRD
preplace inst sys_rstgen -pg 1 -lvl 3 -y 2250 -defaultsOSRD
preplace inst util_ad9361_adc_fifo -pg 1 -lvl 6 -y 580 -defaultsOSRD
preplace inst util_ad9361_divclk -pg 1 -lvl 3 -y 1500 -defaultsOSRD
preplace inst util_ad9361_dac_upack -pg 1 -lvl 7 -y 1180 -defaultsOSRD
preplace inst axi_ad9361_dac_fifo -pg 1 -lvl 6 -y 1200 -defaultsOSRD
preplace inst util_ad9361_adc_pack -pg 1 -lvl 7 -y 630 -defaultsOSRD
preplace inst axi_cpu_interconnect -pg 1 -lvl 7 -y 1640 -defaultsOSRD
preplace inst sys_ps7 -pg 1 -lvl 11 -y 2370 -defaultsOSRD
preplace inst axi_hp1_interconnect -pg 1 -lvl 10 -y 1680 -defaultsOSRD
preplace netloc S00_AXI_2 1 8 2 NJ 1120 4210
preplace netloc axi_ad9361_dac_valid_i1 1 5 4 1770 1910 NJ 1910 NJ 1910 3750
preplace netloc gps_pps_1 1 0 8 20J 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 3070J
preplace netloc S00_AXI_3 1 8 2 3720J 1980 NJ
preplace netloc M07_ARESETN_1 1 5 2 NJ 1560 2100
preplace netloc axi_ad9361_dac_enable_i0 1 5 4 1780 940 NJ 940 NJ 940 3760
preplace netloc sys_ps7_SPI1_MOSI_O 1 11 2 NJ 2440 NJ
preplace netloc S00_AXI_4 1 8 1 3830
preplace netloc axi_ad9361_dac_enable_i1 1 5 4 1740 1940 NJ 1940 NJ 1940 3790
preplace netloc util_ad9361_adc_fifo_dout_enable_0 1 6 1 2280
preplace netloc ps_intr_06_1 1 0 10 -10J 2800 NJ 2800 NJ 2800 NJ 2800 NJ 2800 NJ 2800 NJ 2800 NJ 2800 NJ 2800 4240J
preplace netloc sys_ps7_GPIO_O 1 11 2 5210J 1990 5670J
preplace netloc otg_vbusoc_1 1 0 1 NJ
preplace netloc CombinedT_ip_0_validRx 1 6 1 2280
preplace netloc util_ad9361_adc_fifo_dout_enable_1 1 6 1 2270
preplace netloc axi_ad9361_adc_data_q0 1 5 4 1720 -20 NJ -20 NJ -20 3770
preplace netloc up_enable_1 1 0 8 NJ 1660 NJ 1660 NJ 1660 NJ 1660 NJ 1660 NJ 1660 2170J 340 3060J
preplace netloc axi_ad9361_adc_dma1_irq 1 8 2 NJ 1570 4180
preplace netloc util_ad9361_adc_fifo_dout_enable_2 1 6 1 2260
preplace netloc axi_ad9361_adc_data_q1 1 5 4 1700 -10 NJ -10 NJ -10 3820
preplace netloc ps_intr_02_1 1 0 10 30J 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 NJ 2760 4190J
preplace netloc sys_audio_clkgen_clk_out1 1 2 11 510J 1410 NJ 1410 NJ 1410 1610J 1460 2240J 1370 NJ 1370 NJ 1370 NJ 1370 NJ 1370 5310 1370 5660J
preplace netloc util_ad9361_adc_fifo_dout_enable_3 1 6 1 2240
preplace netloc util_ad9361_divclk_clk_out 1 3 5 NJ 1500 1220 2330 1670 2330 2250 2330 3070
preplace netloc axi_ad9361_l_clk 1 2 7 520 300 NJ 300 NJ 300 1680 300 NJ 300 2870 900 3810
preplace netloc ps_intr_01_1 1 0 10 40J 2750 NJ 2750 NJ 2750 NJ 2750 NJ 2750 NJ 2750 NJ 2750 NJ 2750 NJ 2750 4170J
preplace netloc axi_ad9361_adc_valid_q0 1 5 4 1760 820 NJ 820 3000J 880 3740
preplace netloc axi_hp3_interconnect_M00_AXI 1 9 2 NJ 2520 4560
preplace netloc axi_ad9361_tx_frame_out_n 1 8 5 NJ 150 NJ 150 NJ 150 NJ 150 NJ
preplace netloc axi_ad9361_dac_valid_q0 1 5 4 1750 1490 2220J 1320 NJ 1320 3720
preplace netloc axi_ad9361_adc_dma_fifo_wr_overflow 1 5 3 1770 920 NJ 920 2910J
preplace netloc axi_ad9361_adc_valid_q1 1 5 4 1750 930 NJ 930 NJ 930 3770
preplace netloc sys_ps7_ENET1_GMII_RX_CLK_GND_dout 1 11 1 5180
preplace netloc axi_ad9361_dac_valid_q1 1 5 4 1780 1450 2200J 1330 NJ 1330 3690
preplace netloc sys_ps7_GPIO_T 1 11 2 5240J 2020 5660J
preplace netloc axi_ad9361_tx_frame_out_p 1 8 5 NJ 130 NJ 130 NJ 130 NJ 130 NJ
preplace netloc axi_ad9361_dac_dma_fifo_rd_dout 1 6 2 2280 2230 NJ
preplace netloc rx_frame_in_n_1 1 0 8 NJ 280 NJ 280 NJ 280 NJ 280 NJ 280 NJ 280 NJ 280 NJ
preplace netloc util_ad9361_dac_upack_dac_valid 1 7 1 2860
preplace netloc util_ad9361_dac_upack_dac_data_0 1 3 5 900 890 NJ 890 NJ 890 NJ 890 2830
preplace netloc ps_intr_05_1 1 0 10 0J 2790 NJ 2790 NJ 2790 NJ 2790 NJ 2790 NJ 2790 NJ 2790 NJ 2790 NJ 2790 4230J
preplace netloc sys_ps7_FCLK_RESET0_N 1 2 10 500 1920 NJ 1920 NJ 1920 NJ 1920 NJ 1920 NJ 1920 NJ 1920 NJ 1920 NJ 1920 5110
preplace netloc util_ad9361_divclk_sel_Res 1 2 1 500
preplace netloc util_ad9361_dac_upack_dac_data_1 1 3 5 880 860 1220J 910 NJ 910 NJ 910 2820
preplace netloc util_ad9361_tdd_sync_sync_out 1 7 6 3080 1360 NJ 1360 NJ 1360 NJ 1360 5300 1360 5670J
preplace netloc axi_cpu_interconnect_M04_AXI 1 7 5 2840J 1670 NJ 1670 4150J 1560 4580J 1590 5300
preplace netloc util_ad9361_dac_upack_dac_data_2 1 3 5 890 900 NJ 900 NJ 900 NJ 900 2860
preplace netloc util_ad9361_adc_fifo_din_ovf 1 6 2 2120 440 NJ
preplace netloc ps_intr_07_1 1 0 10 NJ 2810 NJ 2810 NJ 2810 NJ 2810 NJ 2810 NJ 2810 NJ 2810 NJ 2810 NJ 2810 NJ
preplace netloc sys_ps7_DMA1_ACK 1 11 1 5330
preplace netloc util_ad9361_dac_upack_dac_data_3 1 3 5 850 840 NJ 840 NJ 840 NJ 840 2890
preplace netloc spi0_sdi_i_1 1 0 12 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 5150
preplace netloc ps_intr_00_1 1 0 10 50J 2740 NJ 2740 NJ 2740 NJ 2740 NJ 2740 NJ 2740 NJ 2740 NJ 2740 NJ 2740 4150J
preplace netloc sys_ps7_SPI1_SS2_O 1 11 2 NJ 2540 NJ
preplace netloc axi_cpu_interconnect_M01_AXI 1 7 1 2920
preplace netloc rx_clk_in_p_1 1 0 8 20J 220 NJ 220 NJ 220 NJ 220 NJ 220 NJ 220 NJ 220 NJ
preplace netloc util_ad9361_divclk_reset_peripheral_aresetn 1 5 1 1630
preplace netloc axi_ad9361_dac_fifo_din_valid_0 1 6 1 2230
preplace netloc sys_ps7_SPI0_SS1_O 1 11 2 5220J 2330 5620J
preplace netloc rx_clk_in_n_1 1 0 8 NJ 240 NJ 240 NJ 240 NJ 240 NJ 240 NJ 240 NJ 240 NJ
preplace netloc axi_ad9361_dac_fifo_din_valid_1 1 6 1 2180
preplace netloc tdd_sync_i_1 1 0 11 30J 1350 NJ 1350 NJ 1350 NJ 1350 NJ 1350 1620J 1480 2230J 1350 NJ 1350 NJ 1350 NJ 1350 4580J
preplace netloc sys_ps7_DDR 1 11 2 5280J 2040 5620J
preplace netloc axi_ad9361_dac_dma1_m_src_axi 1 8 1 3830
preplace netloc axi_ad9361_dac_fifo_din_valid_2 1 6 1 2140
preplace netloc spi1_clk_i_1 1 0 12 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 NJ 3080 5140
preplace netloc spi0_csn_i_1 1 0 12 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 NJ 3020 5080
preplace netloc sys_logic_inv_Res 1 1 11 280J 2400 NJ 2400 NJ 2400 NJ 2400 NJ 2400 NJ 2400 NJ 2400 NJ 2400 NJ 2400 4540J 2820 5070
preplace netloc axi_iic_main_IIC 1 11 2 NJ 1820 NJ
preplace netloc axi_hp0_interconnect_M00_AXI 1 9 2 NJ 2270 4540
preplace netloc axi_ad9361_tx_clk_out_n 1 8 5 NJ 110 NJ 110 NJ 110 NJ 110 NJ
preplace netloc axi_ad9361_dac_fifo_din_valid_3 1 6 1 2100
preplace netloc util_ad9361_divclk_reset_peripheral_reset 1 5 2 NJ 1540 2210J
preplace netloc axi_ad9361_rst 1 5 4 1710 880 NJ 880 2940J 910 3800
preplace netloc axi_ad9361_dac_r1_mode 1 0 9 50 1900 NJ 1900 NJ 1900 NJ 1900 NJ 1900 NJ 1900 NJ 1900 NJ 1900 3680
preplace netloc ps_intr_08_1 1 0 10 NJ 2830 NJ 2830 NJ 2830 NJ 2830 NJ 2830 NJ 2830 NJ 2830 NJ 2830 NJ 2830 NJ
preplace netloc sys_ps7_SPI0_MOSI_O 1 11 2 5250J 2000 5640J
preplace netloc axi_ad9361_tx_clk_out_p 1 8 5 NJ 90 NJ 90 NJ 90 NJ 90 NJ
preplace netloc axi_ad9361_adc_r1_mode 1 0 9 40 1930 NJ 1930 NJ 1930 NJ 1930 NJ 1930 NJ 1930 NJ 1930 NJ 1930 3820
preplace netloc sys_ps7_SPI1_SS_O 1 11 2 NJ 2500 NJ
preplace netloc axi_ad9361_adc_enable_i0 1 5 4 1760 0 NJ 0 NJ 0 3710
preplace netloc axi_ad9361_adc_dma_irq 1 8 2 NJ 1140 4160
preplace netloc axi_ad9361_adc_enable_i1 1 5 4 1740 10 NJ 10 NJ 10 3760
preplace netloc util_ad9361_divclk_sel_concat_dout 1 1 1 NJ
preplace netloc axi_cpu_interconnect_M03_AXI 1 7 1 2830
preplace netloc gpio_i_1 1 0 12 30J 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 4550J 2810 5090
preplace netloc sys_ps7_SPI1_SCLK_O 1 11 2 NJ 2400 NJ
preplace netloc ps_intr_04_1 1 0 10 10J 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 4220J
preplace netloc util_ad9361_adc_pack_adc_sync 1 7 1 2950
preplace netloc axi_ad9361_tdd_sync_cntr 1 8 5 NJ 270 NJ 270 4610 270 NJ 270 NJ
preplace netloc axi_ad9361_txnrx 1 8 5 NJ 230 NJ 230 NJ 230 NJ 230 NJ
preplace netloc axi_cpu_interconnect_M00_AXI 1 7 4 2880J 1820 NJ 1820 NJ 1820 NJ
preplace netloc axi_ad9361_enable 1 8 5 NJ 210 NJ 210 NJ 210 NJ 210 NJ
preplace netloc axi_cpu_interconnect_M05_AXI 1 7 1 2820
preplace netloc axi_ad9361_dac_fifo_din_enable_0 1 6 1 2240
preplace netloc up_txnrx_1 1 0 8 NJ 1680 NJ 1680 NJ 1680 NJ 1680 NJ 1680 NJ 1680 2190J 350 3050J
preplace netloc axi_hp1_interconnect_M00_AXI 1 10 1 4550
preplace netloc util_mux_0_out_0 1 4 2 NJ 1040 NJ
preplace netloc axi_ad9361_dac_fifo_din_enable_1 1 6 1 2200
preplace netloc ps_intr_03_1 1 0 10 20J 2770 NJ 2770 NJ 2770 NJ 2770 NJ 2770 NJ 2770 NJ 2770 NJ 2770 NJ 2770 4210J
preplace netloc axi_i2s_adi_dma_req_tx 1 10 3 4610 1770 NJ 1770 5580
preplace netloc util_mux_0_out_1 1 4 2 NJ 1060 1650
preplace netloc axi_ad9361_dac_fifo_din_enable_2 1 6 1 2160
preplace netloc util_ad9361_dac_upack_dac_valid_out_0 1 3 5 910 850 NJ 850 NJ 850 NJ 850 2840
preplace netloc sys_200m_clk 1 1 11 290 2680 NJ 2680 NJ 2680 NJ 2680 NJ 2680 NJ 2680 2990 1340 NJ 1340 NJ 1340 NJ 1340 5190
preplace netloc CombinedT_ip_0_axi_ad9361_dac_data_i0 1 3 1 910
preplace netloc util_mux_0_out_2 1 4 2 NJ 1080 1640
preplace netloc axi_ad9361_dac_fifo_din_enable_3 1 6 1 2120
preplace netloc util_ad9361_dac_upack_dac_valid_out_1 1 3 5 920 870 NJ 870 NJ 870 NJ 870 2850
preplace netloc CombinedT_ip_0_axi_ad9361_dac_data_q0 1 3 1 920
preplace netloc util_mux_0_out_3 1 4 2 1220J 1160 N
preplace netloc util_ad9361_dac_upack_dac_valid_out_2 1 3 5 860 360 NJ 360 NJ 360 NJ 360 2880
preplace netloc sys_concat_intc_dout 1 10 1 4530
preplace netloc axi_ad9361_adc_enable_q0 1 5 4 1770 20 NJ 20 NJ 20 3700
preplace netloc ps_intr_15_1 1 0 10 NJ 2970 NJ 2970 NJ 2970 NJ 2970 NJ 2970 NJ 2970 NJ 2970 NJ 2970 NJ 2970 NJ
preplace netloc util_mux_0_out_4 1 4 2 NJ 1120 1660
preplace netloc axi_ad9361_dac_dma1_irq 1 8 2 3670 2850 NJ
preplace netloc sys_ps7_ENET1_GMII_TX_CLK_GND_dout 1 11 1 5170
preplace netloc util_ad9361_dac_upack_dac_valid_out_3 1 3 5 870 370 NJ 370 NJ 370 NJ 370 2900
preplace netloc axi_ad9361_dac_enable_q0 1 5 4 1770 950 NJ 950 NJ 950 3730
preplace netloc axi_ad9361_adc_enable_q1 1 5 4 1750 30 NJ 30 NJ 30 3750
preplace netloc axi_iic_main_iic2intc_irpt 1 9 3 4250J 1430 NJ 1430 5090
preplace netloc spi1_sdi_i_1 1 0 12 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 NJ 3120 5130
preplace netloc sys_ps7_FIXED_IO 1 11 2 5290J 2050 5610J
preplace netloc util_mux_0_out_5 1 4 2 1230J 1100 N
preplace netloc rx_frame_in_p_1 1 0 8 50J 260 NJ 260 NJ 260 NJ 260 NJ 260 NJ 260 NJ 260 NJ
preplace netloc axi_ad9361_dac_fifo_dout_unf 1 6 2 NJ 1360 2960J
preplace netloc axi_ad9361_dac_enable_q1 1 5 4 1760 1950 NJ 1950 NJ 1950 3780
preplace netloc util_ad9361_adc_pack_adc_data 1 7 1 2970
preplace netloc util_mux_0_out_6 1 4 2 1240J 1140 N
preplace netloc axi_ad9361_tx_data_out_n 1 8 5 NJ 190 NJ 190 NJ 190 NJ 190 NJ
preplace netloc axi_ad9361_dac_fifo_dout_data_0 1 6 2 2110 420 2840J
preplace netloc util_mux_0_out_7 1 4 2 NJ 1180 N
preplace netloc axi_ad9361_dac_fifo_dout_data_1 1 6 2 2150 450 3030J
preplace netloc axi_cpu_interconnect_M02_AXI 1 7 1 3020
preplace netloc axi_ad9361_tx_data_out_p 1 8 5 NJ 170 NJ 170 NJ 170 NJ 170 NJ
preplace netloc axi_ad9361_dac_fifo_dout_data_2 1 6 2 2130 430 3040J
preplace netloc spi0_clk_i_1 1 0 12 20J 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 NJ 3030 5160
preplace netloc axi_cpu_interconnect_M06_AXI 1 7 1 2820
preplace netloc rx_data_in_n_1 1 0 8 10J 320 NJ 320 NJ 320 NJ 320 NJ 320 NJ 320 NJ 320 NJ
preplace netloc axi_ad9361_dac_fifo_dout_data_3 1 6 2 NJ 1340 2930J
preplace netloc spi0_sdo_i_1 1 0 12 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 5210
preplace netloc axi_i2s_adi_dma_req_rx 1 10 3 4600 1750 NJ 1750 5590
preplace netloc sys_ps7_DMA0_ACK 1 11 1 5340
preplace netloc util_ad9361_adc_pack_adc_valid 1 7 1 3010
preplace netloc sys_cpu_reset 1 3 1 N
preplace netloc spi1_csn_i_1 1 0 12 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 5100
preplace netloc sys_ps7_SPI0_SS2_O 1 11 2 NJ 2340 NJ
preplace netloc axi_i2s_adi_i2s 1 12 1 5650
preplace netloc axi_ad9361_adc_data_i0 1 5 4 1730 860 NJ 860 NJ 860 3710
preplace netloc sys_cpu_clk 1 2 10 520 2000 NJ 2000 NJ 2000 NJ 2000 2260 2000 3030 2000 3840 2000 4220 1540 4570 1930 5230
preplace netloc sys_cpu_resetn 1 1 11 280 2100 NJ 2100 890 2100 1230J 2100 NJ 2100 2270 2100 3040 2100 3810 2100 4190 1520 4590 1910 5270
preplace netloc axi_ad9361_adc_data_i1 1 5 4 1690 -40 NJ -40 NJ -40 3830
preplace netloc sys_ps7_SPI0_SS_O 1 11 2 5320J 2030 5600J
preplace netloc sys_ps7_SPI0_SCLK_O 1 11 2 5260J 2010 5630J
preplace netloc axi_hp2_interconnect_M00_AXI 1 10 1 4530
preplace netloc CombinedT_ip_0_axi_ad9361_dac_fifo_valid 1 3 1 920
preplace netloc rx_data_in_p_1 1 0 8 0J 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 NJ 330 2880J
preplace netloc axi_ad9361_adc_valid_i0 1 5 4 1780 40 NJ 40 NJ 40 3670
preplace netloc spi1_sdo_i_1 1 0 12 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 NJ 3140 5200
preplace netloc S00_AXI_1 1 6 6 2290 1380 NJ 1380 NJ 1380 NJ 1380 NJ 1380 5120
preplace netloc axi_ad9361_gps_pps_irq 1 8 2 NJ 290 4200
preplace netloc axi_ad9361_dac_dma_irq 1 8 2 3730J 2910 NJ
preplace netloc axi_ad9361_dac_valid_i0 1 5 4 1740 830 NJ 830 2980J 890 3670
preplace netloc axi_ad9361_adc_valid_i1 1 5 4 1780 810 NJ 810 3020J 870 3700
preplace netloc sys_ps7_SPI1_SS1_O 1 11 2 NJ 2520 NJ
levelinfo -pg 1 -30 170 400 690 1120 1450 1960 2690 3510 4020 4400 4840 5460 5690 -top -710 -bot 3330
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

