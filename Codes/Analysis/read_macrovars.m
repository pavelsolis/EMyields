function [data_macro,hdr_macro] = read_macrovars(S)
% READ_MACROVARS Read macroeconomic, financial and policy rate data
%   data_macro: stores historical data
%   hdr_macro: stores headers

% m-files called: read_cbpol
% Pavel Solís (pavel.solis@gmail.com)
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = {'Macro_Vars_Tickers.xlsx','Macro_Vars_Data.xlsx'};

% Read macro data from Bloomberg
cd(pathd)
hdr_mcr  = readcell(namefl{1},'Sheet','Tickers','ExpectedNumVariables',6);  % read headers
hdr_mcr  = hdr_mcr(:,1:6);                                                  % remove extra columns
data_mcr = readmatrix(namefl{2},'Sheet','All');                             % read macro variables
datesmcr = x2mdate(data_mcr(:,1),0);                                        % dates from Excel to Matlab format
data_mcr(:,1) = datesmcr;
datesmonth = unique(lbusdate(year(datesmcr),month(datesmcr)));              % last U.S. business day per month
data_mcr = data_mcr(ismember(datesmcr,datesmonth),:);                       % extract monthly dataset

% MYR GDP case (correlation between survey and actual series of 0.75)
data_myr = readmatrix(namefl{2},'Sheet','MYR');                          	% read GDP and survey data
data_myr(isnan(data_myr(:,2)),2) = data_myr(isnan(data_myr(:,2)),3);        % use survey data for missing obs
fltrMYR  = contains(hdr_mcr(:,3),'MAGDHIY');                            	% identify quarterly GDP for MYR
datesmyr = x2mdate(data_myr(:,1),0);                                        % dates from Excel to Matlab format
datesmyr = unique(lbusdate(year(datesmyr),month(datesmyr)));                % use last business day of quarter
data_mcr(ismember(data_mcr(:,1),datesmyr),fltrMYR) = data_myr(:,2);         % use constructed quarterly GDP data
cd(pathc)

% Read BIS policy rates
[data_cbpol,hdr_cbpol] = read_cbpol(S);

% Merge datasets
TT1 = array2timetable(data_mcr(:,2:end),'RowTimes',datetime(data_mcr(:,1),'ConvertFrom','datenum'));
TT2 = array2timetable(data_cbpol(:,2:end),'RowTimes',datetime(data_cbpol(:,1),'ConvertFrom','datenum'));
TT  = synchronize(TT1,TT2,'intersection');
data_macro = timetable2table(TT);                                         	% data to table
data_macro = table2cell([num2cell(datenum(data_macro{:,1})) data_macro(:,2:end)]);	% date to datenum
data_macro = cell2mat(data_macro);
hdr_macro  = [hdr_mcr; hdr_cbpol];