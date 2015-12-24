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
C
C  $Id$
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF DDS (CHANGE IN SQUARED
C  DIAMETER) FOR EACH TREE RECORD, AND LOADS IT INTO THE ARRAY
C  WK2.  THE SET OF TREE DIAMETERS TO BE USED IS PASSED AS THE
C  ARGUEMENT DIAM.  THIS GIVES THE PROGRAM THE FLEXIBILITY TO
C  COMPUTE THE GROWTHS NEEDED TO PROCESS THE DIFFERENT
C  CALIBRATION OPTIONS.
C  THIS ROUTINE IS CALLED
C  BY **DGDRIV** DURING CALIBRATION AND WHILE CYCLING FOR GROWTH
C  PREDICTION.  ENTRY **DGCONS** IS CALLED BY **RCON** TO LOAD SITE
C  DEPENDENT COEFFICIENTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
      INCLUDE 'GGCOM.F77'
C
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C     DIAM -- ARRAY LOADED WITH TREE DIAMETERS (PASSED AS AN
C             ARGUEMENT).
C     DGLD -- ARRAY CONTAINING COEFFICIENTS FOR THE LOG(DIAMETER)
C             TERM IN THE DDS MODEL (ONE COEFFICIENT FOR EACH
C             SPECIES).
C    DGBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE BASAL AREA IN
C             LARGER TREES TERM IN THE DDS MODEL
C             (ONE COEFFICIENT FOR EACH SPECIES).
C    DGCCF -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             COMPETITION FACTOR TERM IN THE DDS MODEL (ONE
C             COEFFICIENT FOR EACH SPECIES).
C  DGCCFC -- ARRAY CONTAINING CCF COEFFICIENT FOR GROUPS
C            BY SPECIES
C  DGCCFM -- ARRAY CONTAINING THE MAPFOR CCF SITE SPECIES COEFFICIENTS
C            (ONE FOR EACH SPECIES)
C     DGCR -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO TERM IN THE DDS MODEL (ONE COEFFICIENT FOR
C             EACH SPECIES).
C   DGCRSQ -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO SQUARED TERM IN THE DDS MODEL (ONE
C             COEFFICIENT FOR EACH SPECIES).
C----------
      DIMENSION DIAM(MAXTRE)
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,I3,IPCCF,ICLS
      REAL DIAM,YOUNG,OLD,SUMD2,SUMTRE,DGQMD,STDSDI,RELSDI,SSITE
      REAL D,BARK,BRATIO,CR,BAUTBA,SPBA,PBAL,BAL,DDS,X1,XPPDDS
C
      AGERNG= 1000.
      YOUNG= 1000.
      OLD= 0.0
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,*)' ENTERING DGF CYCLE=',ICYC
C----------
C CALL ARANGE AND BADIST
C----------
      CALL BADIST(DEBUG)
C----------
C FIND AGE DISTRIBUTION
C----------
      DO I= 1,ITRN
        IF(ABIRTH(I).LE.1.)GO TO 5
        IF(HT(I) .LE. 4.5) GO TO 5
        IF(ABIRTH(I) .LT. YOUNG) YOUNG = ABIRTH(I)
        IF(ABIRTH(I) .GT. OLD) OLD = ABIRTH(I)
    5   CONTINUE
C----------
C COMPUTE AGE RANGE.
C----------
        AGERNG = OLD - YOUNG
        AGERNG = ABS(AGERNG)
      ENDDO
C----------
C COMPUTE STAGNATION MULTIPLIER DSTAG. DSTAG INITIALIZED IN GRINIT.
C----------
      SUMD2=0.
      SUMTRE=0.
      DGQMD=0.
      IF(ITRN .EQ. 0) GO TO 1001
      DO 1000 I=1,ITRN
      SUMD2=SUMD2+DBH(I)*DBH(I)*PROB(I)
      SUMTRE=SUMTRE+PROB(I)
 1000 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' SUMD2,SUMTRE= ',SUMD2,SUMTRE
      DGQMD = SQRT(SUMD2/SUMTRE)
 1001 CONTINUE
      IF(ICYC.GT.0 .AND. BA.GT.0.0) THEN
        IF(DGQMD.GT.0.)THEN
          STDSDI=SUMTRE*(DGQMD/10.0)**1.605
        ELSE
          STDSDI=0.
        ENDIF
        RELSDI=0.
        CALL SDICAL(SDIMAX)
        IF(SDIMAX.GT.0.)RELSDI=STDSDI/SDIMAX
        IF(DEBUG)WRITE(JOSTND,*)' STDSDI,SDIMAX,RELSDI= ',
     &  STDSDI,SDIMAX,RELSDI
        IF(RELSDI .GT. 0.85) RELSDI = 0.85
        DSTAG = 1.0
        IF(RELSDI .GT. 0.7) DSTAG = 3.33333 * (1.0 - RELSDI)
        IF(DEBUG)WRITE(JOSTND,*)' STAGNATION EFFECT= ',DSTAG
        IF(DEBUG)WRITE(JOSTND,*)' STAGNATION FLAGS = ',ISTAGF
      ENDIF
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES DEPENDENT
C----------
      DO 20 ISPC=1,MAXSP
      SSITE=SITEAR(ISPC)
      I1=ISCT(ISPC,1)
      IF(I1.EQ. 0) GO TO 20
      I2=ISCT(ISPC,2)
C----------
C   PROCESS TREES WITHIN SPECIES.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
      D=DIAM(I)
      ICLS = IFIX(D + 1.0)
      IF(ICLS .GT. 41) ICLS = 41
      BARK=BRATIO(ISPC,D,HT(I))
      WK2(I) = 0.0
      IF (D .LE. 0.0) GO TO 10
      CR=ICR(I)*0.01
      BAUTBA = BAU(ICLS) / BA
      SPBA = TBA(ISPC)
      IPCCF=ITRE(I)
      PBAL=(1.0-(PCT(I)/100.))*PTBAA(IPCCF)
      BAL =(1.0-(PCT(I)/100.))*BA
C
      IF(DEBUG)WRITE(JOSTND,*)' BEFORE CALL TO GEMDG',I,IMODTY,ISPC,
     &BAUTBA,SPBA,SSITE,D,BA,BARK,CR,SLOPE,ASPECT,ELEV,PBAL,
     &PCCF(IPCCF),RELDEN,BAL
C
      CALL GEMDG(DDS,IMODTY,ISPC,BAUTBA,SPBA,SSITE,D,BA,BARK,
     &CR,SLOPE,ASPECT,ELEV,PBAL,PCCF(IPCCF),RELDEN,BAL)
C
      WK2(I) = DDS + COR(ISPC) + DGCON(ISPC)
C---------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C
      X1=0.
      XPPDDS=0.
      CALL PPDGF (XPPDDS,X1,X1,X1,X1,X1,X1)
C
      WK2(I)=WK2(I)+XPPDDS
C---------
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(.NOT.DEBUG) GO TO 10
      WRITE(JOSTND,*)' AFTER CALL TO GEMDG',I,ISPC,DDS,COR(ISPC),
     &DGCON(ISPC),WK2(I)
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      RETURN
      ENTRY DGCONS
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C  ASPECT IS STAND ASPECT.  OBSERV CONTAINS THE NUMBER OF
C  OBSERVATIONS BY HABITAT CLASS BY SPECIES FOR THE UNDERLYING
C  MODEL (THIS DATA IS ACTUALLY USED BY **DGDRIV** FOR CALIBRATION).
C----------
C  OBSERV IS THE NUMBER OF OBSERVATIONS IN THE DIAMETER GROWTH
C  MODEL BY SPECIES AND SITE CLASS.
C----------
      DO 30 ISPC=1,MAXSP
      DGCON(ISPC)= 0.
      SMCON(ISPC)= 0.
C----------
C  IF READCORD OR REUSCORD WAS SPECIFIED (LDCOR2 IS TRUE) ADD
C  LN(COR2) TO THE BAI MODEL CONSTANT TERM (DGCON).  COR2 IS
C  INITIALIZED TO 1.0 IN BLKDATA.
C----------
      IF (LDCOR2.AND.COR2(ISPC).GT.0.0) DGCON(ISPC)=DGCON(ISPC)
     &  + ALOG(COR2(ISPC))
      ATTEN(ISPC)=1000.
   30 CONTINUE
      ATTEN(4)=21277.
      ATTEN(6)=880.
      ATTEN(7)=1176.
      ATTEN(8)=900.
      ATTEN(10)=123.
      ATTEN(14)=306.
      RETURN
      END
