      SUBROUTINE OPMERG (NMYA,MYACTS,NTODO)
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C
C     OPTION PROCESSING ROUTINE - NL CROOKSTON - JAN 1981 - MOSCOW
C
C     OPMERG TAKES A LIST OF POSSIBLE ACTIVITIES (MYACTS) AND
C     FORMS A LIST OF POINTERS TO ACTIVITIES TO DO (IPTODO) WHICH
C     ARE BOTH WITHIN THE CURRENT CYCLE AND WITHIN 'MYACTS'.
C
      INTEGER MYACTS(NMYA),NTODO,NMYA,IPA,IMYA,MY,I,IA
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
C     SET THE NUMBER OF ACTIVITIES TO DO EQUAL TO ZERO.
C
      NTODO=0
C
C     IF 1. THERE ARE NO ACTIVITIES FOR THIS CYCLE, OR
C        2. YOU HAVE INDECATED YOU HAVE NO ACTIVITIES (NMYA=0), OR
C        3. THE LOWEST VALUE OF YOUR ACTIVITIES IS GREATER THAN THE
C           LARGEST ACTIVITY SCHEDULED FOR THIS CYCLE, OR
C        4. THE HIGHEST VALUE OF YOUR ACTIVITIES IS LESS THAN THE
C           LOWEST ACTIVITY SCHEDULED FOR THIS CYCLE.
C
C     THEN: RETURN
C
      IF (IMG1 .EQ. 0) RETURN
      IF (NMYA .EQ. 0) RETURN
      IPA=IOPCYC(IMG2)
      IF (MYACTS(1) .GT. IACT(IPA,1)) RETURN
      IPA=IOPCYC(IMG1)
      IF (MYACTS(NMYA) .LT. IACT(IPA,1)) RETURN
C
C     ELSE: PREFORM THE MERGE
C
C     LOAD THE FIRST "MY" ACTIVITY
C
      IMYA=1
      MY=MYACTS(1)
C
C     DO FOR ALL ACTIVITIES IN THIS CYCLE IN ORDER OF ASSENDING
C     MAGNITUDE OF ACTIVITY CODES (PLACED IN ORDER BY OPCSET).
C
      DO 30 I=IMG1,IMG2
      IPA=IOPCYC(I)
C
C     IF THIS ACTIVITY IS MARKED ACCOMPLISHED OR DELETED;
C     THEN SKIP IT AND GO ON.
C
      IF (IACT(IPA,4) .NE. 0) GOTO 30
      IA=IACT(IPA,1)
C
C     RETEST-MY-ACTIVITY:
C
   10 CONTINUE
C
C     IF THE "MY" ACTIVITY IS GREATER THAN THE SCHEDULED ACTIVITY;
C     THEN: GO ON TO NEXT SCHEDULED ACTIVITY.
C
      IF (MY.GT.IA) GOTO 30
C
C     IF THE "MY" ACTIVITY IS LESS THAN THE SCHEDULED ACTIVITY;
C
      IF (MY .EQ. IA) GOTO 20
C
C     THEN: INCREMENT IMYA
C
      IMYA=IMYA+1
C
C     IF ALL "MY" ACTIVITIES HAVE BEEN SCANED;
C     THEN: SEARCH IS COMPETE
C
      IF (IMYA .GT. NMYA) GOTO 40
C
C     ELSE: RELOAD MY AND RETEST MY.
C
      MY=MYACTS(IMYA)
      GOTO 10
   20 CONTINUE
C
C     ELSE: THE "MY" ACTIVITY IS EQUAL TO THE SCHEDULED ACTIVITY;
C     INCREMENT NTODO, SAVE THE POINTER (IPA) IN IPTODO(NTODO)
C     AND GO ON TO THE NEXT SCHEDULED ACTIVITY.
C
      NTODO=NTODO+1
      IF (NTODO.GT.MXPTDO) THEN
         CALL ERRGRO (.TRUE.,10)
         GOTO 40
      ENDIF
      IPTODO(NTODO)=IPA
   30 CONTINUE
C
   40 CONTINUE
C
C     MEARGE IS COMPLETE:
C     IF THERE WERE NO MATCHES (NTODO IS ZERO);
C     THEN: RETURN
C
      IF (NTODO .EQ. 0) RETURN
C
C     ELSE: SORT THE POINTERS TO THE MACTCHED LIST ON THE DATE ARRAY
C
      CALL OPSORT (NTODO,IDATE,ISEQ,IPTODO,.FALSE.)
      RETURN
      END