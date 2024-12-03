function [data_svys,hdr_svys] = read_surveys()
% READ_SURVEYS Read survey forecasts from Consensus Economics
%   data_svys: stores historical data for countries in same order as in S
%   hdr_svys: headaer (no title in first entry, ready to be appended)

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                  	% platform-specific file separators
namefl = 'CE_Forecasts.xlsx';

cd(pathd)
aux_svys  = readcell(namefl,'Sheet',1);
hdr_svys  = aux_svys(1,:);                                          % include column for dates
datessvys = datenum(aux_svys(2:end,1));                             % exclude header row
datessvys = unique(lbusdate(year(datessvys),month(datessvys)));     % last U.S. business day per month
data_svys = readmatrix(namefl,'Sheet',1);
data_svys = [datessvys data_svys(:,2:end)];                         % use end-of-month dates
cd(pathc)