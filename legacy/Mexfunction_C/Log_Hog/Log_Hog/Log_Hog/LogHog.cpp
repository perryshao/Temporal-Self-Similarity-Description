#include <iostream>
#include "stdafx.h"
#include "log_hogcalculator.h"
//#include "mexopencv.hpp"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* parse input arguments*/
	double *imgData = mxGetPr(prhs[0]);
	int m = mxGetM(prhs[0]);
	int n = mxGetN(prhs[0]);
	// transfer mxArray to Mat in opencv
	Mat image(m,n,CV_64F);
	//image = MxArray(prhs[0]).toMat(CV_32F,false);
	
	for (int i = 0; i < m; i++)
   {
        for (int j = 0; j < n; j++)
        {
			 image.at<double>(i,j) = imgData[j*m+i];
        }
   }
   

	// radius = 30; nbins_theta = 8; nbins_r = 4; nthet = 6; issigned = "unsigned" normmethod = l2hys;
    LogHogCalculator getLogHog(30,8,4,6,"unsigned",4);
	Mat LogHog = getLogHog.ExtractHogsDiagonal(image);

	//int h = LogHog.rows;
	//int w = LogHog.cols;
	//plhs[0] = mxCreateNumericMatrix(h, w,mxSINGLE_CLASS, mxREAL);
	//plhs[0] = MxArray(image);
	
	//Mat LogHog = image;

	
	int h = LogHog.rows;
	int w = LogHog.cols;
	double *output;
	plhs[0] = mxCreateNumericMatrix(h, w,mxDOUBLE_CLASS, mxREAL);
	output = mxGetPr(plhs[0]);
	for (int i = 0; i < h; i++)
	{
	    for (int j = 0; j < w; j++)
	    {
	        output[j*h + i] =  LogHog.at<double>(i,j);
	    }
	}
	
}

