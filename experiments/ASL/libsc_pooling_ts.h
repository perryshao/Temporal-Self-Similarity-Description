//
// MATLAB Compiler: 4.18.1 (R2013a)
// Date: Mon Jun 22 17:50:08 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:libsc_pooling_ts" "-T"
// "link:lib" "sc_pooling_ts" 
//

#ifndef __libsc_pooling_ts_h
#define __libsc_pooling_ts_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_libsc_pooling_ts
#define PUBLIC_libsc_pooling_ts_C_API __global
#else
#define PUBLIC_libsc_pooling_ts_C_API /* No import statement needed. */
#endif

#define LIB_libsc_pooling_ts_C_API PUBLIC_libsc_pooling_ts_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_libsc_pooling_ts
#define PUBLIC_libsc_pooling_ts_C_API __declspec(dllexport)
#else
#define PUBLIC_libsc_pooling_ts_C_API __declspec(dllimport)
#endif

#define LIB_libsc_pooling_ts_C_API PUBLIC_libsc_pooling_ts_C_API


#else

#define LIB_libsc_pooling_ts_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_libsc_pooling_ts_C_API 
#define LIB_libsc_pooling_ts_C_API /* No special import/export declaration */
#endif

extern LIB_libsc_pooling_ts_C_API 
bool MW_CALL_CONV libsc_pooling_tsInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_libsc_pooling_ts_C_API 
bool MW_CALL_CONV libsc_pooling_tsInitialize(void);

extern LIB_libsc_pooling_ts_C_API 
void MW_CALL_CONV libsc_pooling_tsTerminate(void);



extern LIB_libsc_pooling_ts_C_API 
void MW_CALL_CONV libsc_pooling_tsPrintStackTrace(void);

extern LIB_libsc_pooling_ts_C_API 
bool MW_CALL_CONV mlxSc_pooling_ts(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_libsc_pooling_ts
#define PUBLIC_libsc_pooling_ts_CPP_API __declspec(dllexport)
#else
#define PUBLIC_libsc_pooling_ts_CPP_API __declspec(dllimport)
#endif

#define LIB_libsc_pooling_ts_CPP_API PUBLIC_libsc_pooling_ts_CPP_API

#else

#if !defined(LIB_libsc_pooling_ts_CPP_API)
#if defined(LIB_libsc_pooling_ts_C_API)
#define LIB_libsc_pooling_ts_CPP_API LIB_libsc_pooling_ts_C_API
#else
#define LIB_libsc_pooling_ts_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_libsc_pooling_ts_CPP_API void MW_CALL_CONV sc_pooling_ts(int nargout, mwArray& beta, const mwArray& feaSet, const mwArray& B, const mwArray& pyramid, const mwArray& gamma);

#endif
#endif
