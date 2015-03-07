      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,IHTSER,GENTIM,
     &                   TRAGE)
      use esparm_mod
      use contrl_mod
      use escomn_mod
      use prgprm_mod
      implicit none
C----------
C  **ESSUBH--BM  DATE OF LAST REVISION:  04/10/09
C----------
C     CALLED FROM ***ESTAB
C     CALLS ***SMHTGF
C----------
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,IHTSER,N,ITIME
      REAL    AGE,EMSQR,DILATE,DELAY,ELEV,GENTIM,H,HHT,TRAGE
C----------
C     ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C     CREATED BY THE ESTABLISHMENT MODEL.
C     COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON
C     THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER
C     BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF THE
C     CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING
C     THE TREE.
C----------
      CALL DBCHK (DEBUG,'ESSUBH',6,ICYC)
      IF(DEBUG)
     &WRITE(JOSTND,*)' ENTERING ESSUBH - ICYC, TRAGE= ',ICYC,TRAGE
C
      N=DELAY+0.5
      IF(N.LT.-3) N=-3
      DELAY=FLOAT(N)
      ITIME=TIME+0.5
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      TRAGE=TIME-DELAY
C----------
C  CALL SMHTGF TO CALCULATE SEEDLING HEIGHT AT AGE "AGE".
C----------
      CALL SMHTGF (I,HHT,H,0,AGE,ICYC,JOSTND,DEBUG)
C
      IF(DEBUG) THEN
      WRITE(JOSTND,*)' LEAVE ESSUBH -ICYC,I,AGE,TRAGE,TIME,DELAY,HHT= ',
     &ICYC,I,AGE,TRAGE,TIME,DELAY,HHT
      ENDIF
C
      RETURN
      END
