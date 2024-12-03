function TT = construct_panel(S,matsout,currEM,currAE)
% CONSTRUCT_PANEL Generate dataset for regression analysis
% 
%	INPUTS
% S       - structure with fields bsl_pr, ms, mn, ds, dn
% matsout - maturities (in years) to be reported
% currEM  - emerging market countries in the sample
% currAE  - advanced countries in the sample
%
%	OUTPUT
% TT - dataset in a time table

% m-files called: read_mps, read_kw, read_spf, read_global_idxs, read_epu_usdgbl,
% read_financialvars, read_platforms, read_usyc, datesminmax
% Pavel Solís (pavel.solis@gmail.com), September 2020
% 
%% Define variables
dtend   = datetime('11-Aug-2021');                                          % end of sample
flds1   = ['d_gsw' strcat({'dn','ds','dr'},'_blncd') strcat('d_',{'cr','yP','tp'}) strcat('bsl_',{'yP','tp'})];
varnms1 = {'usyc','nom','syn','rho','phi','dyp','dtp','myp','mtp'};
flds2   = {'scbp','scpi','sgdp','stp','rrt','cbp','inf','une','ip','gdp','sdprm','sdcyc','epu'};
varnms2 = flds2;
flds    = [flds1 flds2];                                                    % EM-specific + common variables
varnms  = [varnms1 varnms2];                                                % names in new dataset
nflds   = length(flds); 
ncntrs  = length(S);

%% Read data
TT_mps = read_mps();
TT_kw  = read_kw(matsout);
TT_rr  = read_spf();
TT_rr.Properties.VariableNames = strrep(TT_rr.Properties.VariableNames,{'01Y','05Y','10Y'},{'12M','60M','120M'});
TT_gbl = read_global_idxs();
TT_epu = read_epu_usdgbl();
[data_finan,hdr_finan] = read_financialvars();
addpath(fullfile(pwd,'..','Pre-Analysis'))                                  % folder w/ more functions
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames')                      % suppress table warnings
TTpltf = read_platforms();                                                  % exchange rate data for AE and EM
TTusyc = read_usyc();
trddys = TTusyc.Date(~all(isnan(TTusyc{:,:}),2));                           % remove non-trading days in US

% Read conventions to quote FX
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
cd(pathd)
namefl = 'AE_EM_Curves_Tickers.xlsx';
convfx = readcell(namefl,'Sheet','CONV','Range','H66:H90');                 % update range as necessary
cd(pathc)

% Express all FX as LC per USD
curncs = [currEM;currAE];
TTccy  = TTpltf(:,ismember(TTpltf.Properties.VariableNames,curncs));
fltrFX = ismember(TTccy.Properties.VariableNames,curncs(~startsWith(convfx,'USD')));
TTccy{:,fltrFX} = 1./TTccy{:,fltrFX};

%% Variables common to all countries
hdr_finan(ismember(hdr_finan(:,1),'USD') & ismember(hdr_finan(:,2),'STX'),2) = {'SPX'};
fltrMPS = contains(TT_mps.Properties.VariableNames,{'MP1','ED4','ED8','ONRUN10','PATH','LSAP'}); % US MPS
fltrKW  = contains(TT_kw.Properties.VariableNames,{'TP','yP'});             % Kim-Wirght decomposition
fltrUSD = ismember(hdr_finan(:,2),{'VIX','FFR','SPX','OIL'});               % international variables
fltrLC  = ismember(hdr_finan(:,2),'STX');                                   % domestic variable
findts  = data_finan(:,1);
findata = data_finan(:,fltrUSD);
finnms  = lower(hdr_finan(fltrUSD,2)');
TT0     = array2timetable(findata,'RowTimes',datetime(findts,'ConvertFrom','datenum'),'VariableNames',finnms);
TT0     = synchronize(TT0,TT_mps(:,fltrMPS),'union');                       % add MP shocks
TT0     = synchronize(TT0,TT_kw(:,fltrKW),'union');                         % add KW decomposition
TT0     = synchronize(TT0,TT_rr,'union');                                   % add US real rates
TT0     = synchronize(TT0,TT_gbl,'union');                                  % add global activity indexes
TT0     = synchronize(TT0,TT_epu,'union');                                  % add EPU indexes (US and global)

%% Country-specific variables
for k0 = 1:ncntrs
	% Add domestic variables
    fltrFX  = strcmp(TTccy.Properties.VariableNames,S(k0).iso);
    TTfx    = TTccy(:,fltrFX);
    fltrCTY = ismember(hdr_finan(:,1),S(k0).iso) & fltrLC;
    findata = data_finan(:,fltrCTY);
    if isempty(findata); findata = nan(size(findts)); end                   % in case no stock market data
    TTstx   = array2timetable(findata,'RowTimes',datetime(findts,'ConvertFrom','datenum'));
    TTfx.Properties.VariableNames  = {'fx'};                                % ensure same variable name
    TTstx.Properties.VariableNames = {'stx'};    
    TT1     = synchronize(TT0,TTfx,'union');                                % add FX
    TT1     = synchronize(TT1,TTstx,'union');                               % add stock index
    TT1.cty = repmat(S(k0).iso,size(TT1,1),1);                              % add currency code
    TT1.imf = repmat(S(k0).imf,size(TT1,1),1);                              % add IMF code
    
    % Extract variables in fields of structure S
    for k1 = 1:nflds
        fldnm = flds{k1};
        if ~isempty(S(k0).(fldnm))                                          % fields with data
            if ~isnan(S(k0).(fldnm)(1,1)) && S(k0).(fldnm)(1,1) ~= 0        % single variable case
                dates = S(k0).(fldnm)(:,1);
                data  = S(k0).(fldnm)(:,2);                                 % select first appearance
                varnm = varnms(k1);
            else                                                            % variables w/ tenors
                tnrs  = S(k0).(fldnm)(1,:);
                fltrT = ismember(tnrs,matsout);
                dates = S(k0).(fldnm)(2:end,1);
                data  = S(k0).(fldnm)(2:end,fltrT);
                tnrst = cellfun(@num2str,num2cell(tnrs(fltrT)*12),'UniformOutput',false); % tenors in months
                varnm = strcat(varnms{k1},tnrst,'m');
            end
            TTaux = array2timetable(data,'RowTimes',datetime(dates,'ConvertFrom','datenum'),...
                    'VariableNames',varnm);
            if k1 == 1                                                      % 1st variable must be *common*
                TT2 = TTaux;
            else
                TT2 = synchronize(TT2,TTaux,'union');
            end
        end
    end
    dtmn = datesminmax(S,k0);
    TT2  = TT2(isbetween(TT2.Time,datetime(dtmn,'ConvertFrom','datenum'),dtend),:);
    
    % Add field-specific variables (intersect datasets)
    TT3  = synchronize(TT1,TT2,'intersection');
    
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

%% Clean dataset
TT(~ismember(TT.Time,trddys),:) = [];                                       % remove non-trading days in US
TT.gdp(mod(month(TT.Time),3) ~= 0) = nan;                                   % only keep quarterly data for GDP
TT.Time.Format = 'dd-MMM-yyyy';

% Define dummies
datesmth = unique(lbusdate(year(TT.Time),month(TT.Time)));
TT.eomth = ismember(TT.Time,datetime(datesmth,'ConvertFrom','datenum'));    % end of month
TT.eoqtr = (mod(month(TT.Time),3) == 0) & TT.eomth;                         % end of quarter
TT.em    = ismember(TT.cty,currEM);                                         % emerging markets

%% Export table to Excel
filename = fullfile(pathc,'..','..','Data','Analytic','dataspillovers.xlsx');
writetimetable(TT,filename,'Sheet',1,'Range','A1')

%% Sources
% Merge tables with different dimensions
% https://www.mathworks.com/matlabcentral/answers/179290-merge-tables-with-different-dimensions