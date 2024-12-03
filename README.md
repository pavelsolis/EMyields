# [Term Premia and Credit Risk in Emerging Markets: The Role of U.S. Monetary Policy](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3973655)

by Pavel Solís (pavel.solis@gmail.com)


## System Features
The results in the paper were generated using the following:
- Operating systems: macOS 12.2.1, Windows 10 Enterprise.
- Software: Matlab R2019a, Stata 17.
- Add-ons. Matlab: financial toolboxes. Stata: scheme-modern, xtcsd, xtscc.ado*.
- Restricted data sources: Bloomberg, Datastream.
- Expected running time: Pre-Analysis ~ 30 min, Analysis ~ 2 hrs.

* In the file xtscc.ado, comment out section `Check if dataset's timevar is regularly spaced` (lines 74-83) because `tab timevar` gives the error `too many variables`. Type `which xtscc` in Stata to find the location of the xtscc.ado file.


## Contents of Folder
- README.txt (this file).
- LICENSE: Open-source license for the repository.
- Codes folder with the following subfolders:
	- Pre-Analysis. Codes that generate the *analysis data files* by cleaning and processing the *original data files*.
	- Analysis. Replication codes.
- Data folder with the following subfolders:
	- Raw. Original data files.
	- Analytic. Analysis data files.*
- Docs folder with the following subfolders: 
	- Paper. Files that make up the manuscript and the online appendix.
	- Figures. Files for the figures used in the paper.
	- References. File listing the cited references.


### Data Files
The repository does not support .xls nor .xlsx files.

Some variables and datasets (e.g., from Bloomberg and Datastream) cannot be shared due to licensing rights.

Some data files are stored outside the main folder due to their large sizes. Before running the codes, define where those large datasets will be stored in your computer by updating the paths in the respective codes (read_data.m, ts_analysis.m, spillovers.do).
- The large data files are: struct_datady_cells.mat, struct_datady_S.mat, struct_datamy_S.mat, dataspillovers1.dta, dataspillovers2.dta.
- Most data in Matlab are stored in a structure array of countries with different fields; the information in key fields is stored as a timetable (a Matlab data type). 


## Instructions for Replication
Execute the ts_analysis.m and spillovers.do files to replicate the results in the paper.

Execute the paper.tex and online.tex files to generate the PDF version of the manuscript and the online appendix.


## Code Workflow (Optional)
Below are details to facilitate following the workflow of the codes.

In the Pre-Analysis folder, read_data.m -> generates dataset_daily (approx. runtime: 30 min)
- read_platforms	-> tickers from Bloomberg and Datastream
- read_usyc		-> data from GSW and H.15
- fwd_prm		-> short- and long-term forward premia
- zc_yields		-> par converted into zero-coupon yields
- spreads		-> CIP deviations, yield spreads (LC, FC)
- read_cip		-> load DIS dataset
- plot_spreads		-> plot (term structure of) spreads
- compare_cip		-> compare own spreads vs DIS

variable types in header_daily: RHO, LCNOM, LCSYNT, LCSPRD, CIPDEV, FCSPRD

auxiliary m-files: compare_tbills, compare_ycs, compare_fx

In the Analysis folder, ts_analysis.m -> generates structure with data in fields (approx. runtime: 2 hrs)
- daily2dymy		-> extract monthly data
- add_macroNsvys	-> add macro and survey data
- append_svys2ylds	-> combine yield and survey data
- atsm_estimation 	-> estimate model w/ and w/o survey data, nominal & synthetic YCs
- se_components		-> compute standard errors using the delta method
- (post-estimation)	-> assess_fit, add_vars, ts_plots, ts_correlations, ts_pca
- atsm_daily		-> estimate model w/ daily data
- construct_panel 	-> construct panel dataset

auxiliary m-files: read_macrovars, read_kw

'dataset_daily' contains yield curves (LC, FC, US), forward premiums, spreads (LC, FC, LC-US) for different maturities with DAILY frequency. All series run top-down old-new, series were appended to the RIGHT. Series are identified with a filter over header_daily

'dataset_monthly' contains synthetic LC yield curves, expected short rates, term premia, LCCS for different maturities with MONTHLY frequency. Series run top-down old-new, series were appended BELOW (since series start at different times). Series are identified with a filter over header_monthly
