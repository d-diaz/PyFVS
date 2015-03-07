      SUBROUTINE DGF(DIAM)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use pden_mod
      use prgprm_mod
      implicit none
C----------
C  **DGF--BM    DATE OF LAST REVISION:  02/16/10
C----------
C  THE SEPERATE EQUATIONS FOR TREES LESS THAN 10" DBH INCLUDED
C  MANAGED STAND SURVEY (MSS) DATA.  THE EQUATION FOR LODGEPOLE PINE
C  WAS REFIT TO INCLUDE TERMS FOR CCF AND BA EFFECTS.
C  ALSO, SPLINE FOR DIAMETER ESTIMATES BASED ON MSS DATA, AND FOR
C  ESTIMATES BASED ON LARGER TREES NOW COVERS WHOLE RANGE 3-10" DBH,
C  INSTEAD OF ONLY 7-10".                    DENNIS DONNELLY 11/30/95
C----------
C  Earlier revisions include coefficients for the following species:
C  WL, DF, GF, LP, ES, AF, & PP.  The coefficients for WP, & OT are
C  unchanged.  Species #4 is now GF (no WF in model) and Species #6
C  is now 'blank'.  Species #5 changed from 'WH' to 'MH'.
C
C  SEPERATE EQUATIONS ADDED FOR WL,DF,GF,LP,& PP LESS THAN 10" DBH
C  DIXON 5/16/94. OTHER SPECIES ARE PROXIED
C
C  REFIT EQUATIONS FOR TREES LESS THAN 10" DBH LOADED 9/9/99. THESE
C  WERE REFIT IN 1996 BY RALPH JOHNSON.  DIXON 9/9/99
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF DDS (CHANGE IN SQUARED
C  DIAMETER) FOR EACH TREE RECORD, AND LOADS IT INTO THE ARRAY
C  WK2.  DDS IS PREDICTED FROM HABITAT TYPE, LOCATION, SLOPE,
C  ASPECT, ELEVATION, DBH, CROWN RATIO, BASAL AREA IN LARGER TREES,
C  AND CCF.  THE SET OF TREE DIAMETERS TO BE USED IS PASSED AS THE
C  ARGUEMENT DIAM.  THE PROGRAM THUS HAS THE FLEXIBILITY TO
C  PROCESS DIFFERENT CALIBRATION OPTIONS.  THIS ROUTINE IS CALLED
C  BY **DGDRIV** DURING CALIBRATION AND WHILE CYCLING FOR GROWTH
C  PREDICTION.  ENTRY **DGCONS** IS CALLED BY **RCON** TO LOAD SITE
C  DEPENDENT COEFFICIENTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
      INCLUDE 'OUTCOM.F77'
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C     DIAM -- ARRAY LOADED WITH TREE DIAMETERS (PASSED AS AN
C             ARGUEMENT).
C     DGLD -- ARRAY CONTAINING COEFFICIENTS FOR THE LOG(DIAMETER)
C             TERM IN THE DDS MODEL (ONE COEFFICIENT FOR EACH
C             SPECIES).
C     DGCR -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO TERM IN THE DDS MODEL (ONE COEFFICIENT FOR
C             EACH SPECIES).
C   DGCRSQ -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO SQUARED TERM IN THE DDS MODEL (ONE
C             COEFFICIENT FOR EACH SPECIES).
C   DGDBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE INTERACTION
C             BETWEEN BASAL AREA IN LARGER TREES AND LN(DBH) (ONE
C             COEFFICIENT PER SPECIES).
C----------
C  SPECIES ORDER:
C   1=WP,  2=WL,  3=DF,  4=GF,  5=MH,  6=WJ,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=WB, 12=LM, 13=PY, 14=YC, 15=AS, 16=CW,
C  17=OS, 18=OH
C----------
C  SPECIES EXPANSION:
C  WJ USES SO JU (ORIGINALLY FROM UT VARIANT; REALLY PP FROM CR VARIANT)
C  WB USES SO WB (ORIGINALLY FROM TT VARIANT)
C  LM USES UT LM
C  PY USES SO PY (ORIGINALLY FROM WC VARIANT)
C  YC USES WC YC
C  AS USES SO AS (ORIGINALLY FROM UT VARIANT)
C  CW USES SO CW (ORIGINALLY FROM WC VARIANT)
C  OS USES BM PP
C  OH USES SO OH (ORIGINALLY FROM WC VARIANT)
C----------
      REAL DIAM(MAXTRE),DGLD(MAXSP),DGLBA(MAXSP),DGCR(MAXSP),
     &   DGCRSQ(MAXSP),DGDBAL(MAXSP),DGFOR(4,MAXSP),DGDS(MAXSP),
     &   DGEL(MAXSP),DGEL2(MAXSP),DGSASP(MAXSP),DGCASP(MAXSP),
     &   DGSLOP(MAXSP),DGSLSQ(MAXSP),OBSERV(MAXSP),DGSITE(MAXSP),
     &   DGPCCF(MAXSP),DGBA(MAXSP),DGBAL(MAXSP),DGCCFA(MAXSP),
     &   DGSIC(MAXSP),TEMEL
C
      INTEGER SMMAPH(92,5),SMMAPS(MAXSP)
      REAL SMCONS,SMHAB(5,5),SMPCCF(5),SMSLOP(5),SMCASP(5)
      REAL SMSASP(5),SMEL2(5),SMEL(5),SMDS(5),SMFOR(4,5)
      REAL SMDBAL(5),SMCRSQ(5),SMCR(5),SMLBA(5),SMLD(5)
C
      INTEGER ISPC,I1,I2,INDXS,I3,I,IPCCF,INDXH,IBSERV(5,3),J
      INTEGER LSI,ISIC
      REAL CONSPP,CLD,CLBA,CCR,CCR2,CDSQ,CDBAL,CPCCF,XSITE,ASPTEM
      REAL D,CR,BAL,HOAVH,DDSL,DDSS,DSQ,TEMDG,DSQNEW,XWT,DDS,ASPDG
      REAL BREL,BBA,XPPDDS,TSITE,ALBA,SI,BARK,BRATIO,DPP,BATEM,DF,DIAGR
C
      LOGICAL DEBUG
C----------
C FOR BM ORIGINAL SPECIES: 1-5, 6-10, AND 17:
C COEFFICIENTS FOR TREES SMALLER THAN 10 INCHES.
C SMHAB IS DIMENSIONED BY (COEFF INDEX, SPECIES INDEX).
C SMMAPH IS DIMENSIONED BY (PA INDEX, SPECIES INDEX).
C----------
      DATA SMLD/
     & 1.20856, 1.12948, 1.52803, 1.00488, 1.04225/
C
      DATA SMCR/
     & 1.73596, 1.54957, 0.66664, 2.47118, 2.31970/
C
      DATA SMCRSQ/
     & 0.00000, 0.00000, 1.20070,-0.99894,-0.43073/
C
      DATA SMDBAL/
     &-0.00066,-0.00223,-0.00199,-0.00358,-0.00105/
C
      DATA SMLBA/
     &-0.24782,-0.15369,-0.13405,-0.24135,-0.24965/
C
      DATA SMPCCF/
     & 0.00000,-0.00003,-0.00167,      0., 0.00000/
C
      DATA SMFOR/
     &-0.00991,-0.00991, 0.24298,-0.00991,
     & 0.12927, 0.12927, 0.42841, 0.31221,
     & 1.31341, 1.53206, 1.78409, 1.73754,
     &-0.21988,-0.21988, 0.22239,-0.47388,
     & 1.61313, 1.75654, 1.90894, 1.75744/
C
      DATA SMMAPS/ 1,1,2,3,4,0,4,3,3,5,
     &             0,0,0,0,0,0,5,0/
C
      DATA SMHAB/
C WESTERN LARCH
     & 0., -0.131277, -0.328134,  0.      ,  0.      ,
C DOUGLAS-FIR
     & 0., -0.336855, -1.004248, -0.195972, -0.092403,
C GRAND FIR
     & 0., -0.137259,  0.282528,  0.      ,  0.      ,
C LODGEPOLE PINE
     & 0.,  0.119324,  0.425094,  0.      ,  0.      ,
C PONDEROSA PINE
     & 0.,  0.482619,  0.173487, -0.087731,  0.      /
C
      DATA SMMAPH /
C WESTERN LARCH
     & 27*0, 2, 0, 2, 31*0, 2, 7*0, 2*1, 5*0, 13*1, 3*0,
C DOUGLAS-FIR
     & 1, 1, 8*3, 2*4, 3, 7*0, 2*1, 0, 2*1, 0, 1, 2, 0, 2, 16*3,
     & 2*0, 8*3, 2*0, 3, 0, 3, 2, 24*0, 2*3, 0, 3*3,
C GRAND FIR
     & 85*0, 2, 2*1, 2, 3*0,
C LODGEPOLE PINE
     & 0, 0, 8*2, 2*0, 2, 17*0, 16*2, 6*0, 2*2, 15*0, 2*1,
     & 5*0, 5*1, 0, 3*1, 4*0, 3*2,
C PONDEROSA PINE
     & 30*0, 16*3, 2*0, 8*3, 2*0, 3, 0, 3, 6*0, 2*1, 2*2, 5*1,
     & 4*0, 2, 1, 2*0, 2, 4*0, 3*3/
C
      DATA SMDS/
     & -0.000571,-0.000023,-0.000951,-0.000643,-0.000157/
C
      DATA SMCASP/
     &-0.06358,-0.11174,-0.18548,-0.46361,-0.08695/
C
      DATA SMSASP/
     & 0.12754, 0.05022,-0.11202, 0.35696,-0.13976/
C
      DATA SMSLOP/
     &-0.41366,-0.36252,-0.16110, 0.45733,-0.24248/
C
      DATA SMEL/
     & 0.00000,-0.00823,-0.09472, 0.00912,-0.07547/
C
      DATA SMEL2/
     & 0.00000, 0.00000, 0.00092, 0.00000, 0.00087/
C----------
C FOR BM ORIGINAL SPECIES: 1-5, 6-10, AND 17:
C   COEFFICIENTS FOR TREES LARGER THAN 10 INCHES;
C FOR ALL OTHER SPECIES, USE FOR ALL TREES.
C----------
      DATA DGLD/
     &  0.77889,  0.41802,  0.57990,  1.01031,    0.8978,      0.0,
     &  0.70429,  1.12805,  0.83642,  0.44675,  0.213947, 0.213947,
     & 0.879338, 0.816880,      0.0, 0.889596,   0.44675, 0.889596/
C
      DATA DGCR/
     &  3.36606,  2.15440,  2.13121,  2.56530,    1.2840,      0.0,
     &  3.00236,  3.22770,  1.60755,  1.70901,  1.523464, 1.523464,
     & 1.970052, 2.471226,      0.0, 1.732535,   1.70901, 1.732535/
C
      DATA DGCRSQ/
     & -1.80146, -1.03088, -0.40173, -0.91846,       0.0,      0.0,
     & -1.24947, -1.13951,      0.0,      0.0,       0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,       0.0,      0.0/
C
      DATA DGBA/
     &      0.0,      0.0,      0.0,      0.0,       0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,       0.0,      0.0,
     &-0.000173,-0.000147,      0.0,-0.000981,       0.0,-0.000981/
C
      DATA DGBAL/
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0,
     &      0.0,      0.0,      0.0,      0.0, -0.358634, -0.358634,
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0/
C
      DATA DGCCFA/
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0,
     &      0.0,      0.0,      0.0,      0.0, -0.199592, -0.199592,
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0/
C
      DATA DGSIC/
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0,
     &      0.0,      0.0,      0.0,      0.0,  0.001766,  0.001766,
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0/
C
      DATA DGSITE/
     &       0.0,  0.47469,  0.76217,  0.58666,      0.0,      0.0,
     &   0.34450,  0.34406,  0.51754,  0.73067,      0.0,      0.0,
     & 0.2528530, 0.244694,      0.0, 0.227307,  0.73067, 0.227307/
C
      DATA DGDBAL/
     &  -0.00897, -0.00801, -0.00886, -0.00557,-0.006611,      0.0,
     &  -0.00251, -0.00156, -0.00091, -0.01184,      0.0,      0.0,
     & -0.004215,-0.005950,      0.0,-0.001265, -0.01184,-0.001265/
C
      DATA DGLBA/
     &       0.0,      0.0, -0.06574, -0.15658,      0.0,      0.0,
     &  -0.17037,      0.0, -0.18969, -0.10675,      0.0,      0.0,
     &       0.0,      0.0,      0.0,      0.0, -0.10675,      0.0/
C
      DATA DGPCCF/
     &       0.0,      0.0, -0.00034,      0.0,-0.001074,      0.0,
     &  -0.00032, -0.00014, -0.00038, -0.00057,      0.0,      0.0,
     &       0.0,      0.0,      0.0,      0.0, -0.00057,      0.0/
C
      DATA  OBSERV/
     &  256., 1209., 3478., 2963., 1000.,   0.0,
     & 1117.,  596.,  599., 6577.,   0.0,   0.0,
     &  475.,    0.,   0.0,  220., 6577.,  220./
C----------
C  IBSERV IS THE NUMBER OF OBSERVATIONS IN THE DIAMETER GROWTH
C  MODEL BY SPECIES AND SITE CLASS; USED FOR WJ, WB, LM, AND AS
C----------
      DATA  ((IBSERV(I,J),I=1,5),J=1,3)/
     & 5*1000,                   !WJ
     &  27,  70, 123, 101,  33,  !WB & LM
     & 184, 429, 356, 162,  74/  !AS
C----------
C  DGFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.
C----------
      DATA DGFOR/
     & -0.23185, -0.23185, -0.23185, -0.23185,
     & -0.56061, -0.56061, -0.56061, -0.56061,
     & -1.69223, -1.69223, -1.69223, -1.78978,
     & -1.16884, -1.16884, -1.16884, -1.16884,
     &  -1.6803,  -1.6803,  -1.6803,  -1.6803,
     &      0.0,      0.0,      0.0,      0.0, !WJ
     &  1.59448,  1.59448,  1.59448,  1.49879,
     & -2.38952, -2.38952, -2.38952, -2.38952,
     & -0.48027, -0.48027, -0.48027, -0.48027,
     &  0.05217, -0.04456,  0.05217,  0.11197,
     & 1.911884, 1.911884, 1.911884, 1.911884, !WB USE TT BRIDGER NF
     & 1.911884, 1.911884, 1.911884, 1.911884, !LM
     &-1.310067,-1.310067,-1.310067,-1.310067, !PY
     &-1.178041,-1.178041,-1.178041,-1.178041, !YC
     &       0.,       0.,       0.,       0., !AS
     &-0.107648,-0.107648,-0.107648,-0.107648, !CW
     &  0.05217, -0.04456,  0.05217,  0.11197,
     &-0.107648,-0.107648,-0.107648,-0.107648/ !OH
C----------
C  DGDS CONTAINS COEFFICIENTS FOR THE DIAMETER SQUARED TERMS
C  IN THE DIAMETER INCREMENT MODELS; ARRAYED BY FOREST BY
C  SPECIES.
C----------
      DATA DGDS/
     & -0.000091,       0.0,-0.000380,-0.000541, -0.000484,       0.0,
     &       0.0, -0.000289, 0.000088,-0.000214,-0.0006538,-0.0006538,
     &-0.0001323,-0.0002536,      0.0,      0.0, -0.000214,       0.0/
C----------
C  DGEL CONTAINS THE COEFFICIENTS FOR THE ELEVATION TERM IN THE
C  DIAMETER GROWTH EQUATION.  DGEL2 CONTAINS THE COEFFICIENTS FOR
C  THE ELEVATION SQUARED TERM IN THE DIAMETER GROWTH EQUATION.
C  DGSASP CONTAINS THE COEFFICIENTS FOR THE SIN(ASPECT)*SLOPE
C  TERM IN THE DIAMETER GROWTH EQUATION.  DGCASP CONTAINS THE
C  COEFFICIENTS FOR THE COS(ASPECT)*SLOPE TERM IN THE DIAMETER
C  GROWTH EQUATION.  DGSLOP CONTAINS THE COEFFICIENTS FOR THE
C  SLOPE TERM IN THE DIAMETER GROWTH EQUATION.  DGSLSQ CONTAINS
C  COEFFICIENTS FOR THE (SLOPE)**2 TERM IN THE DIAMETER GROWTH
C  MODELS ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGCASP/
     &  0.12915,      0.0, -0.15167, -0.16504,    0.1794,       0.0,
     & -0.37870, -0.11989, -0.44759, -0.02280, -0.609774, -0.609774,
     &      0.0,-0.023186,      0.0, 0.085958,  -0.02280,  0.085958/
C
      DATA DGSASP/
     & -0.19278,      0.0, -0.11862, -0.19627,    0.1336,       0.0,
     &  0.09760,  0.35781, -0.27729, -0.12480, -0.017520, -0.017520,
     &      0.0, 0.679903,      0.0, -0.86398,  -0.12480,  -0.86398/
C
      DATA DGSLOP/
     &  0.77922,      0.0, -0.28123, -0.67496,    0.0763,       0.0,
     &  0.03990,      0.0,  0.35402, -0.16402, -2.057060, -2.057060,
     &      0.0,      0.0,      0.0,      0.0,  -0.16402,       0.0/
C
      DATA DGSLSQ/
     & -0.93813,      0.0,      0.0,  0.76704,       0.0,       0.0,
     &      0.0,      0.0,      0.0,      0.0,   2.11326,  2.113263,
     &      0.0,      0.0,      0.0,      0.0,       0.0,       0.0/
C
      DATA DGEL/
     &  0.00279,      0.0,  0.00371, -0.00633,    0.0852,       0.0,
     & -0.06908,      0.0, -0.01423, -0.05796,       0.0,       0.0,
     &      0.0,      0.0,      0.0,-0.075986,  -0.05796, -0.075986/
C
      DATA DGEL2/
     & -0.00001,      0.0,      0.0,      0.0,  -0.00094,       0.0,
     &  0.00062,      0.0,      0.0,  0.00060,       0.0,       0.0,
     &      0.0,      0.0,      0.0, 0.001193,   0.00060,  0.001193/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE DGF  CYCLE =',I5)
C----------
C  DEBUG OUTPUT: MODEL COEFFICIENTS.
C----------
      IF(DEBUG) WRITE(JOSTND,*) ' IN DGF,HTCON=',HTCON
      IF(DEBUG)
     & WRITE(JOSTND,*) ' DGCON= ', DGCON
C     IF(DEBUG)
C    & WRITE(JOSTND,9000) DGCON,DGDSQ,DGLD,DGCR,DGCRSQ,DGPCCF,DGDBAL
C9000 FORMAT(/,' DGCON',/12(1X,F9.5),/7(1X,F9.5),/,' DGDSQ',/12(1X,F9.5)
C    & ,/7(1X,F9.5),/,' DGLD',/12(1X,F9.5),/7(1X,F9.5),/,' DGCR',
C    & /12(1X,F9.5),/7(1X,F9.5),/,' DGCRSQ',/12(1X,F9.5),/7(1X,F9.5),
C    & /,' DGPCCF',/12(1X,F9.5),/7(1X,F9.5),/,' DGDBAL',/12(1X,F9.5),
C    & /7(1X,F9.5))
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES
C  DEPENDENT.
C----------
      ALBA=0.0
      IF(BA.GT.0.0)ALBA=ALOG(BA)
      DO 20 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      CONSPP= DGCON(ISPC) + COR(ISPC) + 0.01*DGCCF(ISPC)*RELDEN
      SMCONS= SMCON(ISPC) + COR(ISPC)
      INDXS = SMMAPS(ISPC)
      CLD = DGLD(ISPC)
      CLBA = DGLBA(ISPC)
      CCR = DGCR(ISPC)
      CCR2 = DGCRSQ(ISPC)
      CDSQ = DGDSQ(ISPC)
      CDBAL = DGDBAL(ISPC)
      CPCCF = DGPCCF(ISPC)
      SI=SITEAR(ISPC)
      IF(DEBUG)WRITE(JOSTND,9002)ISPC,DGCON(ISPC),COR(ISPC),
     &DGCCF(ISPC),RELDEN,CONSPP,SMCON(ISPC),SMCONS,INDXS
 9002 FORMAT(' IN DGF 9002 ISPC,DGCON,COR,DGCCF,RELDEN,CONSPP,',
     &'SMCON,SMCONS,INDXS=',I5,7F10.5,I5)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES ISPC.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
      D=DIAM(I)
      IF (D.LE.0.0) GOTO 10
C
      SELECT CASE (ISPC)
C
C  ORIGINAL BM SPECIES
C
      CASE(1:5,7:10,17)
        CR=ICR(I)*0.01
        BAL = (1.0 - (PCT(I)/100.)) * BA
        IPCCF=ITRE(I)
        HOAVH=HT(I)/AVH
        IF(HOAVH .GT. 1.5)HOAVH=1.5
        IF(IPCCF .LT. 100) HOAVH=1.0
        DDSL= CONSPP + CLD*ALOG(D)
     &   + CLBA*ALBA + CR*(CCR + CR*CCR2)
     &   + CDSQ*D*D  + CDBAL*BAL/(ALOG(D+1.0))
     &   + CPCCF*PCCF(IPCCF)
C----------
C  EXTRA VARIABLES FOR INDIVIDUAL SPECIES
C----------
        IF(ISPC .EQ. 1) DDSL= DDSL+ 0.00121 * BAL
     &                     + .00001 * .01 * RMAI * RELDEN
     &                     - .0000016 * RELDEN
        IF(ISPC .EQ. 2) DDSL= DDSL- 0.000695 * BA
C----------
C  DEBUG OUTPUT: DDS FOR TREES >= 10-INCHES
C----------
        IF(DEBUG) WRITE(JOSTND,9010) ISPC, IPCCF,
     &  CONSPP, CLD, CDSQ, D, CLBA, ALBA, CCR, CCR2, CR,
     &  CDBAL, BAL, CPCCF, PCCF(IPCCF), RELDEN
 9010   FORMAT(1H0, 'DGF-9010F', 2I5, 14F8.4)

C----------
C  EQUATION FOR TREES < 10" DBH.
C----------
        DDSS=0.
        IF(D.LT.10.) THEN
          DDSS= SMCONS + SMLD(INDXS)*ALOG(D)
     &        + SMLBA(INDXS)*ALBA + CR*(SMCR(INDXS) + CR*SMCRSQ(INDXS))
     &        + SMDS(INDXS)*D*D  + SMDBAL(INDXS)*BAL/(ALOG(D+1.0))
     &        + SMPCCF(INDXS)*PCCF(IPCCF)
C----------
C  DEBUG OUTPUT: DDS FOR TREES < 10-INCHES
C----------
          IF(DEBUG) WRITE(JOSTND,9020) INDXS, SMCONS,
     &    SMLD(INDXS), SMDS(INDXS), D,  SMLBA(INDXS), ALBA,
     &    SMCR(INDXS), SMCRSQ(INDXS), CR,  SMDBAL(INDXS), BAL,
     &    SMPCCF(INDXS), PCCF(IPCCF), IPCCF
 9020     FORMAT(' DGF-9020F', I5, 13F8.4, I5)

C----------
C  EQN WAS FIT TO 5 YEAR DIAMETER GROWTHS, ADJUST TO 10 YEAR ESTIMATE.
C----------
          DSQ=EXP(DDSS)
          TEMDG=(SQRT(D*D+DSQ)-D)*2.
          DSQNEW=(TEMDG+D)**2. - D*D
          IF(DSQNEW .LE. 0.) THEN
            DDSS=0.
          ELSE
            DDSS=ALOG(DSQNEW)
          ENDIF
        ENDIF
C----------
C   SPLINE L & S ESTIMATES IF D AT CYCLE START IS IN RANGE 3-10 IN.
C   TREES 3-10 IN. SIMULATED BASED ON MSS DATA IN ADDITION TO
C   ORIGINAL SIMULATION.  COMBINE ESTIMATES OVER DIAM. RANGE 3-10 IN
C   SO MSS DATA INFLUENCE PREDOMINATES FOR SMALLER TREES IN 3-10.
C   GRADUALLY INCREASE INFLUENCE OF PREVIOUS ESTIMATES AS TREE SIZE
C   APPROACHES 10 IN. WITH ONLY PREVIOUS ESTIMATES FROM LARGER TREES
C   IN FORCE FOR DIAMETERS GREATER THAN 10 IN.   DMD   11/30/95
C----------
        XWT=1.
        IF(D.GE.3)XWT=(10.-D)/7.
        IF(XWT.LT.0.)XWT=0.
        DDS=XWT*DDSS + (1.-XWT)*DDSL
C
        IF(DEBUG) WRITE(JOSTND,9025) D, XWT, DDSS, DDSL, DDS
 9025   FORMAT(' DGF-9025F--D, XWT, DDSS, DDSL, DDS:', 5F10.5)
        IF(DEBUG) WRITE(JOSTND,9030)
     &  I,ISPC,CONSPP,D,BA,CR,BAL,PCCF(IPCCF),RELDEN,HT(I),AVH,SMCONS
 9030   FORMAT(' DGF-9030F',2I5,10F11.4)
C----------
C  SPECIES FROM THE UT & TT VARIANTS
C----------
      CASE(6,11,12,15)
        BARK=BRATIO(ISPC,D,HT(I))
        IF(ISPC. EQ. 6)THEN
          DPP = D
          IF(DPP .LT. 1.0) DPP = 1.0
          BATEM = BA
          IF(BATEM .LT.  1.0) BATEM = 1.0
          DF = 0.25897 + 1.03129 * DPP - 0.0002025464 * BATEM
     &         + 0.00177 * SI
          IF((DF-DPP) .GT. 1.0) DF = DPP + 1.0
          IF(DF .LT. DPP) DF = DPP
          DIAGR = (DF - DPP) * BARK
          IF(DIAGR .LE. 0.) THEN
            DDS=-9.21
          ELSE
            DDS = ALOG( (DIAGR * (2.0 * DPP * BARK + DIAGR)) ) + CONSPP
            IF(DDS .LT. -9.21) DDS=-9.21
          ENDIF
          WK2(I)= DDS
          IF(DEBUG)WRITE(JOSTND,*)' ISPC,D,DIAGR,DPP,BA,BARK,CONSPP= '
          IF(DEBUG)WRITE(JOSTND,*)ISPC,D,DIAGR,DPP,BA,BARK,CONSPP
        ELSEIF(ISPC .EQ. 15)THEN
          CR = ICR(I)
          CALL DGFASP(D,ASPDG,CR,BARK,SI,DEBUG)
          DDS = ASPDG + ALOG(COR2(ISPC)) + COR(ISPC)
          WK2(I) = DDS
          IF(DEBUG)WRITE(JOSTND,*)' D,ASPDG,CR,BARK,SI= ',D,ASPDG,CR,
     &     BARK,SI
          IF(DEBUG)WRITE(JOSTND,*)' COR2, COR= ',COR2(ISPC),COR(ISPC)
        ELSE
          CR = ICR(I) * 0.01
          BAL = (1.0 - (PCT(I)/100.)) * BA/100.
          DDS=CONSPP + DGLD(ISPC)*ALOG(D) + DGBAL(ISPC)*BAL +
     &       DGCR(ISPC)*CR + CR*CR*DGCRSQ(ISPC) + DGDSQ(ISPC)*D*D +
     &       DGPCCF(ISPC)*PCCF(ITRE(I))
          WK2(I)=DDS
        ENDIF
C----------
C  SPECIES FROM THE WC VARIANT
C----------
      CASE(13,14,16,18)
        CR=ICR(I)*0.01
        BAL = (1.0 - (PCT(I)/100.)) * BA
        IPCCF=ITRE(I)
        DDS = CONSPP + DGLD(ISPC)*ALOG(D)
     &    + CR*(DGCR(ISPC) + CR*DGCRSQ(ISPC))
     &    + DGDSQ(ISPC)*D*D  + DGDBAL(ISPC)*BAL/(ALOG(D+1.0))
        DDS = DDS + DGPCCF(ISPC)*PCCF(IPCCF)
     &    + DGLBA(ISPC)*ALOG(BA)
     &    + DGBAL(ISPC)*BAL + DGBA(ISPC)*BA
        IF(DEBUG) WRITE(JOSTND,8000)
     &  I,ISPC,CONSPP,D,BA,CR,BAL,PCCF(IPCCF),RELDEN,HT(I),AVH
 8000   FORMAT(1H0,'IN DGF 8000F',2I5,9F11.4)
C
      END SELECT
C---------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C     ASSUME THAT THE 10"+ EFFECT ADEQUATELY REPRESENTS THE EFFECT
C     FOR SMALLER TREES.
C
      BREL=0.
      BBA=0.
      IF(ISPC.EQ.1)BREL=0.00001*0.01*RMAI-0.0000016
      IF(ISPC.EQ.2)BBA=-0.000695
      XPPDDS=0.
      CALL PPDGF (XPPDDS,BA,BAL,RELDEN,PCCF(IPCCF),D,CLBA,CDBAL,
     &            CPCCF,BREL,BBA)
      DDS=DDS+XPPDDS
C---------
      IF(DDS.LT.-9.21) DDS=-9.21
      WK2(I)=DDS
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)THEN
      WRITE(JOSTND,9040) I,ISPC,DDS
 9040 FORMAT(' DGF-9040F, I=',I4,',  ISPC=',I3,',  DDS=LN(DDS)=',F7.4)
      ENDIF
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,100)ICYC
  100 FORMAT(' LEAVING SUBROUTINE DGF  CYCLE =',I5)
      RETURN
C
      ENTRY DGCONS
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C  IDTYPE IS A HABITAT TYPE INDEX THAT IS COMPUTED IN **RCON**.
C  ASPECT IS STAND ASPECT.
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
C----------
C  NOTE: FOR UT SPECIES 6(WJ), 12(LM), 15(AS) AND TT 11(WB) 0.7854 IS
C        45 DEGREES IN RADIANS. THIS CORRECTION WAS
C        PROBABLY DUE TO A PROBLEM IN THE WAY ASPECT WAS RECORDED
C        IN THE DATA SET USED TO FIT THE MODEL.  GED 12-20-94.
C  PUT SITE INTO ONE OF 5 CLASSES FOR UT SPECIES 6(WJ), 11(WB) AND 15(AS)
C----------
      XSITE = SITEAR(ISISP)
      LSI=XSITE/10.
      IF(LSI.LT.2)ISIC=1
      IF(LSI.GE.5)ISIC=5
      IF(LSI.GE.3 .AND. LSI.LT.4)ISIC=3
      IF(LSI.GE.4 .AND. LSI.LT.5)ISIC=4
      IF(LSI.GE.2 .AND. LSI.LT.3)ISIC=2
C----------
C  ENTER LOOP TO LOAD SPECIES DEPENDENT VECTORS.
C----------
      DO 30 ISPC=1,MAXSP
      DGCCF(ISPC) = DGCCFA(ISPC)
C----------
C  COMPUTE CONSTANT TERM: LARGE TREES >= 10 INCHES.
C----------
      IF(ISPC.EQ.6 .OR. ISPC.EQ.11 .OR. ISPC.EQ.12 .OR. ISPC.EQ.15)THEN
        ASPTEM=ASPECT-0.7854
      ELSE
        ASPTEM=ASPECT
      ENDIF
      TSITE = SITEAR(ISPC)
      IF(ISPC.EQ.7) TSITE = -43.78 + 2.16 * TSITE
      IF(ISPC.EQ.5) TSITE = TSITE * 3.28
      TEMEL=ELEV
      IF(ISPC.EQ.16 .OR. ISPC.EQ.18)THEN
        IF(TEMEL .GT. 30.)TEMEL=30.
      ENDIF
      DGCON(ISPC) = DGSIC(ISPC)*XSITE
     &                 + DGFOR(IFOR,ISPC)
     &                 + DGEL(ISPC) * TEMEL
     &                 + DGEL2(ISPC) * TEMEL * TEMEL
     &                 +(DGSASP(ISPC) * SIN(ASPTEM)
     &                 + DGCASP(ISPC) * COS(ASPTEM)
     &                 + DGSLOP(ISPC)) * SLOPE
     &                 + DGSLSQ(ISPC) * SLOPE * SLOPE
     &                 + DGSITE(ISPC)*ALOG(TSITE)
      IF(DEBUG) WRITE(JOSTND,9050) IFOR, ISPC,    DGCON(ISPC),
     &  DGFOR(IFOR,ISPC), DGEL(ISPC), DGEL2(ISPC), TEMEL,
     &  DGSASP(ISPC), DGCASP(ISPC), ASPTEM,
     &  DGSLOP(ISPC), DGSLSQ(ISPC), SLOPE,
     &  DGSITE(ISPC), SITEAR(ISPC), TSITE
 9050 FORMAT(' DGF-9050F', 2I5, 14F8.4)
C----------
C  COMPUTE CONSTANT TERM:  LARGE TREES < 10 IN.
C----------
      SELECT CASE (ISPC)
      CASE (1:5,7:10,17)
        INDXS=SMMAPS(ISPC)
        INDXH=SMMAPH(ICL5,INDXS) + 1
        SMCON(ISPC) =      SMHAB(INDXH,INDXS)
     &                   + SMFOR(IFOR,INDXS)
     &                   + SMEL(INDXS) * ELEV
     &                   + SMEL2(INDXS) * ELEV * ELEV
     &                   +(SMSASP(INDXS) * SIN(ASPTEM)
     &                   + SMCASP(INDXS) * COS(ASPTEM)
     &                   + SMSLOP(INDXS)) * SLOPE
      CASE (6,11:16,18)
        SMCON(ISPC) = 0.0
      END SELECT
C
      SELECT CASE (ISPC)
      CASE (6)
        ATTEN(ISPC)=IBSERV(ISIC,1)
      CASE (11,12)
        ATTEN(ISPC)=IBSERV(ISIC,2)
      CASE (15)
        ATTEN(ISPC)=IBSERV(ISIC,3)
      CASE DEFAULT
        ATTEN(ISPC)=OBSERV(ISPC)
      END SELECT
C
      DGDSQ(ISPC)=DGDS(ISPC)
      IF(DEBUG) WRITE(JOSTND,9060) IFOR, ISPC, INDXS, ICL5, INDXH,
     &  SMCON(ISPC), SMHAB(INDXH,INDXS), SMFOR(IFOR,INDXS),
     &  SMEL(INDXS), SMEL2(INDXS), ELEV,
     &  SMSASP(INDXS), SMCASP(INDXS), ASPTEM,
     &  SMSLOP(INDXS), SLOPE,
     &  DGDSQ(ISPC), ATTEN(ISPC)
 9060 FORMAT(' DGF-9060F', 5I5, /' ', 12F8.4,F8.0)

C----------
C  IF READCORD OR REUSCORD WAS SPECIFIED (LDCOR2 IS TRUE) ADD
C  LN(COR2) TO THE BAI MODEL CONSTANT TERM (DGCON).  COR2 IS
C  INITIALIZED TO 1.0 IN BLKDATA.
C----------
      IF (LDCOR2.AND.COR2(ISPC).GT.0.0) THEN
        DGCON(ISPC)=DGCON(ISPC)+ALOG(COR2(ISPC))
C
      SELECT CASE (ISPC)
      CASE (1:5,7:10,17)
        SMCON(ISPC)=SMCON(ISPC)+ALOG(COR2(ISPC))
      END SELECT
C
      ENDIF
   30 CONTINUE
      RETURN
      END
