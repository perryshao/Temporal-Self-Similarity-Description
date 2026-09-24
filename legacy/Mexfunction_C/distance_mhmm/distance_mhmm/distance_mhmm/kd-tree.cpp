/* 
 * kd-tree.c 
 * 
 * Created 5-27-92 by Mark Wheeler at Carnegie Mellon University, 
 *                    mdwheel@cs.cmu.edu
 * 
 * 
 * code to build a kd-tree which 
 * stores a set of n k-dimensional vectors
 * with a uniform dissimilarity metric
 * 
 * Algorithm taken from:
 * "An Algorithm for Finding Best Matches in Logarithmic Expected Time"
 *        by Jerome H. Friedman, Jon Bentley and Raphael Finkel
 * found in "ACM Transactions on Mathematical Software"
 *             VOLUME 3 No. 3 1977, pp. 209-226
 * 
 * Must be compiled with librecipes.a (Numerical Recipes)
 * it calls mdian2() to compute the median of a vector
 */


#include <math.h>
#include <values.h>
#include <stdio.h>
#include "kd-tree.h"
#include "knn.h"



/* 
 * top level call to build a kd-tree of indices into the array data
 * takes:
 *  root -- a pointer to an allocated KDtree node
 *  data -- an (n,k) array of k-d data
 *  k -- the dimension of the data vectors
 *  n -- the number of data vectors
 * creates a kd-tree pointed to by root
 * the kd-tree leaves contain indices which can be used to index the original
 * data vector
 * this saves much space especially if k is large
 */
void MakeKDTree(BUCKET *root, double data[], register int k, register int n)
{
  register int i, *index;

  index = (int *) malloc((unsigned) sizeof(int)*n);

  for( i = 0; i < n; ++i) index[i] = i;

  BuildKDTree(root,data,index,k,n);

  free((char *) index);
}

/* 
 * BuildKDTree --- algorithm from Friedman, Bentley and Finkel
 * data is an (*,k) vector of doubles
 * and index (n) vector of ints which index into elements of data
 */

void BuildKDTree(register BUCKET *result,register double data[],
	    register int index[], register int k, register int n)
{
  register int i,j,*rd,*ld,r,l,count,K,same;
  int d,*left_index,*right_index;
  double p,maxspread,spread_estimate;

  if (n <= BUCKET_SIZE) {
    result->type = TERMINAL;
    result->dimension = 0;
    result->median = 0.0;
    result->left = NULL;
    result->right = NULL;

    result->index = (int *) malloc((unsigned) sizeof(int)*n);

    count = 0;
    for(i=0; i < n; ++i) { 
      /* check for duplicates here - ow this can mess up any application
       * that assumes 1 entry per location */
      j = 0; same = 0;
      while (!same && j < i) {
	same = 1; K = 0;
	while(same && K < k) {
	  same = (data[index[i]*k + K] == data[index[j]*k + K]);
	  ++K;
	}
	++j;
      }
      if (!same) {
	result->index[count] = index[i];
	++count;
      }
#ifdef DEBUG
      else {
	fprintf(stderr,"dups:\n");
	fprintf(stderr,"%d",index[i]);
	for(K = 0; K < k; ++K) 
	  fprintf(stderr," %4.1f",data[index[i]*k + K]);
	fprintf(stderr,"\n");
	fprintf(stderr,"%d",index[j]);
	for(K = 0; K < k; ++K) 
	  fprintf(stderr," %4.1f",data[index[j]*k + K]);
	fprintf(stderr,"\n");
      }
#endif
    }
    result->n = count;
  }
  else {
    maxspread = 0;
    d = 0;    
    for(j=0; j < k; ++j) {
      spread_estimate =  KDSpreadEstimate(j,data,index,k,n);
      if (spread_estimate > maxspread) {
	maxspread = spread_estimate;
	d = j;
      }
    }
    p = KDMedian(d,data,index,k,n);

    left_index = (int *) malloc((unsigned) sizeof(int)*n);
    right_index = (int *) malloc((unsigned) sizeof(int)*n);


    ld = left_index;
    rd = right_index;
    r = 0;     l = 0;
    for(i=0; i < n; ++i)     
      if (data[index[i]*k + d] <= p) {
	++l;
	*ld++ = index[i];
      }
      else {
	++r;
	*rd++ = index[i];
      }

    if ((r == n) || (l == n)) {
      /*
       * we have identical elements: store as one element in a terminal node
       */
      result->type = TERMINAL;
      result->dimension = 0;
      result->median = 0.0;
      result->left = NULL;
      result->right = NULL;

      result->index = (int *) malloc((unsigned) sizeof(int));

      result->n = 1;
      result->index[0] = index[0];
      /* was:
	 fprintf(stderr,
	 "Fatal error: There are %d equivalent entries in k-d tree\n",n);
	 exit(-1);
	 */
    } 
    else {
      result->left = (BUCKET *) malloc((unsigned) sizeof(BUCKET));
      result->right = (BUCKET *) malloc((unsigned) sizeof(BUCKET));

      BuildKDTree(result->left,data,left_index,k,l);
      BuildKDTree(result->right,data,right_index,k,r);
      result->dimension = d;
      result->median = p;
      /* zero out other fields */
      result->type = NONTERMINAL;
      result->index = NULL;
      result->n = 0;
    }
    free((char *) left_index);
    free((char *) right_index);
  }

}


/* 
 * return the median of the dth dimension of the vector of data
 */
double KDMedian(register int d, register double *data, 
	       register int index[],register int k,register int n)
{
  register double *ddata;
  double result;
  register int i;
  void mdian3();

  ddata = (double *) malloc((unsigned) sizeof(double)*(n+1));

  for(i=0; i < n; ++i)  
    ddata[i+1] = data[index[i]*k + d];

  /* code for finding median of a vector of doubles 
   * --- from Numerical Recipes 
   * note NR uses vectors from ddata[1] ... ddata[n]
   */
  mdian3(ddata,n,&result);
  free((char *) ddata);

  return(result);
}

/* 
 * return the magnitude of the range of values of the dth 
 * dimension of the vector of data
 */
double KDSpreadEstimate(register int d,register double *data,
		       register int index[], register int k,register int n)
{
  double sum,mean;
  register int i;

  sum = 0.0;
  for(i=0; i < n; ++i) 
    sum += data[index[i]*k+d];

  mean = sum/(double) n;
  sum = 0.0;
  for(i=0; i < n; ++i) 
    sum += (data[index[i]*k+d] - mean)*(data[index[i]*k+d] - mean);
  
  return(sum/(double) n);
}



/*
 * mdian3.c
 * modified to balance the sides
 */
void mdian3(register double x[],register int n,register double *xmed)
{
  register int n2,nhi,nlo;
  void sort();

  sort(n,x);
  n2 = (n % 2) ? n/2 + 1 : n/2;
  *xmed = x[n2];

  /* when the real median is also the maximum our rule if data <= median
   * will not split the data
   * thus we choose a median just below the real median but above the
   * next lowest data 
   */
  if (*xmed < x[n2+1]) return; /* perfect split */

  nhi = n2 + 1;
  while( (*xmed == x[nhi]) && (nhi < n) ) ++nhi;
  
  nlo = n2 - 1;
  while( (*xmed == x[nlo]) && (nlo > 1) ) --nlo;

  if (n - 2*nlo <= 2*nhi - n) 
    *xmed = x[nlo];
  else *xmed = x[nhi];
}

void sort(register int n, register double ra[])
{
	register int l,j,ir,i;
	double rra;

	l=(n >> 1)+1;
	ir=n;
	for (;;) {
		if (l > 1)
			rra=ra[--l];
		else {
			rra=ra[ir];
			ra[ir]=ra[1];
			if (--ir == 1) {
				ra[1]=rra;
				return;
			}
		}
		i=l;
		j=l << 1;
		while (j <= ir) {
			if (j < ir && ra[j] < ra[j+1]) ++j;
			if (rra < ra[j]) {
				ra[i]=ra[j];
				j += (i=j);
			}
			else j=ir+1;
		}
		ra[i]=rra;
	}
}



BUCKET_PTR KDTreeSearchNode(register BUCKET *node,register double key[],
			    register int k)
{
  if (node->type == TERMINAL) {
    /* for each element in the terminal bucket
     * compute the dissimilarity and insert into the queue
     */
    return(node);
  }
  else {
    if (key[node->dimension] <= node->median) {
      return(KDTreeSearchNode(node->left,key,k));
    }
    else {
      return(KDTreeSearchNode(node->right,key,k));
    }
  }
}


void KDTreeInsertItem(register double data[],register BUCKET *root,
		      register double key[],
		      register int index,register int k)
{
  register int i,*new_index_list;
  int index_list[BUCKET_SIZE+1];
  BUCKET *node;

  node = KDTreeSearchNode(root,key,k);

  if (node->n == BUCKET_SIZE) {
    /* add two buckets to this node to add the new point */
    for (i = 0; i < BUCKET_SIZE+1; ++i)
      index_list[i] = node->index[i];
    index_list[BUCKET_SIZE] = index;
      
    BuildKDTree(node,data,index_list,k,BUCKET_SIZE+1);
  }
  else { /* room to add this to index list */
    new_index_list = (int *) malloc((unsigned) sizeof(int)*(node->n + 1));
    for (i = 0; i < node->n; ++i)
      new_index_list[i] = node->index[i];
    new_index_list[node->n] = index;
    free((char *) node->index);
    node->index = new_index_list;
    node->n = node->n + 1;
  }
}


void KDTreeRemoveItem(register BUCKET *root,
		      register double key[],register int index,register int k)
{
  register int i;
  register BUCKET *node;

  node = KDTreeSearchNode(root,key,k);

  if (node->n == 0) 
    return;
  else {
    i = 0;
    while ((i < node->n) && (node->index[i] != index))
      ++i;
    if (node->index[i] == index) {
      while(i+1 < node->n) {
	node->index[i] = node->index[i+1];
	++i;
      }
      --(node->n);
    }
  }
}





