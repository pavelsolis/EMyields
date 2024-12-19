function [S,fitrprt] = assess_fit(S,currEM,currAE,plotfit)
% ASSESS_FIT Report means and standard deviations of absolute errors and
% store root mean square errors in structure

% Pavel Solís (pavel.solis@gmail.com)
%%
ncntrs  = length(S);
nEMs    = length(currEM);
matsall = [0.25 0.5 1:10];
mtxmae  = nan(ncntrs,length(matsall));  mtxsae = nan(ncntrs,length(matsall));
fitrprt = cell(2*ncntrs+1,length(matsall)+1);
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                                % field containing estimated parameters
for k0  = 1:ncntrs
    if ismember(S(k0).iso,currEM)
        prefix = 'ms'; 
    else
        prefix = 'mn'; 
    end
    
    % Observed yields
    fnameb = fnames{contains(fnames,[prefix '_blncd'])};                    % field containing observed yields
    yields = S(k0).(fnameb)(2:end,2:end)*100;                               % yields in percent
    nobs   = size(yields,1);                                                % number of observations
    dates  = S(k0).(fnameb)(2:end,1);                                       % dates
    mats   = S(k0).(fnameb)(1,2:end);                                       % original maturities
    
    % Fitted yields
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';                     % estimated parameters
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    xs    = S(k0).(fnameq).xs;      xsc   = size(xs,2);
    if xsc == nobs; xs = xs'; end                             	            % ensure xs dimensions are the same as yields
    [AnQ,BnQ] = loadings(mats,mu_xQ,PhiQ,Hcov,rho0,rho1,1/12);	            % loadings using original maturities 
    yieldsQ   = (ones(nobs,1)*AnQ + xs*BnQ)*100;                            % fitted yields in percent
    
    % Fit of the model
    mtxmae(k0,ismember(matsall,mats)) = mean(abs(yields - yieldsQ))*100;    % mean absolute errors in bp
    mtxsae(k0,ismember(matsall,mats)) = std(abs(yields - yieldsQ))*100;     % std of absolute errors in bp
    S(k0).('m_rmse') = sqrt(mean(mean((yields - yieldsQ).^2)));             % RMSE
    
    if plotfit
        if ismember(S(k0).iso,currEM)
            if k0 == 1; figure; end
            subplot(3,5,k0);
            plot(dates,yields(:,end),dates,yieldsQ(:,end))
            title(S(k0).cty); datetick('x','yy'); yline(0); ylabel('%');
        else
            if k0 == nEMs+1; figure; end
            subplot(2,5,k0-nEMs);
            plot(dates,yields(:,end),dates,yieldsQ(:,end))
            title(S(k0).cty); datetick('x','yy'); yline(0); ylabel('%');
        end 
    end
end

% Report means and standard deviations of absolute errors
fitrprt(1,2:end) = num2cell(matsall);                                       % maturities
fitrprt(2:2:2*nEMs+1,1) = currEM;                                           % names of EMs
fitrprt(2*nEMs+2:2:2*ncntrs+1,1) = currAE;                                  % names of AEs
fitrprt(2:2:2*ncntrs+1,2:end) = num2cell(mtxmae);                           % mean absolute errors
fitrprt(3:2:2*ncntrs+1,2:end) = num2cell(mtxsae);                           % std of absolute errors
fitrprt(:,[false,ismember(matsall,[6 8 9])]) = [];                          % delete maturities 6, 8 and 9Y