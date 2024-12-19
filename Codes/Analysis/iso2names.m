function ccy_names = iso2names(iso)
% ISO2NAMES Return country and currency names, three-letter ISO codes and
% three-digit IMF codes
%   iso: three-letter code(s) indicating the currency (ISO 4217)
%   ccy_names: country names, currency names, three-letter and -digit codes

% Pavel Solís (pavel.solis@gmail.com)
%%
% Retrieve codes from sources
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');            % platform-specific file separators
cd(pathd)
codes_imf = readcell('IMF_Country_Codes.xlsx','NumHeaderLines',2);
opts = detectImportOptions('ISO_Currency_Codes.xlsx');
opts.DataRange = 'A5';
codes_iso = table2cell(readtable('ISO_Currency_Codes.xlsx',opts));
cd(pathc)

codes_imf(:,5:end) = [];  codes_iso(:,4:end) = [];          % delete unnecessary data
%%
% For country names from ISO
[~,id] = unique(codes_iso(:,1),'stable');
codes_iso = codes_iso(id,:);                                % delete duplicate country names

aux1 = regexprep(codes_iso(:,1),' \([^\(\)]*\)','');        % delete (what's inside) parentheses
aux1 = replace(aux1,',','');                                % remove commas
aux1 = string(regexp(aux1,'^\w*(\s\w*)?','match'));         % only names with at most two words
aux1 = cellstr(regexp(aux1,'^\w*(\s\w*)?','match'));
codes_iso(:,1) = aux1;

% Exclude countries that complicate the match
xclude_name = {'Australia';'Germany'};
idx       = ismember(lower(codes_iso(:,1)),lower(xclude_name));
% xclude_ccy  = codes_iso(idx,2);
xclude_code = codes_iso(idx,3);
ccy_codes   = iso(~ismember(iso,xclude_code));

% From ISO codes to IMF codes
idx0     = ismember(codes_iso(:,3),ccy_codes);              % match currency codes
iso_ccy  = unique(codes_iso(idx0,2));                       % use currency name
iso_name = unique(codes_iso(idx0,1));                       % use country name

idx1    = ismember(lower(codes_imf(:,3)),lower(iso_name));  % match country name
z1_name = codes_imf(idx1,3);
z1_ccy  = codes_imf(idx1,4);                                % implied currencies

idx2    = ismember(lower(codes_imf(:,4)),lower(iso_ccy));   % match currency name
z2_ccy  = codes_imf(idx2,4);
z2_name = codes_imf(idx2,3);                                % implied countries

miss_name = setdiff(z2_name,z1_name);
idx3      = ismember(lower(codes_imf(:,3)),lower([miss_name;xclude_name])); % match country name

miss_ccy = setdiff(z2_ccy,z1_ccy);
% idx4     = ismember(lower(codes_imf(:,4)),lower([miss_ccy;xclude_ccy])); % match currency name

fltr_imf = idx1 | idx2 | idx3;
codesNUM = codes_imf(fltr_imf,[1 3 4]);

% From IMF codes to ISO codes
idx5 = ismember(lower(codes_iso(:,1)),lower([z1_name;xclude_name]));
idx6 = ismember(lower(codes_iso(:,2)),lower(miss_ccy));
fltr_iso = idx5 | idx6;
codesWRD = codes_iso(fltr_iso,[1 2 3]);

idx7 = ismember(codesWRD(:,3),[ccy_codes;xclude_code]);     % delete extra countries
codesWRD = codesWRD(idx7,:);

% Combine codes and names
ccy_names = [codesNUM codesWRD(:,end)];                     % both ordered alphabetically by country

% Express the three-digit codes as doubles
aux2 = cellfun(@str2num,ccy_names(:,1));
aux2 = num2cell(aux2);
ccy_names(:,1) = aux2;

% Reorder columns to country, currency, iso, imf
ccy_names = ccy_names(:,[2 3 4 1]);

% Reorder rows from alphabetical to EM-AE ordering (assumes iso has EM-AE ordering)
[~,idx_imf] = sort(ccy_names(:,3));                         % reorder iso from alphabetical
[~,idx_iso] = sort(iso);                                    % reorder original iso so both match
[~,idx_idx] = sort(idx_iso);                                % restore original iso

aux3 = ccy_names(idx_imf,:);                                % reorder to alphabetical
ccy_names = aux3(idx_idx,:);                                % reorder to match original