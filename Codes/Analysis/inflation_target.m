function [ld,lu] = inflation_target(cntry)
% INFLATION_TARGETS Return lower and upper bands of the inflation target
% 
% m-files called: none
% Pavel Solís (pavel.solis@gmail.com), August 2020
%% 
switch cntry
    case {'COP','HUF','KRW','MXN'}
        ld = 2;     lu = 4;
    case {'ILS','PEN'}
        ld = 1;     lu = 3;
    case 'BRL'; ld = 2.5;   lu = 6.5;
    case 'IDR'; ld = 3.5;   lu = 5.5;
    case 'MYR'; ld = [];    lu = [];
    case 'PHP'; ld = 3;     lu = 5;
    case 'PLN'; ld = 1.5;   lu = 3.5;
    case 'RUB'; ld = 4;     lu = 7;
    case 'THB'; ld = 1.5;   lu = 4.5;
    case 'TRY'; ld = 3;     lu = 7;
    case 'ZAR'; ld = 3;     lu = 6;
end