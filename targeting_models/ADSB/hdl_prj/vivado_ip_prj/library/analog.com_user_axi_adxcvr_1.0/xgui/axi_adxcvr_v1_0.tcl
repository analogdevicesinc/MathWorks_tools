# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "GTH_OR_GTX_N" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LPM_OR_DFE_N" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_OF_LANES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT_CLK_SEL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QPLL_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SYS_CLK_SEL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_OR_RX_N" -parent ${Page_0}


}

proc update_PARAM_VALUE.GTH_OR_GTX_N { PARAM_VALUE.GTH_OR_GTX_N } {
	# Procedure called to update GTH_OR_GTX_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GTH_OR_GTX_N { PARAM_VALUE.GTH_OR_GTX_N } {
	# Procedure called to validate GTH_OR_GTX_N
	return true
}

proc update_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to update ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to validate ID
	return true
}

proc update_PARAM_VALUE.LPM_OR_DFE_N { PARAM_VALUE.LPM_OR_DFE_N } {
	# Procedure called to update LPM_OR_DFE_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LPM_OR_DFE_N { PARAM_VALUE.LPM_OR_DFE_N } {
	# Procedure called to validate LPM_OR_DFE_N
	return true
}

proc update_PARAM_VALUE.NUM_OF_LANES { PARAM_VALUE.NUM_OF_LANES } {
	# Procedure called to update NUM_OF_LANES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_LANES { PARAM_VALUE.NUM_OF_LANES } {
	# Procedure called to validate NUM_OF_LANES
	return true
}

proc update_PARAM_VALUE.OUT_CLK_SEL { PARAM_VALUE.OUT_CLK_SEL } {
	# Procedure called to update OUT_CLK_SEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_CLK_SEL { PARAM_VALUE.OUT_CLK_SEL } {
	# Procedure called to validate OUT_CLK_SEL
	return true
}

proc update_PARAM_VALUE.QPLL_ENABLE { PARAM_VALUE.QPLL_ENABLE } {
	# Procedure called to update QPLL_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QPLL_ENABLE { PARAM_VALUE.QPLL_ENABLE } {
	# Procedure called to validate QPLL_ENABLE
	return true
}

proc update_PARAM_VALUE.RATE { PARAM_VALUE.RATE } {
	# Procedure called to update RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RATE { PARAM_VALUE.RATE } {
	# Procedure called to validate RATE
	return true
}

proc update_PARAM_VALUE.SYS_CLK_SEL { PARAM_VALUE.SYS_CLK_SEL } {
	# Procedure called to update SYS_CLK_SEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SYS_CLK_SEL { PARAM_VALUE.SYS_CLK_SEL } {
	# Procedure called to validate SYS_CLK_SEL
	return true
}

proc update_PARAM_VALUE.TX_OR_RX_N { PARAM_VALUE.TX_OR_RX_N } {
	# Procedure called to update TX_OR_RX_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_OR_RX_N { PARAM_VALUE.TX_OR_RX_N } {
	# Procedure called to validate TX_OR_RX_N
	return true
}


proc update_MODELPARAM_VALUE.ID { MODELPARAM_VALUE.ID PARAM_VALUE.ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID}] ${MODELPARAM_VALUE.ID}
}

proc update_MODELPARAM_VALUE.NUM_OF_LANES { MODELPARAM_VALUE.NUM_OF_LANES PARAM_VALUE.NUM_OF_LANES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_LANES}] ${MODELPARAM_VALUE.NUM_OF_LANES}
}

proc update_MODELPARAM_VALUE.GTH_OR_GTX_N { MODELPARAM_VALUE.GTH_OR_GTX_N PARAM_VALUE.GTH_OR_GTX_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GTH_OR_GTX_N}] ${MODELPARAM_VALUE.GTH_OR_GTX_N}
}

proc update_MODELPARAM_VALUE.TX_OR_RX_N { MODELPARAM_VALUE.TX_OR_RX_N PARAM_VALUE.TX_OR_RX_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_OR_RX_N}] ${MODELPARAM_VALUE.TX_OR_RX_N}
}

proc update_MODELPARAM_VALUE.QPLL_ENABLE { MODELPARAM_VALUE.QPLL_ENABLE PARAM_VALUE.QPLL_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QPLL_ENABLE}] ${MODELPARAM_VALUE.QPLL_ENABLE}
}

proc update_MODELPARAM_VALUE.LPM_OR_DFE_N { MODELPARAM_VALUE.LPM_OR_DFE_N PARAM_VALUE.LPM_OR_DFE_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LPM_OR_DFE_N}] ${MODELPARAM_VALUE.LPM_OR_DFE_N}
}

proc update_MODELPARAM_VALUE.RATE { MODELPARAM_VALUE.RATE PARAM_VALUE.RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RATE}] ${MODELPARAM_VALUE.RATE}
}

proc update_MODELPARAM_VALUE.SYS_CLK_SEL { MODELPARAM_VALUE.SYS_CLK_SEL PARAM_VALUE.SYS_CLK_SEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SYS_CLK_SEL}] ${MODELPARAM_VALUE.SYS_CLK_SEL}
}

proc update_MODELPARAM_VALUE.OUT_CLK_SEL { MODELPARAM_VALUE.OUT_CLK_SEL PARAM_VALUE.OUT_CLK_SEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_CLK_SEL}] ${MODELPARAM_VALUE.OUT_CLK_SEL}
}

