//
// MATLAB Compiler: 4.18.1 (R2013a)
// Date: Mon Jun 22 18:20:28 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:libli2nsvm_multiclass_fwd" "-T"
// "link:lib" "li2nsvm_multiclass_fwd"
//

#include <stdio.h>
#define EXPORTING_libli2nsvm_multiclass_fwd 1
#include "libli2nsvm_multiclass_fwd.h"

static HMCRINSTANCE _mcr_inst = NULL;

#if defined( _MSC_VER) || defined(__BORLANDC__) || defined(__WATCOMC__) || defined(__LCC__)
#ifdef __LCC__
#undef EXTERN_C
#endif
#include <windows.h>

static char path_to_dll[_MAX_PATH];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, void *pv)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        if (GetModuleFileName(hInstance, path_to_dll, _MAX_PATH) == 0)
            return FALSE;
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
    }
    return TRUE;
}
#endif
#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library.
 */
#ifndef LIB_libli2nsvm_multiclass_fwd_C_API
#define LIB_libli2nsvm_multiclass_fwd_C_API /* No special import/export declaration */
#endif

LIB_libli2nsvm_multiclass_fwd_C_API
bool MW_CALL_CONV libli2nsvm_multiclass_fwdInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!GetModuleFileName(GetModuleHandle("libli2nsvm_multiclass_fwd"), path_to_dll, _MAX_PATH))
    return false;
    {
        mclCtfStream ctfStream =
            mclGetEmbeddedCtfStream(path_to_dll);
        if (ctfStream) {
            bResult = mclInitializeComponentInstanceEmbedded(   &_mcr_inst,
                                                                error_handler,
                                                                print_handler,
                                                                ctfStream);
            mclDestroyStream(ctfStream);
        } else {
            bResult = 0;
        }
    }
    if (!bResult)
    return false;
  return true;
}

LIB_libli2nsvm_multiclass_fwd_C_API
bool MW_CALL_CONV libli2nsvm_multiclass_fwdInitialize(void)
{
  return libli2nsvm_multiclass_fwdInitializeWithHandlers(mclDefaultErrorHandler,
                                                         mclDefaultPrintHandler);
}

LIB_libli2nsvm_multiclass_fwd_C_API
void MW_CALL_CONV libli2nsvm_multiclass_fwdTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

LIB_libli2nsvm_multiclass_fwd_C_API
void MW_CALL_CONV libli2nsvm_multiclass_fwdPrintStackTrace(void)
{
  char** stackTrace;
  int stackDepth = mclGetStackTrace(&stackTrace);
  int i;
  for(i=0; i<stackDepth; i++)
  {
    mclWrite(2 /* stderr */, stackTrace[i], sizeof(char)*strlen(stackTrace[i]));
    mclWrite(2 /* stderr */, "\n", sizeof(char)*strlen("\n"));
  }
  mclFreeStackTrace(&stackTrace, stackDepth);
}

LIB_libli2nsvm_multiclass_fwd_C_API
bool MW_CALL_CONV mlxLi2nsvm_multiclass_fwd(int nlhs, mxArray *plhs[], int nrhs, mxArray
                                            *prhs[])
{
  return mclFeval(_mcr_inst, "li2nsvm_multiclass_fwd", nlhs, plhs, nrhs, prhs);
}

LIB_libli2nsvm_multiclass_fwd_CPP_API
void MW_CALL_CONV li2nsvm_multiclass_fwd(int nargout, mwArray& C, mwArray& Y, const
                                         mwArray& X, const mwArray& w, const mwArray& b,
                                         const mwArray& class_name)
{
  mclcppMlfFeval(_mcr_inst, "li2nsvm_multiclass_fwd", nargout, 2, 4, &C, &Y, &X, &w, &b, &class_name);
}
