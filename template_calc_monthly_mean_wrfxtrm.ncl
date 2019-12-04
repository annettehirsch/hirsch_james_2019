load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; File Name : calc_regrid_monthly_mean_wrfxtrm.ncl

; Purpose :

; Creation Date : 15-03-2019

; Last Modified : Wed Mar 20 12:50:03 2019

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
file_write = dir_write + expt + "_WRFext_Temps_" + syear + "_" + eyear + ".nc"
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

wrf_t2max = new((/eyear-syear+1,12,dx,dy/),float)
wrf_t2min = new((/eyear-syear+1,12,dx,dy/),float)

cc = 0

mind = smon
do yy = syear,eyear,1

   print("Processing: " + yy)

   ; shift mm by the start month

   ; get wrf files
   ll_wrfxtrm = systemfunc("ls " + diri + "/scripts/tmp/wrfxtrm_d01_" + yy + "-*")
   do i = 0,dimsizes(ll_wrfxtrm)-1,1

       print("  Processing: " + ll_wrfxtrm(i))
       f = addfile(ll_wrfxtrm(i),"r")
       dim_var = getfilevardimsizes(f,"T2MAX")
       if (mind.gt.12) then            
         mind = 1
       end if
       wrf_t2max(cc,mind-1,:,:) = dim_avg_n(f->T2MAX(0:dim_var(0)-1,:,:),0)
       wrf_t2min(cc,mind-1,:,:) = dim_avg_n(f->T2MIN(0:dim_var(0)-1,:,:),0)
       mind = mind + 1
 ;  
      delete([/f,dim_var/])   
   end do
  
   cc = cc + 1
   mind = 1
   delete(ll_wrfxtrm)

end do
; mask wrf arrays
wrf_t2max_mask = mask(wrf_t2max,lmask,1)
delete(wrf_t2max)
wrf_t2min_mask = mask(wrf_t2min,lmask,1)
delete(wrf_t2min)

wrf_t2max_mask!0 = "years"
wrf_t2max_mask!1 = "months"
wrf_t2max_mask!2 = "lat"
wrf_t2max_mask!3 = "lon"
filevardef(fo,"wrf_t2max_mask",typeof(wrf_t2max_mask),getvardims(wrf_t2max_mask))
filevarattdef(fo,"wrf_t2max_mask",wrf_t2max_mask)
fo->wrf_t2max_mask = (/wrf_t2max_mask/)
delete(wrf_t2max_mask)

wrf_t2min_mask!0 = "years"
wrf_t2min_mask!1 = "months"
wrf_t2min_mask!2 = "lat"
wrf_t2min_mask!3 = "lon"
filevardef(fo,"wrf_t2min_mask",typeof(wrf_t2min_mask),getvardims(wrf_t2min_mask))
filevarattdef(fo,"wrf_t2min_mask",wrf_t2min_mask)
fo->wrf_t2min_mask = (/wrf_t2min_mask/)
delete(wrf_t2min_mask)

print("Script sucessfully finished")

end ; this ends begin
