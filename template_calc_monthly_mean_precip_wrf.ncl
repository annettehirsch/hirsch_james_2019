load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; File Name : calc_monthly_mean_precip.ncl

; Purpose :

; Creation Date : 18-03-2019

; Last Modified : Wed Mar 20 12:23:32 2019

; Created By : Jatin Kala (Jatin.Kala.JK@gmail.com)

begin
;--------------------- Inputs -------------------------
diri = "/g/data/hh5/tmp/WRF-CABLE/AUS44/"
expt = "PHYSMEMBER"
diro_name = "postprocess/" 
dx = 152 
dy = 223
smon = FIRSTMONTH
syear = FIRSTYEAR
eyear = LASTYEAR
fdum_lmask = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r") ; to get land mask only
;------------------------------------------------------
;create output file aready
dir_write = diri + diro_name 
system("mkdir -p " + dir_write)
file_write = dir_write + expt + "_WRF_Precip_" + syear + "_" + eyear + ".nc"
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

wrf_precip = new((/eyear-syear+1,12,dx,dy/),float)


cc = 0
mind = smon

do yy = syear,eyear,1

   print("Processing: " + yy)
   ll_wrfout = systemfunc("ls " + diri + "/scripts/tmp/wrfout_d01_" + yy + "*")
   ;print(ll_wrfout)
   do i = 0,dimsizes(ll_wrfout)-1,1
         print("  Opening: " + ll_wrfout(i))
         f = addfile(ll_wrfout(i),"r")
         RAINC = f->RAINC
         RAINNC = f->RAINNC
         dsize_array = dimsizes(RAINC)
         RAINC_total = RAINC(dsize_array(0)-1,:,:) - RAINC(0,:,:)
         delete(RAINC)
         RAINNC_total = RAINNC(dsize_array(0)-1,:,:) - RAINNC(0,:,:)
         delete(RAINNC)
         ; find number of days in month to convert to mm/day
         no_days = tofloat(days_in_month(yy,i+1))
         ;print(no_days)
         if (mind.gt.12) then
           mind = 1
         end if 
         wrf_precip(cc,mind-1,:,:) = (RAINNC_total + RAINC_total)/no_days
         delete([/f,dsize_array,RAINNC_total,RAINC_total/])
         mind = mind + 1
   end do

   cc = cc + 1
   mind = 1
   delete(ll_wrfout)


end do

; mask wrf arrays
wrf_precip_mask = mask(wrf_precip,lmask,1)
delete(wrf_precip)

wrf_precip_mask!0 = "years"
wrf_precip_mask!1 = "months"
wrf_precip_mask!2 = "lat"
wrf_precip_mask!3 = "lon"
filevardef(fo,"wrf_precip_mask",typeof(wrf_precip_mask),getvardims(wrf_precip_mask))
filevarattdef(fo,"wrf_precip_mask",wrf_precip_mask)
fo->wrf_precip_mask = (/wrf_precip_mask/)
delete(wrf_precip_mask)

end ; this ends begin
