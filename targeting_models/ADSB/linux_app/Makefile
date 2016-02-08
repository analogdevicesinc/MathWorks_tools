# libiio - Library for interfacing industrial I/O (IIO) devices
#
# Copyright (C) 2014 Analog Devices, Inc.
# Author: Paul Cercueil <paul.cercueil@analog.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.


TARGETS := adsb_decode

CFLAGS = -Wall

.PHONY: all clean

all: $(TARGETS)

adsb_decode.o : adsb_decode.c
	$(CC) adsb_decode.c -c $(CFLAGS)

DecodeBits_ADI.o : DecodeBits_ADI.c DecodeBits_ADI.h
	$(CC) DecodeBits_ADI.c -c $(CFLAGS)

DecodeBits_ADI_initialize.o : DecodeBits_ADI_initialize.c DecodeBits_ADI_initialize.h
	$(CC) DecodeBits_ADI_initialize.c -c $(CFLAGS)

DecodeBits_ADI_terminate.o : DecodeBits_ADI_terminate.c DecodeBits_ADI_terminate.h
	$(CC) DecodeBits_ADI_terminate.c -c $(CFLAGS)

LatLongCalcSingle_ADI.o : LatLongCalcSingle_ADI.c LatLongCalcSingle_ADI.h
	$(CC) LatLongCalcSingle_ADI.c -c $(CFLAGS)

mrdivide.o : mrdivide.c mrdivide.h
	$(CC) mrdivide.c -c $(CFLAGS)

adsb_decode : adsb_decode.o DecodeBits_ADI.o DecodeBits_ADI_initialize.o DecodeBits_ADI_terminate.o LatLongCalcSingle_ADI.o mrdivide.o
	$(CC) -o $@ $^ $(LDFLAGS) -liio -lm
clean:
	rm -f $(TARGETS) *.o
