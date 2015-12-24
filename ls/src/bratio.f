      FUNCTION BRATIO(IS,D,H)
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  **BRATIO--LS DATE OF LAST REVISION:  07/11/08
C----------
C
C FUNCTION TO COMPUTE BARK RATIOS. THIS ROUTINE IS VARIANT SPECIFIC
C AND EACH VARIANT USES ONE OR MORE OF THE ARGUMENTS PASSED TO IT.
C
      INTEGER IS
      REAL H,D,BRATIO
C
      IF(IS .EQ. 0) THEN
        BRATIO=0.93
      ELSE
        BRATIO=BKRAT(IS)
      ENDIF
      RETURN
      END
