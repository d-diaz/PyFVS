      SUBROUTINE FNDAG(TAGE,SITE,RHT,BAUTBA,DEBUG)
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  **FNDAG--UT  DATE OF LAST REVISION:  11/20/09
C----------
C
C THIS ROUTINE USES THE LOGIC FROM GENGYM THAT CALCULATES A HEIGHT
C GIVEN A SITE TO FIND AN EFFECTIVE AGE.
C EVEN-AGED LOGIC FROM GEMHT
C----------
C  COMMONS
C
C  COMMONS
C----------
      LOGICAL DEBUG
      REAL BAUTBA,RHT,SITE,TAGE,AGETEM,TOL,AP,AGEMAX,HG,HL
      REAL HH,RATIO,HTMAX,CCFTEM,DIFF,TSITE
      INTEGER ISPC
C----------
      TOL = 2.0
      AP = 10.0
      AGEMAX = 210.
C----------
C SPRUCE-FIR -- MODEL TYPE 4
C----------
  100 CONTINUE
      AGETEM = AP
      IF(AGETEM .LT. 30.0) AGETEM=30.
      HH = (2.75780*SITE**0.83312) * ((1.0-EXP(-0.015701*AGETEM))
     &      **(22.71944*SITE**(-0.63557))) + 4.5
C     IF(AP .LT. AGETEM) HH = ((HH-4.5) / AGETEM) * AP + 4.5
      RATIO = 1.0 - BAUTBA
      IF(RATIO .LT. 0.728) RATIO = 0.728
      HH = HH * RATIO
      DIFF = ABS(HH - RHT)
      IF(DIFF .LT. TOL) GO TO 9990
      IF(HH .GT. RHT) GO TO 9990
      AP = AP + 5.0
      IF(AP .GT. AGEMAX)THEN
        TAGE  = AGEMAX
        GO TO 9995
      END IF
      GO TO 100
 9990 CONTINUE
      TAGE = AGETEM
        TSITE=SITE
        IF(TSITE.LT.20.)TSITE=20.
        TAGE=TAGE+4.5/(-0.22+0.0155*TSITE)
 9995 CONTINUE
C
      RETURN
      END
