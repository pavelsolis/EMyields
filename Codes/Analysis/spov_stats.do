* ==============================================================================
* Preliminary analysis
* ==============================================================================
use $file_dta2, clear


* ------------------------------------------------------------------------------
* Table 1. Summary statistics for U.S. monetary policy shocks
local tbllbl "f_mpsstats"
matrix drop _all
local j = 0
foreach shock in mp1 path lsap {
	local ++j
	if `j' == 1 local datecond date > td(1jan2000) & date < td(1jan2020)	// target
	if `j' == 4 local datecond date > td(1jan2000) & date < td(1jan2020)	// path
	if `j' == 7 local datecond date > td(1oct2008) & date < td(1jan2020)	// lsap
	
	estpost summ abs`shock' if cty == "CHF" & fomc & `datecond' // & abs`shock' != 0
	if `j' == 1 {
		matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )
		matrix rownames t1 = "Mean" "S.D." "Min." "Max." "Obs"
		matrix t`j' = t`j''
	}
	else {
		matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )'
	}
	local ++j
	estpost summ `shock' if cty == "CHF" & fomc & `shock' > 0
	matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )'
	local ++j
	estpost summ `shock' if cty == "CHF" & fomc & `shock' < 0
	matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )'
}
matrix tablemps = ( t1 \ t2 \ t3 \ t4 \ t5 \ t6 \ t7 \ t8 \ t9 )
matrix rownames tablemps = "Target Surprises (abs. values)" "\quad Target Surprises \(>\) 0" "\quad Target Surprises \(<\) 0" "Path Surprises  (abs. values)" "\quad Path Surprises \(>\) 0" "\quad Path Surprises \(<\) 0" "LSAP Surprises  (abs. values)" "\quad LSAP Surprises \(>\) 0" "\quad LSAP Surprises \(<\) 0"
esttab matrix(tablemps, fmt(1 1 1 1 0)) using x.tex, replace fragment noobs nomtitles nonumbers booktabs
filefilter x.tex y.tex, from(Path) to("Forward Guidance") replace
filefilter y.tex x.tex, from(LSAP) to("Asset Purchase") replace
filefilter x.tex y.tex, from(\nForward) to(\n\BSmidrule\nForward) replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(\nAsset) to(\n\BSmidrule\nAsset) replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table 2. Summary statistics for nominal and synthetic yields
local tbllbl "f_yldcrvstats"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in nom syn {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if eomth, by(ae) statistics(mean sd) nototal
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S.D.") replace
filefilter x.tex y.tex, from(\BS\BS\n) to(\BS\BS\n&) replace
filefilter y.tex x.tex, from(&\BSmidrule\nEmerging) to(\BSmidrule\nEmerging) replace
filefilter x.tex y.tex, from("Emerging Markets") to("Synthetic&Emerging Markets\n%") replace
filefilter y.tex x.tex, from("Advanced Economies") to("&Advanced Economies\n%") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nSynthetic&Emerging) to(Y\BS\BS\n\BSmidrule\nNominal&Emerging) replace
filefilter y.tex x.tex, from(&\BSmidrule) to(\BScmidrule(lr){2-8}) replace
filefilter x.tex y.tex, from("Emerging Markets") to("\BSmulticolumn{7}{c}{Emerging Markets}\t\BS\BS") replace
filefilter y.tex x.tex, from("Advanced Economies") to("\BSmulticolumn{7}{c}{Advanced Economies}\t\BS\BS") replace
filefilter x.tex y.tex, from(Nominal) to("\BSmultirow{7}{*}{Nominal}") replace
filefilter y.tex x.tex, from(Synthetic) to("\BSmultirow{7}{*}{Synthetic}") replace
filefilter x.tex y.tex, from(3M&) to("  & 3M&") replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(%&) to(\BScmidrule(lr){2-8}\n%&) replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table 3. Summary statistics for components of EM nominal yields
local tbllbl "f_dcmpstats"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp phi {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if em & eomth, statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S.D.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex x.tex, from(2\BS\BS\n\BSmidrule\nAverage) to("2\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(0\BS\BS\n\BSmidrule\nAverage) to("0\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Compensation}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Summary statistics for components of EM nominal yields (not truncated)
local tbllbl "f_dcmpstatsnotrunc"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp oldphi {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if em & eomth, statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S.D.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex x.tex, from(1\BS\BS\n\BSmidrule\nAverage) to("1\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(0\BS\BS\n\BSmidrule\nAverage) to("0\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Summary statistics for components of AE nominal yields
local tbllbl "f_dcmpstats_AE"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if !em & eomth, statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S.D.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{5}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(4\BS\BS\n\BSmidrule\nAverage) to("4\BS\BS\n\BSmidrule\n&\BSmulticolumn{5}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------