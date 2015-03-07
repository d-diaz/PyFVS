      SUBROUTINE BFTOPK(ISPC,D,H,BBFV,LCONE,BARK,VMAX,ITHT)
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  **BFTOPK--BASE   DATE OF LAST REVISION:   04/09/08
C----------
C    THIS SUBROUTINE CORRECTS BOARD FOOT VOLUMES FOR DEAD/DAMAGED
C    TOPS.
C
      INCLUDE 'VOLSTD.F77'
C
      LOGICAL LCONE
      INTEGER ITHT,ISPC
      REAL VMAX,BARK,BBFV,H,D,HTRUNC,PHT,DTRUNC,HTMRCH,STUMP
      REAL VOLTK,BEHRE,VOLM
C----------
C  SET PARAMETERS FOR BEHRE HYPERBOLA.
C----------
      IF(BBFV .LE. 0.) GO TO 100
      CALL BEHPRM (VMAX,D,H,BARK,LCONE)
C----------
C  COMPUTE TOTAL BOARD FOOT VOLUME LOSS DUE TO TOPKILL.
C  HEIGHT AND DIAMETER AT THE POINT OF TRUNCATION ARE EXPRESSED
C  AS RATIOS OF "NORMAL" HEIGHT AND DBH (PHT AND DTRUNC,
C  RESPECTIVELY).
C----------
      HTRUNC = ITHT / 100.0
      PHT = 1. - (HTRUNC/H)
      DTRUNC = PHT / (AHAT*PHT + BHAT)
C----------
C  IF THE TOP IS DAMAGED AND THE DIAMETER AT THE POINT OF
C  TRUNCATION IS GREATER THAN THE MERCHANTABLE TOP DIAMETER,
C  CORRECT BOARD FOOT VOLUME ESTIMATE.
C----------
      IF(DTRUNC .GT. BFTOPD(ISPC)/D) THEN
C----------
C     HTMRCH = RATIO OF MERCH. HT (HEIGHT WHERE D=BFTOPD) TO TOTAL
C     HEIGHT.
C----------
        HTMRCH = ((BHAT*BFTOPD(ISPC))/D)/(1. - (AHAT*BFTOPD(ISPC)/D))
C----------
C     ADJUST THE STUMP HEIGHT.
C----------
        STUMP=1.0-BFSTMP(ISPC)/H
        VOLTK=BEHRE(PHT,STUMP)
C----------
C     CORRECT FOR THE TRUNCATED TOP IN THE BFV ESTIMATE
C----------
        IF (LCONE) THEN
          VOLM = STUMP**3-HTMRCH**3.
          VOLTK = STUMP**3. - PHT**3.
          BBFV = BBFV*VOLTK/VOLM
        ELSE
          BBFV = (BBFV*VOLTK) / BEHRE(HTMRCH,STUMP)
        ENDIF
      ENDIF
  100 CONTINUE
      RETURN
      END
