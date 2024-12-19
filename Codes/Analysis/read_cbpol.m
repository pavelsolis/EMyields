function [data_cbpol,hdr_cbpol] = read_cbpol(S)
% READ_CBPOL Read policy rates from BIS policy rate database
%   data_cbpol: stores historical data for countries in same order as in S
%   hdr_cbpol: headaer (no title in first entry, ready to be appended)

% m-files called: construct_hdr
% Pavel Solís (pavel.solis@gmail.com)
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                  	% platform-specific file separators
namefl = 'BIS_CB_Policy_Rates.xlsx';

cd(pathd)
cnts_cbpol = readcell(namefl,'Sheet',3,'Range','3:3');              % read country names (third row)
tckr_cbpol = readcell(namefl,'Sheet',3,'Range','4:4');              % read tickers
data_cbpol = readmatrix(namefl,'Sheet',3);                          % note cnts_cbpol has 1 less column
cnts_cbpol(:,1) = [];
cd(pathc)

% Identify countries in the sample
ncts = length(S);   cnts_smpl = cell(ncts,1);   cnts_ccy = cell(ncts,1);
for k = 1:ncts
    cnts_smpl{k} = S(k).cty;
    cnts_ccy{k}  = S(k).iso;
end

% Extract data for countries in the sample
cnts_cbpol(contains(cnts_cbpol,'Euro area')) = {'Germany'};     	% country names as in cnts_smpl
fltrCTY    = ismember(cnts_cbpol,cnts_smpl);                       	% match country names
cnts_cbpol = cnts_cbpol(fltrCTY);                                   % choose countries in sample
tckr_cbpol = tckr_cbpol([false fltrCTY]);                       	% exclude column name
datescbpol = x2mdate(data_cbpol(:,1),0);                        	% save dates in Matlab format
datescbpol = unique(lbusdate(year(datescbpol),month(datescbpol)));	% use last U.S. business day per month
data_cbpol = data_cbpol(:,[false fltrCTY]);                         % exclude dates column

% Reorder countries in BIS as in S
[~,idxBIS] = sort(cnts_cbpol);                                   	% BISsort = cnts_cbpol(idxBIS)
[~,idxSMP] = sort(cnts_smpl);                                      	% BISsort = cnts_smpl(idxSMP)
[~,idx2]   = sort(idxSMP);                                        	% BISsort(idx2) = cnts_cbpol(idxBIS(idx2))
tckr_cbpol = tckr_cbpol(idxBIS(idx2));                              % reorder tickers
data_cbpol = [datescbpol data_cbpol(:,idxBIS(idx2))];           	% reorder columns and add dates
data_cbpol = data_cbpol(datescbpol >= datenum('1-Jan-2000'),:);     % sample starts in 2000

hdr_cbpol  = construct_hdr(cnts_ccy,'CBP',tckr_cbpol','CB Policy Rate','N/A','Monthly');