function [dates,yonly,ynsvys,matsY,matsS] = splityldssvys(S,k,fldname)
% SPLITYLDSSVYS Report yield and survey data separately along with their 
% maturities and dates for country k in field fldname

% Pavel Solís (pavel.solis@gmail.com)
%%
dates  = S(k).(fldname)(2:end,1);
ynsvys = S(k).(fldname)(2:end,2:end);
mats   = S(k).(fldname)(1,:);                                               % include first column
startS = find(mats(2:end) - mats(1:end-1) < 0);                             % position where survey data starts
mats   = mats(2:end);                                                       % remove extra first column
if isempty(startS)                                                          % if only yields in dataset
    matsY = mats(1:end);                                                    % yield maturities in years
    matsS = [];
    yonly = ynsvys;                                                         % extract yields
else
    matsY = mats(1:startS-1);                                               % yield maturities in years
    matsS = mats(startS:end);                                               % survey maturities in years
    yonly = ynsvys(:,1:startS-1);                                           % extract yields
end