load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; File Name : calc_regrid_monthly_mean_lisxtrm.ncl

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
file_write = dir_write + expt + "_lisout_" + syear + "_" + eyear + ".nc"
system("rm -f " + file_write)
;print(file_write)
fo = addfile(file_write,"c")
delete(file_write)
filedimdef(fo,(/"years","months","lat","lon"/),(/eyear-syear+1,12,dx,dy/),(/False,False,False,False/))

lmask = fdum_lmask->LANDMASK
lis_lat2d = fdum_lmask->lat
lis_lon2d = fdum_lmask->lon
;print(dimsizes(lmask))

lis_lat2d!0 = "lat"
lis_lat2d!1 = "lon"
lis_lon2d!0 = "lat"
lis_lon2d!1 = "lon"

filevardef(fo,"lis_lat2d",typeof(lis_lat2d),getvardims(lis_lat2d))
filevarattdef(fo,"lis_lat2d",lis_lat2d)
fo->lis_lat2d = (/lis_lat2d/)

filevardef(fo,"lis_lon2d",typeof(lis_lon2d),getvardims(lis_lon2d))
filevarattdef(fo,"lis_lon2d",lis_lon2d)
fo->lis_lon2d = (/lis_lon2d/)

lis_hfls = new((/eyear-syear+1,12,dx,dy/),float)
lis_albedo = new((/eyear-syear+1,12,dx,dy/),float)
lis_mrso = new((/eyear-syear+1,12,dx,dy/),float)

cc = 0

mind = smon
do yy = syear,eyear,1

   print("Processing: " + yy)

   ; shift mm by the start month

   ; get lis files
   ll_lisxtrm = systemfunc("ls " + diri + expt + "/LIS_output/LIS.CABLE." + yy + "??0100.d01.nc")
   do i = 0,dimsizes(ll_lisxtrm)-1,1

       print("  Processing: " + ll_lisxtrm(i))
       f = addfile(ll_lisxtrm(i),"r")
       dim_var = getfilevardimsizes(f,"Qle_tavg")
       if (mind.gt.12) then            
         mind = 1
       end if

       vname = "Qle_tavg"
       lis_hfls(cc,mind-1,:,:) = dim_avg_n(f->$vname$(0:dim_var(0)-1,:,:),0)
       vname = "Albedo_inst"
       lis_albedo(cc,mind-1,:,:) = dim_avg_n(f->$vname$(0:dim_var(0)-1,:,:),0)
       vname = "SoilMoist_inst"
       totalmrso = 1000 * (f->$vname$(0:dim_var(0)-1,0,:,:))*0.022 + (f->$vname$(0:dim_var(0)-1,1,:,:))*0.058 + (f->$vname$(0:dim_var(0)-1,2,:,:))*0.154  + (f->$vname$(0:dim_var(0)-1,3,:,:))*0.409  + (f->$vname$(0:dim_var(0)-1,4,:,:))*1.085  + (f->$vname$(0:dim_var(0)-1,5,:,:))*2.872
       lis_mrso(cc,mind-1,:,:) = dim_avg_n(totalmrso,0)
       delete(totalmrso)

      mind = mind + 1
   
      delete([/f,dim_var/])   

   end do
  
   cc = cc + 1
   mind = 1
   delete(ll_lisxtrm)

end do

; mask lis arrays
lis_hfls_mask = mask(lis_hfls,lmask,1)
lis_albedo_mask = mask(lis_albedo,lmask,1)
lis_mrso_mask = mask(lis_mrso,lmask,1)
delete(lis_hfls)
delete(lis_albedo)
delete(lis_mrso)

lis_hfls_mask!0 = "years"
lis_hfls_mask!1 = "months"
lis_hfls_mask!2 = "lat"
lis_hfls_mask!3 = "lon"
filevardef(fo,"lis_hfls_mask",typeof(lis_hfls_mask),getvardims(lis_hfls_mask))
filevarattdef(fo,"lis_hfls_mask",lis_hfls_mask)
fo->lis_hfls_mask = (/lis_hfls_mask/)
delete(lis_hfls_mask)

lis_albedo_mask!0 = "years"
lis_albedo_mask!1 = "months"
lis_albedo_mask!2 = "lat"
lis_albedo_mask!3 = "lon"
filevardef(fo,"lis_albedo_mask",typeof(lis_albedo_mask),getvardims(lis_albedo_mask))
filevarattdef(fo,"lis_albedo_mask",lis_albedo_mask)
fo->lis_albedo_mask = (/lis_albedo_mask/)
delete(lis_albedo_mask)

lis_mrso_mask!0 = "years"
lis_mrso_mask!1 = "months"
lis_mrso_mask!2 = "lat"
lis_mrso_mask!3 = "lon"
filevardef(fo,"lis_mrso_mask",typeof(lis_mrso_mask),getvardims(lis_mrso_mask))
filevarattdef(fo,"lis_mrso_mask",lis_mrso_mask)
fo->lis_mrso_mask = (/lis_mrso_mask/)
delete(lis_mrso_mask)


print("Script sucessfully finished")

end ; this ends begin
