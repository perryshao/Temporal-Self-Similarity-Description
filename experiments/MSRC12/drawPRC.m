function drawPRC(Recall, Precision)
%DRAWPRC  Plot the average recall-precision curve of a retrieval test.
%   DRAWPRC(RECALL, PRECISION) averages the per-query rows of RECALL and
%   PRECISION and plots precision against recall on [0,1] x [0,1].

averageRecall = mean(Recall, 1);
averagePrecision = mean(Precision, 1);
plot(averageRecall, averagePrecision, '-bo');
axis([0 1 0 1]);
xlabel('Recall'); ylabel('Precision');
set(gca, 'box', 'on');
