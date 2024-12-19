function S = add_cr(S,matsout,currEM)
% ADD_CR Report estimated credit risk compensation in a field

% m-files called: syncdatasets
% Pavel Solís (pavel.solis@gmail.com)
%%
dt      = 1/12;
ncntrs  = length(S);
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                                % field containing estimated parameters
for k0  = 1:ncntrs
    if ismember(S(k0).iso,currEM)
        % Nominal yields
        fnameb = 'mn_blncd';                                                % field containing *nominal* yields
        fltrnm = ismember(S(k0).(fnameb)(1,:),matsout);                     % same maturities as in matsout
        yldnom = S(k0).(fnameb)(2:end,fltrnm);                              % yields in decimals
        datesn = S(k0).(fnameb)(2:end,1);                                   % dates

        % Synthetic yields
        fnameb = 'ms_blncd';                                                % field containing *synthetic* yields
        fltrsn = ismember(S(k0).(fnameb)(1,:),matsout);                     % same maturities as in matsout
        yldsyn = S(k0).(fnameb)(2:end,fltrsn);                              % yields in decimals
        nobssn = size(yldsyn,1);                                            % number of observations
        datess = S(k0).(fnameb)(2:end,1);                                   % dates

        % Extract estimated parameters
        cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';
        mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
        rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
        xs    = S(k0).(fnameq).xs;      xsc   = size(xs,2);
        if xsc == nobssn; xs = xs'; end                                     % dimensions of xs & yields are equal
        
        % Estimated credit risk compensation
        [AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
        yieldsQ   = ones(nobssn,1)*AnQ + xs*BnQ;
        [~,crynom,cryldsQ] = syncdatasets([nan matsout; datesn yldnom],[nan matsout; datess yieldsQ]);
        crcomp    = crynom(2:end,2:end) - cryldsQ(2:end,2:end);
        S(k0).('bsl_cr') = [nan matsout; crynom(2:end,1) crcomp];
    else
        fnameb = 'mc_blncd';                                                % field containing CIP deviations
        fltrcp = ismember(S(k0).(fnameb)(1,:),matsout);                     % same maturities as in matsout
        fltrcp(1) = true;                                                   % include dates
        S(k0).('bsl_cr') = S(k0).(fnameb)(:,fltrcp);
    end
end