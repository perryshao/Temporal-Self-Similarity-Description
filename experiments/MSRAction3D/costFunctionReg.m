function [f, df, ddf] = costFunctionReg(theta, X, Y, lambda, C, jointNum, modulaNum, initTheta)
%COSTFUNCTIONREG  Cost and gradient of the group-sparse multi-output regression.
%   [F, DF] = COSTFUNCTIONREG(THETA, X, Y, LAMBDA, C, JOINTNUM, MODULANUM,
%   INITTHETA) returns the loss ||X'*W - Y|| of the D x C weight matrix
%   W = reshape(THETA, D, C) plus three penalties weighted by LAMBDA(1:3):
%   an L2,1 norm over the rows of W, a group norm over the JOINTNUM joint
%   groups and MODULANUM feature modalities, and ||THETA - INITTHETA||^2,
%   which keeps the solution near a previous one.  Also returns the gradient.
%   X is D x N, Y is N x C one-hot.  For use with MINIMIZE.
%
%   See also TRAINBINREGRESSION.

% cosFunctionReg.m This function returns the function value, partial derivatives
% and Hessian of the (general dimension) rosenbrock function, given by:
% C is the class number
% Initialize some useful values
% Y = NxC column vector
if nargout < 7
    initTheta = 0;
end
modalityNum = modulaNum;

%% Compute the costJ of a particular choice of theta
% compute cost costJ
% X = DxN matrix, J and M is the partition parameters over joints and feature modalities
D = size(X, 1); N = size(X, 2);
J = D/jointNum; M = J/modalityNum;
% theta = DxC column vector
theta = reshape(theta, D, C);
% costJ = single number
costJ = norm(X'*theta-Y);

costRegularizationTerm1 = sum(sqrt(sum(theta.^2, 2)));

tempJ = 0;
for j = 1:jointNum
    tempM = 0;
    for m = 1:modalityNum
        tempRegularTerm = theta((j-1)*J+1:j*J, :);
        tempM = tempM + sqrt(sum(tempRegularTerm((m-1)*M+1:m*M, :).^4, 1));
    end
    tempJ = tempJ+sqrt(tempM);
end
costRegularizationTerm2 = sum(tempJ);
clear tempRegularTerm;

costRegularizationTerm3 = norm(theta - initTheta)^2;
costJWithRegularization = costJ + lambda(1)*costRegularizationTerm1 + lambda(2)*costRegularizationTerm2...
                          + lambda(3)*costRegularizationTerm3;
% Compute the partial derivatives and set gradient to the partial
% derivatives of the cost w.r.t. each parameter in theta

%% compute the gradient
gradient = 2*X*(X'*theta-Y);

% ddgradient = sparse(D*C,D*C);
% subD = floor(D/8);subN = floor(N/8);
% XX = sparse(D,D);
% for i = 1:8
%     for j = 1:9
%         if j < 9
%             XX((i-1)*subD+1:i*subD,(i-1)*subD+1:i*subD) = X((i-1)*subD+1:i*subD,(j-1)*subN+1:j*subN)*(X((i-1)*subD+1:i*subD,(j-1)*subN+1:j*subN))';
%         else
%             XX((i-1)*subD+1:i*subD,(i-1)*subD+1:i*subD) = X((i-1)*subD+1:i*subD,(j-1)*subN+1:end)*(X((i-1)*subD+1:i*subD,(j-1)*subN+1:end))';
%         end
%     end
% end
% clear X;
% for i = 1:C
%     ddgradient((i-1)*D+1:i*D,(i-1)*D+1:i*D) = XX;
% end
% clear XX;
clear X;

epsilon = 10e-8; % to avoid inf when divided by zero
gradientRegularizationTerm1 = repmat((sum(theta.^2, 2)+epsilon).^(-1/2), 1, C).*theta;

% tic;
% ddgradientRegularizationTerm1 = 2;
% gradientRegularizationTerm2 = zeros(D,C);
% ddgradientRegularizationTerm2 = zeros(D*C,D*C);
% for c = 1:C
%     for j = 1:jointNum
%         tempGrad = 0;
%         startPosJoint = (j-1)*J+1;
%         for m = 1:modalityNum
%             tempModu = theta(startPosJoint+(m-1)*M:startPosJoint+m*M-1,c);
%             tempGrad = tempGrad + sqrt(sum(tempModu.^4));
%         end
%         for m = 1:modalityNum
%             tempModu = theta(startPosJoint+(m-1)*M:startPosJoint+m*M-1,c);
%             startPosM = startPosJoint+(m-1)*M;
%             for i = 1:M
%                 gradientRegularizationTerm2(startPosM+i-1,c) = (tempModu(i)^3)/(sqrt(sum(tempModu.^4)+epsilon)*sqrt(tempGrad+epsilon));
% %                 for ii = 1:M
% %                     if ii == i
% %                         ddgradientRegularizationTerm2((c-1)*C+startPosM+i-1,(c-1)*C+startPosM+ii-1) = -tempGrad^(-3/2)*(sum(tempModu.^4)^(-2))*tempModu(i)^6 ...
% %                         +3*tempGrad^(-1/2)*(sum(tempModu.^4))^(-1/2)*tempModu(i)^2+(-2)*tempGrad^(-1/2)*(sum(tempModu.^4))^(-3/2)*tempModu(i)^6;
% %                     else
% %                         ddgradientRegularizationTerm2((c-1)*C+startPosM+i-1,(c-1)*C+startPosM+ii-1) = -tempGrad^(-3/2)*(sum(tempModu.^4)^(-2))*tempModu(i)^3 ...
% %                         *tempModu(ii)^3+(-2)*tempGrad^(-1/2)*(sum(tempModu.^4))^(-3/2)*tempModu(i)^3*tempModu(ii)^3;
% %                     end
% %                 end
% %                 for mm = 1:modalityNum
% %                     if m ~= mm
% %                         tempOtherModu = theta(startPosJoint+(mm-1)*M:startPosJoint+mm*M-1,c);
% %                         for ii = 1:M
% %                         ddgradientRegularizationTerm2((c-1)*C+startPosM+i-1,(c-1)*C+startPosJoint+(mm-1)*M+ii) = -tempGrad^(-3/2)*(sum(tempOtherModu.^4))^(-3/2)...
% %                         *(sum(tempModu.^4))^(-1/2)*tempModu(i)^3*tempOtherModu(ii)^3;
% %                         end
% %                     end
% %                 end
%             end
%         end
%     end
% end
% toc;

tic;
gradientRegularizationTerm2 = zeros(D, C);
% ddgradientRegularizationTerm2 = zeros(D*C,D*C);
for j = 1:jointNum
    tempGrad = 0;
    startPosJoint = (j-1)*J+1;
    for m = 1:modalityNum
        tempModu = theta(startPosJoint+(m-1)*M:startPosJoint+m*M-1, :);
        tempGrad = tempGrad + sqrt(sum(tempModu.^4, 1));
    end
    for m = 1:modalityNum
        tempModu = theta(startPosJoint+(m-1)*M:startPosJoint+m*M-1, :);
        startPosM = startPosJoint+(m-1)*M;
        for i = 1:M
            gradientRegularizationTerm2(startPosM+i-1, :) = (tempModu(i, :).^3)./(sqrt(sum(tempModu.^4, 1)+epsilon).*sqrt(tempGrad+epsilon));
        end
    end
end
toc;

gradientRegularizationTerm3 = 2*(theta - initTheta);
% ddgradientRegularizationTerm3 = 2;
% where [0; theta(2:end)] is the same column vector theta beginning with a value of '0' at index
% 1 and then containing the old values from index 2:end of theta

% gradient = DXC column vector
% gradientRegularizationTerm1(isnan(gradientRegularizationTerm1)) = 0;% to eliminate the NaN
% gradientRegularizationTerm2(isnan(gradientRegularizationTerm2)) = 0;% to eliminate the NaN
% gradientRegularizationTerm3(isnan(gradientRegularizationTerm3)) = 0;% to eliminate the NaN

gradient = gradient + lambda(1)*gradientRegularizationTerm1 + lambda(2)*gradientRegularizationTerm2...
                             + lambda(3)*gradientRegularizationTerm3;
% gradient = (DXC)x(DXC) column vector
% ddgradient = ddgradient + lambda(1)*ddgradientRegularizationTerm1 + lambda(2)*ddgradientRegularizationTerm2 + ...
%             lambda(3)*ddgradientRegularizationTerm3;

f = costJWithRegularization;
gradient = reshape(gradient, D*C, 1); % vec(W)

if nargout > 1
    df = gradient;
end

if nargout > 2
    ddf = ddgradient;
end
