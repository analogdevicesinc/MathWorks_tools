/*
 * File: LatLongCalcSingle_ADI.c
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 10-Aug-2015 17:40:17
 */

/* Include Files */
#include <math.h>
#include "DecodeBits_ADI.h"
#include "LatLongCalcSingle_ADI.h"
#include "mrdivide.h"

/* Variable Definitions */
static double NL[58];
static boolean_T NL_not_empty;
static double latzones[59];
static double latOffset0;
static double latOffset1;

/* Function Definitions */

/*
 * Calculate latitude, longitude and altitude from message bits
 *  Copyright 2010, The MathWorks, Inc.
 * Arguments    : const boolean_T msg[112]
 *                double inputLat
 *                double inputLong
 *                double *Rlat
 *                double *Rlon
 *                double *alt
 * Return Type  : void
 */
void LatLongCalcSingle_ADI(const boolean_T msg[112], double inputLat, double
  inputLong, double *Rlat, double *Rlon, double *alt)
{
  int i1;
  signed char b_msg[11];
  double d6;
  static const short b[11] = { 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 };

  int c_msg;
  static const int b_b[17] = { 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512,
    256, 128, 64, 32, 16, 8, 4, 2, 1 };

  double d7;
  int idx;
  signed char ii_data[1];
  signed char ii_size[2];
  int ii;
  boolean_T exitg1;
  double NL0_data[1];
  double Dlon0;
  double b_NL0_data[1];
  double Dlon1;
  double longOffset1;
  if (!NL_not_empty) {
    latOffset0 = inputLat / 6.0;
    latOffset0 = floor(latOffset0);
    latOffset1 = inputLat / 6.101694915254237;
    latOffset1 = floor(latOffset1);
    NL_not_empty = true;
    for (i1 = 0; i1 < 58; i1++) {
      latzones[i1] = 57.295779513082323 * acos(sqrt(0.00547810463172671 / (1.0 -
        cos(6.2831853071795862 / NL[i1]))));
    }

    latzones[58] = 0.0;
  }

  /*  Altitude calculation */
  for (i1 = 0; i1 < 7; i1++) {
    b_msg[i1] = (signed char)msg[40 + i1];
  }

  for (i1 = 0; i1 < 4; i1++) {
    b_msg[i1 + 7] = (signed char)msg[48 + i1];
  }

  d6 = 0.0;
  for (i1 = 0; i1 < 11; i1++) {
    d6 += (double)(b_msg[i1] * b[i1]);
  }

  if (!msg[47]) {
    c_msg = 100;
  } else {
    c_msg = 25;
  }

  *alt = d6 * (double)c_msg;
  d6 = 0.0;
  for (i1 = 0; i1 < 17; i1++) {
    d6 += (double)msg[54 + i1] * (double)b_b[i1];
  }

  d7 = 0.0;
  for (i1 = 0; i1 < 17; i1++) {
    d7 += (double)msg[71 + i1] * (double)b_b[i1];
  }

  /*  Technically you need both even and odd messages to calculate lat/long */
  /*  unambiguously. For this code, use a single message and then check to see */
  /*  if the lat/long values are reasonable. If not, change the lat/long base */
  /*  factors (LL.a1, LL.a2, etc.) and recompute. */
  /*  Latitude calculation */
  if (!msg[53]) {
    *Rlat = 6.0 * (latOffset0 + d6 / 131072.0);
  } else {
    *Rlat = 6.101694915254237 * (latOffset1 + d6 / 131072.0);
  }

  /*  Compare latitude to known location. If it's off by more than two degrees, */
  /*  use new base factors. */
  if (*Rlat > inputLat + 2.0) {
    *Rlat = 6.101694915254237 * ((latOffset1 - 1.0) + d6 / 131072.0);
  } else {
    if (*Rlat < inputLat - 2.0) {
      *Rlat = 6.101694915254237 * ((latOffset1 + 1.0) + d6 / 131072.0);
    }
  }

  /*  Based on latitude, calculate longitude */
  idx = 0;
  for (i1 = 0; i1 < 2; i1++) {
    ii_size[i1] = 1;
  }

  ii = 1;
  exitg1 = false;
  while ((!exitg1) && (ii < 60)) {
    if (latzones[ii - 1] < *Rlat) {
      idx = 1;
      ii_data[0] = (signed char)ii;
      exitg1 = true;
    } else {
      ii++;
    }
  }

  if (idx == 0) {
    ii_size[1] = 0;
  }

  ii = ii_size[1];
  i1 = 0;
  while (i1 <= ii - 1) {
    NL0_data[0] = ii_data[0];
    i1 = 1;
  }

  Dlon0 = mrdivide(NL0_data);
  ii = ii_size[1];
  i1 = 0;
  while (i1 <= ii - 1) {
    b_NL0_data[0] = NL0_data[0] - 1.0;
    i1 = 1;
  }

  Dlon1 = mrdivide(b_NL0_data);
  longOffset1 = floor(inputLong / Dlon1);
  if (!msg[53]) {
    *Rlon = Dlon0 * (floor(inputLong / Dlon0) + d7 / 131072.0);
  } else {
    *Rlon = Dlon1 * (longOffset1 + d7 / 131072.0);
  }

  /*  Compare longitude to known location. If it's off by more than two  */
  /*  degrees, use new base factors. */
  if (*Rlon > inputLong + 2.0) {
    *Rlon = Dlon1 * ((longOffset1 - 1.0) + d7 / 131072.0);
  } else {
    if (*Rlon < inputLong - 2.0) {
      *Rlon = Dlon1 * ((longOffset1 + 1.0) + d7 / 131072.0);
    }
  }

  /*  disp(sprintf('Plane is at altitude %d\nLatitude value: %d\nLongitude value: %d', alt, la1, lo1)); */
  /*  GoogleMap(aircraftID, alt1, Rlat, Rlon) */
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void LatLongCalcSingle_ADI_init(void)
{
  int i2;
  for (i2 = 0; i2 < 58; i2++) {
    NL[i2] = 2.0 + (double)i2;
  }
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void NL_not_empty_init(void)
{
  NL_not_empty = false;
}

/*
 * File trailer for LatLongCalcSingle_ADI.c
 *
 * [EOF]
 */
