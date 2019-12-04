# hirsch_james_2019

Repository of Analysis Code for the Manuscript entitled: "Evaluation of the CABLEv2.3.4 land surface model coupled to NU-WRFv3.9.1.1 in simulating temperature and precipitation means and extremes over CORDEX AustralAsia within a WRF physics ensemble" Hirsch et al. in Journal of Advances in Modeling Earth Systems

This repository contains all the analysis source code for Hirsch et al., 2019 (2019MS001845R) and can be used to reproduce the analysis of the manuscript. Note that all directory paths will need to be updated for successful implementation of the code.

Datasets to which the code applies:

- WRF-LIS-CABLE simulations for the CORDEX AustralAsia domain on a 0.44˚ x 0.44˚ rotated coordinate system for the period Oct. 2008 to Oct 2010. All data will be published via the Australian National Computational Infrastructure (NCI)
- Australian Gridded Climate Data (AGCD) daily precipitation and temperature dataset [Jones et al. 2009 Australia. Aust. Meteor. Mag.]      
- Global Land surface Evaporation: the Amsterdam Methodology (GLEAM) dataset [Miralles et al. 2011, doi:10.5194/hess-15-453-2011; Martens et al. 2017, doi:10.5194/gmd-10-1903-2017]
- Global 5 km resolution estimates of evaporation [van Dijk et al. 2018, doi:10.5194/hess-22-4959-2018].

This repository provides all the tools to process each dataset, evaluate WRF-LIS-CABLE simulation skill using the International Land Model Benchmarking (ILAMB) system [Collier et al. 2018 doi:10.1029/2018MS001354], and produce the figures corresponding to the manuscript.

Further information on the datasets and calculations are available from: Hirsch, A. L., J. Kala, C. C. Carouge, M. G. De Kauwe, G. Di Virgillio, A. M. Ukkola, J. P. Evans, and G. Abramowitz (2019), Evaluation of the CABLEv2.3.4 land surface model coupled to NU-WRFv3.9.1.1 in simulating temperature and precipitation means and extremes over CORDEX AustralAsia within a WRF physics ensemble. Journal of Advances in Modeling Earth Systems, accepted 26.11.2019.  

Scripts used to prepare the data

- process_monthly.pbs - to process the model output to compute monthly means
- process_daily.pbs - to process the wrfxtrm model output 
- process_daily_wrfout.pbs - to process the wrfout model output files
- process_daily_lisout.pbs - to process the wrfout model output files
- regrid_awap_nci.ncl - from Jatin to regrid the AWAP data
- regrid_gleam_nci.ncl - adapted Jatin’s AWAP script to work for GLEAM data
- regrid_wald_et_nci_daily.ncl - adapted Jatin’s AWAP script to work for vD18 data
- template_calc_daily_mean_lisout.ncl
- template_calc_daily_mean_precip_wrf.ncl
- template_calc_monthly_mean_lisout.ncl
- template_calc_monthly_mean_precip_wrf.ncl
- template_calc_monthly_mean_wrfxtrm.ncl
- plot.pbs - to plot the monthly mean biases of pr, tmax and tmin
- plot_lis_invariant_parameters.ncl - to plot the topography and land cover used in the WRF-LIS-CABLE simulations

Python scripts

- common_functions.py - contains functions to calculate the ILAMB skill metrics

Notebooks to plot results:

1. plot_skill.ipynb = plots the ILAMB skill scores for each configuration - add the longer spinup and the soil snow comparison
2. plot_skill_lsm.ipynb = plots the ILAMB skill scores for each configuration - to compare WRF-LIS-CABLE and WRF-Noah simulations
3. plot_contour_skill.ipynb = plots contour maps of obs, obs error, ensemble mean bias, fraction within obs error for key periods of the simulation
4. plot_skill_boxplots.ipynb = boxplots constructed from the spatial biases of each ensemble grouped by sub region, variable and physics (PBL, RA or CU)
5. plot_event_time_series.ipynb = 1 year sub-region time series that includes obs, ensemble range and top performers
6. plot_lsm_time_series.ipynb = 1 year sub-region time series that includes obs, ensemble range and top performers - to compare WRF-LIS-CABLE and WRF-Noah simulations
7. plot_point_time_series.ipynb = 1 year sub-region time series that includes obs, ensemble range and top performers - to compare WRF-LIS-CABLE output to Flux Tower data









