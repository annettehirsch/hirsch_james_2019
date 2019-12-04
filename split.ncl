load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; To cut wrfbdy and wrflowinp files into monthly files.
; It will correctly take into account the 00am time
; of the next month (included in wrflowinp but excluded
; in wrfbdy)
; Adapted to cut the wrfout and wrfxtrm 


undef("cut_files")
function cut_files(filename:string,strict:logical)
; It will cut the input files into monthly files
; filename: root of the file (wrfbdy or wrflowinp)
; strict: If True does not include the extra 00am at the end
begin
  shift = 1
  if (strict) then
    shift = 0 
  end if

  file_list = systemfunc("ls "+filename+"_d??")

  ; Read times in netcdf file
  do nf=0,dimsizes(file_list)-1
    fi = addfile(file_list(nf)+".nc","r")
    
    ; Get Times variable
    times = wrf_user_getvar(fi, "times",-1)

    ; Get start/end month indexes 
    delim = "-"
    months = str_get_field(times,2,delim)
    years  = str_get_field(times,1,delim)
    ; Get the indexes of the different months-years
    yind0 = 0
    mind0 = 0
    do while(yind0.ne.dimsizes(years).and.mind0.ne.dimsizes(months)-shift)
      if (isvar("err")) then
	delete(err)
      end if
      month_ind = ind(years.eq.years(yind0).and.months.eq.months(mind0))
      starting = month_ind(0)
      ending   = month_ind(dimsizes(month_ind)-1)+shift
      print("Create file for month: "+months(starting))
      cmd = "ncks -O -d Time,"+starting+","+ending+" "+file_list(nf)+" "+filename+"_d"+tostring_with_format(nf+1,"%0.2i")+"_"+years(starting)+"-"+months(starting)
      err = systemfunc(cmd)
      if (.not.ismissing(err)) then
        print(err)
        exit
      end if
      mind0 = toint(ending)+1-shift
      if (months(starting).eq.12) then
        yind0 = toint(ending)+1-shift
      end if 
      delete(month_ind)
    end do

    delete(fi)
    delete(times)
    delete(months)
    delete(years)

  end do

  return(err)
end

begin

  inputdir = "/g/data/hh5/tmp/WRF-CABLE/AUS44/scripts/tmp/" 
  print("Input directory is: "+inputdir)
  strict = True  ; Do not include 00 from next month
  err = cut_files(inputdir+"wrfout",strict)
  err = cut_files(inputdir+"wrfxtrm",strict)

end
