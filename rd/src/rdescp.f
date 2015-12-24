      SUBROUTINE RDESCP (LMAXTR,MXRR)
      use prgprm_mod
      implicit none
C----------
C  **RDESCP      LAST REVISION:  08/28/14
C----------
C
C  THIS ROOT DISEASE MODEL SUBROUTINE INSURES THAT THERE IS ROOM
C  IN THE TREELIST FOR ESTAB TREES. IF THERE IS ACTIVE ROOT DISEASE,
C  MXRR WILL BE RETURNED AS THE RD MODEL TREE RECORD LIMIT (IRRTRE).
C
C  CALLED BY :
C     ESTAB   [PROGNOSIS]
C
C  PARAMETERS :
C     LMAXTR - MAXIMUM NUMBER OF PROGNOSIS MODEL TREE RECORDS
C              (NAME CHANGED TO AVOID CONFLICT WITH MAXTRE IN
C               PRGPRM FILE.)
C     MXRR   - MAXIMUM NUMBER OF RROT TREE RECORDS
C
C  Revision History :
C   08/14/12 - Last revision date.
C   08/28/14 Lance R. David (FMSC)
C
C----------------------------------------------------------------------
C
      INCLUDE  'RDPARM.F77'
      INCLUDE  'RDCOM.F77'
C
      INTEGER  IDI, LMAXTR, MXRR
      REAL     TPAREA

      TPAREA = 0.0
      DO 100 IDI=1,ITOTRR
         TPAREA = TPAREA + PAREA(IDI)
  100 CONTINUE

      IF (IROOT .EQ. 0 .OR. TPAREA .EQ. 0.0) THEN
         MXRR = LMAXTR
      ELSE
         MXRR = IRRTRE
      ENDIF

      RETURN
      END
