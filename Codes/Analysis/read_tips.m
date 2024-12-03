function [TTtips,THtips] = read_tips()
% READ_TIPS Read U.S. TIPS yield curve data from Gürkaynak, Sack & Wright (2010)
%   TTtips: stores historical data in a timetable
%   THtips: stores headers in a table

% m-files called: construct_hdr
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = 'TIPS_Yield_Curve_Data.xlsx';

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(1),'datetime');
opts  = setvartype(opts,opts.VariableNames(2:end),'double');
opts.VariableNames{1} = 'Date';
ttaux = readtimetable(namefl,opts);
cd(pathc)

% Yields
matyrs = [2 5 10]';
tnrs   = strtrim(cellstr(num2str(matyrs)));
TTtips = removevars(ttaux,~contains(ttaux.Properties.VariableNames,strcat('TIPSY',{'02','05','10'})));

% Header
H_usyc  = construct_hdr('USD','LCRL',TTtips.Properties.VariableNames',...    % variable names as tickers
    strcat('USD ZERO-COUPON TIPS YIELD',{' '},tnrs,' YR'),num2cell(matyrs),' ','GSW');
THtips = cell2table(H_usyc);
THtips.Properties.VariableNames = {'Currency','Type','Ticker','Name','Tenor','FloatingLeg','Source'};