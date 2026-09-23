#include "stdafx.h"
#include "log_hogcalculator.h"



LogHogCalculator::LogHogCalculator()
{
	radius = 30;
	nbins_theta = 8;
	nbins_r = 4;
	nthet = 6;
	issigned = "unsigned"; //(0-pi) default
	normmethod = 4;
}

LogHogCalculator::LogHogCalculator(double r,int theta_bins, int r_bins, int nthet_bins, char *issignedFlag, int normFlag)
{
	radius = r;
	nbins_theta = theta_bins;
	nbins_r = r_bins;
	nthet = nthet_bins;
	issigned = issignedFlag; //(0-pi) default
	normmethod = normFlag;
}

LogHogCalculator::~LogHogCalculator()
{

}

cv::Mat LogHogCalculator::ExtractHogsDiagonal(cv::Mat img)
{
	double celltheta =  PI/nbins_theta;
	double cellro = log(radius)/nbins_r;
  // check parameters's validity.
	int M = img.rows; int N = img.cols;
	//construct the indx matrix
	int sum = 0;
	for(int i=1;i<=M;i++)
     sum+=i;
	Mat indx_matrix(2,sum,CV_64F,Scalar(0)) ;
	int n=0;
	for (int i = 0;i<M;i++)
	    for (int j = i;j<M;j++)
			{	
				indx_matrix.at<double>(0,n) = i;
				indx_matrix.at<double>(1,n) = j;
				n++;
			}

	// calculate gradient scale matrix.
	 Mat gradscalx(img.rows,img.cols,img.type()), gradscaly(img.rows,img.cols,img.type());
	 Mat gradscal;int ksize = 3;
	 Mat kernel(ksize,ksize,CV_64F,Scalar(0));
	 // filter rows first
	 kernel.at<double>(1,0) = -1;kernel.at<double>(1,1) = 0;kernel.at<double>(1,2) = 1;
	 Ptr<FilterEngine> LinearFilter1 = createLinearFilter(img.type(), gradscalx.type(), kernel, Point(-1,-1), 0, BORDER_CONSTANT, -1, Scalar());
	 LinearFilter1->apply(img,gradscalx,Rect(0,0,-1,-1),Point(0,0),false);
	 // filter columns sencond
	 kernel.setTo(0);
	 kernel.at<double>(0,1) = 1;kernel.at<double>(1,1) = 0;kernel.at<double>(2,1) = -1;
	 Ptr<FilterEngine> LinearFilter2 = createLinearFilter(img.type(), gradscaly.type(), kernel, Point(-1,-1), 0, BORDER_CONSTANT, -1, Scalar());
	 LinearFilter2->apply(img,gradscaly,Rect(0,0,-1,-1),Point(0,0),false);
	 // calculate gradient orientation matrix.
	 // plus small number for avoiding dividing zero.
	 Mat gradscalxplus = gradscalx+Mat(gradscalx.rows,gradscalx.cols,CV_64F,Scalar(0.0001));
	 Mat gradorient;
	 cv::cartToPolar(gradscalx,gradscaly,gradscal,gradorient,false);// orientation will fall into [0-2*PI]
	 // unsigned situation: orientation region is 0 to pi.
	 int or = 0;

	 //test the maximum and minimum in gradorient
	 /*
	 double minVal=0;
	 double maxVal=0;
	 Point minLoc, maxLoc;
	 minMaxLoc(gradorient, &minVal, &maxVal, &minLoc, &maxLoc);
	 */

	 if (strcmp(issigned,"unsigned")==0)
	 {
		Mat dist_flag = gradorient > PI;
		 for (int i=0;i<dist_flag.rows;i++)
			for (int j=0;j<dist_flag.cols;j++)
			{
				if (dist_flag.at<uchar>(i,j) == 255)
					gradorient.at<double>(i,j) = gradorient.at<double>(i,j) - PI;
			}
			or =1;
	 }
	 else if(strcmp(issigned,"signed")==0)
		{
			/*
			for (int i=0;i<dist_flag.rows;i++)
				for (int j=0;j<dist_flag.cols;j++)
				{
					if (dist_flag.at<uchar>(i,j) == 255)
						gradorient.at<double>(i,j) = gradorient.at<double>(i,j) + 2*PI;
				}
			*/
			or = 2;
		}
	 else
			printf("%s\n", "Incorrect ISSIGNED parameter.");


	// calculate block slide step.
	int xbstride = 1;
	int xbstridend = M;
	// calculate the total blocks number in the window detected, which is
	int ntotalbh = M/xbstride;
	/* generate the matrix hist3dbig for storing the 3-dimensions histogram. the
	% matrix covers the whole image in the 'globalinterpolate' condition or
	% covers the local block in the 'localinterpolate' condition. The matrix is
	% bigger than the area where it covers by adding additional elements
	% (corresponding to the cells) to the surround for calculation convenience.*/
	int sizeOfhist3dbig[3] = {nbins_theta+2, nbins_r+2, nthet+2};
	int sizeOfhist3d[3] = {nbins_theta,nbins_r,nthet};
	Mat hist3dbig(3,sizeOfhist3dbig,CV_64F,Scalar(0));
	Mat hist3d(3,sizeOfhist3d,CV_64F,Scalar(0));
	Mat F(1,ntotalbh*nbins_theta*nbins_r*nthet,CV_64F,Scalar(0));
	// generate the matrix for storing histogram of one block;
	Mat sF(1,nbins_theta*nbins_r*nthet,CV_64F,Scalar(0));
	/* vote for histogram. there are two situations according to the interpolate
	% condition('global' interpolate or local interpolate). The hist3d which is
	% generated from the 'bigger' matrix hist3dbig is the final histogram.*/
	int xbstep = xbstride;
	// rotate angle
	Mat tMatrix(2,sum,CV_64F,Scalar(0));
	Mat rtMatrix(2,sum,CV_64F,Scalar(0));
	Mat diagPixels(2,sum,CV_64F,Scalar(0));
	Mat diagPixels_src(2,1,CV_64F,Scalar(0));
	Mat squareMatrix;
	Mat rArray;
	Mat logR;
	Mat thetaArray;
	int gm,gn,binx1,biny1,binz1,binx2,biny2,binz2;
	int idsF,iblock,idF;
	double gs,go,iorbi,jorbj;
	double x1,y1,z1;
	Mat btPixels(2,sum,CV_64F,Scalar(-1));
	Point   center(0, 0);
	double rotTheta = 45;
	Mat rotM = getRotationMatrix2D(center, rotTheta, 1.0);// angle
	Mat rotMatrix(2,2,CV_64F,Scalar(0));
	rotM.col(0).copyTo(rotMatrix.col(0));rotM.col(1).copyTo(rotMatrix.col(1));
	// block slide loop
	for (int btlx = 0, btly =0; btlx<xbstridend; btlx=btlx+xbstep, btly = btlx) 
	{
		diagPixels_src.at<double>(0,0) = btlx;
		diagPixels_src.at<double>(1,0) = btly;
		repeat(diagPixels_src,1,sum,diagPixels);
		tMatrix = indx_matrix - diagPixels;

		rtMatrix = rotMatrix*tMatrix;
		Mat rtM_flag = cv::abs(rtMatrix) < 10e-4;
		for (int i=0;i<rtM_flag.rows;i++)
			for (int j=0;j<rtM_flag.cols;j++)
			{
				if (rtM_flag.at<uchar>(i,j) == 255)
					rtMatrix.at<double>(i,j) = 0;
			}

		squareMatrix = tMatrix.mul(tMatrix);
		btPixels.setTo(-1);//reset the btPixels mat to -1 at every pixel
		for (int i = 0;i<sum;i++)
		{	
			if (std::sqrt(squareMatrix.at<double>(0,i) + squareMatrix.at<double>(1,i)) >0
			 && std::sqrt(squareMatrix.at<double>(0,i) + squareMatrix.at<double>(1,i)) <= radius)
			 {
				 btPixels.at<double>(0,i) = indx_matrix.at<double>(0,i);
		 		 btPixels.at<double>(1,i) = indx_matrix.at<double>(1,i);
			 }
		}
			cv::cartToPolar(rtMatrix.row(0),rtMatrix.row(1),rArray,thetaArray,false);
			cv::log(rArray, logR);
			for (int bi=0;bi<sum;bi++)
			{
				if (btPixels.at<double>(0,bi) == -1 && btPixels.at<double>(1,bi) == -1) 
					continue;
				gm = btPixels.at<double>(0,bi);
				gn = btPixels.at<double>(1,bi);
				gs = gradscal.at<double>(gm,gn);
				go = gradorient.at<double>(gm,gn);
				jorbj = logR.at<double>(0,bi);iorbi = thetaArray.at<double>(0,bi);
				// calculate bin index of hist3dbig

				binx1 = floor((jorbj+cellro/2)/cellro) + 1;
				biny1 = floor((iorbi+celltheta/2)/celltheta) + 1;
				binz1 = floor((go+(or*PI/nthet)/2)/(or*PI/nthet)) + 1;

				if (gs < 1E-5) continue;

				binx2 = binx1 + 1;
				biny2 = biny1 + 1;
				binz2 = binz1 + 1;

				x1 = (binx1-1.5)*cellro; // don't need add 0.5 here
				y1 = (biny1-1.5)*celltheta;
				z1 = (binz1-1.5)*(or*PI/nthet);

				// trillinear interpolation
				hist3dbig.at<double>(biny1-1,binx1-1,binz1-1) =
						hist3dbig.at<double>(biny1-1,binx1-1,binz1-1) + gs*
						 (1-(jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)
						*(1-(go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny1-1,binx1-1,binz2-1) =
						hist3dbig.at<double>(biny1-1,binx1-1,binz2-1) + gs*
						 (1-(jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)
						*((go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny2-1,binx1-1,binz1-1) =
						hist3dbig.at<double>(biny2-1,binx1-1,binz1-1) + gs*
						(1-(jorbj-x1)/cellro)*((iorbi-y1)/celltheta)
						*(1-(go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny2-1,binx1-1,binz2-1) =
						hist3dbig.at<double>(biny2-1,binx1-1,binz2-1) + gs*
						(1-(jorbj-x1)/cellro)*((iorbi-y1)/celltheta)
						*((go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny1-1,binx2-1,binz1-1) =
						hist3dbig.at<double>(biny1-1,binx2-1,binz1-1) + gs*
						((jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)
						*(1-(go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny1-1,binx2-1,binz2-1) =
						hist3dbig.at<double>(biny1-1,binx2-1,binz2-1) + gs*
						((jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)
						*((go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny2-1,binx2-1,binz1-1) =
						hist3dbig.at<double>(biny2-1,binx2-1,binz1-1) + gs*
						((jorbj-x1)/cellro)*((iorbi-y1)/celltheta)
						*(1-(go-z1)/(or*PI/nthet));
				hist3dbig.at<double>(biny2-1,binx2-1,binz2-1) =
						hist3dbig.at<double>(biny2-1,binx2-1,binz2-1) + gs*
						((jorbj-x1)/cellro)*((iorbi-y1)/celltheta)
						*((go-z1)/(or*PI/nthet));
			}

			// In the local interpolate condition. F is generated in this block
		// slide loop. hist3dbig should be cleared in each loop.
			if (or == 2)
			{
				for (int i=0;i<sizeOfhist3dbig[0];i++)
					for (int j=0;j<sizeOfhist3dbig[1];j++)
					{
						hist3dbig.at<double>(i,j,1) = hist3dbig.at<double>(i,j,1) + hist3dbig.at<double>(i,j,nthet+1);
						hist3dbig.at<double>(i,j,nthet) = hist3dbig.at<double>(i,j,nthet) + hist3dbig.at<double>(i,j,0);
					}
			}
			for (int i=0;i<sizeOfhist3d[0];i++)
				for (int j=0;j<sizeOfhist3d[1];j++)
					for(int k=0;k<sizeOfhist3d[2];k++)
						hist3d.at<double>(i,j,k) = hist3dbig.at<double>(i+1,j+1,k+1);
			for (int ibin=0;ibin<nbins_theta;ibin++)
				for (int jbin=0;jbin<nbins_r;jbin++)
				{
					idsF = nthet*(ibin*nbins_r+jbin);
					for (int i=0,j=idsF;i<nthet;i++,j++)
						sF.at<double>(0,j) = hist3d.at<double>(ibin,jbin,i);
				}
			iblock = btlx/xbstride ;
			idF = iblock*nbins_theta*nbins_r*nthet;
			for (int i=0,j=idF;i<nbins_theta*nbins_r*nthet;i++,j++)
				F.at<double>(0,j) = sF.at<double>(0,i);
			hist3dbig.setTo(0);
	}
	// adjust the negative value caused by accuracy of floating-point
	// operations.these value's scale is very small, usually at E-03 magnitude
	// while others will be E+02 or E+03 before normalization.
	Mat fMflag = F < 0;
	for (int i=0;i<fMflag.cols;i++)
		{
			if (fMflag.at<uchar>(0,i) == 255)
				F.at<double>(0,i) = 0;
		}
	// block normalization.
	double e = 0.001;
	double l2hysthreshold = 0.6;
	double div_sum;
	int fslidestep = nbins_r*nbins_theta*nthet;
	switch (normmethod){
			case 0:
			case 1:
				for (int fi=0;fi<F.cols;fi=fi+fslidestep)
				{
					div_sum = 0;
					for (int i=fi;i<fi+fslidestep;i++)
					{
						div_sum = F.at<double>(0,i)+div_sum;
					}
					for (int i=fi;i<fi+fslidestep;i++)
					{
						F.at<double>(0,i) = F.at<double>(0,i)/(div_sum+e);
					}
				}
				break;
			case 2:
				for (int fi=0;fi<F.cols;fi=fi+fslidestep)
				{
					div_sum = 0;
					for (int i=fi;i<fi+fslidestep;i++)
					{
						div_sum = F.at<double>(0,i)+div_sum;
					}
					for (int i=fi;i<fi+fslidestep;i++)
					{
						F.at<double>(0,i) = std::sqrt(F.at<double>(0,i)/(div_sum+e));
					}
				}
				break;
			case 3:
				for (int fi=0;fi<F.cols;fi=fi+fslidestep)
				{
					div_sum = 0;
					for (int i=fi;i<fi+fslidestep;i++)
					{
						div_sum = std::pow(F.at<double>(0,i),2)+div_sum;
					}
					for (int i=fi;i<fi+fslidestep;i++)
					{
						F.at<double>(0,i) = F.at<double>(0,i)/sqrt(div_sum+e*e);
					}
				}
				break;
			case 4:
					for (int fi=0;fi<F.cols;fi=fi+fslidestep)
					{
						div_sum = 0;
						for (int i=fi;i<fi+fslidestep;i++)
						{
							div_sum = std::pow(F.at<double>(0,i),2)+div_sum;
						}
						for (int i=fi;i<fi+fslidestep;i++)
						{   
							F.at<double>(0,i) = F.at<double>(0,i)/sqrt(div_sum+e*e);
							if (F.at<double>(0,i) > l2hysthreshold)
								F.at<double>(0,i) = l2hysthreshold;
						}
						div_sum = 0;
						for (int i=fi;i<fi+fslidestep;i++)
						{
							div_sum = std::pow(F.at<double>(0,i),2)+div_sum;
						}
						for (int i=fi;i<fi+fslidestep;i++)
						{
							F.at<double>(0,i) = F.at<double>(0,i)/sqrt(div_sum+e*e);
						}
					}
					break;
				default: printf("Incorrect NORMMETHOD parameter.\n");
		}
	Mat F_t = F.reshape(0,M);
	// relocate the bins since that the center bins will be summed up to one bin
	int nbins =  nbins_r*nbins_theta-nbins_theta+1;// the sum bins for single center
	Mat F_temp(ntotalbh,nbins*nthet,CV_64F, Scalar(0));
	double temp = 0;
	for (int i=0;i<ntotalbh;i++)
		for (int j=0;j<nbins_r*nbins_theta;j=j+nbins_r)
		{
			for (int m=j*nthet,n=0;m<(j+1)*nthet;m++,n++)
				F_temp.at<double>(i,n) = F_t.at<double>(i,m)+F_temp.at<double>(i,n);
		}
	for (int m=0;m<ntotalbh;m++)
		for (int j=0;j<nbins_theta;j++)
			for (int i=2+j*nbins_r;i<2+j*nbins_r+(nbins_r-2)+1;i++)
			{
				for (int n = (i-1)*nthet,k=(i-j-1)*nthet; n<i*nthet;n++,k++)
					F_temp.at<double>(m,k) = F_t.at<double>(m,n);
			}
	F_t = F_temp;
	return F_t;

}
