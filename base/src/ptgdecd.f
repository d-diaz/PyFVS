      SUBROUTINE PTGDECD(POINTNO,KARD,IFLAG)
      use contrl_mod
      use prgprm_mod
      implicit none
C----------
C  $Id: ptgdecd.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C     DECODE THE POINT GROUP NAME CODE
C     POINTNO IS THE POINT NUMBER, IF THE POINT GROUP IS A NAME,
C                THEN ASSIGN A SEQUENTIAL, NEGATIVE, GROUP NUMBER
C     IFLAG = 0 IF POINT GROUP IS NOT FOUND; 1 IF IT IS.
C     KARD  = CHARACTER REPRESENTATION OF POINT FIELD
C
C----------
      INTEGER IFLAG,POINTNO,J,I
      CHARACTER*10 TEMP
      CHARACTER*10 KARD
C----------
C  IF ISPC IS A POSITIVE NON-ZERO NUMBER THEN ITS A NUMERIC SPECIES
C  CODE
C----------
      IF(POINTNO .GT. 0) THEN
        IFLAG = 0
        GO TO 100
      ENDIF
C----------
C  POINTNO = 0, CHECK FOR ALPHA POINT GROUP NAME.
C  LOAD TEMP WITH UP TO TEN NON-BLANK CHARS IN KARD.
C----------
      TEMP='          '
      J=0
      DO 10 I=1,10
      IF (KARD(I:I).NE.' ') THEN
        DO 5 J=1,MIN(10,10-I+1)
        TEMP(J:J)=KARD(I+J-1:I+J-1)
        CALL UPCASE(TEMP(J:J))
    5   CONTINUE
C        GOTO 20
        EXIT
      ENDIF
   10 CONTINUE
C
   20 CONTINUE
      DO 30 I=1,NPTGRP
      IF(TEMP .EQ. PTGNAME(I)) THEN
        POINTNO=-I
        IFLAG=1
        GO TO 50
      ENDIF
   30 CONTINUE
C
      IFLAG = 0
      GO TO 100
C
   50 CONTINUE
      KARD=TEMP
C
  100 CONTINUE
C----------
C NOTHING WAS FOUND, SO IT MUST BE BLANK AND NOT A POINT GROUP NAME.
C----------
      RETURN
      END
C----------
