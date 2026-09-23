//
// MATLAB Compiler: 4.18.1 (R2013a)
// Date: Mon Jun 22 17:50:08 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:libsc_pooling_ts" "-T"
// "link:lib" "sc_pooling_ts" 
//

#include <stdio.h>
#define EXPORTING_libsc_pooling_ts 1
#include "libsc_pooling_ts.h"

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
#ifndef LIB_libsc_pooling_ts_C_API
#define LIB_libsc_pooling_ts_C_API /* No special import/export declaration */
#endif

LIB_libsc_pooling_ts_C_API 
bool MW_CALL_CONV libsc_pooling_tsInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!GetModuleFileName(GetModuleHandle("libsc_pooling_ts"), path_to_dll, _MAX_PATH))
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

LIB_libsc_pooling_ts_C_API 
bool MW_CALL_CONV libsc_pooling_tsInitialize(void)
{
  return libsc_pooling_tsInitializeWithHandlers(mclDefaultErrorHandler, 
                                                mclDefaultPrintHandler);
}

LIB_libsc_pooling_ts_C_API 
void MW_CALL_CONV libsc_pooling_tsTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

LIB_libsc_pooling_ts_C_API 
void MW_CALL_CONV libsc_pooling_tsPrintStackTrace(void) 
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


LIB_libsc_pooling_ts_C_API 
bool MW_CALL_CONV mlxSc_pooling_ts(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "sc_pooling_ts", nlhs, plhs, nrhs, prhs);
}

LIB_libsc_pooling_ts_CPP_API 
void MW_CALL_CONV sc_pooling_ts(int nargout, mwArray& beta, const mwArray& feaSet, const 
                                mwArray& B, const mwArray& pyramid, const mwArray& gamma)
{
  mclcppMlfFeval(_mcr_inst, "sc_pooling_ts", nargout, 1, 4, &beta, &feaSet, &B, &pyramid, &gamma);
}

