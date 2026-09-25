function basis_regression(root, work)
%BASIS_REGRESSION Exercise constrained basis updates, including failed dual solves.
oldpath = path; oldpwd = pwd;
cleanup = onCleanup(@() restore_session(oldpath, oldpwd));
cd(work);
pkg load optim;
addpath(fullfile(root, 'thirdparty/ScSPM/sparse_coding'), '-begin');
warning('error', 'Octave:singular-matrix');
warning('error', 'Octave:nearly-singular-matrix');
f = load('basis_fixtures.mat');
solutions = cell(1, numel(f.cases));
methods = cell(size(solutions));
residuals = zeros(size(solutions));
for i = 1:numel(f.cases)
    c = f.cases{i};
    [B, info] = l2ls_learn_basis_dual(c.X, c.S, c.radius, c.initial);
    assert(all(isfinite(B(:))));
    assert(max(sqrt(sum(B.^2, 1))) <= c.radius*(1 + 1e-12));
    assert(info.projected_gradient_residual <= 1e-9);
    solutions{i} = B;
    methods{i} = info.method;
    residuals(i) = info.projected_gradient_residual;
end
% No warm start remains a supported public call.
B = l2ls_learn_basis_dual(ones(2, 3), zeros(4, 3), 1);
assert(isequal(B, zeros(2, 4)));
% A solver's success flag is insufficient: lambda=0 violates this fixture's
% atom constraints. An unavailable/broken dual solver must also fall back.
stub = fullfile(work, 'solver_stub');
if ~exist(stub, 'dir'), mkdir(stub); end
addpath(stub, '-begin');
for variant = 1:2
    fid = fopen(fullfile(stub, 'fmincon.m'), 'w');
    if variant == 1
        fprintf(fid, 'function [x,f,flag]=fmincon(fun,x0,varargin)\nx=zeros(size(x0));f=0;flag=1;\nend\n');
    else
        fprintf(fid, 'function varargout=fmincon(varargin)\nerror(''test:solverFailure'',''injected solver failure'');\nend\n');
    end
    fclose(fid);
    clear fmincon;
    rehash;
    [B, info] = l2ls_learn_basis_dual(10*eye(3), eye(3), 1);
    assert(strcmp(info.method, 'coordinate'));
    assert(norm(B-eye(3), 'fro') < 1e-10);
end
rmpath(stub); clear fmincon;
invalid = 0;
try
    l2ls_learn_basis_dual([NaN 0], ones(2), 1);
catch err
    assert(strcmp(err.identifier, 'TSSM:DictionaryInput')); invalid = invalid + 1;
end
try
    l2ls_learn_basis_dual(eye(2), eye(2), -1);
catch err
    assert(strcmp(err.identifier, 'TSSM:DictionaryRadius')); invalid = invalid + 1;
end
try
    l2ls_learn_basis_dual(eye(2), eye(2), 1, ones(3));
catch err
    assert(strcmp(err.identifier, 'TSSM:DictionaryInitial')); invalid = invalid + 1;
end
assert(invalid == 3);
save('-mat7-binary', 'basis_results.mat', 'solutions', 'methods', 'residuals', 'invalid');
end

function restore_session(oldpath, oldpwd)
path(oldpath); cd(oldpwd);
end
