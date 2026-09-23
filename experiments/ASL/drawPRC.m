function drawPRC(Recall, Precision)
averageRecall = mean(Recall, 1);
averagePrecision = mean(Precision, 1);
plot(averageRecall, averagePrecision, '-bo');
axis([0 1 0 1]);
xlabel('Recall'); ylabel('Precision');
set(gca, 'box', 'on');
