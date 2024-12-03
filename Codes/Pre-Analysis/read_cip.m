function [TTcip,currEM,currAE] = read_cip()
% READ_CIP Read CIP data from Du, Im & Schreger (2018)
%   TTcip: stores historical data
%   currEM: contains currencies of emerging market in ascending order
%   currAE: contains currencies of advanced countries in ascending order

% Pavel Solís (pavel.solis@gmail.com), August 2021
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                  % platform-specific file separators
cd(pathd)
namefl = 'CIP_Data.csv';
opts   = detectImportOptions(namefl);
opts   = setvartype(opts,contains(opts.VariableNames,{'group','currency','tenor'}),'categorical');
opts   = setvartype(opts,contains(opts.VariableNames,{'diff_y','rho','cip_govt'}),'double');
opts   = setvartype(opts,contains(opts.VariableNames,'date'),'datetime');
opts   = setvaropts(opts,'date','InputFormat','ddMMMyyyy');
TTcip  = readtimetable(namefl,opts);
cd(pathc)

[~,grp,currencies] = findgroups(TTcip.group,TTcip.currency);
currEM = cellstr(currencies(grp == 'eme'));
currAE = cellstr(currencies(grp == 'g10'));