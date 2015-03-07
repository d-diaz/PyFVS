      SUBROUTINE SITSET
      use contrl_mod
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **SITSET--EC   DATE OF LAST REVISION:  05/09/12
C----------
C THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
C SPECIES, GIVEN A SITE INDEX AND SITE SPECIES, AND LOADS THE SDIDEF
C ARRAY WITH SDI MAXIMUMS FOR SPECIES WHICH WERE NOT ASSIGNED A VALUE
C USING THE SDIMAX KEYWORD.
C----------
C
      INCLUDE 'VOLSTD.F77'
C
C----------
      LOGICAL DEBUG
      CHARACTER*4 ASPEC
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      INTEGER IFIASP, ERRFLAG
      INTEGER NSISET,NSDSET,I,JSISP,INDEX,KNTECO,NTOHI,ISEQ,NUM
      INTEGER ISFLAG,ITOHI,ISPC,K,INTFOR,IREGN,J,JJ
      REAL FORMAX,RSI,RSDI,AG,SINDX,SI
      REAL SIAGE(MAXSP),SDICON(MAXSP)
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE EC VARIANT:
C      USE 6(GF) FOR 16(WF)
C      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
C
C  FROM THE WC VARIANT:
C      USE 19(WH) FOR 11(WH)
C      USE 33(PY) FOR 13(PY)
C      USE 31(WB) FOR 14(WB)
C      USE  7(NF) FOR 15(NF)
C      USE 30(LL) FOR 17(LL)
C      USE  8(YC) FOR 18(YC)
C      USE 29(WJ) FOR 19(WJ)
C      USE 21(BM) FOR 20(BM) AND 21(VN)
C      USE 22(RA) FOR 22(RA)
C      USE 24(PB) FOR 23(PB)
C      USE 25(GC) FOR 24(GC)
C      USE 34(DG) FOR 25(DG)
C      USE 26(AS) FOR 26(AS) AND 32(OH)
C      USE 27(CW) FOR 27(CW)
C      USE 28(WO) FOR 28(WO)
C      USE 36(CH) FOR 29(PL)
C      USE 37(WI) FOR 30(WI)
C----------
C  DATA STATEMENTS
C----------
      DATA SDICON/
     & 645., 648., 766., 766., 766., 766., 674., 766., 700., 645.,
     & 900., 766., 900., 900., 900., 766., 900., 900., 900., 900.,
     & 900., 900., 900., 900., 900., 900., 900., 900., 900., 900.,
     & 766., 900./
C
      DATA FORMAX/900./
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SITSET',6,ICYC)
C----------
C  DETERMINE HOW MANY SITE VALUES AND SDI VALUES WERE SET VIA KEYWORD.
C----------
      NSISET=0
      NSDSET=0
      DO 5 I=1,MAXSP
      IF(SITEAR(I) .GT. 0.) NSISET=NSISET+1
      IF(SDIDEF(I) .GT. 0.) NSDSET=NSDSET+1
    5 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'ENTERING SITSET, SITE VALUES SET = ',
     &NSISET,'  SDI VALUES SET = ',NSDSET
C----------
C  SET SITE SPECIES AND SITE INDEX IF NOT SET BY KEYWORD.
C  ALSO SET SDI DEFAULTS
C
C     REGION 6 FOREST --- CALL **ECOCLS** WITH THE ECOCLASS CODE,
C     AND GET BACK THE DEFAULT SITE SPECIES, ALL SITE INDICIES,
C     AND DEFAULT SDI MAXIMUMS ASSOCIATED WITH THE ECOCLASS
C----------
      JSISP=0
      INDEX=0
      KNTECO=0
      NTOHI=0
   10 CALL ECOCLS (PCOM,ASPEC,RSDI,RSI,ISFLAG,NUM,INDEX,ISEQ)
      KNTECO=KNTECO+1
      IF(DEBUG)WRITE(JOSTND,*)'AFTER ECOCLS,PCOM,ASPEC,RSDI,RSI,',
     &'ISFLAG,NUM,INDEX,ISEQ = ',PCOM,ASPEC,RSDI,RSI,ISFLAG,
     &NUM,INDEX,ISEQ
C----------
C IF DEFAULT SDI IS OUT OF BOUNDS, RESET IT.
C----------
      ITOHI=0
      IF(RSDI .GT. FORMAX)THEN
        RSDI=FORMAX
        ITOHI=1
      ENDIF
C
      IF(ISEQ .EQ. 0) GO TO 25
      IF(JSISP.EQ.0 .AND. ISFLAG.EQ.1) JSISP=ISEQ
      IF(ISISP.LE.0 .AND. ISFLAG.EQ.1) ISISP=ISEQ
      IF(SITEAR(ISEQ).LE.0. .AND. NSISET.EQ.0) SITEAR(ISEQ)=RSI
      IF(SDIDEF(ISEQ) .LE. 0.) THEN
        SDIDEF(ISEQ)=RSDI
        IF(ITOHI .GT. 0) NTOHI=NTOHI+1
      ENDIF
      IF(ISISP.GT.0 .AND. ISFLAG.EQ.1) THEN
        IF(SDIDEF(ISISP) .LE. 0.) THEN
          SDIDEF(ISISP)=RSDI
          IF(ITOHI .GT. 0) NTOHI=NTOHI+1
        ENDIF
      ENDIF
   25   CONTINUE
        IF(NUM.GT.1 .AND. KNTECO.LT.NUM) THEN
          INDEX=INDEX+1
          GO TO 10
        ENDIF
C----------
C  ON THE CHANCE THAT A SITE SPECIES WAS NOT ENCOUNTERED IN **ECOCLS**
C  PROVIDE A REGION 6 GLOBAL DEFAULT.
C----------
        IF(ISISP .LE. 0) ISISP = 10
        IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP) = 70.
C----------
C TRANSLATE SITE INDEX TO A REFERENCE AGE FOR EACH SPECIES.
C----------
      CALL SICHG(ISISP,SITEAR(ISISP),SIAGE)
C----------
C IF SITEAR  HAS NOT BEEN SET WITH SITECODE KEYWORD, LOAD
C IT WITH SITE VALUES CALCULATED HERE.
C----------
      DO 30 ISPC=1,MAXSP
      IF(DEBUG)WRITE(JOSTND,*)'IN SITSET ISISP,ISPC,SITEAR =',
     &ISISP,ISPC,SITEAR(ISISP)
      IF(SITEAR(ISPC) .GT. 0.0) GO TO 30
      AG=SIAGE(ISPC)
      SINDX=SITEAR(ISISP)
C
      SELECT CASE (ISPC)
C
C----------
C LOGIC FOR SPECIES FROM THE EC VARIANT
C----------
      CASE(1:10,12,16,31)
C
        CALL HTCALC(SINDX,ISISP,AG,SI,JOSTND,DEBUG)
C----------
C CHANGE THE SITE INDEX OF MH AND OS TO METRIC
C----------
        IF((ISPC.EQ.12 .AND. ISISP.NE.12) .OR.
     &     (ISPC.EQ.31 .AND. ISISP.NE.31)) THEN
          SI=SI/3.281
          IF(SI .GT. 28.)SI=28.
        ENDIF
C
C----------
C LOGIC FOR SPECIES FROM THE WC VARIANT
C----------
      CASE(11,13:15,17:30,32)
        SI = 0.
        IF(DEBUG)WRITE(JOSTND,*)'CALLING HTCALC SINDX,ISISP,AG,SI=',
     &  SINDX,ISISP,AG,SI
        CALL HTCALC(SINDX,ISISP,AG,SI,JOSTND,DEBUG)
        IF(DEBUG)WRITE(JOSTND,*)'RETURN FROM HTCALC,SINDX,ISISP,AG,SI='
     &  ,SINDX,ISISP,AG,SI
C----------
C MISC. HARDWOODS USE CURTIS SI CURVE CREATED FOR DF. THE
C FOLLOWING EQUATIONS ARE USED TO REDUCE THEIR GROWTH UNTIL
C SI CURVES ARE FOUND FOR THESE SPECIES. 4/26/01 EES.
C----------
      IF(ISPC.EQ.13 .AND. ISISP.NE.13)SI=SI*.25
      IF(ISPC.EQ.14 .AND. ISISP.NE.14)SI=SI*.70
      IF(ISPC.EQ.19 .AND. ISISP.NE.19)SI=SI*.23
      IF(ISPC.EQ.20 .AND. ISISP.NE.20)SI=SI*.75
      IF(ISPC.EQ.21 .AND. ISISP.NE.21)SI=SI*.75
      IF(ISPC.EQ.23 .AND. ISISP.NE.23)SI=SI*1.5
      IF(ISPC.EQ.24 .AND. ISISP.NE.24)SI=SI*.70
      IF(ISPC.EQ.25 .AND. ISISP.NE.25)SI=SI*.60
      IF(ISPC.EQ.26 .AND. ISISP.NE.26)SI=SI*.75
      IF(ISPC.EQ.27 .AND. ISISP.NE.27)SI=SI*.85
      IF(ISPC.EQ.29 .AND. ISISP.NE.29)SI=SI*.50
      IF(ISPC.EQ.30 .AND. ISISP.NE.30)SI=SI*.50
      IF(ISPC.EQ.32 .AND. ISISP.NE.32)SI=SI*.75
C----------
C FOR WHITE OAK USE METHOD DERIVED BY GOULD TO GET ESTIMATE OF MAXIMUM
C HEIGHT (THINK OF AS A BASE AGE 300) FROM DF, FROM KING CURVE (BASE AGE 50).
C----------
      IF(ISPC.EQ.28 .AND. ISISP.NE.28)SI=114.2*(1-EXP(-0.0266*SI))**2.26
C
      END SELECT
C
      SITEAR(ISPC) = SI
C
   30 CONTINUE
C----------
C LOAD THE SDIDEF ARRAY
C----------
      K=ISISP
      IF(SDIDEF(K) .LE. 0.) K=JSISP
      DO 80 I=1,MAXSP
        IF(SDIDEF(I) .GT. 0.0) GO TO 80
        SELECT CASE (I)
        CASE(1:10,12,16,31)
          IF(BAMAX .GT. 0.) THEN
            SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
          ELSE
            SDIDEF(I)=SDIDEF(K) * (SDICON(I)/SDICON(K))
          ENDIF
          IF(SDIDEF(I) .GT. FORMAX)THEN
            SDIDEF(I)=FORMAX
            NTOHI=NTOHI+1
          ENDIF
        CASE(11,13:15,17:30,32)
          SDIDEF(I) = SDIDEF(K)
        END SELECT
   80 CONTINUE
      IF(BAMAX.LE.0) BAMAX=SDIDEF(K)*(PMSDIU/100.)*0.54542
C
      DO 92 I=1,15
      J=(I-1)*10 + 1
      JJ=J+9
      IF(JJ.GT.MAXSP)JJ=MAXSP
      WRITE(JOSTND,90)(NSP(K,1)(1:2),K=J,JJ)
   90 FORMAT(/'SPECIES ',5X,10(A2,6X))
      WRITE(JOSTND,91)(SDIDEF(K),K=J,JJ )
   91 FORMAT('SDI MAX ',   10F8.0)
      IF(JJ .EQ. MAXSP)GO TO 93
   92 CONTINUE
   93 CONTINUE
      IF(NTOHI .GT. 0)WRITE(JOSTND,102)FORMAX
  102 FORMAT(/'*NOTE -- AT LEAST ONE DEFAULT MAXIMUM SDI EXCEEDED THE FO
     &REST DEFAULT MAXIMUM. FOREST DEFAULT MAXIMUM OF ',F5.0,' USED.',/
     &,'          YOU MAY NEED TO SPECIFICALLY RESET VALUES FOR THESE SP
     &ECIES USING THE SDIMAX KEYWORD.')
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='EC'
C
      DO ISPC=1,MAXSP
      READ(FIAJSP(ISPC),'(I3)')IFIASP
      IF(((METHC(ISPC).EQ.6).OR.(METHC(ISPC).EQ.9)).AND.
     &     (VEQNNC(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNC(ISPC)=VOLEQ
      ENDIF
      IF(((METHB(ISPC).EQ.6).OR.(METHB(ISPC).EQ.9)).AND.
     &     (VEQNNB(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNB(ISPC)=VOLEQ
      ENDIF
      ENDDO
C----------
C  IF FIA CODES WERE IN INPUT DATA, WRITE TRANSLATION TABLE
C---------
      IF(LFIA) THEN
        CALL FIAHEAD(JOSTND)
        WRITE(JOSTND,211) (NSP(I,1)(1:2),FIAJSP(I),I=1,MAXSP)
 211    FORMAT ((T12,8(A3,'=',A6,:,'; '),A,'=',A6))
      ENDIF
C----------
C  WRITE VOLUME EQUATION NUMBER TABLE
C----------
      CALL VOLEQHEAD(JOSTND)
      WRITE(JOSTND,230)(NSP(J,1)(1:2),VEQNNC(J),VEQNNB(J),J=1,MAXSP)
 230  FORMAT(4(2X,A2,4X,A10,1X,A10,1X))
C
      RETURN
      END
