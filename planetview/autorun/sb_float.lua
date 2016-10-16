/***
*float.h - constants for floating point values
*
*       Copyright (c) Microsoft Corporation. All rights reserved.
*
*Purpose:
*       This file contains defines for a number of implementation dependent
*       values which are commonly used by sophisticated numerical (floating
*       point) programs.
*       [ANSI]
*
*       [Public]
*
****/

DBL_DIG         = 15                      /* # of decimal digits of precision */
DBL_EPSILON     = 2.2204460492503131e-016 /* smallest such that 1.0+DBL_EPSILON != 1.0 */
DBL_MANT_DIG    = 53                      /* # of bits in mantissa */
DBL_MAX         = 1.7976931348623158e+308 /* max value */
DBL_MAX_10_EXP  = 308                     /* max decimal exponent */
DBL_MAX_EXP     = 1024                    /* max binary exponent */
DBL_MIN         = 2.2250738585072014e-308 /* min positive value */
DBL_MIN_10_EXP  = (-307)                  /* min decimal exponent */
DBL_MIN_EXP     = (-1021)                 /* min binary exponent */
_DBL_RADIX      = 2                       /* exponent radix */
_DBL_ROUNDS     = 1                       /* addition rounding: near */

FLT_DIG         = 6                       /* # of decimal digits of precision */
FLT_EPSILON     = 1.192092896e-07         /* smallest such that 1.0+FLT_EPSILON != 1.0 */
FLT_GUARD       = 0
FLT_MANT_DIG    = 24                      /* # of bits in mantissa */
FLT_MAX         = 3.402823466e+38         /* max value */
FLT_MAX_10_EXP  = 38                      /* max decimal exponent */
FLT_MAX_EXP     = 128                     /* max binary exponent */
FLT_MIN         = 1.175494351e-38         /* min positive value */
FLT_MIN_10_EXP  = (-37)                   /* min decimal exponent */
FLT_MIN_EXP     = (-125)                  /* min binary exponent */
FLT_NORMALIZE   = 0
FLT_RADIX       = 2                       /* exponent radix */
FLT_ROUNDS      = 1                       /* addition rounding: near */

LDBL_DIG        = DBL_DIG                 /* # of decimal digits of precision */
LDBL_EPSILON    = DBL_EPSILON             /* smallest such that 1.0+LDBL_EPSILON != 1.0 */
LDBL_MANT_DIG   = DBL_MANT_DIG            /* # of bits in mantissa */
LDBL_MAX        = DBL_MAX                 /* max value */
LDBL_MAX_10_EXP = DBL_MAX_10_EXP          /* max decimal exponent */
LDBL_MAX_EXP    = DBL_MAX_EXP             /* max binary exponent */
LDBL_MIN        = DBL_MIN                 /* min positive value */
LDBL_MIN_10_EXP = DBL_MIN_10_EXP          /* min decimal exponent */
LDBL_MIN_EXP    = DBL_MIN_EXP             /* min binary exponent */
_LDBL_RADIX     = DBL_RADIX               /* exponent radix */
_LDBL_ROUNDS    = DBL_ROUNDS              /* addition rounding: near */
