#!/bin/bash

###########################################################################
# Start the controller in open loop mode to determine the electrical offset
###########################################################################
# Configure the controller for open loop mode
echo "Initializing the FOC controller..."
sudo ./uio /dev/uio0 w 256 3     # ctrl mode: open loop=3, closed loop=2, standby=1
sudo ./uio /dev/uio0 w 288 0     # encoder offset sfix18.14
sudo ./uio /dev/uio0 w 260 25000 # command sfix18.8
sudo ./uio /dev/uio0 w 280 0     # open loop bias sfix18.14
sudo ./uio /dev/uio0 w 284 1311  # open loop scalar sfix18.16

# Notify the user to enable the motor
echo "FOC controller initialized. Select Run in IIO Scope and hit Enter to continue."
#read var

# Calibrate the encoder offset
echo "Calibrating the encoder offset..."
sleep 2s
OFFSET=$(sudo ./uio /dev/uio0 r 292) # read the encoder offset
#echo $OFFSET
OFFSET_VAL=$(echo $OFFSET | awk -F' ' '{print $4}')
#echo $OFFSET_VAL
OFFSET_DEC=$(printf "%d" $OFFSET_VAL)
#echo $OFFSET_DEC
OFFSET_DEC=$((OFFSET_DEC/4))
#echo $OFFSET_DEC
sudo ./uio /dev/uio0 w 288 $OFFSET_DEC # encoder offset sfix18.14

###########################################################################
# Set the controller to close loop mode
###########################################################################
# Set the parameters of the PI velocity and current controllers
echo "Initializing the closed loop FOC mode..."
sudo ./uio /dev/uio0 w 264 1000   # velocity p gain sfix18.16
sudo ./uio /dev/uio0 w 268 250    # velocity i gain sfix18.15
sudo ./uio /dev/uio0 w 272 1000   # current p gain sfix18.10
sudo ./uio /dev/uio0 w 276 150    # current i gain sfix18.2
# Set the reference speed
sudo ./uio /dev/uio0 w 260 40000  # command sfix18.8
# Configure the controller for closed loop mode
echo "Running in FOC closed loop mode"
sudo ./uio /dev/uio0 w 256 2       # ctrl mode: open loop=3, closed loop=2, standby=1

