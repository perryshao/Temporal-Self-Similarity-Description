/*
 * MATLAB Compiler: 4.18.1 (R2013a)
 * Date: Wed Mar 05 16:36:39 2014
 * Arguments: "-B" "macro_default" "-W" "lib:hist_cost" "-T" "link:lib"
 * "hist_cost_2" "hist.m" 
 */

#ifndef __hist_cost_h
#define __hist_cost_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
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

#ifdef EXPORTING_hist_cost
#define PUBLIC_hist_cost_C_API __global
#else
#define PUBLIC_hist_cost_C_API /* No import statement needed. */
#endif

#define LIB_hist_cost_C_API PUBLIC_hist_cost_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_hist_cost
#define PUBLIC_hist_cost_C_API __declspec(dllexport)
#else
#define PUBLIC_hist_cost_C_API __declspec(dllimport)
#endif

#define LIB_hist_cost_C_API PUBLIC_hist_cost_C_API


#else

#define LIB_hist_cost_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_hist_cost_C_API 
#define LIB_hist_cost_C_API /* No special import/export declaration */
#endif

extern LIB_hist_cost_C_API 
bool MW_CALL_CONV hist_costInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_hist_cost_C_API 
bool MW_CALL_CONV hist_costInitialize(void);

extern LIB_hist_cost_C_API 
void MW_CALL_CONV hist_costTerminate(void);



extern LIB_hist_cost_C_API 
void MW_CALL_CONV hist_costPrintStackTrace(void);

extern LIB_hist_cost_C_API 
bool MW_CALL_CONV mlxHist_cost_2(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_hist_cost_C_API 
bool MW_CALL_CONV mlxHist(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);



extern LIB_hist_cost_C_API bool MW_CALL_CONV mlfHist_cost_2(int nargout, mxArray** HC, mxArray* BH1, mxArray* BH2);

extern LIB_hist_cost_C_API bool MW_CALL_CONV mlfHist(int nargout, mxArray** no, mxArray** xo, mxArray* varargin);

#ifdef __cplusplus
}
#endif
#endif
