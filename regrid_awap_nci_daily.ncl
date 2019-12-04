load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; File Name : regrid_awap_nci.ncl

; Purpose :

; Creation Date : 15-03-2019

; Last Modified : Mon Mar 18 15:12:52 2019

; Created By : Jatin Kala (Jatin.Kala.JK@gmail.com)

begin
;--------------------- Inputs -------------------------
diri = "/g/data/hh5/tmp/WRF-CABLE/AUS44/"
dir_AWAP = "/g/data/hh5/tmp/WRF-CABLE/AUS44/scripts/tmp/" 
diro_name = "postprocess/" 
dx = 133 ; 152 = CABLE and 133 for AUS44i 
dy = 238 ; 223 = CABLE and 238 for AUS44i
dt = 1096
syear = 2008
eyear = 2010
;fdum_lmask = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r") ; to get land mask only
; For WRF-Noah mask
fdum_lmask = addfile("/g/data3/w97/azh561/analysis/cordex_australasia/scripts/geo_em_files/geo_em.AUS-44i.nc","r")
awap_suffix = "daily_0.05.2008-2010.nc" 
;awap_suffix = "rmse_daily_0.05.2008-2010.nc" 
;------------------------------------------------------

;create output file aready
dir_write = diri + diro_name 
system("mkdir -p " + dir_write)
;file_write = dir_write + "AWAP_regrid_daily_" + syear + "_" + eyear + ".nc"
;file_write = dir_write + "AWAP_rmse_regrid_daily_" + syear + "_" + eyear + ".nc"
file_write = dir_write + "AWAP_NOAH_regrid_daily_" + syear + "_" + eyear + ".nc"
system("rm -f " + file_write)
;print(file_write)
fo = addfile(file_write,"c")
delete(file_write)
filedimdef(fo,(/"time","lat","lon"/),(/dt,dx,dy/),(/False,False,False/))

lmask = fdum_lmask->LANDMASK
wrf_lat2d = fdum_lmask->lat
wrf_lon2d = fdum_lmask->lon
; For Noah
wrf_lon2d = where(wrf_lon2d.lt.0,wrf_lon2d+360,wrf_lon2d)

print(wrf_lat2d)
;wrf_lat2d!0 = "lat"
;wrf_lat2d!1 = "lon"
;wrf_lon2d!0 = "lat"
;wrf_lon2d!1 = "lon"

filevardef(fo,"wrf_lat2d",typeof(wrf_lat2d),getvardims(wrf_lat2d))
filevarattdef(fo,"wrf_lat2d",wrf_lat2d)
fo->wrf_lat2d = (/wrf_lat2d/)

filevardef(fo,"wrf_lon2d",typeof(wrf_lon2d),getvardims(wrf_lon2d))
filevarattdef(fo,"wrf_lon2d",wrf_lon2d)
fo->wrf_lon2d = (/wrf_lon2d/)

; get awap data and regrid to WRF domain
ftmax_awap = addfile(dir_AWAP + "tmax_" + awap_suffix, "r")
time_awap = cd_calendar(ftmax_awap->time,-5)
year_awap = time_awap(:,0)
month_awap = time_awap(:,1)
; For variable
awap_lat = ftmax_awap->lat
awap_lon = ftmax_awap->lon
awap_tmax = (ftmax_awap->tmax) - 273.15
; For obs error
;awap_lat = ftmax_awap->latitude
;awap_lon = ftmax_awap->longitude
;awap_tmax = (ftmax_awap->tmax_mask)

;awap_tmax_regrid = rgrid2rcm(awap_lat,awap_lon,awap_tmax,wrf_lat2d,wrf_lon2d,1)
awap_tmax_regrid = linint2(awap_lon,awap_lat,awap_tmax,False,wrf_lon2d,wrf_lat2d,0) ; For Noah
delete(ftmax_awap)
delete(awap_tmax)

ftmin_awap = addfile(dir_AWAP + "tmin_" + awap_suffix, "r")
awap_tmin = (ftmin_awap->tmin) - 273.15
;awap_tmin = (ftmin_awap->tmin_mask)
;awap_tmin_regrid = rgrid2rcm(awap_lat,awap_lon,awap_tmin,wrf_lat2d,wrf_lon2d,1)
awap_tmin_regrid = linint2(awap_lon,awap_lat,awap_tmin,False,wrf_lon2d,wrf_lat2d,0) ; For Noah
delete(ftmin_awap)
delete(awap_tmin)

fprecip_awap = addfile(dir_AWAP + "rr_" + awap_suffix,"r")
;fprecip_awap = addfile(dir_AWAP + "precip_" + awap_suffix,"r")
time_awap = cd_calendar(fprecip_awap->time,-5)
year_awap = time_awap(:,0)
month_awap = time_awap(:,1)
awap_rr = fprecip_awap->rr
;awap_rr = fprecip_awap->precip_mask
;awap_rr_regrid = rgrid2rcm(awap_lat,awap_lon,awap_rr,wrf_lat2d,wrf_lon2d,1)
awap_rr_regrid = linint2(awap_lon,awap_lat,awap_rr,False,wrf_lon2d,wrf_lat2d,0) ; For Noah
delete(fprecip_awap)
delete(awap_rr)

awap_t2max_mask = mask(awap_tmax_regrid,lmask,1)
awap_t2min_mask = mask(awap_tmin_regrid,lmask,1)
awap_precip_mask = mask(awap_rr_regrid,lmask,1)

awap_t2max_mask!0 = "time"
awap_t2max_mask!1 = "lat"
awap_t2max_mask!2 = "lon"
filevardef(fo,"awap_t2max_mask",typeof(awap_t2max_mask),getvardims(awap_t2max_mask))
filevarattdef(fo,"awap_t2max_mask",awap_t2max_mask)

; RMSE variable does not have leap day 29FEB2008
;awap_t2max_leap = new((/dt,dx,dy/),float)
;awap_t2max_leap(0:58,:,:) = awap_t2max_mask(0:58,:,:)
;awap_t2max_leap(60:,:,:) = awap_t2max_mask(59:,:,:)
;fo->awap_t2max_mask = (/awap_t2max_leap/)
fo->awap_t2max_mask = (/awap_t2max_mask/)
delete(awap_t2max_mask)

awap_t2min_mask!0 = "time"
awap_t2min_mask!1 = "lat"
awap_t2min_mask!2 = "lon"
filevardef(fo,"awap_t2min_mask",typeof(awap_t2min_mask),getvardims(awap_t2min_mask))
filevarattdef(fo,"awap_t2min_mask",awap_t2min_mask)

; RMSE variable does not have leap day 29FEB2008
;awap_t2min_leap = new((/dt,dx,dy/),float)
;awap_t2min_leap(0:58,:,:) = awap_t2min_mask(0:58,:,:)
;awap_t2min_leap(60:,:,:) = awap_t2min_mask(59:,:,:)
;fo->awap_t2min_mask = (/awap_t2min_leap/)
fo->awap_t2min_mask = (/awap_t2min_mask/)
delete(awap_t2min_mask)

awap_precip_mask!0 = "time"
awap_precip_mask!1 = "lat"
awap_precip_mask!2 = "lon"
filevardef(fo,"awap_precip_mask",typeof(awap_precip_mask),getvardims(awap_precip_mask))
filevarattdef(fo,"awap_precip_mask",awap_precip_mask)
fo->awap_precip_mask = (/awap_precip_mask/)
delete(awap_precip_mask)


end ; this ends begin
