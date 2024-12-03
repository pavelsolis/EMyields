function corrsprd = plot_spreads(dataset_daily,header_daily,currEM,currAE,figstop,figsave)
% PLOT_SPREADS Plot local and foreign currency interest rate spreads, the forward
% premium and deviations from covered interest rate parity (CIP)
%   corrsprd: pair-wise correlations of forward premium and CIP deviations

% m-files called: save_figure
% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
LCs    = [currEM;currAE];
dates  = dataset_daily(:,1);
figdir = 'Spreads'; formats = {'eps'};

if figstop || figsave
%% Spreads per maturity for each country
types  = {'RHO','CIPDEV','LCSPRD','FCSPRD'};
years  = {'1','5','10'};
fltrTP = ismember(header_daily(:,2),types);             % report specific types
for k0 = 1:numel(years)
    fltrYR = ismember(header_daily(:,5),years{k0});    	% report a specific year
    for k1 = 1:numel(LCs)
        fltrLC  = ismember(header_daily(:,1),LCs{k1});
        fltr    = fltrLC & fltrTP & fltrYR;            	% criteria to meet
        sprds   = dataset_daily(:,fltr);
        sprdsMA = movmean(sprds,10);                   	% to report results as in Du & Schreger (2016)
        labels  = header_daily(fltr,2);                	% types available for the currency
        figure
        plot(dates,sprdsMA);
        title(['Spreads: ' LCs{k1} ' ' years{k0} 'Y'])
        ylabel('%')
        legend(labels,'AutoUpdate','off')
        datetick('x','yy','keeplimits')              	% annual ticks
        yline(0);                                       % horizontal line at the origin
        figname = ['sprds_' years{k0} 'y_' LCs{k1}];
        save_figure(figdir,figname,formats,figsave)
    end
    if figstop == true; input([LCs{k1} ' ' years{k0} 'Y displayed. Press Enter key to continue.']); end
    close all
end

%% Spreads per country across maturities
keydates = datenum(['30-Sep-2008';'31-May-2013';'30-Nov-2016']);
fltrYR   = ismember(header_daily(:,5),years);           % report specific years
for j0 = 1:numel(LCs)
    fltrLC = ismember(header_daily(:,1),LCs{j0});
    for j1 = 1:numel(types)
        fltrTP = ismember(header_daily(:,2),types{j1}); % report a specific type
        fltr   = fltrLC & fltrTP & fltrYR;              % criteria to meet
        if sum(fltr) > 0                                % some countries don't have the specified type
            sprds   = dataset_daily(:,fltr);
            sprdsMA = movmean(sprds,10);
            labels  = strcat(header_daily(fltr,5),'Y'); % tenors of the spreads
            figure
            plot(dates,sprdsMA);
            legend(labels,'Location','best','Orientation','horizontal','AutoUpdate','off')
            title([LCs{j0} ' ' types{j1}])
            ylabel('%')
            datetick('x','yy','keeplimits')
            line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','-.');
            yline(0);                                   % horizontal line at the origin
            figname = ['ts_' LCs{j0} '_' types{j1}];    % term structure per type
            save_figure(figdir,figname,formats,figsave)
        end
    end
    if figstop == true; input(['TS ' LCs{j0} ' ' types{j1} ' displayed. Press Enter key to continue.']); end
    close all
end

end

%% Spreads per maturity across countries
% To see whether spreads are correlated across countries in the sample

types = {'RHO','CIPDEV'};
years = {'1','5','10'};
group = {currEM,currAE};
n0    = numel(types);   n1 = length(group);  n2 = numel(years);
corrsprd = cell(n2,n0*n1,2);
for l0 = 1:n0
    for l1 = 1:n1
        fltrGP  = ismember(header_daily(:,1),group{l1});
        for l2 = 1:n2
            fltrTY  = ismember(header_daily(:,2),types{l0}) & ismember(header_daily(:,5),years{l2});
            fltr    = fltrGP & fltrTY;
            sprds   = dataset_daily(:,fltr);
            sprdsMA = movmean(sprds,10);
            labels  = header_daily(fltr,1);            	% countries
            figure
            plot(dates,sprdsMA)
            title(['G' num2str(l1) ': ' types{l0} ' ' years{l2} 'Y'])
            ylabel('%')
            legend(labels,'Location','best','Orientation','horizontal','NumColumns',5,'AutoUpdate','off')
            datetick('x','yy','keeplimits')
            yline(0);                                 	% horizontal line at the origin
            figname = ['g' num2str(l1) '_' types{l0} '_' years{l2} 'y'];
            save_figure(figdir,figname,formats,figsave)
            [corrsprd{l2,n0*(l0-1)+l1,1},corrsprd{l2,n0*(l0-1)+l1,2}] = corrcoef(sprds,'Rows','complete');
            % rows (1Y,5Y,10Y), cols (RHO (G1,G2),CIP (G1,G2)), 3D (correlations omit NaN rows, p-values)
        end
    end
    if figstop == true; input(['G ' types{l0} ' ' years{l2} 'Y displayed. Press Enter key to continue.']); end
    close all
end