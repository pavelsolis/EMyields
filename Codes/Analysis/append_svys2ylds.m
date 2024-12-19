function S = append_svys2ylds(S,currEM)
% APPEND_SVYS2YLDS Append policy rate forecasts to yields of emerging
% markets; only yield data for advanced countries

% Pavel Solís (pavel.solis@gmail.com)
%%
ncntrs = length(S);
nEMs   = length(currEM);
fnames = fieldnames(S);
prefix = {'mn_','ms_'};
for k0 = 1:2
    fnameb = fnames{contains(fnames,[prefix{k0} 'blncd'])};
    for k1 = 1:nEMs                                                 % emerging markets
        if ~isempty(S(k1).scbp)                                    	% only for countries with survey data
            fltrt = ismember(S(k1).scbp(1,:),[5,10]);               % survey tenors to include
            hdry  = S(k1).(fnameb)(1,:);                         	% yield maturities (include first column)
            hdrv  = S(k1).scbp(1,fltrt);                           	% survey maturities
            ylds  = S(k1).(fnameb)(2:end,2:end);                  	% yields already in decimals
            svys  = S(k1).scbp(2:end,fltrt)/100;                  	% survey forecasts in decimals
            datey = S(k1).(fnameb)(2:end,1);                     	% dates of yields
            datev = S(k1).scbp(2:end,1);                          	% dates of surveys
            fltrd = datev >= datey(1);                              % survey data in sample period
            datev = datev(fltrd);                                	% keep survey data within sample period
            svys  = svys(fltrd,:);
            TTy   = array2timetable(ylds,'RowTimes',datetime(datey,'ConvertFrom','datenum'));
            TTs   = array2timetable(svys,'RowTimes',datetime(datev,'ConvertFrom','datenum'));
            TT    = synchronize(TTy,TTs,'union');
            S(k1).([prefix{k0} 'ylds']) = [hdry hdrv; datenum(TT.Time) TT{:,:}];
        else                                                        % countries w/ no survey data
            S(k1).([prefix{k0} 'ylds']) = S(k1).(fnameb);
        end
    end
    for k2 = nEMs+1:ncntrs                                         	% advanced countries
        S(k2).([prefix{k0} 'ylds']) = S(k2).(fnameb);
    end
end