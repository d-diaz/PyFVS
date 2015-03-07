      SUBROUTINE FORKOD
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  **FORKOD--AK   DATE OF LAST REVISION:  02/14/08
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
C----------
C  NATIONAL FORESTS:
C  1003 = TONGASS: CHATHAM AREA
C  1002 = TONGASS: STIKINE AREA
C  1005 = TONGASS: KETCHIKAN AREA
C   701 = BRITISH COLUMBIA / MAKAH INDIAN RESERVATION
C  1004 = CHUGACH
C----------
      INTEGER JFOR(7),KFOR(7),NUMFOR,I
      DATA JFOR/1003,1002,1005,701,1004,2*0/, NUMFOR/5/
      DATA KFOR/1,1,1,1,1,1,1 /
C
      IF (KODFOR .EQ. 0) GOTO 30
      DO 10 I=1,NUMFOR
      IF (KODFOR .EQ. JFOR(I)) GOTO 20
   10 CONTINUE
      CALL ERRGRO (.TRUE.,3)
      WRITE(JOSTND,11) JFOR(IFOR)
   11 FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS ',I4)
      GOTO 30
   20 CONTINUE
      IFOR=I
      IF(IFOR.EQ.5)THEN
        WRITE(JOSTND,22)
   22   FORMAT(T12,'FOREST CODE 1004 BEING MAPPED TO 1003 FOR THE',
     &  ' GROWTH RELATIONSHIPS USED IN THIS PROJECTION')
        IFOR=1
        GO TO 40
      ENDIF
      IGL=KFOR(I)
   30 CONTINUE
      KODFOR=JFOR(IFOR)
   40 CONTINUE
      RETURN
      END
