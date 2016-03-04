program process_diag

    use read_diag,only:read_radiag_header, diag_header_fix_list, diag_header_chan_list, diag_data_name_list
    use read_diag,only:read_radiag_data, diag_data_fix_list, diag_data_extra_list, diag_data_chan_list

    type(diag_header_fix_list )          ::  headfix
    type(diag_header_chan_list),pointer  ::  headchan(:)
    type(diag_data_name_list)            ::  headname
    type(diag_data_fix_list)             ::  datafix
    type(diag_data_chan_list)  ,pointer  ::  datachan(:)
    type(diag_data_extra_list) ,pointer  ::  dataextra(:,:)

    integer                         ::  ifin, iflag
    character*120                    ::  fn
    real                            ::  delta = 5.0
    integer                         ::  nx, ny, nch
    integer                         ::  ix, iy, ich

    integer,parameter               ::  ict      = 1
    integer,parameter               ::  iomfbbc  = 2
    integer,parameter               ::  iomfbnbc = 3
    integer,parameter               ::  ipr1     = 4
    integer,parameter               ::  ipr2     = 5
    integer,parameter               ::  ipr3     = 6
    integer,parameter               ::  ipr4     = 7
    integer,parameter               ::  ipr5     = 8
    integer,parameter               ::  ipr6     = 9
    integer,parameter               ::  isigo    = 10
    integer,parameter               ::  npred    = 10 !total # of things above

    real :: clat, clon
    integer :: counter 

    real,dimension(:,:,:,:),allocatable :: dataarr

    integer,parameter                    ::  nllun = 53
    integer                              ::  iversion = -9999
    logical                              ::  debug = .false.
    character*80                         ::  nlfn = './process_diag.nl'

    namelist /nlconfig/ debug, iversion

    inquire(file=nlfn, exist=lnamelist)
  
    if (lnamelist) then
      open(nllun,file=nlfn)
      read(nllun,nml=nlconfig)
      close(nllun)
    endif


    nx = 360.0 / delta
    ny = 180.0 / delta

    call getarg(1,fn)

    ifin = 100
    open(ifin,file=fn,form='unformatted',convert='big_endian')

    iflag = 0
    call read_radiag_header( ifin, 5, .false., headfix, headchan, headname, iflag, .true. )

    if (iversion .gt. 0) then
      write(*,*)'BE AWARE THAT iversion IS BEING OVERRIDEN!'
      write(*,*)' iversion diag, override=',headfix%iversion,iversion
      write(*,*)' (this was made necessary w/ emis bc...hopefully only temporary)'
      headfix%iversion = iversion
    endif


    nch = headfix%nchan
    allocate(dataarr(nx,ny,nch,npred))
    dataarr = 0.0

    counter = 0

    do while (iflag .ge. 0) ! iflag == 0 means the end of the file
       call read_radiag_data  ( ifin, headfix, .false., datafix, datachan, &
                                 dataextra, iflag )
       if (iflag .lt. 0) cycle

       clat = datafix%lat
       clon = datafix%lon
       counter = counter + 1 

       print *,clat,clon

       ix = datafix%lon / delta + 1
       iy = (datafix%lat + 90.0) / delta + 1
       do ich=1,nch
           if (datachan(ich)%qcmark .eq. 0 .and. headchan(ich)%iuse .ge. 1) then
               dataarr(ix,iy,ich,ict)      = dataarr(ix,iy,ich,ict) + 1.0
               dataarr(ix,iy,ich,iomfbbc)  = dataarr(ix,iy,ich,iomfbbc) + datachan(ich)%omgbc
               dataarr(ix,iy,ich,iomfbnbc) = dataarr(ix,iy,ich,iomfbnbc) + datachan(ich)%omgnbc
               dataarr(ix,iy,ich,ipr1) = dataarr(ix,iy,ich,ipr1) + datachan(ich)%bicons
               dataarr(ix,iy,ich,ipr2) = dataarr(ix,iy,ich,ipr2) + datachan(ich)%bifix(1)
               dataarr(ix,iy,ich,ipr3) = dataarr(ix,iy,ich,ipr3) + datachan(ich)%biang
               dataarr(ix,iy,ich,ipr4) = dataarr(ix,iy,ich,ipr4) + datachan(ich)%bilap
               dataarr(ix,iy,ich,ipr5) = dataarr(ix,iy,ich,ipr5) + datachan(ich)%bilap2
               dataarr(ix,iy,ich,ipr6) = dataarr(ix,iy,ich,ipr6) + datachan(ich)%biclw
               dataarr(ix,iy,ich,isigo) = dataarr(ix,iy,ich,isigo) + (1.0 / datachan(ich)%errinv)
           endif
       enddo
    enddo

    open(101,file=trim(fn) // '.dataarr',form='unformatted',convert='big_endian')
    write(101)nx,ny,nch,npred
    write(101)dataarr

    print *,counter,iflag,clon,clat
end    
