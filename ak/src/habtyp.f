      SUBROUTINE HABTYP (KARD2,ARRAY2)
      use contrl_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **HABTYP--AK   DATE OF LAST REVISION:  02/21/08
C----------
C
C  DUMMY HABITAT ROUTINE USED IN VARIANTS THAT DON'T USE
C  HABITAT TYPE AS A VARIABLE IN GROWTH FUNCTIONS.
C----------
COMMONS
C----------
      INTEGER KODTYP,ITYPE
      REAL ARRAY2
      CHARACTER*10 KARD2
C----------
      KODTYP=0
      ITYPE=0
      ICL5=999
      KARD2='UNKNOWN   '
      PCOM='UNKNOWN '
      IF(LSTART)WRITE(JOSTND,21)
   21 FORMAT(/,T12,'HABITAT TYPE IS NOT USED IN THIS VARIANT')
      RETURN
      END
