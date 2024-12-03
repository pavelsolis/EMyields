# [Term Premia and Credit Risk in Emerging Markets: The Role of U.S. Monetary Policy](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3973655)

by Pavel Solís (pavel.solis@gmail.com)


## System Features
The results in the paper were generated using the following:
- Operating systems: macOS 11.6, Windows 10 Enterprise.
- Software: Matlab R2019a, Stata 17.
- Add-ons. Financial toolboxes (Matlab); scheme-modern, xtcsd, xtscc.ado* (Stata).
- Restricted data sources: Bloomberg, Datastream.
- Expected running time: Pre-Analysis (30 min), Analysis (2 hrs)

* In the file xtscc.ado, comment out section `Check if dataset's timevar is regularly spaced` (lines 74-83) because `tab timevar` gives the error `too many variables`. Type `which xtscc` in Stata to find the location of the xtscc.ado file.


## Contents of Folder
- README.txt (this file).
- LICENSE: open source license for the repository.
- runAll.sh: calls the main files to generate the results and the latest versions of the paper and the slides.
- Codes folder with the following subfolders:
	- Pre-Analysis folder: codes that generate the *analysis data files* by cleaning and processing the *original data files*.
	- Analysis folder: codes that perform the analysis.
	- Extra folder: auxiliary, temporary and old codes.
- Data folder with the following subfolders:
	- Metadata: files documenting the data sources and variables.
	- Raw folder: original data files.
	- Analytic folder: analysis (gleaned or processed) data files.
	- Extra folder: auxiliary, temporary and old data files.
- Docs folder with the following subfolders: 
	- Paper folder: files that make up the manuscript.
	- Slides folder: files that make up the slides.
	- Equations folder: files that define and reference equations.
	- Figures folder: files for the figures used in the paper or the slides.
	- Tables folder: files for the tables used in the paper or the slides.
	- Settings folder: files with settings for the paper and the slides.
	- References folder: files listing the cited references.
	- Extra folder: auxiliary, temporary and old files.


## Instructions for Replication
The metadata file (Data/Metadata/metadata.docx) describes the (original and analysis) data files and provides instructions on how to update them.

The folder structure uses stratification to avoid repeating code or duplicating files (e.g., equations, figures, tables), and to facilitate collaboration, development and testing (since researchers can focus on specific parts). The following main files call the necessary bits in the required order:
- Codes/Analysis/spillovers.do: runs the codes sequentially (workflow below) to generate the results.
- Docs/Paper/paper.tex: puts together the pieces constituting the manuscript.
- Docs/Slides/slides.tex: calls equations, figures and tables.
- runAll.sh: calls the previous main files sequentially to avoid having to execute them individually.


## Considerations
Make sure the names of files and folders added or modified have *no* spaces.

The codes run regardless of the location of the main folder because they use relative paths based on its structure.
- When possible, directory paths are written to be independent of the platform used. Otherwise, the scripts use the Unix convention (i.e., forward slash) in directory paths; modify them (i.e., use backslashes) if an error occurs while executing a script in a Windows machine.

The analysis data files used to replicate (most of) the results in the paper:
- Contain (most of) the variables necessary for the analysis, generated from the original data files; some variables and original data files are not shared due to licensing rights.
- Can be updated if the user has access to the (restricted) original data sources.

### Data Files
The repository does not support .xls nor .xlsx files.

Datasets that require access to Bloomberg and Datastream cannot be shared due to licensing rights.

From the datasets in the Raw folder, the codes generate new datasets. Some of them are stored outside the main folder Ch_Synt due to their large sizes; they are: struct_datady_cells.mat, struct_datady_S.mat, struct_datamy_S.mat, dataspillovers1.dta, dataspillovers2.dta. Before running the codes (either individually or via runAll.sh), you need to define where those large datasets will be stored in your computer by updating the paths in the respective codes (read_data.m, ts_analysis.m, spillovers.do). 


## Code Workflow (Optional)
Most data in Matlab are stored in a structure array of countries with different fields; the information in key fields is stored as a timetable (a Matlab data type). Below are details to facilitate following the workflow of the codes.

In the Pre-Analysis folder, read_data.m -> generates dataset_daily (approx. runtime: 30 min)
- read_platforms	-> tickers from Bloomberg and Datastream
- read_usyc	-> data from GSW and H.15
- fwd_prm		-> short- and long-term forward premia
- zc_yields	-> par converted into zero-coupon yields
- spreads		-> CIP deviations, yield spreads (LC, FC)
- read_cip		-> load DIS dataset
- plot_spreads	-> plot (term structure of) spreads
- compare_cip	-> compare own spreads vs DIS

variable types in header_daily: RHO, LCNOM, LCSYNT, LCSPRD, CIPDEV, FCSPRD

auxiliary m-files: compare_tbills, compare_ycs, compare_fx

In the Analysis folder, ts_analysis.m -> generates structure with data in fields (approx. runtime: 2 hrs)
- daily2dymy	-> extract monthly data
- add_macroNsvys	-> add macro and survey data
- append_svys2ylds	-> combine yield and survey data
- atsm_estimation 	-> estimate model w/ and w/o survey data, nominal & synthetic YCs
- se_components	-> compute standard errors using the delta method
- (post-estimation)-> assess_fit, add_vars, ts_plots, ts_correlations, ts_pca
- atsm_daily	-> estimate model w/ daily data
- construct_panel 	-> construct panel dataset

auxiliary m-files: read_macrovars, read_kw

'dataset_daily' contains yield curves (LC, FC, US), forward premiums, spreads (LC, FC, LC-US) for different maturities with DAILY frequency. All series run top-down old-new, series were appended to the RIGHT. Series are identified with a filter over header_daily

'dataset_monthly' contains synthetic LC yield curves, expected short rates, term premia, LCCS for different maturities with MONTHLY frequency. Series run top-down old-new, series were appended BELOW (since series start at different times). Series are identified with a filter over header_monthly
