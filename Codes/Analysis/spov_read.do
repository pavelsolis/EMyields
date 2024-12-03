* ==============================================================================
* Load dataset
* ==============================================================================

set excelxlsxlargefile on
import excel using $file_src, clear firstrow case(lower)
save $file_dta1, replace
