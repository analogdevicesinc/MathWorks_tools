#!/bin/sh

find_zynq_base_gpio () {
	for i in /sys/class/gpio/gpiochip*; do
		if [ "zynq_gpio" = `cat $i/label` ]; then
			return `echo $i | sed 's/^[^0-9]\+//'`
			break
		fi
	done
	return -1
}

if [ `id -u` != "0" ]
then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#if [ `iio_attr -q  -D ad9361-phy adi,mgc-rx1-ctrl-inp-enable` = "0" ];then
#	#Enable Pin Control Mode
#	iio_attr -D ad9361-phy adi,mgc-rx1-ctrl-inp-enable 1 > export 2> /dev/null
#	iio_attr -D ad9361-phy adi,mgc-rx2-ctrl-inp-enable 1 > export 2> /dev/null
#	iio_attr -D ad9361-phy initialize 1 > export 2> /dev/null
#
#	sleep 1
#fi


find_zynq_base_gpio
GPIO_BASE=$?
cd /sys/class/gpio

if [ $GPIO_BASE -ge 0 ]
then
  #GPIO_CTRL_IN0=`expr $GPIO_BASE + 94`
  #GPIO_CTRL_IN1=`expr $GPIO_BASE + 95`
  #GPIO_CTRL_IN2=`expr $GPIO_BASE + 96`
  #GPIO_CTRL_IN3=`expr $GPIO_BASE + 97`
  GPIO_EN_AGC=`expr $GPIO_BASE + 98`
  #Export the CTRL_IN GPIOs
  #echo $GPIO_CTRL_IN0 > export 2> /dev/null
  #echo $GPIO_CTRL_IN1 > export 2> /dev/null
  #echo $GPIO_CTRL_IN2 > export 2> /dev/null
  #echo $GPIO_CTRL_IN3 > export 2> /dev/null
  echo $GPIO_EN_AGC > export 2> /dev/null
else
  echo ERROR: Wrong board?
  exit
fi

# Enable settings
iio_reg ad9361-phy 0xFB 0x48
#iio_reg ad9361-phy 0x14 0x2B
iio_reg ad9361-phy 0x14 0x29

iio_reg ad9361-phy 0x110 0xA
iio_reg ad9361-phy 0x115 0x80


#CTRL_IN0=gpio${GPIO_CTRL_IN0}/direction
#CTRL_IN1=gpio${GPIO_CTRL_IN1}/direction
#CTRL_IN2=gpio${GPIO_CTRL_IN2}/direction
#CTRL_IN3=gpio${GPIO_CTRL_IN3}/direction
EN_AGC=gpio${GPIO_EN_AGC}/direction

if [ "$1" = "1" ];then
	echo low > $EN_AGC

elif [ "$1" = "2" ];then
	echo high > $EN_AGC

elif [ "$1" = "0" ];then
	exit
else
	echo "usage: $0 <1(Disable AGC when locked)|2(Allow AGC Evolution)>"
	exit
fi
