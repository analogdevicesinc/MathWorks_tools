# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLK0_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLK0_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLK1_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLK1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLK2_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLK2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKIN2_PERIOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKIN_PERIOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEVICE_TYPE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VCO_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VCO_MUL" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLK0_DIV { PARAM_VALUE.CLK0_DIV } {
	# Procedure called to update CLK0_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK0_DIV { PARAM_VALUE.CLK0_DIV } {
	# Procedure called to validate CLK0_DIV
	return true
}

proc update_PARAM_VALUE.CLK0_PHASE { PARAM_VALUE.CLK0_PHASE } {
	# Procedure called to update CLK0_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK0_PHASE { PARAM_VALUE.CLK0_PHASE } {
	# Procedure called to validate CLK0_PHASE
	return true
}

proc update_PARAM_VALUE.CLK1_DIV { PARAM_VALUE.CLK1_DIV } {
	# Procedure called to update CLK1_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK1_DIV { PARAM_VALUE.CLK1_DIV } {
	# Procedure called to validate CLK1_DIV
	return true
}

proc update_PARAM_VALUE.CLK1_PHASE { PARAM_VALUE.CLK1_PHASE } {
	# Procedure called to update CLK1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK1_PHASE { PARAM_VALUE.CLK1_PHASE } {
	# Procedure called to validate CLK1_PHASE
	return true
}

proc update_PARAM_VALUE.CLK2_DIV { PARAM_VALUE.CLK2_DIV } {
	# Procedure called to update CLK2_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK2_DIV { PARAM_VALUE.CLK2_DIV } {
	# Procedure called to validate CLK2_DIV
	return true
}

proc update_PARAM_VALUE.CLK2_PHASE { PARAM_VALUE.CLK2_PHASE } {
	# Procedure called to update CLK2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK2_PHASE { PARAM_VALUE.CLK2_PHASE } {
	# Procedure called to validate CLK2_PHASE
	return true
}

proc update_PARAM_VALUE.CLKIN2_PERIOD { PARAM_VALUE.CLKIN2_PERIOD } {
	# Procedure called to update CLKIN2_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKIN2_PERIOD { PARAM_VALUE.CLKIN2_PERIOD } {
	# Procedure called to validate CLKIN2_PERIOD
	return true
}

proc update_PARAM_VALUE.CLKIN_PERIOD { PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to update CLKIN_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKIN_PERIOD { PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to validate CLKIN_PERIOD
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

proc update_PARAM_VALUE.VCO_DIV { PARAM_VALUE.VCO_DIV } {
	# Procedure called to update VCO_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VCO_DIV { PARAM_VALUE.VCO_DIV } {
	# Procedure called to validate VCO_DIV
	return true
}

proc update_PARAM_VALUE.VCO_MUL { PARAM_VALUE.VCO_MUL } {
	# Procedure called to update VCO_MUL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VCO_MUL { PARAM_VALUE.VCO_MUL } {
	# Procedure called to validate VCO_MUL
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

proc update_MODELPARAM_VALUE.CLKIN_PERIOD { MODELPARAM_VALUE.CLKIN_PERIOD PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKIN_PERIOD}] ${MODELPARAM_VALUE.CLKIN_PERIOD}
}

proc update_MODELPARAM_VALUE.CLKIN2_PERIOD { MODELPARAM_VALUE.CLKIN2_PERIOD PARAM_VALUE.CLKIN2_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKIN2_PERIOD}] ${MODELPARAM_VALUE.CLKIN2_PERIOD}
}

proc update_MODELPARAM_VALUE.VCO_DIV { MODELPARAM_VALUE.VCO_DIV PARAM_VALUE.VCO_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VCO_DIV}] ${MODELPARAM_VALUE.VCO_DIV}
}

proc update_MODELPARAM_VALUE.VCO_MUL { MODELPARAM_VALUE.VCO_MUL PARAM_VALUE.VCO_MUL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VCO_MUL}] ${MODELPARAM_VALUE.VCO_MUL}
}

proc update_MODELPARAM_VALUE.CLK0_DIV { MODELPARAM_VALUE.CLK0_DIV PARAM_VALUE.CLK0_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK0_DIV}] ${MODELPARAM_VALUE.CLK0_DIV}
}

proc update_MODELPARAM_VALUE.CLK0_PHASE { MODELPARAM_VALUE.CLK0_PHASE PARAM_VALUE.CLK0_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK0_PHASE}] ${MODELPARAM_VALUE.CLK0_PHASE}
}

proc update_MODELPARAM_VALUE.CLK1_DIV { MODELPARAM_VALUE.CLK1_DIV PARAM_VALUE.CLK1_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK1_DIV}] ${MODELPARAM_VALUE.CLK1_DIV}
}

proc update_MODELPARAM_VALUE.CLK1_PHASE { MODELPARAM_VALUE.CLK1_PHASE PARAM_VALUE.CLK1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK1_PHASE}] ${MODELPARAM_VALUE.CLK1_PHASE}
}

proc update_MODELPARAM_VALUE.CLK2_DIV { MODELPARAM_VALUE.CLK2_DIV PARAM_VALUE.CLK2_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK2_DIV}] ${MODELPARAM_VALUE.CLK2_DIV}
}

proc update_MODELPARAM_VALUE.CLK2_PHASE { MODELPARAM_VALUE.CLK2_PHASE PARAM_VALUE.CLK2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK2_PHASE}] ${MODELPARAM_VALUE.CLK2_PHASE}
}

