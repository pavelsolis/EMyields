function S = trend_inflation(S,currEM,trndcntrs,tfplot,tfsave)
% TREND_INFLATION Return the trend (within the inflation target) generated
% by the HP filter on the months in which Consensus Economics generally
% publish forecasts for emerging markets
% 
% m-files called: cntrstimetable, inflation_target, save_figure
% Pavel Solís (pavel.solis@gmail.com)
%% 
nEMs = length(currEM);
if nargin < 4;  tfplot = false;	tfsave = false; end

%% Collect data
TTinf = cntrstimetable(S,currEM,'inf');
TTsvy = cntrstimetable(S,currEM,'scpi',10);

%% HP filter (whole sample)

% Annual, semiannual or quarterly data
TTfreq = TTinf(ismember(month(TTinf.Time),[4 10]),:);                      % annual: 12; quarterly: [3 6 9 12]
isocds = TTfreq.Properties.VariableNames;
HPfreq = array2timetable(hpfilter(TTfreq{:,:},1600),'RowTimes',TTfreq.Time,'VariableNames',isocds);% annual:100

% Shorten sample to range of survey data for other countries
HPfreq = HPfreq(isbetween(HPfreq.Time,min(TTsvy.Time),max(TTsvy.Time)),:);

% Remove trend outside of inflation target
for k1 = 1:nEMs
    [ld,lu] = inflation_target(S(k1).iso);
    if ~isempty(ld)
        fltrCTY = strcmp(isocds,S(k1).iso);
        fltrTGT = HPfreq{:,fltrCTY} > ld & HPfreq{:,fltrCTY} < lu;
        HPfreq{~fltrTGT,fltrCTY} = nan;
    end
end

%% Report trend
for k4 = 1:length(trndcntrs)
    fltrTRN = ismember(isocds,trndcntrs{k4});
    dates   = datenum(HPfreq.Time);
    HPtrend = HPfreq{:,fltrTRN};
    fltrNAN = isnan(HPtrend);
    S(fltrTRN).scpi = [nan 1 5 10;
                       dates(~fltrNAN) nan(size(HPtrend(~fltrNAN),1),1) repmat(HPtrend(~fltrNAN),1,2)];
end

%% Compare against surveys
if tfplot
    k3 = 0;
    figure
    for k2 = 1:nEMs
        if ismember(S(k2).iso,{'ILS','MYR','THB','ZAR'})
            k3 = k3 + 1;
            subplot(2,2,k3)                                                 % 3,5 to see all countries
            plot(TTinf.Time,TTinf{:,k2},'-','LineWidth',1);	hold on
            plot(HPfreq.Time,HPfreq{:,k2},'-.','LineWidth',1);
            if ~isempty(S(k2).scpi) && ~ismember(S(k2).iso,trndcntrs)       % 10Y
                plot(datetime(S(k2).scpi(2:end,1),'ConvertFrom','datenum'),S(k2).scpi(2:end,end),'--','LineWidth',1);
            end
            [ld,lu] = inflation_target(S(k2).iso);
            if ~isempty(ld); yline(ld,'--'); yline(lu,'--'); end
            hold off
            title(S(k2).cty)
            if ismember(k3,[1,3]); ylabel('%'); end
        end
    end
    lbl = {'Inflation','Trend','Forecast'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figdir  = 'Surveys'; formats = {'eps'}; figsave = tfsave;
    figname = ['CPI_' [trndcntrs{:}]]; save_figure(figdir,figname,formats,figsave)  % generate figure A.2
end