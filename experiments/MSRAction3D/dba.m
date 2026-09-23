function average = dba(sequences)
% index=randi(length(sequences),1);
index = 1;
average = sequences{index};
for i = 1:5
    average = DBA_one_iteration(average, sequences);
end
end

function average = DBA_one_iteration(averageS, sequences)

tupleAssociation = cell (1, size(averageS, 2));
for t = 1:size(averageS, 2)
    tupleAssociation{t} = [];
end

for k = 1:length(sequences)
    sequence = sequences{k};
    [~, ~, path] = dtw(averageS', sequence', 50);
    for i = 1: size(path, 1)
        tupleAssociation{path(i, 1)}(:, end+1) = sequence(:, path(i, 2));
    end
end

for t = 1:size(averageS, 2)
    averageS(:, t) = mean(tupleAssociation{t}, 2);
end

average = averageS;

end
