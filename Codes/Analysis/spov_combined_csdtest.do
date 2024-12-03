* ==============================================================================
* Local projections: Pesaran test
* ==============================================================================
use $file_dta2, clear

local maxlag  = 1
local vars nom dyp dtp phi // nom usyc rho phi	//  nom syn rho phi
foreach group in 0 1 {
	if `group' == 0 local grp "AE"
	else local grp "EM"
	
	foreach t in 24 120 { // 3 6 12 24 60 120  {
		// regressions
		foreach v in `vars' {
			
			// controls
			local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
			
			forvalues h = 0(30)$horizon {
				// response variables
				capture gen `v'`t'm`h' = (f`h'.`v'`t'm - l.`v'`t'm)
				
				// conditions
				local condition em == `group' & fomc
				
				// test for cross-sectional independence
				quiet xtreg `v'`t'm`h' `shock' `ctrl`v'`t'm' if `condition', fe
				xtcsd, pesaran abs
				
				capture drop `v'`t'm`h'
			}		// `h' horizon
		}		// `v' yield component	
	}		// `t' tenor
}		// `group' AE or EM
