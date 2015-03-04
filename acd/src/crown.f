      SUBROUTINE CROWN
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **CROWN--NE  DATE OF LAST REVISION:  01/11/11
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND
C  COMPUTE CROWN RATIO CHANGES FOR TREES.  THE EQUATION USED
C  PREDICTS CROWN RATIO FROM BASAL AREA AND TREE DIAMETER.
C  THIS EQUATION AND THE COEFFICIENTS ARE FROM 'A GUIDE TO
C  THE TWIGS PROGRAM FOR THE NORTH CENTRAL U.S.', GENERAL
C  TECHNICAL REPORT, NC-125.  THIS ROUTINE IS CALLED FROM
C  **CRATET** TO DUB MISSING VALUES, AND BY **TREGRO** TO
C  COMPUTE CHANGE DURING REGULAR CYCLING.  ENTRY **CRCONS**
C  IS CALLED BY **RCON** TO LOAD MODEL CONSTANTS THAT ARE SITE
C  DEPENDENT AND NEED ONLYBE RESOLVED ONCE.  PROCESSING OF
C  CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY **REGENT**.
C----------
COMMONS
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'PDEN.F77'
C
      INCLUDE 'VARCOM.F77'
C
      LOGICAL DEBUG
      REAL CRNEW(MAXTRE),BCR1(MAXSP),BCR2(MAXSP),
     &  BCR3(MAXSP),BCR4(MAXSP),PRM(5),
     &  CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP)
      INTEGER MYACTS(1),ICFLG(MAXSP)
      INTEGER JJ,NTODO,I,NP,IACTK,IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP
      INTEGER ISPC,I1,I2,I3,ICRI
      REAL CR,CL,HD,HN,CRMAX,CRLN,PDIFPY,CHG,DEN,D
      DATA MYACTS/81/
C----------
C  SPECIES SPECIFIC COEFFICIENTS
C----------
      DATA BCR1/
     &   5.630,6.000,7.840,4*5.540,5.540, 6.640, 5.350, 6.790,
     &   4*5.710,2*5.710,8*4.350,3.400,3*4.180,3*4.180,2*5.000,
     &   5*4.000,6.210,5*3.733,3*3.733,5*4.500,3.733,5*4.110,4*4.000,
     &   3*3.733,2*5.840,2*4.200,27*4.000,11*4.000/
      DATA BCR2/
     &   .0047,.0053,.0057,4*.0072,.0072, .0135, .0053, .0058,
     &   4*.0077,2*.0077,8*.0046,.0066,3*.0025,3*.0025,2*.0066,
     &   5*.0024,.0073,5*.0040,3*.0040,5*.0032,.0040,5*.0054,4*.0024,
     &   3*.0040,2*.0082,2*.0016,27*.0024,11*.0024/
      DATA BCR3/
     &   3.523,0.431,1.272,4*4.200, 4.200, 3.200, 1.528, 7.590,
     &   4*2.290,2*2.290,8*1.820,2.870,3*1.410,3*1.410,2*4.920,
     &   5*-2.830,9.990,5*3.632,3*3.632,5*0.795,3.632,5*1.650,
     &   4*-2.830,3*3.632,2*3.260,2*2.760,27*-2.830,11*-2.830/
      DATA BCR4/
     &  -.0689,-.0012,-.1420,4*-.0530,-.0530,-.0518,-.0330,-.0103,
     &  4*-.2530,2*-.2530,8*-.2740,-.4340,3*-.5120,3*-.5120,2*-.0263,
     &  5*.0210,-.0100,5*-.0412,3*-.0412,5*-.1050,-.0412,5*-.1100,
     &  4*.0210,3*-.0412,2*-.0490,2*-.0250,27*.0210,11*.0210/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)
C----------
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C----------
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ)=0.0
   10   CONTINUE
      ENDIF
C----------
C  DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
C----------
      IF((ITRN.LE.0).AND.(IREC2.LT.MAXTP1))GO TO 74
C----------
C IF THERE ARE NO TREE RECORDS, THEN RETURN
C----------
      IF(ITRN.EQ.0)THEN
        RETURN
      ELSEIF(TPROB.LE.0.0)THEN
        DO I=1,ITRN
        ICR(I)=ABS(ICR(I))
        ENDDO
        RETURN
      ENDIF
C-----------
C  PROCESS CRNMULT KEYWORD.
C-----------
      CALL OPFIND(1,MYACTS,NTODO)
      IF(NTODO .EQ. 0)GO TO 25
      DO 24 I=1,NTODO
      CALL OPGET(I,5,IDATE,IACTK,NP,PRM)
      IDT=IDATE
      CALL OPDONE(I,IDT)
      ISPCC=IFIX(PRM(1))
C----------
C  ISPCC<0 CHANGE FOR ALL SPECIES IN THE SPECIES GROUP
C  ISPCC=0 CHANGE FOR ALL SPEICES
C  ISPCC>0 CHANGE THE INDICATED SPECIES
C----------
      IF(ISPCC .LT. 0)THEN
        IGRP = -ISPCC
        IULIM = ISPGRP(IGRP,1)+1
        DO 21 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        IF(PRM(2) .GE. 0.0)CRNMLT(IGSP)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(IGSP)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(IGSP)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(IGSP)=1
   21   CONTINUE
      ELSEIF(ISPCC .EQ. 0)THEN
        DO 22 ISPCC=1,MAXSP
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
   22   CONTINUE
      ELSE
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
      ENDIF
   24 CONTINUE
   25 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9024)ICYC,CRNMLT
 9024 FORMAT(/' IN CROWN 9024 ICYC,CRNMLT= ',
     & I5/((1X,11F6.2)/))
C----------
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
      DO 60 I3=I1,I2
      I = IND1(I3)
C----------
C  IF THIS IS THE INITIAL ENTRY TO 'CROWN' AND THE TREE IN QUESTION
C  HAS A CROWN RATIO ASCRIBED TO IT, THE WHOLE PROCESS IS BYPASSED.
C----------
      IF(LSTART .AND. ICR(I).GT.0)GOTO 60
C----------
C  IF ICR(I) IS NEGATIVE, CROWN RATIO CHANGE WAS COMPUTED IN A
C  PEST DYNAMICS EXTENSION.  SWITCH THE SIGN ON ICR(I) AND BYPASS
C  CHANGE CALCULATIONS.
C----------
      IF (LSTART) GOTO 40
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      DEN=1+BCR2(ISPC)*BA
      CRNEW(I)=10*(BCR1(ISPC)/DEN+BCR3(ISPC)*(1-EXP(BCR4(ISPC)*D)))
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR
C----------
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - ICR(I)
      PDIFPY=CHG/ICR(I)/FINT
      IF(PDIFPY.GT.0.01)CHG=ICR(I)*(0.01)*FINT
      IF(PDIFPY.LT.-0.01)CHG=ICR(I)*(-0.01)*FINT
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &I5,F10.3,I5,3F10.3)
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
        CRNEW(I) = ICR(I) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = ICR(I) + CHG
      ENDIF
 9052 ICRI = CRNEW(I)+0.5
      IF(LSTART .OR. ICR(I).EQ.0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &    ICRI = ICRI * CRNMLT(ISPC)
      ENDIF
C----------
C CALC CROWN LENGTH NOW
C----------
      IF(LSTART .OR. ICR(I).EQ.0)GO TO 55
      CRLN=HT(I)*ICR(I)/100.
C----------
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C----------
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),
     & CHG
 9004 FORMAT(' CRMAX=',F10.2,' CRLN=',F10.2,
     &       ' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(ICRI.GT.CRMAX) ICRI=CRMAX+0.5
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0)ICRI=CRMAX+0.5
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,
     & ICRI,CL
 9030 FORMAT(' IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10 .AND. CRNMLT(ISPC).EQ.1) ICRI=10
      IF(ICRI.LT.1)ICRI=1
      ICR(I)= ICRI
   60 CONTINUE
      IF(LSTART .AND. ICFLG(ISPC).EQ.1)THEN
        CRNMLT(ISPC)=1.0
        ICFLG(ISPC)=0
      ENDIF
   70 CONTINUE
   74 CONTINUE
C----------
C  DUB MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 80
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      DEN=1+BCR2(ISPC)*BA
      CR =10*(BCR1(ISPC)/DEN+BCR3(ISPC)*(1-EXP(BCR4(ISPC)*D)))
      ICRI=CR + 0.5
      IF(ITRUNC(I).EQ.0) GO TO 78
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
   78 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10) ICRI=10
      ICR(I)= ICRI
   79 CONTINUE
C
   80 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
      ENTRY CRCONS
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
      RETURN
      END
