# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CPLL_FBDIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CPLL_FBDIV_4_5" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QPLL_CFG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QPLL_FBDIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QPLL_FBDIV_RATIO" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QPLL_REFCLK_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_CDR_CFG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_CLK25_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_DFE_LPM_CFG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_NUM_OF_LANES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_OUT_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_PMA_CFG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_CLK25_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_NUM_OF_LANES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_OUT_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "XCVR_TYPE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CPLL_FBDIV { PARAM_VALUE.CPLL_FBDIV } {
	# Procedure called to update CPLL_FBDIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPLL_FBDIV { PARAM_VALUE.CPLL_FBDIV } {
	# Procedure called to validate CPLL_FBDIV
	return true
}

proc update_PARAM_VALUE.CPLL_FBDIV_4_5 { PARAM_VALUE.CPLL_FBDIV_4_5 } {
	# Procedure called to update CPLL_FBDIV_4_5 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPLL_FBDIV_4_5 { PARAM_VALUE.CPLL_FBDIV_4_5 } {
	# Procedure called to validate CPLL_FBDIV_4_5
	return true
}

proc update_PARAM_VALUE.QPLL_CFG { PARAM_VALUE.QPLL_CFG } {
	# Procedure called to update QPLL_CFG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QPLL_CFG { PARAM_VALUE.QPLL_CFG } {
	# Procedure called to validate QPLL_CFG
	return true
}

proc update_PARAM_VALUE.QPLL_FBDIV { PARAM_VALUE.QPLL_FBDIV } {
	# Procedure called to update QPLL_FBDIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QPLL_FBDIV { PARAM_VALUE.QPLL_FBDIV } {
	# Procedure called to validate QPLL_FBDIV
	return true
}

proc update_PARAM_VALUE.QPLL_FBDIV_RATIO { PARAM_VALUE.QPLL_FBDIV_RATIO } {
	# Procedure called to update QPLL_FBDIV_RATIO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QPLL_FBDIV_RATIO { PARAM_VALUE.QPLL_FBDIV_RATIO } {
	# Procedure called to validate QPLL_FBDIV_RATIO
	return true
}

proc update_PARAM_VALUE.QPLL_REFCLK_DIV { PARAM_VALUE.QPLL_REFCLK_DIV } {
	# Procedure called to update QPLL_REFCLK_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QPLL_REFCLK_DIV { PARAM_VALUE.QPLL_REFCLK_DIV } {
	# Procedure called to validate QPLL_REFCLK_DIV
	return true
}

proc update_PARAM_VALUE.RX_CDR_CFG { PARAM_VALUE.RX_CDR_CFG } {
	# Procedure called to update RX_CDR_CFG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_CDR_CFG { PARAM_VALUE.RX_CDR_CFG } {
	# Procedure called to validate RX_CDR_CFG
	return true
}

proc update_PARAM_VALUE.RX_CLK25_DIV { PARAM_VALUE.RX_CLK25_DIV } {
	# Procedure called to update RX_CLK25_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_CLK25_DIV { PARAM_VALUE.RX_CLK25_DIV } {
	# Procedure called to validate RX_CLK25_DIV
	return true
}

proc update_PARAM_VALUE.RX_DFE_LPM_CFG { PARAM_VALUE.RX_DFE_LPM_CFG } {
	# Procedure called to update RX_DFE_LPM_CFG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_DFE_LPM_CFG { PARAM_VALUE.RX_DFE_LPM_CFG } {
	# Procedure called to validate RX_DFE_LPM_CFG
	return true
}

proc update_PARAM_VALUE.RX_NUM_OF_LANES { PARAM_VALUE.RX_NUM_OF_LANES } {
	# Procedure called to update RX_NUM_OF_LANES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_NUM_OF_LANES { PARAM_VALUE.RX_NUM_OF_LANES } {
	# Procedure called to validate RX_NUM_OF_LANES
	return true
}

proc update_PARAM_VALUE.RX_OUT_DIV { PARAM_VALUE.RX_OUT_DIV } {
	# Procedure called to update RX_OUT_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_OUT_DIV { PARAM_VALUE.RX_OUT_DIV } {
	# Procedure called to validate RX_OUT_DIV
	return true
}

proc update_PARAM_VALUE.RX_PMA_CFG { PARAM_VALUE.RX_PMA_CFG } {
	# Procedure called to update RX_PMA_CFG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_PMA_CFG { PARAM_VALUE.RX_PMA_CFG } {
	# Procedure called to validate RX_PMA_CFG
	return true
}

proc update_PARAM_VALUE.TX_CLK25_DIV { PARAM_VALUE.TX_CLK25_DIV } {
	# Procedure called to update TX_CLK25_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_CLK25_DIV { PARAM_VALUE.TX_CLK25_DIV } {
	# Procedure called to validate TX_CLK25_DIV
	return true
}

proc update_PARAM_VALUE.TX_NUM_OF_LANES { PARAM_VALUE.TX_NUM_OF_LANES } {
	# Procedure called to update TX_NUM_OF_LANES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_NUM_OF_LANES { PARAM_VALUE.TX_NUM_OF_LANES } {
	# Procedure called to validate TX_NUM_OF_LANES
	return true
}

proc update_PARAM_VALUE.TX_OUT_DIV { PARAM_VALUE.TX_OUT_DIV } {
	# Procedure called to update TX_OUT_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_OUT_DIV { PARAM_VALUE.TX_OUT_DIV } {
	# Procedure called to validate TX_OUT_DIV
	return true
}

proc update_PARAM_VALUE.XCVR_TYPE { PARAM_VALUE.XCVR_TYPE } {
	# Procedure called to update XCVR_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.XCVR_TYPE { PARAM_VALUE.XCVR_TYPE } {
	# Procedure called to validate XCVR_TYPE
	return true
}


proc update_MODELPARAM_VALUE.XCVR_TYPE { MODELPARAM_VALUE.XCVR_TYPE PARAM_VALUE.XCVR_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.XCVR_TYPE}] ${MODELPARAM_VALUE.XCVR_TYPE}
}

proc update_MODELPARAM_VALUE.QPLL_REFCLK_DIV { MODELPARAM_VALUE.QPLL_REFCLK_DIV PARAM_VALUE.QPLL_REFCLK_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QPLL_REFCLK_DIV}] ${MODELPARAM_VALUE.QPLL_REFCLK_DIV}
}

proc update_MODELPARAM_VALUE.QPLL_FBDIV_RATIO { MODELPARAM_VALUE.QPLL_FBDIV_RATIO PARAM_VALUE.QPLL_FBDIV_RATIO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QPLL_FBDIV_RATIO}] ${MODELPARAM_VALUE.QPLL_FBDIV_RATIO}
}

proc update_MODELPARAM_VALUE.QPLL_CFG { MODELPARAM_VALUE.QPLL_CFG PARAM_VALUE.QPLL_CFG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QPLL_CFG}] ${MODELPARAM_VALUE.QPLL_CFG}
}

proc update_MODELPARAM_VALUE.QPLL_FBDIV { MODELPARAM_VALUE.QPLL_FBDIV PARAM_VALUE.QPLL_FBDIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QPLL_FBDIV}] ${MODELPARAM_VALUE.QPLL_FBDIV}
}

proc update_MODELPARAM_VALUE.CPLL_FBDIV { MODELPARAM_VALUE.CPLL_FBDIV PARAM_VALUE.CPLL_FBDIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPLL_FBDIV}] ${MODELPARAM_VALUE.CPLL_FBDIV}
}

proc update_MODELPARAM_VALUE.CPLL_FBDIV_4_5 { MODELPARAM_VALUE.CPLL_FBDIV_4_5 PARAM_VALUE.CPLL_FBDIV_4_5 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPLL_FBDIV_4_5}] ${MODELPARAM_VALUE.CPLL_FBDIV_4_5}
}

proc update_MODELPARAM_VALUE.TX_NUM_OF_LANES { MODELPARAM_VALUE.TX_NUM_OF_LANES PARAM_VALUE.TX_NUM_OF_LANES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_NUM_OF_LANES}] ${MODELPARAM_VALUE.TX_NUM_OF_LANES}
}

proc update_MODELPARAM_VALUE.TX_OUT_DIV { MODELPARAM_VALUE.TX_OUT_DIV PARAM_VALUE.TX_OUT_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_OUT_DIV}] ${MODELPARAM_VALUE.TX_OUT_DIV}
}

proc update_MODELPARAM_VALUE.TX_CLK25_DIV { MODELPARAM_VALUE.TX_CLK25_DIV PARAM_VALUE.TX_CLK25_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_CLK25_DIV}] ${MODELPARAM_VALUE.TX_CLK25_DIV}
}

proc update_MODELPARAM_VALUE.RX_NUM_OF_LANES { MODELPARAM_VALUE.RX_NUM_OF_LANES PARAM_VALUE.RX_NUM_OF_LANES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_NUM_OF_LANES}] ${MODELPARAM_VALUE.RX_NUM_OF_LANES}
}

proc update_MODELPARAM_VALUE.RX_OUT_DIV { MODELPARAM_VALUE.RX_OUT_DIV PARAM_VALUE.RX_OUT_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_OUT_DIV}] ${MODELPARAM_VALUE.RX_OUT_DIV}
}

proc update_MODELPARAM_VALUE.RX_CLK25_DIV { MODELPARAM_VALUE.RX_CLK25_DIV PARAM_VALUE.RX_CLK25_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_CLK25_DIV}] ${MODELPARAM_VALUE.RX_CLK25_DIV}
}

proc update_MODELPARAM_VALUE.RX_DFE_LPM_CFG { MODELPARAM_VALUE.RX_DFE_LPM_CFG PARAM_VALUE.RX_DFE_LPM_CFG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_DFE_LPM_CFG}] ${MODELPARAM_VALUE.RX_DFE_LPM_CFG}
}

proc update_MODELPARAM_VALUE.RX_PMA_CFG { MODELPARAM_VALUE.RX_PMA_CFG PARAM_VALUE.RX_PMA_CFG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_PMA_CFG}] ${MODELPARAM_VALUE.RX_PMA_CFG}
}

proc update_MODELPARAM_VALUE.RX_CDR_CFG { MODELPARAM_VALUE.RX_CDR_CFG PARAM_VALUE.RX_CDR_CFG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_CDR_CFG}] ${MODELPARAM_VALUE.RX_CDR_CFG}
}

