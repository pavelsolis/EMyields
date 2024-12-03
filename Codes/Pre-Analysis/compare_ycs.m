function [data_zcus,hdr_zcus] = compare_ycs(dataset,header,curncs)
% COMPARE_YCS Compare BFV and IYC yield curves from Bloomberg
% BFV and IYC curves report coupon-equivalent (CE) par and zero-coupon yields,
% they are converted to zero-coupon continuosly compounded (CC) yields and plotted;
% the code assumes the compounding frequency of CE yields is semiannual
% COP, HUF, IDR, KRW, MXN, MYR, PEN, PHP, PLN, ZAR, USD have BFV and IYC LC curves
% RUB, THB, TRY, AEs only have BFV curves; BRL and ILS only have IYC LC curves
%   data_zcus: stores historical data
%   hdr_zcus: stores headers (note: no title row, i.e. ready to be appended)

% m-files called: fltr4tickers, construct_hdr
% Pavel Solís (pavel.solis@gmail.com), April 2020

%% Compare BFV and IYC curves for countries having both
frqCE  = 2;                                                     % CE compounding frequency: 2 - semiannual
settle = dataset(:,1);

for k0  = 1:numel(curncs)+1
    if k0 > numel(curncs); LC = 'USD'; else; LC = curncs{k0}; end % identify country
    [fltr,tnrscll] = fltr4tickers(LC,'LC','',header);
    
    if ~isequal(length(unique(tnrscll)),length(tnrscll))        % countries with BFV *and* IYC curves
    % BFV curve
    fltrBFV    = fltr & startsWith(header(:,3),{'C','P'});     	% BFV curve starts w/ C or P
    tnrscllBFV = header(fltrBFV,5);                           	% update tenors (col 5 in header)
    tnrsnumBFV = cellfun(@str2num,tnrscllBFV);
    
    % IYC curve
    fltrIYC    = fltr & ~startsWith(header(:,3),{'C','P'});   	
    tnrscllIYC = header(fltrIYC,5);                            	% update tenors (col 5 in header)
    tnrsnumIYC = cellfun(@str2num,tnrscllIYC);
    
    % Extract information (in decimals)
    yldsCEpar = dataset(:,fltrBFV)/100;                         % days w/ data: sum(~isnan(yldsCEpar))
    yldsCEzc  = dataset(:,fltrIYC)/100;
    
    [ndates,ntnrs] = size(yldsCEpar);    ydates  = nan(ndates,ntnrs);
    for k1 = 1:ndates
        % Convert BFV par yields CE to zc yields CC
        fltryBFV   = ~isnan(yldsCEpar(k1,:));               	% tenors with observations
        tnrsBFV    = tnrsnumBFV(fltryBFV);                      % define the tenors
        yzc2fitBFV = [];
        if sum(fltryBFV) > 0                                 	% at least one observation
            ydates(k1,fltryBFV) = datemnth(settle(k1),12*tnrsBFV); % maturities based on settlement day
            try
                yzc2fitBFV = pyld2zero(yldsCEpar(k1,fltryBFV)',ydates(k1,fltryBFV)',settle(k1),...
                            'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
            catch
                try                                             % eg. curncs{4} = 'IDR', k1 = 2292
                    yzc2fitBFV = pyld2zero(yldsCEpar(k1-1,fltryBFV)',ydates(k1,fltryBFV)',settle(k1),...
                        'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                catch                                           % eg. curncs{4} = 'IDR', k1 = 2305
                    try
                    yzc2fitBFV = pyld2zero(yldsCEpar(k1-2,fltryBFV)',ydates(k1,fltryBFV)',settle(k1),...
                        'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    catch
                    try
                    yzc2fitBFV = pyld2zero(yldsCEpar(k1-3,fltryBFV)',ydates(k1,fltryBFV)',settle(k1),...
                    'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    catch
                    yzc2fitBFV = pyld2zero(yldsCEpar(k1-4,fltryBFV)',ydates(k1,fltryBFV)',settle(k1),...
                        'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    end
                    end
                end
            end
        end
        
        % IYC zc yields CE to zc yields CC
        fltryIYC = ~isnan(yldsCEzc(k1,:));                   	% tenors with observations
        tnrsIYC = tnrsnumIYC(fltryIYC);                      	% define the tenors
        yzc2fitIYC = frqCE*log(1 + yldsCEzc(k1,fltryIYC)'./frqCE);
        if strcmp(LC,'PHP') && settle(k1) >= datenum('01-Oct-2018') % convert IYC into CE par yields
            yparPHP(k1,:) = zero2pyld(yzc2fitIYC,ydates(k1,fltryBFV)',settle(k1),...
                'InputCompounding',-1,'InputBasis',0,'OutputCompounding',2,'OutputBasis',0)'*100;
        end
        
        % Plot and compare
        if sum(fltryBFV) > 0 || sum(fltryIYC) > 0
            plot(tnrsBFV,yzc2fitBFV*100,'b',tnrsIYC,yzc2fitIYC*100,'r')
            title([LC '  ' datestr(settle(k1))])
            H(k1) = getframe(gcf);                           	% imshow(H(2).cdata) for a frame
        end
    end
    end
end

%% Comparison of US yield curves: Bloomberg (BFV, IYC) vs GSW
hdr_zcus  = {};                                                 % no title row (ie. ready to be appended)
data_zcus = dataset(:,1);
settle    = dataset(:,1);
LC        = 'USD';
for k0    = 1:3                                                 % 1 - GSW, 2 - BFV, 3 - IYC
tic
    % Determine yield curve
    [fltr,~] = fltr4tickers(LC,'LC','',header);
    if     k0 == 1
        [fltr,tnrscll] = fltr4tickers(LC,'LCNOM','',header);   	% GSW curve
    elseif k0 == 2
        fltr    = fltr & startsWith(header(:,3),{'C','P'});   	% BFV curve starts w/ C or P
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    elseif k0 == 3
        fltr    = fltr & ~startsWith(header(:,3),{'C','P'});   	% IYC curve
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    end
    tnrsnum = cellfun(@str2num,tnrscll);
    
    % Exclude tenors not in BFV or IYC
    ftrue = find(fltr);                                         % ftrue, ttrue, tnrs* have same dimensions
    ttrue = ~ismember(tnrsnum,[0.75 6 11:30]);                	% tenors not in BFV/IYC and to exclude
    tnrsnum(~ttrue) = [];   tnrscll(~ttrue) = [];   ftrue(~ttrue) = [];
    fltr(:) = false;        fltr(ftrue)     = true;
    
    % Extract information and preallocate variables
    yldsCE = dataset(:,fltr)/100;                               % in decimals
    [ndates,ntnrs] = size(yldsCE);
    yldszc  = nan(ndates,ntnrs);    ydates  = nan(ndates,ntnrs);    rmse = nan(ndates,3);   params = [];
    
    % Type of yield curve
    if k0 == 1; yldszc = yldsCE*100; else                   	% GSW curve
    for k1 = 1:ndates                                           % fit NS/NSS models daily
        fltry = ~isnan(yldsCE(k1,:));                           % tenors with observations
        if sum(fltry) > 0                                       % at least one observation
            % Tenors and maturities (based on settlement day)
            tnrs = tnrsnum(fltry);                              % define the tenors
            ydates(k1,fltry) = datemnth(settle(k1),12*tnrs);    % define maturity dates
            
            % Yields treatment depending on whether BFV or IYC curve (column vectors)
            if     k0 == 2                                      % BFV par yields CE to zc yields CC
                yzc2fit = pyld2zero(yldsCE(k1,fltry)',ydates(k1,fltry)',settle(k1),...
                        'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
            elseif k0 == 3                                      % IYC zc yields CE to zc yields CC
                yzc2fit = frqCE*log(1 + yldsCE(k1,fltry)'./frqCE);
            end
            
            % Initial values from the data
            fmin  = find(fltry,1,'first');   fmax = find(fltry,1,'last' );
            beta0 = yzc2fit(fmax);           beta1 = yzc2fit(fmin) - beta0;   beta2 = -beta1;
            % beta0 = yldsCE(k1,fmax);         beta1 = yldsCE(k1,fmin) - beta0;   beta2 = -beta1;
            beta3 = beta2;                   tau1  = 1;                         tau2  = tau1;
            
            % Fit NS/S models
            [yzcfitted,params,error] = fit_NS_S(yzc2fit,tnrs,params,[beta0 beta1 beta2 beta3 tau1 tau2]);
            yldszc(k1,fltry) = yzcfitted*100;                   % in percentages
            rmse(k1,1) = error*100;
            rmse(k1,2) = sqrt(mean((data_zcus(k1,[false fltry])-yzc2fit'*100).^2));     % zc2fit vs GSW
            rmse(k1,3) = sqrt(mean((data_zcus(k1,[false fltry])-yldszc(k1,fltry)).^2)); % zcfitted vs GSW
            
            % Plot and compare
            plot(tnrs,yzc2fit*100,'b',tnrs,yldszc(k1,fltry),'r',tnrs,data_zcus(k1,[false fltry]),'m')
            title([LC '  ' datestr(settle(k1))])
            H(k1) = getframe(gcf);                              % imshow(H(2).cdata) for a frame
        end
    end
    ['RMSE for ' LC ': ' num2str(mean(rmse(:,1),'omitnan')) ', ' num2str(mean(rmse(:,2),'omitnan'))...
        ', ' num2str(mean(rmse(:,3),'omitnan'))]
    end
    
    % Save and append data
    name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrscll,' YR');
    if     k0 == 1; hdr_ZC  = construct_hdr(LC,'LCNOMGSW','N/A',name_ZC,tnrscll,' ',' ');
    elseif k0 == 2; hdr_ZC  = construct_hdr(LC,'LCNOMBFV','N/A',name_ZC,tnrscll,' ',' ');
    elseif k0 == 3; hdr_ZC  = construct_hdr(LC,'LCNOMIYC','N/A',name_ZC,tnrscll,' ',' ');
    end
    hdr_zcus  = [hdr_zcus; hdr_ZC];
    data_zcus = [data_zcus, yldszc];
toc
end

end

function [yldszc,params1model,rmse] = fit_NS_S(yzc2fit,tnrs,params0model,params1data)
% FIT_NS_S Return zero-coupon yields yldszc after fitting NS (if max(tnrs) <= 10Y)
% or NSS (if max(tnrs) > 10Y) model to yzc2fit taking params1data (of length 6) and,
% if available, params0model (of length 4 or 6) as initial values

options = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
if size(yzc2fit,1) ~= 1; yzc2fit = yzc2fit'; end            % ensure yzc2fit is a row vector
if isempty(params0model) || (length(params0model) == 4 && max(tnrs) > 10)
    init_vals = [];                                         % first iteration or change from NS to NSS
else                                                        % previous iteration was either NS or NSS
    init_vals = params0model;                               % use parameters from previous iteration
end                                                         % note: size(init_vals,2) = 4 or 6
vrmse = nan(size(init_vals,1)+1,1);                         % size(rmse,1) = number of initial values

% Fit NS or NSS model
if max(tnrs) <= 10                                          % fit NS model
    init_vals = [init_vals; params1data(1) params1data(2) params1data(3) params1data(5)];
    vparams   = nan(size(init_vals));                       % size(init_vals,2) = 4
    for j0 = 1:size(init_vals,1)                            % at least one, at most two times
        try                                                 % exagerate rmse if init_vals yield error
            [prms,~,res]  = lsqcurvefit(@y_NS,init_vals(j0,:),tnrs,yzc2fit,lb,ub,options);
            vparams(j0,:) = prms;
            vrmse(j0)     = sqrt(mean(res.^2));
        catch
            vparams(j0,:) = init_vals(j0,:);
            vrmse(j0)     = 1e9;
        end
    end
    [rmse,idx]   = min(vrmse);                              % identify best fit
    params1model = vparams(idx,:);                          % choose best fit
    yldszc       = y_NS(params1model,tnrs);                 % extract yields
else                                                        % fit NSS model
    init_vals = [init_vals; params1data];                   % size(init_vals,2) = 6
    vparams   = nan(size(init_vals));
    for j0 = 1:size(init_vals,1)
        try
            [prms,~,res]  = lsqcurvefit(@y_NSS,init_vals(j0,:),tnrs,yzc2fit,lb,ub,options);
            vparams(j0,:) = prms;
            vrmse(j0)     = sqrt(mean(res.^2));
        catch
            vparams(j0,:) = init_vals(j0,:);
            vrmse(j0)     = 1e9;
        end
    end
    [rmse,idx]   = min(vrmse);
    params1model = vparams(idx,:);
    yldszc       = y_NSS(params1model,tnrs);
end
end

%% Save the YC of a country
% varnames = strcat(tnrscll,'Y')';
% dates = datetime(dataset(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
% TTcty = array2timetable(yldsCE,'RowTimes',dates,'VariableNames',varnames);
% TTcty = rmmissing(TTcty);
% writetimetable(TTcty,'TTcty.xlsx')                            % change path to folder to save table