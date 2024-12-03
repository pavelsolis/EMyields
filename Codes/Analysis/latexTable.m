function latex = latexTable(input)
% An easy to use function that generates a LaTeX table from a given MATLAB
% input struct containing numeric values. The LaTeX code is printed in the
% command window for quick copy&paste and given back as a cell array.
%
% Author:       Eli Duenisch
% Contributor:  Pascal E. Fortin
% Date:         April 20, 2016
% License:      This code is licensed using BSD 2 to maximize your freedom of using it :)
% ----------------------------------------------------------------------------------
%  Copyright (c) 2016, Eli Duenisch
%  All rights reserved.
%  
%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are met:
%  
%  * Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%  
%  * Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% ----------------------------------------------------------------------------------
%
% Input:
% input    struct containing your data and optional fields (details described below)
%
% Output:
% latex    cell array containing LaTex code
%
% Example and explanation of the input struct fields:
%
% % numeric values you want to tabulate:
% % this field has to be a matrix or MATLAB table datatype
% % missing values have to be NaN
% % in this example we use an array
% input.data = [1.12345 2.12345 3.12345; ...
%               4.12345 5.12345 6.12345; ...
%               7.12345 NaN 9.12345; ...
%               10.12345 11.12345 12.12345];
%
% % Optional fields (if not set default values will be used):
%
% % Set the position of the table in the LaTex document using h, t, p, b, H or !
% input.tablePositioning = 'h';
%
% % Set column labels (use empty string for no label):
% input.tableColLabels = {'col1','col2','col3'};
% % Set row labels (use empty string for no label):
% input.tableRowLabels = {'row1','row2','','row4'};
%
% % Switch transposing/pivoting your table:
% input.transposeTable = 0;
%
% % Determine whether input.dataFormat is applied column or row based:
% input.dataFormatMode = 'column'; % use 'column' or 'row'. if not set 'column' is used
%
% % Formatting-string to set the precision of the table values:
% % For using different formats in different rows use a cell array like
% % {myFormatString1,numberOfValues1,myFormatString2,numberOfValues2, ... }
% % where myFormatString_ are formatting-strings and numberOfValues_ are the
% % number of table columns or rows that the preceding formatting-string applies.
% % Please make sure the sum of numberOfValues_ matches the number of columns or
% % rows in input.tableData!
% %
% % input.dataFormat = {'%.3f'}; % uses three digit precision floating point for all data values
% input.dataFormat = {'%.3f',2,'%.1f',1}; % three digits precision for first two columns, one digit for the last
%
% % Define how NaN values in input.tableData should be printed in the LaTex table:
% input.dataNanString = '-';
%
% % Column alignment in Latex table ('l'=left-justified, 'c'=centered,'r'=right-justified):
% input.tableColumnAlignment = 'c';
%
% % Switch table borders on/off:
% input.tableBorders = 1;
%
% % Switch table booktabs on/off:
% input.booktabs = 1;
%
% % LaTex table caption:
% input.tableCaption = 'MyTableCaption';
%
% % LaTex table label:
% input.tableLabel = 'MyTableLabel';
%
% % Switch to generate a complete LaTex document or just a table:
% input.makeCompleteLatexDocument = 1;
%
% % Font size:
% input.fontSize = 'small';
%
% % Add horizontal lines:
% columns: row below which cmidrule will be added, start column, end column
% input.tableCmidrules = [4,2,6;7,1,6;9,2,6];
% 
% % Position caption at the top:
% input.captionPosition = 1;
% 
% % Notes below the table:
% input.tableNotes = 'Notes';
% input.notesFontSize = 'scriptsize';
% 
% % Long table:
% input.tableLong = 1;
% 
% % Long table:
% input.tableLandscape = 1;
% 
% % Save file:
% input.texName = 'MyTable';
%
% % % Now call the function to generate LaTex code:
% latex = latexTable(input);

%%%%%%%%%%%%%%%%%%%%%%%%%% Default settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These settings are used if the corresponding optional inputs are not given.
%
% Placement of the table in LaTex document
if isfield(input,'tablePlacement') && (length(input.tablePlacement)>0)
    input.tablePlacement = ['[',input.tablePlacement,']'];
else
    input.tablePlacement = '';
end
% Pivoting of the input data switched off per default:
if ~isfield(input,'transposeTable'),input.transposeTable = 0;end
% Default mode for applying input.tableDataFormat:
if ~isfield(input,'dataFormatMode'),input.dataFormatMode = 'column';end
% Sets the default display format of numeric values in the LaTeX table to '%.4f'
% (4 digits floating point precision).
if ~isfield(input,'dataFormat'),input.dataFormat = {'%.4f'};end
% Define what should happen with NaN values in input.tableData:
if ~isfield(input,'dataNanString'),input.dataNanString = '-';end
% Specify the alignment of the columns:
% 'l' for left-justified, 'c' for centered, 'r' for right-justified
if ~isfield(input,'tableColumnAlignment'),input.tableColumnAlignment = 'c';end
% Specify whether the table has borders:
% 0 for no borders, 1 for borders
if ~isfield(input,'tableBorders'),input.tableBorders = 0;end
% Specify whether the caption is at the top or at the bottom:
% 0 for bottom, 1 for top
if ~isfield(input,'captionPosition'),input.captionPosition = 0;end
% Specify whether it is a long table
% 0 for regular, 1 for long
if ~isfield(input,'tableLong'),input.tableLong = 0;end
% Specify whether the layout is landscape
% 0 for vertical, 1 for landscape
if ~isfield(input,'tableLandscape'),input.tableLandscape = 0;end
% Specify whether to use booktabs formatting or regular table formatting:
if ~isfield(input,'booktabs')
    input.booktabs = 1;
else
    if input.booktabs
        input.tableBorders = 0;
    end
end
% Other optional fields:
if ~isfield(input,'tableCaption'),input.tableCaption = 'MyTableCaption';end
if ~isfield(input,'tableLabel'),input.tableLabel = 'MyTableLabel';end
if ~isfield(input,'notesFontSize'),input.notesFontSize = 'footnotesize';end
if ~isfield(input,'makeCompleteLatexDocument'),input.makeCompleteLatexDocument = 0;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% process table datatype
if isa(input.data,'table')
  if(~isempty(input.data.Properties.RowNames))
    input.tableRowLabels = input.data.Properties.RowNames';
  end
  if(~isempty(input.data.Properties.VariableNames))
    input.tableColLabels = input.data.Properties.VariableNames';
  end
    input.data = table2array(input.data);
end

% get size of data
numberDataRows = size(input.data,1);
numberDataCols = size(input.data,2);

%% obtain cell array for the table data and labels
colLabelsExist = isfield(input,'tableColLabels');
rowLabelsExist = isfield(input,'tableRowLabels');
cellSize = [numberDataRows+colLabelsExist,numberDataCols+rowLabelsExist];
C = cell(cellSize);
C(1+colLabelsExist:end,1+rowLabelsExist:end) = num2cell(input.data);
if rowLabelsExist
    C(1+colLabelsExist:end,1)=input.tableRowLabels';
end
if colLabelsExist
    C(1,1+rowLabelsExist:end)=input.tableColLabels;
end

%% obtain cell array for the format
lengthDataFormat = length(input.dataFormat);
if lengthDataFormat==1
    tmp = repmat(input.dataFormat(1),numberDataRows,numberDataCols);
else
    dataFormatList={};
    for i=1:2:lengthDataFormat
        dataFormatList(end+1:end+input.dataFormat{i+1},1) = repmat(input.dataFormat(i),input.dataFormat{i+1},1);
    end
    if strcmp(input.dataFormatMode,'column')
        tmp = repmat(dataFormatList',numberDataRows,1);
    end
    if strcmp(input.dataFormatMode,'row')
        tmp = repmat(dataFormatList,1,numberDataCols);
    end
end
if ~isequal(size(tmp),size(input.data))
    error(['Please check your values in input.dataFormat:'...
        'The sum of the numbers of fields must match the number of columns OR rows '...
        '(depending on input.dataFormatMode)!']);
end
dataFormatArray = cell(cellSize);
dataFormatArray(1+colLabelsExist:end,1+rowLabelsExist:end) = tmp;

%% transpose table (if this is switched on)
if input.transposeTable
    C = C';
    dataFormatArray = dataFormatArray';
end

%% make table header lines:
hLine = '\hline';

if input.tableLong                          % header for long table
% -------------------------------------------------------------------------
if isfield(input,'tableNotes')
   warning('Long tables do not work well with notes.') 
end

if input.tableBorders
    header = ['\begin{longtable}','{|',repmat([input.tableColumnAlignment,'|'],1,size(C,2)),'}'];
else
    if rowLabelsExist
        header = ['\begin{longtable}','{l',repmat(input.tableColumnAlignment,1,size(C,2)-1),'}'];
    else
        header = ['\begin{longtable}','{',repmat(input.tableColumnAlignment,1,size(C,2)),'}'];
    end
end

if isfield(input,'fontSize')
    latex = {['\begin{',input.fontSize,'}']};
%     latex = {['\begin{',input.fontSize,'}'];['\begin{table}',input.tablePlacement];'\centering';header};
else
    latex = {};
%     latex = {['\begin{table}',input.tablePlacement];'\centering';header};
end

if input.tableLandscape
    latex = [latex;'\begin{landscape}'];
end
latex = [latex;'\begin{center}';[header,input.tablePlacement]];

if isfield(input,'tableNotes')
    latex = [latex;'\begin{threeparttable}'];
end
if input.captionPosition == 1
    latex = [latex;['\caption{',input.tableCaption,'}'];['\label{tab:',input.tableLabel,'}']];
end
% latex = [latex;header];
if input.booktabs;  line1 = '\toprule'; else;   line1 = hLine;  end
if input.booktabs;  line2 = '\midrule'; else;   line2 = hLine;  end
if input.booktabs;  line3 = '\bottomrule'; else;   line3 = hLine;  end
txt1 = ['%\multicolumn{',num2str(size(C,2)),'}{c}{\textit{Continued from previous page}} \\'];
txt3 = [line3,' %\multicolumn{',num2str(size(C,2)),'}{r}{\textit{Continued on next page}} \\'];
title = '';
for j=1:size(C,2)
    dataValue = C{1,j};
    if iscell(dataValue); dataValue = dataValue{:};
    elseif isnan(dataValue); dataValue = input.dataNanString;
    elseif isnumeric(dataValue); dataValue = num2str(dataValue,dataFormatArray{1,j}); end
    if j==1; title = dataValue; else title = [title,' & ',dataValue]; end
end
latex = [latex;'\endfirsthead';txt1;line1;[title,' \\'];line2;'\endhead';txt3;'\endfoot';'\endlastfoot'];
% -------------------------------------------------------------------------

else                                        % header for regular table

if input.tableBorders
    header = ['\begin{tabular}','{|',repmat([input.tableColumnAlignment,'|'],1,size(C,2)),'}'];
else
    if rowLabelsExist
        header = ['\begin{tabular}','{l',repmat(input.tableColumnAlignment,1,size(C,2)-1),'}'];
    else
        header = ['\begin{tabular}','{',repmat(input.tableColumnAlignment,1,size(C,2)),'}'];
    end
end

if isfield(input,'fontSize')
    latex = {['\begin{',input.fontSize,'}']};
%     latex = {['\begin{',input.fontSize,'}'];['\begin{table}',input.tablePlacement];'\centering';header};
else
    latex = {};
%     latex = {['\begin{table}',input.tablePlacement];'\centering';header};
end

if input.tableLandscape
    latex = [latex;'\begin{landscape}'];
end

latex = [latex;['\begin{table}',input.tablePlacement];'\centering'];
if isfield(input,'tableNotes')
    latex = [latex;'\begin{threeparttable}'];
end
if input.captionPosition == 1
    latex = [latex;['\caption{',input.tableCaption,'}'];['\label{tab:',input.tableLabel,'}']];
end
latex = [latex;header];

end                                         % end for if input.tableLong

%% generate table
if input.booktabs
    latex(end+1) = {'\toprule'};
end    

% multicolumns
% Include the following between \toprule and \midrule when multicolumn
% Need ColSharedLabels and starting column of each shared label
% Last line will use input.tableColLabels
% \multicolumn{1}{c}{} &\multicolumn{2}{c}{TP}&\multicolumn{2}{c}{Orthogonal}\\
% \cmidrule(l{.9em}r{.9em}){2-3} \cmidrule(l{.9em}r{.9em}){4-5}
% \multicolumn{1}{c}{} & 5 YR & 10 YR & 5 YR & 10 YR \\
% Later also include \midrule + Total row at the bottom of the table
% Create input.multiCols = 0 (default), 1
% Also: aligned with decimal point
% https://tex.stackexchange.com/questions/2746/aligning-numbers-by-decimal-points-in-table-columns
% 
% multirows
% https://tex.stackexchange.com/questions/156219/proper-centering-with-cmidrule-and-multi-row-and-column

for i=1:size(C,1)
    if i==2 && input.booktabs
        latex(end+1) = {'\midrule'};
    end
    if input.tableBorders
        latex(end+1) = {hLine};
    end
    
    % cmidrules
    if isfield(input,'tableCmidrules') && input.booktabs
        idxCmid = input.tableCmidrules(:,1) == i - 1;
        if any(idxCmid)
            latex(end+1) = {['\cmidrule(lr){',num2str(input.tableCmidrules(idxCmid,2)),'-',num2str(input.tableCmidrules(idxCmid,3)),'}']};
        end
    end
    
    rowStr = '';
    for j=1:size(C,2)
        dataValue = C{i,j};
        if iscell(dataValue)
          dataValue = dataValue{:};
        elseif isnan(dataValue)
          dataValue = input.dataNanString;
        elseif isnumeric(dataValue)
          dataValue = num2str(dataValue,dataFormatArray{i,j});
        end
        if j==1
            rowStr = dataValue;
        else
            rowStr = [rowStr,' & ',dataValue];
        end
    end
    latex(end+1) = {[rowStr,' \\']};
end

if input.booktabs
    latex(end+1) = {'\bottomrule'};
end   


%% make footer lines for table:
if input.tableLong                          % footer for long table
    tableFooter = {};
else                                        % footer for regular table
    tableFooter = {'\end{tabular}'};
end

if input.captionPosition == 0
    tableFooter = [tableFooter;['\caption{',input.tableCaption,'}']; ...
            ['\label{tab:',input.tableLabel,'}']];
end
if isfield(input,'tableNotes')
    tableFooter = [tableFooter;'\begin{tablenotes}[para,flushleft]'; ...
        ['\' input.notesFontSize ' \textit{Notes:} ',input.tableNotes];'\end{tablenotes}';'\end{threeparttable}'];
end
if input.tableLong 
    tableFooter = [tableFooter;'\end{longtable}';'\end{center}'];
else
    tableFooter = [tableFooter;'\end{table}'];
end
if input.tableLandscape
    tableFooter = [tableFooter;'\end{landscape}'];
end

if isfield(input,'fontSize')
    tableFooter = [tableFooter;['\end{',input.fontSize,'}']];
end
if input.tableBorders
    latex = [latex;{hLine};tableFooter];
else
    latex = [latex;tableFooter];
end

%% add code if a complete latex document should be created:
if input.makeCompleteLatexDocument
    % document header
    latexHeader = {'\documentclass[a4paper,10pt]{article}'};
    latexHeader(end+1) = {'\usepackage[labelsep=period,labelfont=bf]{caption}'};
    latexHeader(end+1) = {'\usepackage{multirow}'};
    if input.booktabs
        latexHeader(end+1) = {'\usepackage{booktabs}'};
    end
    if isfield(input,'tableNotes')
        latexHeader(end+1) = {'\usepackage{threeparttable}'};
    end
    if isfield(input,'tableLong')
        latexHeader(end+1) = {'\usepackage{longtable}'};
    end
    if isfield(input,'tableLandscape')
        latexHeader(end+1) = {'\usepackage{pdflscape}'};
    end
    latexHeader(end+1) = {'\begin{document}'};
    % document footer
    latexFooter = {'\end{document}'};
    latex = [latexHeader';latex;latexFooter];
end

%% save latex code to tex file or print to console:
if isfield(input,'texName')
    fid = fopen([input.texName,'.tex'], 'w');
    fprintf(fid,'%s\n',latex{:});           % /n needed to add new line breaks
    fclose(fid);
else
    disp(char(latex));
end

end
