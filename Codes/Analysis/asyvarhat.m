function S = asyvarhat(S,currEM)
% ASYVARHAT Report estimates of the asymptotic covariance matrix

% m-files called: splityldssvys, llkfn, llkfns, vars2parest, hessian (from derivest folder)
% Pavel Solís (pavel.solis@gmail.com)
%%
addpath(genpath('derivest'))
dt      = 1/12;
epsilon = 1e-9;                                                             % 0.00001 basis point
ncntrs  = length(S);
fnameq  = 'bsl_pr';                                                         % field containing estimated parameters

for k0 = 1:ncntrs
    if ismember(S(k0).iso,currEM)
        fnamec = {'ms_ylds','msy_pr',};
    else
        fnamec = {'mn_ylds','mny_pr',};
    end
    % Split yields & surveys
    [~,~,ynsvys,matsY,matsS] = splityldssvys(S,k0,fnamec{1});
    nobs = size(ynsvys,1);
    
    % Extract estimated parameters
    cSgm  = S(k0).(fnameq).cSgm;
    mu_xP = S(k0).(fnameq).mu_xP;   PhiP  = S(k0).(fnameq).PhiP;
    lmbd0 = S(k0).(fnameq).lmbd0;   lmbd1 = S(k0).(fnameq).lmbd1;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    sgmY  = S(k0).(fnameq).sgmY;    sgmS  = S(k0).(fnameq).sgmS;
    x00   = S(k0).(fnamec{2}).x00;	P00   = S(k0).(fnamec{2}).P00;
    
    % Evaluate likelihood at the optimum
    if isempty(sgmS) || (sgmY == sgmS)
        theta0 = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY);
    else
        theta0 = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS);
    end
    ntheta = length(theta0);
    [llk0,llks0] = llkfns(theta0,ynsvys',x00,P00,matsY,matsS,dt);
    llk0 = -llk0;    llks0 = -llks0;
    
    % Compute the score and the Hessian using backward difference
    Score = nan(ntheta,nobs);
    Hess0 = nan(ntheta,ntheta);
    Hess1 = nan(ntheta,ntheta,nobs);
    for k1 = 1:ntheta
        theta1       = theta0;
        theta1(k1)   = theta1(k1) - epsilon;
        [llk1,llks1] = llkfns(theta1,ynsvys',x00,P00,matsY,matsS,dt);
        llk1 = -llk1;  llks1 = -llks1;
        Score(k1,:)  = (llks0 - llks1)'/epsilon;
        
        for k2 = 1:ntheta
            theta2     = theta0;
            theta2(k2) = theta2(k2) - epsilon;
            theta3     = theta2;
            theta3(k1) = theta3(k1) - epsilon;
            [llk2,llks2]   = llkfns(theta2,ynsvys',x00,P00,matsY,matsS,dt);
            [llk3,llks3]   = llkfns(theta3,ynsvys',x00,P00,matsY,matsS,dt);
            llk2 = -llk2;    llks2 = -llks2;    llk3 = -llk3;    llks3 = -llks3;
            Hess0(k1,k2)   = (llk0 - llk1 - llk2 + llk3)/(epsilon^2);
            Hess1(k1,k2,:) = (llks0 - llks1 - llks2 + llks3)'/(epsilon^2);
        end
    end
    
    % Robust numerical differentiation (warning: 2+ hours to run)
%     llkhan = @(x)llkfn(x,ynsvys',x00,P00,matsY,matsS,dt);
%     Hess2  = hessian(llkhan,theta0);
    
    % Sample Hessian estimator
    S(k0).(fnameq).V0 = inv(-Hess0/nobs);
    S(k0).(fnameq).V1 = inv(-sum(Hess1,3)/nobs);
%     S(k0).(fnameq).V2 = inv(-Hess2/nobs);
    
    % Outer product estimator
    dScore = Score - mean(Score,2);
    S(k0).(fnameq).V3 = inv(dScore*dScore'/nobs);
    
    Fisher = zeros(ntheta,ntheta);
    for k3 = 1:nobs
        aux = dScore(:,k3)*dScore(:,k3)';
        Fisher = Fisher + aux;
    end
    Fisher = Fisher/nobs;
    S(k0).(fnameq).V4 = inv(Fisher);
end