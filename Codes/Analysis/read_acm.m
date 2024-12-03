%% Read ACM Term Premimum
% This code reads the term premium estimated by ACM (2013).
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
path = pwd;
cd(fullfile(path,'..','..','Data'))        % Use platform-specific file separators
filename  = 'original_ACM_Term_Premium.xlsx';
[data_acm,txt] = xlsread(filename,'ACM Monthly');
hdr_acm   = txt(1,:);
dates_acm = datenum(txt(2:end,1));
data_acm  = [dates_acm data_acm];           % Append data to dates
cd(path)

clear filename path dates_acm txt
 