      SUBROUTINE VOLS
      use contrl_mod
      use prgprm_mod
      use plot_mod
      use coeffs_mod
      use arrays_mod
      implicit none
C----------
C  **VOLS--ON    DATE OF LAST REVISION:   05/11/11
C----------
C
C  THIS SUBROUTINE CALCULATES TREE VOLUMES AND COMPUTES
C  DISTRIBUTION AND COMPOSITION VECTORS FOR VOLUME AND ACCRETION.
C
C  NATCRS, OCFVOL, AND OBFVOL ARE ENTRY POINTS IN SUBROUTINE
C  **VARVOL**, WHICH IS VARIANT SPECIFIC.
C----------
C
      INCLUDE 'OUTCOM.F77'
      INCLUDE 'VOLSTD.F77'
      INCLUDE 'METRIC.F77'
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C  SPCCC -- TOTAL MERCH CUBIC VOLUME BY SPECIES AND TREE CLASS.
C  SPCAC -- TOTAL MERCH CUBIC VOLUME ACCRETION BY SPECIES AND TREE CLASS.
C  SPCMC -- MERCH SAWLOG CUBIC VOLUME BY SPECIES AND TREE CLASS.
C  SPCBV -- MERCH SAWLOG BOARD VOLUME BY SPECIES AND TREE CLASS.
C
C  THESE VALUES DO NOT INCLUDE CYCLE 0 DEAD TREES.
C  IPASS=1 FOR LIVE TREES;  IPASS=2 FOR CYCLE 0 DEAD TREES.
C
C  BTKFLG - LOGICAL VARIABLES TO INDICATE WHETHER THE VOLUME ESTIMATE
C  CTKFLG   NEEDS TO BE ADJUSTED FOR TOPKILL OR NOT:
C           BTKFLG FOR SAWLOG VOLUME (CUBIC AND BOARD FT)
C           CTKFLG FOR CUBIC PULPWOOD VOLUME
C           .TRUE.  = ADJUST ESTIMATE FOR TOPKILL
C           .FALSE. = NO ADJUSTMENT NEEDED (ALREADY ACCOUNTED FOR).
C
C  VN   = TOTAL MERCH CUBIC FOOT VOLUME (PULPWOOD + SAWLOG CUBIC)
C  VM   = SAWLOG CUBIC FOOT VOLUME
C  BBFV = SAWLOG BOARD FOOT VOLUME
C
C   UPON EXITING THIS ROUTINE:
C   CFV = CARRIES TOTAL MERCH VOLUME IN EASTERN VARIANTS.  THIS IS
C         COMPOSED OF PULPWOOD CUBIC AND SAWLOG CUBIC.
C   WK1 = CARRIES SAWLOG CUBIC FOOT VOLUME.
C   BFV = CARRIES SAWLOG BOARD FOOT VOLUME.
C
C   PULPWOOD CUBIC VOLUME IS CALCULATED AS CFV()-WK1().
C----------
      INTEGER DLIEQN,DLLMOD,FOREST
      LOGICAL DEBUG
      REAL SPCCC(MAXSP,3),SPCAC(MAXSP,3),SPCBV(MAXSP,3),SPCMC(MAXSP,3)
      REAL DBHCLS(9)
      INTEGER I,J,IPASS,ILOW,IHI,ISPC,IT,IM,ICDF,IBDF
      REAL P,D,H,BARK,BRATIO,D2H,VN,VM,VMAX,BBFV,TEMCFI,TEMVOL,ALGSLP
      REAL VOLCOR,PULPV
      LOGICAL TKILL,LCONE,BTKFLG,CTKFLG
      CHARACTER VVER*7
C----------
C  INITIALIZE DBH CLASSES.
C----------
      DATA DBHCLS/0.0,5.0,10.0,15.0,20.0,25.0,30.0,35.0,40.0/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'VOLS',4,ICYC)
      DO J=1,2
      DO I=1,MAXTRE
      HT2TD(I,J)=0.
      ENDDO
      ENDDO
      IF (ITRN.LE.0) GOTO 2
      DO 1 I=1,MAXSP
      DO 1 J=1,3
      SPCCC(I,J)=0.0
      SPCAC(I,J)=0.0
      SPCMC(I,J)=0.0
      SPCBV(I,J)=0.0
    1 CONTINUE
    2 CONTINUE
      IPASS=1
      ILOW=1
      IHI=ITRN
C----------
C  CALL VOLKEY TO PROCESS KEYWORDS USED TO CHANGE VOLUME STANDARDS AND
C  EQUATIONS.
C----------
      CALL VOLKEY (DEBUG)
      IF (ITRN.LE.0) GOTO 205
      FOREST = KODFOR-900
      CALL VARVER(VVER)
      IF(VVER(1:2).EQ.'SN')FOREST=(KODFOR-80000)/100
C----------
C  ENTER TREE BY TREE LOOP TO CALCULATE VOLUMES AND COMPILE
C  SUMMARY ARRAYS.
C
C  I -- SUBSCRIPT TO TREE RECORD.
C  P -- NUMBER OF TREES PER ACRE REPRESENTED BY TREE I.
C  D -- DIAMETER OF TREE I.
C  H -- HEIGHT OF TREE I.
C  ISPC -- SPECIES OF TREE I.
C  WK5 -- ARRAY CONTAINING TOTAL ANNUAL MERCH CUBIC VOLUME ACCRETION
C    PER ACRE FOR EACH TREE.  THIS ARRAY IS NOT LOADED
C    IF LSTART IS TRUE.
C  VN -- USED TO TEMPORARILY STORE TOTAL MERCH CUBIC VOLUME FOR TREE I.
C----------
   10 CONTINUE
      DO 200 I=ILOW,IHI
      WK5(I)=0.0
      P=PROB(I)
      IF(P.LE.0.0) GO TO 200
      ISPC=ISP(I)
      D=DBH(I)
      H = HT(I)
C----------
C  INITIALIZE TOP KILL FLAG FOR NEXT TREE; IF TOPKILLED, ASSIGN H TO
C  NORMHT.
C----------
      TKILL = H.GE.4.5 .AND. ITRUNC(I).GT.0
      IF(TKILL) H=NORMHT(I)/100.0
C----------
C  IF NOT INITIAL SUMMARY, ADD DG TO DBH; ASSIGN D2H.
C----------
      BARK=BRATIO(ISPC,D,H)
      IF(.NOT.LSTART) D=D+DG(I)/BARK
      D2H=D*D*H
C**************************************************
C        TOTAL MERCH VOLUME SECTION               *
C**************************************************
C----------
C  INITIALIZE VOLUME ESTIMATES.
C----------
      VN=0.
      VM=0.
      VMAX=0.
      IF(DEBUG)WRITE(JOSTND,*)' CUBIC SECTION, I,ISPC,METHC= ',
     &I,ISPC,METHC(ISPC)
C----------
C  CALCULATE TOTAL MERCH CUBIC VOLUME. CORRECT FOR TOP KILL IF NEEDED.
C----------
      IT=I
      IF(METHC(ISPC).EQ.6) THEN
        CALL NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,
     1               CTKFLG,BTKFLG,IT)
      ELSEIF ((METHC(ISPC).EQ.8).OR.(METHC(ISPC).EQ.5)) THEN
        CALL OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,LCONE,
     1               CTKFLG,IT)
      ELSE
        CALL CFVOL (ISPC,D,H,D2H,VN,VM,VMAX,TKILL,LCONE,BARK,ITRUNC(I),
     1              CTKFLG)
      ENDIF
      IF(CTKFLG .AND. TKILL .AND. VMAX .GT. 0.)
     1 CALL CFTOPK (ISPC,D,H,VN,VM,VMAX,LCONE,BARK,ITRUNC(I))
C----------
C  LOAD WK1 WITH MERCH CUBIC SAWLOG VOLUME PER TREE.
C----------
      WK1(I)=VM
C----------
C  SUMMARIZE VOLUME BY SPECIES AND TREE CLASS.  IF LSTART IS
C  FALSE, LOAD WK5 AND SUMMARIZE ACCRETION BY SPECIES AND TREE
C  CLASS. DO NOT DO THIS FOR CYCLE 0 DEAD TREES.
C----------
      IF(IPASS .EQ. 2) GO TO 15
      IM=IMC(I)
C----------
C  STORE LAST CYCLE CFV CORRECTED FOR DEFECT FOR USE LATER IN
C  COMPUTING ACCRETION.
C----------
      TEMCFI=CFV(I)
C
      SPCCC(ISPC,IM)=SPCCC(ISPC,IM)+VN*P
C----------
C  LOAD CFV WITH TOTAL CUBIC VOLUME PER TREE.
C  WK1 CONTAINS THE MERCH CUBIC SAWLOG VOLUME PER TREE.
C----------
   15 CONTINUE
      CFV(I)=VN
      TEMVOL=CFV(I)-WK1(I)
      ICDF= DEFECT(I)/1000000
      IF(CFV(I).GT.0.0 .AND. LCVOLS) THEN
C----------
C       COMPUTE DEFECT CORRECTION FACTOR FOR CUBIC FOOT PULPWOOD VOLUME.
C       TAKE LARGEST OF 1) INPUT CF DEFECT PERCENT, 2) COMPUTED LINEAR
C       INTERPOLATION VALUE, OR 3) COMPUTED LOG-LINEAR MODEL VALUE.
C----------
        DLIEQN=NINT(ALGSLP(D,DBHCLS,CFDEFT(1,ISPC),9) * 100.)
        IF(DLIEQN.GT.ICDF) ICDF=DLIEQN
        IF(CFLA0(ISPC).EQ.0.0 .AND. CFLA1(ISPC).EQ.1.0) THEN
          VOLCOR=TEMVOL
        ELSE
          VOLCOR=EXP(CFLA0(ISPC)+CFLA1(ISPC)*ALOG(TEMVOL))
        ENDIF
        IF(TEMVOL .EQ. 0.)GO TO 20
        DLLMOD=NINT(((TEMVOL-VOLCOR)/TEMVOL) * 100.)
        IF(DLLMOD.GT.ICDF) ICDF=DLLMOD
   20   CONTINUE
        IF(ICDF.GT.99) ICDF=99
        IF(ICDF.LT. 0) ICDF= 0
      ENDIF
C**************************************************
C        BOARD FOOT SAWLOG VOLUME SECTION         *
C**************************************************
C----------
C  COMPUTE SCRIBNER BOARD FOOT VOLUME TO A VARIABLE TOP FOR TREES
C  OF MINIMUM MERCHANTABLE DBH AND LARGER.
C----------
      BFV(I)=0.0
      IBDF= DEFECT(I)/10000 - (DEFECT(I)/1000000)*100
      IF(D.LT.BFMIND(ISPC).OR.D.LE.BFTOPD(ISPC)) GO TO 150
C----------
C   CALCULATE SCRIBNER BOARD FOOT VOLUME.
C   NOTE: METHODS 6 AND 9 GIVE SAME ANSWERS IN EASTERN VARIANTS
C         METHOD 9 IS FOR INTERNATIOAL BF VOLUMES, AND WE CURRENTLY
C         DON'T RETURN THOSE FROM VARVOL IN THE EAST.
C----------
      IF(DEBUG)WRITE(JOSTND,*)' BOARD SECTION, I,ISPC,D,H,METHB= ',
     &I,ISPC,D,H,METHB(ISPC)

      IF(METHB(ISPC).EQ.6 .OR. METHB(ISPC).EQ.9) THEN
        IF(METHC(ISPC).EQ.6) THEN
          GO TO 100
        ELSE
        CALL NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,
     1               CTKFLG,BTKFLG,IT)
        ENDIF
      ELSEIF ((METHB(ISPC).EQ.8).OR.(METHB(ISPC).EQ.8)) THEN
        IT=I
        CALL OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,LCONE,
     1               BTKFLG,IT)
      ELSE
        CALL BFVOL (ISPC,D,H,D2H,BBFV,TKILL,LCONE,BARK,VMAX,ITRUNC(I),
     1              BTKFLG)
      ENDIF
C----------
C  CORRECT FOR TOPKILL IF NEEDED.
C  LOAD BFV WITH SCRIBNER BOARD FOOT VOLUME CORRECTED FOR TOPKILL.
C----------
  100 CONTINUE
      IF(BTKFLG .AND. TKILL .AND. VMAX .GT. 0.)
     1 CALL BFTOPK (ISPC,D,H,BBFV,LCONE,BARK,VMAX,ITRUNC(I))

C     TO TRICK THE PRINTING OF BOARD FOOT IN OUTPUT ROUTINES
C     THAT EXPECT THE UNITS TO BE "FT3toM3" SCALED BY HA, DIVIDE
C     THAT CONSTANT OUT HERE. THIS ONLY HAPPENS WHEN THE
C     USER GIVES A BFVOLUME .NE. 8 (THE FVS-ON DEFAULT)

      IF (METHB(ISPC).NE.8) THEN
        BFV(I)= BBFV / FT3toM3
      ELSE
        BFV(I)=BBFV
      ENDIF

      IF(BFV(I).GT.0.0 .AND. LBVOLS) THEN
C----------
C     COMPUTE DEFECT CORRECTION FACTOR FOR BOARD FOOT VOLUME.
C     TAKE LARGEST OF 1) INPUT BF DEFECT PERCENT, 2) COMPUTED LINEAR
C     INTERPOLATION BF VALUE, OR 3) COMPUTED LOG-LINEAR MODEL BF VALUE.
C----------
        DLIEQN=NINT(ALGSLP(D,DBHCLS,BFDEFT(1,ISPC),9) * 100.)
        IF(DLIEQN.GT.IBDF)IBDF=DLIEQN
        IF(BFLA0(ISPC).EQ.0.0 .AND. BFLA1(ISPC).EQ.1.0) THEN
          VOLCOR=BFV(I)
        ELSE
          VOLCOR=EXP(BFLA0(ISPC)+BFLA1(ISPC)*ALOG(BFV(I)))
        ENDIF
        DLLMOD=NINT(((BFV(I)-VOLCOR)/BFV(I)) * 100.)
        IF(DLLMOD.GT.IBDF)IBDF=DLLMOD
        IF(IBDF.GT.99)IBDF=99
        IF(IBDF.LT. 0)IBDF= 0
      ENDIF
C----------
C  RESET NEGATIVE VOLUMES TO ZERO, ADJUST FOR DEFECT, AND COMPILE TOTAL.
C  CONSIDER 99% DEFECT AS 100% DEFECT.
C  AT THIS POINT:
C     CFV = TOTAL MERCH CUBIC VOLUME (SAWLOG CUBIC + PULPWOOD CUBIC)
C     WK1 = MERCH CUBIC SAWLOG VOLUME PER TREE
C     BFV = MERCH BOARD SAWLOG VOLUME PER TREE
C  DEFINE:
C   PULPV = PULPWOOD VOLUME PER TREE
C----------
  150 CONTINUE
      IF(BFV(I).LT.0.) BFV(I)=0.
      IF(CFV(I).LT.0.) CFV(I)=0.
      IF(WK1(I).LT.0.) WK1(I)=0.
      PULPV=CFV(I)-WK1(I)
C----------
C     CORRECT PULPWOOD CUBIC VOLUME FOR FORM AND DEFECT.
C     CONSIDER 99% DEFECT AS 100% DEFECT.
C----------
      IF(ICDF.LT.99) THEN
        PULPV=PULPV*(1.-FLOAT(ICDF)/100.)
      ELSE
        PULPV=0.
      ENDIF
C----------
C     CORRECT MERCHANTABLE BOARD FOOT VOLUME FOR FORM AND DEFECT.
C     CONSIDER 99% DEFECT AS 100% DEFECT.
C----------
      IF(IBDF.LT.99) THEN
        BFV(I)=BFV(I)*(1.-FLOAT(IBDF)/100.)
        WK1(I)=WK1(I)*(1.-FLOAT(IBDF)/100.)
      ELSE
        BFV(I)=0.
        WK1(I)=0.
      ENDIF
C----------
C     RESET THE TOTAL MERCH CUBIC TO THE CORRECTED SUM
C     AND COMPUTE ACCRETION
C----------
      CFV(I)=PULPV+WK1(I)
      IF(.NOT.LSTART) THEN
        IF(TEMCFI.GT.CFV(I))THEN
          WK5(I)=0.
        ELSE
          WK5(I)=(CFV(I)-TEMCFI)*P/FINT
        ENDIF
        SPCAC(ISPC,IM)=SPCAC(ISPC,IM)+WK5(I)
      ENDIF
C
      IF(IPASS .EQ. 1) SPCBV(ISPC,IM)=SPCBV(ISPC,IM)+BFV(I)*P
      IF(IPASS .EQ. 1) SPCMC(ISPC,IM)=SPCMC(ISPC,IM)+WK1(I)*P
C----------
C  SET VALUES IN CODED DEFECT NUMBER TO INDICATE THE ACTUAL DEFECT
C  PERCENTAGES APPLIED THIS CYCLE.
C  DEFECT CODED AS 11223344, WHERE 11=INPUT MC DEFECT %, 22=INPUT BF
C  DEFECT PERCENT, 33=MC DEFECT % USED THIS CYCLE, 44=BF DEFECT % USED
C  THIS CYCLE.
C----------
      DEFECT(I)=((DEFECT(I)/10000)*10000) + ICDF*100 + IBDF
      IF(DEBUG)WRITE(JOSTND,*)' IN VOLS, I= ',I,' DEFECT= ',DEFECT(I)
C----------
C  PRINT DEBUG OUTPUT IF DESIRED
C----------
      IF(.NOT.DEBUG) GO TO 200
      WRITE(JOSTND,9000)I,VN,WK1(I),OMCCUR(7),OBFCUR(7),WK5(I),CFV(I),
     &     SPCAC(ISPC,1),SPCAC(ISPC,2),SPCAC(ISPC,3),SPCCC(ISPC,1),
     &     SPCCC(ISPC,2),SPCCC(ISPC,3),ISPC,D,H
 9000 FORMAT(' IN VOLS, I=',I4,' VN=',E15.6,' WK1=',E15.6,' OMCCUR=',
     &  E15.6,' OBFCUR=',E15.6,/,'  WK5=',E15.6,' CFV=',E15.6,
     &  ' SPCAC=',3(E15.6,',')/'  SPCCC=',3(E15.6,','),' ISPC=',I2,
     &  ' DBH=',E11.2,' NORMAL HT=',E11.2)
C----------
C  END OF TREE LOOP.
C----------
  200 CONTINUE
  205 CONTINUE
      IF(IPASS .EQ. 2) GO TO 250
C----------
C  DETERMINE SPECIES-TREE CLASS COMPOSITION FOR ALL VOLUME STANDARDS.
C----------
      CALL COMP(OSPCV,IOSPCV,SPCCC)
      CALL COMP(OSPBV,IOSPBV,SPCBV)
      CALL COMP(OSPMC,IOSPMC,SPCMC)
C----------
C  DETERMINE SPECIES-TREE CLASS COMPOSITION AND PERCENTILE POINTS IN
C  THE DISTRIBUTION OF DIAMETERS FOR ANNUAL TOTAL CUBIC FOOT ACCRETION.
C  BYPASS IF LSTART IS TRUE.
C----------
      IF(LSTART) GO TO 210
      CALL COMP(OSPAC,IOSPAC,SPCAC)
      CALL PCTILE(ITRN,IND,WK5,WK3,OACC(7))
      CALL DIST(ITRN,OACC,WK3)
  210 CONTINUE
C----------
C  CALCULATE VOLUMES FOR CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 250
      IPASS=2
      ILOW=IREC2
      IHI=MAXTRE
      GO TO 10
C----------
C  END OF VOLS.
C----------
  250 CONTINUE
      RETURN
      END
