module htcalc_mod
    use prgprm_mod
    use varcom_mod

    contains

      real function HTCALC(SINDX,ISPC,AG,JOSTND,DEBUG)
      IMPLICIT NONE

!f2py intent(in) :: sindx,ispc,ag
!f2py intent(hide) :: jostnd,debug

!----------
!  **HTCALC--PN   DATE OF LAST REVISION:  03/07/12
!----------
! THIS ROUTINE CALCULATES A POTENTIAL HEIGHT GIVEN A SPECIES SITE AND
! AGE; IT IS USED TO CALCULATE POTENTIAL HEIGHT AND SITE, WHITE OAK IS NOT
! BASED DIRECTLY ON SI AND AGE, CALCULATED IN HTGF
!----------
!
!OMMONS
!
!
!      INCLUDE 'PRGPRM.F77'
!
!
!      INCLUDE 'VARCOM.F77'
!
!
!OMMONS
!----------
      LOGICAL DEBUG
      INTEGER ISPC,IISPC,JOSTND
      REAL SPCMAP(39),SM45,X2,X3,TERM,B,TERM2,B50,X1,Z,AZ,BZ
      REAL HGUESS,AG,SINDX,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13
!
      DATA SPCMAP / &
          1, 2, 2, 3, 4, 15, 5, 6, 7, 3, &
          8, 7, 9, 9, 7, 14, 6, 15, 10, 11, 6, &
          12,5*6,14,6,13,9*6/
!----------
!
      IF(DEBUG)WRITE(JOSTND,10)
   10 FORMAT(' ENTERING HTCALC')
!----------
! LOAD THE BETA COEFFICIENTS.
!----------
      B0=BB0(ISPC)
      B1=BB1(ISPC)
      B2=BB2(ISPC)
      B3=BB3(ISPC)
      B4=BB4(ISPC)
      B5=BB5(ISPC)
      B6=BB6(ISPC)
      B7=BB7(ISPC)
      B8=BB8(ISPC)
      B9=BB9(ISPC)
      B10=BB10(ISPC)
      B11=BB11(ISPC)
      B12=BB12(ISPC)
      B13=BB13(ISPC)
      IISPC=SPCMAP(ISPC)
!----------
! GO TO A DIFFERENT POTENTIAL HEIGHT CURVE DEPENDING ON THE SPECIES
!----------
      IF(DEBUG)WRITE(JOSTND,20)B0,B1,B2,B3,B4,B5,B6,B7,AG,SINDX,IISPC
   20 FORMAT(' HTCALC 20F B0-7,AG,SINDX,IISPC = ',/,1H ,10F20.8,I5)
      IF(DEBUG)WRITE(JOSTND,30)B8,B9,B10,B11,B12,B13
   30 FORMAT(' HTCALC 30F B8-13 = ',6F14.8)
!
      SELECT CASE(IISPC)
!----------
! PACIFIC SILVER FIR - HOYER, PNW-418
!----------
      CASE(1)
        SM45 = SINDX-4.5
        HGUESS = (1.0 - EXP(-(B0 + B1 * SM45 ) * AG))**B2 &
                 / (1.0 - EXP(-(B0 + B1 * SM45 ) * 100.))**B2
        HGUESS = HGUESS*SM45 + 4.5
!----------
! WHITE & GRAND FIR - COCHRAN, PNW-252
!----------
      CASE(2)
        X2= B0 + B1*ALOG(AG) + B2*(ALOG(AG))**4 &
            + B3*(ALOG(AG))**9 + B4*(ALOG(AG))**11 &
            + B5*(ALOG(AG))**18
        X3= B6 + B7*ALOG(AG) + B8*(ALOG(AG))**2 &
            + B9*(ALOG(AG))**7 + B10*(ALOG(AG))**16 &
            + B11*(ALOG(AG))**24
        HGUESS=EXP(X2) + B12*EXP(X3) + (SINDX - 4.5)*EXP(X3) &
               + 4.5
        IF(DEBUG)WRITE(JOSTND,9500)X2,X3,SINDX,AG,HGUESS
 9500   FORMAT(' X2,X3,SINDX,AG',5E12.4)
!----------
! SUBALPINE FIR - ALEXANDER, RM-32
!----------
      CASE(3)
        HGUESS = 4.5+((B0*SINDX**B1)*(1.0-EXP(-B2*AG))**(B3*SINDX**B4))
        IF(DEBUG)WRITE(JOSTND,*)B0,B1,B2,B3,B4,SINDX,AG,HGUESS
!----------
! RED FIR & CALIFORNIA - DOLPH, PSW-206
!----------
      CASE(4)
        TERM=AG*EXP(AG*B3)*B2
        B = SINDX*TERM + B4*TERM*TERM + B5
        TERM2 = 50.0 * EXP(50.0*B3) * B2
        B50 = SINDX*TERM2 + B4*TERM2*TERM2 + B5
        HGUESS = ((SINDX-4.5)*(1.0-EXP(-B*(AG**B1)))) / &
                 (1.0-EXP(-B50*(50.0**B1)))
        HGUESS = HGUESS+4.5
!----------
! NOBLE FIR - HERMAN, PNW-243
!----------
      CASE(5)
        X1 = B0 + B1*(SINDX - 4.5) - B2*(SINDX - 4.5)**2
        X2 = B3 + B4*(SINDX - 4.5)**(-1) + B5*(SINDX - 4.5)**(-2)
        HGUESS = 4.5 + (SINDX - 4.5)/(X1*(1.0/AG)**2 + &
            X2*(1.0/AG) + 1.0 - 0.0001*X1 - 0.01*X2)
!----------
! MISC. SPECIES - USE CURTIS, FOR. SCI. 20:307-316.  CURTIS CURVES
! ARE PRESENTED IN METRIC (3.2808 ?)
!----------
      CASE(6)
        HGUESS = (SINDX - 4.5) / ( B0 + B1/(SINDX - 4.5) &
            + B2 * AG**(-1.4) +(B3/(SINDX - 4.5))*AG**(-1.4))
!----------
! EXCESSIVE HT GROWTH -- APPROX 30-40 FT/CYCLE, TAKE OUT METRIC MULT
! DIXON 11-05-92
!----------
!       HGUESS = (HGUESS + 4.5)*3.2808
        HGUESS = HGUESS + 4.5
!----------
! INCENSE CEDAR - BARRETT, PNW 232
! PONDEROSA PINE AND JEFFERY PINE USE BARRETT
!----------
      CASE(7)
        HGUESS =( B0*(1.0 -EXP(B1*AG))**B2) &
                 - ((B3 + B4*(1.0-EXP(B5*AG))**B6)*B7) &
                 + ((B3 + B4*(1.0 - EXP(B5*AG))**B6)*(SINDX - 4.5)) &
                 + 4.5
!----------
! LODGEPOLE PINE USE DAHMS PNW 8
!----------
      CASE(8)
        HGUESS = SINDX*(B0 + B1*AG + B2*AG*AG)
!----------
! SUGAR & WHITE PINE - CURTIS, PNW-423
!----------
      CASE(9)
        HGUESS = (1.0-EXP(-EXP(B0+B1*ALOG(AG)+B2/SINDX))) / &
                 (1.0-EXP(-EXP(B0+B1*ALOG(100.)+B2/SINDX)))
        HGUESS = HGUESS*(SINDX-4.5)+4.5
!----------
! WESTERN HEMLOCK - WILEY, 1978
!----------
      CASE(10)
        IF(DEBUG)WRITE(JOSTND,*)' WESTERN HEMLOCK EQUATION'
        Z = 2500./(SINDX-4.5)
        HGUESS = (AG*AG/(B0 + B1*Z + (B2 + B3*Z)*AG + &
                 (B4 + B5*Z)*(AG*AG))) + 4.5
!----------
! MOUNTAIN HEMLOCK - USE MEANS, UNPUBLISHED
!----------
      CASE(11)
        HGUESS = (B0 + B1*SINDX)*(1.0 - EXP(B2*SQRT(SINDX)*AG)) &
                 **(B4 + B5/SINDX)
        HGUESS=(HGUESS + 1.37)*3.281
!----------
! RED ALDER - HARRINGTON, PNW-358
!----------
      CASE(12)
        HGUESS = SINDX &
                 + (B0 + B1*SINDX)*(1.0-EXP((B2 + B3*SINDX)*AG))**B4 &
                 - (B0 + B1*SINDX)*(1.0-EXP((B2 + B3*SINDX)*20.0))**B4
!----------
! SUBALPINE LARCH - COCHRAN, PNW-424
!----------
      CASE(13)
        HGUESS=4.5 + B1*AG + B2*AG*AG + B3*AG**3  + &
               B4*AG**4 + (SINDX -4.5)*(B5 + B6*AG &
               + B7*AG*AG + B8*AG**3)- &
               B9*(B10 + B11*AG + B12*AG*AG + B13*AG**3)
!----------
! DOUGLAS FIR -- KING, WEYERHAUSER FOR RPT #8, 1966
!----------
      CASE(14)
        IF(DEBUG)WRITE(JOSTND,*)' DOUGLAS-FIR EQUATION'
        Z = 2500./(SINDX-4.5)
        HGUESS = (AG*AG/(B0 + B1*Z + (B2 + B3*Z)*AG + &
                 (B4 + B5*Z)*(AG*AG))) + 4.5

!----------
! SITKA SPRUCE -- FARR, RES PAP PNW-326
! WESTERN RED CEDAR USE FARR
!----------
      CASE(15)
        IF(DEBUG) WRITE(JOSTND,*)' SITKA SPRUCE EQUATION'
        AZ = B0 + B1*ALOG(AG) + B2*ALOG(AG)**3. + B3*ALOG(AG)**5. &
             + B4*ALOG(AG)**30.
        BZ = B5 + B6*ALOG(AG) + B7*ALOG(AG)**2. + B8*ALOG(AG)**5. &
             + B9*ALOG(AG)**16. + B10*ALOG(AG)**36.
        HGUESS = 4.5 + EXP(AZ) + B11*EXP(BZ) + (SINDX-4.5)*EXP(BZ)
        IF(DEBUG)WRITE(JOSTND,*) AZ, BZ, HGUESS
!
      END SELECT
!
      IF(DEBUG)WRITE(JOSTND,90021)ISPC,IISPC,AG,SINDX,HGUESS
90021 FORMAT(' ISPC,IISPC,AG,SINDX,HGUESS = ',2I5,3F12.5)
      IF(DEBUG)WRITE(JOSTND,*)' LEAVING HTCALC'
!
      htcalc = hguess
      RETURN
      END

end module htcalc_mod
