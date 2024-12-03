local horizon = 90
local maxlag  = 1

* LPs
local j = 0
foreach shock in mp1 path lsap {
	local ++j
	if `j' == 1 local shk "Target"
	if `j' == 2 local shk "Path"
	if `j' == 3 local shk "LSAP"

levelsof cty, local(levels)
foreach grp of local levels { 
// 	foreach group in "AUD" {
// 		local grp `group'
		local vars nom sftnom // syn sftsyn lagrho
		
		foreach t in 24 120 { // 3 6 12 24 60 120  {
			foreach v in `vars' {
			
				// variables to store the betas, standard errors and confidence intervals
				capture {
				gen b_`v'`t'm   = .
				gen se_`v'`t'm  = .
				gen ll1_`v'`t'm = .
				gen ul1_`v'`t'm = .
				gen ll2_`v'`t'm = .
				gen ul2_`v'`t'm = .
				}
				
				// controls
				local ctrl`v'`t'm l(2).`v'`t'm // l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
				
				forvalues i = 0/`horizon' {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
					// conditions
					local condition cty == "`grp'" & date > td(1jan2000) & date < td(1jan2020)
					
					// one regression for each horizon
					if `i' == 0 reg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', level(95) robust 			// report on-impact effect
					quiet reg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', level(95) robust
					capture {
					replace b_`v'`t'm  = _b[`shock'] if _n == `i'+1
					replace se_`v'`t'm = _se[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					quiet reg, level(90)	// to get 90% CI
					matrix R = r(table)
					replace ll2_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul2_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					
					drop `v'`t'm`i'
					}
				}			// horizon
				
				// graph
				twoway 	(rarea ll1_`v'`t'm ul1_`v'`t'm days, fcolor(gs12) lcolor(white) lpattern(solid)) ///
						(rarea ll2_`v'`t'm ul2_`v'`t'm days, fcolor(gs10) lcolor(white) lpattern(solid)) ///
						(line b_`v'`t'm days, lcolor(black) lpattern(solid) lwidth(thick)) /// 
						(line zero days, lcolor(black)), ///
				title(`: variable label `v'`t'm', color(black) size(medium)) ///
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) ylabel(-3(1)3) xlabel(0 15 30 45 60 75 90) ///
				graphregion(color(white)) plotregion(color(white)) ///
				legend(off) name(`v'`t'm, replace)
				graph export $pathfigs/LPs/`shk'/CTY/`shk'`grp'`v'`t'm.eps, replace
				
				drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		
		graph drop _all
		}				// tenor
	}					// grp (AE, EM, CTY)
}						// shock

// twoway (line nom120m syn120m sftnom120m sftsyn120m datem if cty == "COP") (line usyc120m datem if cty == "COP", yaxis(2))
// twoway (line nom120m sftsyn120m datem if cty == "COP") (line usyc120m datem if cty == "COP", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "MXN") (line usyc120m datem if cty == "MXN", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "PEN") (line usyc120m datem if cty == "PEN", yaxis(2))
// twoway (line nom120m sftsyn120m datem if cty == "CAD") (line usyc120m datem if cty == "CAD", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "BRL") (line usyc120m datem if cty == "BRL", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "GBP") (line usyc120m datem if cty == "GBP", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "HUF") (line usyc120m datem if cty == "HUF", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "PLN") (line usyc120m datem if cty == "PLN", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "ZAR") (line usyc120m datem if cty == "ZAR", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "CHF") (line usyc120m datem if cty == "CHF", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "DKK") (line usyc120m datem if cty == "DKK", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "EUR") (line usyc120m datem if cty == "EUR", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "NOK") (line usyc120m datem if cty == "NOK", yaxis(2))
// twoway (line sftnom120m sftnom60m datem if cty == "NOK") (line usyc120m datem if cty == "NOK", yaxis(2))
// twoway (line sftnom120m sftnom60m datem if cty == "SEK") (line usyc120m datem if cty == "SEK", yaxis(2))
// twoway (line sftnom120m sftnom60m datem if cty == "ILS") (line usyc120m datem if cty == "ILS", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "RUB") (line usyc120m datem if cty == "RUB", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "TRY") (line usyc120m datem if cty == "TRY", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "IDR") (line usyc120m datem if cty == "IDR", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "THB") (line usyc120m datem if cty == "THB", yaxis(2))
// twoway (line nom120m sftsyn120m datem if cty == "MYR") (line usyc120m datem if cty == "MYR", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "PHP") (line usyc120m datem if cty == "PHP", yaxis(2))
// twoway (line sftnom120m sftsyn120m datem if cty == "KRW") (line usyc120m datem if cty == "KRW", yaxis(2))
// twoway (line nom120m sftsyn120m datem if cty == "JPY") (line usyc120m datem if cty == "JPY", yaxis(2))
// twoway (line nom120m sftsyn120m datem if cty == "AUD") (line usyc120m datem if cty == "AUD", yaxis(2))
// twoway (line nom120m sftsyn120m datem if cty == "NZD") (line usyc120m datem if cty == "NZD", yaxis(2))
