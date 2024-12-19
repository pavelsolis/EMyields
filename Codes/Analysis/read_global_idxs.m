function TT_gbl = read_global_idxs()
% READ_GLOBAL_IDX Read cyclical component of global activity index by Hamilton (2020)

% Pavel Solís (pavel.solis@gmail.com)
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = {'Global_IP_Index.xlsx'};

cd(pathd)
opts   = detectImportOptions(namefl{1});
opts   = setvartype(opts,opts.VariableNames(1),'datetime');
opts   = setvartype(opts,opts.VariableNames(2),'double');
TTaux1 = readtable(namefl{1},opts);
dtmth  = unique(lbusdate(year(TTaux1.Var1),month(TTaux1.Var1)));       	    % last U.S. business day per month
dates  = datetime(dtmth,'ConvertFrom','datenum');
TT_gbl = table2timetable(TTaux1(:,2),'RowTimes',dates);                     % index based on industrial production
TT_gbl.Properties.VariableNames = {'ipindex'};

% Cyclical component of global industrial production
logip = log(TT_gbl.ipindex);
TT_gbl.globalip = nan(size(TT_gbl,1),1);
TT_gbl.globalip(25:end) = (logip(25:end) - logip(1:end-24))*100;            % as suggested by Hamilton (2020)
TT_gbl.ipindex = [];
TT_gbl.Time.Format = 'dd-MMM-yyyy';
cd(pathc)