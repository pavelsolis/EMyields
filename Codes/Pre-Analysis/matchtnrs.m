function [fltr,commontnrs] = matchtnrs(fltr,tnr,idx)
% This function adjusts the filters in fltr so that the tenors in tnr match.
% Note: Although the tenors coincide, they need not be unique.
%
%     INPUTS
% cell: fltr  - vectors of logicals with 1's for the relevant tickers
% cell: tnr   - vectors indicating the tenors available per type
% double: idx - vectors with positions (rows) of tickers in the space of tickers
%
%     OUTPUT
% cell: fltr - fltr updated with the same tenors for the different types
% cell: commontnrs - common tenors for the different types
%
% Pavel Solís (pavel.solis@gmail.com)
%%
nvars = size(tnr,2);
if nvars == 1
    commontnrs = tnr;
else
    commontnrs = intersect(tnr{1},tnr{2},'stable'); % nvars is at least 2
    if nvars > 2
        for k = 3:nvars
            commontnrs = intersect(commontnrs,tnr{k},'stable');
        end
    end
end

for k = 1:nvars
    fltr{k} = adjustfltr(fltr{k},tnr{k},idx{k},commontnrs);
end


    function fltr1 = adjustfltr(fltr1,tnr1,idx1,tnr2)
        % This function deletes 1's of fltr1 based on the common tenors
        % indicated in tnr2. Assumes that numel(tnr1) >= numel(tnr2).
        %
        %     INPUTS
        % logical: fltr1 - filter to be adjusted
        % char: tnr1     - vector of original tenors
        % double: idx1   - position of the respective tickers in the space of tickers
        % char: tnr2     - vector of common tenors
        %
        %     OUTPUT
        % logical: fltr1 - updated to match the tenors in tnr2
        %
        % Pavel Solís (pavel.solis@gmail.com), March 2019
        %
        tnrMatch = ismember(tnr1,tnr2); % Logical for tenors needed [numel(tnr1) >= numel(tnr2)]
        idx1     = idx1(tnrMatch);      % Identify location of tenors needed
        fltr1(:) = 0;                   % Clean the filter (o/w some 1's remain)
        fltr1(idx1) = 1;                % Choose only tenors needed
    end

end