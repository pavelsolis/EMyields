%% Prepare Tables for Latex

tnrs2rprt   = [5 10];
labelcty    = ctrsNcods_rf(:,1);
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error

%% Correlation with US TP, LCCS and EPU index
labelcorrs  = {'US TP','LCCS','EPU'};
labeltnrs   = repmat({'5 YR','10 YR'},1,3);      % Used when presenting 5YR and 10YR together
idx         = find(ismember(ctrsNcods_rf(:,1),ctrsEPU));

aux1 = corr_tpus_rf(:,tnrs2rprt);
aux2 = corr_tpcs_rf(:,tnrs2rprt);
aux3 = nan(size(aux2));
aux3(idx,:) = corr_tpepu_rf(:,tnrs2rprt);
corrs5n10   = [aux1 aux2 aux3];

clear input
input.tableRowLabels = labelcty;
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';

input.tableColLabels = labeltnrs;
filename   = fullfile('..','..','Docs','Tables','rp_correl_5n10yr');
input.data = corrs5n10;
input.tableCaption = 'Correlations of EM Term Premia.';
input.tableLabel = 'Correls5n10yr';
input.texName = filename;
latexTable(input);

input.tableColLabels = labelcorrs;
filename   = fullfile('..','..','Docs','Tables','rp_correl_5yr');
input.data = corrs5n10(:,1:2:end);
input.tableCaption = 'Correlations of 5-Year Term Premia.';
input.tableLabel = 'Correls5yr';
input.texName = filename;
latexTable(input);

filename   = fullfile('..','..','Docs','Tables','rp_correl_10yr');
input.data = corrs5n10(:,2:2:end);
input.tableCaption = 'Correlations of 10-Year Term Premia.';
input.tableLabel = 'Correls10yr';
input.texName = filename;
latexTable(input);

%% Common Factors
filename     = fullfile('..','..','Docs','Tables','rp_cmnfctrs_v0'); %Remove '_v0' when update latexTable
date_min = datestr(max(date_first_obs(dataset_mth_rf)),'mmm-yy');
labelcol = repmat({'5 YR','10 YR'},1,2);
labelrow = {['(15) ' date_min],'(8)  Jul-05','(4)  Latam','(5)  Asia','(4)  Europe'}; 
% Follow same order as in rp_common_factors.m

clear input
tpdir  = [squeeze(pcXdates_rf(1,tnrs2rprt,:))'; squeeze(pcXregion_rf(1,tnrs2rprt,:))'];
tpoth  = [squeeze(pcXdates_rf(2,tnrs2rprt,:))'; squeeze(pcXregion_rf(2,tnrs2rprt,:))'];
input.data = [tpdir tpoth];
input.tableColLabels = labelcol;
input.tableRowLabels = labelrow;
input.dataFormat = {'%.2f'};
input.tableCaption = 'Percent of Total Variance Explained by First 3 PCs.';
input.tableLabel = 'CmnFctrs';
input.fontSize = 'footnotesize';
input.texName = filename;
latexTable(input);
% Shared name for columns
% cmnfac = table(tpdir,tpoth,'VariableNames',{'TP','Orthogonal'},'RowNames',rowlbl);


%%  Output Tables from Panel Regressions

clear input
input.fontSize = 'tiny';

for k = 1:numel(tnrs2rprt)
    input.data = tbl(:,:,k);
    filename = fullfile('..','..','Docs','Tables',['rp_pnlreg_' num2str(tnrs2rprt(k)) 'yr_v0']);
    input.texName = filename;
    input.tableCaption = ['Panel Regression: ' num2str(tnrs2rprt(k)) '-Year TP.'];
    input.tableLabel = ['Panel' num2str(tnrs2rprt(k)) 'yr'];
    latexTable(input);
%     matrix2latex(tbl(:,:,k),filename,'alignment','c','size','tiny');
end

%% Decomposition of LC Yield Curves: Average and Standard Deviation

rfmean = []; rfstd  = []; csmean = []; csstd  = [];
for l = 1:size(rpcs,2)
    rfm = mean(rpcs(l).dat1);
    rfd  = std(rpcs(l).dat1);
    csm = mean(rpcs(l).dat3);
    csd  = std(rpcs(l).dat3);
    rfmean = [rfmean;rfm]; rfstd  = [rfstd;rfd];
    csmean = [csmean;csm]; csstd  = [csstd;csd];
end
dcmp_cs  = [rfmean rfstd csmean csstd];         % RF & CS, includes 5YR and 10YR
dcmp_cs5 = dcmp_cs(:,1:2:end);                  % Only 5YR
% [dcmp_cs(:,1:2) dcmp_rf(2:end,3:4)]           % For verification, they should contain same information
dcmp_cs5 = dcmp_cs5(:,3:4);                     % Only CS, does not include BRL
dcmp_rf  = stats_rp_mat_rf([2:5 8:10],:,5)';
dcmp_rk  = stats_rp_mat_rk(2:3,:,5)';           % Does not include BRL
dcmp     = nan(15,11);
dcmp(1,3:9)   = dcmp_rf(1,:);                   % BRL
dcmp(2:end,:) = [dcmp_rk dcmp_rf(2:end,:) dcmp_cs5];
dcmp5         = dcmp(:,[9 1:4 7 8 5 6 10 11]);  % Reorder columns

dcmp_cs10 = dcmp_cs(:,2:2:end);                 % Only 10YR
dcmp_cs10 = dcmp_cs10(:,3:4);                   % Only CS, does not include BRL
dcmp_rf   = stats_rp_mat_rf([2:5 8:10],:,10)';
dcmp_rk   = stats_rp_mat_rk(2:3,:,10)';         % Does not include BRL
dcmp      = nan(15,11);
dcmp(1,3:9)   = dcmp_rf(1,:);                   % BRL
dcmp(2:end,:) = [dcmp_rk dcmp_rf(2:end,:) dcmp_cs10];
dcmp10        = dcmp(:,[9 1:4 7 8 5 6 10 11]);  % Reorder columns

clear input
input.tableRowLabels = labelcty;
labeldcmp   = {'N','Actual','Synthetic','Expected','TP','LCCS'};
input.tableColLabels = labeldcmp;
input.dataFormat = {'%d',1,'%.2f',5};
input.fontSize = 'tiny';

filename    = fullfile('..','..','Docs','Tables','rp_decomp5yr');
input.texName = filename;
input.tableCaption = 'LC Decomposition, 5-Year: Average Values.';
input.tableLabel = 'Decomp5yr';
input.data = dcmp5(:,[1 2:2:end]);              % Due to space, report means only
latexTable(input);

filename    = fullfile('..','..','Docs','Tables','rp_decomp10yr');
input.texName = filename;
input.tableCaption = 'LC Decomposition, 10-Year: Average Values.';
input.tableLabel = 'Decomp10yr';
input.data = dcmp10(:,[1 2:2:end]);              % Due to space, report means only
latexTable(input);

% % Average of means: 5YR and 10 YR 
% mean(dcmp5(:,[1 2:2:end]),'omitnan')
% mean(dcmp10(:,[1 2:2:end]),'omitnan')
% 
% % Average of standard deviations: 5YR and 10 YR 
% mean(dcmp5(:,[1 3:2:end]),'omitnan')
% mean(dcmp10(:,[1 3:2:end]),'omitnan')