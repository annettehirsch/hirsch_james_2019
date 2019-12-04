load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "./lambert_grid_plot_functions.ncl"

; File Name : plot_wrfext_awap_all_years.ncl

; Purpose :

; Creation Date : 15-03-2019

; Last Modified : Wed Mar 20 12:53:28 2019

; Created By : Jatin Kala (Jatin.Kala.JK@gmail.com)

begin
;--------------------- Inputs -------------------------
diri = "/g/data/hh5/tmp/WRF-CABLE/AUS44/"
fdum = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_RA1_PBL1_CU1/WRF_output/wrfout_d01_2008-08-01_00:00:00","r")
res = True
resP = True
type = "pdf"
col_map = "BlAqGrWh2YeOrReVi22"
include_wheatbelt = 0
dir_figs = diri + "postprocess/figures/"
panel_x = 4
panel_y = 3

; Colormap for fractional parameters
frac_map = "t2m_29lev"
cnMinLevelValF_frac = 0.0
cnMaxLevelValF_frac = 1.0
cnLevelSpacingF_frac = 0.05

; Colormap for soil parameters
mrso_map = "precip4_diff_19lev"
cnMinLevelValF_mrso = 0.0
cnMaxLevelValF_mrso = 0.5
cnLevelSpacingF_mrso = 0.025

; Colormap for LAI parameters
lai_map = "t2m_29lev"
cnMinLevelValF_lai = 0.0
cnMaxLevelValF_lai = 4.0
cnLevelSpacingF_lai = 0.1

cnMinLevelValF = -10.0
cnMaxLevelValF = 10.0
cnLevelSpacingF = 0.5
lbTitleString = "(~S~o~N~C)"
cnMinLevelValF_precip = -15.0
cnMaxLevelValF_precip = 15.0
cnLevelSpacingF_precip = 0.5

tiMainString = (/"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"/)
lbOn = True 
lat_plot = ispan(30,105,1)
lon_plot = ispan(38,127,1)
;------------------------------------------------------

; Read in the parameters to plot

f_lisinput = addfile(diri + "PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r")
sand_frac = f_lisinput->SAND(lat_plot,lon_plot)
clay_frac = f_lisinput->CLAY(lat_plot,lon_plot)
silt_frac = f_lisinput->SILT(lat_plot,lon_plot)
lai_monthly = f_lisinput->LAI(:,lat_plot,lon_plot)
landcover = f_lisinput->LANDCOVER(:,lat_plot,lon_plot)
landmask = f_lisinput->LANDMASK(lat_plot,lon_plot)
wrf_lat2d = f_lisinput->lat(lat_plot,lon_plot)
wrf_lon2d = f_lisinput->lon(lat_plot,lon_plot)
delete(f_lisinput)

f_lis4real = addfile(diri + "PHYS_TEST_MASTER/bdy_data/lis4real_input.d01.nc","r")
soil_type = f_lis4real->Soiltype(lat_plot,lon_plot)
delete(f_lis4real)

; Define the STATSGO soil parameters

nsoil = 16
swilt = (/0.010,0.028,0.047,0.084,0.084,0.066,0.067,0.120,0.103,0.100,0.126,0.138,0.066,0.000,0.006,0.028/)
sfc = (/0.236,0.283,0.312,0.360,0.360,0.329,0.314,0.387,0.382,0.338,0.404,0.412,0.329,0.000,0.108,0.283/)
ssat = (/0.339,0.421,0.434,0.476,0.476,0.439,0.404,0.464,0.465,0.406,0.468,0.468,0.439,1.000,0.200,0.421/)
bch = (/ 2.79,4.26,4.74,5.33,5.33,5.25,6.66,8.72,8.17,10.73,10.39,11.55,5.25,0.0,2.79,4.26/)
;hyds = (/1.07E-6,1.41E-5,5.23E-6,2.81E-6,2.81E-6,3.38E-6,4.45E-6,2.04E-6,2.45E-6,7.22E-6,1.34E-6,9.74E-7,3.38E-6,0.00E+0,1.41E-4,1.41E-5/)
sucs = (/-0.069,-0.036,-0.141,-0.759,-0.759,-0.355,-0.135,-0.617,-0.263,-0.098,-0.324,-0.468,-0.355,-0.000,-0.069,-0.036/)

; Map soil parameters using soil type classification

dx = dimsizes(lat_plot)
dy = dimsizes(lon_plot)
swilt_map = new((/dx,dy/),float) 
sfc_map = new((/dx,dy/),float) 
ssat_map = new((/dx,dy/),float)
do ss = 0,nsoil-1,1
  swilt_map = where(soil_type.eq.(ss+1),swilt(ss),swilt_map)
  sfc_map = where(soil_type.eq.(ss+1),sfc(ss),sfc_map)
  ssat_map = where(soil_type.eq.(ss+1),ssat(ss),ssat_map)
end do
;mask ocean points
swilt_map_mask = mask(swilt_map,landmask,1)
sfc_map_mask = mask(sfc_map,landmask,1)
ssat_map_mask = mask(ssat_map,landmask,1)

; Plot monthly invariant parameters

file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Monthly_LAI"
murdoch_plot_lambert_panel_scale(fdum,res,resP,type,lai_map,file_save,lai_monthly,wrf_lat2d,wrf_lon2d,tiMainString,"LAI",include_wheatbelt,panel_x,panel_y,"WRF-LIS-CABLE Invariant Parameter",cnMinLevelValF_lai,cnMaxLevelValF_lai,cnLevelSpacingF_lai,lbOn)

; Plot invariant parameters

; Sand fraction
file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Sand_Fraction"
murdoch_plot_lambert_single(fdum,res,type,frac_map,file_save,sand_frac,wrf_lat2d,wrf_lon2d,"WRF-LIS-CABLE Invariant Parameter","STATSGO Sand Fraction",include_wheatbelt,cnMinLevelValF_frac,cnMaxLevelValF_frac,cnLevelSpacingF_frac)

; Silt fraction
file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Silt_Fraction"
murdoch_plot_lambert_single(fdum,res,type,frac_map,file_save,silt_frac,wrf_lat2d,wrf_lon2d,"WRF-LIS-CABLE Invariant Parameter","STATSGO Silt Fraction",include_wheatbelt,cnMinLevelValF_frac,cnMaxLevelValF_frac,cnLevelSpacingF_frac)

; Clay fraction
file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Clay_Fraction"
murdoch_plot_lambert_single(fdum,res,type,frac_map,file_save,clay_frac,wrf_lat2d,wrf_lon2d,"WRF-LIS-CABLE Invariant Parameter","STATSGO Clay Fraction",include_wheatbelt,cnMinLevelValF_frac,cnMaxLevelValF_frac,cnLevelSpacingF_frac)

; Swilt
file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Swilt"
murdoch_plot_lambert_single(fdum,res,type,mrso_map,file_save,swilt_map_mask,wrf_lat2d,wrf_lon2d,"WRF-LIS-CABLE Invariant Parameter","Mapped STATSGO Wilting Point",include_wheatbelt,cnMinLevelValF_mrso,cnMaxLevelValF_mrso,cnLevelSpacingF_mrso)

; Sfc
file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Sfc"
murdoch_plot_lambert_single(fdum,res,type,mrso_map,file_save,sfc_map_mask,wrf_lat2d,wrf_lon2d,"WRF-LIS-CABLE Invariant Parameter","Mapped STATSGO Field Capacity",include_wheatbelt,cnMinLevelValF_mrso,cnMaxLevelValF_mrso,cnLevelSpacingF_mrso)

; Ssat
file_save = dir_figs + "WRF-LIS-CABLE_Invariant_Parameter_Ssat"
murdoch_plot_lambert_single(fdum,res,type,mrso_map,file_save,ssat_map_mask,wrf_lat2d,wrf_lon2d,"WRF-LIS-CABLE Invariant Parameter","Mapped STATSGO Saturation",include_wheatbelt,cnMinLevelValF_mrso,cnMaxLevelValF_mrso,cnLevelSpacingF_mrso)

end ; this ends begin
