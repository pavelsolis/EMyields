/* Code for 'Term Premia and Credit Risk in Emerging Markets: The Role of U.S. 
Monetary Policy' by Pavel Solís (pavel.solis@gmail.com)

This code uses local projections to estimate the reponse of emerging market bond
yields to a 1 basis point change in U.S. target, path and LSAP surprises */
* ==============================================================================

* ------------------------------------------------------------------------------
* Preamble
* ------------------------------------------------------------------------------
cd "~/EMyields/Codes/Analysis"							// update as necessary
local pathmain `c(pwd)'

global pathdata "`pathmain'/Data/Analytic"
global pathcode "`pathmain'/Codes/Analysis"
global pathtbls "`pathmain'/Docs/Tables"
global pathfigs "`pathmain'/Docs/Figures"
cd $pathdata

global file_src  "$pathdata/dataspillovers.xlsx"
global file_dta1 "$pathdata/dataspillovers1.dta"		// original dataset
global file_dta2 "$pathdata/dataspillovers2.dta"		// cleaned dataset
global file_log  "$pathtbls/impact_regs"

* ------------------------------------------------------------------------------
* Dataset
* ------------------------------------------------------------------------------
do "$pathcode/spov_read"
do "$pathcode/spov_vars"
use $file_dta2, clear

* ------------------------------------------------------------------------------
* Analysis
* ------------------------------------------------------------------------------
log using $file_log, replace
do "$pathcode/spov_stats"								// generate tables 1 to 3
do "$pathcode/spov_drivers"								// generate tables 4, 5, B.1, D.1 and D.2
do "$pathcode/spov_combined_group"						// generate figures 2, 5 and E.14
do "$pathcode/spov_combined_group_path"					// generate figures 3 and 4
do "$pathcode/spov_combined_usyc"						// generate figures E.3, E.6 and E.7
do "$pathcode/spov_combined_usyc_path"					// generate figures E.4 and E.5
do "$pathcode/spov_combined_regionem"					// generate figures E.8 to E.13
do "$pathcode/spov_combined_rho"						// generate figure E.15
log close
translate $file_log.smcl $file_log.pdf, replace
erase $file_log.smcl

* ------------------------------------------------------------------------------
* Files from SSC
* ------------------------------------------------------------------------------
// ssc install xtcsd, replace							// for Pesaran’s CD test
// ssc install xtscc, replace							// for DK standard errors