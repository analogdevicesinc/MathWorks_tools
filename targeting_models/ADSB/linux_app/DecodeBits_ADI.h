/*
 * File: DecodeBits_ADI.h
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 10-Aug-2015 17:40:17
 */

#ifndef __DECODEBITS_ADI_H__
#define __DECODEBITS_ADI_H__

/* Include Files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "DecodeBits_ADI_types.h"

/* Function Declarations */
extern void DecodeBits_ADI(const boolean_T bits[112], double currentLat, double
  currentLong, double *nV, double *eV, double *aV, double *alt, double *lat,
  double *b_long, char *type, double id[6]);

#endif

/*
 * File trailer for DecodeBits_ADI.h
 *
 * [EOF]
 */
