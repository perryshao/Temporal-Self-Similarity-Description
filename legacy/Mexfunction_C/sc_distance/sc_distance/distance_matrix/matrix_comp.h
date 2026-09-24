#include <stdio.h>
#include <math.h>


void print_vector(double v[4])
/*
function: output a 4D position vector to the screen.
Input: v[4] -a 4D position vector
*/
{
	for (int i=0; i<4; i++)
		printf("%0.1f ", v[i]);
	printf("\n");
}


// Task 1
void vector_matrix(double vec[4], double m[4][4], double prod[4])
{
	int n=4;
	for (int j=0; j<n; j++)
		{
			prod[j] = 0; /* initialize the jth element of p to 0*/
			for (int i=0; i<n; i++)
				{
					prod[j] = prod[j] + vec[i]*m[i][j];
				}
		}
}



void matrix_matrix(double m[4][4], double n[4][4], double prod[4][4])
/*
function: to compute the product of two 4x4 matrices
input: m[4][4] - the first matrix
the first index is the row index
the second index is the column index
n[4][4] - the second 4x4 matrix
the first index is the row index
the second index is the column index
output: prod[4][4] - the product m x n
*/
{
	for (int i=0; i<4; i++)
	{
		vector_matrix(m[i], n, prod[i]);
	}
}




// Task 4
void matrix_identity(double m[4][4])
{
	for (int i=0; i<4; i++)
	{
			for (int j=0; j<4; j++)
			{
				if (i==j)m[i][j]=1.0;
				else m[i][j]=0.0;
			}
	}
}









