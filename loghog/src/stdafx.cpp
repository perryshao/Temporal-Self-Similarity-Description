// stdafx.cpp : 只包括标准包含文件的源文件
// Log_Hog.pch 将作为预编译头
// stdafx.obj 将包含预编译类型信息

#include "stdafx.h"
#include "log_hogcalculator.h"

// TODO: 在 STDAFX.H 中
// 引用任何所需的附加头文件，而不是在此文件中引用

int main()
{
	MATFile *pMF; // mat文件
    mxArray *pA; // 矩阵指针
    double *SSM; // 数据指针
    pMF = matOpen("ssm.mat", "r");
    // 获得矩阵
    pA = matGetVariable(pMF,"Image_TSSM");
	int m = mxGetM(pA);
	int n = mxGetN(pA);
    // 获得矩阵数据地址
    SSM = mxGetPr(pA);
	// transfer mxArray to Mat in opencv
	Mat image(m,n,CV_64F);
	size_t subs[2];
	for (int i = 0; i < m; i++)
   {
        subs[0] = i;
        for (int j = 0; j < n; j++)
        {
             subs[1] = j;

			 image.at<double>(i,j) = SSM[j*m+i];
        }
   }

	LogHogCalculator getLogHog(30,8,4,6,"unsigned",4);
	Mat LogHog = getLogHog.ExtractHogsDiagonal(image);
    // 释放矩阵空间
    mxDestroyArray(pA);
    // 关闭文件
    matClose(pMF);
}


