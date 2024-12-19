%% Term Structure Analysis: Nominal and Synthetic for EM and AE
% Estimate and analyze affine term structure models

% m-files called: iso2names, daily2dymy, add_macroNsvys, append_svys2ylds, atsm_estimation, se_state, add_cr, 
%                 asyvarhat, se_components, assess_fit, add_vars, atsm_daily, ts_plots, construct_panel
% Pavel Solís (pavel.solis@gmail.com)
%% Load the data
clear
pathc = pwd;
pathd = fullfile(pathc,'..','..','Data','Analytic');
cd(pathd)
load('yc_data.mat')
cd(pathc)

%% Process data
S = cell2struct(iso2names(curncs)',{'cty','ccy','iso','imf'});
S = daily2dymy(S,dataset_daily,header_daily,true);
S = add_macroNsvys(S,currEM);                                               % generate figure A.2
S = append_svys2ylds(S,currEM);

%% Estimate affine term structure model (fixed and free sgmS cases)
matsout = [0.25 0.5 1 2 5 10];                                              % report 3M-6M-1Y-2Y-5Y-10Y tenors
S = atsm_estimation(S,matsout,false);                                       % fixed sgmS w/fminsearch case (runtime 5.5 hrs)
% S = atsm_estimation(S,matsout,true);                                      % free  sgmS w/fminsearch case (better by country)
% S = atsm_estimation(S,matsout,false,false);                               % fixed sgmS w/fminunc case (only for synthetic)

%% Baseline estimations
ncntrs  = length(S);
fldname = {'mssb_','mny_'};                                                 % EM and AE
fldtype = {'yQ','yP','tp','pr'};
ntypes  = length(fldtype);
for k0  = 1:ncntrs
    for k1 = 1:ntypes
        if ismember(S(k0).iso,currEM)
            fldaux = fldname{1};                                            % synthetic yields + surveys + fixed sgmS
        else
            fldaux = fldname{2};                                            % nominal yields
        end
        S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldaux fldtype{k1}]);
    end
end

%% Post-estimation computations
se_state(S,currEM);
S = add_cr(S,matsout,currEM);
S = asyvarhat(S,currEM);
S = se_components(S,matsout,currEM);
[S,fitrprtmy] = assess_fit(S,currEM,currAE,false);
S = add_vars(S,currEM);

%% Daily frequency estimation
S = daily2dymy(S,dataset_daily,header_daily,false);
[S,fitrprtdy] = atsm_daily(S,matsout,currEM,currAE,false);

%% Store results
cd(pathd)
save yc_decompositions.mat S cur* fitrprt*
cd(pathc)

%% Plot results
ts_plots(S,currEM,currAE,true);                                             % generate figures 1, A.1, B.1-B.4, C.1-C.3, E.1, E.2

%% Construct panel dataset
construct_panel(S,matsout,currEM,currAE);