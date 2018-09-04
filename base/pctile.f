      SUBROUTINE PCTILE (N,INDEX,CHAR,PERCNT,TOT)
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C
C   THIS SUBROUTINE COMPUTES PERCENTILE WITHIN THE DISTRIBU-
C   TION OF A REAL VECTOR (SUCH THAT THE LARGEST ELEMENT HAS
C   A PERCNT((I)=100.0, WHERE I=INDEX(I)) AND ALSO COMPUTES
C   THE SUMS OF THE VECTOR.  VARIABLES USED ARE:
C
C     CHAR -- ARRAY LOADED WITH REAL VECTOR VALUES FOR EACH
C             RECORD
C
C    INDEX -- INDEXING ARRAY WHICH POINTS TO THE MEMBERS OF
C             'CHAR' IN DESCENDING ORDER.
C
C        N -- CURRENT NUMBER OF RECORDS
C
C   PERCNT -- ARRAY LOADED WITH VECTOR PERCENTILES FOR EACH
C             RECORD
C
C      TOT -- SUM OF THE VECTOR VALUES
C
C----------
C   DECLARATIONS
C----------
      INTEGER N,NM1,INDN,I,J,INDJP1,INDJ,INDX1,INDI
      REAL TOT,PERCNT(*),PCTIN1,CHAR(*)
      INTEGER INDEX(*)
C
      IF(N .EQ. 0) THEN
        PERCNT(1)=0.
        TOT=0.
      ELSE
        PERCNT(1)= 100.
        TOT=CHAR(1)
      ENDIF
C----------
C   RETURN IF ONLY 1 RECORD
C----------
      IF( N .LE. 1 )RETURN
      NM1 = N - 1
      INDN = INDEX(N)
      PERCNT(INDN) = CHAR(INDN)
C----------
C   ACCUMULATE THE SUM OF THE VECTORS
C----------
      DO 10 I = 1,NM1
      J = N-I
      INDJP1 = INDEX(J+1)
      INDJ = INDEX(J)
      PERCNT(INDJ)=PERCNT(INDJP1)+CHAR(INDJ)
   10 CONTINUE
      INDX1 = INDEX(1)
C----------
C   DESIGNATE THE SUM
C---------
      TOT = PERCNT(INDX1)
      PERCNT(INDX1) = TOT/100.
C----------
C   RETURN IF THE SUM IS LESS THAN OR EQUAL TO 0.0
C----------
      IF ( TOT .LE. 0.0 )  RETURN
      PCTIN1= PERCNT(INDX1)
      DO 20 I = 2,N
      INDI = INDEX(I)
C----------
C   COMPUTE THE PERCENTILE WITHIN THE DISTRIBUTION
C----------
      PERCNT(INDI)=PERCNT(INDI)/PCTIN1
   20 CONTINUE
      PERCNT(INDX1) = 100.
      RETURN
      END
