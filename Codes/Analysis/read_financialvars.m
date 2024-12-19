function [data_finan,hdr_finan] = read_financialvars()
% READ_FINANCIALVARS Read daily data for financial variables
%   data_finan: stores historical data
%   hdr_finan: stores headers

% Pavel Solís (pavel.solis@gmail.com)
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = {'Macro_Vars_Tickers.xlsx','Macro_Vars_Data.xlsx'};

% Read financial data from Bloomberg
cd(pathd)
hdr_finan  = readcell(namefl{1},'Sheet','Tickers','ExpectedNumVariables',6);% read headers
hdr_finan  = hdr_finan(:,1:6);                                              % remove extra columns
data_finan = readmatrix(namefl{2},'Sheet','All');                           % read macro variables
datesmcr   = x2mdate(data_finan(:,1),0);                                    % dates from Excel to Matlab format
data_finan(:,1) = datesmcr;
cd(pathc)