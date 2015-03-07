      SUBROUTINE ALGPTG(CTOK,LEN,NUM,IRC)
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     CALLED FROM ALGKEY
C
C     CONVERTS CTOK TO A SPECIES CODE LOAD OPERATION.
C
C     CTOK  = C*10 TOKEN FOUND IN AN EXPRESSION.
C     LEN   = THE LENGTH OF THE TOKEN.
C     NUM   = THE LOAD OP-CODE FOR THE SPECIES.
C     IRC   = RETURN CODE, 0=CTOK WAS FOUND, NUM IS DEFINED.
C             1=CTOK WAS NOT FOUND, NUM IS UNDEFINED.
C
      CHARACTER*20 CTOK,CTEMP
      INTEGER IRC,NUM,LEN,I
C
C     IF CTOK IS A 1 CHAR TOKEN, THEN RIGHT JUSTIFY.  OTHERWISE
C     SIMPLY LOAD CTOK INTO CTEMP.
C
      CTEMP(1:20)=''
      IF (LEN.EQ.1) THEN
         CTEMP(1:1)=' '
         CTEMP(2:2)=CTOK(1:1)
      ELSE
         CTEMP=CTOK
      ENDIF
C
C     SEARCH TRHOUGH POINT GROUP CODES.
C
        DO 955 I=1,NPTGRP
        IF(CTOK(1:LEN).EQ.PTGNAME(I))THEN
          NUM=-(I+2000)
          IRC=0
          GOTO 100
        ENDIF
  955   CONTINUE
C
      IRC=1
      RETURN
  100 CONTINUE
      IRC=0
      RETURN
      END
