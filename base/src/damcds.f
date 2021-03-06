      SUBROUTINE DAMCDS (II,ICODES)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     II    = TREE POINTER FOR LIVE TREES
C     ICODES= DISEASE AND DAMAGE CODES ARRAY
C
C----------
C
      INTEGER   I,II
      INTEGER*4 IDD
      INTEGER ICODES(6)

C----------
C  CALL SUBROUTINE TO PROCESS DAMAGE CODES FOR BASE MODEL (SPECIAL
C  TREE STATUS CODES, PERCENT DEFECT).
C----------
      CALL BASDAM (II,ICODES)

C----------
C  STORE DAMAGE CODES FOR LATER PEST EXTENSION PROCESSING.
C----------
      DO I = 1,6
        DAMSEV(I,II) = ICODES(I)
      END DO

      RETURN
      END
