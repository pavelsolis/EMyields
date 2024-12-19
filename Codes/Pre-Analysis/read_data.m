%% Read Data
% Read data from different files to construct a dataset of yield curves,
% spreads, forward premia and deviations from covered interest rate parity

% m-files called: read_platforms, read_usyc, fwd_prm, zc_yields, spreads, append_dataset
% Pavel Solís (pavel.solis@gmail.com)
%% Data on yield curves and swap curves
tic
clear; clc; close all;
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames')                                  % suppress table warnings
[TTpltf,THpltf] = read_platforms();
[TTusyc,THusyc] = read_usyc();
TTdy = synchronize(TTpltf,TTusyc,'commonrange');                                        % union over intersection
THdy = [THpltf; THusyc];

%% Convert tables to cell arrays (easier for performing calculations)
header_daily  = [THdy.Properties.VariableNames;table2cell(THdy)];                       % header to cell
header_daily(2:end,5) = cellfun(@num2str,header_daily(2:end,5),'UniformOutput',false);  % tnrs to string
dataset_daily = [datenum(TTdy.Date) TTdy{:,:}];
curncs = cellstr(unique(THdy.Currency(ismember(THdy.Type,'SPT')),'stable'));
currEM = curncs(1:15); currAE = curncs(16:end);
clear T*

%% Data on forward premiums
[data_fp,hdr_fp,tnrs_fp]     = fwd_prm(dataset_daily,header_daily,curncs);              % no time shift
[dataset_daily,header_daily] = append_dataset(dataset_daily,data_fp,header_daily,hdr_fp);

%% Data on nominal yield curves
[data_zc,hdr_zc] = zc_yields(dataset_daily,header_daily,curncs,false,false,true);       % make time shift
[dataset_daily,header_daily] = append_dataset(dataset_daily,data_zc,header_daily,hdr_zc);

%% Data on spreads (synthetic yield curves, interest rate differentials, CIP deviations)
[data_sprd,hdr_sprd,tnrs_spd] = spreads(dataset_daily,header_daily);
[dataset_daily,header_daily]  = append_dataset(dataset_daily,data_sprd,header_daily,hdr_sprd);

%% Clean dataset
types = {'Type','RHO','LCNOM','LCSYNT','LCSPRD','CIPDEV'};
fltr  = ~ismember(header_daily(:,2),types);
dataset_daily(:,fltr) = [];     header_daily(fltr,:)  = [];
dataset_daily(dataset_daily(:,1) < datenum('1-Aug-2009'),ismember(header_daily(:,1),'RUB')) = nan;
clear data_* hdr_* tnrs* fltr types
toc

%% Save variables in mat file
pathc = pwd;
cd(fullfile(pathc,'..','..','Data','Analytic'))
save yc_data.mat dataset_daily header_daily cur*
cd(pathc)