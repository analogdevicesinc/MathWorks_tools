/*
 * File: DecodeBits_ADI.c
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 10-Aug-2015 17:40:17
 */

/* Include Files */
#include "DecodeBits_ADI.h"
#include "LatLongCalcSingle_ADI.h"

/* Function Definitions */

/*
 * Read message bits and decode valid messages for position, velocity and
 *  altitude data
 * Arguments    : const boolean_T bits[112]
 *                double currentLat
 *                double currentLong
 *                double *nV
 *                double *eV
 *                double *aV
 *                double *alt
 *                double *lat
 *                double *b_long
 *                char *type
 *                double id[6]
 * Return Type  : void
 */
void DecodeBits_ADI(const boolean_T bits[112], double currentLat, double
                    currentLong, double *nV, double *eV, double *aV, double *alt,
                    double *lat, double *b_long, char *type, double id[6])
{
  double d0;
  double d1;
  double d2;
  double d3;
  double d4;
  double d5;
  int i0;
  static const signed char b[4] = { 8, 4, 2, 1 };

  static const short b_b[10] = { 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 };

  int b_bits;
  int c_bits;
  static const short c_b[9] = { 256, 128, 64, 32, 16, 8, 4, 2, 1 };

  int d_bits;

  /*  Initialize data */
  *nV = 0.0;
  *eV = 0.0;
  *aV = 0.0;
  *alt = 0.0;
  *lat = 0.0;
  *b_long = 0.0;
  *type = 'X';
  d0 = 0.0;
  d1 = 0.0;
  d2 = 0.0;
  d3 = 0.0;
  d4 = 0.0;
  d5 = 0.0;
  for (i0 = 0; i0 < 4; i0++) {
    d0 += (double)bits[8 + i0] * (double)b[i0];
    d1 += (double)bits[12 + i0] * (double)b[i0];
    d2 += (double)bits[16 + i0] * (double)b[i0];
    d3 += (double)bits[20 + i0] * (double)b[i0];
    d4 += (double)bits[24 + i0] * (double)b[i0];
    d5 += (double)bits[28 + i0] * (double)b[i0];
  }

  id[0] = d0;
  id[1] = d1;
  id[2] = d2;
  id[3] = d3;
  id[4] = d4;
  id[5] = d5;

  /*  Check 9th and 10th hex characters for mesasge type */
  d0 = 0.0;
  for (i0 = 0; i0 < 4; i0++) {
    d0 += (double)bits[32 + i0] * (double)b[i0];
  }

  d1 = 0.0;
  for (i0 = 0; i0 < 4; i0++) {
    d1 += (double)bits[36 + i0] * (double)b[i0];
  }

  if ((d0 == 9.0) && (d1 == 9.0)) {
    /*  Calculate velocity data from message bits */
    /*  Copyright 2010-2011, The MathWorks, Inc. */
    /*  Calculate East-West velocity */
    /*  Calculate North-South velocity */
    /*  Calculate rate of climb/descent */
    d0 = 0.0;
    for (i0 = 0; i0 < 10; i0++) {
      d0 += (double)bits[57 + i0] * (double)b_b[i0];
    }

    if (!bits[56]) {
      b_bits = 1;
    } else {
      b_bits = -1;
    }

    *nV = (double)b_bits * (d0 - 1.0);
    d0 = 0.0;
    for (i0 = 0; i0 < 10; i0++) {
      d0 += (double)bits[46 + i0] * (double)b_b[i0];
    }

    if (!bits[45]) {
      c_bits = 1;
    } else {
      c_bits = -1;
    }

    *eV = (double)c_bits * (d0 - 1.0);
    d0 = 0.0;
    for (i0 = 0; i0 < 9; i0++) {
      d0 += (double)bits[69 + i0] * (double)c_b[i0];
    }

    if (!bits[68]) {
      d_bits = 1;
    } else {
      d_bits = -1;
    }

    *aV = (double)d_bits * ((d0 - 1.0) * 64.0);
    *type = 'A';
  } else if ((d0 == 5.0) || (d0 == 6.0)) {
    LatLongCalcSingle_ADI(bits, currentLat, currentLong, lat, b_long, alt);
    *type = 'L';
  } else {
    if ((d0 == 9.0) && (d1 == 0.0)) {
      LatLongCalcSingle_ADI(bits, currentLat, currentLong, lat, b_long, alt);
      *type = 'L';
    }
  }
}

/*
 * File trailer for DecodeBits_ADI.c
 *
 * [EOF]
 */
