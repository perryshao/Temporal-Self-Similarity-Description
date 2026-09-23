#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <mat.h>
#include <time.h>
#include <limits.h>
#include <float.h>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;
using namespace std;
const double PI = 3.1415926535897932384626433832795;

class LogHogCalculator
{
    //static const int        cDepthWidth = 512;

public:
    LogHogCalculator();
    LogHogCalculator(double r,int theta_bins, int r_bins, int nthet_bins, char *issignedFlag, int normFlag);
    virtual ~LogHogCalculator();
    Mat ExtractHogsDiagonal(Mat img);

protected:
    //Parameter setting
    double radius;
    int nbins_theta;
    int nbins_r;
    int nthet;
    char *issigned;
    uint8_T normmethod;// 0:none; 1:l1; 2:l1sqrt; 3:l2; 4:l2hys;

};
