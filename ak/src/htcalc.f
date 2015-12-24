      SUBROUTINE HTCALC(I,ISPC,XSITE,AG,HGUESS,POTHTG)
      use contrl_mod
      use varcom_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **HTCALC--AK   DATE OF LAST REVISION:  02/14/08
C----------
C   THIS SUBROUTINE COMPUTES THE HEIGHT INCREMENT GIVEN TREE-SPECIFIC
C   INDEPENDENT VARIABLES SUCH AS DBH, DG AGE ...
C   CALLED FROM **HTGF**
C----------
COMMONS
C------------
      LOGICAL DEBUG
      INTEGER ISPC,I
      REAL POTHTG,HGUESS,AG,XSITE,B0,B1,B2,B3,B4,C0,C1,C2,C3
      REAL HB,PH,TERM1,P1,P2
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTCALC',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTCALC  CYCLE =',I5)
C
      SELECT CASE(ISPC)
C
      CASE(10)
C----------
C  RED ALDER
C----------
        B0=BB0(ISPC)
        B1=BB1(ISPC)
        B2=BB2(ISPC)
        B3=BB3(ISPC)
        B4=BB4(ISPC)
        HGUESS = XSITE
     &         + (B0 + B1*XSITE)*(1.0-EXP((B2 + B3*XSITE)*AG))**B4
     &         - (B0 + B1*XSITE)*(1.0-EXP((B2 + B3*XSITE)*20.0))**B4
C
      CASE(11)
C----------
C  BLACK COTTONWOOD
C---------
        B0=BB0(ISPC)
        B1=BB1(ISPC)
        B2=BB2(ISPC)
        B3=BB3(ISPC)
        HGUESS = (XSITE - 4.5) / ( B0 + B1/(XSITE - 4.5)
     &         + B2 * AG**(-1.4) +(B3/(XSITE - 4.5))*AG**(-1.4))
        HGUESS = HGUESS + 4.5
C
      IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),DG(I),HT(I),
     & POTHTG,HTG(I),DBH(I),HGUESS,AG
  901 FORMAT(' HTGF',I5,13F9.2)
C----------
C  ALL SPECIES OTHER THAN RED ALDER AND COTTONWOOD.
C----------
      CASE(1:9,12,13)
      IF((HT(I) - 4.5) .LE. 0.0)GO TO 900
C
      IF(DEBUG)WRITE(JOSTND,9050)I,ISP(I),DBH(I),HT(I),ICR(I),
     &  XSITE,DG(I)
 9050 FORMAT('IN HTGF 9050 I,ISP,DBH,HT,ICR,AVH,XSITE,DG=',
     &2I5,2F10.2,I5,5F8.3)
C----------
C SPRUCE HEIGHT EQUATION APPLIED TO ALL SPECIES EXCEPT WH.
C----------
      IF(ISPC .EQ. 5) GO TO 41
        B0 = 3.380276
        B1 = 0.8683028
        B2 = 0.01630621
        B3 = 2.744017 * XSITE**(-0.2095425)
        C0 = (1.0 - EXP(-10.0 * B2)) * B0**(1.0/B3)
        C1 = B1/B3
        C2 = EXP(-10.0 * B2)
        C3 = 1.0 / B3
        HB = HT(I) - 4.5
        PH = 4.5 + (C0*XSITE**C1 + C2*HB**C3)**(1.0/C3) - HB
        TERM1 = (1.0 - EXP( - 0.03563*ICR(I)) ** 0.907878)
C----------
C     SPRUCE LOG-LINEAR HEIGHT EQUATION FROM FARR 10-22-87
C----------
      POTHTG = EXP(1.5163 + 0.1429*ALOG(DG(I)) - 6.04687E-5*(HT(I)
     &   *HT(I))
     &  + 0.0103*XSITE + 0.20358*ALOG(90.00 ) + 0.44146*ALOG(DBH(I))
     &  - 0.36662*ALOG(HT(I)))
      POTHTG=POTHTG*TERM1
C----------
C HT GROWTH CORRECTION FOR RC AND YC FROM BILL FARR (PNW JUNEAU)
C JULY 9, 1987.  PUBLISHED BC STUFF INDICATES RC HEIGHT GROWTH SHOULD
C BE ABOUT 75 PERCENT OF SS HEIGHT GROWTH.
C----------
      IF(ISP(I).EQ.2 .OR. ISP(I).EQ.6) POTHTG = POTHTG *
     &(0.84875-0.03039*DBH(I)+0.00076*DBH(I)*DBH(I)+0.00313*XSITE)
      GO TO 100
C----------
C WESTERN HEMLOCK HEIGHT EQUATION
C----------
   41 CONTINUE
C
        B0 = 6.421396
        B1 = 0.7642128
        B2 = 0.01046931
        B3 = 3.316557 * XSITE**(-0.2930032)
        C0 = (1.0 - EXP(-10.0*B2)) * B0**(1.0/B3)
        C1 = B1 / B3
        C2 = EXP(-10.0*B2)
        C3 = 1.0 / B3
        HB = HT(I) - 4.5
        PH = 4.5 + (C0*XSITE**C1 + C2*HB**C3)**(1.0/C3) - HB
        P1 = 0.8174751
        P2 = 0.2010897
C----------
C TERM1 IS BORROWED FROM SPRUCE LOGIC FOR NOW TO GET SOME
C CROWN SENSITIVITY INTO THE HEMLOCK EQUATION.
C----------
        TERM1 = (1.0 - EXP( - 0.03563*ICR(I)) ** 0.907878)
C----------
C     NEW WH LOG-LINEAR HTG EQN FROM BILL FARR 10-22-87
C----------
      POTHTG = EXP(2.18643 + 0.2059*ALOG(DG(I)) - 7.84117E-5*(HT(I)
     & *HT(I))
     &  + 9.6528E-3*XSITE + 0.54334*ALOG(DBH(I)) - 0.35425*ALOG(HT(I)))
      POTHTG=POTHTG*TERM1
C
  100 CONTINUE
      IF(DEBUG)WRITE(JOSTND,110)B0,B1,B2,B3,C0,C1,C2,C3,HB,PH,
     &P1,P2,POTHTG
  110 FORMAT('IN HTCALC 110 FORM B0,B1,B2,B3,C0,C1,C2,C3,HT,PH,P1,P2,HTG
     & =',/,1H ,13F9.5)
C
      IF(POTHTG .GT. PH)POTHTG=PH
C
      END SELECT
C
  900 CONTINUE
      RETURN
      END
