      SUBROUTINE CMADDS (SAMPRB,NENTRY,LINIT)
      IMPLICIT NONE
C----------
C  **CMADDS--PPBASE    DATE OF LAST REVISION:  07/31/08
C----------
C
C     PART OF THE PARALLEL PROCESSING EXTENSION OF PROGNOSIS SYSTEM.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--MAY 1980
C
C     ADDS THE STAND STATISTICS FOUND IN IOSUM TO THE SUMMARY
C     ARRAYS.  IF THE STAND HAS NEW OR UNIQUE YEARS, THEY ARE
C     ADDED TO THE LIST OF YEARS.  THE POINTER VECTOR, INDEX, IS
C     USED TO ACCESS THE STAND IN CRONOLOGICAL ORDER.  THIS ROUTINE
C     MAINTAINS INDEX BY INSERTING VALUES IN THE LIST WHEN NEW YEARS
C     ARE ENCOUNTERED.
C
C     SAMPRB= THE SAMPLING PROBABILITY ASSOCIATED WITH THIS STAND;
C             IN OTHER WORDS, THE WEIGHT GIVEN THE CURRENT VALUES
C             IN IOSUM.
C     NENTRY= THE NUMBER OF ROWS IN IOSUM (USUALLY EQUAL TO THE
C             NUMBER OF CYCLES PLUS 1).
C     LINIT = TRUE IF MAKING THE FIRST CALL TO THIS SUBROUTINE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PPEPRM.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PPCNTL.F77'
C
C
      INCLUDE 'PPCMAD.F77'
C
C
COMMONS
C
      INTEGER NENTRY,I,IHRV,J,IYR,INDI,K,JCOP,JPRT,I1,I2,IY1,IY2
      REAL SAMPRB,XM
      CHARACTER*5 OUTID
      LOGICAL LINIT,LAUT
C
C     *************************************************************
C
      IF (.NOT.LINIT) GOTO 20
      LEN=NENTRY
      DO 10 I=1,NENTRY
      INDEX(I) = I
      PRBSUM(I) = SAMPRB
C
C     SET IHRV = 0 IF NO HARVESTS HAVE OCCURRED
C                1 IF HARVESTS HAVE OCCURRED (IOSUM(7,I).GT.0).
C
      IHRV=0
      IF (IOSUM(7,I).GT.0) IHRV=1
      HRVSUM(I)=SAMPRB*IHRV
      YEAR(I) = IOSUM(1,I)*10+IHRV
      XM = SAMPRB*IOSUM(14,I)
      ALL(15,I)=IOSUM(15,I)*XM
      ALL(16,I)=IOSUM(16,I)*XM
      DO 5 J=2,14
      ALL(J,I)=IOSUM(J,I)*SAMPRB
    5 CONTINUE
   10 CONTINUE
C
C
      RETURN
C
   20 CONTINUE
C
C     FOR ALL ROWS(YEARS) IN IOSUM:
C
      DO 150 I=1,NENTRY
C
C     (A) FIND THE SUBSCRIPT WHICH POINTS TO THE POSITION IN 'ALL' THAT
C         THE CURRENT YEAR IS TO BE ADDED.  THE SEARCH IS IN YEAR
C         VIA INDEX FOR POSITIONS I THRU LEN.
C
      IHRV=0
      IF (IOSUM(7,I).GT.0) IHRV=1
      IYR = IOSUM(1,I)*10+IHRV
      DO 30 J=1,LEN
      INDI = INDEX(J)
      IF(IYR .EQ. YEAR(INDI)) GOTO 100
      IF(IYR .GT. YEAR(INDI)) GOTO  30
C
C     THE YEAR DOES NOT EXIST: SET INDI EQUAL TO THE POSITION IN IND
C     WHERE A NEW POINTER MUST BE INSERTED.  THEN, BRANCH.
C
      INDI = J
      GOTO 40
   30 CONTINUE
C
C     IF THE DO-LOOP FINISHES, THE YEAR IS GT ANY EXISTING YEAR: A
C     NEW POINTER NEEDS TO BE ADDED TO THE BOTTOM OF THE LIST.
C
      LEN = LEN+1
      INDI = LEN
      INDEX(J) = LEN
      GOTO 60
   40 CONTINUE
C
C     A NEW POINTER NEEDS TO BE INSERTED AT POSITION INDI. FIRST,
C     MAKE ROOM IN INDEX.
C
      LEN = LEN+1
      IF (LEN.GT.MXCMRW) CALL PPERRP (.FALSE.,11)
      J = LEN-INDI
      DO 50 K=1,J
      INDEX(LEN-K+1) = INDEX(LEN-K)
   50 CONTINUE
C
C     SECOND, INSERT THE POINTER
C
      INDEX(INDI) = LEN
   60 CONTINUE
C
C     (B) DEFINE A NEW ROW IN ARRAY ALL (THIS IS ONLY DONE WHEN
C         THE YEAR DOES NOT ALREADY EXIST).
C
      YEAR(LEN) = IYR
      XM = SAMPRB*IOSUM(14,I)
      ALL(15,LEN)=IOSUM(15,I)*XM
      ALL(16,LEN)=IOSUM(16,I)*XM
      DO 70 J=2,14
      ALL(J,LEN) = IOSUM(J,I)*SAMPRB
   70 CONTINUE
      PRBSUM(LEN) = SAMPRB
      HRVSUM(LEN) = SAMPRB*IHRV
      GOTO 150
  100 CONTINUE
C
C     (C) ADD THE CORRECT ROW(=I) IN IOSUM TO THE CORRCET ROW(=INDI)
C     IN ALL.
C
      PRBSUM(INDI) = PRBSUM(INDI)+SAMPRB
      HRVSUM(INDI) = HRVSUM(INDI)+(SAMPRB*IHRV)
      XM = SAMPRB*IOSUM(14,I)
      ALL(15,INDI)=ALL(15,INDI)+IOSUM(15,I)*XM
      ALL(16,INDI)=ALL(16,INDI)+IOSUM(16,I)*XM
      DO 120 J=2,14
      ALL(J,INDI) = ALL(J,INDI)+IOSUM(J,I)*SAMPRB
  120 CONTINUE
  150 CONTINUE
      RETURN
C
C
      ENTRY CMPRT(JPRT,JCOP)
C
      IF (PDEBUG)  WRITE (JOPPRT,
     >             '('' IN CMPRT, JPRT, JCOP='',2I4)') JPRT,JCOP
C
C     FIND AND COMBINE ROWS WITH EQUAL YEARS.
C
      INDI=LEN-1
      DO 170 I=1,INDI
      I1=INDEX(I)
      IF (I1.LE.0) GOTO 170
      I2=INDEX(I+1)
      IY1=YEAR(I1)/10
      IY2=YEAR(I2)/10
      IF (IY1.NE.IY2) GOTO 170
      DO 160 J=2,16
      ALL(J,I1)=ALL(J,I1)+ALL(J,I2)
  160 CONTINUE
      PRBSUM(I1)=PRBSUM(I1)+PRBSUM(I2)
      HRVSUM(I1)=HRVSUM(I1)+HRVSUM(I2)
C
C     SIGNAL A COMBINATION BY TURNING THE SIGN BIT ON.
C
      INDEX(I+1)=-INDEX(I+1)
  170 CONTINUE
C
C     CALCULATE THE AVERAGE BY ATTRIBUTE AND PRINT THE SUMMARY.
C     THE TOTALS ARE STORED AS REAL NUMBERS, AS THEY ARE AVERAGED,
C     CONVERT THEM TO INTEGERS.
C
      DO 300 I=1,LEN
      INDI=INDEX(I)
      IF (INDI.LE.0) GOTO 300
      IALL(1,INDI)=YEAR(INDI)/10
      DO 220 J=2,13
      IF (J.LT.7 .OR. J.GT.10) THEN
         XM=PRBSUM(INDI)
      ELSE
         XM=HRVSUM(INDI)
      ENDIF
      IF (XM.LT.1E-20) THEN
         IALL(J,INDI)=0
      ELSE
         IALL(J,INDI)=IFIX(ALL(J,INDI)/XM+.5)
      ENDIF
  220 CONTINUE
      IALL(17,INDI)=IFIX(PRBSUM(INDI)+.5)
      IF (PRBSUM(INDI).GT.1E-20) THEN
         HRVSUM(INDI)=HRVSUM(INDI)/PRBSUM(INDI)
      ELSE
         HRVSUM(INDI)=0.0
      ENDIF
C
C     IF COL 14 (GROWTH PERIOD) IS ZERO; THEN: COLS 15 AND 16 WILL
C     BE SET EQUAL TO ZERO.
C
      IF (ALL(14,INDI) .GE. 1E-10) THEN
         IALL(15,INDI)=IFIX(ALL(15,INDI)/ALL(14,INDI)+.5)
         IALL(16,INDI)=IFIX(ALL(16,INDI)/ALL(14,INDI)+.5)
         IALL(14,INDI)=IFIX(ALL(14,INDI)/PRBSUM(INDI)+.5)
      ELSE
         IALL(14,INDI)=0
         IALL(15,INDI)=0
         IALL(16,INDI)=0
      ENDIF
  300 CONTINUE
C
C     ASSIGN THE MGMID FOR THE COMPOSITE YIELD TABLE.
C
      IF (CMPID.EQ.NSET) THEN
         CALL PPAUID (LAUT,OUTID)
         IF (.NOT.LAUT) OUTID='NONE'
      ELSE
         OUTID=CMPID
      ENDIF
C
C     PRINT VIA CMPRT2
C
      CALL CMPRT2(IALL,HRVSUM,INDEX,JPRT,JCOP,LEN,OUTID)
      IF (JCOP.GT.0) WRITE (JOPPRT,250) LEN,JCOP,OUTID
  250 FORMAT (/' NOTE: ',I3,' LINES OF COMPOSITE DATA WERE WRITTEN TO ',
     >        'THE DATA SET REFERENCED BY ',I2,' AND LABELED "',A4,'"')
      RETURN
      END