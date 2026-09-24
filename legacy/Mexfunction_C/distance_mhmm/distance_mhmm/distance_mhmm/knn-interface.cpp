/*
 * knn-interface.c
 *
 * Created 5-27-92 by Mark Wheeler at Carnegie Mellon University, 
 *                    mdwheel@cs.cmu.edu
 *
 * provides an interface to do multiple nearest neighbor searches of 
 * a given vector of k-dimensional data
 *
 */


#include "c.h"
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "kd-tree.h"
#include "knn.h"

/* KNNSearch provides an interface for doing multiple nearest neighbor 
 * searches while hiding the kd-tree structure from the user.
 * A static variable is used to make sure the kdtree is built only once.
 * the interface is:
 *   data -- an array of k-dimensional points
 *   k    -- dimension of points
 *   m    -- number of neighbors to find
 *   n    -- number of vectors in data

 *   i    -- kd tree index, allow multiple simultaneous	trees
 * returns:
 *   pqd  -- m-dimensional vector of squared distances for the m-nearest
 *           neighbors in increasing order of distance
 *   pqr  -- m-dimensional vector of indices (of the data array) for the 
 *           m-nearest neighbors in increasing order of distance
 * it is assumed that pqd and pqr are allocated by the calling program.
 */
/* static variables visible only to this interface */
static BUCKET *KDNNRoot[200];

void KNNSearch(double data[], double key[], double pqd[],
	       int pqr[], int k, int m, int n, int i)
{
  if (KDNNRoot[i] == NULL) {
    /* Build KDTree first time only */
    KDNNRoot[i] = (BUCKET *) malloc((unsigned) sizeof(BUCKET));
    MakeKDTree(KDNNRoot[i],data,k,n);
  }

  KDNNSearch(KDNNRoot[i],data,key,pqd,pqr,k,m);
}

/* set KDNNFirstTime to TRUE so tree is rebuilt next time */
void NewKNNData(int i)
{
  void freeKNNTree();

  if (KDNNRoot[i]) {
    /* free the tree data structures */
    freeKNNTree(KDNNRoot[i]);
    KDNNRoot[i] = NULL;
  }
}

void freeKNNTree(BUCKET *node)
{
  if (node != NULL) {
    switch(node->type) {
    case TERMINAL:
      free((char *) node->index);
      break;
    case NONTERMINAL:
      freeKNNTree(node->left);
      freeKNNTree(node->right);
      break;
    }
    free((char *) node);
  }
}

void KNNInsertItem(double data[], double key[], int k,int index,int i)
{
  void KDTreeInsertItem();

  KDTreeInsertItem(data,KDNNRoot[i],key,index,k);

}


void KNNRemoveItem(double key[], int k,int index,int i)
{
  void KDTreeRemoveItem();

  KDTreeRemoveItem(KDNNRoot[i],key,index,k);
}



