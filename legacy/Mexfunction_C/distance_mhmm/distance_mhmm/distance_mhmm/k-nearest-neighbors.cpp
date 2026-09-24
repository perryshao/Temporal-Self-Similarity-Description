/* 
 * k-nearest-neighbors.c 
 * 
 * Created 5-27-92 by Mark Wheeler at Carnegie Mellon University, 
 *                    mdwheel@cs.cmu.edu
 * 
 * Code to do k-nearest neighbors search of k-dimensional vectors
 * with a uniform dissimilarity metric utilizing kd-trees
 * 
 * 
 * Algorithm taken from:
 * "An Algorithm for Finding Best Matches in Logarithmic Expected Time"
 *        by Jerome H. Friedman, Jon Bentley and Raphael Finkel
 * found in "ACM Transactions on Mathematical Software"
 *             VOLUME 3 No. 3 1977, pp. 209-226
 *
 * uses code in kd-tree.c to build the optimized kd-tree for efficient search
 *
 * Must be compiled with librecipes.a (Numerical Recipes)
 * it uses mdian2() for finding the median of a vector
 *
 *
 * Modified 5-15-93 by David Simon - Optimized for 3d trees. It is assumed
 * that add data points are 3 dimensional. Also added register variables. 
 *
 */

#include "c.h"
#include <math.h>
#include <values.h> /* definition of MAXFLOAT here */
#include "kd-tree.h" 
#include "knn.h"

/*
 * NOTE: this appears to be faster than the above, despite the claims of
 * Sproull.  
 */
#define ComputeDissimilarity(x, y, k, dis) {\
  double t; int i;\
\
  (dis) = 0;\
  for(i=0; i < k; ++i) {\
    CoordinateDistance(i,x,y,t);\
    (dis) += t;\
  }\
}


/* 
 * top level m-nearest-neighbor search routine (initializes variables required
 * for the recursive search routine):
 * takes:
 *   root -- a pointer to a kd-tree node
 *   data -- an array of k-dimensional points
 *   k    -- dimension of points
 *   m    -- number of neighbors to find
 * returns:
 *   pqd  -- m-dimensional vector of squared distances for the m-nearest 
 *           neighbors in increasing order of distance
 *   pqr  -- m-dimensional vector of indices (of the data array) for the 
 *           m-nearest neighbors in increasing order of distance
 */
void KDNNSearch(BUCKET *root,double data[],double key[],register double pqd[],
		register int pqr[],register int k, register int m)
{
  register int i;
  void  KDNNSearchNode();

  for( i = 0; i < m; ++i) pqd[i] = MAXFLOAT;
  KDNNSearchNode(root,data,key,pqd,pqr,k,m);
}


/* KDNNSearchNode -- algorithm from Friedman, Bentley and Finkel
 * recursive nearest neighbor search routine -- to mimick tail recursion
 * returns TRUE when done to exit previous calls
 */
void KDNNSearchNode(register BUCKET *node, register double data[], 
		    register double key[], register double pqd[],
		    register int pqr[],register int k,register int m)
{
  register int i,j,d;
  double dist,temp,p;
  double dp, dp2;
  register double *dataptr;

  if (node->type == TERMINAL) {
    /* for each element in the terminal bucket
     * compute the dissimilarity and insert into the queue
     */
    for(i = 0; i < node->n; ++i) {
      dataptr = &data[node->index[i]*k];
      ComputeDissimilarity(key, dataptr, k, dist);

      /* if this element is closer than any of the m closest
       * insert it into the queue
       */
      if (dist < pqd[m-1]) {
	j = m-1;
	pqd[j] = dist;
	pqr[j] = node->index[i];
	while ((j-1 >= 0) && (pqd[j] < pqd[j-1])) {
	  temp = pqd[j-1]; pqd[j-1] = pqd[j]; pqd[j] = temp;
	  temp = pqr[j-1]; pqr[j-1] = pqr[j]; pqr[j] = temp;
	  --j;
	}
      }
    }
  }
  else {
    d = node->dimension;
    p = node->median;
    dp = key[d] - p;
    dp2 = dp * dp;

    if (dp <= 0) { /* was < , but <= goes left in kd-tree.c(shouldn't matter)*/
      KDNNSearchNode(node->left,data,key,pqd,pqr,k,m);
      if (dp2 < pqd[m-1]) {
	KDNNSearchNode(node->right,data,key,pqd,pqr,k,m);
      }
    } else {
      KDNNSearchNode(node->right,data,key,pqd,pqr,k,m);
      if (dp2 < pqd[m-1]) {
	KDNNSearchNode(node->left,data,key,pqd,pqr,k,m);
      }
    }
  }
}






