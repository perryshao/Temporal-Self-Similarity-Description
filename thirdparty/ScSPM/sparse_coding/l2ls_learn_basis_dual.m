function [B, info] = l2ls_learn_basis_dual(X, S, l2norm, Binit)
%L2LS_LEARN_BASIS_DUAL Constrained least-squares dictionary update.
%   B minimizes 0.5*||X-B*S||_F^2 subject to ||B(:,j)||_2 <= L2NORM.
%   BINIT is an optional feasible warm start; unused atoms retain its projected
%   values because they do not affect the fixed-code objective. Without BINIT
%   they are zero. [B, INFO] also reports the accepted solver and its residual.
%
%   Well-conditioned active codes use the original Lagrange-dual formulation.
%   Rank-deficient codes, missing FMINCON, or an uncertified dual result use
%   exact cyclic block minimization of the same constrained primal objective.
%   No ridge penalty is added. Every returned result is feasible and passes a
%   scaled projected-gradient stationarity check; nonconvergence raises an error.
%
%   Original dual algorithm: Honglak Lee, Alexis Battle, Rajat Raina and
%   Andrew Y. Ng, "Efficient Sparse Coding Algorithms", NIPS 19 (2007).
%   Original implementation by Honglak Lee, copyright 2007 the above authors.
%   Local robustness changes: singular-code handling and solver certification.

if ~isnumeric(X) || ~isreal(X) || ~ismatrix(X) || ...
        ~isnumeric(S) || ~isreal(S) || ~ismatrix(S) || ...
        size(X, 2) ~= size(S, 2) || ...
        any(~isfinite(X(:))) || any(~isfinite(S(:)))
    error('TSSM:DictionaryInput', 'X and S must be finite real matrices with equal sample counts.');
end
if ~isnumeric(l2norm) || ~isreal(l2norm) || ~isscalar(l2norm) || ...
        ~isfinite(l2norm) || l2norm < 0
    error('TSSM:DictionaryRadius', 'The atom radius must be a finite nonnegative scalar.');
end
X = double(X);
S = double(S);
[d, ~] = size(X);
k = size(S, 1);
if nargin < 4 || isempty(Binit)
    B = zeros(d, k);
else
    if ~isnumeric(Binit) || ~isreal(Binit) || ...
            ~isequal(size(Binit), [d k]) || any(~isfinite(Binit(:)))
        error('TSSM:DictionaryInitial', 'Binit must be a finite real feature-by-atom matrix.');
    end
    B = project_atoms(double(Binit), l2norm);
end
G = full(S*S');
Q = full(X*S');
if any(~isfinite(G(:))) || any(~isfinite(Q(:)))
    error('TSSM:DictionaryOverflow', 'Dictionary sufficient statistics overflowed.');
end
active = find(diag(G) > 0);
info = struct('method', 'inactive', 'iterations', 0, 'dual_exitflag', NaN, ...
    'projected_gradient_residual', 0, 'objective', 0, 'active_atoms', numel(active));
if l2norm == 0
    B(:) = 0;
elseif ~isempty(active)
    A = G(active, active);
    C = Q(:, active);
    initial = B(:, active);
    tolerance = 1e-9;
    % An infinity-norm bound is a safe Lipschitz constant for the symmetric A.
    lipschitz = norm(A, inf);
    accepted = false;
    if rcond(A) > 1e-10 && exist('fmincon', 'file') ~= 0
        try
            if exist('OCTAVE_VERSION', 'builtin')
                options = optimset('GradObj', 'on', 'HessianFcn', 'objective', ...
                    'Display', 'off', 'TolFun', 1e-10, 'MaxIter', 1000);
            else
                options = optimset('GradObj', 'on', 'Hessian', 'on', ...
                    'Display', 'off', 'TolFun', 1e-10, 'MaxIter', 1000);
            end
            lambda0 = max(1, mean(diag(A)))*ones(numel(active), 1);
            [lambda, ~, flag] = fmincon(@(v) dual_objective(v, A, C, l2norm), ...
                lambda0, [], [], [], [], zeros(size(lambda0)), [], [], options);
            info.dual_exitflag = flag;
            [R, failed] = chol(A + diag(lambda));
            if flag > 0 && failed == 0 && all(isfinite(lambda)) && all(lambda >= 0)
                candidate = (R \ (R' \ C'))';
                % Only remove floating-point-sized feasibility error, then
                % certify the projected candidate rather than trusting exitflag.
                if all(isfinite(candidate(:))) && ...
                        max(sqrt(sum(candidate.^2, 1))) <= l2norm*(1 + 1e-8)
                    candidate = project_atoms(candidate, l2norm);
                    accepted = residual(candidate, A, C, l2norm, lipschitz) <= tolerance;
                    if accepted
                        B(:, active) = candidate;
                        info.method = 'dual';
                    end
                end
            end
        catch
            % A solver failure cannot authorize returning an invalid dictionary.
            % The independently certified primal solve below must still succeed.
            accepted = false;
        end
    end
    if ~accepted
        candidate = initial;
        converged = false;
        for sweep = 0:10000
            gradient = candidate*A - C;
            if residual(candidate, A, C, l2norm, lipschitz) <= tolerance
                converged = true;
                break;
            end
            if sweep == 10000, break; end
            for j = 1:numel(active)
                % Exact minimizer over this atom's closed Euclidean ball.
                atom = project_atoms(candidate(:, j) - gradient(:, j)/A(j, j), l2norm);
                delta = atom - candidate(:, j);
                candidate(:, j) = atom;
                gradient = gradient + delta*A(j, :);
            end
        end
        if ~converged
            error('TSSM:DictionaryConvergence', 'Constrained dictionary update did not converge.');
        end
        B(:, active) = candidate;
        info.method = 'coordinate';
        info.iterations = sweep;
    end
    info.projected_gradient_residual = residual(B(:, active), A, C, l2norm, lipschitz);
    % The fixed-code fit must not increase relative to a supplied warm start.
    change = B(:, active) - initial;
    objective_change = sum(sum(change.*(initial*A-C))) + ...
        0.5*sum(sum((change*A).*change));
    if objective_change > 1e-8*max(1, norm(C, 'fro')*norm(initial, 'fro'))
        error('TSSM:DictionaryDescent', 'Dictionary update increased the fixed-code objective.');
    end
end
if any(~isfinite(B(:))) || any(sqrt(sum(B.^2, 1)) > l2norm*(1 + 1e-12))
    error('TSSM:DictionaryFeasibility', 'Dictionary update violated an atom constraint.');
end
fit = X - B*S;
info.objective = 0.5*sum(fit(:).^2);
if ~isfinite(info.objective)
    error('TSSM:DictionaryOverflow', 'Dictionary objective overflowed.');
end
end

function [f, g, H] = dual_objective(lambda, A, C, radius)
% Cholesky solves avoid explicitly inverting a singular Gram matrix.
R = chol(A + diag(lambda));
B = (R \ (R' \ C'))';
f = sum(sum(C.*B)) + radius^2*sum(lambda);
g = radius^2 - sum(B.^2, 1)';
if nargout > 2
    inverse = R \ (R' \ eye(size(A)));
    H = 2*((B'*B).*inverse);
end
end

function B = project_atoms(B, radius)
for j = 1:size(B, 2)
    length = norm(B(:, j));
    if length > radius
        B(:, j) = B(:, j)*(radius/length);
    end
end
end

function value = residual(B, A, C, radius, lipschitz)
gradient = B*A - C;
mapping = lipschitz*(B - project_atoms(B-gradient/lipschitz, radius));
scale = max([1, norm(C, 'fro'), lipschitz*norm(B, 'fro')]);
value = norm(mapping, 'fro')/scale;
end
