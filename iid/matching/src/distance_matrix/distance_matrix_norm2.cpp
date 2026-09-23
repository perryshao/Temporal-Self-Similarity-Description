//#include <windows.h> 
#include <math.h>
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
	double *t, *r, *det;
	double *parameters;
	int dim_t,m,n;
	double temp = 0;
	

    
	/* parse input arguments*/
	t = mxGetPr(prhs[0]);//t
	r = mxGetPr(prhs[1]);//r
	m = mxGetM(prhs[0]);//rows for t
	dim_t  = mxGetN(prhs[0]);//colums for t
	n = mxGetM(prhs[1]);//rows for r


	/* create output arguments*/
	plhs[0]=mxCreateDoubleMatrix(m,n,mxREAL);//det
	det=mxGetPr(plhs[0]);
	/* initialize the g matrix */
	for(int i=0;i<m;i++)
		for(int j=0; j<n; j++)
		{
			temp = 0;
			for (int k=0; k<dim_t; k++)
			{
				temp = temp+pow((t[k*m+i]-r[k*n+j]),2);
			}
			det[j*m+i] = sqrt(temp);
			//det[j*m+i] = temp;
		}
	        

}



