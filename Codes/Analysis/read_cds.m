function TT_cds = read_cds()
% READ_CDS Read CDS data

% Pavel Solís (pavel.solis@gmail.com), August 2021
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = 'CDS_Data.xlsx';

cd(pathd)
opts   = detectImportOptions(namefl,'Sheet','5Y');
opts   = setvartype(opts,opts.VariableNames(1),'datetime');
opts   = setvartype(opts,opts.VariableNames(2:end),'double');
opts.VariableNames{1} = 'Time';
TT_cds = readtimetable(namefl,opts);
cd(pathc)

TT_cds.Properties.VariableNames = erase(TT_cds.Properties.VariableNames,{'CDSUSDSR','5YD14Corp'});