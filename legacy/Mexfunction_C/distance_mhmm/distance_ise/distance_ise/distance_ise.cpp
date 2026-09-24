// distance_ise.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <math.h>
#include <mex.h> 
#include <matrix.h>
#include <time.h>
#include <limits.h>
#include <float.h>
/*
#include "kd-tree.h"
#include "knn.h"
#include "knn-interface.cpp"


#define ComputeDissimilarity(x, y, k, dis) {\
  double t; int i;\
\
  (dis) = 0;\
  for(i=0; i < k; ++i) {\
    CoordinateDistance(i,x,y,t);\
    (dis) += t;\
  }\
}

double distance_ise(int t1,int t2,double *incoming_data,double sigma,int W,int m,int n);
double average(double *data, int n,int flag);
*/

const double PI = 3.1415926535897932384626433832795;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *incoming_data, *w, *sigma,*distance;
	double *t_1, *t_2;
	int m,n,W,N,t1,t2;
	double temp_sum = 0;

  
	/* parse input arguments*/
	t_1 = mxGetPr(prhs[0]);//t1
	t_2 = mxGetPr(prhs[1]);//t2
	incoming_data = mxGetPr(prhs[2]);//incoming_data
	sigma = mxGetPr(prhs[3]);//sigma
	w = mxGetPr(prhs[4]);//W
	sigma = mxGetPr(prhs[2]);//sigma
	m = mxGetM(prhs[2]);//rows for incoming_data
	n  = mxGetN(prhs[2]);//colums for incoming_data
	W = int(w[0]);
	t1 = int(t_1[0]);
	t2 = int(t_2[0]);
	N = m-W+1; // numbers of state
	/* create output arguments*/
	plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);//output distance
	distance=mxGetPr(plhs[0]);//output distance
	distance[0] = distance_ise(t1,t2,incoming_data,sigma[0],W,m,n);
}

double distance_ise(int t1,int t2,double *incoming_data,double sigma,int W,int m,int n)
{
	int dimension = n;
	int rows = m;
	double temp_sum = 0,temp1=0,temp2=0,temp3=0;

	for(int nu=0;nu<W;nu++)
		for(int omega=0; omega<W; omega++)
		{
			for (int k=0;k<n;k++)
			{
				temp1=pow((incoming_data[k*m+(t1-omega)]-incoming_data[k*m+(t1-nu)]),2)+temp1;
				temp2=pow((incoming_data[k*m+(t1-omega)]-incoming_data[k*m+(t2-nu)]),2)+temp2;
				temp3=pow((incoming_data[k*m+(t2-omega)]-incoming_data[k*m+(t2-nu)]),2)+temp3;
			}
			temp_sum = exp(-temp1/(4*sigma*sigma))-2*exp(-temp2/(4*sigma*sigma))+exp(-temp3/(4*sigma*sigma))+temp_sum;
			temp1 = 0;temp2 = 0;temp3 = 0;
		}
	return temp_sum/(W*W*sqrt(pow(4*PI*sigma*sigma,dimension)));
}
/*
double distance_ise(int t1,int t2,double *incoming_data,double sigma,int W,int m,int n)
{
	int dimension = n;
	int rows = m;
	double temp_sum = 0,temp1=0,temp2=0,temp3=0,dist,sigma1,sigma2;
	double *data_t1,*data_t2,*query,*pqd,*nndata;
	double *dist1,*dist2;
	double *mean_dist1,*mean_dist2;
	int *pqr;

	// allocate the memory for data
	data_t1 = mxGetPr(mxCreateDoubleMatrix(W,n,mxREAL));
	data_t2 = mxGetPr(mxCreateDoubleMatrix(W,n,mxREAL));
	query = mxGetPr(mxCreateDoubleMatrix(1,n,mxREAL));
	pqd = mxGetPr(mxCreateDoubleMatrix(n+1,n,mxREAL)); // find the n+1 nearest neigbors
	pqr = (int*)mxGetPr(mxCreateNumericMatrix(1,n,mxINT16_CLASS,mxREAL));
	dist1 = mxGetPr(mxCreateDoubleMatrix(1,n+1,mxREAL));
	dist2 = mxGetPr(mxCreateDoubleMatrix(1,n+1,mxREAL));
	nndata = mxGetPr(mxCreateDoubleMatrix(1,n,mxREAL));
	mean_dist1 = mxGetPr(mxCreateDoubleMatrix(1,W,mxREAL));
	mean_dist2 = mxGetPr(mxCreateDoubleMatrix(1,W,mxREAL));

	for (int i=0;i<W;i++)
		for (int k=0;k<n;k++) 
		{
			data_t1[(t1-i)*n+k] = incoming_data[k*m+t1-i];
			data_t2[(t2-i)*n+k] = incoming_data[k*m+t2-i];
		}

	for (int j=0;j<W;j++)
	{
		for (int k=0;k<m;k++) query[0*n+k] = incoming_data[k*m+t1-j];
		
			KNNSearch(data_t1,query,pqd,pqr,n, n, W, 1);
			for (int knn = 0; knn<n+1;knn++)
			{
				for (int k=0;k<m;k++) nndata[0*n+k] = pqd[knn*n+k];
				ComputeDissimilarity(query, nndata, n, dist);
				dist1[knn] = dist;
			}
		mean_dist1[j] = (average(dist1,n+1)*(n+1))/n;// eliminate the zero element
		for (int k=0;k<m;k++) query[0*n+k] = incoming_data[k*m+t2-j];
		
			KNNSearch(data_t2,query,pqd,pqr,n, n, W, 1);
			for (int knn = 0; knn<n+1;knn++)
			{
				for (int k=0;k<m;k++) nndata[0*n+k] = pqd[knn*n+k];
				ComputeDissimilarity(query, nndata, n, dist);
				dist2[knn] = dist;
			}
		mean_dist2[j] = (average(dist2,n+1)*(n+1))/n;// eliminate the zero element
	}
	sigma1 = average(mean_dist1,W);
	sigma2 = average(mean_dist2,W);

	for(int nu=0;nu<W;nu++)
		for(int omega=0; omega<W; omega++)
		{
			for (int k=0;k<n;k++)
			{
				temp1=pow((incoming_data[k*m+(t1-omega)]-incoming_data[k*m+(t1-nu)]),2)+temp1;
				temp2=pow((incoming_data[k*m+(t1-omega)]-incoming_data[k*m+(t2-nu)]),2)+temp2;
				temp3=pow((incoming_data[k*m+(t2-omega)]-incoming_data[k*m+(t2-nu)]),2)+temp3;
			}
			temp_sum = exp(-temp1/(4*sigma1*sigma1))/sqrt(pow((4*PI*sigma1*sigma1),n))-2*exp(-temp2/((2*sigma1*sigma1+2*sigma2*sigma2)))/sqrt(pow((PI*sigma1*sigma1+PI*sigma2*sigma2),n))+exp(-temp3/(4*sigma2*sigma2))/sqrt(pow((4*PI*sigma2*sigma2),n))+temp_sum;
			temp1 = 0;temp2 = 0;temp3 = 0;
		}
	return temp_sum/(W*W);
}


double average(double *data, int n)
{
	int temp = 0;
	for (int i=0;i<n;i++) temp = data[i]+temp;
	temp = temp/n;
	return temp;
}
*/