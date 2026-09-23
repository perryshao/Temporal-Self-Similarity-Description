function path = traceback_path(steps)
% Traceback a path through a distance array by analyzing a steps matrix.

% (Copied almost verbatim from [Ellis2003].)

path=[];
[i, j] = size(steps);
path(1,:) = [i,j];
% trace path back from bottom right to top left
% while i>1 && j>1 % perry delete
while (i+j)~=2
    if (i-1)==0
        j = j-1;
    elseif (j-1) == 0
        i = i-1;
    else
    switch steps(i,j)
        case 1
            % we got here from g(i, j-1)
            j = j-1;
        case 2
            % we got here from g(i-1, j-1)
            i = i-1;
            j = j-1;
        case 3
            % we got here from g(i-1, j)
            i = i-1;
        otherwise
            error('Oh noes!!1 This cannot have happened.');
    end
    end
    path = [[i j]; path]; %#ok
end
