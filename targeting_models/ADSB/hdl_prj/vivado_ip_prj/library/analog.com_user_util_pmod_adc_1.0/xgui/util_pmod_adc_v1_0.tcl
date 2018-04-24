# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADC_CLK_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADC_CONVERT_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADC_CONVST_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADC_RESET_LENGTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADC_TQUIET_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FPGA_CLOCK_MHZ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_WORD_LENGTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADC_CLK_DIVIDE { PARAM_VALUE.ADC_CLK_DIVIDE } {
	# Procedure called to update ADC_CLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_CLK_DIVIDE { PARAM_VALUE.ADC_CLK_DIVIDE } {
	# Procedure called to validate ADC_CLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.ADC_CONVERT_NS { PARAM_VALUE.ADC_CONVERT_NS } {
	# Procedure called to update ADC_CONVERT_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_CONVERT_NS { PARAM_VALUE.ADC_CONVERT_NS } {
	# Procedure called to validate ADC_CONVERT_NS
	return true
}

proc update_PARAM_VALUE.ADC_CONVST_NS { PARAM_VALUE.ADC_CONVST_NS } {
	# Procedure called to update ADC_CONVST_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_CONVST_NS { PARAM_VALUE.ADC_CONVST_NS } {
	# Procedure called to validate ADC_CONVST_NS
	return true
}

proc update_PARAM_VALUE.ADC_RESET_LENGTH { PARAM_VALUE.ADC_RESET_LENGTH } {
	# Procedure called to update ADC_RESET_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_RESET_LENGTH { PARAM_VALUE.ADC_RESET_LENGTH } {
	# Procedure called to validate ADC_RESET_LENGTH
	return true
}

proc update_PARAM_VALUE.ADC_TQUIET_NS { PARAM_VALUE.ADC_TQUIET_NS } {
	# Procedure called to update ADC_TQUIET_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_TQUIET_NS { PARAM_VALUE.ADC_TQUIET_NS } {
	# Procedure called to validate ADC_TQUIET_NS
	return true
}

proc update_PARAM_VALUE.FPGA_CLOCK_MHZ { PARAM_VALUE.FPGA_CLOCK_MHZ } {
	# Procedure called to update FPGA_CLOCK_MHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_CLOCK_MHZ { PARAM_VALUE.FPGA_CLOCK_MHZ } {
	# Procedure called to validate FPGA_CLOCK_MHZ
	return true
}

proc update_PARAM_VALUE.SPI_WORD_LENGTH { PARAM_VALUE.SPI_WORD_LENGTH } {
	# Procedure called to update SPI_WORD_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_WORD_LENGTH { PARAM_VALUE.SPI_WORD_LENGTH } {
	# Procedure called to validate SPI_WORD_LENGTH
	return true
}


proc update_MODELPARAM_VALUE.FPGA_CLOCK_MHZ { MODELPARAM_VALUE.FPGA_CLOCK_MHZ PARAM_VALUE.FPGA_CLOCK_MHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_CLOCK_MHZ}] ${MODELPARAM_VALUE.FPGA_CLOCK_MHZ}
}

proc update_MODELPARAM_VALUE.ADC_CONVST_NS { MODELPARAM_VALUE.ADC_CONVST_NS PARAM_VALUE.ADC_CONVST_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_CONVST_NS}] ${MODELPARAM_VALUE.ADC_CONVST_NS}
}

proc update_MODELPARAM_VALUE.ADC_CONVERT_NS { MODELPARAM_VALUE.ADC_CONVERT_NS PARAM_VALUE.ADC_CONVERT_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_CONVERT_NS}] ${MODELPARAM_VALUE.ADC_CONVERT_NS}
}

proc update_MODELPARAM_VALUE.ADC_TQUIET_NS { MODELPARAM_VALUE.ADC_TQUIET_NS PARAM_VALUE.ADC_TQUIET_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_TQUIET_NS}] ${MODELPARAM_VALUE.ADC_TQUIET_NS}
}

proc update_MODELPARAM_VALUE.SPI_WORD_LENGTH { MODELPARAM_VALUE.SPI_WORD_LENGTH PARAM_VALUE.SPI_WORD_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_WORD_LENGTH}] ${MODELPARAM_VALUE.SPI_WORD_LENGTH}
}

proc update_MODELPARAM_VALUE.ADC_RESET_LENGTH { MODELPARAM_VALUE.ADC_RESET_LENGTH PARAM_VALUE.ADC_RESET_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_RESET_LENGTH}] ${MODELPARAM_VALUE.ADC_RESET_LENGTH}
}

proc update_MODELPARAM_VALUE.ADC_CLK_DIVIDE { MODELPARAM_VALUE.ADC_CLK_DIVIDE PARAM_VALUE.ADC_CLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_CLK_DIVIDE}] ${MODELPARAM_VALUE.ADC_CLK_DIVIDE}
}

