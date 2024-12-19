function parest = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS)
% VARS2PAREST Vectorize variables into a vector of parmeters

% Pavel Solís (pavel.solis@gmail.com)
%%
parest = [PhiP(:);cSgm(:);lmbd1(:);lmbd0(:);mu_xP(:);rho1(:);rho0;sgmY];
if nargin == 9
    parest = [parest;sgmS];
end