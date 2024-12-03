function [mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt)
% ATSM_PARAMS Define parameters for affine term structure model
% parest - vectorized parameters: PhiP;Sgm;lmbd1;lmbd0;mu_xP;rho1;rho0;sgmY;sgmS
% matsY  - maturities of yields in years
% matsS  - maturities of surveys in years

% m-files called: parest2vars, loadings
% Pavel Solís (pavel.solis@gmail.com), August 2020
%%
% Identify number of yields and surveys
q1 = length(matsY);                                             % q = q1 + q2
q2 = length(matsS);

[PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS] = parest2vars(parest);

% Loadings for yields
Hcov  = cSgm*cSgm';
mu_xQ = mu_xP - chol(Hcov,'lower')*lmbd0;
PhiQ  = PhiP  - chol(Hcov,'lower')*lmbd1;
[AnQ,BnQ] = loadings(matsY,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);      	% AnQ: 1*q1, BnQ: p*q1

if ~isempty(matsS)                                              % applies forward rate to last tenor
    % Define start and ending dates of forward rate
    nmatsS = length(matsS);
    matM   = max(matsS);                                        % ending date of forward rate
    if nmatsS == 1                                              % starting date of forward rate
        matN  = 5;                                              % assumes max(matsS) = 10
        matsS = [matN matM];                                    % ensure matsS has at least 5Y and 10Y
    else
        matN  = matsS(end-1);                                 	% starting date of forward rate
    end
    
    % Loadings for survey yields and forward rate for last tenor
    [AS,BS] = loadings(matsS,mu_xP,PhiP,zeros(size(Hcov)),rho0,rho1,dt);
    Am  = AS(end);      Bm = BS(:,end);                     	% loadings for last maturity
    An  = AS(end-1);	Bn = BS(:,end-1);
    Anm = (matM*Am - matN*An)/(matM - matN);                    % loadings for forward rate
    Bnm = (matM*Bm - matN*Bn)/(matM - matN);
    if nmatsS == 1                                              % replace loadings for last tenor
        AnS = Anm;
        BnS = Bnm;
    else
        AnS = [AS(1:end-1) Anm];
        BnS = [BS(:,1:end-1) Bnm];
    end
    
    % Loadings for bond yields and survey yields
    AnQ = [AnQ,AnS];                                            % 1*q = [1*q1 1*q2]
    BnQ = [BnQ,BnS];                                        	% p*q = [p*q1 p*q2]
end

% Parameters in state space form
mu_x = mu_xP;                                                   % p*1
mu_y = AnQ';                                                    % q*1
Phi  = PhiP;                                                    % p*p
A    = BnQ';                                                    % q*p
Q    = Hcov;                                                    % p*p
if     isempty(sgmY) && isempty(sgmS)                           % q*q
    R = zeros(q1);                                              % this case causes problems
elseif isempty(sgmS)
    sgmS = 0.0075;                                              % same as in Kim & Orphanides (2012)
    R = diag([repmat(sgmY^2,q1,1); repmat(sgmS^2,q2,1)]);       % fixed sgmS case
    % R = diag(repmat(sgmY^2,q1,1));                            % yields only case
else
    R = diag([repmat(sgmY^2,q1,1); repmat(sgmS^2,q2,1)]);
end