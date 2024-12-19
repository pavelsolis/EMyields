function [PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS] = parest2vars(parest)
% PAREST2VARS Transform vector parest into the variables it contains

% Pavel Solís (pavel.solis@gmail.com)
%%
% Fix number of constants in parest to identify dimension of state vector
% ncons = 3;                                                  % number of constants in parest
% p     = (-3 + sqrt(9 - 12*(ncons - length(parest))))/6;     % #states (quadratic formula) given #parameters

% Fix dimension of state vector to identify number of constants in parest
p     = 3;
ncons = length(parest) - 3*p*(p+1);                         % 3 matrices, 3 vectors, the rest are constants

% Reshape to get constants, vectors and matrices
aux  = reshape(parest,ncons,[]);                            % rows = #constants, appropriate #columns
cons = aux(:,end);                                          % #constants in last column
aux  = reshape(aux(:,1:end-1),3*p,p+1);                     % 3p*(p+1) remaining elements
vecs = reshape(aux(:,end),p,3);                             % 3 vectors in parest stacked in last column
matx = reshape(aux(:,1:end-1),p,p,3);                       % 3 matrices in parest

% Recover variables
PhiP  = matx(:,:,1);
cSgm  = matx(:,:,2);
lmbd1 = matx(:,:,3);
lmbd0 = vecs(:,1);
mu_xP = vecs(:,2);
rho1  = vecs(:,3);
rho0  = cons(1);
sgmY  = []; 
sgmS  = [];
if ncons > 1;   sgmY = cons(2);     end                     % sgmY and sgmS only if included in parest
if ncons > 2;   sgmS = cons(3);     end