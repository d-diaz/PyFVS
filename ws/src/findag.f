      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX1,
     &                  HTMAX2,DEBUG)
      IMPLICIT NONE
C----------
C  **FINDAG--WS  DATE OF LAST REVISION:  05/09/12
C----------
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET** AND **HTGF** 
C----------
C  COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,ICLS
      REAL D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX1,HTMAX2,BAUTBA,SITE
      REAL AGEMAX(MAXSP),HTMAX(MAXSP),AG,DIFF,HGUESS,SINDX,TOLER
      REAL TOL,AP,AGETEM,HH,RATIO,TAGE,TSITE
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
C  DATA STATEMENTS
C----------
      DATA AGEMAX/
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0., 400., 400., 
     &   0., 400.,   0., 400., 400., 400., 400.,   0., 400., 400., 
     & 210.,   0.,   0.,   0., 400., 400., 400.,   0.,   0.,   0., 
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0., 
     & 400.,   0.,   0./
C
      DATA HTMAX/
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0., 
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0., 
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0., 
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0., 
     &  20.,   0.,   0./
C----------
C  INITIALIZATIONS
C----------
      TOLER=2.0
      SINDX = SITEAR(ISPC)
      AGMAX=AGEMAX(ISPC)
      HTMAX1 = HTMAX(ISPC)
      AG = 2.0
C----------
C  FOR SPECIES FROM THE SO VARIANT: (41=MC)
C  CRATET CALLS FINDAG AT THE BEGINING OF THE SIMULATION TO
C  CALCULATE THE AGE OF INCOMING TREES.  AT THIS POINT ABIRTH(I)=0.
C  THE AGE OF INCOMING TREES HAVING H>=HTMAX1 IS CALCULATED BY
C  ASSUMING A GROWTH RATE OF 0.10FT/YEAR FOR THE INTERVAL H-HTMAX1.
C  TREES REACHING HTMAX1 DURING THE SIMULATION ARE IDENTIFIED IN HTGF.
C----------
      IF(ISPC.EQ.41 .AND. H.GE.HTMAX1) THEN
        SITAGE = AGMAX + (H - HTMAX1)/0.10
        SITHT = H
        IF(DEBUG)WRITE(JOSTND,*)' ISPC,AGMAX,H,HTMAX1= ',ISPC,
     $  AGMAX,H,HTMAX1
        GO TO 30
      ENDIF
C----------
C  SPECIES THAT DON'T REQUIRE ITERATION OR HAVE THEIR OWN ITERATION
C  21=GB FROM THE CR VARIANT VIA UT VARIANT
C----------
      IF(ISPC .EQ. 21)THEN
        ICLS = IFIX(D1+1.0)
        IF(ICLS .GT. 41) ICLS = 41
        BAUTBA = BAU(ICLS)/BA
        IF(BAUTBA.LT.0.0)BAUTBA=0.0
        SITE = SITEAR(ISPC)
C
        TOL = 2.0
        AP = 10.0
  100   CONTINUE
        AGETEM = AP
        IF(AGETEM .LT. 30.0) AGETEM=30.
        HH = (2.75780*SITE**0.83312) * ((1.0-EXP(-0.015701*AGETEM))
     &      **(22.71944*SITE**(-0.63557))) + 4.5
        RATIO = 1.0 - BAUTBA
        IF(RATIO .LT. 0.728) RATIO = 0.728
        HH = HH * RATIO
        DIFF = ABS(HH - H)
        IF(DIFF .LT. TOL) GO TO 9990
        IF(HH .GT. H) GO TO 9990
        AP = AP + 5.0
        IF(AP .GT. AGEMAX(ISPC))THEN
          TAGE  = AGEMAX(ISPC)
          GO TO 9995
        END IF
        GO TO 100
 9990   CONTINUE
        TAGE = AGETEM
        TSITE=SITE
        IF(TSITE.LT.20.)TSITE=20.
        TAGE=TAGE+4.5/(-0.22+0.0155*TSITE)
 9995 CONTINUE
C
        IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG TAGE,SITE,H,',
     &  'BAUTBA= ',TAGE,SITE,H,BAUTBA
        SITAGE = TAGE
        IF(SITAGE .LE. 0.0) SITAGE=1.0
        GO TO 30
      ENDIF
C----------
C R5 USE DUNNING/LEVITAN SITE CURVE.
C R6 USE **HTCALC** SITE CURVES.
C SPECIES DIFFERENCES ARE ARE ACCOUNTED FOR BY THE SPECIES
C SPECIFIC SITE INDEX VALUES WHICH ARE SET AFTER KEYWORD PROCESSING.
C----------
   75 CONTINUE
C
      HGUESS = 0.
      CALL HTCALC(IFOR,SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)I,IFOR,AG,HGUESS,H
91200 FORMAT(' IN GUESS AN AGE--I,IFOR,AGE,HGUESS,H ',2I5,3F10.2)
C
      DIFF=ABS(HGUESS-H)
      IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
        SITAGE = AG
        SITHT = HGUESS
        GO TO 30
      END IF
      AG = AG + 2.
C
      IF(AG .GT. AGMAX) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C
   30 CONTINUE
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  I,SITAGE,SITHT =',
     &I5,2F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT
