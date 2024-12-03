function S = add_macroNsvys(S,currEM)
% ADD_MACRONSVYS Add macro variables and survey data to structure S

% m-files called: read_macrovars, read_surveys, read_spf, trend_inflation, datesminmax
% Pavel Solís (pavel.solis@gmail.com), January 2021
%%
[data_macro,hdr_macro] = read_macrovars(S);                             % macro and policy rates
[data_svys,hdr_svys]   = read_surveys();                                % CPI and GDP forecasts
TT_rr = read_spf();                                                     % US real rates forecasts
nEMs  = length(currEM);

%% Store macro data
vars   = {'INF','UNE','IP','GDP','CBP'};
fnames = lower(vars);
for l  = 1:length(vars)
    fltrMAC = ismember(hdr_macro(:,2),vars{l});
    for k = 1:nEMs
        fltrCTY    = ismember(hdr_macro(:,1),S(k).iso) & fltrMAC;
        fltrCTY(1) = true;                                              % include dates
        data_mvar  = data_macro(:,fltrCTY);
        if size(data_mvar,2) > 1
            idxNaN = isnan(data_mvar(:,2));                             % assume once release starts, it continues
            S(k).(fnames{l}) = data_mvar(~idxNaN,:);
        end
    end
end

%% Store survey data
tenors  = cellfun(@str2double,regexp(hdr_svys,'\d*','Match'),'UniformOutput',false);%tnrs in hdr_svys
fltrSVY = ~contains(hdr_svys,{'00Y','02Y','03Y','04Y'});             	% exclude current year and years 2 to 4
macrovr = {'CPI','GDP'};
cbptnrs = {'01Y','05Y','10Y'};
varnms1 = strcat('CPI',cbptnrs);
varnms2 = strcat('RHO',cbptnrs);
for k0  = 1:2
    for k1 = 1:nEMs
        fltrCTY = contains(hdr_svys,{'DATE',S(k1).iso}) & fltrSVY;      % include dates
        svydata = data_svys(:,fltrCTY);                                 % extract variables
        svyname = hdr_svys(fltrCTY);                                    % extract headers
        svytnrs = unique(cell2mat(tenors(fltrCTY)));                    % extract unique tnrs as doubles
        svyvar  = svydata(:,contains(svyname,macrovr{k0}));
        
        if sum(fltrCTY) > 1                                             % country w/ survey data
            dtmn   = datesminmax(S,k1);                              	% relevant starting date for surveys
            fltrDT = any(~isnan(svyvar),2) & svydata(:,1) >= dtmn;      % svy obs after first yld obs
            S(k1).(['s' lower(macrovr{k0})]) = [nan svytnrs;            % store survey data on macro vars
                                                svydata(fltrDT,1) svyvar(fltrDT,:)];
        end
    end
end

S = trend_inflation(S,currEM,{'ILS','ZAR'},true,true);                  % use trend inflation when no survey data


%% Compute implied CBP forecasts (only need survey data on inflation)
for k1 = 1:nEMs
        % Match surveys for real rates & inflation
        svytnrs = S(k1).scpi(1,2:end);
        TTscpi  = array2timetable(S(k1).scpi(2:end,2:end),...
            'RowTimes',datetime(S(k1).scpi(2:end,1),'ConvertFrom','datenum'),'VariableNames',varnms1);
        TTsvy   = synchronize(TT_rr,TTscpi,'intersection');

        % Match surveys with forward premium
        TTrho = array2timetable(S(k1).mr_blncd(2:end,ismember(S(k1).mr_blncd(1,:),[1,5,10]))*100,...
            'RowTimes',datetime(S(k1).mr_blncd(2:end,1),'ConvertFrom','datenum'),'VariableNames',varnms2);
        TTsvy = synchronize(TTsvy,TTrho,'intersection');

        % Calculate implied CBP forecasts under SOE assumption
        for k2 = cbptnrs
            lnmdl = fitlm(timetable2table(TTsvy),['RHO' k2{:} '~' 'CPI' k2{:}]);
            TTsvy.(['FPR' k2{:}]) = lnmdl.Residuals.Raw;
            TTsvy.(['CBP' k2{:}]) = TTsvy.(['USRR' k2{:}]) + TTsvy.(['FPR' k2{:}]) + TTsvy.(['CPI' k2{:}]);
            % TTsvy.(['CBP' k2{:}]) = TTsvy.(['USRR' k2{:}]) + TTsvy.(['CPI' k2{:}]); % w/o FP correction
        end

        S(k1).('scbp') = [nan svytnrs;                              % store implied CBP forecasts
                          datenum(TTsvy.Time) TTsvy.CBP01Y TTsvy.CBP05Y TTsvy.CBP10Y];
        S(k1).('usrr') = [nan svytnrs;                              % store US real rates
                          datenum(TTsvy.Time) TTsvy.USRR01Y TTsvy.USRR05Y TTsvy.USRR10Y];
 end