      SUBROUTINE ESUCKR
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **ESUCKR--EM   DATE OF LAST REVISION:   01/27/11
C
C    CREATE STUMP & ROOT SPROUTS FROM TREES CUT AT BEGINNING OF CYCLE.
C    ASSUMPTION: THE TREE LIST HAS BEEN COMPRESSED TO ABOUT 1/2 THE
C    VALUE OF MAXTRE. COMPRS IS CALLED IN ESNUTR.
C----------
COMMONS
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'ESPARM.F77'
C
      INCLUDE 'ESHOOT.F77'
C
      INCLUDE 'ESCOMN.F77'
C
      INCLUDE 'ESCOM2.F77'
C
      INCLUDE 'ESHAP.F77'
C
      INCLUDE 'ESHAP2.F77'
C
      INCLUDE 'ESTREE.F77'
C
      INCLUDE 'STDSTK.F77'
C
      INCLUDE 'VARCOM.F77'
C
C----------
C
      EXTERNAL ESRANN
      LOGICAL DEBUG
      CHARACTER CLABEL*2
      INTEGER*4 MDBH,INUMB,MSP
      INTEGER ISHAG
      REAL RANDEV,DSTMP
      REAL COUNTR(NSPSPE),TPASUM(NSPSPE),HTAVE(NSPSPE)
      REAL TPATOT,PREM,BACHLO,BX,AX,CRDUM,CW
      INTEGER NUMSPR,I,ICL,ISSP,IPLOT,ISPSTO,II,MXRR,J,ITRGT,MXTODO
      INTEGER MYACTS(1),JJ,IDATE,ITODO,IT
      INTEGER NTODO,KDT,NP,IACTK,IDT,IGRP
      INTEGER IULIM,IG,IGSP
      REAL PRMS(6),SPRMLT(NSPSPE,100),HTMSPR(NSPSPE,100),SMULT,HMULT
      REAL DMIN(NSPSPE,100),DMAX(NSPSPE,100)
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
C
      DATA MDBH/10000000/,MSP/10000/,NUMSPR/2/
      DATA MYACTS/450/
      CALL DBCHK (DEBUG,'ESUCKR',6,ICYC)
      IF(ITRNRM.LT.1) GO TO 900
      DO 10 I=1,NSPSPE
      COUNTR(I)=0.0
      TPASUM(I)=0.0
      HTAVE(I)=0.0
   10 CONTINUE
      TPATOT=0.0
C
C  PROCESS SPROUT KEYWORD OPTIONS.
C  INITIALIZE VARIABLES
C
      DO I=1,NSPSPE
      DO J=1,100
      SPRMLT(I,J)=1.
      HTMSPR(I,J)=1.
      DMIN(I,J)=0.
      DMAX(I,J)=0.
      ENDDO
      ENDDO
      HMULT=1.
      SMULT=1.
C
      CALL OPFIND (1,MYACTS(1),NTODO)
      IF (DEBUG) WRITE (JOSTND,5) NTODO,ITRNRM
    5 FORMAT (' IN ESUCKR: OPTS NTODO,ITRNRM=',I2,2X,I2)
      IF(NTODO.LE.0)GO TO 60
C
      DO 50 IT=1,NTODO
      CALL OPGET (IT,5,IDATE,IACTK,NP,PRMS)
      IDT=IDATE
      KDT=IY(ICYC)
      J=IFIX(PRMS(1))
C
C  ALL SPROUTABLE SPECIES
C
      IF (J .EQ. 0) THEN
        DO JJ=1,NSPSPE
        SPRMLT(JJ,IT)=PRMS(2)
        HTMSPR(JJ,IT)=PRMS(3)
        DMIN(JJ,IT)  =PRMS(4)
        DMAX(JJ,IT)  =PRMS(5)
        ENDDO
C
C  SINGLE SPECIES
C
      ELSE
        DO JJ=1,NSPSPE
        IF(J.EQ.ISPSPE(JJ))THEN
          SPRMLT(JJ,IT)=PRMS(2)
          HTMSPR(JJ,IT)=PRMS(3)
          DMIN(JJ,IT)  =PRMS(4)
          DMAX(JJ,IT)  =PRMS(5)
        ENDIF
        ENDDO
      ENDIF
      CALL OPDONE(IT,IDT)
   50 CONTINUE
C
   60 CONTINUE
      DO 500 I=1,ITRNRM
      INUMB=ISHOOT(I)
      ICL = INUMB/MDBH
      ISSP = INUMB/MSP - ICL*1000
      IPLOT = MOD(INUMB,MSP)
      PREM = PRBREM(I)
      ISHAG = JSHAGE(I)
      DSTMP = DSTUMP(I)
C----------
C  IF AN INSIGNIFICANT AMOUNT OF A SPROUTING SPECIES WAS CUT,
C  DO NOT GENERATE SPROUTS.  GED 4-8-97.
C----------
      IF(PREM.LT.0.001)GO TO 500
C
      ISPSTO=ISSP
      DO 200 II=1,NSPSPE
      IF(ISSP.NE.II) GO TO 200
      ISSP=ISPSPE(II)
      GO TO 201
  200 CONTINUE
      WRITE (JOREGT,1000) ISSP,ITRNRM
 1000 FORMAT(' IN ESPROT: NO SPECIES MATCH WHEN DECODING ISHOOT(',
     &  'ITRNRM). ISSP=',I5,'; ITRNRM=',I5)
      GO TO 900
  201 CONTINUE
      IF(DEBUG) WRITE(JOSTND,300) I,IPLOT,ISSP,ICL,PREM
  300 FORMAT(' IN ESUCKR: I=',I5,'; IPLOT=',I5,'; ISSP=',I5,
     &  '; ICL=',I5,'; PREM=',F6.2)
C
C     MAKE SURE THAT THERE IS ROOM IN THE TREE LIST FOR SPROUTS.
C     THE CALL TO RDESCP INSURES THAT THE SPACE REQUIRED IS BELOW THAT
C     NEEDED BY THE ROOT DISEASE MODEL.  RDESCP RETURNS THE MAXIMUM
C     NUMBER OF TREES THAT ROOT DISEASE CAN HANDLE.  IF RROT IS NOT
C     BEING RUN, MXRR IS RETURNED AS MAXTRE.
C
      CALL RDESCP (MAXTRE, MXRR)
C
C     INSERT CODE TO PREDICT NUMBER OF SPROUTS.  ICL IS DIAMETER CLASS
C     IN THE ARRAY DBHMID.  SET NUMSPR TO 2 FOR TESTING PURPOSES.
C
C     SET SPROUT KEYWORD MULTIPLIERS BASED ON DBH RANGE
C
      SMULT=1.
      HMULT=1.
      DO 450 IT=1,NTODO
      IF((DSTMP.GE.DMIN(ISPSTO,IT)).AND.
     &   (DSTMP.LT.DMAX(ISPSTO,IT)))THEN
        SMULT=SPRMLT(ISPSTO,IT)
        HMULT=HTMSPR(ISPSTO,IT)
      ENDIF
  450 CONTINUE
C----------
C  IF SPROUT MULTIPLIER (SMULT) IS ZERO DO NOT ADD RECORDS TO TREE LIST
C----------
      IF(SMULT.LE.0.)GOTO 500
C
      DO 499 J=1,NUMSPR
      IF(ITRN.LT.MXRR) GO TO 100
      ITRGT=ITRNRM-I
      MXTODO=FLOAT(MXRR)* 0.70
      IF(MXTODO.GT.ITRGT) ITRGT=MXTODO
      CALL ESCPRS (ITRGT,DEBUG)
  100 CONTINUE
      ITRN=ITRN+1
      IMC(ITRN)=2
      ISP(ITRN)=ISSP
      ITRE(ITRN)=IPLOT
      CFV(ITRN)=0.0
      ITRUNC(ITRN)=0
      NORMHT(ITRN)=0
C
C     INSERT CODE TO CALCULATE DBH AND HEIGHT OF SPROUTS
C
      PROB(ITRN)=PREM*SMULT
      IF(ISSP.GE.11 .AND. ISSP.LE.17)THEN
        HT(ITRN)=((1.0+SITEAR(ISSP)/5.)/10.)*ISHAG*HMULT
      ELSE
        HT(ITRN)=(0.5 + 0.5*ISHAG)*HMULT
      ENDIF
C
  162 RANDEV=BACHLO(0.,0.5,ESRANN)
      IF(RANDEV.LT.-1.0 .OR. RANDEV.GT.1.0) GO TO 162
      RANDEV = RANDEV*HT(ITRN)/5.5
      HT(ITRN)=HT(ITRN)+RANDEV

      IF(HT(ITRN) .GT.4.5)THEN
        BX=HT2(ISSP)
        IF(IABFLG(ISSP).EQ.1)THEN
          AX=HT1(ISSP)
        ELSE
          AX=AA(ISSP)
        ENDIF
        DBH(ITRN)= (BX/(ALOG(HT(ITRN)-4.5)-AX))-1.0
        IF (DBH(ITRN).LT.0.1) DBH(ITRN)=0.1
      ELSE
        DBH(ITRN)=0.1
      ENDIF
C
      ICR(ITRN)=70
C----------
C  CALCULATE A CROWN WIDTH FOR SPROUTS
C----------
      CRDUM=1.
      CALL CWCALC(ISSP,PROB(ITRN),DBH(ITRN),HT(ITRN),CRDUM,
     &            ICR(ITRN),CW,0,JOSTND)
      CRWDTH(ITRN)=CW
C
      DG(ITRN)=0.0
      HTG(ITRN)=0.0
      PCT(ITRN)=0.0
      OLDPCT(ITRN)=0.0
      WK1(ITRN)=0.0
      WK2(ITRN)=0.
      WK4(ITRN)=0.
      BFV(ITRN)=0.0
      IESTAT(ITRN)=0
      PTBALT(ITRN)=0.
      IDTREE(ITRN)=10000000+ICYC*10000+ITRN
      CALL MISPUTZ(ITRN,0)
C
      ABIRTH(ITRN)=ISHAG
      DEFECT(ITRN)=0.
      ISPECL(ITRN)=0
      OLDRN(ITRN)=0.
      PTOCFV(ITRN)=0.
      PMRCFV(ITRN)=0.
      PMRBFV(ITRN)=0.
      NCFDEF(ITRN)=0
      NBFDEF(ITRN)=0
      PDBH(ITRN)=0.
      PHT(ITRN)=0.
      ZRAND(ITRN)=-999.
C
      COUNTR(ISPSTO)=COUNTR(ISPSTO) +1.0
      TPASUM(ISPSTO)=TPASUM(ISPSTO) +PREM*SMULT
      TPATOT=TPATOT+PREM*SMULT
      HTAVE(ISPSTO)=HTAVE(ISPSTO) +HT(ITRN)
  499 CONTINUE
  500 CONTINUE
      IF(IPRINT.NE.0) THEN
        WRITE(JOREGT,1100) NPLT,MGMID,IY(ICYC+1)-1
 1100   FORMAT(' ',54('-'),/,' REGENERATION FROM STUMP & ROOT SPROUTS',
     &  //,' STAND ID: ',A26,'  MANAGEMENT CODE: ',A4,'  YEAR: ',I5,//,
     &  T15,'TREES  AVERAGE',/,T6,'SPECIES  /ACRE  HEIGHT',/,T6,
     &  '-------  -----  -------')
        DO 700 I=1,NSPSPE
        CLABEL=NSP(ISPSPE(I),1)
        HTAVE(I)=HTAVE(I)/(COUNTR(I)+.00001)
        IF(TPASUM(I).GT.0.0)
     &  WRITE(JOREGT,1200) CLABEL,TPASUM(I),HTAVE(I)
 1200   FORMAT(T9,A2,T14,F6.0,T22,F6.1)
  700   CONTINUE
        WRITE(JOREGT,1300) TPATOT
 1300   FORMAT(T15,'-----',/,T14,F6.0,/,54('-') )
      ENDIF
  900 CONTINUE
      ITRNRM=0
      RETURN
      END
