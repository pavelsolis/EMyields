function [data,hdr] = remove_NaNcols(header,dataset)
% REMOVE_NANCOLS Remove columns with no data from a dataset, if any.
% 
%     INPUTS
% cell: header    - headers of dataset (may or may not have row 1 with titles)
% double: dataset - matrix with historic values (time in rows, vars in cols)
% 
%     OUTPUT
% double: data - matrix with historic values (with no all-NaN columns) 
% cell: hdr    - updated header (if no row 1 with titles in header, neither do hdr)

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
data     = dataset;
colsdata = size(data,2);
[rowshdr,colshdr] = size(header);

% Add extra row if needed
if rowshdr == colsdata                          % if header has row 1 with titles, use it
    hdr = header;
else                                            % otherwise, temporarily add row 1 with titles
    [hdr_aux{1:colshdr}] = deal('hdr'); 
    hdr = [hdr_aux; header];                    % needed for fltrNaN
end

% If there are cols with NaN, remove them
fltrNaN = findNaN(hdr, data);                   % find cols with all NaN
if sum(fltrNaN) > 0                             % if at least one col with all NaN
    data(:,fltrNaN) = [];                       % delete cols with no data
    hdr(fltrNaN,:)  = [];                       % delete corresponding rows in header
end

% Remove extra row if added
if rowshdr ~= colsdata                          % if row 1 was temporarily added
    hdr = hdr(2:end,:);                         % remove extra row 1
end

end

function [fltrNaN,NaNwho] = findNaN(header,dataset,cols)
% FINDNAN Find which columns in a dataset have all NaN
% 
%     INPUTS
% cell: header    - headers of dataset from which NaN columns will be identified
% double: dataset - matrix with historic values (time in rows, vars in cols)
% double: cols    - [optional] vector of header columns to be reported
% 
%     OUTPUT
% logical: fltrNaN - true for variables with no observations (only NaN)
% cell: NaNwho     - identifiers of variables with all NaN
%
%     EXAMPLES
% [fltrNaNdata,NaNdata] = findNaN(hdr_blp, data_blp, [1 3]);
% [fltrNaNccs,NaNccs]   = findNaN(hdr_ccs, data_ccs);

%%
NaNdata = isnan(dataset);                       % matrix of logicals for NaN
NaNmax  = max(sum(NaNdata));                    % maximum number of NaN in the dataset
fltrNaN = sum(NaNdata) == NaNmax;               % logical row vector for cols with only NaN
nobs    = size(dataset,1);                      % number of observations in the dataset
if NaNmax == nobs                               % if at least one variable has all NaN
    if exist('cols','var')                      % if cols defined, report those cols
        NaNwho = header(fltrNaN,cols);
    else                                        % if cols not defined, report all cols
        NaNwho = header(fltrNaN,:);
    end
else
    fltrNaN(:) = 0; NaNwho = {};                % if NaNmax ~= nobs, there is no all NaN cols
end

end