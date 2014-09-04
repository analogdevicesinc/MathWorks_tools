#!/bin/bash

###########################################################################
# Util functions
###########################################################################
str_to_dec () {
	VAL_DEC=$(printf "%d" $4)
}

abs () {
	ABS_VAL=$1
	if [ $1 -ge 2147483648 ]; then
		ABS_VAL=$((ABS_VAL-4294967296))
	fi
	if [ $ABS_VAL -le 0 ];then
		ABS_VAL=$((ABS_VAL * -1))
	fi
}

###########################################################################
# Start the controller in open loop mode to determine the electrical offset
###########################################################################
echo "Initializing the FOC controller..."
sudo ./uio /dev/uio0 w 256 3     # ctrl mode: open loop=3, closed loop=2, standby=1
sudo ./uio /dev/uio0 w 288 0     # encoder offset sfix18.14
sudo ./uio /dev/uio0 w 260 25000 # command sfix18.8
sudo ./uio /dev/uio0 w 280 0     # open loop bias sfix18.14
sudo ./uio /dev/uio0 w 284 1311  # open loop scalar sfix18.16
echo "FOC controller initialized. Select Run in IIO Scope and hit Enter to continue."
read var

###########################################################################
# Calibrate the encoder offset
###########################################################################
echo "Calibrating the encoder offset..."
# Read the encoder error
OFFSET_ERR=$(sudo ./uio /dev/uio0 r 292) # read the encoder offset
str_to_dec $OFFSET_ERR
OFFSET_DEC=$((VAL_DEC/4))
echo 'OFFSET1'
echo $OFFSET_DEC

# Write the first estimated offset and read the encoder error
sudo ./uio /dev/uio0 w 288 -$OFFSET_DEC # encoder offset sfix18.14
sleep 0.1s
OFFSET_ERR=$(sudo ./uio /dev/uio0 r 292) # read the encoder offset
str_to_dec $OFFSET_ERR
abs $VAL_DEC
OFFSET_ERR1=$ABS_VAL
echo 'ERR1'
echo $OFFSET_ERR1

# Write the second estimated offset and read the encoder error
STEP=50
OFFSET_DEC=$((OFFSET_DEC + STEP))
echo 'OFFSET2'
echo $OFFSET_DEC
sudo ./uio /dev/uio0 w 288 -$OFFSET_DEC # encoder offset sfix18.14
sleep 0.1s
OFFSET_ERR=$(sudo ./uio /dev/uio0 r 292) # read the encoder offset
str_to_dec $OFFSET_ERR
abs $VAL_DEC
OFFSET_ERR2=$ABS_VAL
echo 'ERR2'
echo $OFFSET_ERR2

# Check if the offset changing step must reverse the sign 
if [ $OFFSET_ERR2 -ge $OFFSET_ERR1 ]; then
	echo 'CHANGING STEP'	
	STEP=-50
fi

# Adjust the encoder offset until the error to go below a specified value
OFFSET_ERR=$OFFSET_ERR2
echo $OFFSET_ERR
while [ $OFFSET_ERR -ge 100 ]
do
	OFFSET_DEC=$((OFFSET_DEC+STEP))
	sudo ./uio /dev/uio0 w 288 -$OFFSET_DEC # encoder offset sfix18.14
	sleep 0.1s
	OFFSET_ERR=$(sudo ./uio /dev/uio0 r 292) # read the encoder offset
	str_to_dec $OFFSET_ERR
	abs $VAL_DEC
	OFFSET_ERR=$ABS_VAL
done
sudo ./uio /dev/uio0 w 288 $OFFSET_DEC # encoder offset sfix18.14
echo 'OFFSET_DEC'	
echo $OFFSET_DEC
echo 'OFFSET_ERR'	
echo $OFFSET_ERR

###########################################################################
# Set the controller to close loop mode
###########################################################################
# Set the parameters of the PI velocity and current controllers
echo "Initializing the closed loop FOC mode..."
sudo ./uio /dev/uio0 w 264 1000  # velocity p gain sfix18.16
sudo ./uio /dev/uio0 w 268 200    # velocity i gain sfix18.15
sudo ./uio /dev/uio0 w 272 1500   # current p gain sfix18.10
sudo ./uio /dev/uio0 w 276 150    # current i gain sfix18.2
# Set the refence speed
sudo ./uio /dev/uio0 w 260 40000 # command sfix18.8
# Configure the controller for closed loop mode
echo "Running in FOC closed loop mode"
sudo ./uio /dev/uio0 w 256 3     # ctrl mode: open loop=3, closed loop=2, standby=1

