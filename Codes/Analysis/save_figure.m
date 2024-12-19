function save_figure(subfolder,figname,formats,saveit)
% SAVE_FIGURE Save current figure in Figures->subfolder with different formats
%	subfolder: name of subfolder under the Figures folder 
%	figname: string with name with which the figure will be saved
%   formats: cell array with formats in which the figure will be saved
%	saveit: true for actually saving the figure (avoids commenting the line calling the function)

% Pavel Solís (pavel.solis@gmail.com)
%%
if saveit == 1
    figname = fullfile('..','..','Docs','Figures',subfolder,figname);
    if any(ismember(formats,{'eps'})); saveas(gcf,figname,'epsc'); end
    if any(ismember(formats,{'pdf'})); saveas(gcf,figname,'pdf'); end
    if any(ismember(formats,{'fig'})); saveas(gcf,figname,'fig'); end
    close
end
 