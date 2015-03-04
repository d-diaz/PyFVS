      SUBROUTINE VARMRT(TOKILL,DEBUG,SUMKIL)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **VARMRT--WS    DATE OF LAST REVISION:  05/09/12
C----------
C SUBROUTINE TO DISTRIBUTE MORTALITY ACCORDING TO PERCENTILE AND
C SPECIES TOLERANCE.
C----------
COMMONS
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'ESTREE.F77'
C
      INCLUDE 'MULTCM.F77'
C
      INCLUDE 'PDEN.F77'
C
      LOGICAL DEBUG
      INTEGER I,JPASS,J,MINSTP
      INTEGER JSPC,IG,NPASS,ISWTCH
      REAL VARADJ(MAXSP),TEMWK2(MAXTRE),EFFTR(MAXTRE)
      REAL SUMKIL,TOKILL,PEFF,XKILL,CRI
      REAL SHORT,TEMKIL,ADJUST,PASS1,TPALFT,OTEM2,TEMSUM
C----------
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C
C     1 = SUGAR PINE (SP)                   PINUS LAMBERTIANA
C     2 = DOUGLAS-FIR (DF)                  PSEUDOTSUGA MENZIESII
C     3 = WHITE FIR (WF)                    ABIES CONCOLOR
C     4 = GIANT SEQUOIA (GS)                SEQUOIADENDRON GIGANTEAUM
C     5 = INCENSE CEDAR (IC)                LIBOCEDRUS DECURRENS
C     6 = JEFFREY PINE (JP)                 PINUS JEFFREYI
C     7 = CALIFORNIA RED FIR (RF)           ABIES MAGNIFICA
C     8 = PONDEROSA PINE (PP)               PINUS PONDEROSA
C     9 = LODGEPOLE PINE (LP)               PINUS CONTORTA
C    10 = WHITEBARK PINE (WB)               PINUS ALBICAULIS
C    11 = WESTERN WHITE PINE (WP)           PINUS MONTICOLA
C    12 = SINGLELEAF PINYON (PM)            PINUS MONOPHYLLA
C    13 = PACIFIC SILVER FIR (SF)           ABIES AMABILIS
C    14 = KNOBCONE PINE (KP)                PINUS ATTENUATA
C    15 = FOXTAIL PINE (FP)                 PINUS BALFOURIANA
C    16 = COULTER PINE (CP)                 PINUS COULTERI
C    17 = LIMBER PINE (LM)                  PINUS FLEXILIS
C    18 = MONTEREY PINE (MP)                PINUS RADIATA
C    19 = GRAY PINE (GP)                    PINUS SABINIANA
C         (OR CALIFORNIA FOOTHILL PINE)
C    20 = WASHOE PINE (WE)                  PINUS WASHOENSIS
C    21 = GREAT BASIN BRISTLECONE PINE (GB) PINUS LONGAEVA
C    22 = BIGCONE DOUGLAS-FIR (BD)          PSEUDOTSUGA MACROCARPA
C    23 = REDWOOD (RW)                      SEQUOIA SEMPERVIRENS
C    24 = MOUNTAIN HEMLOCK (MH)             TSUGA MERTENSIANA
C    25 = WESTERN JUNIPER (WJ)              JUNIPERUS OCIDENTALIS
C    26 = UTAH JUNIPER (UJ)                 JUNIPERUS OSTEOSPERMA
C    27 = CALIFORNIA JUNIPER (CJ)           JUNIPERUS CALIFORNICA
C    28 = CALIFORNIA LIVE OAK (LO)          QUERCUS AGRIFOLIA
C    29 = CANYON LIVE OAK (CY)              QUERCUS CHRYSOLEPSIS
C    30 = BLUE OAK (BL)                     QUERCUS DOUGLASII
C    31 = CALIFORNIA BLACK OAK (BO)         QUERQUS KELLOGGII
C    32 = VALLEY OAK (VO)                   QUERCUS LOBATA
C         (OR CALIFORNIA WHITE OAK)
C    33 = INTERIOR LIVE OAK (IO)            QUERCUS WISLIZENI
C    34 = TANOAK (TO)                       LITHOCARPUS DENSIFLORUS
C    35 = GIANT CHINQUAPIN (GC)             CHRYSOLEPIS CHRYSOPHYLLA
C    36 = QUAKING ASPEN (AS)                POPULUS TREMULOIDES
C    37 = CALIFORNIA-LAUREL (CL)            UMBELLULARIA CALIFORNICA
C    38 = PACIFIC MADRONE (MA)              ARBUTUS MENZIESII
C    39 = PACIFIC DOGWOOD (DG)              CORNUS NUTTALLII
C    40 = BIGLEAF MAPLE (BM)                ACER MACROPHYLLUM
C    41 = CURLLEAF MOUNTAIN-MAHOGANY (MC)   CERCOCARPUS LEDIFOLIUS
C    42 = OTHER SOFTWOODS (OS)
C    43 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH)
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE),
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C----------
      DATA VARADJ/
     & 0.70, 0.65, 0.55, 0.80, 0.60, 0.85, 0.50, 0.85, 0.90, 0.90,
     & 0.70, 0.90, 0.55, 0.90, 0.90, 0.90, 0.90, 0.85, 0.90, 0.90,
     & 0.90, 0.65, 0.80, 0.70, 0.90, 0.90, 0.90, 1.00, 1.00, 1.00,
     & 1.00, 1.00, 1.00, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 1.00,
     & 1.10, 0.75, 1.00/
C----------
C ADJUST = FINAL SCALAR ADJUSTMENT NEEDED TO SCALE MORTALITY VALUES
C          TO ACHIEVE THE DESIRED MORTALITY LEVEL
C  SHORT = TPA SHORT OF REACHING THE DESIRED MORTALITY LEVEL (DUE TO
C          ALL THE TREE'S PROB BEING ATTRIBUTED TO MORTALITY BEFORE THE
C          DESIRED STAND LEVEL MORTALITY LEVEL IS REACHED)
C TOKILL = NUMBER OF TREES TO KILL THIS CYCLE
C SUMKIL = RUNNING TOTAL OF NUMBER OF TREES KILLED SO FAR
C  PASS1 = NUMBER OF TREES KILLED IN ONE PASS THROUGH THE TREELIST
C          WITH THE SPECIFIED TREE LEVEL MORTALITY EFFICIENCIES
C VARADJ = TREE SHADE TOLERANCE (1.0 = MOST INTOLERANT)
C  JPASS = VARIABLE TO TRACK THE NUMBER OF PASSES THROUGH THE LOGIC
C TPALFT = DIFFERENCE BETWEEN INITIAL TPA AND MORTALITY TPA
C----------
      IF(DEBUG)WRITE(JOSTND,20)ICYC,TOKILL
   20 FORMAT('0ENTERING VARMRT CYCLE =',I3,' DENSITY RELATED TOKILL = ',
     &F6.1)
C----------
C DETERMINE TOTAL NUMBER OF TREES TO KILL IF BACKGROUND MORTALITY
C IS STILL IN EFFECT.
C----------
      IF(TOKILL .EQ. 0.0) THEN
        DO I=1,ITRN
          TOKILL = TOKILL+WK2(I)
        ENDDO
        IF(DEBUG)WRITE(JOSTND,*)' BACKGROUND TOKILL = ',TOKILL
      ENDIF
C----------
C INITIALIZE SCALARS AND ARRAYS.
C----------
      TEMKIL=TOKILL
      JPASS=0
      PASS1=0.
      SUMKIL=0.
      DO I=1,ITRN
        WK2(I)=0.
        TEMWK2(I)=0.
        EFFTR(I)=0.
      ENDDO
C----------
C PASS THROUGH THE TREELIST AND LOAD MORTALITY EFFICIENCY VALUES FOR
C EACH TREE RECORD.
C CALCULATE HOW MANY TPA WILL BE KILLED IN ONE PASS THROUGH THE TREELIST
C WITH EFFICIENCY VALUES SET AT THIS LEVEL.
C----------
      DO I=1,ITRN
        JSPC=ISP(I)
        CRI = FLOAT(ICR(I))
        PEFF = 0.84525 - 0.01074*PCT(I) + 0.0000002*PCT(I)**3.0
        IF(PEFF .GT. 1.0) PEFF = 1.0
        IF(PEFF .LT. 0.01) PEFF = 0.01
C
        SELECT CASE (JSPC)
C----------
C  SPECIES USING EQUATIONS FROM THE CR VARIANT
C----------
        CASE(21)
          EFFTR(I) = PEFF * ((100.-CRI)/100.) * VARADJ(JSPC) * 0.01
C----------
C  ALL OTHER SPECIES
C----------
        CASE DEFAULT
          EFFTR(I) = PEFF * VARADJ(JSPC) * 0.1
C
        END SELECT
C
        PASS1 = PASS1 + PROB(I)*EFFTR(I)
      ENDDO
      IF(DEBUG)WRITE(JOSTND,30)ITRN,(EFFTR(IG),IG=1,ITRN)
   30 FORMAT(' MORTALITY EFFICIENCY VALUES, ITRN = ',I7,
     &(/10F10.5))
      IF(DEBUG)WRITE(JOSTND,*)' TREES KILLED IN ONE PASS = ',PASS1
C----------
C  CALCULATE THE APPROXIMATE NUMBER OF PASSES NEEDED TO ACHIEVE THE
C  DESIRED MORTALITY.
C----------
      NPASS = IFIX(TOKILL/PASS1)+1
      IF(DEBUG)WRITE(JOSTND,*)' APPROXIMATE NUMBER OF PASSES NEEDED = ',
     &NPASS
C----------
C  LOOP THROUGH THE TREES AND LOAD THE FIRST GUESS AT TREE RECORD
C  MORTALITY BASED ON THE MORTALITY EFFICIENCY (r) AND APPROXIMATE NUMBER
C  OF PASSES NEEDED (n). THIS IS A GEOMETRIC PROGRESSION WHERE THE RATE
C  IS THE MORTALITY EFFICIENCY (r) AND THE STARTING VALUE IS THE INITIAL
C  PROB VALUE (a). THE Nth TERM IN THE PROGRESSION IS a*r*(1-r)**(n-1)
C  AND THE SUM OF N TERMS IS -a*((1-r)**n - 1).
C  ACCUMULATE THE MORTALITY ACHIEVED WITH THIS FIRST PASS.
C----------
  100 CONTINUE
      JPASS=JPASS+1
      IF(JPASS .GT. 1)TEMKIL=SHORT
      ISWTCH=0
  105 CONTINUE
      TEMSUM=0.
      DO I=1,ITRN
        TPALFT = PROB(I)-WK2(I)
        IF(TPALFT .GT. 0.)THEN
          OTEM2 = TEMWK2(I)
          TEMWK2(I) = (-TPALFT*((1.0-EFFTR(I))**NPASS - 1.0))
          IF(DEBUG)WRITE(JOSTND,*)' I,PROB,WK2,TPALFT,EFFTR,TEMWK2,',
     &    'OTEM2= ',I,PROB(I),WK2(I),TPALFT,EFFTR(I),TEMWK2(I),OTEM2
          TEMSUM=TEMSUM+TEMWK2(I)
        ENDIF
      ENDDO
      IF(DEBUG)WRITE(JOSTND,*)' AFTER GUESS ',JPASS,' TEMSUM= ',TEMSUM,
     &'  TOKILL= ',TOKILL
C----------
C ADJUST MORTALITY VALUES TO ACHIEVE DESIRED MORTALITY.
C IF AN ENTIRE TREE RECORD PROB GETS KILLED, ADJUST PASS1 VALUE FOR
C THE NEXT PASS.
C----------
      IF(NPASS .GT. 50)THEN
        MINSTP=5
      ELSEIF(NPASS .GT. 20)THEN
        MINSTP=2
      ELSE
        MINSTP=1
      ENDIF
      ADJUST=TEMKIL/TEMSUM
      IF(ADJUST .LT. 0.8)THEN
        IF(ISWTCH .EQ. 2) GO TO 110
        IF(DEBUG)WRITE(JOSTND,*)' TEMKIL,TEMSUM,PASS1,NPASS= ',
     &  TEMKIL,TEMSUM,PASS1,NPASS
        NPASS=NPASS-MAX(MINSTP,IFIX((TEMSUM-TEMKIL)/PASS1))
        IF(DEBUG)WRITE(JOSTND,*)' ADJUST= ',ADJUST,'  IS TO SMALL,',
     &  ' MIN STEP= ',MINSTP,' NEW NPASS= ',NPASS
        ISWTCH=1
        IF(NPASS .LE. 0)GO TO 110
        GO TO 105
      ELSEIF(ADJUST .GT. 1.2)THEN
        IF(ISWTCH .EQ. 1) GO TO 110
        NPASS=NPASS+MAX(MINSTP,IFIX((TEMKIL-TEMSUM)/PASS1))
        IF(DEBUG)WRITE(JOSTND,*)' ADJUST= ',ADJUST,'  IS TO BIG,',
     &  ' MIN STEP= ',MINSTP,' NEW NPASS= ',NPASS
        ISWTCH=2
        GO TO 105
      ENDIF
  110 CONTINUE
      SHORT=0.
      IF(DEBUG)WRITE(JOSTND,*)' TEMKIL= ',TEMKIL,'  TEMSUM= ',
     &TEMSUM,'  ADJUSTMENT= ',ADJUST
      DO 150 I=1,ITRN
        TPALFT = PROB(I)-WK2(I)
        IF(TPALFT .LT. 0.00001)GO TO 150
        XKILL=TEMWK2(I)*ADJUST
        IF((PROB(I)-WK2(I)-XKILL) .LE. 0.00001) THEN
          TEMWK2(I)=PROB(I)-WK2(I)
          IF(DEBUG)WRITE(JOSTND,*)' SHORT,I,XKILL,PROB,WK2= ',
     &    SHORT,I,XKILL,PROB(I),WK2(I)
          SHORT=SHORT+(XKILL-PROB(I)+WK2(I))
          IF(DEBUG)WRITE(JOSTND,*)' SHORT= ',SHORT
          PASS1=PASS1-EFFTR(I)
          GO TO 140
        ENDIF
        TEMWK2(I)=XKILL
  140 CONTINUE
      WK2(I)=WK2(I)+TEMWK2(I)
      SUMKIL=SUMKIL+TEMWK2(I)
  150 CONTINUE
      IF(DEBUG)WRITE(JOSTND,23)ITRN,(WK2(IG),IG=1,ITRN)
   23 FORMAT(' ADJUSTED MORTALITY VALUES, ITRN = ',I7,
     &(/10F10.5))
      IF(DEBUG)WRITE(JOSTND,*)' SHORT = ',SHORT
      IF(SHORT .GT. 0.)THEN
        NPASS=IFIX(SHORT/PASS1)+1
        IF(DEBUG)WRITE(JOSTND,*)' SHORT,PASS1, ADJUSTED PASSES NEEDED',
     &  '= ',SHORT,PASS1,NPASS
        GO TO 100
      ENDIF
C
      RETURN
      END
