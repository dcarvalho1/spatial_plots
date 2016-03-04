program process_ods

    use m_ods

    integer                         ::  ifin

    character*120                    ::  fn
    character*80  ftype

    real                            ::  delta = 5.0
    integer                         ::  nx, ny !, nch
    integer                         ::  ix, iy, ich

    integer,parameter               ::  ict      = 1
    integer,parameter               ::  iimp  = 2
    integer,parameter               ::  iomf  = 3
    integer,parameter               ::  npred    = 3 !total # of things above

    real*8,dimension(:,:,:,:),allocatable :: dataarr, dataout

    integer                         ::  nch = 99999

    integer                         ::  itime, nymd, nhms, nobs, ierr

    integer                         ::  maxchan

    type(ods_vect)                  ::  ods

    nx = 360.0 / delta
    ny = 180.0 / delta

    call getarg(1,fn)

    allocate(dataarr(nx,ny,nch,npred))


    maxchan = -99999

    do itime=1,32767
      nymd = -1            ! get data for next synoptic time on file
      nhms =  0
      call ODSNxTime ( trim(fn), nymd, nhms )
      print *,nymd,nhms
      if ( nymd .eq. -1 ) then
        print *, 'End-Of-File'
        exit
      end if 

      call ODS_Get ( trim(fn), nymd, nhms, ftype, ods, ierr )

      nobs = ods%data%nobs
      print *,nobs

      ich = 1
!      maxchan = 1

      do i=1,nobs
!        print *,i,ods%data%lev(i),ods%data%lon(i),ods%data%lat(i),ods%data%qcexcl(i)
!        ich = ods%data%lev(i)
!        if (ich .gt. maxchan) maxchan = ich
        ich  = ods%data%kt(i)*1000 + ods%data%kx(i)
        if (ich > maxchan) maxchan = ich
        clat = ods%data%lat(i)
        clon = ods%data%lon(i)
        if (clon .lt. 0.000) then
           clon = 360. + clon
        endif
        ix = clon / delta + 1
        iy = (clat + 90.0) / delta + 1
!        print *,ich,ix,clon,iy
        if (ods%data%qcexcl(i) .eq. 0) then
!          print *,ods%data%xvec(i)
          dataarr(ix,iy,ich,ict)      = dataarr(ix,iy,ich,ict) + 1.0
          dataarr(ix,iy,ich,iimp)  = dataarr(ix,iy,ich,iimp) + ods%data%xvec(i)
          dataarr(ix,iy,ich,iomf)  = dataarr(ix,iy,ich,iomf) + ods%data%omf(i)
        endif
      enddo
    enddo

    allocate(dataout(nx,ny,maxchan,npred))
    do i=1,maxchan
      dataout(:,:,i,:) = dataarr(:,:,i,:)
    enddo

    open(101,file=trim(fn) // '.dataarr',form='unformatted',convert='big_endian')
    write(101)nx,ny,maxchan,npred
    print *,nx,ny,maxchan,npred

    write(101)dataout


end program process_ods
