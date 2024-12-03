* ==============================================================================
* Local projections: AE and EM
* ==============================================================================
use $file_dta2, clear


* Define local variables
local xtcmd xtscc			// xtreg
local xtopt fe level(90)	// fe level(90) cluster($id)
local maxlag  = 1

foreach group in 1 { // 0 1 {
	if `group' == 0 {
		local grp "AE"
		local vars nom dyp dtp // nom usyc rho phi	//  nom syn rho phi
		local region regionae
	}
	else {
		local grp "EM"
		local vars nom dyp dtp phi // nom usyc rho phi	//	nom syn rho phi
		local region regionem
	}
	
	foreach t in 24 120 {
		// regressions
		foreach v in `vars' {
		
			// variables to store the betas and confidence intervals
			capture {
			foreach shock in mp1 path lsap {
				gen b_`shock'_`v'`t'm   = .
				gen ll1_`shock'_`v'`t'm = .
				gen ul1_`shock'_`v'`t'm = .
			}	// `shock'
			}
			
			// controls
			local ctrl`v'`t'm l(1/`maxlag').fx	// l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
			
			forvalues h = 0/$horizon {
				// response variables
				capture gen `v'`t'm`h' = (f`h'.`v'`t'm - l.`v'`t'm)
				
				// conditions
				local condition em == `group'	// & `region' == 4
				
				// one regression for each horizon
				if `h' == 0 {
					`xtcmd' `v'`t'm`h' mp1 path lsap `ctrl`v'`t'm' if `condition', `xtopt'	// on-impact effect
					foreach shock in mp1 path lsap {
						local pvalue = (2 * ttail(e(df_r),abs(_b[`shock']/_se[`shock'])))
						if `pvalue' < 0.1 local `shock'`v'  = -1*_b[`shock']
						else local `shock'`v' = 0
					}
				}
				quiet `xtcmd' `v'`t'm`h' mp1 path lsap `ctrl`v'`t'm' if `condition', `xtopt'
				
				capture {				
				foreach shock in mp1 path lsap {
					replace b_`shock'_`v'`t'm  = -1*_b[`shock'] if _n == `h'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`shock'_`v'`t'm = -1*el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `h'+1
					replace ul1_`shock'_`v'`t'm = -1*el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `h'+1
				}		// `shock'
				drop `v'`t'm`h'
				}
			}		// `h' horizon
		}		// `v' yield component
		
		// graphs
		local j = 0
		foreach shock in mp1 path lsap {
			local ++j
			if `j' == 1 local shk "Target"
			if `j' == 2 local shk "Path"
			if `j' == 3 local shk "LSAP"
			
			local k = 0
			foreach v in `vars' {
				local ++k
				if `k' == 1 local yxtitles ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall))
				else local yxtitles xtitle("Days", size(medsmall))
				twoway 	(line ll1_`shock'_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
						(line ul1_`shock'_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
						(line b_`shock'_`v'`t'm days, lcolor(blue*1.25) lpattern(solid) lwidth(thick)) /// 
						(line zero days, lcolor(black)), ///
				`yxtitles' xlabel(0(15)$horizon, nogrid) ylabel(``shock'`v'' "{bf:{&rArr}}", add custom labcolor(red) tlcolor(red) nogrid) ///
				graphregion(color(white)) plotregion(color(white)) legend(off) name(`v'`t'm, replace) ///
				title(`: variable label `v'`t'm', color(black) size(medium))

// 				graph export $pathfigs/LPs/`shk'/`grp'/`v'`t'm.eps, replace
				local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'm
				drop *_`shock'_`v'`t'm				// b_ and confidence intervals
			}	// `v' yield component

			graph combine `graphs`shock'`grp'`t'', rows(1) ycommon
			graph export $pathfigs/LPs/`shk'/`grp'/`shk'`grp'nomyptpphi`t'mNickell.eps, replace
			graph drop _all
		}		// `shock'
	}		// `t' tenor
}		// `group' AE or EM
