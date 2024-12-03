function [TTusyc,THusyc] = read_usyc()
% READ_USYC Read U.S. yield curve data from CRSP or H15 for 3M and 6M tenors,
% and from Gürkaynak, Sack & Wright (2007) for tenors larger than 1 year
%   TTusyc: stores historical data in a timetable
%   THusyc: stores headers in a table

% m-files called: construct_hdr
% Pavel Solís (pavel.solis@gmail.com), August 2021
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = 'US_Yield_Curve_Data.xlsx';

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(1),'datetime');
opts  = setvartype(opts,opts.VariableNames(2:end),'double');
opts.VariableNames{1} = 'Date';
ttaux = readtimetable(namefl,opts);
cd(pathc)

% Yields
matmth = [0.25 0.5];	matyrs = [1:9 10:5:30];     matall = [matmth,matyrs]';
tnrs   = strtrim(cellstr(num2str(matall)));
TTgsw  = removevars(ttaux,~contains(ttaux.Properties.VariableNames,'SVENY')); % keep zero-coupon yields
TTgsw  = TTgsw(:,matyrs);                                                     % keep tenors 1Y-9Y+10Y:5Y:30Y
% TTbill = read_crsp();                                                       % 3M and 6M yields from CRSP
TTbill = read_h15();                                                          % 3M and 6M yields from H15
TTusyc = synchronize(TTbill,TTgsw);                                           % merge yields (old-new)
TTusyc(sum(ismissing(TTusyc),2) == size(TTusyc,2),:) = [];                    % remove days without data

% Header
H_usyc  = construct_hdr('USD','LCNOM',TTusyc.Properties.VariableNames',...    % variable names as tickers
    strcat('USD ZERO-COUPON YIELD',{' '},tnrs,' YR'),num2cell(matall),' ','GSW');
H_usyc(1:numel(matmth),end) = {'H15'};                                        % T-bill data source
THusyc = cell2table(H_usyc);
THusyc.Properties.VariableNames = {'Currency','Type','Ticker','Name','Tenor','FloatingLeg','Source'};
end

function TTcrsp = read_crsp()
% READ_CRSP Read U.S. Treasury bill yields from CRSP
%   TTcrsp: stores historical daily data in a timetable
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','CRSP');                     % platform-specific file separators
namefl = 'CRSP_TFZ_DLY_RF2.xlsx';                                           % risk-free daily

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(contains(opts.VariableNames,'CALDT')),'datetime');
ttaux = readtimetable(namefl,opts);
ttaux.Properties.DimensionNames{1} = 'Date';
ttaux(isnat(ttaux.Date),:) = [];                                            % delete extra rows
ttaux.TYLDA = ttaux.TDYLD*365*100;                                          % annualized percent
TTcrsp = synchronize(ttaux(ttaux.KYTREASNOX == 2000062,{'TYLDA'}),...
                     ttaux(ttaux.KYTREASNOX == 2000063,{'TYLDA'}));
TTcrsp.Properties.VariableNames = {'CRSP3M','CRSP6M'};
cd(pathc)
end

function TTh15 = read_h15()
% READ_H15 Read U.S. Treasury bill yields from FRB H.15 release
%   TTh15: stores historical daily data in a timetable
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = 'US_H15_Data.xlsx';                                                % risk-free daily

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(contains(opts.VariableNames,'TimePeriod')),'datetime');
opts  = setvartype(opts,opts.VariableNames(2:end),'double');
ttaux = readtimetable(namefl,opts);
ttaux.Properties.DimensionNames{1} = 'Date';
ttaux(:,~contains(ttaux.Properties.VariableNames,{'M03','M06'})) = [];      % keep 3M and 6M yields
TTh15 = rmmissing(ttaux);                                                   % delete extra rows
TTh15.Properties.VariableNames = {'CRSP3M','CRSP6M'};                       % use names as in CRSP
cd(pathc)
end