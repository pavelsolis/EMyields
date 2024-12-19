function [mrgd,dtst1,dtst2] = syncdatasets(dtst1,dtst2,synctype)
% SYNCDATASETS Synchronize arrays (default is intersection)

% Pavel Solís (pavel.solis@gmail.com)
%%
if nargin < 3; synctype = 'intersection'; end
hdr1  = dtst1(1,2:end);
hdr2  = dtst2(1,2:end);
cols1 = size(dtst1,2);
TT1   = array2timetable(dtst1(2:end,2:end),'RowTimes',...
        datetime(dtst1(2:end,1),'ConvertFrom','datenum'));
TT2   = array2timetable(dtst2(2:end,2:end),'RowTimes',...
        datetime(dtst2(2:end,1),'ConvertFrom','datenum'));
TT    = synchronize(TT1,TT2,synctype);
mrgd  = [nan hdr1 hdr2; datenum(TT.Time) TT{:,:}];
dtst1 = mrgd(:,1:cols1);
dtst2 = [mrgd(:,1) mrgd(:,cols1+1:end)];