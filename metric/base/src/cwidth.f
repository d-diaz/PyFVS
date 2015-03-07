      SUBROUTINE CWIDTH
      use contrl_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C  THIS SUBROUTINE COMPUTES A CROWN WIDTH FOR EACH TREE RECORD USING
C  EITHER USER-DEFINED EQUATIONS OR DEFAULT EQUATIONS. IT ALSO
C  PROCESSES CROWN WIDTH MODIFIERS ENTERED VIA THE FIXCW KEYWORD.
C  THIS ROUTINE IS CALLED FROM **MAIN** TO LOAD THE INITIAL CROWN
C  WIDTHS, AND FROM **UPDATE** TO LOAD THE END-OF-CYCLE VALUES.
C----------
COMMONS
      INCLUDE 'CWDCOM.F77'
      INCLUDE 'METRIC.F77'
C
C----------
C  DEFINITIONS:
C
C        I -- TREE SUBSCRIPT.
C        D -- TREE DIAMETER.
C        P -- NUMBER OF TREES PER ACRE REPRESENTED BY A TREE.
C----------
      LOGICAL DEBUG,LINCL
      REAL PRM(5)
      INTEGER MYACTS(1)
      INTEGER IG,IULIM,IGRP,ISPCC,IDATE,IACTK,NP,ITODO,NTODO,IWHO,IICR
      INTEGER ISPC,I
      REAL P,D,H,CR,CW
	REAL    DM

C----------
C  DATA STATEMENTS.
C  ACTIVITY 90 = FIXCW
C----------
      DATA MYACTS/90/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CWIDTH',6,ICYC)
      IF(DEBUG)WRITE(JOSTND,*)' ENTERING CWIDTH ICYC,ITRN= ',ICYC,ITRN
C---------
C  IF THERE ARE NO TREE RECORDS, SIMPLY PROCESS THE FIXCW REQUESTS.
C---------
      IF (ITRN.LE.0) GOTO 100
C----------
C  START LOOP TO ESTIMATE CROWN WIDTH.  TREES ARE PROCESSED
C  ONE AT A TIME WITHIN A SPECIES.
C----------
      DO 50 I=1,ITRN
      ISPC=ISP(I)
      P=PROB(I)
      D=DBH(I)
	DM=DBH(I)*INtoCM
      H=HT(I)
	CR=FLOAT(ICR(I))
      IICR=ICR(I)
      CRWDTH(I)=0.0
      IF(LSPCWE(ISPC))THEN
        IF(D .LT. CWTDBH(ISPC))THEN
          CW=CWDS0(ISPC)+CWDS1(ISPC)*DM+
     &       CWDS2(ISPC)*(DM**CWDS3(ISPC))
        ELSE
          CW=CWDL0(ISPC)+CWDL1(ISPC)*DM+
     &       CWDL2(ISPC)*(DM**CWDL3(ISPC))
        ENDIF
        CRWDTH(I) = CW*MtoFT
      ELSE
	  IWHO=0
        CALL CWCALC(ISPC,P,D,H,CR,IICR,CW,IWHO,JOSTND)
	  CRWDTH(I) = CW
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' LIVE: I,ISPC,D,H,CW= ',
     &I,ISPC,D,CR,CW
   50 CONTINUE
C
  100 CONTINUE
C----------
C  ESTIMATE CROWN WIDTH ON CYCLE 0 DEAD TREES
C  PROB IS NOT USED IN ESTIMATION OF CROWN WIDTH SO DON'T
C  WORRY ABOUT INFLATION OF DEAD-TREE PROB HERE.
C----------
      IF(IREC2.GT.MAXTRE) GO TO 200
      DO 150 I=IREC2,MAXTRE
      ISPC=ISP(I)
      P=PROB(I)
      D=DBH(I)
	DM=DBH(I)*INtoCM
      H=HT(I)
      CR=FLOAT(ICR(I))
      CRWDTH(I)=0.0
      IF(LSPCWE(ISPC))THEN
        IF(D .LT. CWTDBH(ISPC))THEN
          CW=CWDS0(ISPC)+CWDS1(ISPC)*DM+
     &       CWDS2(ISPC)*(DM**CWDS3(ISPC))
          CRWDTH(I) = CW * MtoFT
        ELSE
          CW=CWDL0(ISPC)+CWDL1(ISPC)*DM+
     &       CWDL2(ISPC)*(DM**CWDL3(ISPC))
        ENDIF
        CRWDTH(I) = CW*MtoFT
      ELSE
        IWHO=0
        CALL CWCALC(ISPC,P,D,H,CR,IICR,CW,IWHO,JOSTND)
	  CRWDTH(I) = CW
      ENDIF

      IF(DEBUG)WRITE(JOSTND,*)' DEAD: I,ISPC,D,H,CW= ',
     &I,ISPC,D,H,CW
  150 CONTINUE
  200 CONTINUE
C----------
C PROCESS THE FIXCW OPTIONS.
C----------
      CALL OPFIND (1,MYACTS(1),NTODO)
      IF(DEBUG)WRITE(JOSTND,*)' PROCESSING FIXCW, NTODO= ',NTODO
      IF (NTODO.GT.0) THEN
         DO 300 ITODO=1,NTODO
         CALL OPGET (ITODO,4,IDATE,IACTK,NP,PRM)
         IF(DEBUG)WRITE(JOSTND,*)' ITODO,IDATE,IACTK,NP,PRM= ',
     &   ITODO,IDATE,IACTK,NP,PRM
         IF (IACTK.LT.0) GOTO 300
         IF(ICYC.GT.0)CALL OPDONE(ITODO,IY(ICYC))
         ISPCC=IFIX(PRM(1))
         IF(PRM(2) .LT. 0.) PRM(2)=0.
         IF(PRM(3) .LT. 0.) PRM(3)=0.
         IF(PRM(4) .LE. 0.) PRM(4)=999.
         IF(DEBUG)WRITE(JOSTND,*)' FIXCW: ISPCC,MULT,DBHLO,DBHHI= ',
     &   ISPCC,PRM(2),PRM(3),PRM(4)
         IF (ITRN.GT.0) THEN
            DO 290 I=1,ITRN
            LINCL = .FALSE.
            IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(I))THEN
              LINCL = .TRUE.
            ELSEIF(ISPCC.LT.0)THEN
              IGRP = -ISPCC
              IULIM = ISPGRP(IGRP,1)+1
              DO 210 IG=2,IULIM
              IF(ISP(I) .EQ. ISPGRP(IGRP,IG))THEN
                LINCL = .TRUE.
                GO TO 215
              ENDIF
  210         CONTINUE
            ENDIF
  215       CONTINUE
            IF(LINCL .AND.
     >        (PRM(3).LE.DBH(I) .AND. DBH(I).LT.PRM(4))) THEN
              CRWDTH(I)=CRWDTH(I)*PRM(2)
              IF(CRWDTH(I).GT. 99.9)CRWDTH(I)=99.9
              IF(DEBUG)WRITE(JOSTND,*)' LIVE: I,ISPCC,ISP,DBH,CRWDTH= ',
     &        I,ISPCC,ISP(I),DBH(I),CRWDTH(I)
            ENDIF
  290       CONTINUE
         ENDIF
         IF(IREC2.GT.MAXTRE)GO TO 295
         DO 293 I=IREC2,MAXTRE
            LINCL = .FALSE.
            IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(I))THEN
              LINCL = .TRUE.
            ELSEIF(ISPCC.LT.0)THEN
              IGRP = -ISPCC
              IULIM = ISPGRP(IGRP,1)+1
              DO 220 IG=2,IULIM
              IF(ISP(I) .EQ. ISPGRP(IGRP,IG))THEN
                LINCL = .TRUE.
                GO TO 225
              ENDIF
  220         CONTINUE
            ENDIF
  225       CONTINUE
         IF (LINCL .AND.
     >         (PRM(3).LE.DBH(I) .AND. DBH(I).LT.PRM(4))) THEN
               CRWDTH(I)=CRWDTH(I)*PRM(2)
              IF(CRWDTH(I).GT. 99.9)CRWDTH(I)=99.9
              IF(DEBUG)WRITE(JOSTND,*)' DEAD: I,ISPCC,ISP,DBH,CRWDTH= ',
     &        I,ISPCC,ISP(I),DBH(I),CRWDTH(I)
            ENDIF
  293    CONTINUE
  295    CONTINUE
  300    CONTINUE
      ENDIF
C
      IF(DEBUG)WRITE(JOSTND,*)' LEAVING CWIDTH ICYC= ',ICYC
      RETURN
      END
