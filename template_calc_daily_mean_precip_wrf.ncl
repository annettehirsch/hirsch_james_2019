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
dt = 822
smon = FIRSTMONTH
emon = NUMMONTHYEARS
syear = FIRSTYEAR
eyear = LASTYEAR
fdum_lmask = addfile("/g/data/hh5/tmp/WRF-CABLE/AUS44/PHYS_TEST_MASTER/bdy_data/lis_input.d01.nc","r") ; to get land mask only
;------------------------------------------------------
;create output file aready
dir_write = diri + diro_name 
system("mkdir -p " + dir_write)
file_write = dir_write + expt + "_WRF_Precip_daily_" + syear + "_" + eyear + ".nc"
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

wrf_precip = new((/dt,dx,dy/),float)


tt = 0
mind = smon
yymm = 0

do yy = syear,eyear,1

  do while(mind.le.12.and.yymm.lt.emon)

   mstr = tostring_with_format(mind,"%0.2i")
   print("Processing: " + yy + "-" + mstr)
   ll_wrfout = systemfunc("ls " + diri + "/scripts/tmp/wrfout_d01_" + yy + "-" + mstr + "-*")
  
   do i = 0,dimsizes(ll_wrfout)-1,1

         ;print("  Opening: " + ll_wrfout(i))
         f = addfile(ll_wrfout(i),"r")
         RAINC = f->RAINC
         RAINNC = f->RAINNC
         dsize_array = dimsizes(RAINC)
         RAINC_total = RAINC(dsize_array(0)-1,:,:) - RAINC(0,:,:)
         delete(RAINC)
         RAINNC_total = RAINNC(dsize_array(0)-1,:,:) - RAINNC(0,:,:)
         delete(RAINNC)
         wrf_precip(tt,:,:) = (RAINNC_total + RAINC_total)
         delete([/f,dsize_array,RAINNC_total,RAINC_total/])
         tt = tt + 1

    end do ; do i = 0,dimsizes(ll_wrfout)-1,1

    mind = mind + 1
    yymm = yymm + 1

   delete(ll_wrfout)
 
   end do ;do while(mind.le.12)

   mind = 1

end do ; do yy = syear,eyear,1

; mask wrf arrays
wrf_precip_mask = mask(wrf_precip,lmask,1)
delete(wrf_precip)

wrf_precip_mask!0 = "time"
wrf_precip_mask!1 = "lat"
wrf_precip_mask!2 = "lon"
filevardef(fo,"wrf_precip_mask",typeof(wrf_precip_mask),getvardims(wrf_precip_mask))
filevarattdef(fo,"wrf_precip_mask",wrf_precip_mask)
fo->wrf_precip_mask = (/wrf_precip_mask/)
delete(wrf_precip_mask)

end ; this ends begin
