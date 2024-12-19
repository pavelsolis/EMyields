function [vars,tenors] = split_merge_vars(LC,vars1,vars2,tenors1,tenors2,dataset)
% This function splits the variables in vars1 and vars2 using a cut-off date and
% merge them into vars. It only applies to AE currencies.
% 
%     INPUTS
% string: LC      - local currency is used to find the corresponding cut-off date
% double: vars1   - variables before the cut-off date with matched tenors
% double: vars2   - variables after the cut-off date with matched tenors
% cell: tenors1   - tenors of the variables in vars1
% cell: tenors2   - tenors of the variables in vars2
% double: dataset - contains dates and historic values of all the tickers
% 
%     OUTPUT
% double: vars - merges vars1 and vars2 before and after the cut-off date
% cell: tenors - useful to construct the header for the extracted variables
%
% Pavel Solís (pavel.solis@gmail.com)
%%
% Check that each cell in vars1 and vars2 has the same size
if iscell(vars1) && iscell(vars2)
    szvars1 = cellfun(@size,vars1,'uni',false)';                            % Obtain the sizes of all cells in vars1
    szvars2 = cellfun(@size,vars2,'uni',false)';
    szvars1 = cell2mat(szvars1);                                            % Stack sizes of cells in vars1 (#obs in col1, #tnrs in col2)
    szvars2 = cell2mat(szvars2);
    mnvars1 = numel(unique(szvars1));                                       % If all have same sizes, only 2 unique values (#obs and #tnrs)
    mnvars2 = numel(unique(szvars2));                                       % numel since tenors1 and tenors2 can contain different tenors
    nvars1 = size(szvars1,1);
    nvars2 = size(szvars2,1);
    if ~isequal(nvars1,nvars2)
        warning('vars1 and vars2 must have same number of variables.')
    end
else
    nvars1  = 1;                                                            % If vars1 and vars2 are not cell arrays, they only have one var
    mnvars1 = size(vars1);
    mnvars2 = size(vars2);
end
if ~isequal(mnvars1,mnvars2)
    warning('Verify that the sizes (of the cells) in vars1 and vars2 are the same.')
end

% Identify all tenors from vars1 and vars2
tenors = unique([tenors1;tenors2],'stable');
dates  = dataset(:,1);

% Split the variables using the cut-off date and merge them
cutoff     = cutoff_dates();                                                % Read cut-off dates
fltr_tnr1  = ismember(tenors,tenors1);                                      % tenors1 and tenors2 can contain same or different tenors
fltr_tnr2  = ismember(tenors,tenors2);
fltr_cdate = ismember(cutoff(:,1),LC);                                      % Find cut-off date for country
fltr_dates = dates < cutoff{fltr_cdate,2};                                  % Use the cut-off date to split the variables

if iscell(vars1) && iscell(vars2)
    vars   = cell(1,nvars1);
    for k = 1:nvars1
        vars{k} = nan(numel(dates),numel(tenors));
        vars{k}(fltr_dates,fltr_tnr1)  = vars1{k}(fltr_dates,:);
        vars{k}(~fltr_dates,fltr_tnr2) = vars2{k}(~fltr_dates,:);           % Includes the cut-off date
    end
else
    vars = nan(numel(dates),numel(tenors));
    vars(fltr_dates,fltr_tnr1)  = vars1(fltr_dates,:);
    vars(~fltr_dates,fltr_tnr2) = vars2(~fltr_dates,:);                     % Includes the cut-off date
end
end

function cutoff = cutoff_dates()
% This function reads the cut-off dates in which the convention for computing
% IRS for some AE currencies changed from 6 months to 3 months. 
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
cd(pathd)
namefl = 'AE_EM_Curves_Tickers.xlsx';
ctrs   = readcell(namefl,'Sheet','FWD PRM','Range','B5:B14');               % update ranges as necessary
raw    = readmatrix(namefl,'Sheet','FWD PRM','Range','F5:F14');	            % matrix with dates in Excel format
raw    = num2cell(x2mdate(raw));                                 	        % dates in Matlab format in cell array
cutoff = [ctrs, raw];
cd(pathc)
end