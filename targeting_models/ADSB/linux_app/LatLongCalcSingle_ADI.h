/*
 * File: LatLongCalcSingle_ADI.h
 *
 * MATLAB Coder version            : 2.8
 * C/C++ source code generated on  : 10-Aug-2015 17:40:17
 */

#ifndef __LATLONGCALCSINGLE_ADI_H__
#define __LATLONGCALCSINGLE_ADI_H__

/* Include Files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "DecodeBits_ADI_types.h"

/* Function Declarations */
extern void LatLongCalcSingle_ADI(const boolean_T msg[112], double inputLat,
  double inputLong, double *Rlat, double *Rlon, double *alt);
extern void LatLongCalcSingle_ADI_init(void);
extern void NL_not_empty_init(void);

#endif

/*
 * File trailer for LatLongCalcSingle_ADI.h
 *
 * [EOF]
 */
