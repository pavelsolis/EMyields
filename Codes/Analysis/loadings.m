function [Ay,By,Ap,Bp] = loadings(mats_years,mu,Phi,Hcov,rho0dt,rho1dt,dt)
% LOADINGS Compute loadings for yields and log-prices for different maturities
% 
% INPUTS
% mats_years : 1*q, where q is the number of maturities
% mu         : p*1, where p is the number of factors or state variables
% Phi        : p*p
% Hcov       : p*p
% rho0dt     : scalar
% rho1dt     : p*1
% dt         : length of period in years (eg. dt = 1/12 for monthly data)
% 
% OUTPUT
% Ay, A      : 1*q
% By, B      : p*q
% 
% ASSUMPTIONS
% T        : number of observations
% X(t)     : p*1
% r(t)     : scalar
% yields   : 1*q
% Important: r(t) and yields are decimals
% 
% The dynamics of the state variables are given by
%       X(t+1) = mu + Phi*X(t) + eps(t+1), Cov(eps(t+1)) = Hcov
% The dynamics for the one-period (dt) discount rate are given by
%       r(t)   = rho0dt + rho1dt'*X(t); rho0dt and rho1dt are in per period units (e.g. rho0dt = rho0*dt)
% Note: yields = Ay + X(t)'*By but if X(t) is T*p, yields are T*q: yields = ones(T,1)*Ay + X(t)*By
% 
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
mats_months = round(mats_years/dt);
p  = length(mu);    maxM = max(mats_months);
A  = nan(1,maxM);	B  = nan(p,maxM);
An = 0;             Bn = zeros(p,1);                        % initial values

for k  = 1:maxM
    An = -rho0dt + An + mu'*Bn + 0.5*Bn'*Hcov*Bn;
    Bn = -rho1dt + Phi'*Bn;
    
    A(1,k) = An;
    B(:,k) = Bn;
end

Ap = A(1,mats_months);  Bp = B(:,mats_months);          	% loadings for log-prices
Ay = -Ap./mats_years; 	By = -Bp./mats_years;           	% loadings for yields (annualized)