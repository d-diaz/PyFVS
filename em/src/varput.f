      SUBROUTINE VARPUT (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      use prgprm_mod
      implicit none
C----------
C EM $Id$
C----------
C
C     WRITE THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
COMMONS
      INCLUDE 'EMCOM.F77'
C
C
COMMONS
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).  
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      PARAMETER (MXL=1,MXI=1,MXR=1)
      LOGICAL LOGICS(*)
      REAL WK3(MAXTRE)
      INTEGER INTS(*)
      REAL REALS(*)
C
C     STORE THE INTEGER SCALARS.
C
      INTS(1) = IEMTYP
      CALL IFWRIT (WK3, IPNT, ILIMIT, INTS, MXI, 2)
C
C     STORE THE LOGICAL SCALARS.
C
C**   CALL LFWRIT (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     STORE THE REAL SCALARS.
C
C**   CALL BFWRIT (WK3, IPNT, ILIMIT, REALS, MXR, 2)
      RETURN
      END

      SUBROUTINE VARCHPUT (CBUFF, IPNT, LNCBUF)
      use prgprm_mod
      implicit none
C----------
C     Put variant-specific character data
C----------

      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      INTEGER IPNT
      ! Stub for variants which need to get/put character data
      ! See /bc/varget.f and /bc/varput.f for examples of VARCHGET and VARCHPUT
      RETURN
      END
