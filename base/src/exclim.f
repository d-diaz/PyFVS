      SUBROUTINE EXCLIM
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C
C     EXTRA EXTERNAL REFERENCES FOR CLIMATE EXTENSION CALLS
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
COMMONS
C
      LOGICAL DEBUG,LKECHO,L
      INTEGER KEY,IPNT,ILIMIT,ISP,IRC
      CHARACTER*8 KEYWRD,NOCLIM 
      REAL SDIDEF(MAXSP),XMAX,TREEMULT(MAXTRE),WK3(MAXTRE),VIA
      REAL DANUW
      LOGICAL LDANUW
      REAL DANUW
      LOGICAL LDANUW
C
      DATA NOCLIM/'*NO CLIM'/
C
C----------
C  ENTRY CLINIT
C----------
      ENTRY CLINIT
      RETURN
C
C----------
C  ENTRY CLACTV
C----------
      ENTRY CLACTV (L)
      L=.FALSE.
      RETURN
C
C----------
C  ENTRY CLSETACTV
C----------
      ENTRY CLSETACTV (L)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      LDANUW = L
C
      RETURN
C
C----------
C  ENTRY CLPUT
C----------
      ENTRY CLPUT (WK3,IPNT,ILIMIT)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = WK3(1)
      DANUW = REAL(IPNT)
      DANUW = REAL(ILIMIT)
C
      RETURN
C
C----------
C  ENTRY CLGET
C----------
      ENTRY CLGET (WK3,IPNT,ILIMIT)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = WK3(1)
      DANUW = REAL(IPNT)
      DANUW = REAL(ILIMIT)
C
      RETURN
C
C----------
C  ENTRY CLIN
C----------
      ENTRY CLIN  (DEBUG,LKECHO)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      LDANUW = DEBUG
      LDANUW = LKECHO
C
      CALL ERRGRO (.TRUE.,11)
      RETURN
C
C----------
C  ENTRY CLKEY
C----------
      ENTRY CLKEY(KEY,KEYWRD)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(KEY)
C
      KEYWRD=NOCLIM 
      RETURN
C
C----------
C  ENTRY CLGMULT
C----------
      ENTRY CLGMULT(TREEMULT)
      TREEMULT=1.
      RETURN
C
C----------
C  ENTRY CLMORTS
C----------
      ENTRY CLMORTS 
      RETURN
C
C----------
C  ENTRY CLMAXDEN
C----------
      ENTRY CLMAXDEN (SDIDEF,XMAX)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = SDIDEF(1)
      DANUW = XMAX
C
      RETURN 
C
C----------
C  ENTRY CLAUESTB
C----------
      ENTRY CLAUESTB
      RETURN
C
C----------
C  ENTRY CLSPVIAB
C----------
      ENTRY CLSPVIAB (ISP,VIA,IRC)
      IRC=1
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = VIA
      DANUW = REAL(ISP)
      RETURN
C
C
      END
