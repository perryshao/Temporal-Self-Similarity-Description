//#include <windows.h> 
#include "StdAfx.h"
#include <math.h>
#include <mex.h> 
#include <matrix.h>
#include <time.h>
#include <limits.h>
#include <float.h>
#include<string.h>
#include "hist_cost.h" //添加MATLAB引擎头文件
#include "mclmcrrt.h"
#include "mclcppclass.h"
#include "mclmcr.h"

//#pragma comment(lib,"libeng.lib")
//#pragma comment(lib,"libmex.lib")
#pragma comment(lib,"libmx.lib")
#pragma comment(lib,"libmat.lib")
#pragma comment(lib, "mclmcrrt.lib")
#pragma comment(lib, "mclmcr.lib")
#pragma comment(lib,"hist_cost.lib")


double min_data;
double min_index;
const double PI = 3.1415926535897932384626433832795;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *sc1,*sc2,*t,*r,*det_k,*det_t,*det_sc;
	double *S_t,*S_k,*parameters;
	double *sc_theta,*sc_alpha,*x_p,*y_p;
	int dim_sc,dim_t,m,n,m_sc1,m_sc2;
	int nbins = 60, m_num =9;
	double temp1 = 0,temp2 = 0,temp3 = 0,temp4 = 0,orien = 0;
	

    
	/* parse input arguments*/
	t = mxGetPr(prhs[0]);//t
	r = mxGetPr(prhs[1]);//r
	sc1 = mxGetPr(prhs[2]);//sc1
	sc2 = mxGetPr(prhs[3]);//sc2
	m = mxGetM(prhs[0]);//rows for t
	dim_t  = mxGetN(prhs[0]);//colums for t
	n = mxGetM(prhs[1]);//rows for r
	dim_sc = mxGetN(prhs[2]);//colums for sc
	m_sc1 =  mxGetM(prhs[2]);// rows for sc1
	m_sc2 =  mxGetM(prhs[3]);// rows for sc2
	//det_diff = (double *)malloc(ncosts*sizeof(double));


	/* create output arguments*/
	plhs[0]=mxCreateDoubleMatrix(m,n,mxREAL);//det_k
	plhs[1]=mxCreateDoubleMatrix(m,n,mxREAL);//det_t
	plhs[2]=mxCreateDoubleMatrix(m,n,mxREAL);//S_k
	plhs[3]=mxCreateDoubleMatrix(m,n,mxREAL);//S_t
	plhs[4]=mxCreateDoubleMatrix(m,n,mxREAL);//det_sc

	det_k=mxGetPr(plhs[0]);
	det_t=mxGetPr(plhs[1]);
	S_k=mxGetPr(plhs[2]);
	S_t=mxGetPr(plhs[3]);
	det_sc=mxGetPr(plhs[4]);

	 mclmcrInitialize();


	if (!mclInitializeApplication(NULL,0))
        {
            mexPrintf("could not initialize application properly");
        }
		
	if (!hist_costInitialize())
		{
			mexPrintf("can't inital matlab fucntion!");
			//exit(1);
		}
        

	/*Engine *ep; 
	if(!(ep=engOpen(NULL))) //打开MATLAB引擎
	{
		mexPrintf("can't start MATLAB engine!");
		exit(1);
	}
	engSetVisible(ep, 0);*/
	//利用MATLAB API mxCreateDoubleMatrix函数生成矩阵，即申请空间，MATLAB引擎中使用mxArray类型数据
	mxArray *xx=mxCreateDoubleMatrix(m_num,nbins,mxREAL);//1行N列，mxREAL为实双精度矩阵
	mxArray *yy=mxCreateDoubleMatrix(m_num,nbins,mxREAL);
	mxArray *x=mxCreateDoubleMatrix(m_num,nbins,mxREAL);//1行N列，mxREAL为实双精度矩阵
	mxArray *y=mxCreateDoubleMatrix(m_num,nbins,mxREAL);
	mxArray *sc_cost_theta=mxCreateDoubleMatrix(1,1,mxREAL);
	mxArray *sc_cost_alpha=mxCreateDoubleMatrix(1,1,mxREAL);
	x_p=mxGetPr(x);
	y_p=mxGetPr(y);
	sc_theta=mxGetPr(sc_cost_theta);
	sc_alpha=mxGetPr(sc_cost_theta);

	int k_sep = 0;
	for(int i=0;i<m/m_num;i++)
		for(int j=0; j<n/m_num; j++)
		{
			for (int k=0; k<dim_sc/2; k++)
			{
				for (int idev=0;idev<m_num;idev++) { x_p[k*m_num+idev] = sc1[k*m_sc1+i*m_num+idev];x_p[k*m_num+idev] = sc2[k*m_sc2+j*m_num+idev];}
				mlfHist_cost_2(1,&sc_cost_theta,x,y);

				//mxGetPr获取指向输入、输出矩阵数据的指针
				//memcpy(mxGetPr(xx),x,m_num*nbins*sizeof(double));//将数组 x 复制到 mxarray 数组 xx 中，即给xx数组赋值
				//memcpy(mxGetPr(yy),y,m_num*nbins*sizeof(double));
				//engPutVariable(ep,"xx",xx);//将 mxArray 数组 xx 写入到 Matlab 工作空间，命名为 xx 
				//engPutVariable(ep,"yy",yy);
				//engEvalString(ep,"costmat_theta=hist_cost_2(xx,yy)");//通过引擎调用MATLAB中plot(x,y)函数，绘制函数曲线
				//engEvalString(ep,"a1=min(costmat_theta,[],1)");engEvalString(ep,"a2=min(costmat_theta,[],2)");engEvalString(ep,"sc_cost_theta=max(mean(a1),mean(a2))");
				//sc_cost_theta = engGetVariable(ep,"sc_cost_theta");

			}
				for (int k=dim_sc/2; k<dim_sc; k++)
			{
				for (int idev=0;idev<m_num;idev++) { x_p[k*m_num+idev] = sc1[k*m_sc1+i*m_num+idev];x_p[k*m_num+idev] = sc2[k*m_sc2+j*m_num+idev];}
				//mxGetPr获取指向输入、输出矩阵数据的指针
				mlfHist_cost_2(1,&sc_cost_alpha,x,y);
				//memcpy(mxGetPr(xx),x,m_num*nbins*sizeof(double));//将数组 x 复制到 mxarray 数组 xx 中，即给xx数组赋值
				//memcpy(mxGetPr(yy),y,m_num*nbins*sizeof(double));
				//engPutVariable(ep,"xx",xx);//将 mxArray 数组 xx 写入到 Matlab 工作空间，命名为 xx 
				//engPutVariable(ep,"yy",yy);
				//engEvalString(ep,"costmat_alpha=hist_cost_2(xx,yy)");//通过引擎调用MATLAB中plot(x,y)函数，绘制函数曲线
				//engEvalString(ep,"a1=min(costmat_alpha,[],1)");engEvalString(ep,"a2=min(costmat_alpha,[],2)");engEvalString(ep,"sc_cost_alpha=max(mean(a1),mean(a2))");
				//sc_cost_alpha = engGetVariable(ep,"sc_cost_alpha");
			}
				det_sc[j*(m/m_num)+i]=sc_alpha[0]+sc_theta[0];
				//det_sc[j*(m/m_num)+i]=x_p[0]+y_p[0];
	
		}
	
	

	mxDestroyArray(xx); //释放内存
	mxDestroyArray(yy);//释放内存
	mxDestroyArray(sc_cost_theta); //释放内存
	mxDestroyArray(sc_cost_alpha);//释放内存
	//engClose(ep); 
	hist_costTerminate();

	


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



