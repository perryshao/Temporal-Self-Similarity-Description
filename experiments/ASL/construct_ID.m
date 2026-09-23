function [trainGID, testGID]=construct_ID(TRAJDB, TRAJSAMPLES)
samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
r_rows = zeros(1, samples_r);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i}=='/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2));
    r_rows(i) = size(TRAJDB{2, i}, 1);
end
trainGID = grp2idx(TRAJDB(1, :)');
t_rows = zeros(1, samples_t);
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i}=='/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2));
    t_rows(i) = size(TRAJSAMPLES{2, i}, 1);
end
testGID = grp2idx(TRAJSAMPLES(1, :)');
