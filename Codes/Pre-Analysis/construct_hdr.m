function header = construct_hdr(varargin)
% This function constructs a cell array of headers that can be stacked to
% the existing headers for a dataset. It follows the order in which the
% variables are introduced.
%
%     INPUTS
% char/double: from none to all; they can be currency, type (LC, IRS, etc.), name
% and/or
% cell: from none to all; they can be tikcers, name, tenors (all must have same dimensions)
% 
%     OUTPUT
% cell: header - dimensions are given by size of cell inputs and by number of variables
%
%     EXAMPLES
% A = construct_hdr(currency, type, ticker, name, tenor);
% A = construct_hdr('USD', 'LC', ticker, 'YC', tenor, NaN, 'GSW');
%
% Pavel Solís (pavel.solis@gmail.com)
%%
nvars = length(varargin);                     % Number of input variables
sizes = zeros(nvars,1);
for k = 1:nvars
    sizes(k) = size(varargin{k},1);           % Detect char/double (sizes = 1) vs. cell (sizes > 1) variables
end

maxsize = max(sizes);
idx    = sizes > 1;                           % Logical for variables of type cell
if sum(sizes(idx)) ~= maxsize*sum(idx)        % Verify that all cell variables have same dimensions
    error('Inputs of type cell must have the same dimensions.')
end

header = cell(maxsize,nvars);
for k = 1:nvars
    if sizes(k) == 1                          % If char, repeat in all rows
        [header{:,k}] = deal(varargin{k});    % Equivalent of [A{:,1}] = deal('USD')
    else                                      % If cell, each element goes in a row
        [header{:,k}] = deal(varargin{k}{:}); % Equivalent of [A{:,3}] = deal(ticker{:})
    end
end
