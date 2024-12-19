function [S,data_frq,hdr_frq] = daily2dymy(S,dataset_daily,header_daily,to_my)
% DAILY2DYMY Daily or monthly data for RHO, CIPDEV, LCNOM, LCSYNT for countries in S
% 
%     INPUT
% struct:  S - country and currency names, letter and digit codes
% double:  dataset_daily - obs as rows (top-down is old-new), col1 has dates
% cell:    header_daily  - names for the columns of dataset_daily
% logical: to_my - convert to monthly frequency if true, o/w daily frequency
% 
%     OUTPUT
% struct: S - (un)balanced panels for each variable type, date of first obs
% double: data_frq - obs as rows (top-down is old-new), col1 has dates
% cell:   hdr_frq  - names for the columns of the new dataset

% Pavel Solís (pavel.solis@gmail.com)
%%
VarType = {'RHO','CIPDEV','LCNOM','LCSYNT'};
fields  = {'dated','data','dateb','blncd'};
ncntrs  = length(S);    ntypes = length(VarType);                           % #countries and #variables
tnrmin  = 5;            tnrmax = 10;                                        % minimum and maximum tenors
tnrsall = [0; cellfun(@str2num,header_daily(2:end,5))];                     % tenors as doubles
fltrTNR = tnrsall <= tnrmax;                                                % identify tenors <= maximum tenor
tnrsall = tnrsall(fltrTNR);
if to_my
    datesdy  = dataset_daily(:,1);
    datesmt  = unique(lbusdate(year(datesdy),month(datesdy)));              % last U.S. business day per month
    data_frq = dataset_daily(ismember(datesdy,datesmt),fltrTNR);            % extract monthly dataset
    prfxfrq  = 'm';
else
    data_frq = dataset_daily(:,fltrTNR);                                    % extract daily dataset
    prfxfrq  = 'd';
end
hdr_frq = header_daily(fltrTNR,:);                                          % header
nobs    = size(data_frq,1);
fltrUSD = ismember(hdr_frq(:,1),{'USD','Currency'}) & ismember(hdr_frq(:,2),{'LCNOM','Type'});

for j0 = 1:ntypes
    switch VarType{j0}                                                      % prefix for field names
        case 'RHO';     prfxvar = 'r';
        case 'CIPDEV';  prfxvar = 'c';
        case 'LCNOM';   prfxvar = 'n';
        case 'LCSYNT';  prfxvar = 's';
    end
    
    % Construct datasets for each type of variable per country
    fnames  = strcat(prfxfrq,prfxvar,'_',fields);                           % field names for variable type
    fltrTYP = ismember(hdr_frq(:,2),{VarType{j0},'Type'});                  % include column name
    for k0  = 1:ncntrs
        % Unbalanced panels
        fltrVAR  = ismember(hdr_frq(:,1),{S(k0).iso,'Currency'}) & fltrTYP; % country + variable type
        tnrs     = tnrsall(fltrVAR);                                        % available tenors
        data_var = data_frq(:,fltrVAR);                                     % extract data (include dates)
        istnrmin = repmat(tnrs' >= tnrmin,nobs,1);                          % cols w/ tenors >= minimum tenor
        isrowobs = ~isnan(data_var);                                        % rows w/ actual observations
        idxRows  = any(isrowobs & istnrmin,2);                              % rows w/ tenors above min
        data_var = data_var(idxRows,:);                                     % keep rows w/ tenors above min
        S(k0).(fnames{1}) = datestr(data_var(1,1),'mmm-yyyy');              % first monthly observation
        S(k0).(fnames{2}) = [tnrs'; data_var(:,1) data_var(:,2:end)/100];   % data in decimals
        
        % Balanced panels
        udataset = S(k0).(fnames{2});
        tnrsrmv  = [];                                                      % remove tenors in limited cases
        if any(strcmp(VarType{j0},{'RHO','CIPDEV','LCSYNT'}))
            switch S(k0).iso
                case {'COP','AUD'}
                    tnrsrmv = [8 9];
                case {'HUF','DKK','EUR','GBP','NOK','SEK'}
                    tnrsrmv = 9;
                case {'KRW','CAD','CHF','NZD'}
                    tnrsrmv = [6 8 9];
            end
        end
        udataset = udataset(:,~ismember(udataset(1,:),tnrsrmv));            % keep tenors not in tnrsrmv
        idxRmv   = any(isnan(udataset),2);                                  % rows w/ NaNs
        udataset = udataset(~idxRmv,:);                                     % remove rows w/ NaNs
        S(k0).(fnames{3}) = datestr(udataset(2,1),'mmm-yyyy');
        S(k0).(fnames{4}) = udataset;
        
        if strcmp(VarType{j0},'RHO')
            fltrUSDx = fltrUSD & ismember(tnrsall,udataset(1,:));
            data_usd = data_frq(ismember(data_frq(:,1),udataset(2:end,1)),fltrUSDx);
            S(k0).([prfxfrq '_gsw']) = [tnrsall(fltrUSDx)'; data_usd(:,1) data_usd(:,2:end)/100];  % decimals
        end
    end
end