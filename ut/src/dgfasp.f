      SUBROUTINE DGFASP(D,ASPDG,CR,BARK,SI,DEBUG)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use pden_mod
      use prgprm_mod
      implicit none
C----------
C  **DGFASP--UT  DATE OF LAST REVISION:  11/17/09
C
C   CALCULATES DIAMETER GROWTH RATES FOR LARGE ASPEN TREES
C----------
C
      INCLUDE 'OUTCOM.F77'
C
C----------
      LOGICAL DEBUG
      REAL SI,BARK,CR,ASPDG,D,XSITE,REL,ASPCR,POT,FOFR,GOFAD,BAACT
      REAL VALMOD,PREDGR
C----------
C PEEL OFF THE SPECIES INDICATOR ON THE SITE INDEX
C----------
      XSITE = SI
      REL=D/RMSQD
      ASPCR=CR/10.0
C----------
C CALC THE POTENTIAL GROWTH
C----------
      POT=(.4755 - 3.8336E-6 * D **4.1488)
     &    + (4.510E-2 * ASPCR * D **.67266)
      IF(POT .LE. 0.0)POT = 0.01
C----------
C CALC FUNCTION OF RELATIVE DENSITY
C----------
      FOFR=1.07528 * (1.0 - EXP(-1.89022 * REL))
C----------
C CALC FUNCTION OF AVE DIA
C----------
      GOFAD=2.1963E-1 * (RMSQD + 1.0) **0.73355
C----------
C CALC MODIFIER VALUE CORRECTED FOR PLOT DENSITY
C THE NEXT TWO LINES ARE A TEMPORARY FIX.
C----------
      BAACT=BA
      IF(BAACT .GE. 310.0) BAACT=305.
      VALMOD=1.0 - EXP(-FOFR * GOFAD * ((310.0-BAACT)/310.0)
     &        **0.5)
  800 CONTINUE
C----------
C CALC PRED DIA IN REAL TERMS CORRECTED FOR SITE
C----------
      PREDGR=POT * VALMOD * (.48630 + 0.01258 * XSITE)
C----------
C CHANGE DG TO LN(DDS)
C----------
      ASPDG=ALOG(2.0*D*BARK*PREDGR + PREDGR*PREDGR)
C
      IF(DEBUG)WRITE(JOSTND,900)D,CR,POT,FOFR,GOFAD,VALMOD,
     & ASPDG,PREDGR,BARK,XSITE
  900 FORMAT(' IN ASPEN DIA GR: D=',F6.1,
     & ' ASPCR=',F5.1,' POT=',E10.4,' FOFR=',E10.4,' GOFAD=',E10.4,
     & ' VALMOD=',E10.4,' ASPDG=',E10.4,/,15X,' PREDGR =',
     &E10.4,'  BARK =',F10.6,'XSITE =',F10.2)
C
      RETURN
      END
