      SUBROUTINE DFBINV
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **DFBINV  DATE OF LAST REVISION:  06/30/10
C----------
C
C  COUNTS THE TREES/ACRE OF DOUGLAS-FIR READ IN AS KILLED BY DFB.
C
C  CALLED BY :
C     MAIN     [PROGNOSIS]
C
C  CALLS :
C     NONE
C
C  LOCAL VARIABLES :
C     I      - INDEX TO RECENTLY ATTACKED TREES.
C     II     - COUNTER.
C
C  COMMON BLOCK VARIABLES USED :
C     IPT    - (DFBCOM)  INPUT
C     LINV   - (DFBCOM)  INPUT
C     NDAMS  - (DFBCOM)  INPUT
C     PREKLL - (DFBCOM)  OUTPUT
C     PROB   - (ARRAYS)  INPUT
C
      INCLUDE 'DFBCOM.F77'
C

      INTEGER I, II

C.... COUNT THE TREES/ACRE KILLED BY DFB AND READ IN THROUGH DAMAGE
C.... CODES IN THE TREE LIST DATA.

      IF (NDAMS .GT. 0 .AND. LINV) THEN
         PREKLL = 0.0
         DO 100 II = 1,NDAMS
            I = IPT(II)
            PREKLL = PREKLL + PROB(I)
  100    CONTINUE
      ENDIF

      RETURN
      END
