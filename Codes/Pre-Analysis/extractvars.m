function [vars,tenors] = extractvars(currencies,types,header,dataset)
% This function extracts from dataset the tickers (and the corresponding 
% tenors) specified in currencies and types.
% Assumes ctrs_struct.m has already been run.
% m-files called: fltr4tickers.m, matchtnrs.m
% 
%     INPUTS
% cell: currencies - currencies of the tickers to be extracted
% cell: types      - types of tickers (e.g. IRS, NDS, BS, etc.) to be extracted
% cell: header     - contains information about the tikcers (e.g. currency, type, tenor)
% double: dataset  - contains historic values of all the tickers
% 
%     OUTPUT
% double: vars - variables extracted from dataset, with matched tenors
% cell: tenors - useful to construct the header for the extracted variables
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
ncur = numel(currencies);
ntyp = numel(types);
if ncur ~= ntyp
    error('The number of elements in currencies and types must match.')
end

% Filters
floatleg = ''; nloops = 0;
while nloops <= 0                               % Runs at least once; if IRS case, runs two more times
    fltr = cell(1,ntyp); tnr = cell(1,ntyp); idx = cell(1,ntyp); vars = cell(1,ntyp);
    for k = 1:ntyp                              % Identify tickers, as well as their tenors and positions
        [fltr{k},tnr{k},idx{k}] = fltr4tickers(currencies{k},types{k},floatleg,header);
    end
    
    % Case of two LC or FC yield curves in dataset (detect repeated tenors with unique)
    LoF = ismember(types,{'LC','USD'});
    if any(LoF)
        pLoF = find(LoF);
        for k = 1:numel(pLoF)
            nLoF = pLoF(k);
            if ~isequal(length(unique(tnr{:,nLoF})),length(tnr{:,nLoF}))
                fltr{:,nLoF} = fltr{:,nLoF} & startsWith(header(:,3),{'C','P'});  % BFV curve starts w/ C or P
                tnr{:,nLoF}  = header(fltr{:,nLoF},5);                            % Update tnr; tenors in col 5
                idx{:,nLoF}  = find(fltr{:,nLoF});                                % Update idx
            end
        end
    end
    
    [fltr,tenors] = matchtnrs(fltr,tnr,idx);
    
    % Extract Information
    for k = 1:ntyp
        vars{k} = dataset(:,fltr{k});           % Extract the history of the tickers needed
    end
    
    nloops = nloops + 1;                        % Exit while loop the first time for EMs and G10 w/o cutoff date

    if ismember('IRS',types)                        % IRS case: IRS for 3M and 6M
        if numel(vars) > 1                          % IRS case only arises when extracting more than 1 variable
            if size(vars{1},2) ~= size(vars{2},2)   % Case of IRS convention for G10 (assumes IRS is var{1})
                nloops = -1;                        % Need to run the while loop two more times (3M and 6M)
            end
        end

        if  nloops == -1                            % Do first recalculation for 6M
            floatleg = '6M';
        elseif nloops == 0                          % Do second recalculation for 3M
            vars1    = vars;                        % Save vars and tenors for 6M
            tenors1  = tenors;
            floatleg = '3M';
        end
    end
end

% When IRS is in types, merge variables using a cutoff date
if exist('vars1','var') == 1                    % If variable vars1 exist, deal with IRS case
    vars2   = vars;                             % Save vars and tenors for 3M
    tenors2 = tenors;

    LC = currencies{1};                         % First currency is always the local currency
    [vars,tenors] = split_merge_vars(LC,vars1,vars2,tenors1,tenors2,dataset);
end
