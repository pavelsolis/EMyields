function se_state(S,currEM)
% SE_STATE Report standard errors due to uncertainty in the state. The
% parameters are assumed to be known with certainty

% m-files called: splityldssvys, loadings, vars2parest, atsm_params, Kfs
% Pavel Solís (pavel.solis@gmail.com)
%%
dt      = 1/12; 
ncntrs  = length(S);
matsall = [0.25 0.5 1:10];
mtxmse  = nan(ncntrs,length(matsall),3);                                % yQ, yP, TP
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                            % field containing estimated parameters

for k0  = 1:ncntrs
    % Field names
    if ismember(S(k0).iso,currEM)
        prefix = 'ms'; 
    else
        prefix = 'mn'; 
    end
    fnamey = [prefix '_ylds'];      fname0 = [prefix 'y_pr'];
    
    % Split yields & surveys
    [~,~,ynsvys,matsY,matsS] = splityldssvys(S,k0,fnamey);
    nobs = size(ynsvys,1);                                              % number of observations
    
    % Extract estimated parameters
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';
    mu_xP = S(k0).(fnameq).mu_xP;   PhiP  = S(k0).(fnameq).PhiP;        % for parest
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;        % for BnQ
    lmbd0 = S(k0).(fnameq).lmbd0;   lmbd1 = S(k0).(fnameq).lmbd1;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    sgmY  = S(k0).(fnameq).sgmY;    sgmS  = S(k0).(fnameq).sgmS;
    x00   = S(k0).(fname0).x00;     P00   = S(k0).(fname0).P00;
    
    % Loadings using original maturities
    [~,BnQ] = loadings(matsall,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
    [~,BnP] = loadings(matsall,mu_xP,PhiP,Hcov,rho0,rho1,dt);
    
    % Covariance matrix of state vector based on estimated parameters
    parest = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS);
    [mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt);        	% get model parameters
    [~,~,~,~,~,~,Ps] = Kfs(ynsvys',mu_x,mu_y,Phi,A,Q,R,x00,P00);     	% smoothed state
    
    % Compute standrad errors across maturities for each period
    aux = nan(nobs,length(matsall),3);                                  % yQ, yP, TP
    for k1 = 1:nobs
        aux(k1,:,1) = sqrt(diag((BnQ'*Ps(:,:,k1)*BnQ)));                % yQ
        aux(k1,:,2) = sqrt(diag((BnP'*Ps(:,:,k1)*BnP)));                % yP
        aux(k1,:,3) = sqrt(diag(((BnQ-BnP)'*Ps(:,:,k1)*(BnQ-BnP))));	% TP
    end
    
    % Average standrad errors across maturities
    mtxmse(k0,:,1) = mean(aux(:,:,1));
    mtxmse(k0,:,2) = mean(aux(:,:,2));
    mtxmse(k0,:,3) = mean(aux(:,:,3));
end

% Report standrad errors for EMs and AEs
mtxmse = mtxmse*10000;                                                  % in basis points
sprintf('EM: Avg. s.e. from uncertainty in xs for yQ (%1.2f), yP (%1.2f) and TP (%1.2f)',...
    mean(mean(mtxmse(1:15,:,1))),mean(mean(mtxmse(1:15,:,2))),mean(mean(mtxmse(1:15,:,3))))
sprintf('AE: Avg. s.e. from uncertainty in xs for yQ (%1.2f), yP (%1.2f) and TP (%1.2f)',...
    mean(mean(mtxmse(16:end,:,1))),mean(mean(mtxmse(16:end,:,2))),mean(mean(mtxmse(16:end,:,3))))
sprintf('EM: Avg. s.e. per country from uncertainty in xs for yQ (col1), yP (col2) and TP (col3)')
    [mean(mtxmse(1:15,:,1),2) mean(mtxmse(1:15,:,2),2) mean(mtxmse(1:15,:,3),2)]