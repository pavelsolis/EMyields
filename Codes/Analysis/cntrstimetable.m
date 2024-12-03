function TTvar = cntrstimetable(S,cntrs,fldname,tenor)
% CNTRSTIMETABLE Return timetable w/ variable fldname for countries in cntrs
% 
% m-files called: none
% Pavel Solís (pavel.solis@gmail.com), August 2020
%% 
nctrs   = length(S);
datehld = datetime(lbusdate(2001,3),'ConvertFrom','datenum');               % based on 1st obs of survey data
for k0  = 1:nctrs
    % Extract variable in a timetable
    if ~isempty(S(k0).(fldname))                                            % country w/ no data
        ctymtrx = S(k0).(fldname);                                          % extract information
        [nrows,ncols] = size(ctymtrx);
        if isnan(ctymtrx(1,1)) || ctymtrx(1,1) == 0                         % identify whether tenors in 1st row
            fltrROW = [false; true(nrows-1,1)];                             % if so, start in 2nd row
            if nargin < 4; tenor = 10; end                                  % default tenor is 10Y
            fltrCOL = ctymtrx(1,:) == tenor;
        else
            fltrROW = true(nrows,1);                                        % o/w start in 1st row
            fltrCOL = [false(ncols-1,1); true];                             % last column (b/c no tenors)
        end
        datesVAR = ctymtrx(fltrROW,1);                                      % extract dates
        dataVAR  = ctymtrx(fltrROW,fltrCOL);                                % extract variable
        
        TTaux = array2timetable(dataVAR,'RowTimes',datetime(datesVAR,'ConvertFrom','datenum'),'VariableNames',{S(k0).iso});
    else                                                                    % placeholder when no data
        TTaux = array2timetable(nan,'RowTimes',datehld,'VariableNames',{S(k0).iso});
    end
    
    % Append variables
    if k0 == 1
        TTvar = TTaux;
    else
        TTvar = synchronize(TTvar,TTaux,'union');
    end
end

TTvar = TTvar(:,ismember(TTvar.Properties.VariableNames,cntrs));