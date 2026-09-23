//
// MATLAB Compiler: 4.18.1 (R2013a)
// Date: Mon Jun 22 18:20:28 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:libli2nsvm_multiclass_fwd" "-T"
// "link:lib" "li2nsvm_multiclass_fwd"
//

#ifndef __libli2nsvm_multiclass_fwd_h
#define __libli2nsvm_multiclass_fwd_h 1

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

#ifdef EXPORTING_libli2nsvm_multiclass_fwd
#define PUBLIC_libli2nsvm_multiclass_fwd_C_API __global
#else
#define PUBLIC_libli2nsvm_multiclass_fwd_C_API /* No import statement needed. */
#endif

#define LIB_libli2nsvm_multiclass_fwd_C_API PUBLIC_libli2nsvm_multiclass_fwd_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_libli2nsvm_multiclass_fwd
#define PUBLIC_libli2nsvm_multiclass_fwd_C_API __declspec(dllexport)
#else
#define PUBLIC_libli2nsvm_multiclass_fwd_C_API __declspec(dllimport)
#endif

#define LIB_libli2nsvm_multiclass_fwd_C_API PUBLIC_libli2nsvm_multiclass_fwd_C_API

#else

#define LIB_libli2nsvm_multiclass_fwd_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library.
 */
#ifndef LIB_libli2nsvm_multiclass_fwd_C_API
#define LIB_libli2nsvm_multiclass_fwd_C_API /* No special import/export declaration */
#endif

extern LIB_libli2nsvm_multiclass_fwd_C_API
bool MW_CALL_CONV libli2nsvm_multiclass_fwdInitializeWithHandlers(
       mclOutputHandlerFcn error_handler,
       mclOutputHandlerFcn print_handler);

extern LIB_libli2nsvm_multiclass_fwd_C_API
bool MW_CALL_CONV libli2nsvm_multiclass_fwdInitialize(void);

extern LIB_libli2nsvm_multiclass_fwd_C_API
void MW_CALL_CONV libli2nsvm_multiclass_fwdTerminate(void);

extern LIB_libli2nsvm_multiclass_fwd_C_API
void MW_CALL_CONV libli2nsvm_multiclass_fwdPrintStackTrace(void);

extern LIB_libli2nsvm_multiclass_fwd_C_API
bool MW_CALL_CONV mlxLi2nsvm_multiclass_fwd(int nlhs, mxArray *plhs[], int nrhs, mxArray
                                            *prhs[]);

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_libli2nsvm_multiclass_fwd
#define PUBLIC_libli2nsvm_multiclass_fwd_CPP_API __declspec(dllexport)
#else
#define PUBLIC_libli2nsvm_multiclass_fwd_CPP_API __declspec(dllimport)
#endif

#define LIB_libli2nsvm_multiclass_fwd_CPP_API PUBLIC_libli2nsvm_multiclass_fwd_CPP_API

#else

#if !defined(LIB_libli2nsvm_multiclass_fwd_CPP_API)
#if defined(LIB_libli2nsvm_multiclass_fwd_C_API)
#define LIB_libli2nsvm_multiclass_fwd_CPP_API LIB_libli2nsvm_multiclass_fwd_C_API
#else
#define LIB_libli2nsvm_multiclass_fwd_CPP_API /* empty! */
#endif
#endif

#endif

extern LIB_libli2nsvm_multiclass_fwd_CPP_API void MW_CALL_CONV li2nsvm_multiclass_fwd(int nargout, mwArray& C, mwArray& Y, const mwArray& X, const mwArray& w, const mwArray& b, const mwArray& class_name);

#endif
#endif
