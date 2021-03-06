!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! 22/03/2013                                                                !!
!!                           cc_aux_func.f90                                 !!
!!                                                                           !!
!!  auxiliary functions                                                      !!
!!  -- j0                                                                !!
!!  -- I0                                                                !!
!!  -- gamma0                                                                !!
!!  -- j1                                                                    !!
!!  -- I1                                                                !!
!!  -- gamma1                                                                !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                                                           !!
!!                                  aux_func                                  !!
!!                                                                           !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Module containing auxiliary functions
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
MODULE aux_func
  IMPLICIT NONE

CONTAINS

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                   j0                                      !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Computes the J0 Bessel function
!!
!!   This routine is based on caljy0 of the specfun package
!!   http://people.sc.fsu.edu/~jburkardt/f_src/specfun/specfun.f90
!!   which is freely available under GNU license
!!
!!   Original authors: William Cody
!!   Original reference: John Hart, Ward Cheney, Charles Lawson, Hans Maehly
!!          Charles Mesztenyi, John Rice, Henry Thatcher, Christoph Witzgall,
!!          Computer Approximations, Wiley, 1968, LC: QA297.C64.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  FUNCTION bessel0 ( arg )
    IMPLICIT NONE

    INTEGER (kind = 4) i
    REAL :: arg, bessel0
    REAL(kind = 8) :: ax, down
    REAL(kind = 8) :: prod, r0, r1, up, w, wsq
    REAL(kind = 8) :: xden, xnum, z, zsq

    !  Mathematical constants
    REAL(kind = 8), PARAMETER ::  pi2 = 6.3661977236758134308d-1
    REAL(kind = 8), PARAMETER ::  twopi  = 6.2831853071795864769d0
    REAL(kind = 8), PARAMETER ::  twopi1 = 6.28125d0
    REAL(kind = 8), PARAMETER ::  twopi2 = 1.9353071795864769253d-3

    !  Machine-dependent constants
    REAL(kind = 8) :: xmax  = 1.07d+09
    REAL(kind = 8) :: xsmall = 9.31d-10

    !  Zeroes of Bessel functions
    REAL(kind = 8), PARAMETER :: xj0 = 2.4048255576957727686d+0
    REAL(kind = 8), PARAMETER :: xj1 = 5.5200781102863106496d+0
    REAL(kind = 8), PARAMETER :: xj01 = 616.0d+0
    REAL(kind = 8), PARAMETER :: xj02 = -1.4244423042272313784d-03
    REAL(kind = 8), PARAMETER :: xj11 = 1413.0d+0
    REAL(kind = 8), PARAMETER :: xj12 = 5.4686028631064959660d-04

    !  Coefficients for rational approximation of
    !  J0(X) / (X**2 - XJ0**2),  XSMALL < |X| <= 4.0
    REAL(kind = 8), PARAMETER, DIMENSION(7) ::  pj0 = &
         &(/6.6302997904833794242d+06,-6.2140700423540120665d+08, &
         &2.7282507878605942706d+10,-4.1298668500990866786d+11, &
         &-1.2117036164593528341d-01, 1.0344222815443188943d+02, &
         &-3.6629814655107086448d+04/)
    REAL(kind = 8), PARAMETER, DIMENSION(5) ::  qj0 = & 
         &(/4.5612696224219938200d+05, 1.3985097372263433271d+08, &
         &2.6328198300859648632d+10, 2.3883787996332290397d+12, &
         &9.3614022392337710626d+02/)

    !  Coefficients for rational approximation of
    !  J0(X) / (X**2 - XJ1**2), 4.0 < |X| <= 8.0
    REAL(kind = 8), PARAMETER, DIMENSION(8) ::  pj1 = &
         &(/4.4176707025325087628d+03, 1.1725046279757103576d+04, &
         &1.0341910641583726701d+04,-7.2879702464464618998d+03, &
         &-1.2254078161378989535d+04,-1.8319397969392084011d+03, &
         &4.8591703355916499363d+01, 7.4321196680624245801d+02/)
    REAL(kind = 8), PARAMETER, DIMENSION(7) ::  qj1 = &
         &(/3.3307310774649071172d+02,-2.9458766545509337327d+03, &
         &1.8680990008359188352d+04,-8.4055062591169562211d+04, &
         &2.4599102262586308984d+05,-3.5783478026152301072d+05, &
         &-2.5258076240801555057d+01/)

    !  Coefficients for Hart,s approximation, 8.0 < |X|.
    REAL(kind = 8), PARAMETER, DIMENSION(6) ::  p0 = &
         &(/3.4806486443249270347d+03, 2.1170523380864944322d+04, &
         &4.1345386639580765797d+04, 2.2779090197304684302d+04, &
         &8.8961548424210455236d-01, 1.5376201909008354296d+02/)
    REAL(kind = 8), PARAMETER, DIMENSION(5) ::  q0 = &
         &(/3.5028735138235608207d+03, 2.1215350561880115730d+04, &
         &4.1370412495510416640d+04, 2.2779090197304684318d+04, &
         &1.5711159858080893649d+02/)
    REAL(kind = 8), PARAMETER, DIMENSION(6) ::  p1 = &
         & (/-2.2300261666214198472d+01,-1.1183429920482737611d+02, &
         &-1.8591953644342993800d+02,-8.9226600200800094098d+01, &
         &-8.8033303048680751817d-03,-1.2441026745835638459d+00/)
    REAL(kind = 8), PARAMETER, DIMENSION(5) ::  q1 = &
         &(/1.4887231232283756582d+03, 7.2642780169211018836d+03, &
         &1.1951131543434613647d+04, 5.7105024128512061905d+03, &
         &9.0593769594993125859d+01/)

    xsmall = 2.0*EPSILON(xsmall)
    xmax = 0.5*HUGE(xmax)

    !  Check for error conditions.
    ax = abs ( arg )

    IF ( xmax < ax ) THEN

       bessel0 = 0.0
       RETURN

    ELSE IF ( ax <= xsmall ) THEN

       bessel0 = 1.0
       RETURN

    ELSE IF ( 8.0d0 < ax ) THEN

       !  Calculate J0 for 8.0 < |ARG|.
       z = 8.0d0 / ax
       w = ax / twopi
       w = aint ( w ) + 0.125d0
       w = ( ax - w * twopi1 ) - w * twopi2
       zsq = z * z
       xnum = p0(5) * zsq + p0(6)
       xden = zsq + q0(5)
       up = p1(5) * zsq + p1(6)
       down = zsq + q1(5)

       DO i = 1, 4
          xnum = xnum * zsq + p0(i)
          xden = xden * zsq + q0(i)
          up = up * zsq + p1(i)
          down = down * zsq + q1(i)
       END DO

       r0 = xnum / xden
       r1 = up / down

       bessel0 = REAL(sqrt ( pi2 / ax ) &
            * ( r0 * cos ( w ) - z * r1 * sin ( w ) ))
       RETURN

    ELSE 
       !  Calculate J0 for appropriate interval, preserving
       !  accuracy near the zero of J0.
       zsq = ax * ax

       IF ( ax <= 4.0d0 ) THEN
          xnum = ( pj0(5) * zsq + pj0(6) ) * zsq + pj0(7)
          xden = zsq + qj0(5)
          DO i = 1, 4
             xnum = xnum * zsq + pj0(i)
             xden = xden * zsq + qj0(i)
          END DO
          prod = ( ( ax - xj01 / 256.0d0 ) - xj02 ) * ( ax + xj0 )
       ELSE
          wsq = 1.0d0 - zsq / 64.0d0
          xnum = pj1(7) * wsq + pj1(8)
          xden = wsq + qj1(7)
          DO i = 1, 6
             xnum = xnum * wsq + pj1(i)
             xden = xden * wsq + qj1(i)
          END DO
          prod = ( ax + xj1 ) * ( ( ax - xj11 / 256.0d0 ) - xj12 )
       END IF

       bessel0 = REAL(prod * xnum / xden)

       RETURN
    END IF
  END FUNCTION bessel0



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                I0                                     !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Computes I0(x) the modified Bessel function
!!
!!  This routine is based on calci0 of the specfun package
!!  http://people.sc.fsu.edu/~jburkardt/f_src/specfun/specfun.f90
!!  which is freely available under GNU license
!!
!!  Original authors: William Cody, Laura Stoltz
!!  Original comment: The main computation evaluates slightly modified forms of
!!    minimax approximations generated by Blair and Edwards, Chalk
!!    River (Atomic Energy of Canada Limited) Report AECL-4928,October, 1974.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  FUNCTION bessel_mod0 ( arg )
    IMPLICIT NONE

    INTEGER(kind = 4) :: i
    REAL :: arg, bessel_mod0
    REAL(kind = 8) :: sump, sumq, x, xx

    !  Machine-dependent constants    
    REAL(kind = 8) :: xmax = 713.986d0
    REAL(kind = 8) :: xsmall = 5.55d-17
    REAL(kind = 8) :: xinf = 1.79d308

    !  Mathematical constants
    REAL(kind = 8), PARAMETER :: rec15 = 6.6666666666666666666d-2

    !  Coefficients for XSMALL <= ABS(ARG) < 15.0
    REAL(kind = 8),PARAMETER,DIMENSION(15) :: p = &
         (/-5.2487866627945699800d-18,-1.5982226675653184646d-14, &
         -2.6843448573468483278d-11,-3.0517226450451067446d-08, &
         -2.5172644670688975051d-05,-1.5453977791786851041d-02, &
         -7.0935347449210549190d+00,-2.4125195876041896775d+03, &
         -5.9545626019847898221d+05,-1.0313066708737980747d+08, &
         -1.1912746104985237192d+10,-8.4925101247114157499d+11, &
         -3.2940087627407749166d+13,-5.5050369673018427753d+14, &
         -2.2335582639474375249d+15/)
    REAL(kind = 8),PARAMETER,DIMENSION(5) :: q = &
         &(/-3.7277560179962773046d+03, 6.5158506418655165707d+06, &
         &-6.5626560740833869295d+09, 3.7604188704092954661d+12, &
         &-9.7087946179594019126d+14/)

    !  Coefficients for 15.0 <= ABS(ARG)
    REAL(kind = 8),PARAMETER,DIMENSION(8) :: pp = &
         &(/-3.9843750000000000000d-01, 2.9205384596336793945d+00, &
         &-2.4708469169133954315d+00, 4.7914889422856814203d-01, &
         &-3.7384991926068969150d-03,-2.6801520353328635310d-03, &
         &9.9168777670983678974d-05,-2.1877128189032726730d-06/)

    REAL(kind = 8),PARAMETER,DIMENSION(7) :: qq = &
         &(/-3.1446690275135491500d+01, 8.5539563258012929600d+01, &
         &-6.0228002066743340583d+01, 1.3982595353892851542d+01, &
         &-1.1151759188741312645d+00, 3.2547697594819615062d-02, &
         &-5.5194330231005480228d-04/)

    xsmall = 2.0*EPSILON(xsmall)
    xmax = 0.5*HUGE(xmax)

    x = abs ( arg )

    IF ( x < xsmall ) THEN

       bessel_mod0 = 1.0

    !  XSMALL <= ABS(ARG) < 15.0.
    ELSE IF ( x < 15.0d0 ) THEN

       xx = x * x
       sump = p(1)
       DO i = 2, 15
          sump = sump * xx + p(i)
       END DO
       xx = xx - 225.0d0

       sumq = (((( &
            xx + q(1) ) &
            * xx + q(2) ) &
            * xx + q(3) ) &
            * xx + q(4) ) &
            * xx + q(5)

       bessel_mod0 = REAL(sump / sumq )

    ELSE IF ( 15.0d0 <= x ) THEN

      if (xmax < x) then
          bessel_mod0 = xinf
      else
    !
    !    15.0 <= ABS(ARG).
    !   
       xx = 1.0d0 / x - rec15

       sump = (((((( &
            pp(1) &
            * xx + pp(2) ) &
            * xx + pp(3) ) &
            * xx + pp(4) ) &
            * xx + pp(5) ) &
            * xx + pp(6) ) &
            * xx + pp(7) ) &
            * xx + pp(8)

       sumq = (((((( &
            xx + qq(1) ) &
            * xx + qq(2) ) &
            * xx + qq(3) ) &
            * xx + qq(4) ) &
            * xx + qq(5) ) &
            * xx + qq(6) ) &
            * xx + qq(7)

       bessel_mod0 = REAL( sump / sumq )
       
      END IF
    END IF

  END function bessel_mod0

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                gamma0                                     !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Computes I0(x) * exp(-abs(x)) where I0 is the modified Bessel function
!!
!!  This routine is based on calci0 of the specfun package
!!  http://people.sc.fsu.edu/~jburkardt/f_src/specfun/specfun.f90
!!  which is freely available under GNU license
!!
!!  Original authors: William Cody, Laura Stoltz
!!  Original comment: The main computation evaluates slightly modified forms of
!!    minimax approximations generated by Blair and Edwards, Chalk
!!    River (Atomic Energy of Canada Limited) Report AECL-4928,October, 1974.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  FUNCTION gamma0 ( arg )
    IMPLICIT NONE

    INTEGER(kind = 4) :: i
    REAL :: arg, gamma0
    REAL(kind = 8) :: sump, sumq, x, xx

    !  Machine-dependent constants    
    REAL(kind = 8) :: xmax = 713.986d0
    REAL(kind = 8) :: xsmall = 5.55d-17

    !  Mathematical constants
    REAL(kind = 8), PARAMETER :: rec15 = 6.6666666666666666666d-2

    !  Coefficients for XSMALL <= ABS(ARG) < 15.0
    REAL(kind = 8),PARAMETER,DIMENSION(15) :: p = &
         (/-5.2487866627945699800d-18,-1.5982226675653184646d-14, &
         -2.6843448573468483278d-11,-3.0517226450451067446d-08, &
         -2.5172644670688975051d-05,-1.5453977791786851041d-02, &
         -7.0935347449210549190d+00,-2.4125195876041896775d+03, &
         -5.9545626019847898221d+05,-1.0313066708737980747d+08, &
         -1.1912746104985237192d+10,-8.4925101247114157499d+11, &
         -3.2940087627407749166d+13,-5.5050369673018427753d+14, &
         -2.2335582639474375249d+15/)
    REAL(kind = 8),PARAMETER,DIMENSION(5) :: q = &
         &(/-3.7277560179962773046d+03, 6.5158506418655165707d+06, &
         &-6.5626560740833869295d+09, 3.7604188704092954661d+12, &
         &-9.7087946179594019126d+14/)

    !  Coefficients for 15.0 <= ABS(ARG)
    REAL(kind = 8),PARAMETER,DIMENSION(8) :: pp = &
         &(/-3.9843750000000000000d-01, 2.9205384596336793945d+00, &
         &-2.4708469169133954315d+00, 4.7914889422856814203d-01, &
         &-3.7384991926068969150d-03,-2.6801520353328635310d-03, &
         &9.9168777670983678974d-05,-2.1877128189032726730d-06/)

    REAL(kind = 8),PARAMETER,DIMENSION(7) :: qq = &
         &(/-3.1446690275135491500d+01, 8.5539563258012929600d+01, &
         &-6.0228002066743340583d+01, 1.3982595353892851542d+01, &
         &-1.1151759188741312645d+00, 3.2547697594819615062d-02, &
         &-5.5194330231005480228d-04/)

    xsmall = 2.0*EPSILON(xsmall)
    xmax = 0.5*HUGE(xmax)

    x = abs ( arg )

    IF ( x < xsmall ) THEN

       gamma0 = 1.0

    !  XSMALL <= ABS(ARG) < 15.0.
    ELSE IF ( x < 15.0d0 ) THEN

       xx = x * x
       sump = p(1)
       DO i = 2, 15
          sump = sump * xx + p(i)
       END DO
       xx = xx - 225.0d0

       sumq = (((( &
            xx + q(1) ) &
            * xx + q(2) ) &
            * xx + q(3) ) &
            * xx + q(4) ) &
            * xx + q(5)

       gamma0 = REAL(sump / sumq * exp ( - x ))

    ELSE IF ( 15.0d0 <= x ) THEN
       !  15.0 <= ABS(ARG).
       xx = 1.0d0 / x - rec15

       sump = (((((( &
            pp(1) &
            * xx + pp(2) ) &
            * xx + pp(3) ) &
            * xx + pp(4) ) &
            * xx + pp(5) ) &
            * xx + pp(6) ) &
            * xx + pp(7) ) &
            * xx + pp(8)

       sumq = (((((( &
            xx + qq(1) ) &
            * xx + qq(2) ) &
            * xx + qq(3) ) &
            * xx + qq(4) ) &
            * xx + qq(5) ) &
            * xx + qq(6) ) &
            * xx + qq(7)

       gamma0 = REAL(( sump / sumq - pp(1) ) / sqrt ( x ))

    END IF

  END function gamma0

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                   j1                                      !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Computes the J1 Bessel function
!!
!!   This routine is based on caljy1 of the specfun package
!!   http://people.sc.fsu.edu/~jburkardt/f_src/specfun/specfun.f90
!!   which is freely available under GNU license
!!
!!   Original authors: William Cody
!!   Original reference: John Hart, Ward Cheney, Charles Lawson, Hans Maehly
!!          Charles Mesztenyi, John Rice, Henry Thatcher, Christoph Witzgall,
!!          Computer Approximations, Wiley, 1968, LC: QA297.C64.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  function bessel1 ( arg )
    implicit none

    integer(kind=4) :: i
    real :: arg, bessel1
    real(kind=8) :: ax, dblarg, down
    real(kind=8) :: prod, r0, r1, up, w
    real(kind=8) :: xden, xnum, z, zsq

    !  Mathematical constants
    real(kind = 8), parameter :: pi2 = 6.3661977236758134308d-1
    real(kind = 8), parameter :: p17 = 1.716d-1
    real(kind = 8), parameter :: twopi  = 6.2831853071795864769d+0
    real(kind = 8), parameter :: twopi1 = 6.28125d0
    real(kind = 8), parameter :: twopi2 = 1.9353071795864769253d-03
    real(kind = 8), parameter :: two56  = 256.0d+0
    real(kind = 8), parameter :: rtpi2  = 7.9788456080286535588d-1

    !  Machine-dependent constants
    real(kind = 8) :: xmax  = 1.07d+09
    real(kind = 8) :: xsmall = 9.31d-10

    !  Zeroes of Bessel functions
    real(kind = 8), parameter :: xj0  = 3.8317059702075123156d+0
    real(kind = 8), parameter :: xj1  = 7.0155866698156187535d+0
    real(kind = 8), parameter :: xj01 = 981.0d+0
    real(kind = 8), parameter :: xj02 = -3.2527979248768438556d-04
    real(kind = 8), parameter :: xj11 = 1796.0d+0
    real(kind = 8), parameter :: xj12 = -3.8330184381246462950d-05

    !  Coefficients for rational approximation of
    !  J1(X) / (X * (X**2 - XJ0**2)), XSMALL < |X| <=  4.0
    real(kind = 8),parameter,dimension(7) :: pj0 = &
         &(/9.8062904098958257677d+05,-1.1548696764841276794d+08, &
         &6.6781041261492395835d+09,-1.4258509801366645672d+11, &
         &-4.4615792982775076130d+03, 1.0650724020080236441d+01, &
         &-1.0767857011487300348d-02/)
    real(kind = 8),parameter,dimension(5) :: qj0 = &
         &(/5.9117614494174794095d+05, 2.0228375140097033958d+08, &
         &4.2091902282580133541d+10, 4.1868604460820175290d+12, &
         &1.0742272239517380498d+03/)

    !  Coefficients for rational approximation of
    !  J1(X) / (X * (X**2 - XJ1**2)), 4.0 < |X| <= 8.0
    real(kind = 8),parameter,dimension(8) :: pj1 = &
         &(/4.6179191852758252280d+00,-7.1329006872560947377d+03, &
         &4.5039658105749078904d+06,-1.4437717718363239107d+09, &
         &2.3569285397217157313d+11,-1.6324168293282543629d+13, &
         &1.1357022719979468624d+14, 1.0051899717115285432d+15/)
    real(kind = 8),parameter,dimension(7) :: qj1 = &
         &(/1.1267125065029138050d+06, 6.4872502899596389593d+08, &
         &2.7622777286244082666d+11, 8.4899346165481429307d+13, &
         &1.7128800897135812012d+16, 1.7253905888447681194d+18, &
         &1.3886978985861357615d+03/)

    !  Coefficients for Hart's approximation, 8.0 < |X|.
    real(kind = 8),parameter,dimension(6) :: p0 = &
         &(/-1.0982405543459346727d+05,-1.5235293511811373833d+06, &
         &-6.6033732483649391093d+06,-9.9422465050776411957d+06, &
         &-4.4357578167941278571d+06,-1.6116166443246101165d+03/)
    real(kind = 8),parameter,dimension(6) :: q0 = &
         &(/-1.0726385991103820119d+05,-1.5118095066341608816d+06, &
         &-6.5853394797230870728d+06,-9.9341243899345856590d+06, &
         &-4.4357578167941278568d+06,-1.4550094401904961825d+03/)
    real(kind = 8),parameter,dimension(6) :: p1 = &
         &(/ 1.7063754290207680021d+03, 1.8494262873223866797d+04, &
         & 6.6178836581270835179d+04, 8.5145160675335701966d+04, &
         & 3.3220913409857223519d+04, 3.5265133846636032186d+01/)
    real(kind = 8),parameter,dimension(6) :: q1 = &
         &(/ 3.7890229745772202641d+04, 4.0029443582266975117d+05, &
         &1.4194606696037208929d+06, 1.8194580422439972989d+06, &
         &7.0871281941028743574d+05, 8.6383677696049909675d+02/)

    xsmall = 2.0*EPSILON(xsmall)
    xmax = HUGE(xmax)

    !  Check for error conditions.
    dblarg = arg
    ax = abs ( dblarg )

    if ( xmax < ax ) then
       bessel1 = 0.0
       return
    end if

    if ( 8.0d0 < ax ) then
       !  Calculate J1 or Y1 for 8.0 < |ARG|.
       z = 8.0d0 / ax
       w = aint ( ax / twopi ) + 0.375d0
       w = ( ax - w * twopi1 ) - w * twopi2
       zsq = z * z
       xnum = p0(6)
       xden = zsq + q0(6)
       up = p1(6)
       down = zsq + q1(6)

       do i = 1, 5
          xnum = xnum * zsq + p0(i)
          xden = xden * zsq + q0(i)
          up = up * zsq + p1(i)
          down = down * zsq + q1(i)
       end do

       r0 = xnum / xden
       r1 = up / down

       bessel1 = real(( rtpi2 / sqrt ( ax ) ) &
            * ( r0 * cos ( w ) - z * r1 * sin ( w ) ))

       if (dblarg < 0.0d0 ) then
          bessel1 = -bessel1
       end if

       return
    else if ( ax <= xsmall ) then
       bessel1 = real(dblarg * 0.5d0)
       return
    end if

    !  Calculate J1 for appropriate interval, preserving
    !  accuracy near the zero of J1.
    zsq = ax * ax

    if ( ax <= 4.0d0 ) then
       xnum = ( pj0(7) * zsq + pj0(6) ) * zsq + pj0(5)
       xden = zsq + qj0(5)
       do i = 1, 4
          xnum = xnum * zsq + pj0(i)
          xden = xden * zsq + qj0(i)
       end do
       prod = dblarg * ( ( ax - xj01 / two56 ) - xj02 ) * ( ax + xj0 )
    else
       xnum = pj1(1)
       xden = ( zsq + qj1(7) ) * zsq + qj1(1)
       do i = 2, 6
          xnum = xnum * zsq + pj1(i)
          xden = xden * zsq + qj1(i)
       end do
       xnum = xnum * ( ax - 8.0d0 ) * ( ax + 8.0d0 ) + pj1(7)
       xnum = xnum * ( ax - 4.0d0 ) * ( ax + 4.0d0 ) + pj1(8)
       prod = dblarg * ( ( ax - xj11 / two56 ) - xj12 ) * ( ax + xj1 )
    end if

    bessel1 = prod * ( xnum / xden )

  end function bessel1

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                   II modified Bessel                      !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Computes the modified Bessel function of the first kind and order one, I1(X) 
!!  for real arguments X
!!
!!   This routine is based on caljy1 of the specfun package
!!   http://people.sc.fsu.edu/~jburkardt/f_src/specfun/specfun.f90
!!   which is freely available under GNU license
!!
!!   Original authors: William Cody
!!   Original reference: John Hart, Ward Cheney, Charles Lawson, Hans Maehly
!!          Charles Mesztenyi, John Rice, Henry Thatcher, Christoph Witzgall,
!!          Computer Approximations, Wiley, 1968, LC: QA297.C64.
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  FUNCTION bessel_mod1( arg )
    implicit none

    integer ( kind = 4 ) :: j
    real :: arg, bessel_mod1
    real(kind = 8) :: sump, sumq, x, xx

    !  Mathematical constants
    real(kind = 8),parameter :: rec15 = 6.6666666666666666666d-2

    !  Machine-dependent constants
    real(kind = 8) :: xsmall = 5.55d-17
    real(kind = 8) :: xmax = 713.987d0
    real(kind = 8) :: xinf = 1.79d308

    !  Coefficients for XSMALL <= ABS(ARG) < 15.0
    real(kind = 8),parameter,dimension(15) :: p = &
         &(/-1.9705291802535139930d-19,-6.5245515583151902910d-16, &
         &-1.1928788903603238754d-12,-1.4831904935994647675d-09, &
         &-1.3466829827635152875d-06,-9.1746443287817501309d-04, &
         &-4.7207090827310162436d-01,-1.8225946631657315931d+02, &
         &-5.1894091982308017540d+04,-1.0588550724769347106d+07, &
         &-1.4828267606612366099d+09,-1.3357437682275493024d+11, &
         &-6.9876779648010090070d+12,-1.7732037840791591320d+14, &
         &-1.4577180278143463643d+15/)
    real(kind = 8),parameter,dimension(5) :: q = &
         &(/-4.0076864679904189921d+03, 7.4810580356655069138d+06, &
         &-8.0059518998619764991d+09, 4.8544714258273622913d+12, &
         &-1.3218168307321442305d+15/)

    !  Coefficients for 15.0 <= ABS(ARG)
    real(kind = 8),parameter,dimension(8) :: pp = &
         &(/-6.0437159056137600000d-02, 4.5748122901933459000d-01, &
         &-4.2843766903304806403d-01, 9.7356000150886612134d-02, &
         &-3.2457723974465568321d-03,-3.6395264712121795296d-04, &
         &1.6258661867440836395d-05,-3.6347578404608223492d-07/)
    real(kind = 8),parameter,dimension(6) :: qq = &
         &(/-3.8806586721556593450d+00, 3.2593714889036996297d+00, &
         &-8.5017476463217924408d-01, 7.4212010813186530069d-02, &
         &-2.2835624489492512649d-03, 3.7510433111922824643d-05/)
    real(kind = 8),parameter :: pbar = 3.98437500d-01

    xsmall = 2.0*epsilon(xsmall)
    xmax = 0.5*huge(xmax)

    x = abs ( arg )

    !  Return for ABS(ARG) < XSMALL.
    if ( x < xsmall ) then

       bessel_mod1 = real(0.5d0 * x)

    !  XSMALL <= ABS(ARG) < 15.0.
    else if ( x < 15.0d0 ) then

       xx = x * x
       sump = p(1)
       do j = 2, 15
          sump = sump * xx + p(j)
       end do
       xx = xx - 225.0d0

       sumq = (((( &
            xx + q(1) ) &
            * xx + q(2) ) &
            * xx + q(3) ) &
            * xx + q(4) ) &
            * xx + q(5)

       bessel_mod1 = real(( sump / sumq ) * x)
   
    else if ( xmax < x ) then
        
        bessel_mod1 = xinf

    else
       !  15.0 <= ABS(ARG).
       xx = 1.0d0 / x - rec15

       sump = (((((( &
            pp(1) &
            * xx + pp(2) ) &
            * xx + pp(3) ) &
            * xx + pp(4) ) &
            * xx + pp(5) ) &
            * xx + pp(6) ) &
            * xx + pp(7) ) &
            * xx + pp(8)

       sumq = ((((( &
            xx + qq(1) ) &
            * xx + qq(2) ) &
            * xx + qq(3) ) &
            * xx + qq(4) ) &
            * xx + qq(5) ) &
            * xx + qq(6)

       bessel_mod1 = real(sump / sumq)

    end if

    if ( arg < 0.0 ) then
       bessel_mod1 = -bessel_mod1
    end if

  end function bessel_mod1
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                  gamma1                      !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  Computes the modified Bessel functions of the first kind 
!! and order one, gamma1(X) = I1(X)*exp(-X)
!!
!!   This routine is based on caljy1 of the specfun package
!!   http://people.sc.fsu.edu/~jburkardt/f_src/specfun/specfun.f90
!!   which is freely available under GNU license
!!
!!   Original authors: William Cody
!!   Original reference: John Hart, Ward Cheney, Charles Lawson, Hans Maehly
!!          Charles Mesztenyi, John Rice, Henry Thatcher, Christoph Witzgall,
!!          Computer Approximations, Wiley, 1968, LC: QA297.C64.
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  function gamma1( arg )
    implicit none

    integer ( kind = 4 ) :: j
    real :: arg, gamma1
    real(kind = 8) :: sump, sumq, x, xx

    !  Mathematical constants
    real(kind = 8),parameter :: rec15 = 6.6666666666666666666d-2

    !  Machine-dependent constants
    real(kind = 8) :: xsmall = 5.55d-17
    real(kind = 8) :: xmax = 713.987d0

    !  Coefficients for XSMALL <= ABS(ARG) < 15.0
    real(kind = 8),parameter,dimension(15) :: p = &
         &(/-1.9705291802535139930d-19,-6.5245515583151902910d-16, &
         &-1.1928788903603238754d-12,-1.4831904935994647675d-09, &
         &-1.3466829827635152875d-06,-9.1746443287817501309d-04, &
         &-4.7207090827310162436d-01,-1.8225946631657315931d+02, &
         &-5.1894091982308017540d+04,-1.0588550724769347106d+07, &
         &-1.4828267606612366099d+09,-1.3357437682275493024d+11, &
         &-6.9876779648010090070d+12,-1.7732037840791591320d+14, &
         &-1.4577180278143463643d+15/)
    real(kind = 8),parameter,dimension(5) :: q = &
         &(/-4.0076864679904189921d+03, 7.4810580356655069138d+06, &
         &-8.0059518998619764991d+09, 4.8544714258273622913d+12, &
         &-1.3218168307321442305d+15/)

    !  Coefficients for 15.0 <= ABS(ARG)
    real(kind = 8),parameter,dimension(8) :: pp = &
         &(/-6.0437159056137600000d-02, 4.5748122901933459000d-01, &
         &-4.2843766903304806403d-01, 9.7356000150886612134d-02, &
         &-3.2457723974465568321d-03,-3.6395264712121795296d-04, &
         &1.6258661867440836395d-05,-3.6347578404608223492d-07/)
    real(kind = 8),parameter,dimension(6) :: qq = &
         &(/-3.8806586721556593450d+00, 3.2593714889036996297d+00, &
         &-8.5017476463217924408d-01, 7.4212010813186530069d-02, &
         &-2.2835624489492512649d-03, 3.7510433111922824643d-05/)
    real(kind = 8),parameter :: pbar = 3.98437500d-01

    xsmall = 2.0*epsilon(xsmall)
    xmax = 0.5*huge(xmax)

    x = abs ( arg )

    !  Return for ABS(ARG) < XSMALL.
    if ( x < xsmall ) then

       gamma1 = real(0.5d0 * x)

    !  XSMALL <= ABS(ARG) < 15.0.
    else if ( x < 15.0d0 ) then

       xx = x * x
       sump = p(1)
       do j = 2, 15
          sump = sump * xx + p(j)
       end do
       xx = xx - 225.0d0

       sumq = (((( &
            xx + q(1) ) &
            * xx + q(2) ) &
            * xx + q(3) ) &
            * xx + q(4) ) &
            * xx + q(5)

   
       gamma1 = real(( sump / sumq ) * x  * exp ( -x ))

       !  15.0 <= ABS(ARG).
       xx = 1.0d0 / x - rec15

       sump = (((((( &
            pp(1) &
            * xx + pp(2) ) &
            * xx + pp(3) ) &
            * xx + pp(4) ) &
            * xx + pp(5) ) &
            * xx + pp(6) ) &
            * xx + pp(7) ) &
            * xx + pp(8)

       sumq = ((((( &
            xx + qq(1) ) &
            * xx + qq(2) ) &
            * xx + qq(3) ) &
            * xx + qq(4) ) &
            * xx + qq(5) ) &
            * xx + qq(6)

          gamma1 = real(( sump / sumq  + pbar ) / sqrt ( x ))
    end if

    if ( arg < 0.0 ) then
       gamma1 = -gamma1
    end if

  end function gamma1

END MODULE aux_func
