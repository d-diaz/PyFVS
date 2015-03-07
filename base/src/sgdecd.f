      SUBROUTINE SGDECD (ISPC,KARD,IFLAG)
      use contrl_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     DECODE THE SPECIES GROUP CODE.
C     ISPC  = NUMERIC SPECIES CODE.
C     IFLAG = 0 IF SPECIES GROUP IS NOT FOUND; 1 IF IT IS.
C     KARD  = CHARACTER REPRESENTATION OF SPECIES FIELD
C
C----------
      INTEGER IFLAG,ISPC,J,I
      CHARACTER*10 KARD,TEMP
C----------
C  IF ISPC IS A POSITIVE NON-ZERO NUMBER THEN ITS A NUMERIC SPECIES
C  CODE
C----------
      IF(ISPC .GT. 0) THEN
        IFLAG = 0
        GO TO 100
      ENDIF
C----------
C  IF ISPC IS A NEGATIVE NUMBER, THEN ITS A SPECIES GROUP INDICATOR
C----------
      IF(ISPC .LT. 0)THEN
        KARD=NAMGRP(-ISPC)
        IFLAG = 1
        GO TO 100
      ENDIF
C----------
C  ISPC = 0, CHECK FOR ALPHA SPECIES GROUP NAME.
C  LOAD TEMP WITH UP TO THREE NON-BLANK CHARS IN KARD.
C----------
      TEMP='          '
      J=0
      DO 10 I=1,10
      IF (KARD(I:I).NE.' ') THEN
        DO 5 J=1,MIN(10,10-I+1)
        TEMP(J:J)=KARD(I+J-1:I+J-1)
        CALL UPCASE(TEMP(J:J))
    5   CONTINUE
        GOTO 20
      ENDIF
   10 CONTINUE
C----------
C NOTHING WAS FOUND, SO IT MUST BE BLANK AND NOT A SPECIES GROUP NAME.
C----------
      GO TO 50
C----------
C CHECK TO SEE IF THE SPECIES GROUP NAME IS VALID.
C 'ALL' IS SPECIES CODE ZERO AND NOT A VALID GROUP NAME.
C----------
   20 CONTINUE
      IF (TEMP.EQ.'ALL') THEN
        IFLAG = 0
        GO TO 100
      ENDIF
C
      DO 30 I=1,NSPGRP
      IF(TEMP .EQ. NAMGRP(I)) THEN
        ISPC=-I
        IFLAG=1
        GO TO 50
      ENDIF
   30 CONTINUE
C----------
C NO VALID SPECIES GROUP CODE WAS FOUND. RETURN TO CHECK FOR VALID
C ALPHA SPECIES CODE
C----------
      IFLAG = 0
      GO TO 100
C
   50 CONTINUE
      KARD=TEMP
C
  100 CONTINUE
      RETURN
      END
