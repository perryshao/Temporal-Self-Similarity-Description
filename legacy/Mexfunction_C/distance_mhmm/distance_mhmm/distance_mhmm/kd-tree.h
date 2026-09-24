/* 
 * kd-tree.h 
 * 
 * Created 5-27-92 by Mark Wheeler at Carnegie Mellon University, 
 *                    mdwheel@cs.cmu.edu
 * 
 * definitions code to build a kd-tree which 
 * stores a set of n k-dimensional vectors
 * with a uniform dissimilarity metric
 * 
 * Algorithm taken from:
 * "An Algorithm for Finding Best Matches in Logarithmic Expected Time"
 *        by Jerome H. Friedman, Jon Bentley and Raphael Finkel
 * found in "ACM Transactions on Mathematical Software"
 *             VOLUME 3 No. 3 1977, pp. 209-226 * Created 5-27-92 by MD Wheeler
 * 
 *
 * Modified 5-15-93 by David Simon - Optimized for 3d trees. It is assumed
 * that add data points are 3 dimensional. Also added register variables. 
 *
 */

#ifndef kd_tree_h
#define kd_tree_h 1
#define TERMINAL 1
#define NONTERMINAL 0
#define BUCKET_SIZE 5
#define NULL 0

#define CoordinateDistance(d,x,y,r) {\
  double val = ((x)[(d)] - (y)[(d)]); \
  (r) = val*val; \
}

/*
 * Note - this was changed on 1/13/93 by David Simon. There is no point
 * in computing the sqrt. Just a waste of time since the same result 
 * will occur w/o it. 
 */
/*#define Dissimilarity(x) (sqrt((double) x)) */
#define Dissimilarity(x) (x)

struct bucket {
  int type;
  int dimension;
  double median;
  struct bucket *left,*right;
  int *index;
  int n;
};

typedef struct bucket BUCKET;
typedef struct bucket *BUCKET_PTR;
#endif /* kd_tree_h */


