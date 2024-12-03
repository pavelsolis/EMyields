function [ylds_Q,ylds_P,termprm,params] = estimation_jsz(ylds,matsin,matsout,dt,p)
% ESTIMATION_JSZ Estimate affine term structure model using JSZ normalization
% See Joslin, Singleton & Zhu (2011) 
% 
%	INPUTS
% ylds    - bond yields (rows: obs, cols: maturities)
% matsin  - bond maturities (in years) in the data
% matsout - bond maturities (in years) to be reported
% dt      - length of period in years (eg. 1/12 for monthly data)
% p       - number of pricing factors
%
%	OUTPUT
% ylds_Q  - estimated yields under Q measure
% ylds_P  - estimated yields under P measure
% termprm - estimated term premia
% params  - estimated parameters
%
% m-files called: sample_estimation_fun, jszLLK_KF, loadings
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
nobs = size(ylds,1);                                                        % number of observations
Ip   = eye(p);                                                              % identity matrix
W    = pca(ylds,'NumComponents',p);                                         % W': N*length(mats);

% Estimate parameters via JSZ normalization (use yields only)
[llks,AcP,BcP,AX,BX,kinfQ,K0P_cP,K1P_cP,sigma_e,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP, ...
    llkP,llkQ,K0Q_X,K1Q_X,rho0_X,rho1_X,Sigma_cP] = sample_estimation_fun(W',ylds,matsin,dt,false);
[llk,AcP,BcP,AX,BX,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP,yields_filtered,cP_filtered] = ...
    jszLLK_KF(ylds,W',K1Q_X,kinfQ,Sigma_cP,matsin,dt,K0P_cP,K1P_cP,sigma_e);

% Estimate the term premium
[AnQ,BnQ] = loadings(matsout,K0Q_cP,K1Q_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
[AnP,BnP] = loadings(matsout,K0P_cP,K1P_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
% ylds_Q  = ones(nobs,1)*AcP + cP_filtered*BcP;                             % same as yields_filtered
ylds_Q    = ones(nobs,1)*AnQ + cP_filtered*BnQ;                             % same cP for ylds_Q and ylds_P
ylds_P    = ones(nobs,1)*AnP + cP_filtered*BnP;
termprm   = ylds_Q - ylds_P;                                                % in decimals

% Report parameters
mu_xP = K0P_cP;
PhiP  = K1P_cP + Ip;
Hcov  = Sigma_cP;
x00   = (Ip - PhiP)\mu_xP;                                                  % p*1
P00   = reshape((eye(p^2)-kron(PhiP,PhiP))\reshape(Hcov,p^2,1),p,p);        % p*p
if any(isnan(P00),'all') || any(isinf(P00),'all') || any(~isreal(eig(P00))) || any(eig(P00) < 0)
    x00 = zeros(p,1);       P00 = Ip;                                       % in case state is non-stationary
end
mu_xQ = K0Q_cP; PhiQ  = K1Q_cP + Ip;    cSgm = chol(Hcov,'lower');
params.mu_xP = mu_xP;                   params.PhiP  = PhiP;
params.mu_xQ = mu_xQ;                   params.PhiQ  = PhiQ;
params.rho0  = rho0_cP*dt;              params.rho1  = rho1_cP*dt;          % rho0 & rho1 in per period units
params.lmbd0 = cSgm\(mu_xP - mu_xQ);    params.lmbd1 = cSgm\(PhiP  - PhiQ); % implied lambda0 & lambda1
params.sgmY  = sigma_e;                 params.sgmS  = sigma_e;
params.cSgm  = cSgm;                    params.xs    = cP_filtered;
params.x00   = x00;                     params.P00   = P00;