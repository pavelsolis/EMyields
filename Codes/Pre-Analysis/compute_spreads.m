function [SPRDvars,SPRDhdr] = compute_spreads(LC,ccy_type,header,dataset)
% COMPUTE_SPREADS Compute interest rate differentials of local currency (LC)
% and foreign currency (FC) sovereign bonds with respect to the U.S., LC
% synthetic yield curves and deviations from covered interest parity (CIP)
% Note: Variables are extracted in pairs since tenors differ
%
%     INPUTS
%	LC: string with country for which the spreads will be computed
% 	ccy_type: 1 for LC and 2 for FC
%   header:  cell with information about the tickers (e.g. currency, type, tenor)
%	dataset: dataset with historic values of all the tickers
% 
%     OUTPUT
%	SPRDvars: daily LC synthetic yield curves, spreads and CIP deviations (rows) for different tenors (cols)
%	SPRDhdr: header ready to be appended (i.e. NO extra first row with titles)

% m-files called: extractvars, construct_hdr
% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
% Type of US yield curve
ycUS = {'LCNOM','LC'};	optUS = 1;          	% LCNOM is GSW, LC is Bloomberg
ycCY = {'LCNOM','LC'};  optCY = 1;            	% LCNOM is NSS, LC is Bloomberg

switch ccy_type
    case 1  % LC case
        % Synthetic LC yield curve
        currencies = {'USD',LC};
        types      = {ycUS{optUS},'RHO'};
        [vars,tnrLCsynt] = extractvars(currencies,types,header,dataset);
        y_US = vars{1};   FP = vars{2};
        y_LCsynt = y_US + FP;
        name_LCsynt = strcat(LC,' SYNTHETIC LC YIELD CURVE',{' '},tnrLCsynt,' YR');
        hdr_LCsynt  = construct_hdr(LC,'LCSYNT','N/A',name_LCsynt,tnrLCsynt,' ',' ');
        
        % LC-US interest rate spread
        currencies = {LC,'USD'};
        types      = {ycCY{optCY},ycUS{optUS}};
        [vars,tnrLCsprd] = extractvars(currencies,types,header,dataset);
        y_LC = vars{1};   y_US = vars{2};
        y_LCsprd = y_LC - y_US;
        name_LCsprd = strcat(LC,' LC INTEREST RATE SPREAD',{' '},tnrLCsprd,' YR');
        hdr_LCsprd  = construct_hdr(LC,'LCSPRD','N/A',name_LCsprd,tnrLCsprd,' ',' ');
        
        vars_aux = [y_LCsynt, y_LCsprd];
        hdr_aux  = [hdr_LCsynt; hdr_LCsprd];
        
        % Deviations from CIP
        currencies = {LC,LC};
        types      = {ycCY{optCY},'LCSYNT'};
        [vars,tnrCIPdev] = extractvars(currencies,types,[header;hdr_aux],[dataset,vars_aux]);
        y_LC = vars{1};   y_LCsynt = vars{2};
        CIP_dev = y_LC - y_LCsynt;
        name_CIPdev = strcat(LC,' CIP DEVIATION',{' '},tnrCIPdev,' YR');
        hdr_CIPdev  = construct_hdr(LC,'CIPDEV','N/A',name_CIPdev,tnrCIPdev,' ',' ');
        
        % Append all variables and stack the headers
        SPRDvars = [vars_aux, CIP_dev];        
        SPRDhdr  = [hdr_aux; hdr_CIPdev];
        
    case 2  % FC case
        % FC interest rate differential
        currencies = {LC,'USD'};
        types      = {'USD',ycUS{optUS}};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        y_FC = vars{1};  y_US = vars{2};
        y_FCsprd = y_FC - y_US;
        name_FCsprd = strcat(LC,' FC INTEREST RATE SPREAD',{' '},tnr,' YR');
        SPRDhdr = construct_hdr(LC,'FCSPRD','N/A',name_FCsprd,tnr,' ',' ');
        
        SPRDvars = y_FCsprd;

    otherwise
        disp('Cannot compute the credit spread.')
end
