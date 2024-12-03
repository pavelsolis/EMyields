function [TT_kw,kwtp,kwyp] = read_kw(maturities)
% READ_KW Read the Kim-Wright decomposition of the US yield curve from FRED

% m-files called: getFredData, syncdatasets
% Pavel Solís (pavel.solis@gmail.com), July 2020
%%
datemn = datestr(datenum('1-Jan-2000'),29);                         % 29: date format ID
datemx = datestr(datenum(today()),29);
series = {'THREEFY','THREEFYTP'};                                   % fitted yields and term premium
mats   = maturities(rem(maturities,1) == 0 & maturities <= 10);   	% only annual maturities up to 10Y
nmats  = length(mats);
nsrs   = length(series);

for k0 = 1:nsrs
    for k1 = 1:nmats
        tnr  = mats(k1);                                            % tenor as a number
        KWfr = getFredData([series{k0} num2str(tnr)],datemn,datemx);% pull data
        KWdt = [nan tnr; KWfr.Data];                                % add headers for syncdatasets
        KWdt(isnan(KWdt(:,2)),:) = [];                            	% remove NaNs
        if k0 == 1 && k1 == 1                                      	% first tenor of first series
            KW = KWdt;
        else
            KW = syncdatasets(KW,KWdt);                             % append new series
        end
    end
end
KW(1,:) = [];                                                       % remove headers
yP = KW(:,2:nmats+1) - KW(:,nmats+2:end);                           % expected future short rate
KW = [KW yP];                                                       % append to existing variables

tnrs  = cellfun(@num2str,num2cell(mats*12),'UniformOutput',false);	% tenors as strings
tnrs  = strcat(tnrs,'M');                                           % tenors are in months 
names = [strcat('USyQ',tnrs) strcat('USTP',tnrs) strcat('USyP',tnrs)];
TT_kw = array2timetable(KW(:,2:end),'RowTimes',datetime(KW(:,1),'ConvertFrom','datenum'),'VariableNames',names);

kwtp = [nan mats; datenum(TT_kw.Time) TT_kw{:,contains(TT_kw.Properties.VariableNames,'TP')}];
kwyp = [nan mats; datenum(TT_kw.Time) TT_kw{:,contains(TT_kw.Properties.VariableNames,'yP')}];