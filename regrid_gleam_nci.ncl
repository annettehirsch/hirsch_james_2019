load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; File Name : regrid_gleam_nci.ncl

; Purpose :

; Creation Date : 15-03-2019

; Last Modified : Mon Mar 18 15:12:52 2019

; Created By : Jatin Kala (Jatin.Kala.JK@gmail.com)

begin
;--------------------- Inputs -------------------------
diri = "/g/data/hh5/tmp/WRF-CABLE/AUS44/"
dir_GLEAM = "/g/data/hh5/tmp/WRF-CABLE/AUS44/scripts/tmp/" 
diro_name = "postprocess/" 
dx = 152 
dy = 223
syear = 2008
eyear = 2010
fdum_lmask = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r") ; to get land mask only
gleam_suffix = "GLEAM_v3.2b_monthly_2008-2010.nc" 
;------------------------------------------------------

;create output file aready
dir_write = diri + diro_name 
system("mkdir -p " + dir_write)
file_write = dir_write + "GLEAM_regrid_" + syear + "_" + eyear + ".nc"
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

; get hfls data
gleam_hfls = new((/eyear-syear+1,12,dx,dy/),float)

; get gleam data and regrid to WRF domain
fhfls_gleam = addfile(dir_GLEAM + "E_" + gleam_suffix, "r")
time_gleam = cd_calendar(fhfls_gleam->time,-5)
year_gleam = time_gleam(:,0)
month_gleam = time_gleam(:,1)
gleam_lat = fhfls_gleam->lat(::-1)
gleam_lon = fhfls_gleam->lon
gleam_hfls_readin = doubletofloat((/fhfls_gleam->E(:,:,::-1)/))*2500000./86400.
gleam_hfls_readin!0 = "time"
gleam_hfls_readin!1 = "lon"
gleam_hfls_readin!2 = "lat"
delete(gleam_hfls_readin@missing_value)
gleam_hfls_regrid = rgrid2rcm(gleam_lat,gleam_lon,gleam_hfls_readin(time|:,lat|:,lon|:),wrf_lat2d,wrf_lon2d,0)
delete(fhfls_gleam)
delete(gleam_hfls_readin)

cc = 0

do yy = syear,eyear,1

   print("Processing: " + yy)
   ; get gleam
    ind_gleam = ind(year_gleam .eq. yy)
    gleam_hfls(cc,:,:,:) = gleam_hfls_regrid(ind_gleam,:,:)
    delete(ind_gleam)
    cc = cc + 1
end do

gleam_hfls_mask = mask(gleam_hfls,lmask,1)
delete(gleam_hfls)

gleam_hfls_mask!0 = "years"
gleam_hfls_mask!1 = "months"
gleam_hfls_mask!2 = "lat"
gleam_hfls_mask!3 = "lon"
filevardef(fo,"gleam_hfls_mask",typeof(gleam_hfls_mask),getvardims(gleam_hfls_mask))
filevarattdef(fo,"gleam_hfls_mask",gleam_hfls_mask)
fo->gleam_hfls_mask = (/gleam_hfls_mask/)
delete(gleam_hfls_mask)


end ; this ends begin
