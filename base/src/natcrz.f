      SUBROUTINE NATCRZ (IWHO)
      use htcal_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use econ_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     CREATE A FILE FOR PROCESSING THROUGH THE NATIONAL CRUISE SYSTEM
C     VOLUME ROUTINE
C
C     IWHO=1 IF CALLED FROM MAIN, IWHO=2 IF CALLED FROM CUTS
C
      INCLUDE 'ESTREE.F77'
C
      INCLUDE 'WORKCM.F77'
C
      INCLUDE 'STDSTK.F77'
C
      INCLUDE 'SUMTAB.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'OPCOM.F77'
C
      INTEGER IFC,IBDF,ICDF,I3,I2,I1,ISPC,ISITE,IA,KFOR,KREG,ITMFOR
      INTEGER I,ITPLAB,IP,JYR,ISTLNB,KODE,KOLIST,IBA,IDT,IACTK
      INTEGER NPRMS,ITODO,NTODO,IOPEN,IWHO,KDST
      INTEGER MYACT(1)
      REAL TEM(6),XXWT,TEMBA,P,DP,HTLL,TDIBB,TDIBC,FC,BKRAT,BRATIO
      CHARACTER CISN*11,TIM*8,DAT*10,VVER*7,TID*8,CLAB1(2)*4
      CHARACTER REV*10,EQNC*10,EQNB*10
      INTEGER*4 IDCMP1,IDCMP2
      LOGICAL LPPACT
      DATA MYACT/205/
      DATA IDCMP1,IDCMP2/10000000,20000000/
      DATA CLAB1/'TREE','CUT '/
C----------
C  SET FILE OPEN STATUS TO ZERO IF THIS IS CYCLE 0
C----------
      IF (LSTART) THEN
        IOPEN=0
      ENDIF
C----------
C  FIND OUT IF THERE IS A FVSSTAND OPTION.
C----------
      CALL OPFIND (1,MYACT(1),NTODO)
C----------
C  IF THERE ARE NONE TO DO, RETURN
C----------
      IF (NTODO.EQ.0) GO TO 220
C----------
C  ELSE: DO THE OPTIONS PRESENT.
C----------
      DO 200 ITODO=1,NTODO
      CALL OPGET (ITODO,2,IDT,IACTK,NPRMS,TEM)
      IF (IACTK.LT.0) GOTO 200
C----------
C  IF THE OUTPUT FILE IS NOT OPEN, OPEN IT.
C----------
      IF(IOPEN .EQ. 0) THEN
        KOLIST=30
        CALL MYOPEN(KOLIST,KWDFIL(1:ISTLNB(KWDFIL))//'.ncp',
     >              5,170,0,1,1,0,KODE)
        IF(KODE .GT. 0) THEN
          WRITE(JOSTND,*) ' FVSSTAND FILE DID NOT OPEN'
          CALL RCDSET (2,.TRUE.)
          GO TO 200
        ENDIF
        IOPEN=1
      ENDIF
C----------
C  LET IP BE THE RECORD OUTPUT COUNT
C  SET THE OUTPUT REPORTING YEAR.
C----------
      IF(IWHO .EQ. 1) THEN
        JYR=IY(ICYC+1)
        IP=ITRN
        ITPLAB=1
      ELSE
        JYR=IY(ICYC)
        IP=0
        DO 1 I=1,ITRN
        IF(WK3(I) .GT. 0.) IP=IP+1
    1   CONTINUE
        ITPLAB=2
      ENDIF
C----------
C  IF AT THE PRE-PROJECTION TIME, FIND OUT IF A FVSSTAND HAS BEEN
C  SUPPRESSED. IF YES, BRANCH TO NOT ACCOMPLISH THE REQUEST.
C  ONLY MARK THE OPTION DONE IF THIS IS CALLED FROM MAIN.
C----------
      IF (LSTART) THEN
        IF (NPRMS.GE.1 .AND. TEM(1).EQ.1.) GOTO 200
        IF(NPRMS.GE.1 .AND. TEM(1).EQ.2)CALL OPDONE(ITODO,JYR)
      ELSE
        IF (NPRMS.GE.1 .AND. TEM(1).EQ.2.) GOTO 200
        IF(IWHO .EQ. 1)THEN
          CALL OPDONE (ITODO,JYR-1)
        ELSE
C         CALL OPDONE(ITODO,JYR)
        ENDIF
      ENDIF
C----------
C  WRITE A MARKER AND THE NUMBER OF RECORDS WHICH FOLLOW.
C
C  IF THE PPE IS ACTIVE, USE THE PPE STAND WEIGHTING FACTOR FOR
C  THE SAMPLING WEIGHT.
C----------
      CALL PPISN (CISN)
      XXWT=SAMWT
      CALL PPEATV (LPPACT)
      IF (LPPACT) CALL PPWEIG (0,XXWT)
      CALL VARVER (VVER)
      CALL REVISE (VVER,REV)
      CALL GRDTIM (DAT,TIM)
      IF(VVER(:2) .EQ. 'KT') THEN
        ITMFOR=KODFOR/100000
      ELSEIF(VVER(:2) .EQ. 'SN') THEN
        ITMFOR=KODFOR/100
      ELSE
        ITMFOR=KODFOR
      ENDIF
      KREG=ITMFOR/100
      KFOR=ITMFOR-KREG*100
      IF(VVER(:2) .EQ. 'SN') THEN
        KDST=KODFOR-ITMFOR*100
      ELSE
        KDST=0
      ENDIF
      IBA=NINT(BA/GROSPC)
      IF(IWHO.NE.1)THEN
        TEMBA=0.
        DO 40 I=1,ITRN
        TEMBA=TEMBA+0.0054542*DBH(I)*DBH(I)*PROB(I)
   40   CONTINUE
        IBA=NINT(TEMBA/GROSPC)
      ENDIF
      ISITE=IFIX(SITEAR(ISISP))
      WRITE (KOLIST,2) IP,ICYC,JYR,NPLT,MGMID,VVER,DAT,TIM,
     &CLAB1(ITPLAB)(1:1),IFINT,XXWT,REV,CISN,FIAJSP(ISISP),ISITE,IBA
    2 FORMAT (' -999',3I5,6(1X,A),I3,E14.7,2(1X,A),1X,A3,I5,I5)
C----------
C  PROCESS TREELIST
C----------
      DO 60 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 60
      I2=ISCT(ISPC,2)
      DO 50 I3=I1,I2
      I=IND1(I3)
      IF(ITPLAB .EQ. 1) THEN
        P = PROB(I) / GROSPC
        IF(ICYC.GT.0) THEN
          DP = WK2(I)/ GROSPC
        ELSE
          DP = 0.0
        ENDIF
      ELSE
        P = WK3(I)/GROSPC
        DP = 0.
        IF(P .LE. 0.) GO TO 50
      ENDIF
C----------
C   TRANSLATE TREE IDS FOR TREES THAT HAVE BEEN COMPRESSED OR
C   GENERATED THROUGH THE ESTAB SYSTEM.
C----------
      IF (IDTREE(I) .GT. IDCMP1) THEN
         IF (IDTREE(I) .GT. IDCMP2) THEN
            WRITE(TID,'(''CM'',I6.6)') IDTREE(I)-IDCMP2
         ELSE
            WRITE(TID,'(''ES'',I6.6)') IDTREE(I)-IDCMP1
         ENDIF
      ELSE
         WRITE(TID,'(I8)') IDTREE(I)
      ENDIF
C----------
C  DECODE DEFECT AND COMPUTE CROWN BASE HT.
C----------
      ICDF=(DEFECT(I)-((DEFECT(I)/10000)*10000))/100
      IBDF= DEFECT(I)-((DEFECT(I)/100)*100)
      HTLL=HT(I)-HT(I)*(FLOAT(ICR(I))*0.01)
C----------
C  GET VOLUME EQUATION NUMBER, TOP DIB AND FORM CLASS FOR THIS TREE
C----------
      CALL GETEQN(ISP(I),DBH(I),HT(I),EQNC,EQNB,TDIBC,TDIBB)
      CALL FORMCL(ISP(I),IFOR,DBH(I),FC)
      IFC=IFIX(FC)
C----------
C  GET THE BARK RATIO FOR THIS TREE
C----------
      BKRAT=BRATIO(ISPC,DBH(I),HT(I))
C
      IF(VVER(:2) .EQ. 'SN') THEN
        IF(P.LT.9999.9995 .AND. DP.LT.9999.9995)THEN
          WRITE(KOLIST,21) KREG,KFOR,KDST,ICYC,TID,I,FIAJSP(ISPC),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,EQNC,
     >    EQNB,TDIBC,TDIBB,BKRAT
   21     FORMAT(1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,', 01,',1X,A8,
     >    ',',1X,I4,',',1X,A4,',',1X,I4,',',1X,F7.2,',',1X,F7.2,',',
     >    1X,F5.1,',',1X,F5.1,',',1X,I2,',',1X,I2,',',1X,I2,',',1X,
     >    I2,',',1X,F5.1,',',1X,A10,',',1X,A10,',',1X,F5.2,',',1X,
     >    F5.2,',',1X,F6.4)
        ELSE
          WRITE(KOLIST,20) KREG,KFOR,KDST,ICYC,TID,I,FIAJSP(ISPC),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,
     >    EQNC,EQNB,TDIBC,TDIBB,BKRAT
   20     FORMAT(1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,', 01,',1X,A8,
     >    ',',1X,I4,',',1X,A4,',',1X,I4,',',1X,F7.1,',',1X,F7.1,',',
     >    1X,F5.1,',',1X,F5.1,',',1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,
     >    ',',1X,F5.1,',',1X,A10,',',1X,A10,',',1X,F5.2,',',1X,F5.2,
     >    ',',1X,F6.4)
        ENDIF
      ELSE
        IF(P.LT.9999.9995 .AND. DP.LT.9999.9995)THEN
          WRITE(KOLIST,31) KREG,KFOR,KDST,ICYC,TID,I,NSP(ISP(I),1)(1:2),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,
     >    EQNC,EQNB,TDIBC,TDIBB,BKRAT
   31     FORMAT(1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,', 01,',1X,A8,
     >    ',',1X,I4,',',1X,A2,',',1X,I4,',',1X,F7.2,',',1X,F7.2,',',
     >    1X,F5.1,',',1X,F5.1,',',1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,
     >    ',',1X,F5.1,',',1X,A10,',',1X,A10,',',1X,F5.2,',',1X,F5.2,
     >    ',',1X,F6.4)
        ELSE
          WRITE(KOLIST,30) KREG,KFOR,KDST,ICYC,TID,I,NSP(ISP(I),1)(1:2),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,
     >    EQNC,EQNB,TDIBC,TDIBB,BKRAT
   30     FORMAT(1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,', 01,',1X,A8,
     >    ',',1X,I4,',',1X,A2,',',1X,I4,',',1X,F7.1,',',1X,F7.1,',',
     >    1X,F5.1,',',1X,F5.1,',',1X,I2,',',1X,I2,',',1X,I2,',',1X,I2,
     >    ',',1X,F5.1,',',1X,A10,',',1X,A10,',',1X,F5.2,',',1X,F5.2,
     >    ',',1X,F6.4)
        ENDIF
      ENDIF
C
   50 CONTINUE
   60 CONTINUE
C
C  FOR CYCLE 0 LIST, PRINT DEAD TREES WHICH WERE PRESENT IN
C  THE INVENTORY DATA AT THE BOTTOM OF THE FVSSTAND LIST
C
      IF(IREC2.GT.MAXTRE .OR. ITPLAB.EQ.2) GO TO 200
      DO 150 I=IREC2,MAXTRE
      P =(PROB(I) / GROSPC) / (FINT/FINTM)
      WRITE(TID,'(I8)') IDTREE(I)
C----------
C  DECODE DEFECT AND COMPUTE CROWN BASE HT.
C----------
      ICDF=(DEFECT(I)-((DEFECT(I)/10000)*10000))/100
      IBDF= DEFECT(I)-((DEFECT(I)/100)*100)
      HTLL=HT(I)-HT(I)*(FLOAT(ICR(I))*0.01)
C----------
C  GET VOLUME EQUATION NUMBER, TOP DIB AND FORM CLASS FOR THIS TREE
C----------
      CALL GETEQN(ISP(I),DBH(I),HT(I),EQNC,EQNB,TDIBC,TDIBB)
      CALL FORMCL(ISP(I),IFOR,DBH(I),FC)
      IFC=IFIX(FC)
C----------
C  PUT PROB IN MORTALITY COLUMN
C----------
      DP = P
      P = 0.
C----------
C  GET THE BARK RATIO FOR THIS TREE
C----------
      BKRAT=BRATIO(ISP(I),DBH(I),HT(I))
C
      IF(VVER(:2) .EQ. 'SN')THEN
C
        IF(P.LT.9999.9995 .AND. DP.LT.9999.9995)THEN
          WRITE(KOLIST,21) KREG,KFOR,KDST,ICYC,TID,I,FIAJSP(ISP(I)),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,EQNC,
     >    EQNB,TDIBC,TDIBB,BKRAT
        ELSE
          WRITE(KOLIST,20) KREG,KFOR,KDST,ICYC,TID,I,FIAJSP(ISP(I)),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,EQNC,
     >    EQNB,TDIBC,TDIBB,BKRAT
        ENDIF
C
      ELSE
C
        IF(P.LT.9999.9995 .AND. DP.LT.9999.9995)THEN
          WRITE(KOLIST,31) KREG,KFOR,KDST,ICYC,TID,I,NSP(ISP(I),1)(1:2),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,EQNC,EQNB,
     >    TDIBC,TDIBB,BKRAT
        ELSE
          WRITE(KOLIST,30) KREG,KFOR,KDST,ICYC,TID,I,NSP(ISP(I),1)(1:2),
     >    ITRE(I),P,DP,DBH(I),HT(I),ICR(I),ICDF,IBDF,IFC,HTLL,EQNC,EQNB,
     >    TDIBC,TDIBB,BKRAT
        ENDIF
      ENDIF
C
  150 CONTINUE
C
  200 CONTINUE
C
  220 CONTINUE
      RETURN
      END
