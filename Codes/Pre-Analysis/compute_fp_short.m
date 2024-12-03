function [FP,hdr] = compute_fp_short(LC,header,dataset,curncs)
% COMPUTE_FP_SHORT Compute forward premium (FP) for 3- 6- 9-month maturities
% Assumption: countries in convpts and convfx (below) have same order as in curncs
% m-files called: construct_hdr
%
%     INPUTS
% char: LC        - local currency for which the forward premium will be computed
% cell: header    - contains information about the tikcers (eg currency, type, tenor)
% double: dataset - dataset with historic values of all the tickers
% cell: curncs    - contains all currencies in ascending order (EMs followed by AEs)
% 
%     OUTPUT
% double: FP - matrix of historic forward premiums (rows) for different tenors (cols)
% cell: hdr  - header ready to be appended (NO extra first row with titles)

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
% Read conventions used to quote FX forward points
pathc    = pwd;
pathd    = fullfile(pathc,'..','..','Data','Raw');                  % platform-specific file separators
cd(pathd)
filename = 'AE_EM_Curves_Tickers.xlsx';
convpts  = readmatrix(filename,'Sheet','CONV','Range','N66:N90');	% update range as necessary
convfx   = readcell(filename,'Sheet','CONV','Range','H66:H90');     % update range as necessary
cd(pathc)

tnrs = {'0.25';'0.5';'0.75'};

% Extract the FX spot
fltrSPT = ismember(header(:,1),LC) & ismember(header(:,2),'SPT');
fx_spt  = dataset(:,fltrSPT & ismember(header(:,7),'Bloomberg'));

% Extract (outright) or calculate (forward points) the FX forwards (3M, 6M, 9M)
fltrAUX = ismember(header(:,1),LC) & ismember(header(:,2),'FWD') & ismember(header(:,5),tnrs);
fltrBLP = fltrAUX & ismember(header(:,7),'Bloomberg');
fltrWMR = fltrAUX & ismember(header(:,7),'WMR');

switch LC
    case {'KRW','PHP','THB'}
        fx_spt  = dataset(:,fltrSPT & ismember(header(:,7),'WMR')); % spot from same source for consistency
        fltrFWD = fltrWMR & endsWith(header(:,3),'F');      % use outright forwards from Datastream
        fx_fwd  = dataset(:,fltrFWD);
        
    case {'IDR','MYR','PEN'}                                % use outright forwards from Bloomberg
        fltrFWD = fltrBLP & contains(header(:,3),'+');
        fx_fwd  = dataset(:,fltrFWD);
        
    otherwise                                               % use forward points from Bloomberg
        fltrFWD = fltrBLP & ~contains(header(:,3),'+');
        fx_fwd  = fx_spt + dataset(:,fltrFWD)/convpts(ismember(curncs,LC)); % Use right convention
end

% Express all FX as LC per USD
switch LC
    case curncs(~startsWith(convfx,'USD'))'
        fx_spt = 1./fx_spt;
        fx_fwd = 1./fx_fwd;
end

% Calculate the FP (expressed in percentage points) for maturities < 1 yr
fctr = 100./cellfun(@str2double,tnrs');     % Need to annualize the FP (note: tnrs are in year fractions)
FP   = fctr.*(fx_fwd - fx_spt)./fx_spt;     % Alternative formula: FP = fctr.*(log(fx_fwd) - log(fx_spt));

% Header
name = strcat(LC,' FORWARD PREMIUM',{' '},tnrs,' YR');
hdr  = construct_hdr(LC,'RHO','N/A',name,tnrs,' ',' ');     % Note: No extra row 1 (title)

%% Compare the FP for EMs Obtained Using Datastream
% for k = 1:15
%     if k ~= [4, 8]                               % DIS (2018) use Bloomberg for IDR and MYR
%         LC   = curncs{k};   tnr  = 0.25;
%         rows = T_cip.currency==LC & T_cip.tenor=='3m';
% 
%         fltrSPT = TH_daily.Currency==LC & TH_daily.Type=='SPT' & TH_daily.Source=='WMR';
%         fx_spt  = TT_daily{:,fltrSPT};
% 
%         fltrFWD    = TH_daily.Currency==LC & TH_daily.Type=='FWD' & TH_daily.Tenor==tnr;
%         fltrWMRf   = fltrFWD & TH_daily.Source=='WMR' & endsWith(cellstr(TH_daily.Ticker),'F');
%         fx_fwd_wmr = TT_daily{:,fltrWMRf};
% 
%         FPwmr = (100/tnr)*(fx_fwd_wmr - fx_spt)./fx_spt;
% 
%         figure
%         plot(T_cip.date(rows),T_cip{rows,'rho'},TT_daily.Date,FPwmr)
%         legend('DIS','Own')
%         title([LC ' ' num2str(tnr)])
%         datetick('x','yy','keeplimits')
%     end
% end
