function [data_fp,hdr_fp,tnrsLCfp] = fwd_prm(dataset_daily,header_daily,curncs)
% FWD_PRM Calculate the market-implied forward premium using forward/spot
% exchange rates (<1Y maturities) and cross-currency swaps (>=1Y maturities)
%   data_fp: stores historical data
%   hdr_fp: stores headers (note: row 1 has no titles, i.e. ready to be appended)
%   tnrsLCfp: reports FP tenors per currency

% m-files called: compute_fp_short, compute_fp_long, remove_NaNcols
% Pavel Solís (pavel.solis@gmail.com), August 2020
%% Construct the FP Database
% LCs  = ['BRL2'; curncs]';         % there are two formulas for Brazil
hdr_fp  = {};                       % no row 1 with titles (i.e. ready to be appended)
data_fp = dataset_daily(:,1);

for k = 1:numel(curncs)
    [FP,hdr1]  = compute_fp_short(curncs{k},header_daily,dataset_daily,curncs);
    [CCS,hdr2] = compute_fp_long(curncs{k},header_daily,dataset_daily);
    hdr_fp     = [hdr_fp; hdr1; hdr2];
    data_fp    = [data_fp, FP, CCS];
end

% Remove columns w/ no data
[data_fp,hdr_fp] = remove_NaNcols(hdr_fp,data_fp);

%% Report FP Tenors per Currency
tnrsLCfp = {};                      % count only after remove_NaNcols.m is called
LC_once = unique(hdr_fp(:,1),'stable');
for k = LC_once'
    tnrsLCfp = [tnrsLCfp; k, 'Fwd Prm', sum(strcmp(hdr_fp(:,1),k))];
end