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
    times = tostring(fi->time)

    ; Get start/end month indexes 
    dtime_map = (/4,2,2,2,2/)
    tst_dtime = str_split_by_length(times, dtime_map)
    years = tst_dtime(:,0)
    months = tointeger(tst_dtime(:,1))
    days = tointeger(tst_dtime(:,2))

    ; Get the indexes of the different months-years
    yind0 = 0
    mind0 = 0
    dind0 = 0
    do while(yind0.ne.dimsizes(years).and.mind0.ne.dimsizes(months)-shift.and.dind0.ne.dimsizes(days))
      if (isvar("err")) then
	delete(err)
      end if
      month_ind = ind(years.eq.years(yind0).and.months.eq.months(mind0).and.days.eq.days(dind0))
      starting = month_ind(0)
      ending   = month_ind(dimsizes(month_ind)-1)+shift
      print("Create file for month: "+months(starting))
      cmd = "ncks -O -d time,"+starting+","+ending+" "+file_list(nf)+" "+filename+"_d"+tostring_with_format(nf+1,"%0.2i")+"_"+years(starting)+"-"+tostring_with_format(months(starting),"%0.2i")+"-"+tostring_with_format(days(starting),"%0.2i")
      err = systemfunc(cmd)
      if (.not.ismissing(err)) then
        print(err)
        exit
      end if
      mind0 = toint(ending)+1-shift
      dind0 = toint(ending)+1
      if (months(starting).eq.12) then
        yind0 = toint(ending)+1-shift
      end if 
      delete(month_ind)
    end do

    delete(fi)
    delete(times)
    delete(months)
    delete(years)
    delete(days)
    delete(dtime_map)
    delete(tst_dtime)

  end do

  return(err)
end

begin

  inputdir = "/g/data/hh5/tmp/WRF-CABLE/AUS44/scripts/tmp/" 
  print("Input directory is: "+inputdir)
  strict = True  ; Do not include 00 from next month
  err = cut_files(inputdir+"lisout",strict)

end
