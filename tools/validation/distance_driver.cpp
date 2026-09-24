// Feed valid column-major matrices to the unmodified MEX numerical sources.
#include "mex.h"
#include <iomanip>
#include <iostream>
void mexFunction(int, mxArray**, int, const mxArray**);
int main() {
    std::size_t m, n, d;
    if (!(std::cin >> m >> n >> d) || !m || !n || !d) return 1;
    mxArray a{m, d, std::vector<double>(m*d)};
    mxArray b{n, d, std::vector<double>(n*d)};
    for (double& v : a.data) if (!(std::cin >> v)) return 1;
    for (double& v : b.data) if (!(std::cin >> v)) return 1;
    const mxArray* inputs[] = {&a, &b};
    mxArray* outputs[1] = {nullptr};
    mexFunction(1, outputs, 2, inputs);
    for (double v : outputs[0]->data) std::cout << std::setprecision(17) << v << '\n';
    delete outputs[0];
}
