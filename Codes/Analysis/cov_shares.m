ncntrs  = length(S);
nEMs = 15;
nAEs = ncntrs - nEMs;
tnr = 10;

for k = 1:ncntrs
    % Nominal
    cols = S(k).nomblncd(1,:) == tnr; cols(1) = 1;
    yieldsnom = S(k).nomblncd(2:end,cols);
    dates     = datetime(yieldsnom(:,1),'ConvertFrom','datenum');
    tt        = array2timetable(yieldsnom(:,2)*100,'RowTimes',dates);
    if k == 1
        tt_yldsnom = tt;
    else
        tt_yldsnom = synchronize(tt_yldsnom,tt);
    end
    
    % Synthetic
    cols = S(k).synblncd(1,:) == tnr; cols(1) = 1;
    yieldssyn = S(k).synblncd(2:end,cols);
    dates     = datetime(yieldssyn(:,1),'ConvertFrom','datenum');
    tt        = array2timetable(yieldssyn(:,2)*100,'RowTimes',dates);
    if k == 1
        tt_yldssyn = tt;
    else
        tt_yldssyn = synchronize(tt_yldssyn,tt);
    end
    
    % Expected short rate
    cols = S(k).synyldsP(1,:) == tnr; cols(1) = 1;
    yieldsP   = S(k).synyldsP(2:end,cols);
    dates     = datetime(yieldsP(:,1),'ConvertFrom','datenum');
    tt        = array2timetable(yieldsP(:,2)*100,'RowTimes',dates);
    if k == 1
        tt_yldsexp = tt;
    else
        tt_yldsexp = synchronize(tt_yldsexp,tt);
    end
    
    % Term premia
    cols = S(k).syntp(1,:) == tnr; cols(1) = 1;
    tpsyn     = S(k).syntp(3:end,cols);
    dates     = datetime(tpsyn(:,1),'ConvertFrom','datenum');
    tt        = array2timetable(tpsyn(:,2),'RowTimes',dates);
    if k == 1
        tt_tpsyn = tt;
    else
        tt_tpsyn = synchronize(tt_tpsyn,tt);
    end
    
    % CIP deviations
    cols = S(k).cipdev(1,:) == tnr; cols(1) = 1;
    cipd      = S(k).cipdev(2:end,cols);
    dates     = datetime(cipd(:,1),'ConvertFrom','datenum');
    tt        = array2timetable(cipd(:,2),'RowTimes',dates);
    if k == 1
        tt_cipd = tt;
    else
        tt_cipd = synchronize(tt_cipd,tt);
    end
end

%% TP: EMs
covtpEMnom = nan(nEMs,nEMs);
for cls = 1:nEMs
    for rws = cls:nEMs
        if cls == rws
            ytp = synchronize(tt_yldsnom(:,cls),tt_tpsyn(:,cls));
            ytp = rmmissing(ytp);               % need same range for tps and yls to ensure ratio < 1
            ytp = table2array(timetable2table(ytp,'ConvertRowTimes',false));
            figure
            plot(ytp)
            covytp = cov(ytp);
            covtpEMnom(rws,cls) = covytp(2,1)/covytp(1,1);
        else
            tps = synchronize(tt_tpsyn(:,cls),tt_tpsyn(:,rws));
            yls = synchronize(tt_yldsnom(:,cls),tt_yldsnom(:,rws));
            tpsyls = synchronize(tps,yls);
            tpsyls = rmmissing(tpsyls);         % need same range for tps and yls to ensure ratio < 1
            tpsyls = table2array(timetable2table(tpsyls,'ConvertRowTimes',false));
            covtps = cov(tpsyls(:,[1 2]));
            covyls = cov(tpsyls(:,[3 4]));
            covtpEMnom(rws,cls) = covtps(2,1)/covyls(2,1);
        end
    end
end

%% TP: AEs
covtpAEnom = nan(nAEs,nAEs);
for cls = nEMs+1:ncntrs
    for rws = cls:ncntrs
        if cls == rws
            ytp = synchronize(tt_yldsnom(:,cls),tt_tpsyn(:,cls));
            ytp = rmmissing(ytp);               % need same range for tps and yls to ensure ratio < 1
            ytp = table2array(timetable2table(ytp,'ConvertRowTimes',false));
            covytp = cov(ytp);
            covtpAEnom(rws-nEMs,cls-nEMs) = covytp(2,1)/covytp(1,1);
        else
            tps = synchronize(tt_tpsyn(:,cls),tt_tpsyn(:,rws));
            yls = synchronize(tt_yldsnom(:,cls),tt_yldsnom(:,rws));
            tpsyls = synchronize(tps,yls);
            tpsyls = rmmissing(tpsyls);         % need same range for tps and yls to ensure ratio < 1
            tpsyls = table2array(timetable2table(tpsyls,'ConvertRowTimes',false));
            covtps = cov(tpsyls(:,[1 2]));
            covyls = cov(tpsyls(:,[3 4]));
            covtpAEnom(rws-nEMs,cls-nEMs) = covtps(2,1)/covyls(2,1);
        end
    end
end


%% CIP: EMs
covcipEM = nan(nEMs,nEMs);
for cls = 1:nEMs
    for rws = cls:nEMs
        if cls == rws
            ytp = synchronize(tt_yldsnom(:,cls),tt_cipd(:,cls));
            ytp = rmmissing(ytp);               % need same range for tps and yls to ensure ratio < 1
            ytp = table2array(timetable2table(ytp,'ConvertRowTimes',false));
            figure
            plot(ytp)
            covytp = cov(ytp);
            covcipEM(rws,cls) = covytp(2,1)/covytp(1,1);
        else
            tps = synchronize(tt_cipd(:,cls),tt_cipd(:,rws));
            yls = synchronize(tt_yldsnom(:,cls),tt_yldsnom(:,rws));
            tpsyls = synchronize(tps,yls);
            tpsyls = rmmissing(tpsyls);         % need same range for tps and yls to ensure ratio < 1
            tpsyls = table2array(timetable2table(tpsyls,'ConvertRowTimes',false));
            covtps = cov(tpsyls(:,[1 2]));
            covyls = cov(tpsyls(:,[3 4]));
            covcipEM(rws,cls) = covtps(2,1)/covyls(2,1);
        end
    end
end


%% TP against Synthetic Yields: EMs
covtpEMsyn = nan(nEMs,nEMs);
for cls = 1:nEMs
    for rws = cls:nEMs
        if cls == rws
            ytp = synchronize(tt_yldssyn(:,cls),tt_tpsyn(:,cls));
            ytp = rmmissing(ytp);               % need same range for tps and yls to ensure ratio < 1
            ytp = table2array(timetable2table(ytp,'ConvertRowTimes',false));
            figure
            plot(ytp)
            covytp = cov(ytp);
            covtpEMsyn(rws,cls) = covytp(2,1)/covytp(1,1);
        else
            tps = synchronize(tt_tpsyn(:,cls),tt_tpsyn(:,rws));
            yls = synchronize(tt_yldssyn(:,cls),tt_yldssyn(:,rws));
            tpsyls = synchronize(tps,yls);
            tpsyls = rmmissing(tpsyls);         % need same range for tps and yls to ensure ratio < 1
            tpsyls = table2array(timetable2table(tpsyls,'ConvertRowTimes',false));
            covtps = cov(tpsyls(:,[1 2]));
            covyls = cov(tpsyls(:,[3 4]));
            covtpEMsyn(rws,cls) = covtps(2,1)/covyls(2,1);
        end
    end
end


%% Expected: EMs
covexpEM = nan(nEMs,nEMs);
for cls = 1:nEMs
    for rws = cls:nEMs
        if cls == rws
            ytp = synchronize(tt_yldsnom(:,cls),tt_yldsexp(:,cls));
            ytp = rmmissing(ytp);               % need same range for tps and yls to ensure ratio < 1
            ytp = table2array(timetable2table(ytp,'ConvertRowTimes',false));
            figure
            plot(ytp)
            covytp = cov(ytp);
            covexpEM(rws,cls) = covytp(2,1)/covytp(1,1);
        else
            tps = synchronize(tt_yldsexp(:,cls),tt_yldsexp(:,rws));
            yls = synchronize(tt_yldsnom(:,cls),tt_yldsnom(:,rws));
            tpsyls = synchronize(tps,yls);
            tpsyls = rmmissing(tpsyls);         % need same range for tps and yls to ensure ratio < 1
            tpsyls = table2array(timetable2table(tpsyls,'ConvertRowTimes',false));
            covtps = cov(tpsyls(:,[1 2]));
            covyls = cov(tpsyls(:,[3 4]));
            covexpEM(rws,cls) = covtps(2,1)/covyls(2,1);
        end
    end
end

%% Subset of EM countries for TP cov shares

idxrm = [1 3 4 7 8 12 13];  % remove: BRL, HUF, IDR, MXN, MYR, RUB, THB
covtpEMnomsub = covtpEMnom;
covtpEMnomsub(idxrm,:) = [];
covtpEMnomsub(:,idxrm) = [];

idxkp = ~ismember(1:nEMs,idxrm);
labelcty = {};
for k0 = 1:nEMs
    if idxkp(k0)
        labelcty = [labelcty S(k0).iso];
    end
end

clear input
input.tableColLabels = labelcty;
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.dataFormat = {'%.2f'};
input.fontSize = 'scriptsize';
filename   = fullfile('..','..','Docs','Tables','temp_covshares');
input.data = covtpEMnomsub;
input.tableCaption = 'Variance-Covariance of 10-Year Yields Explained by Term Premia';
input.tableLabel = 'temp_covshares';
input.texName = filename;
latexTable(input);



%%

% covAE = nan(nAEs,nAEs);
% for cls = nEMs+1:ncntrs
%     for rws = cls:ncntrs
%         if cls == rws
%             ytp = table2array(timetable2table(synchronize(tt_yldsnom(:,cls),tt_tpsyn(:,cls)),'ConvertRowTimes',false));
%             yls = table2array(timetable2table(tt_yldsnom(:,cls),'ConvertRowTimes',false));
%             covytp = cov(ytp,'omitrows');
%             varyls = var(yls,'omitnan');
%             covAE(rws-nEMs,cls-nEMs) = covytp(2,1)/varyls;
%         else
%             tps = table2array(timetable2table(synchronize(tt_tpsyn(:,cls),tt_tpsyn(:,rws)),'ConvertRowTimes',false));
%             yls = table2array(timetable2table(synchronize(tt_yldsnom(:,cls),tt_yldsnom(:,rws)),'ConvertRowTimes',false));
%             covtps = cov(tps,'omitrows');
%             covyls = cov(yls,'omitrows');
%             covAE(rws-nEMs,cls-nEMs) = covtps(2,1)/covyls(2,1);
%         end
%     end
% end

% covAE(1:nAEs+1:end) = nan;  % make diagonal elements of the matrix NaNs




%     cols = S(k).synyldsP(1,:) == tnr; cols(1) = 1;
%     yieldsP   = S(k).synyldsP(2:end,cols);


% for k = 1:ncntrs
%     yieldsnom = mean(S(k).nomblncd(2:end, S(k).nomblncd(1,:) == tnr)*100);
%     yieldssyn = mean(S(k).synblncd(2:end, S(k).synblncd(1,:) == tnr)*100);
%     yieldsP   = mean(S(k).synyldsP(2:end, S(k).synyldsP(1,:) == tnr)*100);
%     tpsyn     = mean(S(k).syntp(3:end, S(k).syntp(1,:) == tnr));
%     lccs      = mean(S(k).cipdev(2:end, S(k).cipdev(1,:) == tnr),'omitnan');
%     decomp(k,:) = [yieldsnom yieldssyn yieldsP tpsyn lccs];
% end
% AvgDecomp = [mean(decomp(1:15,:)); mean(decomp([16:19 23:25],:)); mean(decomp(20:22,:))];