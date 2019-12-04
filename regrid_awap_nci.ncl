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
;dir_AWAP = "/g/data1/rr7/AWAP/others/monthly_mean_0.05/"
dir_AWAP = "/g/data/hh5/tmp/WRF-CABLE/AUS44/scripts/tmp/" 
diro_name = "postprocess/" 
dx = 152 
dy = 223
syear = 2008
eyear = 2010
fdum_lmask = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r") ; to get land mask only
awap_suffix = "monthly_0.05.2000-2010.nc" 
;------------------------------------------------------

;create output file aready
dir_write = diri + diro_name 
system("mkdir -p " + dir_write)
file_write = dir_write + "AWAP_regrid_" + syear + "_" + eyear + ".nc"
system("rm -f " + file_write)
;print(file_write)
fo = addfile(file_write,"c")
delete(file_write)
filedimdef(fo,(/"years","months","lat","lon"/),(/eyear-syear+1,12,dx,dy/),(/False,False,False,False/))

lmask = fdum_lmask->LANDMASK
wrf_lat2d = fdum_lmask->lat
wrf_lon2d = fdum_lmask->lon
;print(dimsizes(lmask))

wrf_lat2d!0 = "lat"
wrf_lat2d!1 = "lon"
wrf_lon2d!0 = "lat"
wrf_lon2d!1 = "lon"

filevardef(fo,"wrf_lat2d",typeof(wrf_lat2d),getvardims(wrf_lat2d))
filevarattdef(fo,"wrf_lat2d",wrf_lat2d)
fo->wrf_lat2d = (/wrf_lat2d/)

filevardef(fo,"wrf_lon2d",typeof(wrf_lon2d),getvardims(wrf_lon2d))
filevarattdef(fo,"wrf_lon2d",wrf_lon2d)
fo->wrf_lon2d = (/wrf_lon2d/)

; get precip data
awap_precip = new((/eyear-syear+1,12,dx,dy/),float)
awap_t2max = new((/eyear-syear+1,12,dx,dy/),float)
awap_t2min = new((/eyear-syear+1,12,dx,dy/),float)

; get awap data and regrid to WRF domain
ftmax_awap = addfile(dir_AWAP + "tmax_" + awap_suffix, "r")
time_awap = cd_calendar(ftmax_awap->time,-5)
year_awap = time_awap(:,0)
month_awap = time_awap(:,1)
awap_lat = ftmax_awap->lat
awap_lon = ftmax_awap->lon
awap_tmax = (ftmax_awap->tmax) - 273.15
awap_tmax_regrid = rgrid2rcm(awap_lat,awap_lon,awap_tmax,wrf_lat2d,wrf_lon2d,1)
delete(ftmax_awap)
delete(awap_tmax)

ftmin_awap = addfile(dir_AWAP + "tmin_" + awap_suffix, "r")
awap_tmin = (ftmin_awap->tmin) - 273.15
awap_tmin_regrid = rgrid2rcm(awap_lat,awap_lon,awap_tmin,wrf_lat2d,wrf_lon2d,1)
delete(ftmin_awap)
delete(awap_tmin)

fprecip_awap = addfile(dir_AWAP + "rr_" + awap_suffix,"r")
awap_rr = fprecip_awap->rr
awap_rr_regrid = rgrid2rcm(awap_lat,awap_lon,awap_rr,wrf_lat2d,wrf_lon2d,1)
delete(fprecip_awap)
delete(awap_rr)

cc = 0

do yy = syear,eyear,1

   print("Processing: " + yy)
   ; get awap
    ind_awap = ind(year_awap .eq. yy)
    awap_t2max(cc,:,:,:) = awap_tmax_regrid(ind_awap,:,:)
    awap_t2min(cc,:,:,:) = awap_tmin_regrid(ind_awap,:,:)
    awap_precip(cc,:,:,:) = awap_rr_regrid(ind_awap,:,:)
    delete(ind_awap)
    cc = cc + 1
end do

awap_t2max_mask = mask(awap_t2max,lmask,1)
delete(awap_t2max)
awap_t2min_mask = mask(awap_t2min,lmask,1)
delete(awap_t2min)
awap_precip_mask = mask(awap_precip,lmask,1)
delete(awap_precip)

awap_t2max_mask!0 = "years"
awap_t2max_mask!1 = "months"
awap_t2max_mask!2 = "lat"
awap_t2max_mask!3 = "lon"
filevardef(fo,"awap_t2max_mask",typeof(awap_t2max_mask),getvardims(awap_t2max_mask))
filevarattdef(fo,"awap_t2max_mask",awap_t2max_mask)
fo->awap_t2max_mask = (/awap_t2max_mask/)
delete(awap_t2max_mask)

awap_t2min_mask!0 = "years"
awap_t2min_mask!1 = "months"
awap_t2min_mask!2 = "lat"
awap_t2min_mask!3 = "lon"
filevardef(fo,"awap_t2min_mask",typeof(awap_t2min_mask),getvardims(awap_t2min_mask))
filevarattdef(fo,"awap_t2min_mask",awap_t2min_mask)
fo->awap_t2min_mask = (/awap_t2min_mask/)
delete(awap_t2min_mask)

awap_precip_mask!0 = "years"
awap_precip_mask!1 = "months"
awap_precip_mask!2 = "lat"
awap_precip_mask!3 = "lon"
filevardef(fo,"awap_precip_mask",typeof(awap_precip_mask),getvardims(awap_precip_mask))
filevarattdef(fo,"awap_precip_mask",awap_precip_mask)
fo->awap_precip_mask = (/awap_precip_mask/)
delete(awap_precip_mask)


end ; this ends begin
