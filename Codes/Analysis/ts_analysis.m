%% Term Structure Analysis: Nominal and Synthetic for EM and AE
% This code calls functions to estimate and analyze affine term structure models

% m-files called: daily2dymy, add_macroNsvys, append_svys2ylds, atsm_estimation, se_state, add_cr, 
% se_components, assess_fit, add_vars, ts_plots, ts_correlations, ts_pca, atsm_daily, construct_panel
% auxiliary: read_macrovars, read_kw
% Pavel Solís (pavel.solis@gmail.com), October 2021
% 
%% Load the data
clear
pathc = pwd;
%pathd = '/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB/August-2021';
pathd = 'C:\Users\G12284\Documents\Dropbox\Dissertation\Book-DB-Sync\Ch_Synt-DB\Codes-DB\August-2021';
cd(pathd)
load('struct_datady_S.mat')
load('struct_datady_cells.mat')
cd(pathc)

%% Process data
S = daily2dymy(S,dataset_daily,header_daily,true);
S = add_macroNsvys(S,currEM);
S = append_svys2ylds(S,currEM);

%% Estimate affine term structure model using fminsearch (fixed and free sgmS cases)
matsout = [0.25 0.5 1 2 5 10];                                      % report 3M-6M-1Y-2Y-5Y-10Y tenors

% Fixed sgmS case, runtime 5.5 hrs
datetime(now(),'ConvertFrom','datenum')
S = atsm_estimation(S,matsout,false);
datetime(now(),'ConvertFrom','datenum')

% % Free sgmS case, runtime 4.5 hrs
% % Not needed, but if done, better by country; if so, do it at the end and use: save('struct_datamy_S.mat','S','-append')
% S = atsm_estimation(S,matsout,true);
% datetime(now(),'ConvertFrom','datenum')

%% Estimate affine term structure model using fminunc (fixed sgmS case)
% sgmSfree = false;                                                   % consistent w/ baseline (fixed sgmS) case
% datetime(now(),'ConvertFrom','datenum')
% S = atsm_estimation(S,matsout,sgmSfree,false);                      % fminunc, runtime ~20 min
% datetime(now(),'ConvertFrom','datenum')

%% Baseline estimations
ncntrs  = length(S);
fldname = {'mssb_','mny_'};                                             % EM and AE
fldtype = {'yQ','yP','tp','pr'};
ntypes  = length(fldtype);
for k0  = 1:ncntrs
    for k1 = 1:ntypes
        if ismember(S(k0).iso,currEM)
            fldaux = fldname{1};                                    % synthetic yields + surveys + fixed sgmS
        else
            fldaux = fldname{2};                                    % nominal yields
        end
        S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldaux fldtype{k1}]);
    end
end

%% Post-estimation computations
seX = se_state(S,currEM);
S   = add_cr(S,matsout,currEM);
S   = asyvarhat(S,currEM);
S   = se_components(S,matsout,currEM);
[S,fitrprtmy] = assess_fit(S,currEM,currAE,false);
S   = add_vars(S,currEM);

%% Daily frequency estimation
S = daily2dymy(S,dataset_daily,header_daily,false);
[S,fitrprtdy] = atsm_daily(S,matsout,currEM,currAE,false);

%% Store/load results
cd(pathd)
save struct_datamy_S.mat S currAE currEM fitrprtdy fitrprtmy
% load('struct_datamy_S.mat')
% load('struct_datady_cells.mat')
cd(pathc)

%% Post-estimation analysis
[data_macro,hdr_macro] = read_macrovars(S);                 % macro and policy rates
vix = data_macro(:,ismember(hdr_macro(:,2),{'type','VIX'}));
[TT_kw,kwtp,kwyp] = read_kw(matsout);

ts_plots(S,currEM,currAE,kwtp,vix,true);
[corrTPem,corrTPae,corrBRP,corrTPyP] = ts_correlations(S,currEM,currAE,kwtp,vix);
[pcexplnd,pc1em,pc1ae,pc1res,r2TPyP] = ts_pca(S,currEM,currAE,kwyp,kwtp);

cd(pathd)
save struct_datamy_S.mat S currAE currEM fitrprtdy fitrprtmy corrTPem corrTPae ...
corrTPyP pcexplnd pc1em pc1ae pc1res r2TPyP
cd(pathc)

%% Construct panel dataset
datetime(now(),'ConvertFrom','datenum')
TT = construct_panel(S,matsout,currEM,currAE);
datetime(now(),'ConvertFrom','datenum')