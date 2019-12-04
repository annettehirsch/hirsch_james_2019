load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; File Name : regrid_wald_nci.ncl

; Purpose :

; Creation Date : 15-03-2019

; Last Modified : Mon Mar 18 15:12:52 2019

; Created By : Jatin Kala (Jatin.Kala.JK@gmail.com)

begin
;--------------------- Inputs -------------------------
diri = "/g/data/hh5/tmp/WRF-CABLE/AUS44/"
dir_WALD = "/g/data/hh5/tmp/WRF-CABLE/AUS44/scripts/tmp/" 
diro_name = "postprocess/" 
dx = 152 
dy = 223
dt = 1096
syear = 2008
eyear = 2010
fdum_lmask = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r") ; to get land mask only
wald_suffix = "AUS_W3v2.LE.20" 
;------------------------------------------------------

;create output file aready
dir_write = diri + diro_name 
system("mkdir -p " + dir_write)
file_write = dir_write + "WALD_regrid_daily_" + syear + "_" + eyear + ".nc"
system("rm -f " + file_write)
;print(file_write)
fo = addfile(file_write,"c")
delete(file_write)
filedimdef(fo,(/"time","lat","lon"/),(/dt,dx,dy/),(/False,False,False/))

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

; get wald data and regrid to WRF domain
files = systemfunc("ls -1 " + dir_WALD + wald_suffix + "*.nc")  
fhfls_wald = addfiles(files, "r")
time_wald = cd_calendar(fhfls_wald[:]->time,-5)
year_wald = time_wald(:,0)
month_wald = time_wald(:,1)
wald_lat = fhfls_wald[0]->latitude(::-1)
wald_lon = fhfls_wald[0]->longitude
wald_hfls_readin = fhfls_wald[:]->LE(:,::-1,:)
wald_hfls_readin!0 = "time"
wald_hfls_readin!1 = "lat"
wald_hfls_readin!2 = "lon"
delete(wald_hfls_readin@missing_value)
print(dimsizes(wald_lat))
print(dimsizes(wald_lon))
wald_hfls_regrid = rgrid2rcm(wald_lat,wald_lon,wald_hfls_readin(time|:,lat|:,lon|:),wrf_lat2d,wrf_lon2d,0)
delete(fhfls_wald)
delete(wald_hfls_readin)

;fatal:rgrid2rcm: The rightmost dimensions of fi must be nlat1d x nlon1d, where nlat1d and nlon1d are the dimensions of the lat1d/lon1d arrays


wald_hfls_mask = mask(wald_hfls_regrid,lmask,1)

wald_hfls_mask!0 = "time"
wald_hfls_mask!1 = "lat"
wald_hfls_mask!2 = "lon"
filevardef(fo,"wald_hfls_mask",typeof(wald_hfls_mask),getvardims(wald_hfls_mask))
filevarattdef(fo,"wald_hfls_mask",wald_hfls_mask)
fo->wald_hfls_mask = (/wald_hfls_mask/)
delete(wald_hfls_mask)


end ; this ends begin
