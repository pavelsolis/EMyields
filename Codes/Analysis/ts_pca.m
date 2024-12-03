function [pcexplnd,pc1em,pc1ae,pc1res,r2TPyP] = ts_pca(S,currEM,currAE,kwyp,kwtp)
% TS_PCA Report results from principal component analysis on yields,
% components, and residuals of regressing EM components on US components;
% R2 of those regressions are also reported

% m-files called: syncdatasets, cntrstimetable
% Pavel Solís (pavel.solis@gmail.com), August 2020
%%
ncntrs = length(S);
nEMs   = length(currEM);

%% Percent of variation in yields explained by first 3 PCs

pcexplnd = cell(ncntrs+1,5);
pcexplnd(1,:) = {'' 'PC1' 'PC2' 'PC3' 'PC1-PC3'};
for k0 = 1:ncntrs
    pcexplnd{k0+1,1} = S(k0).iso;
    if ismember(S(k0).iso,currEM)
        fnameb = 'ms_blncd';
    else
        fnameb = 'mn_blncd';
    end
    yields = S(k0).(fnameb)(2:end,2:end);
    [~,~,~,~,explained] = pca(yields);
    pcexplnd{k0+1,2} = sum(explained(1));
    pcexplnd{k0+1,3} = sum(explained(2));
    pcexplnd{k0+1,4} = sum(explained(3));
    pcexplnd{k0+1,5} = sum(explained(1:3));         % percent explained by first 3 PCs using balanced panel
end

sprintf('Average pct explained by PC1, PC2, PC3 and sum for EM: %2.2f, %2.2f, %2.2f, %2.2f',...
        mean(cell2mat(pcexplnd(2:16,2))),   mean(cell2mat(pcexplnd(2:16,3))),...
        mean(cell2mat(pcexplnd(2:16,4))),   mean(cell2mat(pcexplnd(2:16,5))))
sprintf('Average pct explained by PC1, PC2, PC3 and sum for AE: %2.2f, %2.2f, %2.2f, %2.2f',...
        mean(cell2mat(pcexplnd(17:end,2))), mean(cell2mat(pcexplnd(17:end,3))),...
        mean(cell2mat(pcexplnd(17:end,4))), mean(cell2mat(pcexplnd(17:end,5))))

%% Common factors affecting YC components

% AE
fldname = {'dn_blncd','d_yP','d_tp','dc_blncd','mn_blncd','bsl_yP','bsl_tp','mc_blncd'};
pc1ae   = fldname';
for k1 = 1:length(fldname)
    TTaux = cntrstimetable(S,currAE,fldname{k1});
    [~,~,~,~,xplnAUX] = pca(TTaux{:,:});
    pc1ae{k1,2} = xplnAUX(1);
end

% EM
fldname = [fldname {'inf','sdprm','sdcyc'}];
pc1em   = fldname';
for k1 = 1:length(fldname)
    TTaux = cntrstimetable(S,currEM,fldname{k1});
    [~,~,~,~,xplnAUX] = pca(TTaux{:,:});
    pc1em{k1,2} = xplnAUX(1);
end

% hptrend = hpfilter(TTqtr{:,:},1600);
% [~,~,~,~,xplnHPTR] = pca(hptrend);                  % PC1: 93%
% 
% TTsvy = cntrstimetable(S,currEM,'scpi',10);
% z1 = rmmissing(TTsvy(:,[4 5 6 8 13 15]));
% z2 = rmmissing(TTsvy(TTsvy.Time <= datetime('31-Oct-2014') & TTsvy.Time ~= datetime('30-Sep-2004'),[3 11]));
% [~,~,~,~,xplnSCPI] = pca([z1{:,:} z2{:,:}]);        % PC1: 51%, PC2: 24%
% 
% TTrrt = cntrstimetable(S,currEM,'rrt');
% z1 = rmmissing(TTrrt(:,[4 5 6 8 13 15]));
% z2 = rmmissing(TTrrt(TTrrt.Time <= datetime('31-Oct-2014') & TTrrt.Time ~= datetime('30-Sep-2004'),[3 11]));
% [~,~,~,~,xplnRRT] = pca([z1{:,:} z2{7:end,:}]);    	% PC1: 62%, PC2: 16%

%% US and non-US common factors
k2 = 0;
r2TPyP = cell(ncntrs+1,6);
r2TPyP(1,:) = {'' 'yP1' 'yP10' 'TP1' 'TP10' 'yP10-USTP10'};
pc1res = cell(6,2);
pc1res(2:end,1) = {'yP1' 'yP10' 'TP1' 'TP10' 'yP10-USTP10'};
grp = 'AE';                                             % 'EM' or 'AE'
if strcmp(grp,'EM'); n1 = 1; nN = nEMs; else; n1 = nEMs+1; nN = ncntrs; end
dateskey = {'1-Jan-2008','1-Sep-2008'};                 % {'1-Jan-2008','1-Sep-2008'} all countries after GFC
datestrt = datenum(dateskey{1});                        % select countries based on date of first observation
datecmmn = datenum(dateskey{2});                        % select sample period for selected countries
for k0 = n1:nN
    k2 = k2 + 1;
    r2TPyP{k2+1,1} = S(k0).iso;
    fldname = {'bsl_yP','bsl_tp'};
    if datenum(S(k0).ms_dateb,'mmm-yyyy') <= datestrt
%     if ismember(S(k0).iso,{'BRL','HUF','KRW','MXN','MYR','PHP','PLN','THB'}) % EM TP < 0
%     if ismember(S(k0).iso,currEM(~contains(currEM,{'ILS','ZAR'})))           % EM w/ surveys
    
        [~,datayp,uskwypk0] = syncdatasets(S(k0).(fldname{1}),kwyp);
        [~,datatp,uskwtpk0] = syncdatasets(S(k0).(fldname{2}),kwtp);
       
        datayp10 = datayp(datayp(:,1) >= datecmmn,datayp(1,:) == 10);
        datayp01 = datayp(datayp(:,1) >= datecmmn,datayp(1,:) == 1);
        datatp10 = datatp(datatp(:,1) >= datecmmn,datatp(1,:) == 10);
        datatp01 = datatp(datatp(:,1) >= datecmmn,datatp(1,:) == 1);
        usyp10   = uskwypk0(uskwypk0(:,1) >= datecmmn,uskwypk0(1,:) == 10);
        usyp01   = uskwypk0(uskwypk0(:,1) >= datecmmn,uskwypk0(1,:) == 1);
        ustp10   = uskwtpk0(uskwtpk0(:,1) >= datecmmn,uskwtpk0(1,:) == 10);
        ustp01   = uskwtpk0(uskwtpk0(:,1) >= datecmmn,uskwtpk0(1,:) == 1);
        
        % Residuals and R2 for yP, TP and crossed
        mdlRSyp01 = fitlm(usyp01,datayp01);
        resyp01   = mdlRSyp01.Residuals.Raw;
        r2TPyP{k2+1,2} = mdlRSyp01.Rsquared.Ordinary;

        mdlRSyp10 = fitlm(usyp10,datayp10);
        resyp10   = mdlRSyp10.Residuals.Raw;
        r2TPyP{k2+1,3} = mdlRSyp10.Rsquared.Ordinary;

        mdlRStp01 = fitlm(ustp01,datatp01);
        restp01   = mdlRStp01.Residuals.Raw;
        r2TPyP{k2+1,4} = mdlRStp01.Rsquared.Ordinary;

        mdlRStp10 = fitlm(ustp10,datatp10);
        restp10   = mdlRStp10.Residuals.Raw;
        r2TPyP{k2+1,5} = mdlRStp10.Rsquared.Ordinary;
        
        mdlRSyptp10 = fitlm(ustp10,datayp10);
        resyptp10   = mdlRSyptp10.Residuals.Raw;
        r2TPyP{k2+1,6} = mdlRSyptp10.Rsquared.Ordinary;
        
        % Construct panel
        if k2 == 1
            ttyp01   = [nan 1; datayp(datayp(:,1) >= datecmmn,1) resyp01];
            ttyp10   = [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyp10];
            tttp01   = [nan 1; datatp(datatp(:,1) >= datecmmn,1) restp01];
            tttp10   = [nan 10;datatp(datatp(:,1) >= datecmmn,1) restp10];
            ttyptp10 = [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyptp10];
        else
            ttyp01 = syncdatasets(ttyp01,...
                [nan 1; datayp(datayp(:,1) >= datecmmn,1) resyp01],'union');
            ttyp10 = syncdatasets(ttyp10,...
                [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyp10],'union');
            tttp01 = syncdatasets(tttp01,...
                [nan 1; datatp(datatp(:,1) >= datecmmn,1) restp01],'union');
            tttp10 = syncdatasets(tttp10,...
                [nan 10;datatp(datatp(:,1) >= datecmmn,1) restp10],'union');
            ttyptp10 = syncdatasets(ttyptp10,...
                [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyptp10],'union');
        end
    end
end

fltrbln = find(any(isnan(ttyp01),2),1,'last') + 1;                  % first date w/ balanced panel
ttyp01  = ttyp01(fltrbln:end,:);                                    % no headers, sample w/ no NaNs
[~,~,~,~,explndyp01] = pca(ttyp01(ttyp01(:,1) >= datecmmn,2:end));  % factors after common date

fltrbln = find(any(isnan(ttyp10),2),1,'last') + 1;
ttyp10  = ttyp10(fltrbln:end,:);
[~,~,~,~,explndyp10] = pca(ttyp10(ttyp10(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp01),2),1,'last') + 1;
tttp01  = tttp01(fltrbln:end,:);
[~,~,~,~,explndtp01] = pca(tttp01(tttp01(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp10),2),1,'last') + 1;
tttp10  = tttp10(fltrbln:end,:);
[~,~,~,~,explndtp10] = pca(tttp10(tttp10(:,1) >= datecmmn,2:end));


fltrbln   = find(any(isnan(ttyptp10),2),1,'last') + 1;
ttyptp10  = ttyptp10(fltrbln:end,:);
[~,~,~,~,explndyptp10] = pca(ttyptp10(ttyptp10(:,1) >= datecmmn,2:end));


pc1res(1,:)     = {'' [num2str(k2) '-' datestr(datecmmn,'mm/yy')]}; % #countries included plus start date
pc1res(2:end,2) = {explndyp01(1); explndyp10(1); explndtp01(1); explndtp10(1); explndyptp10(1)}; % PC1 only