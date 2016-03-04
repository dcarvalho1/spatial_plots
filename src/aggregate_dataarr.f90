program process_diag

    integer                         ::  ifin, ifout
    character*1                     ::  init
    character*120                    ::  fnin, fnout
    real                            ::  delta = 5.0
    integer                         ::  nxi, nyi, nchi, npredi
    integer                         ::  nxo, nyo, ncho, npredo

    real*8,dimension(:,:,:,:),allocatable :: dataarr, aggarr


    call getarg(1,fnout)
    call getarg(2,fnin)
    call getarg(3,init)


    ifin = 100

    open(ifin,file=fnin,form='unformatted',convert='big_endian')
    read(ifin)nxi,nyi,nchi,npredi

    allocate(dataarr(nxi,nyi,nchi,npredi))

    read(ifin)dataarr
    close(ifin)
    
    ifout = 101

    if (init .eq. 'T') then
        nxo = nxi
        nyo = nyi
        ncho=nchi
        npredo=npredi

        print *,nxo,nyo,ncho,npredo

        allocate(aggarr(nxi,nyi,nchi,npredi))
        aggarr = 0.0
    else
        open(ifout,file=fnout,form='unformatted',convert='big_endian')
        read(ifout)nxo,nyo,ncho,npredo

        if (nxi .ne. nxo .or. nyi .ne. nyo .or. nchi .ne. ncho .or. npredi .ne. npredo) then
            print *,'size mismatch, dying'
            print *,' indim=',nxi,nyi,nchi,npredi
            print *,'outdim=',nxo,nyo,ncho,npredo
            print *,' fnin=',fnin
            print *,'fnout=',fnout
            call abort
        endif

        allocate(aggarr(nxi,nyi,nchi,npredi))
        read(ifout)aggarr
        close(ifout)

    endif


    aggarr = aggarr + dataarr

    open(ifout,file=trim(fnout),form='unformatted',convert='big_endian')
    write(ifout)nxo,nyo,ncho,npredo
    write(ifout)aggarr
    close(ifout)
end    
