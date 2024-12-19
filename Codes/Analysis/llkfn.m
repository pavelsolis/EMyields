function llk = llkfn(parest,y,x00,P00,matsY,matsS,dt)
% LLKFN Return the negative log-likelihood computed by the Kalman filter

% m-files called: atsm_params, Kfs
% Pavel Solís (pavel.solis@gmail.com)
%%
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt);	                % get model parameters
llk = Kfs(y,mu_x,mu_y,Phi,A,Q,R,x00,P00);                                   % calculate the log-likelihood
llk = -llk;                                                                 % return minus log-likelihood