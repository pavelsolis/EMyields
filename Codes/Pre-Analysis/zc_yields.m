function [data_zc,hdr_zc,fitrprt] = zc_yields(dataset,header,curncs,tfnss,tfplot,timeshift)
% ZC_YIELDS Return zero-coupon continuosly compounded (CC) local currency (LC)
% yield curves from BFV and IYC LC curves which report coupon-equivalent (CE)
% par and zero-coupon yields. IYC for BRL & ILS, BFV for all other countries
% Optional: fit Nelson-Siegel-Svensson model to yields
% Optional: shift time forward one day due to the time difference
%   data_zc: stores historical data
%   hdr_zc: stores headers (note: no title row, i.e. ready to be appended)
%   fitrprt: reports NSS fit (country, average RMSE in %, minutes to fit)

% m-files called: fltr4tickers, construct_hdr; y_NS, y_NSS
% Pavel Solís (pavel.solis@gmail.com)
%% Zero-coupon continuosly compounded yield curves for advanced and emerging economies
hdr_zc  = {};                                                   % no title row (ie. ready to be appended)
data_zc = dataset(:,1);
settle  = dataset(:,1);
tmax    = 10;
frqCE   = 2;                                                    % CE compounding frequency: 2 - semiannual
tnrsout = [0.25 0.5 1:10]';
tnrshdr = cellfun(@num2str,num2cell(tnrsout),'UniformOutput',false);
fitrprt = cell(numel(curncs),3);
for k0  = 1:numel(curncs)
    if tfnss; tic; end                                          % measure time if NSS fit
    LC  = curncs{k0};	tfbfv = true;
    [fltr,tnrscll] = fltr4tickers(LC,'LC','',header);
    
    % Determine whether BFV or IYC curve
    if ~isequal(length(unique(tnrscll)),length(tnrscll))     	% case of two curves, chose BFV
        fltr    = fltr & startsWith(header(:,3),{'C','P'});   	% BFV curves start w/ C or P
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    end
    if any(~startsWith(header(fltr,3),{'C','P'}))            	% case of only IYC curve (BRL, ILS)
        tfbfv = false;
    end
    tnrsnum = cellfun(@str2num,tnrscll);
    
    % Exclude tenors beyond tmax
    ftrue = find(fltr);                                         % ftrue, ttrue, tnrs* have same dimensions
    ttrue = tnrsnum <= tmax;                                   	% maximum tenor to include
    tnrsnum(~ttrue) = [];   tnrscll(~ttrue) = [];   ftrue(~ttrue) = [];
    fltr(:) = false;        fltr(ftrue)     = true;
    if (strcmp(LC,'HUF') && strcmp(tnrscll{end},'20'))          % in case tmax >= 20
        fltr(find(fltr,1,'last')) = false; %tnrscll(end) = [];
    end
    
    % Extract information and preallocate variables
    yldsCE = dataset(:,fltr)/100;                               % in decimals, needed for pyld2zero
    [ndates,ntnrs] = size(yldsCE);
    ydates = nan(ndates,ntnrs);    
    if tfnss                                                    % #zc yields will depend on whether NSS fit
        yldszc = nan(ndates,length(tnrsout));   rmse = nan(ndates,1);   params = [];
    else
        yldszc = nan(ndates,ntnrs);
    end
    
    % Convert CE yields into zero-coupon CC yields
    for k1 = 1:ndates
        fltry = ~isnan(yldsCE(k1,:));                           % tenors with observations
        if sum(fltry) > 0                                       % at least one observation
            % Tenors and maturities (based on settlement day)
            tnrsin = tnrsnum(fltry);                          	% define tenors
            ydates(k1,fltry) = datemnth(settle(k1),12*tnrsin); 	% define maturity dates in months
            
            % Yields treatment depending on whether BFV or IYC curve  (column vectors)
            if tfbfv == true                                  	% BFV par yields CE to zc yields CC
                try                                             % if error, use values from previous days
                    yzc2fit = pyld2zero(yldsCE(k1,fltry)',ydates(k1,fltry)',settle(k1),...
                        'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                catch
                    try                                         % eg. curncs{4} = 'IDR', k1 = 2292
                        yzc2fit = pyld2zero(yldsCE(k1-1,fltry)',ydates(k1,fltry)',settle(k1),...
                            'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    catch                                       % eg. curncs{4} = 'IDR', k1 = 2305
                        yzc2fit = pyld2zero(yldsCE(k1-2,fltry)',ydates(k1,fltry)',settle(k1),...
                            'InputCompounding',frqCE,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    end
                end
            else                                            	% IYC zc yields CE to zc yields CC
                yzc2fit = frqCE*log(1 + yldsCE(k1,fltry)'./frqCE);
            end
            
            % Save zero-coupon CC yields
            if tfnss
                % Initial values from the data
                beta0 = yzc2fit(end);       beta1 = yzc2fit(1) - beta0;     beta2 = -beta1;
                beta3 = beta2;             	tau1  = 1;                      tau2  = tau1;
                paramsdata = [beta0 beta1 beta2 beta3 tau1 tau2];

                % Fit NS/S models
                [yzcfitted,params,error] = fit_NS_S(yzc2fit,tnrsin,tnrsout,params,paramsdata);
                yldszc(k1,:) = yzcfitted*100;                       % in percentages
                rmse(k1)     = error*100;

                % Plot and compare
                if tfplot
                plot(tnrsin,yzc2fit*100,'b',tnrsout,yldszc(k1,:),'r',tnrsin,yldsCE(k1,fltry)*100,'mo')
                title([LC '  ' datestr(settle(k1))])
                H(k1) = getframe(gcf);                              % imshow(H(2).cdata) for a frame
                end
            else
                yldszc(k1,fltry) = yzc2fit'*100;                  	% in percentages
            end
        end
    end
    
    % Save and append data
    if tfnss                                                        % report fit if NSS
        secs2fit = toc;
        fitrprt{k0,1} = LC; fitrprt{k0,2} = mean(rmse,'omitnan'); fitrprt{k0,3} = secs2fit/60;
        name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrshdr,' YR');
        hdr_ZC  = construct_hdr(LC,'LCNOM','N/A',name_ZC,tnrshdr,' ',' ');
    else
        name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrscll,' YR');
        hdr_ZC  = construct_hdr(LC,'LCNOM','N/A',name_ZC,tnrscll,' ',' ');
    end
    hdr_zc  = [hdr_zc; hdr_ZC];
    data_zc = [data_zc, yldszc];
end

% Shift data forward one day due to time difference
if timeshift
    westhem = [true; ismember(hdr_zc(:,1),{'BRL','CAD','COP','MXN','PEN'})];% consider 1st column of dates
    data_zc(1:end-1,~westhem) = data_zc(2:end,~westhem);                    % shift non-WH nominal yields
end

end

function [yldszc,params1model,rmse] = fit_NS_S(yzc2fit,tnrsin,tnrsout,params0model,params1data)
% FIT_NS_S Return zero-coupon yields yldszc after fitting NS (if max(tnrs) <= 10Y)
% or NSS (if max(tnrs) > 10Y) model to yzc2fit taking params1data (of length 6) and,
% if available, params0model (of length 4 or 6) as initial values
%%
options = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
if size(yzc2fit,1) ~= 1; yzc2fit = yzc2fit'; end            % ensure yzc2fit is a row vector
if isempty(params0model) || (length(params0model) == 4 && max(tnrsin) > 10)
    init_vals = [];                                         % first iteration or change from NS to NSS
else                                                        % previous iteration was either NS or NSS
    init_vals = params0model;                               % use parameters from previous iteration
end                                                         % note: size(init_vals,2) = 4 or 6
vrmse = nan(size(init_vals,1)+1,1);                         % size(rmse,1) = number of initial values

% Fit NS or NSS model
if max(tnrsin) <= 10                                       	% fit NS model
    init_vals = [init_vals; params1data(1) params1data(2) params1data(3) params1data(5)];
    vparams   = nan(size(init_vals));                       % size(init_vals,2) = 4
    for j0 = 1:size(init_vals,1)                            % at least one, at most two times
        try                                                 % exagerate rmse if init_vals yield error
            [prms,~,res]  = lsqcurvefit(@y_NS,init_vals(j0,:),tnrsin,yzc2fit,lb,ub,options);
            vparams(j0,:) = prms;
            vrmse(j0)     = sqrt(mean(res.^2));
        catch
            vparams(j0,:) = init_vals(j0,:);
            vrmse(j0)     = 1e9;
        end
    end
    [rmse,idx]   = min(vrmse);                              % identify best fit
    params1model = vparams(idx,:);                          % choose best fit
    yldszc       = y_NS(params1model,tnrsout);             	% extract yields
else                                                        % fit NSS model
    init_vals = [init_vals; params1data];                   % size(init_vals,2) = 6
    vparams   = nan(size(init_vals));
    for j0 = 1:size(init_vals,1)
        try
            [prms,~,res]  = lsqcurvefit(@y_NSS,init_vals(j0,:),tnrsin,yzc2fit,lb,ub,options);
            vparams(j0,:) = prms;
            vrmse(j0)     = sqrt(mean(res.^2));
        catch
            vparams(j0,:) = init_vals(j0,:);
            vrmse(j0)     = 1e9;
        end
    end
    [rmse,idx]   = min(vrmse);
    params1model = vparams(idx,:);
    yldszc       = y_NSS(params1model,tnrsout);
end
if max(tnrsin) < max(tnrsout) - 1                           % extrapolating from max-1Y to max is allowed
    yldszc(tnrsout > max(tnrsin)) = nan;                    % don't extrapolate from more than 1Y to the max
end
end