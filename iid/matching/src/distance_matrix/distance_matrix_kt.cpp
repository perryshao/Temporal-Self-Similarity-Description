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
	double *t, *r,*det_k,*det_t;
	double *S_t,*S_k;
	int dim_t,m,n;
	double temp1 = 0,temp2 = 0,temp3 = 0,temp4 = 0,orien = 0;
	

    
	/* parse input arguments*/
	t = mxGetPr(prhs[0]);//t
	r = mxGetPr(prhs[1]);//r
	m = mxGetM(prhs[0]);//rows for t
	dim_t  = mxGetN(prhs[0]);//colums for t
	n = mxGetM(prhs[1]);//rows for r
	//det_diff = (double *)malloc(ncosts*sizeof(double));


	/* create output arguments*/
	plhs[0]=mxCreateDoubleMatrix(m,n,mxREAL);//det_k
	plhs[1]=mxCreateDoubleMatrix(m,n,mxREAL);//det_t
	plhs[2]=mxCreateDoubleMatrix(m,n,mxREAL);//S_k
	plhs[3]=mxCreateDoubleMatrix(m,n,mxREAL);//S_t


	det_k=mxGetPr(plhs[0]);
	det_t=mxGetPr(plhs[1]);
	S_k=mxGetPr(plhs[2]);
	S_t=mxGetPr(plhs[3]);

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
	
		}
	        

}



