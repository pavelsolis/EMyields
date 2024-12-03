function TT_gbl = read_global_idxs()
% READ_GLOBAL_IDX Read cyclical components of global activity indexes 
% developed by Hamilton (2020) and Kilian (2019)

% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','Global-Activity');      % platform-specific file separators
namefl = {'Global_IP_Index.xlsx','Kilian_Index_Corrected.txt','shipping_costs.xlsx'};

cd(pathd)

% Hamilton index
opts   = detectImportOptions(namefl{1});
opts   = setvartype(opts,opts.VariableNames(1),'datetime');
opts   = setvartype(opts,opts.VariableNames(2),'double');
TTaux1 = readtable(namefl{1},opts);
dtmth  = unique(lbusdate(year(TTaux1.Var1),month(TTaux1.Var1)));       	% last U.S. business day per month
dates  = datetime(dtmth,'ConvertFrom','datenum');
TTip   = table2timetable(TTaux1(:,2),'RowTimes',dates);                 % index based on industrial production
TTip.Properties.VariableNames = {'ipindex'};

% Cyclical component of global industrial production
logip = log(TTip.ipindex);
TTip.globalip = nan(size(TTip,1),1);
TTip.globalip(25:end) = (logip(25:end) - logip(1:end-24))*100;          % as suggested by Hamilton (2020)
TTip.ipindex = [];

% Kilian index
aux    = readmatrix(namefl{2});
aux(~isnan(aux(:,4)),3) = aux(~isnan(aux(:,4)),4);                      % positive values in different columns
date1  = datetime('1-Jan-1968');                                        % index starts in Jan-1968
date2  = datetime('today');                                             % in case of updates
date3  = date1:calmonths(1):date2;                                      % monthly frequency
dtmth  = unique(lbusdate(year(date3),month(date3)));                    % last U.S. business day per month
dates  = datetime(dtmth(1:size(aux,1))','ConvertFrom','datenum');       % adjust length of dates
TTki = array2timetable(aux(:,3),'RowTimes',dates);                      % index based on shipping costs
TTki.Properties.VariableNames = {'globalki'};

% Cyclical component of real cost of shipping
opts   = detectImportOptions(namefl{3},'Sheet','data');
opts   = setvartype(opts,opts.VariableNames(1),'datetime');
opts   = setvartype(opts,opts.VariableNames(2:end),'double');
TTaux1 = readtable(namefl{3},opts);
dtmth  = unique(lbusdate(year(TTaux1.Var1),month(TTaux1.Var1)));       	% last U.S. business day per month
dates  = datetime(dtmth,'ConvertFrom','datenum');
TTsc   = table2timetable(TTaux1(:,end),'RowTimes',dates);               % seasonal adjustment (Hamilton, 2020)
TTsc.Properties.VariableNames = {'globalsc'};

cd(pathc)

TT_gbl = synchronize(TTip,TTki,'union');
TT_gbl = synchronize(TT_gbl,TTsc,'union');
TT_gbl.Time.Format = 'dd-MMM-yyyy';
% TT_gbl = rmmissing(TT_gbl);

%% Plots
% yyaxis left
% plot(TT_gbl.Time,[TT_gbl.globalki,TT_gbl.globalsc])
% yyaxis right
% plot(TT_gbl.Time,TT_gbl.globalip)
% 
% subplot(3,1,1); plot(TT_gbl.Time,TT_gbl.globalki)
% subplot(3,1,2); plot(TT_gbl.Time,TT_gbl.globalsc)
% subplot(3,1,3); plot(TT_gbl.Time,TT_gbl.globalip)