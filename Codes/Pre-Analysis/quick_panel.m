%% In Analysis folder
TT_mps  = read_mps();
fltrMPS = contains(TT_mps.Properties.VariableNames,{'MP1','ED4','ED8','ONRUN10','PATH','LSAP'}); % US MPS
TT1     = TT_mps(:,fltrMPS);

ncntrs = length(curncs);
for k0 = 1:ncntrs
    fltrCTY = ismember(hdr_fp(:,1),curncs{k0});
    tnrs    = hdr_fp(fltrCTY,5);
    dates   = data_fp(:,1);
    data    = data_fp(:,[false; fltrCTY]);      % take into account 1st col of dates
    tnrs    = str2double(tnrs);
    fltrTNR = ismember(tnrs,[0.25 0.5 1 2 5 10]);
    data    = data(:,fltrTNR);
    
    tnrst = cellfun(@num2str,num2cell(tnrs(fltrTNR)*12),'UniformOutput',false); % tenors in months
    varnm = strcat('rho',tnrst,'m');
    TT2 = array2timetable(data,'RowTimes',datetime(dates,'ConvertFrom','datenum'),'VariableNames',varnm);
    
    TT3  = synchronize(TT1,TT2,'union');
    TT3.cty = repmat(curncs{k0},size(TT3,1),1);                              % add currency code
    TT3.imf = repmat(k0,size(TT3,1),1);                              % add IMF code
    
    % Stack panels
    if k0 == 1
        TT = TT3;
    else
        TTcolsmiss  = setdiff(TT3.Properties.VariableNames, TT.Properties.VariableNames);
        TT3colsmiss = setdiff(TT.Properties.VariableNames, TT3.Properties.VariableNames);
        TT  = [TT  array2table(nan(height(TT),  numel(TTcolsmiss)),  'VariableNames', TTcolsmiss)];
        TT3 = [TT3 array2table(nan(height(TT3), numel(TT3colsmiss)), 'VariableNames', TT3colsmiss)];
        TT  = [TT;TT3];
    end
end

TT  = TT(isbetween(TT.Time,datetime('1-Jan-2000'),datetime('31-Jan-2019')),:);
%% In Pre-Analysis folder
TTusyc = read_usyc();
trddys = TTusyc.Date(~all(isnan(TTusyc{:,:}),2));                           % remove non-trading days in US
TT(~ismember(TT.Time,trddys),:) = [];                                       % remove non-trading days in US
TT.Time.Format = 'dd-MMM-yyyy';

filename = fullfile(pwd,'..','..','Data','Analytic','datarho.xlsx');
writetimetable(TT,filename,'Sheet',1,'Range','A1')