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
file_write = dir_write + expt + "_lisout_daily_" + syear + "_" + eyear + ".nc"
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

lis_hfls = new((/dt,dx,dy/),float)
lis_hfss = new((/dt,dx,dy/),float)
lis_albedo = new((/dt,dx,dy/),float)
lis_mrso = new((/dt,dx,dy/),float)


tt = 0
mind = smon
yymm = 0

do yy = syear,eyear,1

  do while(mind.le.12.and.yymm.lt.emon)

   mstr = tostring_with_format(mind,"%0.2i")
   print("Processing: " + yy + "-" + mstr)
   ll_lisout = systemfunc("ls " + diri + "/scripts/tmp/lisout_d01_" + yy + "-" + mstr + "-*")
  
   do i = 0,dimsizes(ll_lisout)-1,1

         ;print("  Opening: " + ll_lisout(i))
         f = addfile(ll_lisout(i),"r")
         dim_var = getfilevardimsizes(f,"Qle_tavg")
         vname = "Qle_tavg"
         lis_hfls(tt,:,:) = dim_avg_n(f->$vname$,0) 
         vname = "Qh_tavg"
         lis_hfss(tt,:,:) = dim_avg_n(f->$vname$,0) 
         vname = "Albedo_inst"
         lis_albedo(tt,:,:) = dim_avg_n(f->$vname$,0) 
         ;vname = "SoilMoist_inst"
         ;totalmrso = 1000 * (f->$vname$(0:dim_var(0)-1,0,:,:))*0.022 + (f->$vname$(0:dim_var(0)-1,1,:,:))*0.058 + (f->$vname$(0:dim_var(0)-1,2,:,:))*0.154  + (f->$vname$(0:dim_var(0)-1,3,:,:))*0.409  + (f->$vname$(0:dim_var(0)-1,4,:,:))*1.085  + (f->$vname$(0:dim_var(0)-1,5,:,:))*2.872
         ;lis_mrso(tt,:,:) = dim_avg_n(totalmrso,0)
         ;delete([/f,dim_var,totalmrso/])
         vname = "SoilWet_inst"
         lis_mrso(tt,:,:) = dim_avg_n(f->$vname$,0)
         delete([/f,dim_var/])
         tt = tt + 1

    end do ; do i = 0,dimsizes(ll_lisout)-1,1

    mind = mind + 1
    yymm = yymm + 1

   delete(ll_lisout)
 
   end do ;do while(mind.le.12)

   mind = 1

end do ; do yy = syear,eyear,1

; mask wrf arrays
lis_hfls_mask = mask(lis_hfls,lmask,1)
delete(lis_hfls)
lis_hfss_mask = mask(lis_hfss,lmask,1)
delete(lis_hfss)
lis_albedo_mask = mask(lis_albedo,lmask,1)
delete(lis_albedo)
lis_mrso_mask = mask(lis_mrso,lmask,1)
delete(lis_mrso)

lis_hfls_mask!0 = "time"
lis_hfls_mask!1 = "lat"
lis_hfls_mask!2 = "lon"
filevardef(fo,"lis_hfls_mask",typeof(lis_hfls_mask),getvardims(lis_hfls_mask))
filevarattdef(fo,"lis_hfls_mask",lis_hfls_mask)
fo->lis_hfls_mask = (/lis_hfls_mask/)
delete(lis_hfls_mask)

lis_hfss_mask!0 = "time"
lis_hfss_mask!1 = "lat"
lis_hfss_mask!2 = "lon"
filevardef(fo,"lis_hfss_mask",typeof(lis_hfss_mask),getvardims(lis_hfss_mask))
filevarattdef(fo,"lis_hfss_mask",lis_hfss_mask)
fo->lis_hfss_mask = (/lis_hfss_mask/)
delete(lis_hfss_mask)

lis_albedo_mask!0 = "time"
lis_albedo_mask!1 = "lat"
lis_albedo_mask!2 = "lon"
filevardef(fo,"lis_albedo_mask",typeof(lis_albedo_mask),getvardims(lis_albedo_mask))
filevarattdef(fo,"lis_albedo_mask",lis_albedo_mask)
fo->lis_albedo_mask = (/lis_albedo_mask/)
delete(lis_albedo_mask)

lis_mrso_mask!0 = "time"
lis_mrso_mask!1 = "lat"
lis_mrso_mask!2 = "lon"
filevardef(fo,"lis_mrso_mask",typeof(lis_mrso_mask),getvardims(lis_mrso_mask))
filevarattdef(fo,"lis_mrso_mask",lis_mrso_mask)
fo->lis_mrso_mask = (/lis_mrso_mask/)
delete(lis_mrso_mask)

end ; this ends begin
