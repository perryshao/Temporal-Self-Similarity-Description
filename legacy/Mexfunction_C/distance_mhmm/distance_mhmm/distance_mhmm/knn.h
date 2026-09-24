
#ifndef knn_h
#define knn_h 1


#include "kd-tree.h"
/*
 * in kd-tree.c
 */
void MakeKDTree(BUCKET *, double [], register int, register int);
void BuildKDTree(register BUCKET *,register double [],
	    register int [], register int , register int );
double KDMedian(register int, register double *, 
	       register int [],register int,register int);
double KDSpreadEstimate(register int,register double *,
		       register int [], register int,register int);
void mdian3(register double [],register int,register double *);
void sort(register int, register double []);
BUCKET_PTR KDTreeSearchNode(register BUCKET *,register double [],
			    register int);
void KDTreeInsertItem(register double [],register BUCKET *,
		      register double [],register int,register int);
void KDTreeRemoveItem(register BUCKET *,
		      register double [],register int,register int);

/*
 * in k-nearest-neighbors.c
 */
void KDNNSearch(BUCKET *,double [],double [],register double [],
		register int [],register int, register int);
void KDNNSearchNode(register BUCKET *, register double [], 
		    register double [], register double [],
		    register int [],register int,register int);

/*
 * in knn-interface.c
 */
void KNNSearch(double [], double [], double [],
	       int [], int , int, int, int);
void NewKNNData(int);
void freeKNNTree(BUCKET *);
void KNNInsertItem(double [], double [], int,int,int);

#endif /* knn_h */
