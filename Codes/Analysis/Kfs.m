function [llk,xp,Pp,xf,Pf,xs,Ps,x0n,P0n,S11,S10,S00,Syx,llks] = Kfs(y,mu_x,mu_y,Phi,A,Q,R,xf0,Pf0)
% KFS Implement the missing-data versions of the Kalman filter and smoother
% Notation from Time Series Analysis and Its Applications by Shumway & Stoffer
% 
%               Dynamic linear model with time-invariant coefficients
% transition  : x_t = mu_x + Phi*x_{t-1} + w_t, cov(w) = Q
% measurement : y_t = mu_y +   A*x_t     + v_t, cov(v) = R
% dimensions  : p states, q measurements, n observations
% 
% INPUTS
% y    : q*n matrix of measurements
% mu_x : p*1 transition intercept
% mu_y : q*1 measurement intercept
% Phi  : p*p state transition matrix
% A    : q*p measurement matrix
% Q    : p*p state error covariance matrix
% R    : q*q measurement error covariance matrix
% xf0  : p*1 initial state mean vector (optional)
% Pf0  : p*p initial state covariance matrix (optional)
%
% OUTPUT
% llk  : 1*1   log-likelihood (includes constant)
% xp   : p*n   matrix of predicted mean of state,       stores Exp[x(t)|y(t-1)]
% Pp   : p*p*n matrix of predicted covariance of state, stores Var[x(t)|y(t-1)]
% xf   : p*n   matrix of filtered mean of state,        stores Exp[x(t)|y(t)]
% Pf   : p*p*n matrix of filtered covariance of state,  stores Var[x(t)|y(t)]
% xs   : p*n   matrix of smoothed mean of state,        stores Exp[x(t)|y(n)]
% Ps   : p*p*n matrix of smoothed covariance of state,  stores Var[x(t)|y(n)]
% x0n  : p*1   (smoothed) estimate of initial state mean
% P0n  : p*p   (smoothed) estimate of initial state covariance matrix
% S11  : (p+1)*(p+1) smoother using current xs and Ps (accounts for intercept)
% S10  : p*(p+1)     smoother using current and past xs and Pslag (accounts for intercept)
% S00  : (p+1)*(p+1) smoother using past xs and Ps (accounts for intercept)
% Syx  : q*(p+1)     smoother using y and current xs (accounts for intercept)
% llks : n*1   log-likelihoods

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
% Determine dimensions
p     = size(Phi,1);
[q,n] = size(y);
if  n < q; warning('The number of columns in y should equal the sample size.'); end

% Pre-allocate space
xp  = nan(p,n);     Pp  = nan(p,p,n);       Ip    = eye(p);
xf  = nan(p,n);     Pf  = nan(p,p,n);       J     = nan(p,p,n);	
xs  = nan(p,n);     Ps  = nan(p,p,n);       Pslag = nan(p,p,n);

% Initialize recursion with unconditional moments assuming state is stationary x0 ~ N(xf0,Pf0)
if nargin < 8
    xf0 = (Ip - Phi)\mu_x;                                         	% p*1
    Pf0 = reshape((eye(p^2)-kron(Phi,Phi))\reshape(Q,p^2,1),p,p);   % p*p
    if any(isnan(Pf0),'all') || any(isinf(Pf0),'all') || any(~isreal(eig(Pf0))) || any(eig(Pf0) < 0)
        xf0 = zeros(p,1);       Pf0 = Ip;                           % in case the state is non-stationary
    end
end

% Deal with missing observations
miss = isnan(y);                                                    % keep record of missing data
yt   = y;   yt(miss) = 0;                                         	% replace missing values w/ zeros

%% Estimation: Kalman filter
llk  = 0;
llks = nan(n,1);
for t = 1:n
    % Predicting equations
    if t == 1
        xp(:,t)   = Phi*xf0 + mu_x;
        Pp(:,:,t) = Phi*Pf0*Phi' + Q;
    else
        xp(:,t)   = Phi*xf(:,t-1) + mu_x;
        Pp(:,:,t) = Phi*Pf(:,:,t-1)*Phi' + Q;
    end
    
    At = A; At(miss(:,t),:) = 0;                                 	% account for missing observations
    u  = yt(:,t) - (mu_y + At*xp(:,t));                             % innovation
    U  = At*Pp(:,:,t)*At' + R;                                      % innovation covariance
    K  = Pp(:,:,t)*At'/U;                                           % optimal Kalman gain
    
    % Updating equations
    xf(:,t)   = xp(:,t) + K*u;
    Pf(:,:,t) = (Ip - K*At)*Pp(:,:,t);
    
    % Log-likelihood
    term3   = max(u'*(U\u),0);                                    	% in case V is non-PSD
    llks(t) = - 0.5*(q*log(2*pi) + log(det(U)) + term3);
    llk     = llk + llks(t);
end

%% Inference: Kalman smoother
for t = n:-1:1
    if t == n
        xs(:,t)   = xf(:,n);
        Ps(:,:,t) = Pf(:,:,n);
        continue
    end
    
    J(:,:,t+1) = Pf(:,:,t)*Phi'/Pp(:,:,t+1);
    xs(:,t)    = xf(:,t) + J(:,:,t+1)*(xs(:,t+1) - xp(:,t+1));
    Ps(:,:,t)  = Pf(:,:,t) + J(:,:,t+1)*(Ps(:,:,t+1) - Pp(:,:,t+1))*J(:,:,t+1)';
    
    if t == 1
        J(:,:,t) = Pf0*Phi'/Pp(:,:,t);
        x0n      = xf0 + J(:,:,t)*(xs(:,t) - xp(:,t));
        P0n      = Pf0 + J(:,:,t)*(Ps(:,:,t) - Pp(:,:,t))*J(:,:,t)';
    end
end

% Lag-one covariance smoother
for t = n:-1:1
    if t == n
        Pslag(:,:,t) = (Ip - K*At)*Phi*Pf(:,:,t-1);                 % note: K = Kn, At = An
    else
        Pslag(:,:,t) = Pf(:,:,t)*J(:,:,t)' + J(:,:,t+1)*(Pslag(:,:,t+1) - Phi*Pf(:,:,t))*J(:,:,t)';
    end
end

% Smoothers (account for a constant)
Xs  = [ones(1,n+1); x0n xs];                                        % (p+1)*(n+1) includes constant, t = 0:n

    % t = 1:n
Syx = yt*Xs(:,2:end)';                                              % q*n x n*(p+1) = q*(p+1) exclude t = 0
S11 = Xs(:,2:end)*Xs(:,2:end)';                                 	% (p+1)*(p+1) exclude t = 0
S11(2:p+1,2:p+1) = S11(2:p+1,2:p+1) + sum(Ps,3);                    % exclude constant zero cov, sum Ps over n

    % t = 0:n-1
S00 = Xs(:,1:end-1)*Xs(:,1:end-1)';                                 % (p+1)*(p+1) exclude t = n
S00(2:p+1,2:p+1) = S00(2:p+1,2:p+1) + P0n + sum(Ps,3) - Ps(:,:,end);% excl. constant, add t = 0, remove t = n

    % t = 0:n (t = 1:n and t = 0:n-1)
S10 = Xs(2:end,2:end)*Xs(:,1:end-1)';                               % p*n x n*(p+1) = p*(p+1)
S10(:,2:end) = S10(:,2:end) + sum(Pslag,3);                         % excl. constant, sum Pslag over all t

% Smoothers w/o a constant
% Syx = Syx(:,2:p+1);     S11 = S11(2:p+1,2:p+1);
% S10 = S10(:,2:p+1);     S00 = S00(2:p+1,2:p+1);