//#include "stdafx.h"
//#include <windows.h> 
//#include <GL/gl.h>
//#include <GL/glu.h>
//#include "glut.h"
//#include <math.h>
//#include <stdio.h>
//#include <stdlib.h>
//#include <iostream>
//#include <ctime>
//#include "resource.h"

#include <vector>
#include <cmath>
#include <climits>
#include <exception>
#include <deque>

//#ifdef HAVE_UNISTD_H
//#include <unistd.h>
//#else
//#include <io.h>
//#endif
#include <mex.h> 
#include <matrix.h>
#include <time.h>


class pt{
public:
	double x,y;
	pt(){ x=-101;y=-101;};
};

std::deque<pt> dq; // convex hull

std::vector<pt> points; // Sized per call; no fixed 1000-point buffer. // simple polyline
int length=0; // actual number of points of the polyline

bool v_cross_sgn(pt a, pt b, pt c){ 
pt u,v; v.x=b.x-a.x; v.y=b.y-a.y; u.x=c.x-b.x; u.y=c.y-b.y;
double uxvz = u.x * v.y - u.y * v.x; 
if (uxvz>0) return 1; //right
else return 0;//left
}

void Melkman(void){
if (length<3) return; //less than 2 points

if (v_cross_sgn(points[0],points[1],points[2])){ //right
	dq.push_back(points[0]); //insert at the end (right)	 
	dq.push_back(points[1]);
}
else{ 	//left
	dq.push_back(points[1]);	
	dq.push_back(points[0]);
}
dq.push_back(points[2]);
dq.push_front(points[2]); //insert at the begin (left)
if (length==3) return;
  for (int i=3; i<length; i++){
	int s=dq.size();
	while (v_cross_sgn(points[i],dq.at(0),dq.at(1)) && v_cross_sgn(dq.at(s-2),dq.at(s-1),points[i])){
		i++; if (i>length-1) return;
		}
	while (!v_cross_sgn(dq.at(s-2),dq.at(s-1),points[i])){
		dq.pop_back(); s=dq.size();
		}
	dq.push_back(points[i]);
	while (!v_cross_sgn(points[i],dq.at(0),dq.at(1))){
		dq.pop_front(); 
		}
	dq.push_front(points[i]);
   } 
}

void online_Melkman(void)
{
	if (length<=3) return Melkman();
	else
		{
		 int s=dq.size();
		 if (!(v_cross_sgn(points[length-1],dq.at(0),dq.at(1)) && v_cross_sgn(dq.at(s-2),dq.at(s-1),points[length-1])))
			{
				while (!v_cross_sgn(dq.at(s-2),dq.at(s-1),points[length-1]))
				{
					dq.pop_back(); s=dq.size();
				}
				dq.push_back(points[length-1]);
				while (!v_cross_sgn(points[length-1],dq.at(0),dq.at(1)))
				{
					dq.pop_front(); 
				}
				dq.push_front(points[length-1]);
			}
		}
}

void clear(void){
length=0;
int s=dq.size();
for (int i=0; i<s;++i){
	dq.pop_back();
}

}

static void runHull(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *A, *B, *C;//*D;
    int m, n,k;
	length = 0;
	/* parse input arguments*/
	A = mxGetPr(prhs[0]);
	m = mxGetM(prhs[0]);
	n = mxGetN(prhs[0]);
	if (nrhs==1)
	{
		
		length = m;
		for(int i=0;i<m;i++) 
		{
			points[i].x=A[0*m+i];
			points[i].y=A[1*m+i];
		}			  
		Melkman();
	}
	else
	{
		B = mxGetPr(prhs[1]);
		k = mxGetM(prhs[1]);
		
		for (int i=0;i<m;i++)
		{

			points[i].x=A[0*m+i];
			points[i].y=A[1*m+i];
			length++;

		}
		Melkman();	
		for (int i=0;i<k;i++)
		{
			
			points[length].x=B[0*k+i];
			points[length].y=B[1*k+i];
			length++;
			
		}

		online_Melkman();
	}
    /* create output arguments*/
	int s=dq.size();
	plhs[0]=mxCreateDoubleMatrix(s,n,mxREAL);
	C=mxGetPr(plhs[0]);
	for (int i=0;i<s;i++)
	{
		C[0*s+i]=dq.at(i).x;
		C[1*s+i]=dq.at(i).y;	
	}

	clear();
}


// Restored from Mexfunction_C, 2026-09-24. The original algorithm is unchanged.
// Supported incremental use appends exactly one point, matching Determine_xy.m.
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    clear();
    if ((nrhs != 1 && nrhs != 2) || nlhs != 1)
        mexErrMsgIdAndTxt("Melkman:arity", "Use H = MelkmanConvexHull(P[, point]).");
    mwSize total = 0;
    for (int a = 0; a < nrhs; ++a) {
        if (!mxIsDouble(prhs[a]) || mxIsComplex(prhs[a]) || mxIsSparse(prhs[a]) ||
            mxGetNumberOfDimensions(prhs[a]) != 2 || mxGetN(prhs[a]) != 2)
            mexErrMsgIdAndTxt("Melkman:type", "Inputs must be full real double N-by-2 matrices.");
        mwSize rows = mxGetM(prhs[a]);
        if ((a == 0 && rows < 3) || (a == 1 && rows != 1))
            mexErrMsgIdAndTxt("Melkman:shape", "Use at least three initial points and one optional new point.");
        if (rows > static_cast<mwSize>(INT_MAX) - total)
            mexErrMsgIdAndTxt("Melkman:size", "Too many points for the legacy algorithm.");
        total += rows;
        const double *v = mxGetPr(prhs[a]);
        for (mwSize j = 0; j < rows * 2; ++j)
            if (!std::isfinite(v[j]))
                mexErrMsgIdAndTxt("Melkman:finite", "Point coordinates must be finite.");
    }
    const double *v = mxGetPr(prhs[0]);
    mwSize m = mxGetM(prhs[0]);
    double cross = (v[1] - v[0]) * (v[m+2] - v[m]) -
                   (v[m+1] - v[m]) * (v[2] - v[0]);
    if (!std::isfinite(cross) || cross == 0.0)
        mexErrMsgIdAndTxt("Melkman:degenerate", "The first three points must form a nondegenerate triangle.");
    try {
        points.resize(total);
        runHull(nlhs, plhs, nrhs, prhs);
    } catch (const std::exception&) {
        clear();
        mexErrMsgIdAndTxt("Melkman:geometry", "Unsupported degenerate point sequence or allocation failure.");
    }
}
