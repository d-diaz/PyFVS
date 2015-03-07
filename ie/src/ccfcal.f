      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  **CCFCAL--IE   DATE OF LAST REVISION:   04/01/08
C----------
C  THIS ROUTINE COMPUTES CROWN WIDTH AND CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE, REGENT, PRTRLS, SSTAGE, AND CVCW.
C
C  CROWN WIDTH EQUATIONS FOR SPECIES 1-10 ARE FROM ANALYSIS BY
C  NICK CROOKSTON USING DATA FROM RENATE BUSH. CROWN WIDTH EQUATION
C  FOR SPECIES 11 IS FROM ANALYSIS BY NICK CROOKSTON USING CVS DATA
C  FROM THE COLVILLE NF.
C----------
COMMONS
C----------
C  ARGUMENT DEFINITIONS:
C    ISPC = NUMERIC SPECIES CODE
C       D = DIAMETER AT BREAST HEIGHT
C       H = TOTAL TREE HEIGHT
C     JCR = CROWN RATIO IN PERCENT (0-100)
C       P = TREES PER ACRE
C   LTHIN = .TRUE. IF THINNING HAS JUST OCCURRED
C         = .FALSE. OTHERWISE
C    CCFT = CCF REPRESENTED BY THIS TREE
C  CRWDTH = CROWN WIDTH OF THIS TREE
C    MODE = 1 IF ONLY NEED CCF RETURNED
C           2 IF ONLY NEED CRWDTH RETURNED
C
C  DIMENSION AND DATA STATEMENTS FOR INTERNAL VARIABLES.
C
C     CCF COEFFICIENTS FOR TREES THAT ARE GREATER THAN 10.0 IN. DBH:
C      RD1 -- CONSTANT TERM IN CROWN COMPETITION FACTOR EQUATION,
C             SUBSCRIPTED BY SPECIES
C      RD2 -- COEFFICIENT FOR SUM OF DIAMETERS TERM IN CROWN
C             COMPETITION FACTOR EQUATION,SUBSCRIPTED BY SPECIES
C      RD3 -- COEFFICIENT FOR SUM OF DIAMETER SQUARED TERM IN
C             CROWN COMPETITION EQUATION, SUBSCRIPTED BY SPECIES
C
C     CCF COEFFICIENTS FOR TREES THAT ARE LESS THAN 10.0 IN. DBH:
C      RDA -- MULTIPLIER.
C      RDB -- EXPONENT.  CCF(I) = RDA*DBH**RDB
C
C  SPECIES ORDER:
C  1=WP  2=WL  3=DF  4=GF  5=WH  6=RC  7=LP  8=ES  9=AF 10=PP
C 11=MH 12=WB 13=LM 14=LL 15=PI 16=JU 17=PY 18=AS 19=CO 20=MM
C 21=PB 22=OH 23=OS
C
C  SOURCES OF CCF COEFFICIENTS:
C     1 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN WHITE PINE
C     2 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN LARCH
C     3 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: DOUGLAS-FIR
C     4 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: GRAND FIR
C     5 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN HEMLOCK
C     6 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C     7 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C     8 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: ENGELMANN SPRUCE
C     9 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: SUBALPINE FIR
C    10 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: PONDEROSA PINE
C    11 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: MOUNTAIN HEMLOCK
C    12 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN LARCH
C    13 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C    14 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: SUBALPINE FIR
C    15 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C    16 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C    17 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C    18 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C    19 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN HEMLOCK
C    20 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C    21 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C    22 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN HEMLOCK
C    23 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN HEMLOCK
C
C      WYKOFF, CROOKSTON, STAGE, 1982. USER'S GUIDE TO THE STAND
C        PROGNOSIS MODEL. GEN TECH REP INT-133. OGDEN, UT:
C        INTERMOUNTAIN FOREST AND RANGE EXP STN. 112P.
C
C  CROWN WIDTH EQUATIONS:
C      EQUATIONS ARE A REFIT OF THE MOEUR EQUATIONS USING THE COLVILLE
C      NATIONAL FOREST CVS DATA.  THE SAME EQUATIONS ARE USED FOR ALL
C      TREE SIZES.
C
C  SPECIES EXPANSION:
C      WB USES WL
C      LM, PI, JU, PY, USES LP (SAME AS UT & TT VARIANTS)
C      LL USES AF
C      AS, MM, PB, USES RC (SAME AS UT VARIANT)
C      CO, OH USES WH (SAME AS CR VARIANT)
C      OS USES MH
C----------
      LOGICAL LTHIN
      REAL CCFT,CRWDTH,C1,C2,P,D,H,BAREA,CL,W
      INTEGER MODE,JCR,ISPC
      REAL  RD1(MAXSP),RD2(MAXSP),RD3(MAXSP),RDA(MAXSP),RDB(MAXSP)
      REAL  B1(MAXSP),B2(MAXSP),B3(MAXSP),B4(MAXSP),B5(MAXSP),B6(MAXSP)
C
      DATA RD1 /.03,.02,.11,.04,.03,.03,.01925,.03,.03,.03,.03,
     &       .02,.01925,.03,3*.01925,6*.03/
      DATA RD2 /.0167,.0148,.0333,.0270,.0215,.0238,.01676,.0173,
     &  .0216,.0180,.0215,
     &  .0148,.01676,.0216,3*.01676,.0238,.0215,2*.0238,2*.0215/
      DATA RD3 /.00230,.00338,.00259,.00405,.00363,.00490,.00365,
     & .00259,.00405,.00281,.00363,
     & .00338,.00365,.00405,3*.00365,.00490,.00363,2*.00490,2*.00363/
      DATA RDA/
     & 0.009884, 0.007244, 0.017299, 0.015248, 0.011109,
     & 0.008915, 0.009187, 0.007875, 0.011402, 0.007813, 0.011109,
     & .007244,.009187,.011402,3*.009187,.008915,.011109,2*.008915,
     & 2*.011109/
      DATA RDB/
     &   1.6667,  1.8182,  1.5571,  1.7333,  1.7250,
     &   1.7800,  1.7600,  1.7360,  1.7560,  1.7680,  1.7250,
     &   1.8182,1.7600,1.7560,3*1.7600,1.7800,1.7250,2*1.7800,
     &   2*1.7250/
C
C     B1  = BIAS CORRECTION COEFFICIENT
C     B2  = CONSTANT TERM
C     B3  = LOG-NATURAL OF CROWN LENGTH COEFFICIENT
C     B4  = LOG-NATURAL OF DBH COEFFICIENT
C     B5  = LOG-NATURAL OF TOTAL TREE HEIGHT COEFFICIENT
C     B6  = LOG-NATURAL OF BASAL AREA COEFFICIENT
      DATA B1/
     &   1.04050, 1.02478, 1.01685, 1.03030, 1.02460, 1.03597,
     &   1.03992, 1.02687, 1.02886, 1.02687, 0.00000,
     &   1.02478, 1.03992, 1.02886, 3*1.03992, 1.03597, 1.02460,
     &   2*1.03597, 1.02460, 0.0/
      DATA B2/
     &   1.27990, 0.99889, 1.48372, 1.14079, 1.35223, 1.46111,
     &   1.58777, 1.28027, 1.01255, 1.49085, 0.00000,
     &   0.99889, 1.58777, 1.01255, 3*1.58777, 1.46111, 1.35223,
     &   2*1.46111, 1.35223, 0.0/
      DATA B3/
     &   0.11941, 0.19422, 0.27378, 0.20904, 0.24844, 0.26289,
     &   0.30812, 0.22490, 0.30374, 0.18620, 0.00000,
     &   0.19422, 0.30812, 0.30374, 3*0.30812, 0.26289, 0.24844,
     &   2*0.26289, 0.24844, 0.0/
      DATA B4/
     &   0.42745, 0.59423, 0.49646, 0.38787, 0.41212, 0.18779,
     &   0.64934, 0.47075, 0.37093, 0.68272, 0.00000,
     &   0.59423, 0.64934, 0.37093, 3*0.64934, 0.18779, 0.41212,
     &   2*0.18779,0.41212, 0.0/
      DATA B5/
     &   0.00000, -0.09078, -0.18669, 0.00000, -0.10436, 0.00000,
     &  -0.38964, -0.15911, -0.13731, -0.28242, 0.00000,
     &  -0.09078, -0.38964, -0.13731, -0.38964, -0.38964,
     &  -0.38964, 0.0, -0.10436, 2*0.0, -0.10436, 0.0/
      DATA B6/
     &   -0.07182,-0.02341,-0.01509, 0.00000, 0.03539, 0.00000,
     &    0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &   -0.02341, 6*0.0, 0.03539, 2*0.0, 0.03539, 0.0/
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.
      CRWDTH = 0.
C----------
C  COMPUTE CCF
C----------
      IF(MODE.EQ.1) THEN
        SELECT CASE (ISPC)
        CASE(1:12,14,23)
        IF (D.GE.10.0) THEN
          CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
        ELSE
          CCFT = RDA(ISPC) * (D**RDB(ISPC))
        ENDIF
C
        CASE(13,15,16,17,18,20,21)
        IF (D .GE. 1.0) THEN
          CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
        ELSEIF (D .GT. 0.1) THEN
          CCFT = RDA(ISPC) * (D**RDB(ISPC))
        ELSE
          CCFT = 0.001
        ENDIF
C
        CASE(19,22)
        IF (D .GE. 10.0) THEN
          CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
        ELSEIF (D .GT. 0.1) THEN
          CCFT = RDA(ISPC) * (D**RDB(ISPC))
        ELSE
          CCFT = 0.001
        ENDIF
        END SELECT
      ENDIF
      CCFT=CCFT*P
C----------
C  COMPUTE CROWN WIDTH.
C----------
      IF(JCR .LE. 0) GO TO 100
      IF(MODE.EQ.2) THEN
        CL = FLOAT(JCR)*H*.01
        BAREA = BA
        IF(LTHIN.OR.LFIRE) BAREA=OLDBA
        IF(BAREA.LE.0. .OR. CL.LE.0. .OR. H.LE.0. .OR.D.LE.0.)GOTO 100
C----------
C  FOR COLVILLE (R6) USE R6 CROWN WIDTH LOGIC
C----------
        IF(IFOR .EQ. 5) THEN
          CALL R6CRWD (ISPC,D,H,CRWDTH)
        ELSE
          SELECT CASE (ISPC)
          CASE(1:10,12:22)
          IF(BAREA.LE.1.)BAREA=1.
          CRWDTH=B1(ISPC)*EXP(B2(ISPC)+B3(ISPC)*ALOG(CL)+B4(ISPC)*
     &           ALOG(D)+B5(ISPC)*ALOG(H)+B6(ISPC)*ALOG(BAREA))
C
          CASE(11,23)
          IF (H.LE.5.) THEN
            CRWDTH=.8*H*MAX(.5,JCR*.01)
          ELSE IF (H.GE.15.) THEN
            CRWDTH=6.90396*D**0.55645*H**(-.28509)*CL**0.20430
          ELSE
            C1=.8*H*MAX(.5,JCR*.01)
            C2=6.90396*D**0.55645*H**(-0.28509)*CL**0.20430
            W =(H-5.)*.1
            CRWDTH=C1*(1.-W)+C2*W
          ENDIF
          END SELECT
C
        ENDIF
        IF(CRWDTH .GT. 99.9) CRWDTH=99.9
      ENDIF
C
  100 CONTINUE
      IF(CRWDTH .LT. 0.1)CRWDTH=0.1
      RETURN
      END
