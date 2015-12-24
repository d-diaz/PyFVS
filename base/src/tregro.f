      SUBROUTINE TREGRO
      use contrl_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C    CALLED FROM **MAIN** AND PPMAIN EACH CYCLE.
C----------
COMMONS
C----------
C  DECLARATIONS:
C----------
      LOGICAL LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,LBGCGO,DEBUG
      INTEGER :: ISTOPRES,IRTNCD,ISTOPDONE
      LTMGO=.FALSE.
      LMPBGO=.FALSE.
      LDFBGO=.FALSE.
      LBWEGO=.FALSE.
      LCVATV=.FALSE.
      LBGCGO=.FALSE.
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'TREGRO',6,ICYC)
C-----------
C  GET THE RESTART CODE AND BRANCH ACCORDINGLY.
C-----------
      CALL fvsGetRestartCode (ISTOPRES)
      IF (DEBUG) WRITE(JOSTND,2) ICYC,ISTOPRES
    2 FORMAT (' IN TREGRO, ICYC=',I3,' ISTOPRES=',I3)
      IF (ISTOPRES.GE.5) GOTO 10
C-----------
C  CALL GRINCR TO COMPUTE INCREMENTS AND SEE IF BUG MODELS ARE ACTIVE.
C-----------
      CALL GRINCR (DEBUG,1,LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,LBGCGO)
      CALL getAmStopping (ISTOPDONE)
      IF (ISTOPDONE.NE.0) RETURN

      call fvsStopPoint (5,ISTOPRES)
      IF (ISTOPRES.NE.0) RETURN
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
   10 CONTINUE
C-----------
C  CALL GRADD TO COMPUTE BUGS AND ADD THE INCREMENTS.
C-----------
      CALL GRADD (DEBUG,1,LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,LBGCGO)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C----------
C  END OF CYCLE.
C----------
      IF(DEBUG) WRITE(JOSTND,9022) ICYC
 9022 FORMAT(' END OF TREGRO, CYCLE=',I2)
      RETURN
      END
