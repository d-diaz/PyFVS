      SUBROUTINE SMHTGF (MODE,ICYC,I,H,CR1,DTIME,HHT,JOSTND,DEBUG)
      use pden_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **SMHTGF--SO  DATE OF LAST REVISION:  02/01/11
C----------
C  THIS ROUTINE CALCULATES THE HEIGHT GROWTH OF SMALL TREES (D<3.0 IN).
C  WHEN CALLED FROM ESSUBH (MODE=0), DTIME= TOTAL TREE AGE.
C  IF CALLED FROM REGENT (MODE=1), DTIME= FINT AND THE
C  RETURN VARIABLE (HHT) IS THE HEIGHT INCREMENT.
C  CALLED FROM **ESSUBH
C  CALLED FROM **REGENT
C
C  INPUT VARIABLES
C  I      - SPECIES SEQUENCE NUMBER
C  H      - BEGINING HEIGHT
C  SI     - SITE INDEX FOR SPECIES
C  MODE   - = 0 IF CALL IS FROM ESSUBH,
C           = 1 IF CALL IS FROM REGENT
C  DTIME  - DTIME=TOTAL SEEDLING AGE (MODE= 0), DTIME=FINT (MODE= 1)
C
C  RETURN VARIABLES
C  HHT    - HEIGHT GROWTH OVER TIME INCREMENT DTIME (REGENT)
C  HHT    - HEIGHT 5 YEARS INTO CYCLE, OR END OF CYCLE FINT<5 (ESSUBH)
C
      LOGICAL  DEBUG
      INTEGER  I,ICYC,JOSTND,MODE
      REAL     AGEPDT,C1,C2,C3,C4,EFFAGE,DTIME,H,HHT,HHT1,HHT2,SI
      REAL     RELHT,DOMHTGR,CRMOD,CR1,RHMOD,SMHMOD,FACTOR,BAL,TEMBAL
      REAL     IPCCF,PPCCF,BACHLO,D,BETA1,BETA2,HTG1,STDDEV
      REAL     SHI,SLO,CR,B0A,B0B,B1A,B1B,B0ASTD,B0BSTD,B1BSTD,HTGRTH
      EXTERNAL RANN
C----------
C  IF NO GROWTH IS TO BE CALCULATED ON ESTAB TREES, I.E. PLANTING
C  IS MORE THAN 5 YEARS INTO THE SIMULATION, THEN RETURN AND
C  LEAVE THE SMALL TREE GROWTH, DURING THE PLANTING CYCLE, TO
C  THE REGENT ROUTINE.
C----------
      HHT = 0.
      IF(DTIME .LE. 0.0) GO TO 120
C
      SI= SITEAR(I)
C
      SELECT CASE(I)
C----------
C  HEIGHT OF TALLEST SUBSEQUENT SPECIES 1 (WP) **********
C----------
      CASE(1)
C----------
C  FOR NON-LINEAR HEIGHT GROWTH MODEL SOLVE FIRST FOR EFFECTIVE
C  AGE BASED ON INPUT HEIGHT.
C----------
      C1= 0.375045
      C2= 0.92503
      C3= -0.020796
      C4= 2.48811
C
      IF(MODE .EQ. 0) THEN
        EFFAGE= 0.
        AGEPDT= EFFAGE + DTIME
      ELSEIF(MODE .EQ. 1) THEN
        EFFAGE= ALOG( (1.0 - (C1/SI * H)**(1/C4))/C2 ) / C3
        AGEPDT= EFFAGE + DTIME
      ENDIF
C
      HHT1 = (SI/C1)*(1.0-C2*EXP(C3*EFFAGE))**C4
      HHT2 = (SI/C1)*(1.0-C2*EXP(C3*AGEPDT))**C4
      HHT= HHT2 - HHT1
C----------
C  HEIGHT OF TALLEST SUBS. SPECIES 2 (SP) **********
C----------
      CASE(2)
C
      HHT = ((-1.0 + 0.32857*SI)/(28.0 - 0.042857*SI))*DTIME
      GO TO 120
C----------
C  HT OF TALLEST SUBS. SPECIES 3 (DF) **********
C  ALSO USED FOR 32 (OS)
C----------
      CASE(3,32)
C
      HHT = ((2.0 + 0.420*SI)/(28.5 - 0.05*SI))*DTIME
      HHT=HHT*1.1
C----------
C  HT OF TALLEST SUBS. SPECIES 4 (WF) AND 12 (GF) **********
C----------
      CASE(4,12)
C
      HHT = ((4.2435 + 0.1510*SI)/(19.0184 - 0.0570*SI))*DTIME
      HHT=HHT*1.2
C----------
C  HT OF TALLEST SUBS. SPECIES 5 (MH) **********
C  IN METERS CONVERTED TO FEET
C----------
      CASE(5)
C
      HHT = ((0.965758 + 0.082969*SI)/(55.249612 - 1.288852*SI))*DTIME
     &      *3.280833
      HHT=HHT*1.60
C----------
C  HT OF TALLEST SUBS. SPECIES 6 (IC) **********
C----------
      CASE(6)
C----------
C  ADD SEEDLING AGE TO DTIME IF USER DOES NOT ENTER SEEDLING HEIGHT
C  WHEN SERVING ESSUBH ROUTINE
C----------
C
      HHT = ((4.2435 + 0.1510*SI)/(19.0184 - 0.0570*SI))*DTIME
      HHT=HHT*1.3
C----------
C  HT OF TALLEST SUBS. SPECIES 7 (LP) and 16 (WB) **********
C----------
      CASE(7,16)
C
      HHT = (0.02008805*SI)*DTIME
       IF(I.EQ.16)HHT=1.6*HHT
       IF(DEBUG)WRITE(16,*)' HHT= ',HHT
       IF(DEBUG)WRITE(16,*)' HHT= ',HHT
C----------
C  HT OF TALLEST SUBS. SPECIES 8 (ES) **********
C----------
      CASE(8)
      HHT = ((0.09211 + 0.208517*SI)/(43.358 - 0.168166*SI))*DTIME
      HHT=HHT*1.35
C----------
C  RED SHASTA FIR FROM CA VARIANT
C----------
      CASE(9)
      IF(AVH .LE. 0.0) THEN
        RELHT= 1.0
      ELSE
        RELHT=H/AVH
      ENDIF
      IF (RELHT .GT. 1.05) RELHT= 1.05
C
      DOMHTGR= 5*(2.2227 + 0.4314*SI)/(29.0 - 0.05*SI)
      CR= CR1/100.
      CRMOD=(1.0-EXP(-4.26558*CR))
      RHMOD=(EXP(2.54119*(RELHT**0.250537-1.0)))
      SMHMOD= 1.016605*CRMOD*RHMOD
      HHT= DOMHTGR*SMHMOD
      IF (DEBUG) WRITE (JOSTND,9900) DOMHTGR, SMHMOD,HHT, SI,CR,RELHT
 9900 FORMAT(' DEBUG-SMHTGF--9900--',3F10.4, 2F6.1,F7.4)
C----------
C  HT OF TALLEST SUBS. SPECIES 10 (PP) **********
C----------
      CASE(10)
      HHT = ((-1.0 + 0.32857*SI)/(28.0 - 0.042857*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 11 (WJ) FROM UT **********
C  IF THIS CHANGES ALSO CHANGE IN HTCALC
C----------
      CASE(11)
      SHI=75.
      SLO=5.
      SI=SITEAR(I)
      IF(SI .GT. SHI) SI=SHI
      IF(SI .LE. SLO) SI=SLO + 0.5
      HHT = (SI/5.0)*(SI*1.5-H)/(SI*1.5)
      IF (DEBUG)
     & WRITE(JOSTND,*)' LEAVING SMHTGF, ICYC,I,HHT,DTIME,SI= ',
     &ICYC,I,HHT,DTIME,SI
C----------
C  HT OF TALLEST SUBS. SPECIES 13 (AF) **********
C----------
      CASE(13)
      HHT = ((6.0 + 0.14*SI)/(33.882 - 0.06588*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 14 (SF) FROM EC(4) **********
C----------
      CASE(14)
      HHT = ((-0.6667 + 0.4333*SI)/(28.5 - 0.05*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 15 (NF) FROM WC(7) **********
C----------
      CASE(15)
      HHT = ((11.26677 + 0.12027*SI)/(27.93806 - 0.02873*SI))*DTIME
C----------
C  HEIGHT OF TALLEST SUBS. SPECIES 17 (WL)  FROM EC(2) **********
C----------
      CASE(17)
      HHT = ((-3.9725 + 0.50995*SI)/(28.1168 - 0.05661*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 18 (RC) FROM EC(5) **********
C----------
      CASE(18)
      C1= 0.752842
      C2= 1.0
      C3= -0.0174
      C4= 1.4711
      IF(MODE .EQ. 0) THEN
        EFFAGE= 0.
        AGEPDT= EFFAGE + DTIME
      ELSEIF(MODE .EQ. 1) THEN
        EFFAGE= ALOG( (1.0 - (C1/SI * H)**(1/C4))/C2 ) / C3
        AGEPDT= EFFAGE + DTIME
      ENDIF
C
      HHT1 = (SI/C1)*(1.0-C2*EXP(C3*EFFAGE))**C4
      HHT2 = (SI/C1)*(1.0-C2*EXP(C3*AGEPDT))**C4
      HHT= HHT2 - HHT1
C----------
C  HT OF TALLEST SUBS. SPECIES 19 (WH) FROM WC (19) **********
C----------
      CASE(19)
      HHT = ((-5.74874 + 0.54576*SI)/(26.15767 - 0.03596*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 20 (PY) FROM WC (33) **********
C  ALSO SPECIES 21,23,25,26,28:31,33
C----------
      CASE(20,21,23,25,26,28:31,33)
      HHT = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 22 (RA) FROM WC (22) **********
C----------
      CASE(22)
      HHT = (-0.007025 + 0.056794*SI)*DTIME
      HHT=HHT*1.20
C----------
C  FROM CA BLACKOAK
C----------
      CASE(27)
      BAL=((100.0-PCT(I))/100.0)*BA
      FACTOR = 1.*(.80+0.004*(SI-50.))
      TEMBAL=BAL
      IF(TEMBAL .LT. 5.0) TEMBAL=5.0
      HHT = EXP(3.817 - 0.7829*ALOG(TEMBAL)) * FACTOR
      END SELECT
  120 CONTINUE
C
  900 CONTINUE
      RETURN
      END
