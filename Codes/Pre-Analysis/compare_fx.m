%% Compare FX from Bloomberg and Datastream
% This code compares the FX spots and the FX forwards of emerging markets
% from Bloomberg and Datastream.
% Assumes that TH_daily and TT_daily are in the workspace.
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
% 
%% Compare FX Spots
diffs = []; correls = [];
for k = 1:length(currEM)
    fltrSPT = TH_daily.Currency==currEM{k} & TH_daily.Type=='SPT';
    fx = TT_daily{:,fltrSPT};
    figure
    plot(TT_daily.Date,fx)
    legend(cellstr(TH_daily.Source(fltrSPT)),'Location','best')
    title(currEM{k})
    datetick('x','yy','keeplimits')
    
    diffs   = [diffs; mean(fx(:,1) - fx(:,2),'omitnan')];   % Absolute deviations (regardless of units)
    correls = [correls; corr(fx(:,1),fx(:,2),'Rows','complete')];
end

sprintf('Minimum FX spot correlation: %0.4f',min(correls))
sprintf('Average FX spot correlation: %0.4f',mean(correls))

%% Compare FX Forwards (Points and Outright)
% Read the conventions used to quote FX forward points
path        = pwd;
cd(fullfile(path,'..','..','Data','Raw'))               % Use platform-specific file separators
filename = 'AE_EM_Curves_Tickers.xlsx';
ptsconv  = xlsread(filename,'CONV','N66:N80');          % Update ranges as necessary
cd(path)

correls = [];
tnr = 0.25;
for k = 1:length(currEM)
    % When using forward points, need the FX spot to calculate the forward FX
    fltrSPT = TH_daily.Currency==currEM{k} & TH_daily.Type=='SPT' & TH_daily.Source=='Bloomberg';
    fx_spt  = TT_daily{:,fltrSPT};
    
    % Identify the FX forwards, at least one from Bloomberg and one from Datastream
    fltrFWD = TH_daily.Currency==currEM{k} & TH_daily.Type=='FWD' & TH_daily.Tenor==tnr;
    
    % Identify the FX forwards from Bloomberg and choose the one with the longest history
    fltrBLPfwd  = fltrFWD & TH_daily.Source=='Bloomberg';
    fltrBLPpts  = fltrBLPfwd & ~contains(cellstr(TH_daily.Ticker),'+'); % Forward points
    fltrBLPout  = fltrBLPfwd & contains(cellstr(TH_daily.Ticker),'+');  % Outright forward (not all countries)
    fx_fwd_blpP = fx_spt + TT_daily{:,fltrBLPpts}/ptsconv(k);           % Use forward points to get forward FX
    fx_fwd_blpF = TT_daily{:,fltrBLPout};
    
    fltrBLP     = [fltrBLPpts, fltrBLPout];
    fx_fwd_blp  = [fx_fwd_blpP, fx_fwd_blpF];
    [~,idx]     = max(sum(~isnan(fx_fwd_blp)));                     % In general, choose longest history
    if strcmp(currEM{k},'PEN') && numel(sum(~isnan(fx_fwd_blp)))==2 % For PEN need to use outright forward
        idx = 2;                    % For PEN, outright forward tracks Datastream USPEN*F closely
    elseif strcmp(currEM{k},'RUB')                                  % For RUB need to use forward points
        idx = 1;                    % For RUB, outright forward has longer early history but mostly outliers
    end
    fltrBLP     = fltrBLP(:,idx);
    fx_fwd_blp  = fx_fwd_blp(:,idx);
    
    % Identify the FX forwards from Datastream and choose the one with the longest history
    fltrWMRfwd  = fltrFWD & TH_daily.Source=='WMR';
    fltrWMRf    = fltrWMRfwd & endsWith(cellstr(TH_daily.Ticker),'F');
    fltrWMRm    = fltrWMRfwd & endsWith(cellstr(TH_daily.Ticker),'M');  % Not all countries (shorter history)
    fx_fwd_wmrF = TT_daily{:,fltrWMRf};
    fx_fwd_wmrM = TT_daily{:,fltrWMRm};
    
    fltrWMR     = [fltrWMRf, fltrWMRm];
    fx_fwd_wmr  = [fx_fwd_wmrF, fx_fwd_wmrM];
    [~,idx]     = max(sum(~isnan(fx_fwd_wmr)));                         % In general, choose longest history
    fltrWMR     = fltrWMR(:,idx);
    fx_fwd_wmr  = fx_fwd_wmr(:,idx);

    % Compare the FX forwards from Bloomberg and Datastream
    figure
    plot(TT_daily.Date,[fx_fwd_blp fx_fwd_wmr])
    lgnd = [cellstr(TH_daily.Ticker(fltrBLP)),cellstr(TH_daily.Ticker(fltrWMR))];
    legend(lgnd,'Location','best')
    title([currEM{k} ' ' num2str(tnr) ' Years'])
    datetick('x','yy','keeplimits')
    
    correls = [correls; corr(fx_fwd_blp,fx_fwd_wmr,'Rows','complete')];
end

sprintf('Average FX forward correlation: %0.4f',mean(correls))

%% FX Forward for Canada
curr = 'CAD';
tnr  = 0.25; %0.25, 0.5
fltrSPT    = TH_daily.Currency==curr & TH_daily.Type=='SPT';
fx_spt     = TT_daily{:,fltrSPT};
fltrBLPfwd = TH_daily.Currency==curr & TH_daily.Type=='FWD' & TH_daily.Tenor==tnr;

% Identify the FX forwards for Canada
fltrBLPpts  = fltrBLPfwd & ~contains(cellstr(TH_daily.Ticker),'+'); % Forward points
fltrBLPout  = fltrBLPfwd & contains(cellstr(TH_daily.Ticker),'+');  % Outright forward (not all countries)
fx_fwd_blpP = fx_spt + TT_daily{:,fltrBLPpts}/10000;                % Use forward points to get forward FX
fx_fwd_blpF = TT_daily{:,fltrBLPout};

figure
plot(TT_daily.Date,[fx_fwd_blpP, fx_fwd_blpF])
lgnd = [cellstr(TH_daily.Ticker(fltrBLPpts)),cellstr(TH_daily.Ticker(fltrBLPout))];
legend(lgnd,'Location','best')
title([curr ' ' num2str(tnr) ' Years'])
datetick('x','yy','keeplimits')

clear k path filename diffs correls fx* fltr* ptsconv idx lgnd curr tnr