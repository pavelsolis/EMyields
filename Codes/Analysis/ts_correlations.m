function [corrTPem,corrTPae,corrBRP,corrTPyP] = ts_correlations(S,currEM,currAE,kwtp,vix)
% TS_CORRELATIONS Report correlations and p-values of estimated TP with other
% variables (LC credit spread, inflation, EPU index, US term premium, VIX),
% and correlations of yield curve components (yP, TP) with emprical measures

% m-files called: syncdatasets
% Pavel Solís (pavel.solis@gmail.com), July 2020
%%
ncntrs = length(S);
nEMs   = length(currEM);
nAEs   = length(currAE);
ustp10 = [kwtp(:,1) kwtp(:,kwtp(1,:) == 10)];

%% TP correlations: LCCS, INF, EPU, USTP, VIX
    % EMs
corrTPem = cell(nEMs+1,13); corrBRP = cell(nEMs+1,13);
corrTPem(1,:) = {'' 'LCCS' 'pval' 'INF' 'pval' 'EPU' 'pval','EPULCCS' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
corrBRP(1,:)  = {'' 'LCCS' 'pval' 'INF' 'pval' 'EPU' 'pval','EPULCCS' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
hdrfk = [nan 10];
for k0 = 1:nEMs
    corrTPem{k0+1,1} = S(k0).iso; corrBRP{k0+1,1} = S(k0).iso;
    fldname = {'bsl_tp','mc_blncd','inf','epu','brp'};
    fltr1   = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2   = find(S(k0).(fldname{2})(1,:) == 10);
    fltr5   = find(S(k0).(fldname{5})(1,:) == 10);
    datatp  = S(k0).(fldname{1})(:,[1 fltr1]);
    databrp = S(k0).(fldname{5})(:,[1 fltr5]);
    
    % LCCS
    mrgd = syncdatasets(datatp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,2:3) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrBRP(k0+1,2:3) = {correl,round(pval,4)};
    
    % INF
    datacr = [hdrfk; S(k0).(fldname{3})];
    mrgd   = syncdatasets(datatp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,4:5) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,4:5) = {correl,round(pval,4)};
    
    % EPU
    if ~isempty(S(k0).epu)
        datacr = [hdrfk; S(k0).(fldname{4})];
        mrgd   = syncdatasets(datatp,datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
        corrTPem(k0+1,6:7) = {correl,round(pval,4)};
        
        mrgd = syncdatasets(S(k0).(fldname{2})(:,[1 fltr2]),datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
        corrTPem(k0+1,8:9) = {correl,round(pval,4)};
        
        mrgd = syncdatasets(databrp,datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
        corrBRP(k0+1,6:7) = {correl,round(pval,4)};
    end
    
    % USTP
    mrgd = syncdatasets(datatp,ustp10);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,10:11) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,ustp10);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,10:11) = {correl,round(pval,4)};
    
    % VIX
    datacr = [hdrfk; vix];
    mrgd   = syncdatasets(datatp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,12:13) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,12:13) = {correl,round(pval,4)};
end

    % AEs
corrTPae = cell(nAEs+1,7);
corrTPae(1,:) = {'' 'CIPdev' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
for k0 = nEMs+1:ncntrs
    corrTPae{k0-14,1} = S(k0).iso;
    fldname = {'mny_tp','mc_blncd'};
    fltr1   = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2   = find(S(k0).(fldname{2})(1,:) == 10);
    datatp  = S(k0).(fldname{1})(:,[1 fltr1]);
    
    % CIP deviations
    mrgd = syncdatasets(datatp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,2:3) = {correl,round(pval,4)};
    
    % USTP
    mrgd = syncdatasets(datatp,ustp10);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,4:5) = {correl,round(pval,4)};
    
    % VIX
    mrgd = syncdatasets(datatp,[nan 10; vix]);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,6:7) = {correl,round(pval,4)};
end

% Report averages
sprintf('Average correlation of EMTP w/ LCCS, INF, USTP, Vix: %1.4f, %1.4f, %1.4f, %1.4f',...
    mean(cell2mat(corrTPem(2:end,2))),mean(cell2mat(corrTPem(2:end,4))),...
    mean(cell2mat(corrTPem(2:end,10))),mean(cell2mat(corrTPem(2:end,12))))
sprintf('Average correlation of AETP w/ USTP, Vix: %1.4f, %1.4f',...
    mean(cell2mat(corrTPae(2:end,4))),mean(cell2mat(corrTPae(2:end,6))))

%% Correlations of YC components with alternative measures
corrTPyP = cell(nEMs+1,5);
corrTPyP(1,:) = {'' 'TP-Slope' 'Res-Slope' 'TP-Res' 'yP-2Y'};
for k0 = 1:nEMs
    corrTPyP{k0+1,1} = S(k0).iso;
    fldname = {'bsl_tp','bsl_yP','ms_blncd'};
    [~,datatps,datayld] = syncdatasets(S(k0).(fldname{1}),S(k0).(fldname{3}));
    [~,datayp] = syncdatasets(S(k0).(fldname{2}),datatps);
    
    datatps = datatps(2:end,datatps(1,:) == 10);
    datayp  = datayp(2:end, datayp(1,:)  == 10);
    datas10 = datayld(2:end,datayld(1,:) == 10);
    datas02 = datayld(2:end,datayld(1,:) == 2);
    datas3M = datayld(2:end,datayld(1,:) == 0.25);
    slopes  = datas10 - datas3M;
    corrTPyP{k0+1,2} = corr(datatps,slopes);
    
    mdlRSs  = fitlm(datas3M,datas10);
    datarss = mdlRSs.Residuals.Raw;
    corrTPyP{k0+1,3} = corr(datarss,slopes);
    corrTPyP{k0+1,4} = corr(datarss,datatps);
    corrTPyP{k0+1,5} = corr(datayp,datas02);
end

sprintf('Average correlation of EMTP w/ slope and residual: %1.4f and %1.4f',...
    mean(cell2mat(corrTPyP(2:end,2))),mean(cell2mat(corrTPyP(2:end,4))))
sprintf('Average correlation of yP w/ 2Y: %1.4f',mean(cell2mat(corrTPyP(2:end,end))))