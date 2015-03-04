      SUBROUTINE REGENT(LESTB,ITRNIN)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **REGENT--NC   DATE OF LAST REVISION:   01/11/12
C----------
C  **REGENT** COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR SMALL
C  TREES.  THE HEIGHT INCREMENT MODEL AND DBH INCREMENT MODEL ARE
C  APPLIED TO TREES THAT ARE LESS THAN  5 INCHES DBH. FOR TREES
C  GREATER THAN 2 INCHES DBH, HEIGHT AND DBH INCREMENT PREDICTIONS
C  ARE AVERAGED WITH PREDICTIONS FROM THE LARGE TREE MODEL.
C
C  **REGENT** IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **GRINCR** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
C
C  **REGENT** IS ALSO USED TO PREDICT HEIGHT INCREMENT, DBH AND CROWN
C  RATIO FOR TREES THAT ARE CREATED BY THE REGENERATION ESTABLISHMENT
C  MODEL.  5-YEAR OLD TREES ARE GENERATED BY **ESTAB** AND **REGENT**
C  COMPUTES INCREMENTS FROM AGE 5 TO THE END OF THE CYCLE.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'PDEN.F77'
C
      INCLUDE 'HTCAL.F77'
C
      INCLUDE 'MULTCM.F77'
C
      INCLUDE 'ESTCOR.F77'
C
      INCLUDE 'VARCOM.F77'
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C      HT1 -- SPECIES DEPENDENT CONSTANT IN THE HEIGHT-DBH MODEL USED
C             TO ASSIGN DIAMETERS TO SMALL TREES.
C      HT2 -- SPECIES DEPENDENT EXPONENT IN THE HEIGHT-DBH MODEL USED
C             TO ASSIGN DIAMETERS TO SMALL TREES.
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED. ALSO DBH INCREMENT.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED. ALSO DBH INCREMENT.
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      REAL CORTEM(MAXSP)
      INTEGER NUMCAL(MAXSP),K
      REAL XMAX(MAXSP),XMIN(MAXSP),DIAM(MAXSP)
      REAL TEMP,P,EDH,XHTGR,SNY,SNX,SSITE,DDS,SCALE,SCALE2,SCALE3
      INTEGER ISPEC,KK,KOUT,N,IREFI,I3,I2,I1,ISPC,ITRNIN,NTYR,I,IPCCF
      REAL REGYR,CR,RAN,BACHLO,XRHGRO,XRDGRO,CON,XMX,XMN,BX,AX,XSITE
      REAL D,L,H,XBA,RELHT,TPCCF,HTGR,XA,XPPMLT,XWT,HK,DK,BARK
      REAL BRATIO,CORNEW,SNP,TERM,DKK,X1
      CHARACTER SPEC*2
C----------
C  DATA STATEMENTS.
C----------
      DATA DIAM/
     & 0.3, 0.4, 2*0.3, 4*0.2, 0.3, 0.5, 0.2/
      DATA XMAX/ 11*5.0 /,  XMIN/ 11*2.0 /
      DATA REGYR/5.0/
C----------
C  CHECK FOR DEBUG.
C----------
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
C----------
C  THE SMALL TREE HEIGHT INCREMENT MODEL IS BASED ON 5-YEAR GROWTH DATA.
C----------
      LSKIPH=.FALSE.
      NTYR=FINT
      IF(LSTART) NTYR=IFINTH
      IF(LESTB) NTYR=NTYR-5
      IF(LESTB.AND.NTYR.LE.0) LSKIPH=.TRUE.
C----------
C  IF THIS IS THE FIRST ENTRY, BRANCH TO THE CALIBRATION SECTION.
C----------
      IF(LSTART) GOTO 40
C----------
C  LOAD MULTIPLIERS.
C----------
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      SCALE=YR/FINT
      SCALE2=FINT/REGYR
      IF(DEBUG)WRITE(JOSTND,8996)LESTB,LSKIPH,ITRN,ITRNIN,SCALE,SCALE2
 8996 FORMAT('IN REGENT, LESTB = ',L1,', LSKIPH = ',L1,
     &  ', ITRN = ',I4,', ITRNIN = ',I4,', SCALE = ',F6.3,
     &  ', SCALE2 = ',F6.3)
      IF (ITRN.LE.0) RETURN
C----------
C  STORE INITIAL HEIGHTS IN WK3; DUB CROWN RATIO FOR NEWLY ESTABLISHED
C  SEEDLINGS.
C----------
      DO 13 I=1,ITRN
      IF(LESTB.AND.I.GE.ITRNIN) THEN
        IPCCF=ITRE(I)
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
   12   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 12
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=(CR*100.0)+0.5
      ENDIF
      WK3(I)=HT(I)
   13 CONTINUE
C----------
C  ENTER GROWTH PREDICTION LOOP.  TREES ARE PROCESSED ONE AT A TIME.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
      XRHGRO=XRHMLT(ISPC)*SCALE2
      XRDGRO=XRDMLT(ISPC)
      CON=RHCON(ISPC)*EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      BX=HT2(ISPC)
      IF(IABFLG(ISPC) .EQ. 1) THEN
        AX=HT1(ISPC)
      ELSE
        AX=AA(ISPC)
      ENDIF
      XSITE=SITEAR(ISPC)
      DO 25 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      IF(D.GE.XMX) GO TO 25
      IF(LESTB .AND. I.LT.ITRNIN) GO TO 25
      K=I
      L=0
      H=HT(I)
C----------
C  IF CALLED FROM **ESTAB** AND TOTAL CYCLE LENGTH IS LESS THAN OR EQUAL
C  TO 5 YEARS, SKIP HEIGHT INCREMENT CALCULATION BUT ASSIGN CR AND DBH.
C----------
      IF(LSKIPH) THEN
         HTG(K)=0
         GO TO 20
      ENDIF
      XBA=BA
      IF(XBA .LE. 0.0) XBA=0.1
      CR=ICR(I)/10.0
      RELHT=1.
      IF(H.GT.0. .AND. AVH.GT.0.)RELHT=H/AVH
      TPCCF=PCCF(ITRE(I))
      IF(TPCCF .LE. 75.) RELHT=1.0-((RELHT-1.0)/75.)*TPCCF
      IF(RELHT .GT. 1.5) RELHT=1.5
      CALL HTGR5(ISPC,XSITE,XBA,HTGR,RELHT,CR,H)
      IF(DEBUG)WRITE(JOSTND,*)'AFTER HTGR5 I,ISPC,XSITE,XBA,HTGR,',
     &'RELHT,CR,CON,XRHGRO=',I,ISPC,XSITE,XBA,HTGR,RELHT,CR,H,
     &CON,XRHGRO
      HTGR = HTGR*CON*XRHGRO
C----------
C     GET A MULTIPLIER FOR THIS TREE FROM PPREGT TO ACCOUNT FOR
C     THE DENSITY EFFECTS OF NEIGHBORING TREES.
C
      X1=0.
      XPPMLT=0.
      CALL PPREGT (XPPMLT,X1,X1,X1,X1)
C----------
      HTGR = HTGR + XPPMLT
   18 CONTINUE
C----------
C  COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C  ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN OR IF CALLED
C  FROM **ESTAB**, THE LARGE TREE PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=0.0
      IF(D.LE.XMN.OR.LESTB) GO TO 19
      XWT=(D-XMN)/(XMX-XMN)
   19 CONTINUE
      HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
   20 CONTINUE
C----------
C  ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C  THAN 3 INCHES.  COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C  PROJECTION PERIOD LENGTH.  BYPASS INCREMENT CALCULATION IF
C  D GE 3.0 INCHES.
C----------
      IF(D.GE.3.0) GO TO 23
      HK=H+HTG(K)
      IF(HK .LE. 4.5) THEN
        DBH(K) = D + HK*0.001
        DG(K)=0.0
      ELSE
        DK=BX/(ALOG(HK-4.5)-AX)-1.0
        IF(H .LE. 4.5) THEN
          DKK = D
        ELSE
          DKK=BX/(ALOG(H-4.5)-AX)-1.0
        ENDIF
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
      IF(.NOT.LHTDRG(ISPC) .OR.
     &   (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
        CALL HTDBH (IFOR,ISPC,DK,HK,1)
        IF(H .LE. 4.5) THEN
          DKK=D
        ELSE
          CALL HTDBH (IFOR,ISPC,DKK,H,1)
        ENDIF
        IF(DEBUG)WRITE(JOSTND,*)'INV EQN DUBBING IFOR,ISPC,H,HK,DK,'
     &  ,'DKK= ',IFOR,ISPC,H,HK,DK,DKK
        IF(DEBUG)WRITE(JOSTND,*)'ISPC,LHTDRG,IABFLG= ',
     &  ISPC,LHTDRG(ISPC),IABFLG(ISPC)
      ENDIF
C----------
C       IF CALLING FROM **ESTAB** ASSIGN DIAMETER AND DIAMETER
C       INCREMENT.
C----------
        IF(LESTB) THEN
          DBH(K)=DK
          IF(DBH(K) .LT. DIAM(ISPC)) DBH(K)=DIAM(ISPC)
          DBH(K)=DBH(K) + 0.001*HK
          DG(K)=DBH(K)
        ELSE
C----------
C         DIAMETER INCREMENT IS THE DIFFERENCE BETWEEN COMPUTED
C         DIAMETERS.  MULTIPLIER IS APPLIED TO DIAMETER INCREMENT
C         AT THIS POINT.
C----------
          BARK=BRATIO(ISPC,DBH(K),HT(K))
          IF(DK.LT.0. .OR. DKK.LT.0.)THEN
            DG(K)=HTG(K)*0.2*BARK*XRDGRO
            DK=D+DG(K)
          ELSE
            DG(K)=(DK-DKK)*BARK*XRDGRO
          ENDIF
          IF(DG(K).LT.0.) DG(K)=0.
C----------
C         SCALE DIAMETER INCREMENT FOR BARK AND PERIOD LENGTH.
C         IN ORDER TO MAINTAIN CONSISTENCY WITH **GRADD**,
C         ADJUSTMENTS ARE MADE ON THE DDS SCALE.
C----------
          DDS = DG(K)*(2.0*BARK*D+DG(K))*SCALE
          DG(K)=SQRT((D*BARK)**2.0+DDS)-BARK*D
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
   23 CONTINUE
C----------
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TRIPLE OR NEXT TREE.
C----------
      IF(.NOT.DEBUG) GO TO 24
      WRITE(JOSTND,9000) I,K,ISPC,H,HTG(K),HK,DBH(K),DG(K)
 9000 FORMAT('IN REGENT LOOP 2, I=',I4,', K=',I4,', ISPC=',I3,
     &       ', CUR HT=',F7.2,', HT INC=',F7.4/T19,'NEW HT=',F7.2,
     &       ', CUR DBH=',F7.2,', 10-YR DBH INC=',F7.4)
   24 CONTINUE
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 25
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 18
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   25 CONTINUE
   30 CONTINUE
      RETURN
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) RETURN
      IF(IFINTH .EQ. 0)  GOTO 100
      SCALE3 = REGYR/FINTH
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      DO 90 ISPC=1,MAXSP
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 90
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      SSITE=SITEAR(ISPC)
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS GREATER THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
      IF(HTG(I).LT.0.001) GO TO 60
      CR=FLOAT(ICR(I))/10.
      RELHT=H/AVH
      IF(RELHT .GT. 1.5) RELHT=1.5
      XBA=BA
      IF(XBA .LE. 0.0) XBA=0.1
      CALL HTGR5(ISPC,SSITE,XBA,XHTGR,RELHT,CR,H)
      EDH=XHTGR*RHCON(ISPC)
      P=PROB(I)
      TERM=HTG(I)*SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG) WRITE(JOSTND,9001) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),XHTGR,RHCON(ISPC),EDH,TERM
 9001 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  XHTGR=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9010) ISPC,SNP,SNX,SNY
 9010 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';   SNX=',F10.2,';   SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE FOR THE GROWTH SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  THE CORRECTION TERM IS THE MEAN OF OBSERVED INCREMENTS
C  DIVIDED BY THE MEAN OF PREDICTED INCREMENTS (NOT THE REGRESSION
C  ESTIMATE USED FOR DIAMETER INCREMENT CALIBRATION).
C----------
      CORNEW=SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
   90 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9002) (NUMCAL(I),I=1,NUMSP)
 9002 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T48,11(I4,2X)/)))
  100 CONTINUE
      WRITE(JOSTND,9003) (CORTEM(I),I=1,NUMSP)
 9003 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
      RETURN
C
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C---------
      DO 110 ISPC=1,MAXSP
      RHCON(ISPC)=1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)
     &RHCON(ISPC)=RCOR2(ISPC)
  110 CONTINUE
      RETURN
      END
