function [TTpltf,THpltf] = read_platforms()
% READ_PLATFORMS Read data retrieved from Bloomberg and Datastream
%   TTpltf: stores historical data in a timetable
%   THpltf: stores headers in a table

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');       % platform-specific file separators
namefl = {'AE_EM_Curves_Data.xlsx','EM_Currencies_Data.xlsx'};
nfls   = length(namefl);

cd(pathd)
for k0 = 1:nfls
    opts  = detectImportOptions(namefl{k0},'Sheet','Data');
    opts  = setvartype(opts,opts.VariableNames(2:end),'double');
    ttaux = readtimetable(namefl{k0},opts);
    thaux = readtable(namefl{k0},'Sheet','Identifiers','ReadVariableNames',true);
    if k0 == 1
        TTpltf = ttaux;
        THpltf = thaux;
    else
        TTpltf = synchronize(TTpltf,ttaux);
        THpltf = [THpltf; thaux];
    end
end
cd(pathc)

if size(THpltf,1) ~= size(TTpltf,2)
    error('The number of tickers in the ''Data'' and ''Identifiers'' sheets must be the same.')
end

% Clean dataset
TTpltf.Properties.VariableNames = erase(TTpltf.Properties.VariableNames,{'Curncy','Index','Comdty'});
% THpltf.Ticker = TTpltf.Properties.VariableNames';     % variable names in TTdt as tickers in THdt

% Formatting
TTpltf.Date.Format = 'dd-MMM-yyyy';