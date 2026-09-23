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

void minimal(double a, double b,double c)
{
	if(a<b)                       /*用if双分支结构判断比较求出前两个数的大小,把小的那个赋值给min*/
    {
		min_data=a;
		min_index=1;
	}	    
    else
	{
		min_data=b;
		min_index=2;

	}
    if(min_data>c)          /*把前两个数中最小值min同第三个数c比较,如果c大于min,将c的值赋值给min*/
	{	
		min_data=c;
		min_index=3;
	}

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *d, *g, *r,*steps;
    double s,a,b,c;
	int i_1=0,j_1=0,m_g,n_g,m,n;

    
	/* parse input arguments*/
	d = mxGetPr(prhs[0]);//d
	r = mxGetPr(prhs[1]);//r, adjust_windows
	m = mxGetM(prhs[0]);//rows for d
	n = mxGetN(prhs[0]);//columns for d
	s = (double) n/m; // slope constraint


	/* create output arguments*/
	m_g = m+1;//rows for g
	n_g = n+1;//columns for g
	plhs[0]=mxCreateDoubleMatrix(m_g,n_g,mxREAL);
	plhs[1]=mxCreateDoubleMatrix(m,n,mxREAL);
	//plhs[1]=mxCreateNumericMatrix(m,n,mxINT8_CLASS,mxREAL);
	g=mxGetPr(plhs[0]);
	steps=mxGetPr(plhs[1]);

	/* initialize the g matrix */
	for (int i = 0; i < m_g; i++)  
       for (int j = 0; j < n_g; j++)
		   g[j*m_g+i]=DBL_MAX;	
	g[0*m_g+0]=2*d[0*m+0];

	/* begin dynamically computting the optimal path*/
	for (int i=1;i<m_g;i++)
		for (int j=1;j<n_g;j++)
		{
			if (fabs(i+1-(j+1)/s) > r[0])
			   continue;
	        i_1 = i-1;
			j_1 = j-1;
			//minimal(2,1,3);
			a=g[(j-1)*m_g+i]+d[j_1*m+i_1];b=g[(j-1)*m_g+i-1]+2*d[j_1*m+i_1];c=g[j*m_g+i-1]+d[j_1*m+i_1];
			minimal(a,b,c);
			//g[0]=min_data;
			//steps[0]=min_index;
            g[j*m_g+i]=min_data;
			steps[(j-1)*m+(i-1)]=min_index;
		}
}



