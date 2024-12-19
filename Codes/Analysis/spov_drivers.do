* ==============================================================================
* Panel regressions with monthly data
* ==============================================================================
use $file_dta2, clear


* Keep monthly data and define panel
keep if eomth
global idm imf
global tm datem
sort  $idm $tm
xtset $idm $tm
drop date eomth
order  datem, first
replace cbp = cbp*100


* Compute monthly returns (in basis points)
foreach v of varlist vix spx oil fx stx epuus epugbl globalip {
    gen log`v' = ln(`v')
	by $idm: gen rt`v' = (log`v' - log`v'[_n-1])*10000
}


* Standardize the exchange rate
egen meanFX = mean(fx), by($idm)
egen stdFX  = sd(fx), by($idm)
gen  zfx    = (fx - meanFX) / stdFX


* Define local variables
local xtcmd xtscc	// xtreg
local xtopt fe		// fe cluster($id)


* Define global variables
global x0 sdprm
global x1 logvix logepuus logepugbl globalip
global x2 cbp inf une zfx $x1


* Label variables for use in figures and tables
#delimit ;
unab oldlabels : ustp* usyp* rtvix rtfx rtoil rtspx rtstx rtepuus rtepugbl rtglobalip 
				 logepuus logepugbl logvix vix zfx cbp;
local newlabels `" "U.S. Term Premium" "U.S. Term Premium" "U.S. Term Premium" "U.S. Term Premium" 
				"U.S. E. Short Rate" "U.S. E. Short Rate" "U.S. E. Short Rate" "U.S. E. Short Rate" 
				"Vix" "FX" "Oil" "S\&P" "Stock" "EPU U.S." "Global EPU" "Global Ind. Prod." 
				"Log(EPU U.S.)" "Log(EPU Global)" "Log(VIX)" "VIX" "LC per USD (Std.)" "Local Policy Rate" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}


* ------------------------------------------------------------------------------
* Table B.1. TP and UCSV
local tbllbl "f_tpucsv"
eststo clear
local j = 0
foreach t in 6 12 24 60 120 {
	local ++j
	`xtcmd' dtp`t'm $x0 if em, `xtopt'
	eststo mtp`j', addscalars(Lags e(lag) R2 e(r2_w) Countries e(N_g) Obs e(N))
	estadd local FE Yes
	local ++j
	`xtcmd' dtp`t'm $x0 gdp if em, `xtopt'
	eststo mtp`j', addscalars(Lags e(lag) R2 e(r2_w) Countries e(N_g) Obs e(N))
	estadd local FE Yes
	quiet xtreg dtp`t'm $x0 if em, fe
	xtcsd, pesaran abs
	quiet xtreg dtp`t'm $x0 gdp if em, fe
	xtcsd, pesaran abs
}
esttab mtp* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
keep($x0 gdp) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("6 Months" "1 Year" "2 Years" "5 Years" "10 Years", pattern(1 0 1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
varlabels(, elist(gdp \midrule)) scalars("FE Fixed Effects" "Lags" "Countries No. Countries" "Obs Observations" "R2 \(R^{2}\)") sfmt(%4.0fc %4.0fc %4.0fc %4.0fc %4.2fc)
// scalars("e(lag) Lags" "e(r2_w) R2" "e(N_g) Countries" "e(N) Obs" “Fixed Effects”)
// filefilter x.tex "$pathtbls/`tbllbl'.tex", from(\BS\BS\n) to(\BStabularnewline\n) replace
// erase x.tex
* ------------------------------------------------------------------------------

* Repeat sdprm values throughout the quarter
replace sdprm = L.sdprm if sdprm >= .

* ------------------------------------------------------------------------------
* Tables 4, 5, D.1 and D.2. Drivers
local tbllbl "f_ycdcmp"
eststo clear
foreach t in 12 24 60 120 {
	local ty = `t'/12
	foreach group in 1 { // 0
		local condition em == `group'
		local j = 0
		foreach v in nom dyp dtp phi {
			local ++j
			if `group' == 0 {
				`xtcmd' `v'`t'm ustp`t'm usyp`t'm $x1 if `condition', `xtopt'
				eststo mdl`j', addscalars(Lags e(lag) R2 e(r2_w) Countries e(N_g) Obs e(N))
				estadd local FE Yes
				quiet xtreg `v'`t'm ustp`t'm usyp`t'm $x1 if `condition', fe
				xtcsd, pesaran abs
			}
			
			if `group' == 1 {
				`xtcmd' `v'`t'm ustp`t'm usyp`t'm $x2 if `condition' & phi`t'm != ., `xtopt'
				eststo mdl`j', addscalars(Lags e(lag) R2 e(r2_w) Countries e(N_g) Obs e(N))
				estadd local FE Yes
				quiet xtreg `v'`t'm ustp`t'm usyp`t'm $x2 if `condition', fe
				xtcsd, pesaran abs
			}
		}	// `v' variables
		esttab mdl* using x.tex, replace fragment cells(b(fmt(2) star) se(fmt(2) par)) ///
		nocons nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
		mgroups("Nominal" "E. Short Rate" "Term Premium" "Credit Risk", pattern(1 1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		varlabels(, elist(globalip \midrule)) scalars("FE Fixed Effects" "Lags" "Countries No. Countries" "Obs Observations" "R2 \(R^{2}\)") sfmt(%4.0fc %4.0fc %4.0fc %4.0fc %4.2fc)
	}	// `group'
	filefilter x.tex "$pathtbls/`tbllbl'`ty'y.tex", from(Observations) to(Observations) replace
}	// `t'
erase x.tex
* ------------------------------------------------------------------------------