function [fltr,tnr,idx] = fltr4tickers(currency,type,floatleg,header)
% FLTR4TICKERS Identify tickers, tenors and position in header based on
% currency and type; for type IRS, also based on the floating leg
%
%     INPUTS
% char: currency - currency of the ticker
% char: type     - type of ticker (e.g. IRS, NDS, BS, etc.)
% char: floatleg - '3M' (3-month) or '6M' (6-month) floating interbank benchmark
% cell: header   - contains information about the tikcers (e.g. currency, type, tenor)
%
%     OUTPUT
% logical: fltr    - true when currency (col 1), type (col 2) -and leg (col 6)- match
% cell/double: tnr - available tenors
% double: idx      - position of tickers in header (the space of tickers)

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
if strcmp(type,'IRS') && ~isempty(floatleg) % Case of IRS convention for G10
    fltr = ismember(header(:,1),currency) & ismember(header(:,2),type) & contains(header(:,6),floatleg);
else                                        % Emerging markets and non-IRS cases
    fltr = ismember(header(:,1),currency) & ismember(header(:,2),type);
end

tnr  = header(fltr,5);                      % Tenors are in col 5
idx  = find(fltr);