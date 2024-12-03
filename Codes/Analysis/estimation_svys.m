function [ylds_Q,ylds_P,termprm,params] = estimation_svys(yldsvy,matsY,matsS,matsout,dt,params0,sgmSfree,simplex)
% ESTIMATION_SVYS Estimate affine term structure model using yields and surveys
% 
%	INPUTS
% yldsvy   - bond yields and survey forecasts (rows: obs, cols: maturities)
% matsY    - maturities of yields in years
% matsS    - maturities of surveys in years
% matsout  - bond maturities (in years) to be reported
% dt       - length of period in years (eg. 1/12 for monthly data)
% params0  - initial values of parameters
% sgmSfree - logical for whether to estimate sgmS (o/w fixed at 75 bp)
% simplex  - logical for whether to estimate using fminsearch (default) or fminunc
%
%	OUTPUT
% ylds_Q  - estimated yields under Q measure
% ylds_P  - estimated yields under P measure
% termprm - estimated term premia
% params  - estimated parameters

% m-files called: vars2parest, llkfn, atsm_params, Kfs, parest2vars, loadings
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
if nargin < 8; simplex = true; end                                          % set fminsearch as default solver
nobs   = size(yldsvy,1);                                                    % number of observations
x00    = params0.x00;
P00    = params0.P00;
niter  = 2000;
exflag = 0;

% Estimate parameters
while exflag == 0
    if niter == 2000                                                        % initial values from input
        if sgmSfree
            par0 = vars2parest(params0.PhiP,params0.cSgm,params0.lmbd1,params0.lmbd0,...
                               params0.mu_xP,params0.rho1,params0.rho0,params0.sgmY,params0.sgmS);
        else                                                                % sgmS fixed in atsm_params
            par0 = vars2parest(params0.PhiP,params0.cSgm,params0.lmbd1,params0.lmbd0,...
                               params0.mu_xP,params0.rho1,params0.rho0,params0.sgmY);
        end
    else
        par0 = parest;                                                      % initial values from previous run
    end
    
    maxitr = length(par0)*niter;
    llkhan = @(x)llkfn(x,yldsvy',x00,P00,matsY,matsS,dt);                   % include vars in workspace
    if simplex
        options = optimset('MaxFunEvals',maxitr,'MaxIter',maxitr);
        [parest,fval,exflag] = fminsearch(llkhan,par0,options);
    else
        options = optimoptions('fminunc','Display','notify','Algorithm','quasi-newton','HessUpdate','bfgs',...
            'MaxFunctionEvaluations',maxitr,'MaxIter',maxitr,'UseParallel',false);
        [parest,fval,exflag,~,~,hessian] = fminunc(llkhan,par0,options);
    end
    if ~isinf(fval) && exflag == 0;   niter = niter + 1000;   end
end

% Estimate state vector based on estimated parameters
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt);                 % get model parameters
[~,~,~,~,~,xs,Ps] = Kfs(yldsvy',mu_x,mu_y,Phi,A,Q,R,x00,P00);               % smoothed state and its covariance
xs = xs';                                                                   % same dimensions as yldsvy 

% Estimate the term premium
[PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS] = parest2vars(parest);
Hcov      = cSgm*cSgm';             cSgm = chol(Hcov,'lower');              % crucial: cSgm from Cholesky
mu_xQ     = mu_xP - cSgm*lmbd0;     PhiQ = PhiP  - cSgm*lmbd1;
[AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
[AnP,BnP] = loadings(matsout,mu_xP,PhiP,Hcov,rho0,rho1,dt);
ylds_Q    = ones(nobs,1)*AnQ + xs*BnQ;
ylds_P    = ones(nobs,1)*AnP + xs*BnP;
termprm   = ylds_Q - ylds_P;        % = ones(nobs,1)*(AnQ - AnP) + xs*(BnQ - BnP);

% Report parameters
params.mu_xP = mu_xP;   params.PhiP  = PhiP;
params.mu_xQ = mu_xQ;   params.PhiQ  = PhiQ;
params.rho0  = rho0;    params.rho1  = rho1;
params.lmbd0 = lmbd0;   params.lmbd1 = lmbd1;
params.sgmY  = sgmY;    params.sgmS  = sgmS;
params.cSgm  = cSgm;    params.xs    = xs;
params.x00   = x00;     params.P00   = P00;
params.Ps    = Ps;      if ~simplex; params.Hess = hessian; end