function ts_plots(S,currEM,currAE,kwtp,vix,figsave)
% TS_PLOTS Plot different series after estimation of affine model

% m-files called: datesminmax, syncdatasets, inflation_target, save_figure,
% read_spf, read_cds, rollingcorrs, ts_dyindex
% Pavel Solís (pavel.solis@gmail.com), October 2021
%%
if nargin < 6; figsave = false; end
nEMs = length(currEM);
nAEs = length(currAE);

clrplt = [0.06, 0.5, 0.95
        0.7, 0.075, 0.36
        0.553, 0.353, 0.714
        0.08, 0.9, 0.4
        0, 0.77, 0.96];

%% Plot macro data
figdir = 'Data'; formats = {'eps'}; %figsave = false;
vars   = {'INF','UNE','IP','GDP','CBP'};
fnames = lower(vars);
% whole period
for l = 1:length(vars)
    figure
    for k0 = 1:nEMs
        if size(S(k0).(fnames{l}),2) > 1
            date1 = datenum(S(k0).mn_dateb,'mmm-yyyy'); 
            date2 = datenum(S(k0).ms_dateb,'mmm-yyyy');
            subplot(3,5,k0)
            plot(S(k0).(fnames{l})(:,1),S(k0).(fnames{l})(:,2),'LineWidth',1.25)
            title([S(k0).cty ' ' vars{l}]); datetick('x','yy'); yline(0);
            xline(date1); xline(date2); if ismember(k0,[1,6,11]); ylabel('%'); end
        end
    end
    figname = ['wh' vars{l}]; save_figure(figdir,figname,formats,figsave)
end

% within period
for l = 1:length(vars)
    figure
    for k0 = 1:nEMs
        if size(S(k0).(fnames{l}),2) > 1
            [dtmn,dtmx] = datesminmax(S,k0);
            fltrd = S(k0).(fnames{l})(:,1) >= dtmn;
            subplot(3,5,k0)
            plot(S(k0).(fnames{l})(fltrd,1),S(k0).(fnames{l})(fltrd,2),'LineWidth',1.25)
            title([S(k0).cty ' ' vars{l}]); datetick('x','yy'); yline(0);
            xline(dtmx); if ismember(k0,[1,6,11]); ylabel('%'); end
        end
    end
    figname = ['wn' vars{l}]; save_figure(figdir,figname,formats,figsave)
end

% Inflation volatility: permanent vs cyclical
figure
for k0 = 1:nEMs
    fldname = {'sdprm','sdcyc'};                                            % std of permanent and cyclical
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(:,1),S(k0).(fldname{1})(:,2),'LineWidth',1.25)
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(:,1),S(k0).(fldname{2})(:,2),'LineWidth',1.25)
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('SDPRM','SDCYC','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); %yline(0);
end
figname = 'INF_vol'; save_figure(figdir,figname,formats,figsave)

close all

%% Plot 10Y yields
figdir  = 'Data'; formats = {'eps'}; %figsave = false;
fldname = {'ms_data','inf','scbp'};

% Yield only
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25)
    title(S(k0).iso); 
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
figname = 'YLD10Y'; save_figure(figdir,figname,formats,figsave)

% All yields (term structure)
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    fltrYLD = ismember(S(k0).(fldname{1})(1,:),[0.25 1 5 10]);
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltrYLD)*100,'LineWidth',1)
    title(S(k0).iso);
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
lgd = legend({'3 Months','1 Year','5 Years','10 Years'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'syntTSIR'; save_figure(figdir,figname,formats,figsave)

% Yield and inflation
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    dtmn  = datesminmax(S,k0);
    fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25); hold on
    plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end),'LineWidth',1.25)
    title(S(k0).iso); 
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
lgd = legend({'10-Year Synthetic Yield','Inflation'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'YLD10Y_INF'; save_figure(figdir,figname,formats,figsave)

% Yield and survey interest rate forecast
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{3}))
        subplot(3,5,k0)
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25); hold on
        plot(S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,end),'-.','LineWidth',1.25)
        title(S(k0).cty); 
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lbl = {'10-Year Synthetic Yield','Implied Long-Term Forecast of Short Rate'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'YLD10Y_CBP'; save_figure(figdir,figname,formats,figsave)

close all

%% Plot survey data
figdir  = 'Surveys'; formats = {'eps'}; %figsave = false;
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
%             L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))     % sets #ticks to 4
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

%% Compare results (different versions, different variables): ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
fldname = [strcat({'mny','msy','mnsf','mnsb','mssf','mssb'},'_tp') 'mssb_yP'];
fldnmAE = [strcat({'mny','msy'},'_tp') 'mny_yP'];
% Simple
    % EM
for k1 = 1:length(fldname)
    figure
    for k0 = 1:nEMs
        if ~isempty(S(k0).(fldname{k1}))
            subplot(3,5,k0)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end)*100)
            title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
        end
    end
    figname = fldname{k1}; save_figure(figdir,figname,formats,figsave)
end

    % AEs
for k1 = 1:length(fldnmAE)
    figure; k2 = 0;
    for k0 = nEMs+1:nEMs+nAEs
        if ~isempty(S(k0).(fldnmAE{k1}))
            k2 = k2 + 1;
            subplot(2,5,k2)
            plot(S(k0).(fldnmAE{k1})(2:end,1),S(k0).(fldnmAE{k1})(2:end,end)*100)
            title([S(k0).iso ' ' num2str(S(k0).(fldnmAE{k1})(1,end)) 'Y ' fldnmAE{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0); if ismember(k2,[1,6]); ylabel('%'); end
        end
    end
    figname = [fldnmAE{k1} '_AE']; save_figure(figdir,figname,formats,figsave)
end

% QE, TT events: QE1, QE2, MEP, QE3, TT
    % EMs
for k1 = 1:length(fldname)
    figure
    for k0 = 1:nEMs
        if ~isempty(S(k0).(fldname{k1}))
            subplot(3,5,k0)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end)*100)
            title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
            xline(datenum('25-Nov-2008')); xline(datenum('3-Nov-2010')); 
            xline(datenum('21-Sep-2011')); xline(datenum('13-Sep-2012')); 
            xline(datenum('19-Jun-2013'));
        end
    end
    figname = [fldname{k1} '_QE']; save_figure(figdir,figname,formats,figsave)
end

    % AEs
for k1 = 1:length(fldnmAE)
    figure; k2 = 0;
    for k0 = nEMs+1:nEMs+nAEs
        if ~isempty(S(k0).(fldnmAE{k1}))
            k2 = k2 + 1;
            subplot(2,5,k2)
            plot(S(k0).(fldnmAE{k1})(2:end,1),S(k0).(fldnmAE{k1})(2:end,end)*100)
            title([S(k0).iso ' ' num2str(S(k0).(fldnmAE{k1})(1,end)) 'Y ' fldnmAE{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0); if ismember(k2,[1,6]); ylabel('%'); end
            xline(datenum('25-Nov-2008')); xline(datenum('3-Nov-2010')); 
            xline(datenum('21-Sep-2011')); xline(datenum('13-Sep-2012')); 
            xline(datenum('19-Jun-2013'));
        end
    end
    figname = [fldnmAE{k1} '_QE_AE']; save_figure(figdir,figname,formats,figsave)
end

% Local events
for k1 = 1:length(fldname)
    figure; k2 = 0;
    for k0 = 1:nEMs
        if ~isempty(S(k0).(fldname{k1}))
            if ismember(S(k0).iso,{'BRL','COP','HUF','IDR','KRW','PHP','PLN','RUB','THB','TRY'})
            k2 = k2 + 1;
            subplot(2,5,k2)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end)*100)
            title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0); if ismember(k2,[1,6]); ylabel('%'); end
            switch S(k0).iso
                case 'BRL'
                    xline(datenum('19-Oct-2009')); xline(datenum('4-Oct-2010'));
                    xline(datenum('6-Jan-2011')); xline(datenum('8-Jul-2011'));
                    xline(datenum('4-Jun-2013'));
                case 'COP'
                    xline(datenum('1-Dec-2004'));
                    xline(datenum('1-Jun-2006'));  xline(datenum('1-May-2007')); 
                    xline(datenum('1-Jul-2007')); xline(datenum('4-Oct-2008'));
                case 'HUF'
                    xline(datenum('16-Apr-2003'));
                    xline(datenum('1-Aug-2005'));xline(datenum('1-Sep-2018'));
                case 'IDR'; xline(datenum('1-Jul-2005'));
                case 'KRW'; xline(datenum('13-Jun-2010'));
                case 'PHP'; xline(datenum('1-Jan-2002'));
                case 'PLN'; xline(datenum('16-Apr-2003')); xline(datenum('28-Jul-2017'));
                case 'RUB'; xline(datenum('27-Sep-2013'));
                case 'THB'; xline(datenum('1-Dec-2006'));
                case 'TRY'
                    xline(datenum('1-Jan-2006'));  xline(datenum('27-Jan-2017'));
                    xline(datenum('24-Jun-2018')); xline(datenum('2-Oct-2018')); 
            end
            end
        end
    end
    figname = [fldname{k1} '_local']; save_figure(figdir,figname,formats,figsave)
end

close all

%% Compare TP (different versions, same variable): ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
% sgmS baseline vs free: differences due to convergence, check fit for BRL-COP-MYR
fldtype1 = 'mssb_';   fldvar  = 'tp';
fldtype2 = 'mssf_';   fldname = [fldtype2 fldvar];
if isfield(S,fldname)                                                   % fldname exists only if free sgmS case was ran
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic with Surveys Fixed','Synthetic with Surveys Free'},...
    'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)
end

% Synthetic vs nominal: yields only (gains from synthetic)
fldtype1 = 'msy_';   fldvar  = 'tp';
fldtype2 = 'mny_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic Yields Only','Nominal Yields Only'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic vs nominal: surveys (gains from synthetic)
fldtype1 = 'mssb_';   fldvar  = 'tp';
fldtype2 = 'mnsb_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic with Surveys','Nominal with Surveys'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Nominal: surveys vs yields (gains from surveys)
fldtype1 = 'mnsb_';   fldvar = 'tp';
fldtype2 = 'mny_';   fldname = [fldtype1 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Nominal with Surveys','Nominal Yields Only'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic: surveys vs yields (gains from surveys)
fldtype1 = 'mssb_';	fldvar  = 'tp';
fldtype2 = 'msy_';   fldname = [fldtype1 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic with Surveys','Synthetic Yields Only'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic surveys vs nominal yields (gains from both)
fldtype1 = 'mssb_';	fldvar  = 'tp';
fldtype2 = 'mny_';   fldname = [fldtype1 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic with Surveys','Nominal Yields Only'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

    % AEs
% Synthetic vs nominal: yields only (gains from synthetic)
fldtype1 = 'mny_';   fldvar  = 'tp';
fldtype2 = 'msy_';   fldname = [fldtype2 fldvar];
figure; k2 = 0;
for k0 = nEMs+1:nEMs+nAEs
    if ~isempty(S(k0).(fldname))
        k2 = k2 + 1;
        subplot(2,5,k2)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == nEMs+2
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0); if ismember(k2,[1,6]); ylabel('%'); end
    end
end
figname = [fldtype1 fldtype2 fldvar '_AE']; save_figure(figdir,figname,formats,figsave)

close all

%% Model fit to synthetic
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;

    % Monthly data
fldname = {'ms_blncd','bsl_yQ'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25); hold on
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end)*100,'-.','LineWidth',1.25);    % 10Y
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend({'Observed','Fitted'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 's_ylds_bsl_yQ'; save_figure(figdir,figname,formats,figsave)

    % Daily data
fldname = {'ds_blncd','d_yQ'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,'LineWidth',1.25); hold on
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end)*100,'--','LineWidth',1.25);    % 10Y
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend({'Observed','Fitted'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 's_ylds_d_yQ'; save_figure(figdir,figname,formats,figsave)

close all

%% Residuals of synthetic: Actual minus fitted
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;

    % Monthly data: 10Y
fldname = {'ms_blncd','bsl_yQ','bsl_cr'};                                   % for monthly: {'ms_blncd','bsl_yQ','bsl_cr'};
yr      = 10;
rescrc  = nan(nEMs,1);
figure
for k0 = 1:nEMs
    aux1 = S(k0).(fldname{1});
    aux2 = S(k0).(fldname{2});
    aux3 = S(k0).(fldname{3});
    ttaux1 = array2timetable(aux1(2:end,aux1(1,:) == yr),'RowTimes',datetime(aux1(2:end,1),'ConvertFrom','datenum'));
    ttaux2 = array2timetable(aux2(2:end,aux2(1,:) == yr),'RowTimes',datetime(aux2(2:end,1),'ConvertFrom','datenum'));
    ttaux3 = array2timetable(aux3(2:end,aux3(1,:) == yr),'RowTimes',datetime(aux3(2:end,1),'ConvertFrom','datenum'));
    ttaux  = synchronize(ttaux1,ttaux2);
    ttaux.res = ttaux.(1) - ttaux.(2);                               	% actual minus fitted
    ttaux = removevars(ttaux,contains(ttaux.Properties.VariableNames,{'ttaux1','ttaux2'}));
    ttcor = synchronize(ttaux,ttaux3);
    ttcor = rmmissing(ttcor);
    ttcor(abs(ttcor{:,2}) < 0.0002,:) = [];                             % drop small CRC (<2 bps) o/w exaggerate ratio below 
    rescrc(k0) = mean(ttcor{:,1}./ttcor{:,2})*100;                      % in basis points
    %[rho,pval] = corr(ttcor{:,:},'rows','complete');                    % corr b/w CRC and residual
    %sprintf([S(k0).iso ': corr Res-CRC is %0.4f with a p-value of %0.4f'],rho(2,1),pval(2,1))
end
sprintf('EM: Residual as pct of CRC: %d',mean(abs(rescrc)))

    % Daily data: 10Y
fldname = {'ds_blncd','d_yQ','d_cr'};                                   % for monthly: {'ms_blncd','bsl_yQ','bsl_cr'};
yr      = 10;
figure
for k0 = 1:nEMs
    aux1 = S(k0).(fldname{1});
    aux2 = S(k0).(fldname{2});
    ttaux1 = array2timetable(aux1(2:end,aux1(1,:) == yr),'RowTimes',datetime(aux1(2:end,1),'ConvertFrom','datenum'));
    ttaux2 = array2timetable(aux2(2:end,aux2(1,:) == yr),'RowTimes',datetime(aux2(2:end,1),'ConvertFrom','datenum'));
    ttaux  = synchronize(ttaux1,ttaux2);
    ttaux.res = ttaux.(1) - ttaux.(2);                               	% actual minus fitted
    ttaux = removevars(ttaux,contains(ttaux.Properties.VariableNames,{'ttaux1','ttaux2'}));
    
    subplot(3,5,k0)
    plot(ttaux.Time,ttaux.res*10000,'LineWidth',1.25)                  	% in basis points
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('Basis Points'); end
end
lgd = legend({'Residual'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 's_residual'; save_figure(figdir,figname,formats,figsave)

close all

%% Comparing yP vs surveys_CBP (assess fit + benefits of surveys)
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
% mssb_yP (surveys) vs surveys_CBP 
fldname = {'bsl_yP','scbp'};
figure
for k0 = 1:nEMs
    dtmn  = datesminmax(S,k0);
    subplot(3,5,k0)
    fltrt = S(k0).(fldname{1})(1,:) == 10;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltrt)*100,'LineWidth',1.25);
    if ~isempty(S(k0).(fldname{2}))
        fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
        hold on; plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end),'*','LineWidth',0.6);  % 10Y
    end
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend('Model','Forecast','Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname{1} '_' fldname{2}]; save_figure(figdir,figname,formats,figsave)

% msy_yP (yields only) vs surveys_CBP
fldname = {'msy_yP','scbp'};
figure
for k0 = 1:nEMs
    dtmn  = datesminmax(S,k0);
    subplot(3,5,k0)
    fltrt = S(k0).(fldname{1})(1,:) == 10;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltrt)*100,'LineWidth',1.25);
    if ~isempty(S(k0).(fldname{2}))
        fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
        hold on; plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end),'*','LineWidth',0.6);  % 10Y
    end
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
end
lgd = legend('Model Yields Only','Surveys','Orientation','horizontal','location','best','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname{1} '_' fldname{2}]; save_figure(figdir,figname,formats,figsave)

close all

%% Real rate = yP - svyINF
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
TT_rr = read_spf();                                                         % US real rates forecasts

    % Long-term
fldname = 'rrt';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100,'LineWidth',1.25)       % 10Y
        title(S(k0).cty);
        datetick('x','yy'); yline(0); ylim([-4 8]); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lgd = legend({'10-Year Domestic Short-Term Real Rate'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_LT']; save_figure(figdir,figname,formats,figsave)

    % Long-term EMRR vs USRR
fldname = 'rrt';
% TT_rr   = read_spf();
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100,'LineWidth',1.25); hold on       % 10Y
        fltrUS = datenum(TT_rr.Time) >= S(k0).(fldname)(2,1) & datenum(TT_rr.Time) <= S(k0).(fldname)(end,1);
        plot(datenum(TT_rr.Time(fltrUS)),TT_rr.USRR10Y(fltrUS),'-.','LineWidth',1.25)
        hold off
        title(S(k0).cty);
        datetick('x','yy'); yline(0); ylim([-4 8]); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lgd = legend({'10-Year Domestic Short-Term Real Rate','10-Year U.S. Short-Term Real Rate'},...
    'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_LTvsUSrrt']; save_figure(figdir,figname,formats,figsave)

    % All tenors
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,2:end)*100,'LineWidth',1)
        title(S(k0).cty);
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lgd = legend(strcat(cellfun(@num2str,num2cell(S(k0).(fldname)(1,2:end)),'UniformOutput',false),'Y'),...
    'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_all']; save_figure(figdir,figname,formats,figsave)

close all

%% TP survey = sy - sCBP
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;

    % Long-term TPsvy
fldname = 'stp';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100)
        title(S(k0).cty); 
        datetick('x','yy'); yline(0); ylim([-2 7]); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lgd = legend({'10-Year Survey-Based Term Premium'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = fldname; save_figure(figdir,figname,formats,figsave)

    % Compare TPsynt vs TPsvy: robustness check of TP estimates
fldname = {'stp','bsl_tp'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100);    % 10Y
    if ~isempty(S(k0).(fldname{2}))
        hold on; plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end)*100);
    end
    title(S(k0).cty);
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end % ylim([-2 10]);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend({'10-Year Survey-Based Term Premium','10-Year Model-Implied Term Premium'},...
    'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname{1} '_svy']; save_figure(figdir,figname,formats,figsave)

close all

%% Synthetic vs nominal yP
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
    % Surveys: similar yP supports BRP = TP + CR
fldtype1 = 'mssb_';   fldvar = 'yP';
fldtype2 = 'mnsb_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);  % 10Y
        title(S(k0).cty)
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic Yields and Surveys','Nominal Yields and Surveys'},...
    'Orientation','horizontal','AutoUpdate','off'); % 10-Year Average Short Rate
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

    % Yields only: discrepancy supports using surveys
fldtype1 = 'mssb_';   fldvar  = 'yP';
fldtype2 = 'msy_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end)*100,...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end)*100);  % 10Y
        title(S(k0).cty)
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
    end
end
lgd = legend({'Synthetic Yields and Surveys','Synthetic Yields Only'},...
    'Orientation','horizontal','AutoUpdate','off'); % 10-Year Average Short Rate
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

close all

%% Term structure
% Term premia
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
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
            plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,posTNR(k1))*100,lstyle{k1},'LineWidth',1)
        end
        hold off
        title(S(k0).cty); 
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lbl = cellfun(@num2str,num2cell(S(k0).(fldname)(1,fltrTNR)),'UniformOutput',false);
lbl = {[lbl{1} ' Year'],[lbl{2} ' Years'],[lbl{3} ' Years']};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');            % TS of Term Premia
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_ts']; save_figure(figdir,figname,formats,figsave)

% Credit risk  premia
fldname = 'mc_blncd';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        fltrTNR = ismember(S(k0).(fldname)(1,:),[1 5 10]);
        posTNR  = find(fltrTNR);
        hold on
        for k1 = 1:length(posTNR)
            plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,posTNR(k1))*100,lstyle{k1},'LineWidth',1)
        end
        hold off
        title(S(k0).cty); 
        datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lbl = cellfun(@num2str,num2cell(S(k0).(fldname)(1,fltrTNR)),'UniformOutput',false);
lbl = {[lbl{1} ' Year'],[lbl{2} ' Years'],[lbl{3} ' Years']};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');            % TS of Credit Risk Compensation
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_ts']; save_figure(figdir,figname,formats,figsave)

close all

%% Plot bond risk premia
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
% BRP: compensation for risk in EMs
fldname = 'brp';
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100)           % 10Y
    title(S(k0).cty); 
    datetick('x','yy'); yline(0); ylim([-2 10]); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = fldname; save_figure(figdir,figname,formats,figsave)

% BRP components: relative importance
figure
for k0 = 1:nEMs
    fldname = {'brp','bsl_tp','mc_blncd'};
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100,...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100,...
         S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:) == 10)*100)   % 10Y
    title(S(k0).cty)
    if k0 == 13
        legend('BRP','TP','LCCS','Orientation','horizontal','Location','south','AutoUpdate','off'); 
    end
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end % ylim([-2 10]);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'brp_dcmp'; save_figure(figdir,figname,formats,figsave)

% Compare BRP vs TPnom: if similar, supports LCNOM gives biased estimates of TP
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).mssb_tp)
        fldname = {'brp','mnsb_tp'};
    else
        fldname = {'brp','mny_tp'};
    end
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100,...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100)   % 10Y
    title(S(k0).cty)
    if k0 == 14; legend('BRP','TPnom','AutoUpdate','off'); end
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'brp_ntp'; save_figure(figdir,figname,formats,figsave)

close all

%% Nominal YC decomposition: drivers of yields
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
    % EM: monthly
fldname = {'bsl_yP','bsl_tp','bsl_cr'};
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:nEMs
    subplot(3,5,k0)                             % 10Y
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:)==10)*100,'-','LineWidth',1);
    hold on
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:)==10)*100,'-.','LineWidth',1);
%   plot(S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:)==10)*100,'--','LineWidth',1);
    crcts = S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:)==10);
    crcts(crcts < 0) = 0;
    plot(S(k0).(fldname{3})(2:end,1),crcts*100,'--','LineWidth',1);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Expected Short Rate','Term Premium','Credit Risk Compensation'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'ny_dcmp'; save_figure(figdir,figname,formats,figsave)

    % AE
fldname = {'bsl_yP','bsl_tp'};  k1 = 0;
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = nEMs+1:nEMs+nAEs
    k1 = k1 + 1;
    subplot(2,5,k1)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:)==10)*100,'-','LineWidth',1);
    hold on;
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:)==10)*100,'-.','LineWidth',1);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k1,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Expected Short Rate','Term Premium'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'ny_dcmp_AE'; save_figure(figdir,figname,formats,figsave)

close all

%% Compare estimated CRC versus DS LCCS
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
    % Monthly frequency
fldname = {'bsl_cr','mc_blncd'};
tnr = 10;
corrcrclccs = nan(nEMs,1);
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    var1 = S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == tnr)*100;
    var2 = S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == tnr)*100;
    plot(S(k0).(fldname{1})(2:end,1),var1,S(k0).(fldname{2})(2:end,1),var2);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
    ttaux1 = array2timetable(var1,'RowTimes',datetime(S(k0).(fldname{1})(2:end,1),'ConvertFrom','datenum'));
    ttaux2 = array2timetable(var2,'RowTimes',datetime(S(k0).(fldname{2})(2:end,1),'ConvertFrom','datenum'));
    ttaux = synchronize(ttaux1,ttaux2,'intersection');
    corrcrclccs(k0) = corr(ttaux{:,1},ttaux{:,2},'rows','complete');
end
sprintf('EM: Average Corr. CRC-LCCS: %d', mean(corrcrclccs))
lbl = {'Own','DS'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'crc_lccs'; save_figure(figdir,figname,formats,figsave)

    % Daily frequency
fldname = {'d_cr','dc_blncd'};
tnr = 10;
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    var1 = S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == tnr)*100;
    var2 = S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == tnr)*100;
    plot(S(k0).(fldname{1})(2:end,1),var1,S(k0).(fldname{2})(2:end,1),var2);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[1,6,11]); ylabel('%'); end
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Own','DS'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'crc_lccs_dy'; save_figure(figdir,figname,formats,figsave)

close all

%% Compare estimated CRC versus CDS
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
TT_cds  = read_cds();
    % EM: daily
fldname = 'd_cr';                                                   % bsl_cr
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:nEMs
    subplot(3,5,k0)
    yyaxis left
    crcts = S(k0).(fldname)(2:end,S(k0).(fldname)(1,:)==5);         % 5Y
    crcts(crcts < 0) = 0;
    ttaux = array2timetable(crcts*100,'RowTimes',datetime(S(k0).(fldname)(2:end,1),'ConvertFrom','datenum'));
    ttaux = synchronize(ttaux,TT_cds(:,k0),'intersection');
    plot(ttaux.Time,ttaux.(1),'-','LineWidth',0.6);
    if ismember(k0,[1,6,11]); ylabel('%'); end
    hold on
    yyaxis right
    plot(ttaux.Time,ttaux.(2),'-.','LineWidth',0.6);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k0,[5,10,15]); ylabel('Basis Points'); end
end
lbl = {'Credit Risk Compensation (in LC) (LHS)','CDS (in USD) (RHS)'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'crc_cds_EM'; save_figure(figdir,figname,formats,figsave)

    % GER: daily
fldname = 'd_cr';                                                   % bsl_cr
figure                             
    k0 = 20;                                                        % Germany
    yyaxis left
    crcts = S(k0).(fldname)(2:end,S(k0).(fldname)(1,:)==5);         % 5Y
    %crcts(crcts < 0) = 0;
    ttaux = array2timetable(crcts*100,'RowTimes',datetime(S(k0).(fldname)(2:end,1),'ConvertFrom','datenum'));
    ttaux = synchronize(ttaux,TT_cds(:,17),'intersection');         % Germany
    plot(ttaux.Time,ttaux.(1),'-','LineWidth',0.6);
    ylabel('%')
    hold on
    yyaxis right
    plot(ttaux.Time,ttaux.(2),'-.','LineWidth',0.6);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); ylabel('Basis Points')
    corrcrcds = corr(ttaux{:,1},ttaux{:,2},'rows','complete');
    text(datetime(2018,1,1),110,['Corr: ' num2str(round(corrcrcds,3))])
lbl = {'CIP Deviation (EUR in %) (LHS)','CDS (USD in basis points) (RHS)'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0010 0.2554 0.05],'Units','normalized')
figname = 'crc_cds_GER'; save_figure(figdir,figname,formats,figsave)

    % AE
fldname = 'd_cr';                                                   % bsl_cr
figure
for k0 =[16, 20, 21, 22]
    if k0 == 16
        k1 = k0;
        k2 = 1;
    else
        k1 = k1 + 1;
        k2 = k2 + 1;
    end
    subplot(2,2,k2)
    yyaxis left
    crcts = S(k0).(fldname)(2:end,S(k0).(fldname)(1,:)==5);         % 5Y
    %crcts(crcts < 0) = 0;
    ttaux = array2timetable(crcts*100,'RowTimes',datetime(S(k0).(fldname)(2:end,1),'ConvertFrom','datenum'));
    ttaux = synchronize(ttaux,TT_cds(:,k1),'intersection');
    plot(ttaux.Time,ttaux.(1),'-','LineWidth',0.6);
    if ismember(k2,[1,3]); ylabel('%'); end
    hold on
    yyaxis right
    plot(ttaux.Time,ttaux.(2),'-.','LineWidth',0.6);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); if ismember(k2,[2,4]); ylabel('Basis Points'); end
    %corr(ttaux{:,1},ttaux{:,2},'rows','complete')
end
lbl = {'CIP Deviation (LC in %) (LHS)','CDS (USD in basis points) (RHS)'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0010 0.2554 0.05],'Units','normalized')
figname = 'crc_cds_AE'; save_figure(figdir,figname,formats,figsave)

close all

%% Components with confidence bands
    % EM
figdir = 'Estimation'; formats = {'eps'}; %figsave = false;
vars   = {'yQ','yP','tp','cr'};
names  = {'Fitted Yields','Expected Short Rate','Term Premium','Credit Risk Compensation'};
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
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
    end
    lbl = {names{k0},'Confidence Bands'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = [fldname{1} '_CI_' num2str(tnr) 'y_V1']; save_figure(figdir,figname,formats,figsave)
end

    % AE
vars   = {'yQ','yP','tp'};
names  = {'Fitted Yields','Expected Short Rate','Term Premium'};
tnr    = 10;
for k0 = 1:length(vars)
    fldname = {['bsl_' vars{k0}],['bsl_' vars{k0} '_se']};
    figure
    k2 = 0;
    for k1 = nEMs+1:length(S)
        k2 = k2 + 1;
        subplot(2,5,k2)
        var   = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == tnr)*100;
        varse = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == tnr)*100;
        plot(S(k1).(fldname{1})(2:end,1),var,'-','LineWidth',1.25); hold on
        plot(S(k1).(fldname{2})(2:end,1),var - 2*varse,'--','Color', [0.6 0.6 0.6],'LineWidth',0.75)
        plot(S(k1).(fldname{2})(2:end,1),var + 2*varse,'--','Color', [0.6 0.6 0.6],'LineWidth',0.75); hold off
        title(S(k1).cty)
        datetick('x','yy'); yline(0); if ismember(k2,[1,6,11]); ylabel('%'); end
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
    end
    lbl = {names{k0},'Confidence Bands'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = [fldname{1} '_CI_' num2str(tnr) 'y_V1_AE']; save_figure(figdir,figname,formats,figsave)
end

%% Plot TP against LCCS, USTP, VIX, EPU, INF
figdir  = 'Estimation'; formats = {'eps'}; %figsave = false;
% TP vs LCCS: negative relationship
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp','mc_blncd'};
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100)
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('TP','LCCS','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_lccs'; save_figure(figdir,figname,formats,figsave)            % update reference to figure

% TP vs USTP: US TP as potential driver of EM TP
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp'};
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100)   % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(kwtp(2:end,1),kwtp(2:end,end))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 13; legend('TP','USTP','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_ustp'; save_figure(figdir,figname,formats,figsave)            % update reference to figure

% TP vs VIX: relationship w/ measures of risk and uncertainty
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp'};
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(vix(:,1),vix(:,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 6; legend('TP','VIX','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_vix'; save_figure(figdir,figname,formats,figsave)             % update reference to figure

% TP vs EPU: relationship w/ measures of uncertainty
figure; k2 = 0;
for k0 = 1:nEMs
    if ~isempty(S(k0).epu)
        k2 = k2 + 1;
        fldname = {'bsl_tp','epu'};
        [~,dtmx] = datesminmax(S,k0);
        fltrd = S(k0).(fldname{2})(:,1) > dtmx;
        subplot(3,2,k2)
        yyaxis left
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
        set(gca,'ytick',[])
        yyaxis right
        plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
        set(gca,'ytick',[])
        title(S(k0).cty)
        if k2 == 5; legend('TP','EPU','Orientation','horizontal','AutoUpdate','off'); end
        datetick('x','yy'); yline(0);
%         L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
figname = 'tp_epu'; save_figure(figdir,figname,formats,figsave)             % update reference to figure

% TP vs INF
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp','inf'};
    [~,dtmx] = datesminmax(S,k0);
    fltrd = S(k0).(fldname{2})(:,1) > dtmx;
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('TP','INF','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_inf'; save_figure(figdir,figname,formats,figsave)             % update reference to figure

% TP vs inflation volatility
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp','sdprm'};                                           % std of permanent component
    [~,dtmx] = datesminmax(S,k0);
    fltrd = S(k0).(fldname{2})(:,1) > dtmx;
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('TP','SDPRM','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
%     L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_sdprm'; save_figure(figdir,figname,formats,figsave)

close all

%% Fitting error in CRC
tenor = 0.25;
fname = {'d_cr','d_crds'};
rprt = nan(nEMs,4);
figure
for k0 = 1:nEMs
    mrgdtst = syncdatasets(S(k0).(fname{1}),S(k0).(fname{2}));
    fltr = ismember(mrgdtst(1,:),tenor);
    aux = mrgdtst(:,fltr);
    crcdiff = (aux(2:end,1) - aux(2:end,2))*10000;      % in basis points
    rprt(k0,:) = [mean(crcdiff) std(crcdiff) min(crcdiff) max(crcdiff)];
    subplot(3,5,k0)
    plot(mrgdtst(2:end,1),crcdiff); ylim([-100 100])
    datetick('x','yy'); if ismember(k0,[1,6,11]); ylabel('Basis Points'); end
end

close all

%% Rolling correlations (daily frequency): Yield components
figdir  = 'Estimation'; formats = {'eps','fig'}; %figsave = false;

    % AE + EM (nominal, synthetic)
tenor  = 10;
fname  = {'dn_data','ds_data'};
lstyle = {'-','-.','--'};
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:length(fname)
    rollcorr = rollingcorrs(S,currEM,fname{k0},tenor);
    plot(rollcorr(:,1),rollcorr(:,2),lstyle{k0},'LineWidth',1); hold on
end
k0 = 1;
rollcorr = rollingcorrs(S,currAE,fname{k0},tenor);
plot(rollcorr(:,1),rollcorr(:,2),lstyle{end},'LineWidth',1); hold on
datetick('x','yy'); hold off
lbl = {'Emerging Markets - Nominal','Emerging Markets - Synthetic','Advanced Economies - Nominal'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['rolling' num2str(tenor) 'y_nomsyn']; save_figure(figdir,figname,formats,figsave)

    % EM
tenor  = 10;
fname  = {'d_yP','d_tp','d_cr'};
lstyle = {'-','-.','--'};
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:length(fname)
    rollcorr = rollingcorrs(S,currEM,fname{k0},tenor);
    plot(rollcorr(:,1),rollcorr(:,2),lstyle{k0},'LineWidth',1); hold on
end
datetick('x','yy'); hold off
lbl = {'Exp. Short Rate','Term Premium','Credit Risk Compensation'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['rolling' num2str(tenor) 'y_dcmp']; save_figure(figdir,figname,formats,figsave)

    % AE
tenor  = 10;
fname  = {'dn_data','d_yP','d_tp'};
lstyle = {'-','-.','--'};
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:length(fname)
    rollcorr = rollingcorrs(S,currAE,fname{k0},tenor);
    plot(rollcorr(:,1),rollcorr(:,2),lstyle{k0},'LineWidth',1); hold on
end
datetick('x','yy'); hold off
legend({'Nominal Yield','Exp. Short Rate','Term Premium'},'Location','best','AutoUpdate','off');
figname = ['rolling' num2str(tenor) 'y_dcmp_AE']; save_figure(figdir,figname,formats,figsave)

close all

%% Rolling correlations (daily frequency): Term structure
figdir  = 'Estimation'; formats = {'eps','fig'}; %figsave = false;
fname   = {'dn_data'}; % {'dn_data','d_yP','d_tp','d_cr'};
lstyle  = {'-','-.','--',':'};
tenor   = [10 5 1 0.25];
lbl     = {'10 Years','5 Years','1 Year','3 Months'};

    % EM
for k0 = 1:length(fname)
    figure
    if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
    for k1 = 1:length(tenor)
        rollcorr = rollingcorrs(S,currEM,fname{k0},tenor(k1));
        plot(rollcorr(:,1),rollcorr(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['rolling_' fname{k0}]; save_figure(figdir,figname,formats,figsave)
end

    % AE
for k0 = 1:length(fname)
    figure
    if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
    for k1 = 1:length(tenor)
        rollcorr = rollingcorrs(S,currAE,fname{k0},tenor(k1));
        plot(rollcorr(:,1),rollcorr(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['rolling_' fname{k0} '_AE']; save_figure(figdir,figname,formats,figsave)
end

%% Rolling correlations w/ US yield curve (daily frequency): Term structure
figdir  = 'Estimation'; formats = {'eps','fig'}; %figsave = false;
fname   = {'dn_data'}; % {'dn_data','d_yP','d_tp','d_cr'};
lstyle  = {'-','-.','--',':'};
tenor   = [10 5 1 0.25];
lbl     = {'10 Years','5 Years','1 Year','3 Months'};

    % EM
for k0 = 1:length(fname)
    figure
    for k1 = 1:length(tenor)
        rollcorr = rollingcorrsus(S,currEM,fname{k0},tenor(k1));
        plot(rollcorr(:,1),rollcorr(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['rollingUS_' fname{k0}]; save_figure(figdir,figname,formats,figsave)
end

    % AE
for k0 = 1:length(fname)
    figure
    for k1 = 1:length(tenor)
        rollcorr = rollingcorrsus(S,currAE,fname{k0},tenor(k1));
        plot(rollcorr(:,1),rollcorr(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['rollingUS_' fname{k0} '_AE']; save_figure(figdir,figname,formats,figsave)
end

%% DY index (daily frequency): Yield components
figdir  = 'Estimation'; formats = {'eps','fig'}; %figsave = false;

    % AE + EM (nominal, synthetic)
tenor = 10;
fldname = {'dn_data','ds_data'};
lstyle  = {'-','-.','--'};
datemin = datenum('31-Jan-2019');
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
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
figname = ['dy_index' num2str(tenor) 'y_nomsyn']; save_figure(figdir,figname,formats,figsave)

    % EM
tenor = 10;
fldname = {'d_yP','d_tp','dc_data'};
lstyle  = {'-','-.','--'};
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currEM(~contains(currEM,{'BRL','KRW','PHP','THB'})),fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0},'LineWidth',1); hold on
end
datetick('x','yy'); ylabel('%'); hold off
lbl = {'Exp. Short Rate','Term Premium','Credit Risk Compensation'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_dcmp']; save_figure(figdir,figname,formats,figsave)

    % AE
fldname = {'dn_data','d_yP','d_tp'};
figure
if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currAE(~contains(currAE,{'NOK'})),fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0},'LineWidth',1); hold on
end
datetick('x','yy'); ylabel('%'); hold off
legend({'Nominal Yield','Exp. Short Rate','Term Premium'},'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_dcmp_AE']; save_figure(figdir,figname,formats,figsave)

%% DY index (daily frequency): Term structure
figdir  = 'Estimation'; formats = {'eps','fig'}; %figsave = true;
fldname = {'dn_data'}; % {'dn_data','d_yP','d_tp','d_cr'};
lstyle  = {'-','-.','--',':'};
tenor   = [10 5 1 0.25];
lbl     = {'10 Years','5 Years','1 Year','3 Months'};

    % EM
for k0 = 1:length(fldname)
    figure
    if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
    for k1 = 1:length(tenor)
        [DYindex,DYtable] = ts_dyindex(S,currEM(~contains(currEM,{'PHP'})),fldname{k0},tenor(k1));
        disp([fldname{k0} ' ' num2str(tenor(k1))])
        disp(DYtable)
        plot(DYindex(:,1),DYindex(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); ylabel('%'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['dy_index_' fldname{k0}]; save_figure(figdir,figname,formats,figsave)
end

    % AE
for k0 = 1:length(fldname)
    figure
    if datenum(version('-date')) >= datenum('11-Sept-2019'); colororder(clrplt) ; end
    for k1 = 1:length(tenor)
        [DYindex,DYtable] = ts_dyindex(S,currAE,fldname{k0},tenor(k1));
        disp([fldname{k0} ' ' num2str(tenor(k1))])
        disp(DYtable)
        plot(DYindex(:,1),DYindex(:,2),lstyle{k1},'LineWidth',1); hold on
    end
    datetick('x','yy'); ylabel('%'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['dy_index_' fldname{k0} '_AE']; save_figure(figdir,figname,formats,figsave)
end

%% Plot yield curves
% k0 = 1;                                                                     % country
% matrix = S(k0).ms_blncd;                                                    % synthetic
% dates  = matrix(2:end,1);
% tenors = matrix(1,2:end);
% ylds   = matrix(2:end,2:end);
% H      = nan(length(dates),1);
% for k1 = 1:length(dates)
%     plot(tenors,ylds(k1,:)*100,'b')
%     title(datestr(dates(k1)))
%     H(k1) = getframe(gcf);
% end
% 
% movie(H,1,2);                                                               % play
% imshow(H(2).cdata);                                                         % one frame

%% Sources

% Hold on a legend in a plot
% https://www.mathworks.com/matlabcentral/answers/...
% 9434-how-can-i-hold-the-previous-legend-on-a-plot
% plot(S(k).(fnames{l})(:,1),S(k).(fnames{l})(:,2),'DisplayName',S(k).iso)
% if k == 1; legend('-DynamicLegend'); hold all; else; hold all; end

% Set the subplot position without worrying about the outside legends
% https://www.mathworks.com/matlabcentral/answers/...
% 300188-how-do-i-set-the-subplot-position-without-worrying-about-the-outside-legends

% Setting and extracting position vector of legend
% https://www.mathworks.com/matlabcentral/answers/12555-legend-position-on-a-plot

% Recession shaded areas
% https://www.mathworks.com/matlabcentral/answers/243194-shade-an-area-in-a-plot-between-two-y-values

% Select a Color from a Gradient
% https://www.mathworks.com/help/matlab/ref/uisetcolor.html#mw_1bc83bef-7644-4f22-9acf-7e3d589d26bf

% Data color picker
% https://learnui.design/tools/data-color-picker.html#palette