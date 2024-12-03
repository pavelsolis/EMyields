function parest = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS)
% VARS2PAREST Transform variables into a vector of parmeters
% Parameters vectorized in parest: PhiP;cSgm;lmbd1;lmbd0;mu_xP;rho1;rho0;sgmY;sgmS

% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
parest = [PhiP(:);cSgm(:);lmbd1(:);lmbd0(:);mu_xP(:);rho1(:);rho0;sgmY];
if nargin == 9
    parest = [parest;sgmS];
end