# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DAC_DATAPATH_DISABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEVICE_TYPE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IO_DELAY_GROUP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_CLK0_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_CLK1_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_CLKIN_PERIOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_OR_BUFIO_N" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_VCO_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_VCO_MUL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SERDES_OR_DDR_N" -parent ${Page_0}


}

proc update_PARAM_VALUE.DAC_DATAPATH_DISABLE { PARAM_VALUE.DAC_DATAPATH_DISABLE } {
	# Procedure called to update DAC_DATAPATH_DISABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DAC_DATAPATH_DISABLE { PARAM_VALUE.DAC_DATAPATH_DISABLE } {
	# Procedure called to validate DAC_DATAPATH_DISABLE
	return true
}

proc update_PARAM_VALUE.DEVICE_TYPE { PARAM_VALUE.DEVICE_TYPE } {
	# Procedure called to update DEVICE_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEVICE_TYPE { PARAM_VALUE.DEVICE_TYPE } {
	# Procedure called to validate DEVICE_TYPE
	return true
}

proc update_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to update ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to validate ID
	return true
}

proc update_PARAM_VALUE.IO_DELAY_GROUP { PARAM_VALUE.IO_DELAY_GROUP } {
	# Procedure called to update IO_DELAY_GROUP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IO_DELAY_GROUP { PARAM_VALUE.IO_DELAY_GROUP } {
	# Procedure called to validate IO_DELAY_GROUP
	return true
}

proc update_PARAM_VALUE.MMCM_CLK0_DIV { PARAM_VALUE.MMCM_CLK0_DIV } {
	# Procedure called to update MMCM_CLK0_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_CLK0_DIV { PARAM_VALUE.MMCM_CLK0_DIV } {
	# Procedure called to validate MMCM_CLK0_DIV
	return true
}

proc update_PARAM_VALUE.MMCM_CLK1_DIV { PARAM_VALUE.MMCM_CLK1_DIV } {
	# Procedure called to update MMCM_CLK1_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_CLK1_DIV { PARAM_VALUE.MMCM_CLK1_DIV } {
	# Procedure called to validate MMCM_CLK1_DIV
	return true
}

proc update_PARAM_VALUE.MMCM_CLKIN_PERIOD { PARAM_VALUE.MMCM_CLKIN_PERIOD } {
	# Procedure called to update MMCM_CLKIN_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_CLKIN_PERIOD { PARAM_VALUE.MMCM_CLKIN_PERIOD } {
	# Procedure called to validate MMCM_CLKIN_PERIOD
	return true
}

proc update_PARAM_VALUE.MMCM_OR_BUFIO_N { PARAM_VALUE.MMCM_OR_BUFIO_N } {
	# Procedure called to update MMCM_OR_BUFIO_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_OR_BUFIO_N { PARAM_VALUE.MMCM_OR_BUFIO_N } {
	# Procedure called to validate MMCM_OR_BUFIO_N
	return true
}

proc update_PARAM_VALUE.MMCM_VCO_DIV { PARAM_VALUE.MMCM_VCO_DIV } {
	# Procedure called to update MMCM_VCO_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_VCO_DIV { PARAM_VALUE.MMCM_VCO_DIV } {
	# Procedure called to validate MMCM_VCO_DIV
	return true
}

proc update_PARAM_VALUE.MMCM_VCO_MUL { PARAM_VALUE.MMCM_VCO_MUL } {
	# Procedure called to update MMCM_VCO_MUL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_VCO_MUL { PARAM_VALUE.MMCM_VCO_MUL } {
	# Procedure called to validate MMCM_VCO_MUL
	return true
}

proc update_PARAM_VALUE.SERDES_OR_DDR_N { PARAM_VALUE.SERDES_OR_DDR_N } {
	# Procedure called to update SERDES_OR_DDR_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SERDES_OR_DDR_N { PARAM_VALUE.SERDES_OR_DDR_N } {
	# Procedure called to validate SERDES_OR_DDR_N
	return true
}


proc update_MODELPARAM_VALUE.ID { MODELPARAM_VALUE.ID PARAM_VALUE.ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID}] ${MODELPARAM_VALUE.ID}
}

proc update_MODELPARAM_VALUE.DEVICE_TYPE { MODELPARAM_VALUE.DEVICE_TYPE PARAM_VALUE.DEVICE_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEVICE_TYPE}] ${MODELPARAM_VALUE.DEVICE_TYPE}
}

proc update_MODELPARAM_VALUE.SERDES_OR_DDR_N { MODELPARAM_VALUE.SERDES_OR_DDR_N PARAM_VALUE.SERDES_OR_DDR_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SERDES_OR_DDR_N}] ${MODELPARAM_VALUE.SERDES_OR_DDR_N}
}

proc update_MODELPARAM_VALUE.MMCM_OR_BUFIO_N { MODELPARAM_VALUE.MMCM_OR_BUFIO_N PARAM_VALUE.MMCM_OR_BUFIO_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_OR_BUFIO_N}] ${MODELPARAM_VALUE.MMCM_OR_BUFIO_N}
}

proc update_MODELPARAM_VALUE.MMCM_CLKIN_PERIOD { MODELPARAM_VALUE.MMCM_CLKIN_PERIOD PARAM_VALUE.MMCM_CLKIN_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_CLKIN_PERIOD}] ${MODELPARAM_VALUE.MMCM_CLKIN_PERIOD}
}

proc update_MODELPARAM_VALUE.MMCM_VCO_DIV { MODELPARAM_VALUE.MMCM_VCO_DIV PARAM_VALUE.MMCM_VCO_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_VCO_DIV}] ${MODELPARAM_VALUE.MMCM_VCO_DIV}
}

proc update_MODELPARAM_VALUE.MMCM_VCO_MUL { MODELPARAM_VALUE.MMCM_VCO_MUL PARAM_VALUE.MMCM_VCO_MUL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_VCO_MUL}] ${MODELPARAM_VALUE.MMCM_VCO_MUL}
}

proc update_MODELPARAM_VALUE.MMCM_CLK0_DIV { MODELPARAM_VALUE.MMCM_CLK0_DIV PARAM_VALUE.MMCM_CLK0_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_CLK0_DIV}] ${MODELPARAM_VALUE.MMCM_CLK0_DIV}
}

proc update_MODELPARAM_VALUE.MMCM_CLK1_DIV { MODELPARAM_VALUE.MMCM_CLK1_DIV PARAM_VALUE.MMCM_CLK1_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_CLK1_DIV}] ${MODELPARAM_VALUE.MMCM_CLK1_DIV}
}

proc update_MODELPARAM_VALUE.DAC_DATAPATH_DISABLE { MODELPARAM_VALUE.DAC_DATAPATH_DISABLE PARAM_VALUE.DAC_DATAPATH_DISABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DAC_DATAPATH_DISABLE}] ${MODELPARAM_VALUE.DAC_DATAPATH_DISABLE}
}

proc update_MODELPARAM_VALUE.IO_DELAY_GROUP { MODELPARAM_VALUE.IO_DELAY_GROUP PARAM_VALUE.IO_DELAY_GROUP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IO_DELAY_GROUP}] ${MODELPARAM_VALUE.IO_DELAY_GROUP}
}

