%% Read data
TT_rr = read_spf();
[TTtips,THtips] = read_tips();

%% Synchronize and clean data
rr1y  = synchronize(TT_rr(:,1),TTtips(:,1),'intersection');
rr5y  = synchronize(TT_rr(:,2),TTtips(:,2),'intersection');
rr10y = synchronize(TT_rr(:,3),TTtips(:,3),'intersection');

rr1y  = rmmissing(rr1y);
rr5y  = rmmissing(rr5y);
rr10y = rmmissing(rr10y);

%% Figures
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;

figure
plot(rr1y.Time, [rr1y.(1)  rr1y.(2)])
legend({'SPF','TIPS'})
figname = 'spf_tips_1y'; save_figure(figdir,figname,formats,figsave)
figure
plot(rr5y.Time, [rr5y.(1)  rr5y.(2)])
legend({'SPF','TIPS'})
figname = 'spf_tips_5y'; save_figure(figdir,figname,formats,figsave)
figure
plot(rr10y.Time,[rr10y.(1) rr10y.(2)])
legend({'SPF','TIPS'})
figname = 'spf_tips_10y'; save_figure(figdir,figname,formats,figsave)

%% Summary statistics
% 1Y
corr(rr1y.(1),  rr1y.(2))
mean([rr1y.(1)  rr1y.(2)])
std([rr1y.(1)  rr1y.(2)])

% 5Y
corr(rr5y.(1),  rr5y.(2))
mean([rr5y.(1)  rr5y.(2)])
std([rr5y.(1)  rr5y.(2)])

% 10Y
corr(rr10y.(1), rr10y.(2))
mean([rr10y.(1) rr10y.(2)])
std([rr10y.(1) rr10y.(2)])