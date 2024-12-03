function [llk,llks] = llkfns(parest,y,x00,P00,matsY,matsS,dt)
% LLKFN Return the overall negative log-likelihood and individual negative 
% log-likelihoods computed by the Kalman filter

% m-files called: atsm_params, Kfs
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt);                 % get model parameters
[llk,~,~,~,~,~,~,~,~,~,~,~,~,llks] = Kfs(y,mu_x,mu_y,Phi,A,Q,R,x00,P00);    % calculate the log-likelihoods
llk  = -llk;                                                                % return minus log-likelihood
llks = -llks;