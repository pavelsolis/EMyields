function [DYindex,DYtable] = ts_dyindex(S,cntrs,fldname,tenor)
% TS_DYINDEX Report the Diebold-Yilmaz (2014) connectedness index and table
% as implemented by Binh Thai Pham (2020)
%
% m-files called: cntrstimetable, computeDYtable, computeDYRolling
% Pavel Solís (pavel.solis@gmail.com), August 2020
% 
%% Load data
addpath(genpath('dy_code'))
TTy = cntrstimetable(S,cntrs,fldname,tenor);                                   % extract information
hdr = char(TTy.Properties.VariableNames');                                  % extract header
dts = datenum(TTy.Time);                                                    % extract dates
y   = TTy{:,:};                                                             % extract data
dy  = y(2:end,:) - y(1:end-1,:);                                            % daily changes
% dy(isnan(dy)) = 0;
idx = all(~isnan(dy),2);
dy  = dy(idx,:);                                                            % balanced panel
dts = dts(idx);
[nobs,nvars] = size(dy);

%% Parameters
nlags  = 1;                                                                 % Adrian et al. (2019)
nsteps = 10;                                                                % Bostanci & Yilmaz (2020)
window = 150;                                                               % Bostanci & Yilmaz (2020)

%% Static analysis

% Estimate VAR model
dts    = dts((end-nobs+1):end);
dy_sub = dy((end-nobs+1):end,:);
Mdl    = varm(nvars,nlags);
dyMdl  = estimate(Mdl,dy_sub);

% Connectedness table
[DYtable,~,~,~,Net] = computeDYtable(dyMdl,nsteps,1);                       % useGIRF
DYtable  = array2table([DYtable;[Net;NaN]']);
varnames = [hdr repmat('        ',size(hdr,1),1);'FROM_OTHERS'];
rownames = [hdr repmat('        ',size(hdr,1),1);'TO_OTHERS  ';'NET        '];
DYtable.Properties.VariableNames = cellstr(varnames);
DYtable.Properties.RowNames      = cellstr(rownames);

%% Dynamic analysis
[~,DYindex,~,~,~] = computeDYRolling(dy_sub,nlags,nsteps,window);
DYindex = [dts DYindex];