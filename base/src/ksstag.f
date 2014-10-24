      SUBROUTINE KSSTAG (IPRINT,KEYWRD,LNOTBK,ARRAY,LKECHO)
      IMPLICIT NONE
C----------
C  $Id: ksstag.f 1333 2014-10-23 17:49:02Z tod.haren $
C----------
C
C   THIS SUBROUTINE PROCESSES THE KEYWORD FOR THE STAND STRUCTURAL  
C   CLASSES CALCULATIONS.  SEE SUBROUTINE SSTAGE.
C
C   N.L.CROOKSTON - INT MOSCOW - JUNE 1996 AND WITH
C   A.R.STAGE - INT MOSCOW - JUNE 1997
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'SSTGMC.F77'
C
C
COMMONS
C

      CHARACTER*8  KEYWRD
      REAL         ARRAY(7)
      INTEGER      IPRINT
      LOGICAL      LNOTBK(7),LKECHO

C     TURN ON THE CALCULATIONS.

      LCALC = .TRUE.

C     PROCESS THE KEYWORD FOR THE STRUCTURAL STAGE ROUTINE.

C     IF THE FIRST FIELD CONTAINS A CHARACTER, THEN WE ARE PRINTING.   

      IF (LNOTBK(1)) THEN
         IF (ARRAY(1).EQ.0) THEN
            LPRNT = .FALSE.
         ELSE
            LPRNT = .TRUE.
         ENDIF
      ENDIF
      IF (LPRNT) THEN
         ARRAY(1)=1.
      ELSE
         ARRAY(1)=0.
      ENDIF

C     THE PERCENTAGE OF A TREE HEIGHT THAT A GAP MUST EXCEED.      

      IF (LNOTBK(2)) GAPPCT=ARRAY(2)

C     THE DBH BREAK BETWEEN SEEDLING/SAPLINGS AND POLE-SIZED TREES

      IF (LNOTBK(3)) SSDBH=ARRAY(3)

C     THE DBH BREAK BETWEEN POLES-SIZED TREES AND LARGE (OLDER)

      IF (LNOTBK(4)) SAWDBH=ARRAY(4)

C     THE MINIMUM COVER PERCENT TO QUALIFY A POTENTIAL STRATUM.

      IF (LNOTBK(5)) CCMIN=ARRAY(5)

C     THE MINIMUM TREES/ACRE THAT MUST BE EXCEEDED FOR A STAND
C     THAT HAS LESS THAN 5% COVER TO BE CLASSIFIED STAND INIT.

      IF (LNOTBK(6)) TPAMIN=ARRAY(6)

C     THE PERCENTAGE OF THE MAXIMUM STAND DENSITY INDEX THAT MUST
C     BE EXCEEDED FOR A STAND TO BE CLASSIFIED STEM EXCLUSION
C     RATHER THAN STAND INITIATION

      IF (LNOTBK(7)) PCTSMX=ARRAY(7)

      IF(LKECHO)WRITE (IPRINT,200) KEYWRD,ARRAY(1),GAPPCT,SSDBH,
     >                   SAWDBH,CCMIN,TPAMIN,PCTSMX
  200 FORMAT (/A8,'   STAND STRUCTURAL CLASSES WILL BE ',
     >  'COMPUTED.'/T12,
     >  'OUTPUT PRINTING CODE = ',F3.0,' (0=NO OUTPUT, 1=PRINT)'/T12,
     >  'THE PERCENTAGE OF A TREE HEIGHT THAT A GAP MUST EXCEED =',
     >   T76,F6.1/T12,
     >  'THE DBH BREAK BETWEEN SEEDLING/SAPLINGS AND ',
     >  'POLE-SIZED TREES =',T76,F6.1/T12,
     >  'THE DBH BREAK BETWEEN POLE-SIZED AND LARGE, OLDER, TREES =',
     >   T76,F6.1/T12,
     >  'THE MINIMUM COVER PERCENT TO QUALIFY A POTENTIAL STRATUM =',
     >   T76,F6.1/T12,
     >  'THE MINIMUM TREE/ACRE TO BE CLASSIFIED STAND INITIATION =',
     >   T76,F6.1/T12,
     >  'THE MINIMUM PERCENT OF MAXSDI TO BE CLASSIFIED ', 
     >  'STEM EXCLUSION =',T76,F6.1)
      RETURN
      END
