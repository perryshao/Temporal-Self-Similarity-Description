//#include <windows.h> 
#include <math.h>
#include <cmath>
#include <climits>
using std::abs;
//#include <stdio.h>
//#include <stdlib.h>
//#include <ctime>
//#include <time.h>

//#include <vector>
//#include <deque>

//#ifdef HAVE_UNISTD_H
//#include <unistd.h>
//#else
//#include <io.h>
//#endif
#include <mex.h> 
#include <matrix.h>
#include <time.h>
#include <limits.h>
#include <float.h>

double min_data;
double min_index;
const double PI = 3.1415926535897932384626433832795;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Restored API: callers use eight matrices; ninth legacy output is optional.
    if (nrhs != 4 || (nlhs != 8 && nlhs != 9))
        mexErrMsgIdAndTxt("distance_matrix:arity", "Four inputs and eight (or nine) outputs are required.");
    for (int a = 0; a < 4; ++a) {
        if (!mxIsDouble(prhs[a]) || mxIsComplex(prhs[a]) || mxIsSparse(prhs[a]) ||
            mxGetNumberOfDimensions(prhs[a]) != 2)
            mexErrMsgIdAndTxt("distance_matrix:type", "Inputs must be full real double matrices.");
        if (mxGetM(prhs[a]) > INT_MAX || mxGetN(prhs[a]) > INT_MAX ||
            mxGetNumberOfElements(prhs[a]) > INT_MAX)
            mexErrMsgIdAndTxt("distance_matrix:size", "Matrix too large for legacy indexing.");
    }
    if (mxGetN(prhs[0]) != mxGetN(prhs[1]) || mxGetN(prhs[0]) % 2 != 0 ||
        mxGetN(prhs[2]) != mxGetN(prhs[3]) ||
        mxGetM(prhs[0]) != mxGetM(prhs[2]) || mxGetM(prhs[1]) != mxGetM(prhs[3]))
        mexErrMsgIdAndTxt("distance_matrix:shape", "Pair widths must agree; descriptors need even width and matching orientation rows.");
    if (mxGetM(prhs[1]) != 0 && mxGetM(prhs[0]) > static_cast<mwSize>(INT_MAX) / mxGetM(prhs[1]))
        mexErrMsgIdAndTxt("distance_matrix:size", "Output exceeds legacy indexing limits.");

	double *t, *r, *orientation1,*orientation2,*det_orien,*det_rd,*det_k,*det_t;
	double *S_orien,*S_rd,*S_t,*S_k,*parameters;
	int dim_orien,dim_t,m,n;
	double temp1 = 0,temp2 = 0,temp3 = 0,temp4 = 0,orien = 0;
	

    
	/* parse input arguments*/
	t = mxGetPr(prhs[0]);//t
	r = mxGetPr(prhs[1]);//r
	orientation1 = mxGetPr(prhs[2]);//orientation1
	orientation2 = mxGetPr(prhs[3]);//orientation2
	m = mxGetM(prhs[0]);//rows for t
	dim_t  = mxGetN(prhs[0]);//colums for t
	n = mxGetM(prhs[1]);//rows for r
	dim_orien = mxGetN(prhs[2]);//colums for orientation
	//det_diff = (double *)malloc(ncosts*sizeof(double));


	/* create output arguments*/
	plhs[0]=mxCreateDoubleMatrix(m,n,mxREAL);//det_k
	plhs[1]=mxCreateDoubleMatrix(m,n,mxREAL);//det_t
	plhs[2]=mxCreateDoubleMatrix(m,n,mxREAL);//det_orien
	plhs[3]=mxCreateDoubleMatrix(m,n,mxREAL);//det_rd
	plhs[4]=mxCreateDoubleMatrix(m,n,mxREAL);//S_k
	plhs[5]=mxCreateDoubleMatrix(m,n,mxREAL);//S_t
	plhs[6]=mxCreateDoubleMatrix(m,n,mxREAL);//S_orien
	plhs[7]=mxCreateDoubleMatrix(m,n,mxREAL);//S_rd
	if (nlhs == 9) plhs[8]=mxCreateDoubleMatrix(1,2,mxREAL);//S_rd

	det_k=mxGetPr(plhs[0]);
	det_t=mxGetPr(plhs[1]);
	det_orien=mxGetPr(plhs[2]);
	det_rd=mxGetPr(plhs[3]);
	S_k=mxGetPr(plhs[4]);
	S_t=mxGetPr(plhs[5]);
	S_orien=mxGetPr(plhs[6]);
	S_rd=mxGetPr(plhs[7]);

	/* initialize the g matrix */
	for(int i=0;i<m;i++)
		for(int j=0; j<n; j++)
		{
			temp1 = 0;temp2 = 0;temp3 = 0;temp4 = 0;
			for (int k=0; k<dim_t/2; k++)
			{
				temp1 = temp1+abs(t[k*m+i]-r[k*n+j]);
				temp2 = temp2+abs(t[k*m+i])+abs(r[k*n+j]);
				temp3 = temp3+abs(t[(k+dim_t/2)*m+i]-r[(k+dim_t/2)*n+j]);
				temp4 = temp4+abs(t[(k+dim_t/2)*m+i])+abs(r[(k+dim_t/2)*n+j]);
			}
			det_k[j*m+i] = temp1;S_k[j*m+i]=temp2;det_t[j*m+i]=temp3;S_t[j*m+i]=temp4;
			temp1 = 0;temp2 = 0;temp3 = 0;temp4 = 0;
			for (int k=0; k<dim_orien; k++)
				if (k == 2 || k == 5)
				{
					temp1 = temp1+abs(orientation1[k*m+i]-orientation2[k*n+j]);
					temp2 = temp2+abs(orientation1[k*m+i])+abs(orientation2[k*n+j]);
				}
				else
				{
					orien = orientation1[k*m+i]-orientation2[k*n+j];
					if (orien > PI) orien = orien - 2*PI;
					if (orien < -PI) orien = orien + 2*PI;
					temp3 = temp3+abs(orien);
					temp4 = temp4+abs(orientation1[k*m+i])+abs(orientation2[k*n+j]);
				}
				det_rd[j*m+i] = temp1;S_rd[j*m+i]=temp2;det_orien[j*m+i]=temp3;S_orien[j*m+i]=temp4;
		}
	        

}



