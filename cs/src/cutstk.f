      SUBROUTINE CUTSTK
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **CUTSTK--CS   DATE OF LAST REVISION:  05/19/08
C----------
C  THIS SUBROUTINE CONTAINS ENTRY POINTS FOR CALCULATING STOCKING
C  LEVELS FOR VARIOUS THINNING OPTIONS.
C----------
COMMONS
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
C----------
      LOGICAL DEBUG,LINCL
      REAL BASP(5),A1(5),A2(5),A3(5),TPRED(5)
      INTEGER JJSP(MAXSP)
      REAL FSTOCK,TOTBA,STTPA,HU,HL,DU,DL,CSTOCK,D,H,TPA
      INTEGER I,IISPG,JPNUM,JSPCUT,JTYP,IC,IGRP,IULIM,IG
      DATA A1/-.5779,-.5373,-.3430,-.1433,-.1879/
      DATA A2/16.9246,23.1713,10.7172,7.1389,9.0272/
      DATA A3/45.7353,60.8299,43.0417,34.3018,46.7800/
C----------
C  PUT SPECIES IN ONE OF 5 STOCKING CATEGORIES
C
C  SPECIES GROUP 1 - SHORTLEAF PINE
C  SPECIES GROUP 2 - EASTERN WHITE PINE
C  SPECIES GROUP 3 - OAKS
C  SPECIES GROUP 4 - NORTHERN HARDWOOD
C  SPECIES GROUP 5 - NORTHERN HARDWOODS  50-100% BASSWOOD
C----------
      DATA JJSP/5*1,2*2,2*3,18*4,3,3*4,3,8*4,3,5,4*4,21*3,10*4,19*3/
C
C----------
C  SEE IF WE NEED TO DO SOME DEBUG
C----------
      CALL DBCHK (DEBUG,'CUTSTK',6,ICYC)
C----------
C  ENTRY AUTSTK CALCULATES NORMAL STOCKING FOR AUTOMATIC THINS.
C
C  VARIABLE DEFINITIONS:
C  A1,A2,A3  COEFFICIENTS TO PREDICT TPA BY STOCKING CATEGORY
C  TPRED     TREES PER ACRE FOR THE STAND AT 100% STOCKING-
C            BY STOCKING CATEGORY.
C  STTPA     NUMBER OF TREES PER ACRE PREDICTED FOR THE NEW STAND AT
C            100% STOCKING--INCLUDES ALL SIX STOCKING CATEGORIES
C-----------
      ENTRY AUTSTK (FSTOCK)
      DO 10 I=1,5
      BASP(I) = 0.0
      TPRED(I) = 0.0
   10 CONTINUE
      TOTBA = 0.0
C----------
C  DETERMINE TOTAL NUMBER OF TREES PER ACRE IN EACH SPECIES GROUP
C----------
      DO 20 I=1,ITRN
      IISPG = JJSP(ISP(I))
      BASP(IISPG) = BASP(IISPG) + .0054542*DBH(I)*DBH(I)*PROB(I)
   20 CONTINUE
C----------
C  RECALCULATE STOCKING PERCENT FOR LIVE TREES ONLY (ISTATUS = 1).
C----------
      DO 30 I=1,5
      IF(BASP(I) .EQ. 0.0) THEN
        TPRED(I)= 1.0
        GO TO 30
      ENDIF
      TOTBA=BASP(I)+TOTBA
C----------
C  CALCULATE PREDICTED TREES PER ACRE FOR EACH SPECIES GROUP
C----------
      TPRED(I) =(A1(I)*RMSQD*RMSQD+A2(I)*RMSQD+A3(I))/
     &                (.0054542*RMSQD*RMSQD)
   30 CONTINUE
C----------
C  WEIGHT PREDICTED TPA FOR EACH STOCKING CATEGORY BY PERCENT BA IN
C  EACH STOCKING CATEGORY
C----------
      STTPA = (BASP(1)*TPRED(1)+BASP(2)*TPRED(2)+BASP(3)*TPRED(3)
     &           +BASP(4)*TPRED(4)+BASP(5)*TPRED(5))/TOTBA
      FSTOCK = STTPA
      RETURN
C
C-----------
C  ENTRY CLSSTK COMPUTES BA OR TPA STOCKING IN A SPECIFIED
C  DBH/HT/SPECIES CLASS.
C
C  CSTOCK = CLASS STOCKING
C  JTYP   = 1 IF STOCKING IS IN TPA,  2 IF STOCKING IS IN BA
C  JSPCUT = SPECIES WHICH WILL BE CUT
C  LINCL  = LOGICAL VARIABLE USED TO INCLUDE SPECIES OR NOT.
C  DL,DU  = LOWER AND UPPER DIAMETER LIMITS RESPECTIVELY (GE,LT)
C  HL,HU  = LOWER AND UPPER HEIGHT LIMITS RESPECTIVELY (GE,LT)
C  JPNUM = POINT NUMBER (IN FVS SEQUENCE FORMAT), 0 = ALL POINTS
C----------
      ENTRY CLSSTK (CSTOCK,JTYP,JSPCUT,DL,DU,HL,HU,JPNUM)
      CSTOCK=0.0
      DO 100 IC=1,ITRN
      IF(JPNUM.GT.0 .AND. ITRE(IC).NE.JPNUM)GO TO 100
C
      LINCL = .FALSE.
      IF(JSPCUT.EQ.0 .OR. JSPCUT.EQ.ISP(IC))THEN
        LINCL = .TRUE.
      ELSEIF(JSPCUT.LT.0)THEN
        IGRP = -JSPCUT
        IULIM = ISPGRP(IGRP,1)+1
        DO 60 IG=2,IULIM
        IF(ISP(IC) .EQ. ISPGRP(IGRP,IG))THEN
          LINCL = .TRUE.
          GO TO 61
        ENDIF
   60   CONTINUE
      ENDIF
   61 CONTINUE
C
      IF (LINCL) THEN
        D=DBH(IC)
        H=HT(IC)
        TPA=WK4(IC)
        IF(JPNUM.GT.0)TPA=TPA*(PI-FLOAT(NONSTK))
        IF(D.LT.DL .OR. D.GE.DU) GO TO 100
        IF(H.LT.HL .OR. H.GE.HU) GO TO 100
        IF(JTYP.EQ.1) THEN
          CSTOCK=CSTOCK + TPA
        ELSE
          CSTOCK=CSTOCK + TPA*(D*D*0.005454154)
        ENDIF
      ENDIF
  100 CONTINUE
      RETURN
C
      END
