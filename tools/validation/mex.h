// Minimal numerical test shim. This is NOT the MATLAB MEX ABI.
#pragma once
#include <cstddef>
#include <vector>
struct mxArray {
    std::size_t rows, columns;
    std::vector<double> data;
};
constexpr int mxREAL = 0;
inline double* mxGetPr(const mxArray* x) {
    return const_cast<double*>(x->data.data());
}
inline std::size_t mxGetM(const mxArray* x) { return x->rows; }
inline std::size_t mxGetN(const mxArray* x) { return x->columns; }
inline mxArray* mxCreateDoubleMatrix(std::size_t m, std::size_t n, int) {
    return new mxArray{m, n, std::vector<double>(m*n)};
}
