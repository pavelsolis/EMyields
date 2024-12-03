/* Code for 'Term Premia and Credit Risk in Emerging Markets: The Role of U.S. 
Monetary Policy' by Pavel Solís (pavel.solis@gmail.com), October 2021

This code uses local projections to estimate the reponse of emerging market bond
yields to a 1 basis point change in U.S. target, path and LSAP shocks */
* ==============================================================================


* ------------------------------------------------------------------------------
* Preamble (uses Mac OS directory convention)
* ------------------------------------------------------------------------------
cd "/Users/Pavel/Documents/GitHub/Dissertation/Ch_Synthetic"	// update as necessary
local pathmain `c(pwd)'

global pathdlfs "/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB/August-2021"
global pathdata "`pathmain'/Data/Analytic"
global pathcode "`pathmain'/Codes/Analysis"
global pathtbls "`pathmain'/Docs/Tables"
global pathfigs "`pathmain'/Docs/Figures"
cd $pathdata

global file_src  "$pathdata/dataspillovers.xlsx"
global file_dta1 "$pathdlfs/dataspillovers1.dta"		// original dataset
global file_dta2 "$pathdlfs/dataspillovers2.dta"		// cleaned dataset
global file_log  "$pathtbls/impact_regs"
global file_tbl  "$pathtbls/impact_tbls"

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
// do "$pathcode/spov_pre"
do "$pathcode/spov_stats"
do "$pathcode/spov_combined_rho"
do "$pathcode/spov_combined_group"
do "$pathcode/spov_combined_usyc"
do "$pathcode/spov_combined_group_path"
do "$pathcode/spov_combined_usyc_path"
do "$pathcode/spov_combined_nickell"
do "$pathcode/spov_drivers"
log close
translate $file_log.smcl $file_log.pdf, replace
erase $file_log.smcl

* ------------------------------------------------------------------------------
* Files from SSC
* ------------------------------------------------------------------------------
// ssc install xtcsd, replace	// for Pesaran’s CD test of cross-sectional independence in FE panel models
// ssc install xtscc, replace	// for DK standard errors with FE panel models

* ------------------------------------------------------------------------------
* Sources
* ------------------------------------------------------------------------------
// Standard errors corrected for heteroskedasticity and autocorrelation
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1475615-newey-regression-for-panel-data

// Accesssing values of confidence intervals
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1304264-quickly-accessing-p-values-and-confidence-interval-limits

// Accessing values in a matrix identified by row name and column name
// https://www.stata.com/statalist/archive/2009-03/msg01179.html

// Handling gaps in time series using business calendars
// https://blog.stata.com/2016/02/04/handling-gaps-in-time-series-using-business-calendars/
// https://www.stata.com/manuals13/dbcal.pdf
// https://www.stata.com/manuals13/tstsset.pdf
// https://www.stata.com/statalist/archive/2005-08/msg00479.html

// Time trend in panel data
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1317069-time-trend-in-panel-data

// Country-specific time trends
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1376523-country-specific-time-trends

// Create a group variable
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1355976-how-can-i-create-groups-of-observations-in-a-panel-data

// Use -inlist- with local list
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1315256-use-inlist-with-local-list

// Tables Stata to Latex
// https://asjadnaqvi.com/stata-to-latex-part-1/
// https://www.jwe.cc/2012/03/stata-latex-tables-estout/

// Driscoll-Kray standard errors
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1566497-xtscc-error-too-many-values-r-134
