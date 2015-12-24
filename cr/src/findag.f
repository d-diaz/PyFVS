      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &                  DEBUG)
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C CR $Id$
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C
CALLS **FNDAG
C----------
C COMMONS
C
      INCLUDE 'GGCOM.F77'
C
C COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,ICLS
      REAL BAUTBA,SITE,EFFAGE
      REAL D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2
C
      ICLS = IFIX(D1+1.0)
      IF(ICLS .GT. 41) ICLS = 41
      BAUTBA = BAU(ICLS)/BA
      IF(BAUTBA.LT.0.0)BAUTBA=0.0
      SITE = SITEAR(ISPC)
      CALL FNDAG(I,EFFAGE,SITE,H,BAUTBA,ISPC,DEBUG)
      IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG I,EFFAGE,SITE,H,',
     &'BAUTBA,ISPC= ',I,EFFAGE,SITE,H,BAUTBA,ISPC
      SITAGE = EFFAGE
      IF(SITAGE .LE. 0.0) SITAGE = 1.0
C
      RETURN
      END
