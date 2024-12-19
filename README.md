# [Term Premia and Credit Risk in Emerging Markets: The Role of U.S. Monetary Policy](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3973655)

by Pavel Solís (pavel.solis@gmail.com)


## System Features
The results in the paper were generated using the following:
- Operating systems: macOS 12.2.1, Windows 10 Enterprise.
- Software: Matlab R2019a, Stata 17.
- Add-ons. Matlab: financial toolboxes. Stata: xtcsd, xtscc.ado*, scheme-modern.
- Restricted data sources: Bloomberg, Datastream.
- Expected running time. Data reading: 30 mins. ATSM estimation: 6 hrs. Local projections: 2 hrs.

\* In the file xtscc.ado, comment out section `Check if dataset's timevar is regularly spaced` (lines 74-83) because `tab timevar` gives the error `too many variables`. Type `which xtscc` in Stata to find the location of the xtscc.ado file.


## Contents of Folder
- README.txt (this file).
- LICENSE: Open-source license for the repository.
- Codes folder with the following subfolders:
	- Pre-Analysis. Codes that clean and process the original data files.
	- Analysis. Replication codes.
- Data folder with the following subfolders:
	- Raw. Original data files.
	- Analytic. Analysis data files.
- Docs folder with the following subfolders: 
	- Paper. Source files for the manuscript and the online appendix.
	- Figures. Figures used in the paper and the online appendix.


## Instructions for Replication
Execute the files Docs/Paper/paper.tex and Docs/Paper/online.tex to generate the PDF version of the manuscript and the online appendix.

The contents of several original data files in the Data/Raw folder cannot be shared due to licensing rights or due to size limits but the file Data/MetadataGuide.docx documents the steps to access the data sources. In case the user has access to the data sources, simply execute the Codes/Pre-Analysis/read_data.m file to read the original data files and generate the analysis data file Data/Analytic/yc_data.mat; beware that it creates dta files that might be too large for version control.

Execute the files Codes/Analysis/ts_analysis.m and Codes/Analysis/spillovers.do to replicate the figures and tables in the paper and the online appendix; comments in those codes indicate the lines that generate each figure and table.
- Codes/Analysis/ts_analysis.m loads the data file Data/Analytic/yc_data.mat, computes the decompositions of the yield curves of the countries in the sample at the monthly and daily frequency, and generates the data files Data/Analytic/yc_decompositions.mat and Data/Analytic/dataspillovers.xlsx.
- Codes/Analysis/spillovers.do loads the data file Data/Analytic/dataspillovers.xlsx and performs the spillover analysis.
