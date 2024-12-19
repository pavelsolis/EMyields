function TT_epu = read_epu_usdgbl()
% READ_EPU_USDGBL Read U.S. (daily) and global (monthly) economic policy 
% uncertainty (EPU) indexes

% Pavel Solís (pavel.solis@gmail.com)
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','EPU');                      % platform-specific file separators
namefl = strcat('EPU_Index_',{'USD.csv','GBL.xlsx'});
nfls   = length(namefl);

cd(pathd)
for k0 = 1:nfls
    opts   = detectImportOptions(namefl{k0});
    opts   = setvartype(opts,opts.VariableNames(:),'double');
    TTaux1 = readtable(namefl{k0},opts);
    TTaux1 = rmmissing(TTaux1);
    TTaux1.Properties.VariableNames = lower(TTaux1.Properties.VariableNames);
    if k0 == 1
        dates = datetime(TTaux1.year,TTaux1.month,TTaux1.day);
        varnm = {'epuus'};
    else
        dtmth = unique(lbusdate(TTaux1.year,TTaux1.month));                 % last U.S. business day per month
        dates = datetime(dtmth,'ConvertFrom','datenum');
        varnm = {'epugbl'};
    end
    TTaux2 = table2timetable(TTaux1(:,end),'RowTimes',dates);
    TTaux2.Properties.VariableNames = varnm;
    
    if k0 == 1
        TT_epu = TTaux2;
    else
        TT_epu = synchronize(TT_epu,TTaux2,'union');                        % add yields and components
    end
end
cd(pathc)

TT_epu.Time.Format = 'dd-MMM-yyyy';