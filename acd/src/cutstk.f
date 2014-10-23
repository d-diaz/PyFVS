      SUBROUTINE CUTSTK
      IMPLICIT NONE
C----------
C  **CUTSTK--NE   DATE OF LAST REVISION:  07/11/08
C----------
C  THIS SUBROUTINE CONTAINS ENTRY POINTS FOR CALCULATING STOCKING
C  LEVELS FOR VARIOUS THINNING OPTIONS.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C----------
      LOGICAL LINCL
      REAL TPRED(7),B0(7),SPPRO(7),SPTPA(8)
      INTEGER JJSP(MAXSP)
      INTEGER I,IISPG,JPNUM,JSPCUT,JTYP,IC,IGRP,IULIM,IG
      REAL TPA,H,D,CSTOCK,DL,DU,HL,HU,TPAPRD,RSD,SPATOT,FSTOCK
      DATA B0/4.129,3.990,3.938,4.029,3.969,4.135,4.101/
C----------
C  PUT SPECIES IN ONE OF 8 STOCKING CATEGORIES
C----------
C  SPECIES GROUP 1 - CHERRY/OAK/POPLAR 80%
C  SPECIES GROUP 2 - NORTHERN HARDWOODS
C  SPECIES GROUP 3 - UPLAND OAK
C  SPECIES GROUP 4 - PAPER BIRCH
C  SPECIES GROUP 5 - RED OAK
C  SPECIES GROUP 6 - SPRUCE/FIR
C  SPECIES GROUP 7 - WHITE PINE
C  SPECIES GROUP 8 - MISCELLANEOUS
C----------
      DATA JJSP/7*6,4*7,6*6,8*7,7*2,2*4,5*3,2,8*1,5*2,1,12*3,2*5,
     &          2*3,38*8/
C
C----------
C  ENTRY AUTSTK CALCULATES NORMAL STOCKING FOR AUTOMATIC THINS.
C
C  VARIABLE DEFINITIONS:
C  B0 --  CONSTANT TO PREDICT STOCKING PERCENT.  ONE B0 FOR EACH
C         STOCKING PERCENT CATEGORY.
C  SPATOT TOTAL NUMBER OF TREES IN THE SEVEN STOCKING PERCENT
C         CATEGORIES.
C  SPPRO  PROPORTION OF TREES BY STOCKING PERCENT CATEGORY.
C  TPRED  NUMBER OF TREES PER ACRE FOR THE STAND AT 100% STOCKING-
C           BY STOCKING CATEGORY.
C TPAPRD  NUMBER OF TREES PER ACRE PREDICTED FOR THE NEW STAND AT
C           100% STOCKING--INCLUDES ALL SEVEN STOCKING PERCENT
C           CATEGORIES.
C----------
      ENTRY AUTSTK (FSTOCK)
      DO 10 I=1,7
      TPRED(I) = 0.0
   10 CONTINUE
C----------
C  DETERMINE TOTAL NUMBER OF TREES PER ACRE IN EACH SPECIES GROUP
C----------
      DO 20 I=1,ITRN
      IISPG = JJSP(ISP(I))
      SPTPA(IISPG) = SPTPA(IISPG) + PROB(I)
   20 CONTINUE
      DO 30 I=1,7
      SPATOT =SPATOT + SPTPA(I)
   30 CONTINUE
      IF (SPATOT .EQ. 0.0) GO TO 50
C----------
C  ADD THE TREES PER ACRE FROM THE MISCELLANEOUS SPECIES GROUP INTO
C  OTHER SPECIES GROUPS PROPORTIONALLY.
C----------
      DO 40 I=1,7
      SPPRO(I) = SPTPA(I)/SPATOT
   40 SPTPA(I) = SPTPA(I) + (SPPRO(I)*SPTPA(8))
C----------
C  IF ALL TREES PER ACRE ARE IN THE MISCELLANEOUS SPECIES GROUP
C  READJUST OTHER SPECIES GROUPS.
C----------
   50 CONTINUE
      SPATOT = SPTPA(8)
      DO 60 I=1,7
      SPTPA(I) = SPTPA(I) + (.14286*SPATOT)
   60 CONTINUE
C----------
C  RECALCULATE STOCKING PERCENT FOR LIVE TREES ONLY (ISTATUS = 1).
C----------
      DO 80 I=1,7
      IF (SPTPA(I) .EQ. 0.0) THEN
        TPRED(I) = 1.0
        GO TO 80
      ENDIF
C----------
C  CALCULATE PREDICTED NUMBER OF TREES FOR EACH SPECIES GROUP
C----------
      TPRED(I) = 10.0**(B0(I) - 1.605*(LOG10(ORMSQD)))
   80 CONTINUE
C----------
C  CALCULATE RELATIVE STAND DENSITY
C----------
       RSD = ((SPTPA(1)/TPRED(1))+(SPTPA(2)/TPRED(2))+
     &              (SPTPA(3)/TPRED(3))+(SPTPA(4)/TPRED(3))+
     &              (SPTPA(5)/TPRED(5))+(SPTPA(6)/TPRED(6))+
     &              (SPTPA(7)/TPRED(7)))
       TPAPRD = (100.0/RSD)*OLDTPA
       FSTOCK = TPAPRD
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
        DO 90 IG=2,IULIM
        IF(ISP(IC) .EQ. ISPGRP(IGRP,IG))THEN
          LINCL = .TRUE.
          GO TO 91
        ENDIF
   90   CONTINUE
      ENDIF
   91 CONTINUE
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
