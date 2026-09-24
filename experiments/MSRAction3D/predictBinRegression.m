function predictLabel = predictBinRegression(testdata, theta)
%PREDICTBINREGRESSION  Predict classes with the multi-output linear regressor.
%   LABEL = PREDICTBINREGRESSION(TESTDATA, THETA) returns, for every column of
%   TESTDATA (D x N), the class with the largest response TESTDATA(:,i)'*THETA.
%
%   See also TRAINBINREGRESSION.

N = size(testdata, 2);
predictLabel = zeros(N, 1);
for i = 1:N
    [~, predictLabel(i)] = max(testdata(:, i)'*theta);
end
