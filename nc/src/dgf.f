      SUBROUTINE DGF(DIAM)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use pden_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **DGF--NC    DATE OF LAST REVISION:  04/03/08
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
      INCLUDE  'CALCOM.F77'
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
C    DGCCFA -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             COMPETITION FACTOR TERM IN THE DDS MODEL (ONE
C             COEFFICIENT FOR EACH SPECIES, LOADED IN RCON).
C----------
      LOGICAL DEBUG
      REAL DIAM(MAXTRE),DGLD(11),DGCR(11),DGCRSQ(11),DGCCFA(11)
      REAL DGDBAL(11),DGFOR(6,11),DGDS(4,11),DGEL2(11)
      REAL DGSASP(11),DGCASP(11),DGSLOP(11),DGSLSQ(11),DGSLQ2(11)
      INTEGER MAPDSQ(7,11),MAPLOC(7,11)
      REAL DGSLP2(11),DGSITE(11)
      INTEGER OBSERV(11)
      REAL DGBA(11),DGHAH(11),DGPCCF(11),DGLAT2(5,11)
      REAL DGDBA2,DGBA2,DGLD2,DGDSQ2,DGCR2,ALBA,ALRD,CONSPP,DGLDS
      REAL DGCRS,DGCRS2,DGDSQS,DGDBLS,D,ALD,CRID,CR,BAL,HOAVH,PBA,PBAL
      REAL ALPBA,DDS,TDDS,X1,XPPDDS
      INTEGER ISPC,I1,I2,I3,I,IPCCF,ILAT
C----------
C COEFS FOR SPECIES 2,6,9 ARE FROM THE WESSIN VARIANT (DOLPH)
C----------
      DIMENSION DGCR2(11),DGDSQ2(11),DGLD2(11),DGBA2(11),DGDBA2(11)
C
      DATA DGLD/
     & 0.88425, 0.0    , 0.86990, 1.01718, 1.14082, 0.0    ,
     & 1.23911, 0.99531, 0.0    , 0.96865, 0.99531/
      DATA DGCR/
     & 2.83271, 0.0    , 2.96040, 3.01884, 2.82796, 0.0    ,
     &-1.20841, 2.08524, 0.0    , 1.5466 , 2.08524/
      DATA DGCRSQ/
     &-0.84141, 0.0    ,-1.08219,-1.12464,-2.14739, 0.0    ,
     & 2.31782,-0.98396, 0.0    , 0.07152,-0.98396/
      DATA DGDBAL/
     &-0.00358, 0.0    ,-0.00443,-0.00257,-0.00126, 0.0    ,
     &-0.00199,-0.00147, 0.0    ,-0.00408,-0.00147/
      DATA DGBA /
     & 0.0    , 0.0    ,-0.01744,-0.16596, 0.0    , 0.0    ,
     & 0.0    , 0.0    , 0.0    , 0.0    , 0.0    /
      DATA DGHAH /
     & 0.0    , 0.0    , 0.0    , 0.0    , 0.56348, 0.0    ,
     & 0.0    , 0.50155, 0.0    , 0.0    , 0.50155/
      DATA DGPCCF/
     & 0.0    , 0.0    , 0.0    , 0.0    , 0.0    , 0.0    ,
     & 0.0    ,-0.00018, 0.0    ,-0.00002,-0.0018/
      DATA DGLD2/
     & 1.52284, 1.26883, 1.92426, 1.53339, 1.26883, 1.41389,
     & 1.41389, 1.52284, 1.53339, 1.63568, 1.41389/
      DATA DGCR2/
     & 0.51033, 0.27986, 0.40047, 0.35739, 0.27986, 0.32660,
     & 0.32660, 0.51033, 0.35739, 0.27516, 0.32660/
      DATA DGDSQ2/
     &-0.26590,-0.35325,-0.44612,-0.47442,-0.35325,-0.48938,
     &-0.48938,-0.26590,-0.47442,-0.54162,-0.48938/
      DATA DGBA2/
     &-0.35579, 0.00000,-0.24596,-0.12359, 0.00000,-0.25287,
     &-0.25287,-0.35579,-0.12359,-0.20902,-0.25287/
      DATA DGDBA2/
     & 0.00000,-0.79922, 0.00000,-0.44256,-0.79922,-0.16000,
     &-0.16000, 0.00000,-0.44256,-0.32497,-0.16000/
C----------
C  IDTYPE IS A HABITAT TYPE INDEX THAT IS COMPUTED IN **RCON**.
C  ASPECT IS STAND ASPECT.  OBSERV CONTAINS THE NUMBER OF
C  OBSERVATIONS BY HABITAT CLASS BY SPECIES FOR THE UNDERLYING
C  MODEL (THIS DATA IS ACTUALLY USED BY **DGDRIV** FOR CALIBRATION).
C----------
      DATA  OBSERV/
     &7019.0, 138.0,7019.0,  395.0,1762.0, 125.0,  583.0,
     &6504.0,    9.0,  403.0,6504.0/
C----------
C  DGCCFA CONTAINS COEFFICIENTS FOR THE CCF TERM BY SPECIES
C----------
      DATA DGCCFA/
     &-0.06784, 0.0    , 0.0    , 0.0    , 0.0    , 0.0    ,
     & 0.0    , 0.0    , 0.0    , 0.0    , 0.0   /
C----------
C  DGFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.
C  MAPLOC IS AN ARRAY WHICH MAPS FOREST ONTO A LOCATION CLASS.
C----------
      DATA MAPLOC/
     & 1,1,1,2,3,3,2,
     & 1,1,1,1,1,1,1,
     & 1,1,1,2,3,3,2,
     & 1,1,1,2,3,3,2,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1/
      DATA DGFOR/
     &-2.00201,-2.19449,-1.84083, 0.00000, 0.00000, 0.00000,
     & 0.0    , 0.0    , 0.0    , 0.0    , 0.00000, 0.00000,
     &-2.54402,-2.41928,-2.75656, 0.0    , 0.0    , 0.00000,
     &-1.88042,-2.06853,-1.69815, 0.0    , 0.00000, 0.00000,
     &-1.69950, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 0.0    , 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-2.68349, 0.0    , 0.0    , 0.0    , 0.0    , 0.0    ,
     &-0.94563, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 0.0    , 0.0    , 0.0    , 0.0    , 0.0    , 0.00000,
     &-4.6744 , 0.0    , 0.0    , 0.0    , 0.00000, 0.00000,
     &-0.94563, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/
      DATA DGLAT2/
     &  0.1630,  0.1630,  0.1630,  0.1630,  0.1630,
     & -0.4297, -0.4297, -0.4297, -0.2777, -0.4297,
     & -0.1043, -0.1043, -0.1043, -0.1043, -0.1043,
     &  0.1434,  0.3191,  0.1434,  0.2246,  0.1434,
     & -0.4297, -0.4297, -0.4297, -0.2777, -0.4297,
     &  0.0540, -0.1232,  0.0540,  0.0540,  0.0540,
     &  0.0540, -0.1232,  0.0540,  0.0540,  0.0540,
     &  0.1630,  0.1630,  0.1630,  0.1630,  0.1630,
     &  0.1434,  0.3191,  0.1434,  0.2246,  0.1434,
     &  0.1035, -0.3955, -0.3955, -0.3955, -0.3995,
     &  0.0540, -0.1232,  0.0540,  0.0540,  0.0540/
C----------
C  DGSLOP CONTAINS THE COEFFICIENTS FOR THE
C  SLOPE TERM IN THE DIAMETER GROWTH EQUATION.  DGSLSQ CONTAINS
C  COEFFICIENTS FOR THE (SLOPE)**2 TERM IN THE DIAMETER GROWTH MODELS.
C  ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGSLP2/
     & 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 0.00000, 0.00000, 0.00000, 0.80370, 0.00000/
      DATA DGSLQ2/
     & 0.00000, 0.00000, 0.00000,-0.83400, 0.00000, 0.00000,
     & 0.00000, 0.00000,-0.83400, 0.00000, 0.00000/
      DATA DGEL2/
     & 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 0.00000, 0.00000,-0.00700, 0.00000, 0.00000/
      DATA DGSITE/
     & 0.47932, 0.01401, 0.56356, 0.47360, 0.20189, 0.01200,
     & 0.32093, 0.00659, 0.00734, 1.10842, 0.00659/
C----------
C  DGDS CONTAINS COEFFICIENTS FOR THE DIAMETER SQUARED TERMS
C  IN THE DIAMETER INCREMENT MODELS; ARRAYED BY FOREST BY
C  SPECIES.  MAPDSQ IS AN ARRAY WHICH MAPS FOREST ONTO A DBH**2
C  COEFFICIENT.
      DATA MAPDSQ/
     & 1,1,1,1,2,2,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,2,2,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1/
      DATA DGDS/
     & -0.000328,-0.000248,      0.0,      0.0,
     &  0.0     , 0.000000,      0.0,      0.0,
     & -0.000313, 0.0     , 0.000000, 0.000000,
     & -0.000356,-0.000268, 0.0     ,      0.0,
     & -0.000875, 0.000000, 0.000000,      0.0,
     &  0.0     , 0.0     ,      0.0,      0.0,
     & -0.000338, 0.000000, 0.000000, 0.000000,
     & -0.000373, 0.000000, 0.000000,      0.0,
     &  0.0     , 0.000000,      0.0,      0.0,
     & -0.000728, 0.0     , 0.0     ,      0.0,
     & -0.000373, 0.000000,      0.0,      0.0/
C----------
C  DGEL2 CONTAINS THE COEFFICIENTS FOR
C  THE ELEVATION SQUARED TERM IN THE DIAMETER GROWTH EQUATION.
C  DGSASP CONTAINS THE COEFFICIENTS FOR THE SIN(ASPECT)*SLOPE
C  TERM IN THE DIAMETER GROWTH EQUATION.  DGCASP CONTAINS THE
C  COEFFICIENTS FOR THE COS(ASPECT)*SLOPE TERM IN THE DIAMETER
C  GROWTH EQUATION.  DGSLOP CONTAINS THE COEFFICIENTS FOR THE
C  SLOPE TERM IN THE DIAMETER GROWTH EQUATION.  DGSLSQ CONTAINS
C  COEFFICIENTS FOR THE (SLOPE)**2 TERM IN THE DIAMETER GROWTH MODELS.
C  ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGCASP/
     &-0.14319, 0.0    ,-0.16836,-0.15630,-0.19174, 0.0    ,
     & 0.08632,-0.19935, 0.0    , 0.0    ,-0.19935/
      DATA DGSASP/
     &-0.02884, 0.0    ,-0.040708,-0.01560,-0.10656, 0.0    ,
     &-0.11954,-0.03587, 0.0    , 0.0    ,-0.03587/
      DATA DGSLOP/
     & 0.63500, 0.0    , 0.46468, 0.58937,-1.29627, 0.0    ,
     & 0.85815, 0.73530, 0.0    , 0.0    , 0.73530/
      DATA DGSLSQ/
     &-1.09400, 0.0    ,-0.87145,-1.05045, 0.87335, 0.0    ,
     &-1.17209,-0.99561, 0.0    , 0.0    ,-0.99561/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE DGF  CYCLE =',I5)
C----------
C  DEBUG OUTPUT: MODEL COEFFICIENTS.
C----------
      IF(DEBUG)WRITE(JOSTND,*) 'IN DGF,HTCON=',HTCON,
     *'RMAI=',RMAI,'ELEV=',ELEV,'RELDEN=',RELDEN
      IF(DEBUG)
     & WRITE(JOSTND,9000) DGCON,DGDSQ,DGLD,DGCR,DGCRSQ,DGCCFA
 9000 FORMAT(/11(1X,F10.5))
C----------
C  ASSIGN VARIABLES WHICH ARE STAND DEPENDENT.
C----------
      ALBA=0.0
      IF(BA.GT.0.0)ALBA=ALOG(BA)
      ALRD=0.0
      IF(RELDEN.GT.0.0)ALRD=ALOG(RELDEN)
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES DEPENDENT
C----------
      DO 20 ISPC=1,11
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      CONSPP= DGCON(ISPC) + COR(ISPC) + DGCCFA(ISPC)*ALRD
     &         + DGBA(ISPC)*ALBA
      DGLDS= DGLD(ISPC)
      DGCRS= DGCR(ISPC)
      DGCRS2=DGCRSQ(ISPC)
      DGDSQS=DGDSQ(ISPC)
      DGDBLS=DGDBAL(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES ISPC.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
      D=DIAM(I)
      IF (D.LE.0.0) GOTO 10
      ALD=ALOG(D)
      CRID = ((ICR(I)*ICR(I))/(ALOG(D+1.0)))/1000.0
      IF(D .LT. 2.0)CRID = 1.8
      CR=ICR(I)*0.01
      BAL = (1.0 - (PCT(I)/100.)) * BA
      HOAVH=HT(I)/AVH
      IF(HOAVH .GT. 1.5)HOAVH=1.5
      PBA=PTBAA(ITRE(I))
      PBAL=PBA*(1.0-(PCT(I)/100.))
      IF(PBAL.LE.0.0)PBAL = BAL
      IF(PBA.LE.0.0 )PBA = BA
      ALPBA=0.0
      IF(PBA .GT. 0.0)ALPBA=ALOG(PBA)
      IPCCF=ITRE(I)
      IF (DEBUG) WRITE(JOSTND,333) PBA,D,BA,PBAL
  333 FORMAT(' DGF PBA,D,BA,PBAL =',4F12.3)
C----------
C   DIFFERENT CALCULATION OF DG FOR SPECIES 2, 6 QND 9. IF NOT THESE
C   SPECIES SKIP TO CALCULATION FOR OTHER SPECIES.
C----------
      IF(ISPC .NE. 2 .AND. ISPC .NE. 6 .AND. ISPC .NE. 9) GO TO 8
C
        DDS = CONSPP + DGLD2(ISPC)*ALD + DGDSQ2(ISPC)*D*D/1000.0
     &  + DGCR2(ISPC)*CRID + DGDBA2(ISPC)*PBAL/(ALOG(D+1.0))/100.0
     &  + DGBA2(ISPC)*ALPBA
C
      IF (DEBUG) WRITE(JOSTND,334) DDS,CONSPP,ALD,ALPBA,CRID
  334 FORMAT(' DGF DDS,CONSPP,ALD,ALPBA,CRID =',5F12.3)
C----------
C CONVERT TO 5 YEAR RATE IN REAL SCALE
C----------
      IF(DDS .LT. -8.52) DDS=-8.52
      TDDS=EXP(DDS)
      DDS=ALOG(TDDS/2.0)
C
      GO TO 9
C
   8  CONTINUE
      DDS=CONSPP + DGLDS*ALD  + CR*(DGCRS+CR*DGCRS2)
     &    + DGDSQS*D*D  + DGDBLS*BAL/(ALOG(D+1.0))
     &    + DGPCCF(ISPC)*PCCF(IPCCF) + DGHAH(ISPC)*HOAVH
      IF(ISPC .EQ. 4)DDS = DDS - 0.15032
C----------
C THIS IS A SPECIES DUMMY TO ADJUST THE OTHERWISE DF COEFFICIENTS
C----------
    9 CONTINUE
C---------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C
      X1=0.
      XPPDDS=0.
      CALL PPDGF (XPPDDS,X1,X1,X1,X1,X1,X1)
C
      DDS=DDS+XPPDDS
C---------
      IF(DDS.LT.-9.21) DDS=-9.21
      WK2(I)=DDS
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)THEN
      WRITE(JOSTND,9001) I,ISPC,D,BAL,CR,RELDEN,BA,DDS
 9001 FORMAT(' IN DGF, I=',I4,',  ISPC=',I3,',  DBH=',F7.2,
     &      ',  BAL=',F7.2,',  CR=',F7.4/
     &      '       RELDEN=',F9.3,',  BA=',F9.3,',   LN(DDS)=',F7.4)
      ENDIF
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,100)ICYC
  100 FORMAT(' LEAVING SUBROUTINE DGF  CYCLE =',I5)
      RETURN
      ENTRY DGCONS
      CALL DBCHK (DEBUG,'DGCONS',6,ICYC)
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C
C  ENTER LOOP TO LOAD SPECIES DEPENDENT VECTORS.
C----------
      DO 30 ISPC=1,11
      ILAT = 5
      ISPFOR=MAPLOC(IFOR,ISPC)
      ISPDSQ=MAPDSQ(IFOR,ISPC)
C----------
C   DIFFERENT CALCULATION FOR SPECIES 2,6 AND 9. SKIP SPECIAL
C   CODE IF NOT ONE OF THESE SPECIES.
C----------
      IF(ISPC  .NE. 2 .AND. ISPC  .NE. 6 .AND. ISPC  .NE. 9) GO TO 12
C
          DGCON(ISPC) = DGLAT2(ILAT,ISPC) + DGEL2(ISPC)*ELEV
     &    + DGSLP2(ISPC)*SLOPE + DGSLQ2(ISPC)*SLOPE*SLOPE
     &    + DGSITE(ISPC)*SITEAR(ISPC)
        GO TO 29
C
   12 CONTINUE
      DGCON(ISPC) =  DGFOR(ISPFOR,ISPC)
     &             + DGEL2(ISPC) * ELEV * ELEV
     &             +(DGSASP(ISPC) * SIN(ASPECT)
     &             + DGCASP(ISPC) * COS(ASPECT)
     &             + DGSLOP(ISPC)) * SLOPE
     &             + DGSLSQ(ISPC) * SLOPE * SLOPE
     &             + DGSITE(ISPC)*ALOG(SITEAR(3))
   29 CONTINUE
      DGDSQ(ISPC)=DGDS(ISPDSQ,ISPC)
      ATTEN(ISPC)=OBSERV(ISPC)
      SMCON(ISPC)=0.
C
      IF(DEBUG)WRITE(JOSTND,9030)
     &DGFOR(ISPFOR,ISPC),ELEV,DGEL2(ISPC),DGSASP(ISPC),
     &ASPECT,DGCASP(ISPC),DGSLOP(ISPC),SLOPE,DGSLSQ(ISPC),
     &RMAI,DGCON(ISPC)
 9030 FORMAT(' IN DGF 9030',7F10.5,/,1H ,11X,7F10.5)
C----------
C  IF READCORD OR REUSCORD WAS SPECIFIED (LDCOR2 IS TRUE) ADD
C  LN(COR2) TO THE BAI MODEL CONSTANT TERM (DGCON).  COR2 IS
C  INITIALIZED TO 1.0 IN BLKDATA.
C----------
      IF (LDCOR2.AND.COR2(ISPC).GT.0.0) DGCON(ISPC)=DGCON(ISPC)
     &  + ALOG(COR2(ISPC))
   30 CONTINUE
      RETURN
      END
