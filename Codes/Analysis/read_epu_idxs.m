function S = read_epu_idxs(S)
% READ_EPU_IDXS Read economic policy uncertainty indexes (Baker-Bloom-Davis, 2016)
% Files are not standardized, need to deal with exceptions

% Pavel Solís (pavel.solis@gmail.com)
%%
pathc   = pwd;
pathd   = fullfile(pathc,'..','..','Data','Raw','EPU');                     % platform-specific file separators
prepost = {'EPU_Index_','.xlsx'};                                           % text before and after iso codes
ncntrs  = length(S);

cd(pathd)
namesfl = dir('*.xlsx');                                                    % detect files in folder
namesfl = struct2cell(namesfl);                                             % convert to cell array
namesfl(2:end,:) = [];                                                      % keep file names only
ctrsepu = erase(namesfl,prepost);                                           % keep iso codes only
for k0 = 1:ncntrs
    if ismember(S(k0).iso,ctrsepu)
        filename = [prepost{1} S(k0).iso prepost{2}];                       % use country file name
        opts     = detectImportOptions(filename);
        if ismember(S(k0).iso,{'COP','KRW'})
            opts = setvartype(opts,opts.VariableNames(1),'datetime');       % read first column as datetime
            opts = setvartype(opts,opts.VariableNames(2:end),'double');
            if strcmp(S(k0).iso,'COP')
                inputfmt = 'yyyy-MM';                                       % COP case
            else
                inputfmt = 'mm/yyyy';                                       % KRW case
                opts.VariableNames(contains(opts.VariableNames,'Var')) = [];% delete extra columns
            end
            opts = setvaropts(opts,'Date','InputFormat',inputfmt);          % use correct input format
        else
            opts = setvartype(opts,opts.VariableNames(:),'double');         % all other countries
        end
        TTaux = readtable(filename,opts);
        if strcmp(S(k0).iso,'JPY')
            TTaux(:,all(isnan(TTaux{:,:}),1)) = [];                         % remove cols w/ all NaNs
        end
        TTaux = rmmissing(TTaux);                                           % remove rows w/ missing values
        if ismember(S(k0).iso,{'COP','KRW'})
            yr = year(TTaux{:,1});  mth = month(TTaux{:,1});                % 1st col is datetime
        else
            yr = TTaux{:,1};        mth = TTaux{:,2};                       % 1st col is year, 2nd col is month
        end
        dtmth = lbusdate(yr,mth);                                           % last U.S. business day per month
        if ismember(S(k0).iso,{'EUR','JPY'})
            idx = TTaux{:,3};                                               % index is in 3rd column
        else
            idx = TTaux{:,end};                                             % all other countries
        end
        S(k0).epu = [dtmth idx];
    end
end
cd(pathc)