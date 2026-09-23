function predictLabel = predictBinRegression(testdata, theta)
N = size(testdata, 2);
predictLabel = zeros(N, 1);
for i = 1:N
    [~, predictLabel(i)] = max(testdata(:, i)'*theta);
end
