program split_dataarr_by_kt

    integer                         ::  ifin, ifout
    character*1                     ::  init
    character*2                     ::  ckt
    character*120                    ::  fnin, fnout
    real                            ::  delta = 5.0
    integer                         ::  nxi, nyi, nchi, npredi
    integer                         ::  nxo, nyo, ncho, npredo
    integer*4                         ::  i,j,ich,ikt,ikx, ct
    integer                         ::  maxchan = 999

    real*8,dimension(:,:,:,:),allocatable :: dataarr, dataout


    call getarg(1,fnin)


    ifin = 100

    open(ifin,file=fnin,form='unformatted',convert='big_endian')
    read(ifin)nxi,nyi,nchi,npredi
    print *,nxi,nyi,nchi,npredi

    allocate(dataarr(nxi,nyi,nchi,npredi))
    allocate(dataout(nxi,nyi,maxchan,npredi))

    read(ifin)dataarr

    close(ifin)
    
    ifout = 101
    do ikt=1,nchi/1000
       print *,ikt,nchi/1000
      
       ct = 0   
       dataout(:,:,:,:) = 0
       do ikx=1,maxchan
          ich = ikt * 1000 + ikx
          if (ich < nchi) then 
             dataout(:,:,ikx,:) = dataarr(:,:,ich,:)
             do i=1,nxi
                do j=1,nyi
                   ct = ct + dataarr(i,j,ich,1)
                enddo
             enddo
          endif
       enddo

       if (ct > 0) then
          write(ckt,fmt='((I2.2))')ikt
          fnout = trim(fnin) // '.' // ckt
          print *,'writing ',fnout
          open(ifout,file=trim(fnout),form='unformatted',convert='big_endian')
          write(ifout)nxi,nyi,maxchan,npredi
          write(ifout)dataout
          close(ifout)
       endif
     enddo

end

!
!        open(ifout,file=fnout,form='unformatted',convert='big_endian')
!        read(ifout)nxo,nyo,ncho,npredo
!
!        if (nxi .ne. nxo .or. nyi .ne. nyo .or. nchi .ne. ncho .or. npredi .ne. npredo) then
!            print *,'size mismatch, dying'
!            print *,' indim=',nxi,nyi,nchi,npredi
!            print *,'outdim=',nxo,nyo,ncho,npredo
!            print *,' fnin=',fnin
!            print *,'fnout=',fnout
!            call abort
!        endif
!
!        allocate(aggarr(nxi,nyi,nchi,npredi))
!        read(ifout)aggarr
!        close(ifout)
!
!    endif
!
!
!    aggarr = aggarr + dataarr
!
!    open(ifout,file=trim(fnout),form='unformatted',convert='big_endian')
!    write(ifout)nxo,nyo,ncho,npredo
!    write(ifout)aggarr
!    close(ifout)
!end    
