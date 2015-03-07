      SUBROUTINE VOLKEY(DEBUG)
      use contrl_mod
      use prgprm_mod
      use plot_mod
      use coeffs_mod
      use arrays_mod
      implicit none
C----------
C  $Id$
C----------
C----------
C  THIS SUBROUTINE PROCESSES THE KEYWORDS USED TO MODIFY VOLUME
C  STANDARDS AND EQUATIONS.
C----------
COMMONS
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'VOLSTD.F77'
C
C----------
      LOGICAL DEBUG
      INTEGER MYACTS(4)
      REAL PRMS(7)
      INTEGER NTODO,I,NP,IACTK,KDT,INUM,ISPC,IGRP,IULIM,IG,IGSP,J
C----------
C  INITIALIZE ACTIVITY VECTORS.
C    215 = MCDEFECT
C    216 = BFDEFECT
C    217 = VOLUME
C    218 = BFVOLUME
C----------
      DATA MYACTS/215,216,217,218/
C----------
C  IF CYCLE EQUAL ZERO, THEN THIS STUFF "CAN NOT" BE DONE.
C----------
      IF (ICYC.EQ.0) GO TO 9960
C----------
C  DETERMINE IF VOLUME STANDARDS CHANGE THIS CYCLE.
C----------
      CALL OPFIND(4,MYACTS,NTODO)
      IF(NTODO.LE.0) GO TO 9960
      DO 7 I=1,NTODO
      CALL OPGET(I,7,KDT,IACTK,NP,PRMS)
C----------
C  IF THE PARAMETER COUNT IS TOO LOW, DELETE THE ACTIVITY.
C----------
      IF (NP.LT.6) THEN
         CALL OPDEL1 (I)
         GOTO 7
      ENDIF
      INUM=219-IACTK
      GO TO (9905,9915,9925,9935),INUM
C----------
C  CHANGE MERCHANTABILITY STANDARDS FOR THE BOARD FOOT VOLUME
C  EQUATIONS.  EMPIRICAL ADJUSTMENT DEVELOPED BY J. E. BRICKELL,
C  REGION ONE, TM.
C  BFVOLUME KEYWORD.
C----------
 9905 CONTINUE
      CALL OPDONE(I,IY(ICYC))
      ISPC=IFIX(PRMS(1))

      IF(ISPC .LT. 0)THEN
        IGRP = -ISPC
        IULIM = ISPGRP(IGRP,1)+1
        DO 9906 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        BFMIND(IGSP)=PRMS(2)
        BFTOPD(IGSP)=PRMS(3)
        BFSTMP(IGSP)=PRMS(4)
        FRMCLS(IGSP)=PRMS(5)
        METHB(IGSP)=IFIX(PRMS(6))
 9906   CONTINUE
      ELSEIF(ISPC .EQ. 0) THEN
        DO 9907 J=1,MAXSP
        BFMIND(J)=PRMS(2)
        BFTOPD(J)=PRMS(3)
        BFSTMP(J)=PRMS(4)
        FRMCLS(J)=PRMS(5)
        METHB(J)=IFIX(PRMS(6))
 9907   CONTINUE
      ELSE
        BFMIND(ISPC)=PRMS(2)
        BFTOPD(ISPC)=PRMS(3)
        BFSTMP(ISPC)=PRMS(4)
        FRMCLS(ISPC)=PRMS(5)
        METHB(ISPC)=IFIX(PRMS(6))
      ENDIF
      GO TO 7
C----------
C  CHANGE MERCHANTABILITY STANDARDS FOR MERCHANTABLE CUBIC
C  FOOT VOLUME EQUATIONS.  ADJUSTMENTS BASED ON BEHRE HYPERBOLA.
C  VOLUME KEYWORD.
C----------
 9915 CONTINUE
      CALL OPDONE(I,IY(ICYC))
      ISPC=IFIX(PRMS(1))
      IF(ISPC .LT. 0)THEN
        IGRP = -ISPC
        IULIM = ISPGRP(IGRP,1)+1
        DO 9916 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        DBHMIN(IGSP)=PRMS(2)
        TOPD(IGSP)=PRMS(3)
        STMP(IGSP)=PRMS(4)
        FRMCLS(IGSP)=PRMS(5)
        METHC(IGSP)=IFIX(PRMS(6))
 9916   CONTINUE
      ELSEIF(ISPC .EQ. 0) THEN
        DO 9917 J=1,MAXSP
        DBHMIN(J)=PRMS(2)
        TOPD(J)=PRMS(3)
        STMP(J)=PRMS(4)
        FRMCLS(J)=PRMS(5)
        METHC(J)=IFIX(PRMS(6))
 9917   CONTINUE
      ELSE
        DBHMIN(ISPC)=PRMS(2)
        TOPD(ISPC)=PRMS(3)
        STMP(ISPC)=PRMS(4)
        FRMCLS(ISPC)=PRMS(5)
        METHC(ISPC)=IFIX(PRMS(6))
      ENDIF
      GO TO 7
C----------
C  CHANGE DEFECT STANDARDS FOR BOARD FOOT VOLUME. ADJUSTMENTS ARE
C  BASED ON LINE SEGMENT DATA.
C  BFDEFECT KEYWORD.
C----------
 9925 CONTINUE
      CALL OPDONE(I,IY(ICYC))
      ISPC=IFIX(PRMS(1))
      IF(ISPC .LT. 0)THEN
        IGRP = -ISPC
        IULIM = ISPGRP(IGRP,1)+1
        DO 9926 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        BFDEFT(2,IGSP)=PRMS(2)
        BFDEFT(3,IGSP)=PRMS(3)
        BFDEFT(4,IGSP)=PRMS(4)
        BFDEFT(5,IGSP)=PRMS(5)
        BFDEFT(6,IGSP)=PRMS(6)
        BFDEFT(7,IGSP)=PRMS(6)
        BFDEFT(8,IGSP)=PRMS(6)
        BFDEFT(9,IGSP)=PRMS(6)
 9926   CONTINUE
      ELSEIF(ISPC .EQ. 0) THEN
        DO 9927 J=1,MAXSP
        BFDEFT(2,J)=PRMS(2)
        BFDEFT(3,J)=PRMS(3)
        BFDEFT(4,J)=PRMS(4)
        BFDEFT(5,J)=PRMS(5)
        BFDEFT(6,J)=PRMS(6)
        BFDEFT(7,J)=PRMS(6)
        BFDEFT(8,J)=PRMS(6)
        BFDEFT(9,J)=PRMS(6)
 9927   CONTINUE
      ELSE
        BFDEFT(2,ISPC)=PRMS(2)
        BFDEFT(3,ISPC)=PRMS(3)
        BFDEFT(4,ISPC)=PRMS(4)
        BFDEFT(5,ISPC)=PRMS(5)
        BFDEFT(6,ISPC)=PRMS(6)
        BFDEFT(7,ISPC)=PRMS(6)
        BFDEFT(8,ISPC)=PRMS(6)
        BFDEFT(9,ISPC)=PRMS(6)
      ENDIF
      GO TO 7
C----------
C  CHANGE DEFECT STANDARDS FOR CUBIC FOOT VOLUME. ADJUSTMENTS ARE
C  BASED ON SEGMENTED LINED DATA.
C  MCDEFECT KEYWORD.
C----------
 9935 CONTINUE
      CALL OPDONE(I,IY(ICYC))
      ISPC=IFIX(PRMS(1))
      IF(ISPC .LT. 0)THEN
        IGRP = -ISPC
        IULIM = ISPGRP(IGRP,1)+1
        DO 9936 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        CFDEFT(2,IGSP)=PRMS(2)
        CFDEFT(3,IGSP)=PRMS(3)
        CFDEFT(4,IGSP)=PRMS(4)
        CFDEFT(5,IGSP)=PRMS(5)
        CFDEFT(6,IGSP)=PRMS(6)
        CFDEFT(7,IGSP)=PRMS(6)
        CFDEFT(8,IGSP)=PRMS(6)
        CFDEFT(9,IGSP)=PRMS(6)
 9936   CONTINUE
      ELSEIF(ISPC .EQ. 0) THEN
        DO 9937 J=1,MAXSP
        CFDEFT(2,J)=PRMS(2)
        CFDEFT(3,J)=PRMS(3)
        CFDEFT(4,J)=PRMS(4)
        CFDEFT(5,J)=PRMS(5)
        CFDEFT(6,J)=PRMS(6)
        CFDEFT(7,J)=PRMS(6)
        CFDEFT(8,J)=PRMS(6)
        CFDEFT(9,J)=PRMS(6)
 9937   CONTINUE
      ELSE
        CFDEFT(2,ISPC)=PRMS(2)
        CFDEFT(3,ISPC)=PRMS(3)
        CFDEFT(4,ISPC)=PRMS(4)
        CFDEFT(5,ISPC)=PRMS(5)
        CFDEFT(6,ISPC)=PRMS(6)
        CFDEFT(7,ISPC)=PRMS(6)
        CFDEFT(8,ISPC)=PRMS(6)
        CFDEFT(9,ISPC)=PRMS(6)
      ENDIF
    7 CONTINUE
C
 9960 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9970) (BFMIND(I),BFTOPD(I),BFSTMP(I),
     &                              I,I=1,MAXSP)
 9970 FORMAT(' BFMIND=',F10.2,' BFTOPD=',F10.2,' BFSTMP=',
     &       F10.2,' SPECIES=',I2)
C
      RETURN
      END
