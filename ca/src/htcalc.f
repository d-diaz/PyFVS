      SUBROUTINE HTCALC(JFOR,SINDX,KSPEC,AG,HGUESS,JOSTND,DEBUG)
      use varcom_mod
      use prgprm_mod
      implicit none

!f2py intent(in) :: jfor,sindx,kspec,ag
!f2py intent(hide) :: jostnd,debug
!f2py intent(out) :: hguess

C----------
C  **HTCALC--CA   DATE OF LAST REVISION:  01/10/11
C----------
C THIS ROUTINE CALCULATES A POTENTIAL HT GIVEN A SITE INDEX, SPECIES,
C AND AGE. IT IS USED TO CALCULATE POTENTIAL HEIGHT GROWTH AND SITE
C EQUIVALENTS.
C----------
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER INDEX(49),INDX,KSPEC,JFOR,JOSTND
      REAL HGUESS,AG,SINDX,B0,B1,B2,B3,B4,B5,B6,Z,A,B,C
      REAL X1,X2,TOPTRM,BOTTRM,TERM,TERM2,B50
      REAL DUNL1(6),DUNL2(6),DUNL3(6)
C----------
C SPECIES ORDER IN CA VARIANT:
C  1=PC  2=IC  3=RC  4=WF  5=RF  6=SH  7=DF  8=WH  9=MH 10=WB
C 11=KP 12=LP 13=CP 14=LM 15=JP 16=SP 17=WP 18=PP 19=MP 20=GP
C 21=JU 22=BR 23=GS 24=PY 25=OS 26=LO 27=CY 28=BL 29=EO 30=WO
C 31=BO 32=VO 33=IO 34=BM 35=BU 36=RA 37=MA 38=GC 39=DG 40=FL
C 41=WN 42=TO 43=SY 44=AS 45=CW 46=WI 47=CN 48=CL 49=OH
C----------
      DATA INDEX/ 3,  3,  3,  3,  5,  5,  3,  3,  5,  6,
     &            6,  6,  6,  6,  4,  3,  4,  4,  4,  4,
     &            6,  3,  3,  7,  3,  9,  9,  9,  9,  7,
     &            7,  7,  9, 10,  7, 10,  9,  9,  7,  7,
     &           10,  8, 10, 10, 10, 10, 10, 10, 10/
C
      DATA DUNL1/ -88.9, -82.2, -78.3, -82.1, -56.0, -33.8 /
      DATA DUNL2/ 49.7067, 44.1147, 39.1441,
     &            35.4160, 26.7173, 18.6400 /
      DATA DUNL3/ 2.375, 2.025, 1.650, 1.225, 1.075, 0.875 /
C
      IF(DEBUG)WRITE(JOSTND,15)
   15 FORMAT(' ENTERING HTCALC')
      IF(DEBUG)WRITE(JOSTND,30)AG,SINDX,KSPEC
   30 FORMAT(' IN HTCALC 30F AG,SINDX,KSPEC=',2F10.4,I10)
C
      SELECT CASE (JFOR)
C----------
C REGION 5 LOGIC
C R5 USE DUNNING/LEVITAN SITE CURVE.
C----------
      CASE(1:5)
        IF(JFOR .LE. 5) THEN
C----------
C SET UP MAPPING TO THE CORRECT DUNNING-LEVITAN SITE CURVE
C----------
          IF(SINDX .LE. 44.) THEN
            INDX=6
          ELSEIF (SINDX.GT.44. .AND. SINDX.LE.52.) THEN
            INDX=5
          ELSEIF (SINDX.GT.52. .AND. SINDX.LE.65.) THEN
            INDX=4
          ELSEIF (SINDX.GT.65. .AND. SINDX.LE.82.) THEN
            INDX=3
          ELSEIF (SINDX.GT.82. .AND. SINDX.LE.98.) THEN
            INDX=2
          ELSE
            INDX=1
          ENDIF
          IF(AG .LE. 40.) THEN
            HGUESS = DUNL3(INDX) * AG
          ELSE
            HGUESS = DUNL1(INDX) + DUNL2(INDX)*ALOG(AG)
          ENDIF
        ENDIF
C
      CASE DEFAULT
C----------
C REGION 6 LOGIC
C
C   LOAD COEFFICIENTS AND GO TO A SITE CURVE BASED ON SPECIES.
C   COEFFS IN BB_ ARRAYS ARE LOADED IN BLKDAT:
C       1 = KING DOUGLAS-FIR; WEYERH FOR PAP 8
C       2 = DOLPH WHITE FIR PSW 185;
C       3 = HANN-SCRIVANI DOUGLAS-FIR
C       4 = HANN-SCRIVANI PONDEROSA PINE
C       5 = DOLPH RED FIR PSW 206
C       6 = DAHMS LODGEPOLE RP-PNW-8
C       7 = POWERS BLACK OAK RES NOTE PSW-262
C       8 = PORTER & WIANT TANOAK JOF 4/95 286-287
C       9 = PORTER & WIANT MADRONE JOF 4/95 286-287
C      10 = PORTER & WIANT RED ALDER JOF 4/95 286-287
C
C   INDEX = ARRAY HOLDING THE INDEX FOR ACCESSING THE APPROPRIATE SITE
C           CURVE COEFFICIENTS IN THE BB_ ARRAYS.
C----------
        INDX = INDEX(KSPEC)
        B0=BB0(INDX)
        B1=BB1(INDX)
        B2=BB2(INDX)
        B3=BB3(INDX)
        B4=BB4(INDX)
        B5=BB5(INDX)
        B6=BB6(INDX)
        IF(DEBUG) WRITE(JOSTND,*)' INDX,B0,B1,B2,B3,B4,B5,B6= ',
     &  INDX,B0,B1,B2,B3,B4,B5,B6
C----------
C GO TO A DIFFERENT POTENTIAL HEIGHT CURVE DEPENDING ON THE INDEX
C SCALE FACTORS ADDED TO SOME SPECIES SO THEY WOULD
C HIT THE SITE HEIGHT.
C----------
        SELECT CASE (INDX)
C----------
C KING DOUGLAS-FIR, WEYERHAUSER FOR PAP 8, 1966.
C----------
        CASE(1)
          Z = B0/(SINDX - 4.5)
          A = B1 + B2*Z
          B = B3 + B4*Z
          C = B5 + B6*Z
          HGUESS = ((AG*AG)/(A + B*AG + C*AG*AG)) + 4.5
C----------
C DOLPH WHITE FIR, RES PAP PSW-185, FEB 1987
C----------
        CASE(2)
          X1 = (B1*AG**B2*EXP(B3*AG))
          X2 = B4*(1.0 - EXP(B5*AG**B6))
          HGUESS = (SINDX - B0 + X1*X2)/X1 + 4.5
          IF(DEBUG)WRITE(JOSTND,*)' X1,X2,SINDX,AG,HGUESS= ',
     &    X1,X2,SINDX,AG,HGUESS
C----------
C HANN-SCRIVANI OSU RES BULL 59, FEB 1987
C----------
        CASE(3,4)
          TOPTRM = 1.0-EXP(-EXP(B0+B1*ALOG(SINDX-4.5)+B2*ALOG(AG)))
          BOTTRM = 1.0-EXP(-EXP(B0+B1*ALOG(SINDX-4.5)+B2*ALOG(50.)))
          HGUESS = ((SINDX-4.5)*TOPTRM/BOTTRM) + 4.5
          HGUESS = HGUESS*1.05
          IF(DEBUG)WRITE(JOSTND,*)' SINDX,AG,TOPTRM,BOTTRM,HGUESS= ',
     &    SINDX,AG,TOPTRM,BOTTRM,HGUESS
C----------
C DOLPH RED FIR CURVES, RES PAP PSW 206
C----------
        CASE(5)
          TERM=AG*EXP(AG*B3)*B2
          B = SINDX*TERM + B4*TERM*TERM + B5
          TERM2 = 50.0 * EXP(50.0*B3) * B2
          B50 = SINDX*TERM2 + B4*TERM2*TERM2 + B5
          HGUESS = ((SINDX-4.5) * (1.0-EXP(-B*(AG**B1)))) /
     &             (1.0-EXP(-B50*(50.0**B1)))
          HGUESS = HGUESS + 4.5
          IF(DEBUG)WRITE(JOSTND,*)' SINDX,AG,TERM,B,TERM2,B50,HGUESS= ',
     &    SINDX,AG,TERM,B,TERM2,B50,HGUESS
C----------
C DAHMS LODGEPOLE PINE, RES PAP PNW-8
C----------
        CASE(6)
          HGUESS = SINDX * (B0 + B1*AG + B2*AG*AG)
          HGUESS = HGUESS*1.10
          IF(DEBUG)WRITE(JOSTND,*)' SINDX,AG,HGUESS= ',SINDX,AG,HGUESS
C----------
C POWERS BLACK OAK RES NOTE PSW-262
C----------
        CASE(7)
          TERM = SQRT(AG)-SQRT(50.)
          HGUESS = (SINDX * (1 + B1*TERM)) - B0*TERM
          HGUESS = HGUESS * 0.70
          IF(DEBUG)WRITE(JOSTND,*)' SINDX,AG,TERM,HGUESS= ',
     &    SINDX,AG,TERM,HGUESS
C----------
C PORTER & WIANT TANOAK, MADRONE, RED ALDER, JOF 4/1965 286-287p
C----------
        CASE(8:10)
          HGUESS = SINDX / (B0 + B1/AG)
          HGUESS = HGUESS * 0.80
          IF(DEBUG)WRITE(JOSTND,*)' SINDX,AG,HGUESS= ',SINDX,AG,HGUESS
C
      END SELECT
C
      END SELECT
C
      RETURN
      END
