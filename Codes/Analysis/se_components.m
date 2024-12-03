function S = se_components(S,matsout,currEM)
% SE_COMPONENTS Report standard errors for yield components due to uncertainty 
% in the estimated parameters. The state is assumed to be known with certainty

% m-files called: syncdatasets, vars2parest, parest2vars, loadings
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
dt      = 1/12;
epsilon = 1e-9;                                                             % 0.00001 basis point
ncntrs  = length(S);
nmats   = length(matsout);
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                                % field containing estimated parameters

for k0 = 1:ncntrs
    % Nominal yields
    fnameb = 'mn_blncd';                                                    % field containing *nominal* yields
    fltrnm = ismember(S(k0).(fnameb)(1,:),matsout);                         % same maturities as in matsout
    yldnom = S(k0).(fnameb)(2:end,fltrnm);                                  % yields in decimals
    nobsnm = size(yldnom,1);                                                % number of observations
    datesn = S(k0).(fnameb)(2:end,1);                                       % dates
    
    % Synthetic yields
    fnameb = 'ms_blncd';                                                    % field containing *synthetic* yields
    fltrsn = ismember(S(k0).(fnameb)(1,:),matsout);                         % same maturities as in matsout
    yldsyn = S(k0).(fnameb)(2:end,fltrsn);                                  % yields in decimals
    nobssn = size(yldsyn,1);                                                % number of observations
    datess = S(k0).(fnameb)(2:end,1);                                       % dates
    
    if ismember(S(k0).iso,currEM); nobs = nobssn; dates = datess; else; nobs = nobsnm; dates = datesn; end
    % nobs = nobsnm; dates = datesn;                                        % in case mny for EMs
    
    % Extract estimated parameters
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';
    mu_xP = S(k0).(fnameq).mu_xP;   PhiP  = S(k0).(fnameq).PhiP;
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
    lmbd0 = S(k0).(fnameq).lmbd0;   lmbd1 = S(k0).(fnameq).lmbd1;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    sgmY  = S(k0).(fnameq).sgmY;    sgmS  = S(k0).(fnameq).sgmS;
    xs    = S(k0).(fnameq).xs;      [rws,cls] = size(xs);
    if rws < cls; xs = xs'; end                                             % dimensions of xs & yields are equal
    Vasy  = S(k0).(fnameq).V1;                                              % Vasy = inv(-S(k0).(fnameq).Hess/nobssn)
    
    % Original decomposition
    [AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
    [AnP,BnP] = loadings(matsout,mu_xP,PhiP,Hcov,rho0,rho1,dt);
    yQold     = ones(nobs,1)*AnQ + xs*BnQ;
    yPold     = ones(nobs,1)*AnP + xs*BnP;
    tpold     = yQold - yPold;
    [~,crynom,cryQold] = syncdatasets([nan matsout; datesn yldnom],[nan matsout; dates yQold]);
    crold     = crynom(2:end,2:end) - cryQold(2:end,2:end);
    datesc    = crynom(2:end,1);
    nobscr    = length(datesc);
    
    % Delta method
    if isempty(sgmS) || (sgmY == sgmS)
        thetaold = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY);
    else
        thetaold = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS);
    end
    ntheta   = length(thetaold);
    JyQ      = nan(nmats,ntheta,nobs);
    JyP      = nan(nmats,ntheta,nobs);
    Jtp      = nan(nmats,ntheta,nobs);
    Jcr      = nan(nmats,ntheta,nobscr);
    for k1 = 1:ntheta
        % Subtract epsilon to theta
        thetanew     = thetaold;
        thetanew(k1) = thetanew(k1) - epsilon;

        % New decomposition (assumes no uncertainty in state)
        [PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0] = parest2vars(thetanew);    % sgmY and sgmS no needed
        Hcov      = cSgm*cSgm';             cSgm = chol(Hcov,'lower');      % crucial: cSgm from Cholesky
        mu_xQ     = mu_xP - cSgm*lmbd0;     PhiQ = PhiP  - cSgm*lmbd1;
        [AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
        [AnP,BnP] = loadings(matsout,mu_xP,PhiP,Hcov,rho0,rho1,dt);
        yQnew     = ones(nobs,1)*AnQ + xs*BnQ;
        yPnew     = ones(nobs,1)*AnP + xs*BnP;
        tpnew     = yQnew - yPnew;
        [~,crynom,cryQnew] = syncdatasets([nan matsout; datesn yldnom],[nan matsout; dates yQnew]);
        crnew     = crynom(2:end,2:end) - cryQnew(2:end,2:end);

        % Jacobians
        JyQ(:,k1,:) = (yQold - yQnew)'/epsilon;
        JyP(:,k1,:) = (yPold - yPnew)'/epsilon;
        Jtp(:,k1,:) = (tpold - tpnew)'/epsilon;
        Jcr(:,k1,:) = (crold - crnew)'/epsilon;
    end
    
    % Standard errors
    seyQ = nan(nobs,nmats);
    seyP = nan(nobs,nmats);
    setp = nan(nobs,nmats);
    secr = nan(nobscr,nmats);
    for k2 = 1:nobs
        seyQ(k2,:) = sqrt(diag(JyQ(:,:,k2)*Vasy*JyQ(:,:,k2)'/nobs));
        seyP(k2,:) = sqrt(diag(JyP(:,:,k2)*Vasy*JyP(:,:,k2)'/nobs));
        setp(k2,:) = sqrt(diag(Jtp(:,:,k2)*Vasy*Jtp(:,:,k2)'/nobs));
    end
    for k2 = 1:nobscr
        secr(k2,:) = sqrt(diag(Jcr(:,:,k2)*Vasy*Jcr(:,:,k2)'/nobscr));
    end
    
    S(k0).('bsl_yQ_se') = [nan matsout; dates seyQ];
    S(k0).('bsl_yP_se') = [nan matsout; dates seyP];
    S(k0).('bsl_tp_se') = [nan matsout; dates setp];
    S(k0).('bsl_cr_se') = [nan matsout; datesc secr];
end