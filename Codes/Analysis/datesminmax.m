function [dtmn,dtmx] = datesminmax(S,k0)
% DATESMINMAX From the first observations of the balanced panels for nominal
% and synthetic yields, return earliest and latest date. If available, daily
% data has precedence

% Pavel Solís (pavel.solis@gmail.com), July 2020
%%
flddts = '_blncd';
fldnms = fieldnames(S);
if ismember(['mn' flddts],fldnms)               % monthly data current version
    date1 = S(k0).(['mn' flddts])(2,1);     % datenum(S(k0).mn_dateb,'mmm-yyyy');
    date2 = S(k0).(['ms' flddts])(2,1);     % datenum(S(k0).ms_dateb,'mmm-yyyy');
else                                            % monthly data previous version
    date1 = S(k0).(['n' flddts])(2,1);      % datenum(S(k0).n_dateb,'mmm-yyyy');
    date2 = S(k0).(['s' flddts])(2,1);      % datenum(S(k0).s_dateb,'mmm-yyyy');
end
if ismember(['dn' flddts],fldnms)               % daily data
    date1 = S(k0).(['dn' flddts])(2,1);     % datenum(S(k0).dn_dateb,'mmm-yyyy');
    date2 = S(k0).(['ds' flddts])(2,1);     % datenum(S(k0).ds_dateb,'mmm-yyyy');
end
dtmn  = min(date1,date2); 
dtmx  = max(date1,date2);