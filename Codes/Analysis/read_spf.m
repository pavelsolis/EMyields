function TT_rr = read_spf()
% READ_SPF Read Tbill and CPI from Survey of Professional Forecasters (SPF)
% and returns the implied forecasts for the real interest rate
%   TT_rr: stores historical data at monthly frequency

% Pavel Solís (pavel.solis@gmail.com)
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','SPF');           	% platform-specific file separators
namefl = {'TBILL','BILL10','CPI','CPI5YR','CPI10'};
namefl = strcat('Mean_',namefl,'_Level.xlsx');
nfiles = length(namefl);

TT_rr = [];
cd(pathd)
for k0 = 1:nfiles
    opts  = detectImportOptions(namefl{k0});
    opts  = setvartype(opts,opts.VariableNames,'double');
    TTaux = readtable(namefl{k0},opts);
    if k0 > 1
        TTaux = removevars(TTaux,{'YEAR','QUARTER'});
    end
    TT_rr = [TT_rr TTaux];
end
cd(pathc)

% Interporlate 10Y expected Tbill rates
TT_rr.BILL10prv = fillmissing(TT_rr.BILL10,'previous');             % b/c BILL10 available only on first quarter
TT_rr.BILL10lin = fillmissing(TT_rr.BILL10,'linear');             	% use linear interpolation
TT_rr.BILL10lin(isnan(TT_rr.BILL10prv)) = nan;                    	% delete filled values before 1st one

% Compute implied expected real rates
TT_rr.USRR01Y = TT_rr.TBILL6 - TT_rr.CPI6;
TT_rr.USRR05Y = TT_rr.TBILLD - TT_rr.CPI5YR;
TT_rr.USRR10Y = TT_rr.BILL10lin - TT_rr.CPI10;

% Store data using monthly frequency
dates  = lbusdate(TT_rr.YEAR,TT_rr.QUARTER*3 - 1);                	% survey released in middle month of Q
TT_rr  = table2timetable(TT_rr,'RowTimes',datetime(dates,'ConvertFrom','datenum'));
datesm = TT_rr.Time(1):calmonths(1):TT_rr.Time(end);             	% monthly frequency
datesm = unique(lbusdate(year(datesm),month(datesm)));          	% last U.S. business day per month
TTaux  = array2timetable([1:length(datesm)]','RowTimes',datetime(datesm','ConvertFrom','datenum')); % placeholder
TT_rr  = synchronize(TTaux,TT_rr,'union');                       	% store quarterly data monthly

% Keep real rates and fill months w/ no data
fltrRM = ~ismember(TT_rr.Properties.VariableNames,{'USRR01Y','USRR05Y','USRR10Y'});
TT_rr = removevars(TT_rr,TT_rr.Properties.VariableNames(fltrRM)); 	% remove extra variables
TT_rr = fillmissing(TT_rr,'previous');                            	% fill w/ previous values