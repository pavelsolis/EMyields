function ts_plots(S,currEM,currAE,figsave)
% TS_PLOTS Plot different series after estimation of affine model

% m-files called: datesminmax, syncdatasets, inflation_target, save_figure, rollingcorrs, ts_dyindex
% Pavel Solís (pavel.solis@gmail.com)
%%
if nargin < 4; figsave = false; end
nEMs = length(currEM);

%% Figure 1. Decomposition of 10Y nominal yields of EMs (monthly)
figdir  = ''; formats = {'eps'};
fldname = {'bsl_yP','bsl_tp','bsl_cr'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(datetime(S(k0).(fldname{1})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:)==10)*100,'-','LineWidth',0.5);
    hold on
    plot(datetime(S(k0).(fldname{2})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:)==10)*100,'-.','LineWidth',0.6);
%   plot(datetime(S(k0).(fldname{3})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:)==10)*100,'--','LineWidth',1);
    crcts = S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:)==10);
    crcts(crcts < 0) = 0;
    pO = plot(datetime(S(k0).(fldname{3})(2:end,1),'ConvertFrom','datenum'),crcts*100,'-o','LineWidth',0.8);
    pO.MarkerSize = 6; pO.MarkerIndices = 1:50:length(crcts);
    title(S(k0).cty); xtickformat('yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
lbl = {'Expected Short Rate','Term Premium','Credit Risk Compensation'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'ny_dcmp'; save_figure(figdir,figname,formats,figsave)
close all

%% Figure A.1. Plot survey data
figdir  = ''; formats = {'eps'};
macrovr = {'CPI','GDP','CBP'};
for k0 = 1:length(macrovr)
    fldname = ['s' lower(macrovr{k0})];
    figure
    for k1 = 1:nEMs
        if ~isempty(S(k1).(fldname))
            dtmn  = datesminmax(S,k1);
            fltrd = S(k1).(fldname)(:,1) >= dtmn;
            subplot(3,5,k1)
            plot(S(k1).(fldname)(fltrd,1),S(k1).(fldname)(fltrd,end),'LineWidth',1.25); hold on
            plot(S(k1).(fldname)(fltrd,1),S(k1).(fldname)(fltrd,end-1),'-.','LineWidth',1.25);
            title(S(k1).cty); datetick('x','yy'); 
            if strcmp(macrovr{k0},'CBP'); ylim([0 10]); else; ylim([0 8]); end
            if strcmp(macrovr{k0},'CPI')
                [ld,lu] = inflation_target(S(k1).iso);
                if ~isempty(ld); yline(ld,'--'); yline(lu,'--'); end
            end
            if ismember(k1,[1,6,11]); ylabel('%'); end
        end
    end
    lgd = legend({'Long Term','5 Years Ahead'},'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = ['wn' macrovr{k0}]; save_figure(figdir,figname,formats,figsave)
end
close all

%% Figure B.1. Comparison of yP vs surveys_CBP
figdir  = ''; formats = {'eps'};
fldname = {'bsl_yP','scbp'};
figure
for k0 = 1:nEMs
    dtmn  = datesminmax(S,k0);
    subplot(3,5,k0)
    fltrt = S(k0).(fldname{1})(1,:) == 10;
    plot(datetime(S(k0).(fldname{1})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{1})(2:end,fltrt)*100,'LineWidth',1.25);
    if ~isempty(S(k0).(fldname{2}))
        fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
        hold on; plot(datetime(S(k0).(fldname{2})(fltrd,1),'ConvertFrom','datenum'),S(k0).(fldname{2})(fltrd,end),'*','LineWidth',0.6);  % 10Y
    end
    title(S(k0).cty); xtickformat('yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
lgd = legend('Model','Forecast','Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname{1} '_' fldname{2}]; save_figure(figdir,figname,formats,figsave)
close all

%% Figure B.2. Term structure of term premia
figdir  = ''; formats = {'eps'};
fldname = 'bsl_tp';
figure
lstyle  = {'-','-.','--'};
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        fltrTNR = ismember(S(k0).(fldname)(1,:),[1 5 10]);
        posTNR  = find(fltrTNR);
        hold on
        for k1 = 1:length(posTNR)
            plot(datetime(S(k0).(fldname)(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname)(2:end,posTNR(k1))*100,lstyle{k1},'LineWidth',1)
        end
        hold off
        title(S(k0).cty); xtickformat('yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lbl = cellfun(@num2str,num2cell(S(k0).(fldname)(1,fltrTNR)),'UniformOutput',false);
lbl = {[lbl{1} ' Year'],[lbl{2} ' Years'],[lbl{3} ' Years']};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_ts']; save_figure(figdir,figname,formats,figsave)
close all

%% Figures B.3 & B.4. Components with confidence bands
figdir = ''; formats = {'eps'};
vars   = {'tp','cr'};
names  = {'Term Premium','Credit Risk Compensation'};
tnr    = 10;
for k0 = 1:length(vars)
    fldname = {['bsl_' vars{k0}],['bsl_' vars{k0} '_se']};
    figure
    for k1 = 1:nEMs
        subplot(3,5,k1)
        var   = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == tnr)*100;
        varse = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == tnr)*100;
        plot(S(k1).(fldname{1})(2:end,1),var,'-','LineWidth',1.25); hold on
        plot(S(k1).(fldname{2})(2:end,1),var - 2*varse,'--','Color', [0.6 0.6 0.6],'LineWidth',0.75)
        plot(S(k1).(fldname{2})(2:end,1),var + 2*varse,'--','Color', [0.6 0.6 0.6],'LineWidth',0.75); hold off
        title(S(k1).cty)
        datetick('x','yy'); yline(0); if ismember(k1,[1,6,11]); ylabel('%'); end
    end
    lbl = {names{k0},'Confidence Bands'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = [fldname{1} '_CI_' num2str(tnr) 'y_V1']; save_figure(figdir,figname,formats,figsave)
end
close all

%% Figure C.1. Rolling correlations: Term structure (daily frequency)
figdir  = ''; formats = {'eps','fig'};
fname   = {'dn_data'};
lstyle  = {'-','-.','--',':'};
tenor   = [10 5 1 0.25];
lbl     = {'10 Years','5 Years','1 Year','3 Months'};

    % EM
for k0 = 1:length(fname)
    figure
    for k1 = 1:length(tenor)
        rollcorr = rollingcorrs(S,currEM,fname{k0},tenor(k1));
        plot(rollcorr(:,1),rollcorr(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['rolling_' fname{k0}]; save_figure(figdir,figname,formats,figsave)       %figure C.1(a)
end

    % AE
for k0 = 1:length(fname)
    figure
    for k1 = 1:length(tenor)
        rollcorr = rollingcorrs(S,currAE,fname{k0},tenor(k1));
        plot(rollcorr(:,1),rollcorr(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['rolling_' fname{k0} '_AE']; save_figure(figdir,figname,formats,figsave) %figure C.1(b)
end

%% Figure C.2. DY index: Term structure (daily frequency)
figdir  = ''; formats = {'eps','fig'};
fldname = {'dn_data'};
lstyle  = {'-','-.','--',':'};
tenor   = [10 5 1 0.25];
lbl     = {'10 Years','5 Years','1 Year','3 Months'};

    % EM
for k0 = 1:length(fldname)
    figure
    for k1 = 1:length(tenor)
        [DYindex,DYtable] = ts_dyindex(S,currEM(~contains(currEM,{'PHP'})),fldname{k0},tenor(k1));
        disp([fldname{k0} ' ' num2str(tenor(k1))])
        disp(DYtable)
        plot(DYindex(:,1),DYindex(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); ylabel('%'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['dy_index_' fldname{k0}]; save_figure(figdir,figname,formats,figsave)        % figure C.2(a)
end

    % AE
for k0 = 1:length(fldname)
    figure
    for k1 = 1:length(tenor)
        [DYindex,DYtable] = ts_dyindex(S,currAE,fldname{k0},tenor(k1));
        disp([fldname{k0} ' ' num2str(tenor(k1))])
        disp(DYtable)
        plot(DYindex(:,1),DYindex(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); ylabel('%'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['dy_index_' fldname{k0} '_AE']; save_figure(figdir,figname,formats,figsave)  % figure C.2(b)
end

%% Figure C.3. DY index: Yield components (daily frequency)
figdir  = ''; formats = {'eps','fig'};

    % AE + EM (nominal, synthetic)
tenor = 10;
fldname = {'dn_data','ds_data'};
lstyle  = {'-','-.','--'};
datemin = datenum('31-Jan-2019');
figure
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currEM(~contains(currEM,{'BRL','KRW','PHP','THB'})),fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0},'LineWidth',1); hold on
    if DYindex(1,1) < datemin
        datemin = DYindex(1,1);
    end
end
k0 = 1;
[DYindex,DYtable] = ts_dyindex(S,currAE(~contains(currAE,{'NOK'})),fldname{k0},tenor);
disp(DYtable)
fltrAE = DYindex(:,1) >= datemin;
plot(DYindex(fltrAE,1),DYindex(fltrAE,2),lstyle{end},'LineWidth',1); hold on
datetick('x','yy'); ylabel('%'); hold off
lbl = {'Emerging Markets - Nominal','Emerging Markets - Synthetic','Advanced Economies - Nominal'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_nomsyn']; save_figure(figdir,figname,formats,figsave)   % figure C.3(a)

    % EM
tenor = 10;
fldname = {'d_yP','d_tp','dc_data'};
lstyle  = {'-','-.','--'};
figure
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currEM(~contains(currEM,{'BRL','KRW','PHP','THB'})),fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0},'LineWidth',1); hold on
end
datetick('x','yy'); ylabel('%'); hold off
lbl = {'Exp. Short Rate','Term Premium','Credit Risk Compensation'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_dcmp']; save_figure(figdir,figname,formats,figsave)     % figure C.3(b)

%% Figure E.1. Plot 10Y yields and long-term interest rate forecast
figdir  = ''; formats = {'eps'};
fldname = {'ms_data','inf','scbp'};
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{3}))
        subplot(3,5,k0)
        plot(datetime(S(k0).(fldname{1})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25); hold on
        plot(datetime(S(k0).(fldname{3})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{3})(2:end,end),'-.','LineWidth',1.25)
        title(S(k0).cty); xtickformat('yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lbl = {'10-Year Synthetic Yield','Implied Long-Term Forecast of Short Rate'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'YLD10Y_CBP'; save_figure(figdir,figname,formats,figsave)
close all

%% Figure E.2. Model fit to synthetic
figdir  = ''; formats = {'eps'};
fldname = {'ms_blncd','bsl_yQ'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(datetime(S(k0).(fldname{1})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25); hold on
    plot(datetime(S(k0).(fldname{2})(2:end,1),'ConvertFrom','datenum'),S(k0).(fldname{2})(2:end,end)*100,'-.','LineWidth',1.25);    % 10Y
    title(S(k0).cty); xtickformat('yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
lgd = legend({'Observed','Fitted'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 's_ylds_bsl_yQ'; save_figure(figdir,figname,formats,figsave)
close all