function transmat = mk_leftright_transmat(Q, p)
% MK_LEFTRIGHT_TRANSMAT Q = num states, p = prob on (i,i), 1-p on (i,i+1)
% function transmat = mk_leftright_transmat(Q, p)

% first order transition matrix
transmat = p*diag(ones(Q,1)) + (1-p)*diag(ones(Q-1,1),1);

% second order transition matrix
% transmat = p*diag(ones(Q,1)) + (1-p/2)*diag(ones(Q-1,1),1)...
            +(1-p/2)*diag(ones(Q-2,1),2);       
transmat(Q,Q)=1;
