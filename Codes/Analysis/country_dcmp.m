clrplt = [0.06, 0.5, 0.95
        0.7, 0.075, 0.36
        0.553, 0.353, 0.714
        0.08, 0.9, 0.45
        0, 0.77, 0.96];

figdir  = 'Estimation'; formats = {'eps','pdf','png'}; figsave = false;
fldname = {'bsl_yP','bsl_tp','bsl_cr'};         % daily data: {'d_yP','d_tp','dc_blncd'};
figure
colororder(clrplt)
k0 = 7;
plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:)==10)*100,'LineWidth',2);
hold on
plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:)==10)*100,'-.','LineWidth',2);
crcts = S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:)==10);
crcts(crcts < 0) = 0;
plot(S(k0).(fldname{3})(2:end,1),crcts*100,'--','LineWidth',2);
title([S(k0).cty ': 10-Year Yield Decomposition'])
datetick('x','yy'); yline(0); ylabel('%');
lbl = {'Expected Short Rate','Term Premium','Credit Risk Compensation'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'MX_dcmp'; save_figure(figdir,figname,formats,figsave)

%%
figdir  = 'Estimation'; formats = {'eps','pdf'}; figsave = false;
    % EM: monthly
fldname = {'bsl_yP','bsl_tp','bsl_cr'};         % daily data: {'d_yP','d_tp','dc_blncd'};
figure
colororder(clrplt)
k1 = 0;
for k0 = [3,7]
    k1 = k1 + 1;
    subplot(2,1,k1)                             % 10Y
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:)==10)*100,'LineWidth',2);
    hold on
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:)==10)*100,'-.','LineWidth',2);
    crcts = S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:)==10);
    crcts(crcts < 0) = 0;
    plot(S(k0).(fldname{3})(2:end,1),crcts*100,'--','LineWidth',2);
    title(S(k0).cty)
    datetick('x','yy'); yline(0); ylabel('%');
end
lbl = {'Expected Short Rate','Term Premium','Credit Risk Compensation'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'HUF_MXN_dcmp'; save_figure(figdir,figname,formats,figsave)