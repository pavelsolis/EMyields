function Scorr = compare_cip(dataset_daily,header_daily,curncs,TTcip,figstop,figsave)
% COMPARE_CIP Compare own CIP Calculations with those of Du, Im & Schreger (2018)
%   Scorr: structure with the correlations for each type at each tenor

% Pavel Solís (pavel.solis@gmail.com), April 2020
%% Prepare dataset and tenors
Scorr = cell2struct(curncs','ccy');                 % assign each currency to a structure with field ccy
TTcip.cip_govt = TTcip.cip_govt(:)/100;             % express cip_govt in percentages instead of bps

tnrscell = categories(TTcip.tenor);                 % tenors as a cell array
tnrsnum  = tnrscell;
tnrsnum{contains(tnrsnum,'3m')} = '0.25y';          % express all tenors in years
tnrsnum  = cellfun(@str2num,strrep(tnrsnum,'y',''));% remove 'y' and convert to numbers
[tnrsnum,idx] = sort(tnrsnum);                      % sort all tenors in ascending order
tnrscell = tnrscell(idx);                           % reorder cell array of tenors in ascending order
ntnrs    = length(tnrscell);

%% diff_y = rho + cip_govt
% TTcip.lcsprd   = TTcip.rho(:) + TTcip.cip_govt(:);  % define the LC spread
% for k0 = 1:length(curncs)
%     close all
%     for k1 = 1:length(tnrscell)
%         figure
%         fltr0 = TTcip.currency == curncs{k0} & TTcip.tenor == tnrscell{k1};
%         plot(TTcip.date(fltr0),[TTcip.diff_y(fltr0),TTcip.lcsprd(fltr0)]);
%         title([curncs{k0} ' ' tnrscell{k1}])
%     end
%     if figstop; input(['LC spread for ' curncs{k0} ' displayed. Press Enter key to continue.']); end
% end

%% For each country compare CIP variables for all maturities
figdir  = 'DISvsOwn'; formats = {'eps'};
varDIS  = {'rho','cip_govt','diff_y'};
varOWN  = {'RHO','CIPDEV','LCSPRD'};
pltname = {'Forward Premium','CIP Deviations','Spread'};

for j0 = 1:length(varDIS)
for j1 = 1:length(curncs)
    LC = curncs{j1};
    corrs = nan(ntnrs,2);
    for j2 = 1:ntnrs
        tnr = tnrscell{j2}; corrs(j2,1) = tnrsnum(j2);
        
        fltr1 = TTcip.currency == LC & TTcip.tenor == tnr;
        TTdis = TTcip(fltr1,varDIS{j0});
        
        fltr2 = ismember(header_daily(:,1),LC) & ismember(header_daily(:,2),varOWN{j0}) & ...
            ismember(header_daily(:,5),num2str(tnrsnum(j2)));
        if sum(fltr2) > 0                        	% compare if tenor exists (i.e. data was available)
            t     = datetime(dataset_daily(:,1),'ConvertFrom','datenum');
            TTown = table2timetable(table(t,dataset_daily(:,fltr2)));
            
            TT = synchronize(TTdis,TTown,'intersection'); % match values of variables in time
            corrs(j2,2) = corr(TT.(1),TT.(2),'Rows','complete');
        end
        
        if figstop || figsave
            figure
            plot(TTcip.date(fltr1),TTcip{fltr1,varDIS{j0}})
            if sum(fltr2) > 0                        	% plot own if tenor exists (i.e. data was available)
                hold on
                plot(t,dataset_daily(:,fltr2))
                legend('DIS','Own')
            else
                legend('DIS')
            end
            title([pltname{j0} ': ' LC ' ' tnr])
            ylabel('%')
            datetick('x','yy','keeplimits')
            figname = [varDIS{j0} '_' LC '_' tnr];
            save_figure(figdir,figname,formats,figsave)
        end
    end
    if figstop == true; input([varDIS{j0} ' for ' LC ' displayed. Press Enter key to continue.']); end
    close all
    Scorr(j1).([varDIS{j0} '_corr']) = corrs;
end
end