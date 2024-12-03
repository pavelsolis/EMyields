function TT_mps = read_mps()
% READ_MPS Read U.S. monetary policy shocks

% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','MPS');                      % platform-specific file separators
namefl = 'wide_mar2019.xls';

cd(pathd)
opts   = detectImportOptions(namefl);
opts   = setvartype(opts,opts.VariableNames(1),'datetime');
opts   = setvartype(opts,opts.VariableNames(2:end),'double');
opts.VariableNames{1} = 'Time';
TT_mps = readtimetable(namefl,opts);
cd(pathc)

% Remove meeting following 9/11
TT_mps(TT_mps.Time == '17-Sep-2001',:) = [];

% Compute path and LSAP shocks
T = timetable2table(TT_mps,'ConvertRowTimes',false);
mdlPath     = fitlm(T,'ED8~MP1');
TT_mps.PATH = mdlPath.Residuals.Raw;

T = timetable2table(TT_mps,'ConvertRowTimes',false);
mdlLSAP     = fitlm(T,'ONRUN10~MP1+PATH');
TT_mps.LSAP = mdlLSAP.Residuals.Raw;