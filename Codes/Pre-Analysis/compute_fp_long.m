function [CCS,hdr] = compute_fp_long(LC,header,dataset)
% COMPUTE_FP_LONG Compute fixed-for-fixed cross-currency swaps for maturities >= 1Y
% Formulas are in 'AE_EM_Curves_Tickers.xlsx'. See Du & Schreger (2016) and Du, Im & Schreger (2018)
%
%     INPUTS
% char: LC        - local currency for which CCS will be computed
% cell: header    - contains information about the tikcers (eg currency, type, tenor)
% double: dataset - dataset with historic values of all the tickers
% 
%     OUTPUT
% double: CCS - matrix of historic CCS (rows) for different tenors (cols)
% cell: hdr   - header ready to be appended (NO extra first row with titles)

% m-files called: extractvars, split_merge_vars, construct_hdr
% Pavel Solís (pavel.solis@gmail.com)
%%
ccy_AE = {'AUD','CAD','CHF','DKK','EUR','GBP','JPY','NOK','NZD','SEK'};
switch LC
    case {'BRL','COP','IDR','PEN','PHP','KRW'}      % Formula 1
        currencies = {LC,'USD','USD'};
        types      = {'NDS','TBS3v6_USD','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        NDS = vars{1};   TBS3v6_USD = vars{2};   IRS_USD = vars{3};

        CCS = NDS - TBS3v6_USD./100 - IRS_USD;
    
    case {'HUF','PLN'}                              % Formula 2
        currencies = {LC,LC,'EUR','USD'};
        types      = {'IRS','BS','BS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2};  BS_EUR = vars{3}; IRS_USD = vars{4};
        BS(isnan(BS)) = 0;                          % allows it to compute CCS when BS is NaN

        CCS = IRS + BS./100 + BS_EUR./100 - IRS_USD;

    case ['ILS','MYR','ZAR',ccy_AE]                 % Formula 3
        currencies = {LC,LC,'USD'};
        types      = {'IRS','BS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; IRS_USD = vars{3};
        
        CCS = IRS + BS./100 - IRS_USD;

    case 'MXN'                                      % Formula 4
        currencies = {LC,LC,'USD','USD'};
        types      = {'IRS','BS','TBS1v3_USD','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; TBS1v3_USD = vars{3};  IRS_USD = vars{4};

        CCS = IRS - BS./100 + TBS1v3_USD./100 - IRS_USD;

    case 'THB'                                      % Formula 5
        currencies = {LC,LC,'USD','USD'};
        types      = {'IRS','BS','TBS3v6_USD','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; TBS3v6_USD = vars{3};  IRS_USD = vars{4};

        CCS = IRS + BS./100 - TBS3v6_USD./100 - IRS_USD;

    case 'TRY'                                      % Formula 6
        currencies = {LC,'USD'};
        types      = {'CCS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        CCS = vars{1};  IRS_USD = vars{2};

        CCS = CCS - IRS_USD;

    case 'RUB'                                      % Formula 7
        currencies = {LC,'USD'};
        types      = {'NDS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        NDS = vars{1};  IRS_USD = vars{2};

        CCS = NDS - IRS_USD;

%     case 'BRL2' % Formula 8
%         currencies = {LC,LC};
%         types      = {'IRS','CC'};
%         [vars,tnr] = extractvars(currencies,types,header,dataset);
%         IRS = vars{1};  CC = vars{2};
% 
%         CCS = IRS - CC;
        
    otherwise
        disp('Cannot compute the CCS for %s.',LC)
end

% Special cases (formula changes)
if strcmp(LC,'JPY') || strcmp(LC,'NOK')
    CCS1 = CCS; tnr1 = tnr;
    
    currencies   = {LC,LC,LC,'USD'};
    types        = {'IRS','TBS','BS','IRS_USD'};
    [vars2,tnr2] = extractvars(currencies,types,header,dataset);
    IRS = vars2{1}; TBS = vars2{2}; BS = vars2{3}; IRS_USD = vars2{4};
    TBS(isnan(TBS)) = 0;                                                    % allows it to compute CCS when TBS is NaN

    CCS2 = IRS - TBS./100 + BS./100 - IRS_USD;

    [CCS,tnr] = split_merge_vars(LC,CCS1,CCS2,tnr1,tnr2,dataset);           % if CCS* as cell arrays, may not need iscell
end

% Header
name = strcat(LC,' CROSS-CURRENCY SWAP',{' '},tnr,' YR');
hdr  = construct_hdr(LC,'RHO','N/A',name,tnr,' ',' ');                      % Note: No extra row 1 (title)

% if strcmp(LC,'BRL2')                                                      % Since 2 ways to compute CCS for BRL
%     hdr  = construct_hdr(LC,'RHO2','N/A',name,tnr,' ',' ');
% end

%% Formulas
% 
% % Formula 1
% BRL	NDS-TBS3v6_USD/100-IRS_USD
% COP	NDS-TBS3v6_USD/100-IRS_USD
% IDR	NDS-TBS3v6_USD/100-IRS_USD
% KRW	NDS-TBS3v6_USD/100-IRS_USD
% PEN	NDS-TBS3v6_USD/100-IRS_USD
% PHP	NDS-TBS3v6_USD/100-IRS_USD
% 
% % Formula 2
% HUF	IRS+BS/100+BS_EUR/100-IRS_USD
% PLN	IRS+BS/100+BS_EUR/100-IRS_USD
% 
% % Formula 3
% ILS	IRS+BS/100-IRS_USD
% MYR	IRS+BS/100-IRS_USD
% ZAR	IRS+BS/100-IRS_USD
% 
% % Formula 4
% MXN	IRS-BS/100+TBS1v3_USD/100-IRS_USD
% 
% % Formula 5
% THB	IRS+BS/100-TBS3v6_USD/100-IRS_USD
% 
% % Formula 6
% TRY	CCS-IRS_USD
% 
% % Formula 7
% RUB	NDS-IRS_USD
% 
% % Formula 8
% BRL2	IRS-CC