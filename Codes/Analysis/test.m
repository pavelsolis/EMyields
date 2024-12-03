%% Compare pricing factors vs principal components
k0 = 7;
[~,z1] = pca(S(k0).ds_blncd(2:end,2:end));
z1 = [S(k0).ds_blncd(2:end,1) z1(:,1:3)];
subplot(3,1,1)
plot(S(k0).d_xs(2:end,1),S(k0).d_xs(2:end,2),z1(:,1),z1(:,2)) % PC1
subplot(3,1,2)
plot(S(k0).d_xs(2:end,1),S(k0).d_xs(2:end,3),z1(:,1),z1(:,3)) % PC2
subplot(3,1,3)
plot(S(k0).d_xs(2:end,1),S(k0).d_xs(2:end,4),z1(:,1),z1(:,4)) % PC3

%% Compare common factors in AE and EM
TT_gbl = read_global_idxs();

TTaux = cntrstimetable(S,currAE,'dn_blncd');    % 10Y
[~,PCae] = pca(TTaux{:,:},'NumComponents',1);
PCae = [datenum(TTaux.Time) PCae];

TTaux = cntrstimetable(S,currEM,'dn_blncd');    % 10Y
[~,PCem] = pca(TTaux{:,:},'NumComponents',1);
PCem = [datenum(TTaux.Time) PCem];

yyaxis left
plot(PCae(:,1),PCae(:,2),PCem(:,1),PCem(:,2))
yyaxis right
plot(datenum(TT_gbl.Time(TT_gbl.Time > datetime('1-Jan-2000'))),...
    TT_gbl.globalip(TT_gbl.Time > datetime('1-Jan-2000')))
datetick('x','yy')

%%
fldname = {'dn_blncd','d_yP','d_tp','dc_blncd','mn_blncd','bsl_yP','bsl_tp','mc_blncd'};
k1 = 1;
TT3m = cntrstimetable(S,currEM,fldname{k1},0.25);
TT6m = cntrstimetable(S,currEM,fldname{k1},0.5);
TT12m = cntrstimetable(S,currEM,fldname{k1},1);
TT24m = cntrstimetable(S,currEM,fldname{k1},2);
TT60m = cntrstimetable(S,currEM,fldname{k1},5);
TT120m = cntrstimetable(S,currEM,fldname{k1},10);

TTaux = synchronize(TT3m,TT6m,'intersection');
TTaux = synchronize(TTaux,TT12m,'intersection');
TTaux = synchronize(TTaux,TT24m,'intersection');
TTaux = synchronize(TTaux,TT60m,'intersection');
TTaux = synchronize(TTaux,TT120m,'intersection');
TTaux2 = rmmissing(TTaux);


%%
aedata = cell2table(fitrprtmy);


clear input
input.tableRowLabels = aedata{2:31,1}';
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';

input.tableColLabels = aedata{1,[2 3 4 5 8 10]};
filename   = fullfile('..','..','Docs','Tables','modelfit');
input.data = aedata(1:31,[2 3 4 5 8 10]);
input.tableCaption = 'Model Fit';
input.tableLabel = 'modelfit';
input.texName = filename;
latexTable(input);

%% SE for parameters
fname = {'mn_blncd','ms_blncd','bsl_pr'};
theta_se = nan(38,ncntrs);
for k0 = 1:ncntrs
    if ismember(S(k0).iso,currAE); k1 = 1; else; k1 = 2; end
    fltrsn = ismember(S(k0).(fname{k1})(1,:),matsout);                         % same maturities as in matsout
    yldsyn = S(k0).(fname{k1})(2:end,fltrsn);                                  % yields in decimals
    nobs = size(yldsyn,1); 
    Vasy = S(k0).(fname{3}).V1;
    theta_se(:,k0) = sqrt(diag(Vasy/nobs));
end


%% Hessian
% fminsearch uses the Nelder-Mead simplex (direct search) method, it is a simplex-based solver suggested
% for nonsmooth objective functions
% fminunc assumes your problem is differentiable
% if function is not differentiable, a genetic algorithm (global search or patternsearch) is required
% fminunc would almost certainly be faster and more reliable than fminsearch
% fminunc returns an estimated Hessian matrix at the solution. 
% If your objective function does not include a gradient, use 'Algorithm' = 'quasi-newton'
% In fminunc, the Hessian is only used by the trust-region algorithm
% The Quasi-Newton Algorithm computes the estimate by finite differences, so the estimate is generally accurate.
% HessUpdate is a method for choosing the search direction in the Quasi-Newton algorithm, 'bfgs' is the default
% fminunc can have trouble with minimizing a simulation or differential equation, in which case you might 
% need to take bigger finite difference steps (set DiffMinChange to 1e-3 or so)

%  Search methods that use only function evaluations (e.g., the simplex search of Nelder and Mead) are 
% most suitable for problems that are not smooth or have a number of discontinuities. 
% Gradient methods are generally more efficient when the function to be minimized is continuous in its 
% first derivative. Higher order methods, such as Newton's method, are only really suitable when the 
% second-order information is readily and easily calculated, because calculation of second-order information, 
% using numerical differentiation, is computationally expensive. Quasi-Newton methods avoid this by 
% using the observed behavior of f(x) and ?f(x) to build up curvature information to make an approximation 
% to H using an appropriate updating technique. The BFGS formula is thought to be the most effective for 
% use in a general purpose method.

% the reciprocal condition number is a more accurate measure of singularity than the determinant
% If A is well conditioned, rcond(A) is near 1.0. If A is badly conditioned, rcond(A) is near 0. 
% When A is badly conditioned, a small change in b produces a very large change in the solution to x = A\b. 
% The system is sensitive to perturbations.
% When the initial guess is too good, the algorithm shows the warning, but still calculated the correct result.
% Either choose a different initial guess or take into account that the first step has an inaccurate result.
% When you have concluded that your problem really merits a solution as is, and there is a good reason to need 
% to solve the problem DESPITE the numerical singularity, then you can use pinv. Thus, instead of A\b, 
% use pinv(A)*B. Pinv has some different properties than backslash. One reason why pinv is not used as a 
% default always is that it will be slower, sometimes significantly slower. Nobody wants slow code.



% https://www.mathworks.com/matlabcentral/answers/...
% 40375-question-on-optimization-problem-and-fminsearch-fminunc-lsqnonlin
% https://stackoverflow.com/questions/24360774/matlab-fminsearch-hessians
% https://www.mathworks.com/matlabcentral/answers/90374-fminsearch-finds-local-minimum-when-fminunc-does-not
% https://www.mathworks.com/matlabcentral/answers/330290-warning-matrix-is-close-to-singular-or-badly-scaled

% https://www.mathworks.com/help/optim/ug/optimization-decision-table.html
% https://www.mathworks.com/help/optim/ug/hessian.html#bsapedg
% https://www.mathworks.com/help/optim/ug/fminunc.html
% https://www.mathworks.com/help/optim/ug/unconstrained-nonlinear-optimization-algorithms.html#f171

% https://www.mathworks.com/help/matlab/ref/rcond.html