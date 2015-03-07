      SUBROUTINE DGF(DIAM)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use pden_mod
      use prgprm_mod
      implicit none
C----------
C  **DGF--SO    DATE OF LAST REVISION:  11/17/09
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
C
C ES DIAMETER GROWTH EQUATIONS ARE FROM BM VARIANT   6/5/89
C
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
      INCLUDE 'OUTCOM.F77'
C
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
C    DGBA  -- ARRAY CONTAINING COEFFICIENTS FOR BASAL AREA
C             TERM IN THE DDS MODEL
C             (ONE COEFFICIENT FOR EACH SPECIES).
C    DGBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE BASAL AREA IN
C             LARGER TREES TERM IN THE DDS MODEL
C             (ONE COEFFICIENT FOR EACH SPECIES).
C   DGDBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE INTERACTION
C             BETWEEN BASAL AREA IN LARGER TREES AND LN(DBH) (ONE
C             COEFFICIENT PER SPECIES).
C    DGCCF -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             COMPETITION FACTOR TERM IN THE DDS MODEL (ONE
C             COEFFICIENT FOR EACH SPECIES, LOADED IN RCON).
C  SPECIES ORDER:
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C----------
      LOGICAL DEBUG
C
      REAL DIAM(MAXTRE),DGLD(MAXSP),DGBAL(MAXSP),DGCR(MAXSP),
     &   DGCRSQ(MAXSP),DGDBAL(MAXSP),DGFOR(6,MAXSP),
     &   DGDS(4,MAXSP),DGEL(MAXSP),DGEL2(MAXSP),DGSASP(MAXSP),
     &   DGCASP(MAXSP),DGSLOP(MAXSP),DGSLSQ(MAXSP),DGSIC(MAXSP),
     &   DGMAI(MAXSP),DGMACC(MAXSP),DGPCCF(MAXSP),DGCCFA(MAXSP),
     &   SLODUM(MAXSP),DGHAH(MAXSP),DGSITE(MAXSP),
     &   DGLBA(MAXSP),DGBA(MAXSP)
      INTEGER MAPDSQ(8,MAXSP),MAPLOC(8,MAXSP)
      INTEGER IBSERV(5,MAXSP),I,J,ISPC,I1,I2,I3,IPCCF,ISIC
      REAL ALCCF,CONSPP,DGLDS,DGBALS,DGCRS,DGCRS2,DGDSQS,DGDBLS,SI,D
      REAL BARK,BRATIO,RELHT,DPP,BATEM,DF,DIAGR,DDS,CR,ASPDG,CONST
      REAL DUMMY,ALD,BAL,HOAVH,DGLCCF,DGPCF2,BREL,XPPDDS,XSITE,LSI
      REAL XSLOPE,ASPTEM,TEMEL,SASP,OBSERV(MAXSP)
      DATA DGLD/
     &  0.77889,  1.05245,  0.33160,  0.89887,  0.99324,
     &  0.72947,  0.63249,  1.32610, 1.186676,  0.53028,
     &      0.0,  0.89887,  0.91259, 0.980383,0.9042530,
     & 0.213947, 0.609098,  0.58705,0.7224620,0.8793380,
     &0.8895960,      0.0,1.0241860,      0.0,0.8895960,
     &0.8895960, 1.310111,0.8895960,0.8895960,0.8895960,
     &0.8895960,  0.33160,0.8895960/
      DATA DGCR/
     &  3.36606,  2.89738,  4.43317,  3.11044,  1.73837,
     &  1.57139,  2.35065,  1.29730, 2.763519,  3.43377,
     &      0.0,  3.11044,  2.44945, 1.709846,4.1231012,
     & 1.523464, 1.158355,  1.29360,2.1603479,1.9700520,
     &1.7325350,      0.0,0.4593870,      0.0,1.7325350,
     &1.7325350, 0.271183,1.7325350,1.7325350,1.7325350,
     &1.7325350,  4.43317,1.7325350/
      DATA DGCRSQ/
     & -1.80146, -0.95430, -2.82894, -1.13806, -0.12161,
     &  0.00000, -0.63173,  0.00000,-0.871061, -1.84300,
     &      0.0, -1.13806, -0.72173,      0.0,-2.6893401,
     &      0.0,      0.0,      0.0,-0.8341960,     0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0, -2.82894,      0.0/
      DATA DGBA/
     &  0.00000,  0.00000,  0.00000,  0.00000,  0.00000,
     &  0.00000,  0.00000,  0.00000,  0.00000,  0.00000,
     &  0.00000,  0.00000,  0.00000,  0.00000,      0.0,
     &  0.00000,  0.00000,  0.00000,      0.0,-0.0001730,
     &-0.000981,      0.0,      0.0,  0.00000,-0.0009810,
     &-0.000981,  0.00000,-0.000981,-0.000981,-0.0009810,
     &-0.000981,  0.00000,-0.000981/
      DATA DGBAL/
     &  0.00121,  0.00020,  0.00479,  0.00106, -0.00087,
     &  0.00483,  0.00169,  0.00000,      0.0,  0.00325,
     &      0.0,  0.00106,  0.00380,      0.0,      0.0,
     &-0.358634,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,  0.00479,      0.0/
      DATA DGDBAL/
     & -0.00897, -0.00437, -0.01918, -0.00707, -0.00105,
     & -0.01497, -0.00647, -0.00239,-0.003728, -0.01362,
     &      0.0, -0.00707, -0.01620,-0.000261,-0.006368,
     &      0.0,-0.004253, -0.02284,-0.004065,-0.004215,
     &-0.001265,     0.0, -0.010222,      0.0,-0.001265,
     &-0.001265,      0.0,-0.001265,-0.001265,-0.001265,
     &-0.001265, -0.01918,-0.001265/
      DATA DGMAI/
     &  0.00000,  0.00375,  0.00044,  0.00114,  0.00000,
     &  0.00246,  0.00778,  0.00000,      0.0,  0.00360,
     &      0.0,  0.00114,  0.00753,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,  0.00044,      0.0/
      DATA DGMACC/
     &  0.00001, -0.00001,  0.00001,  0.00001,  0.00001,
     &  0.00000, -0.00003,  0.00000,      0.0,  0.00000,
     &      0.0,  0.00001, -0.00002,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,  0.00001,      0.0/
      DATA DGPCCF/
     &  0.00000, -0.00060, -0.00041, -0.00027,  0.00000,
     & -0.00053,  0.00000, -0.00044,      0.0,  0.00000,
     &      0.0, -0.00027, -0.00064,-0.000643,-0.0004710,
     &      0.0,-0.000568, -0.00094,      0.0,      0.0,
     &      0.0,      0.0,-0.000757,      0.0,      0.0,
     &      0.0,-0.000473,      0.0,      0.0,      0.0,
     &      0.0, -0.00041,      0.0/
C----------
C  IBSERV IS THE NUMBER OF OBSERVATIONS IN THE DIAMETER GROWTH
C  MODEL BY SPECIES AND SITE CLASS.
C----------
      DATA  ((IBSERV(I,J),I=1,5),J=1,15)/
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000/
      DATA  ((IBSERV(I,J),I=1,5),J=16,33)/
     & 27,70,123,101,33,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 184,429,356,162,74,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000,
     & 5*1000/
C----------
C  OBSERV CONTAINS THE NUMBER OF OBSERVATIONS BY HABITAT CLASS
C  BY SPECIES FOR THE UNDERLYING MODEL (THIS DATA IS ACTUALLY
C  USED BY **DGDRIV** FOR CALIBRATION.
C----------
      DATA  OBSERV/
     &  256.0,  306.0,  697.0,  5513.0,  779.0,
     &  501.0, 3208.0, 1185.0,   2062., 7837.0,
     &   22.0, 5513.0, 1198.0,   1210.,  1467.,
     &   22.0,   591.,  100.0,   4836.,   475.,
     &  220.0,  125.,    78.0,    22.0,  220.,
     &  220.,   306.,    220.,    220., 220.,
     &  220.,  697.0,  220./
C----------
C  DGCCFA CONTAINS COEFFICIENTS FOR THE CCF TERM BY SPECIES BY
C  HABITAT CLASS.
C----------
      DATA DGCCFA/
     & -0.00016,  0.00157, -0.00138, -0.00024, -0.00027,
     &  0.00000,  0.00109,  0.00000,      0.0,  0.00000,
     &  0.00000, -0.00024,  0.00201,      0.0,      0.0,
     &-0.199592,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,  0.00000,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0, -0.00138,      0.0/
C----------
C  DGFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.
C  MAPLOC IS AN ARRAY WHICH MAPS FOREST ONTO A LOCATION CLASS.
C----------
      DATA ((MAPLOC(I,J),I=1,8),J=1,15)/
     & 1,1,1,1,1,1,1,1,
     & 1,2,3,4,4,4,4,1,
     & 1,1,2,3,4,5,4,5,
     & 1,1,2,2,3,3,3,4,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,2,2,3,4,5,4,6,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,2,2,3,3,4,3,2,
     & 1,1,1,1,1,1,1,1,
     & 1,1,2,2,3,3,3,4,
     & 1,2,2,3,4,5,4,5,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1/
      DATA ((MAPLOC(I,J),I=1,8),J=16,33)/
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,2,3,4,5,4,5,
     & 1,1,1,1,1,1,1,1/
C
      DATA ((DGFOR(I,J),I=1,6),J=1,15)/
     &-0.23185, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-1.09124,-1.04630,-.048564,-0.47130, 0.00000, 0.00000,
     & 0.83941, 0.97742, 0.67207, 1.17949, 0.83941, 0.00000,
     &-0.16674,-0.04804, 0.02336, 0.47563, 0.00000, 0.00000,
     &-0.25368, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 0.23477, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.03997,-0.17367, 0.80024, 0.40611, 0.17307, 0.35268,
     &-4.64535, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-2.073942, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 1.48355, 1.34282, 1.46037, 1.54377, 0.00000, 0.00000,
     & 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.16674,-0.04804, 0.02336, 0.47563, 0.00000, 0.00000,
     &-1.68772,-0.96240,-1.38122,-1.03440,-0.76742, 0.00000,
     &-.441408, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-1.127977, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/
      DATA ((DGFOR(I,J),I=1,6),J=16,33)/
     &1.911884, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-.605649, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 1.49419, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.147675,0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-1.3100671,0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648,0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &     0.0,0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-7.753469,0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &     0.0, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-1.958189, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     & 0.83941, 0.97742, 0.67207, 1.17949, 0.83941, 0.00000,
     &-0.107648, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/
C----------
C  DGDS CONTAINS COEFFICIENTS FOR THE DIAMETER SQUARED TERMS
C  IN THE DIAMETER INCREMENT MODELS; ARRAYED BY FOREST BY
C  SPECIES.  MAPDSQ IS AN ARRAY WHICH MAPS FOREST ONTO A DBH**2
C  COEFFICIENT.
C----------
      DATA ((MAPDSQ(I,J),I=1,8),J=1,15)/
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,2,3,2,3,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,2,1,2,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,2,3,3,3,3,3,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,2,3,2,3,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1/
      DATA ((MAPDSQ(I,J),I=1,8),J=16,33)/
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1,
     & 1,1,1,1,1,1,1,1/
C
      DATA ((DGDS(I,J),I=1,4),J=1,15)/
     & -0.000091, 0.000000,      0.0,      0.0,
     & -0.000295, 0.000000,      0.0,      0.0,
     & -0.000066, 0.000000, 0.000000, 0.000000,
     & -0.000414,-0.000239,-0.000325,      0.0,
     & -0.000252, 0.000000, 0.000000,      0.0,
     & -0.000251,-0.000133,      0.0,      0.0,
     & -0.000099, 0.000000, 0.000000, 0.000000,
     &  0.000000, 0.000000, 0.000000,      0.0,
     &-0.0004572, 0.000000,      0.0,      0.0,
     & -0.000324,-0.000356,-0.000120,      0.0,
     &       0.0,      0.0,      0.0,      0.0,
     & -0.000414,-0.000239,-0.000325,      0.0,
     & -0.000468, 0.000000,      0.0,      0.0,
     &-0.0002189, 0.000000,      0.0,      0.0,
     &-0.0003996, 0.000000,      0.0,      0.0/
      DATA ((DGDS(I,J),I=1,4),J=16,33)/
     &-0.0006538, 0.000000,      0.0,      0.0,
     &-0.0001683, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &-0.0001546, 0.000000,      0.0,      0.0,
     &-0.0001323, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &-0.0001737, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &-0.0003048, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     &       0.0, 0.000000,      0.0,      0.0,
     & -0.000066, 0.000000, 0.000000, 0.000000,
     &       0.0, 0.000000,      0.0,      0.0/
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
C  MODELS. ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGCASP/
     &  0.12915,  0.08831, -0.17389, -0.14234, -0.29385,
     & -0.04156, -0.39893,  0.38002,-0.444594, -0.05217,
     &      0.0, -0.14234, -0.65502,-0.059062,-0.3745120,
     &-0.609774,-0.156235, -0.06625,      0.0,      0.0,
     &0.0859580,      0.0,      0.0,      0.0,0.0859580,
     &0.0859580,      0.0,0.0859580,0.0859580,0.0859580,
     &0.0859580, -0.17389,0.0859580/
C
      DATA DGSASP/
     & -0.19278,  0.56358, -0.40153, -0.17130,  0.33069,
     & -0.43281, -0.25658, -0.17911, 0.139180, -0.14076,
     &      0.0, -0.17130, -0.28887,-0.128126,-0.2076590,
     &-0.017520, 0.258712,  0.05534,      0.0,      0.0,
     &-0.8639800,      0.0,     0.0,      0.0,-0.86398,
     &  -0.86398,      0.0,-0.86398, -0.86398, -0.86398,
     &  -0.86398, -0.40153,-0.86398/
C
      DATA DGSLOP/
     &  0.77922, -1.50252, -0.18923,  0.02912, -0.59628,
     & -0.90318,  0.19253, -0.81780,      0.0, -0.29407,
     &      0.0,  0.02912,  0.64936, 0.240178,0.4002230,
     &-2.057060,-0.635704,  0.11931,0.4214860,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0, -0.18923,      0.0/
C
      DATA DGSLSQ/
     & -0.93813,  1.21439, -0.49057, -0.29671,  1.07549,
     &  1.36603,  0.00000,  0.84368,      0.0,  0.16735,
     &      0.0, -0.29671, -0.37153, 0.131356,      0.0,
     &  2.11326,      0.0,      0.0,-0.6936100,     0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0, -0.49057,      0.0/
C
      DATA DGEL/
     &  0.00279,  0.00466,  0.01544,  0.00362, -0.03036,
     & -0.00637,  0.01012,  0.00000,   0.0248, -0.00331,
     &      0.0,  0.00362,  0.02956,-0.015087,-0.0690450,
     &      0.0, 0.004379, -0.00175,-0.0400670,      0.0,
     &-0.075986,      0.0,-0.012111,      0.0,-0.0759860,
     &-0.075986,   0.0049,-0.075986,-0.075986,-0.075986,
     &-0.075986,  0.01544,-0.075986/
C
      DATA DGEL2/
     & -0.00001,  0.00001, -0.00010, -0.00006,  0.00037,
     &  0.00014, -0.00020,  0.00000,-0.00033429,  0.00006,
     &      0.0, -0.00006, -0.00033,      0.0, 0.0006080,
     &      0.0,      0.0,-0.000067,0.0003950,      0.0,
     &0.0011930,      0.0,      0.0,      0.0, 0.001193,
     & 0.001193,-0.00008781,0.001193,0.001193,0.001193,
     &0.001193, -0.00010,0.001193/
C
      DATA DGSIC /
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     &      0.0, 0.000000, 0.000000,      0.0,      0.0,
     & 0.001766,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0, 0.000000,      0.0, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000/
C
      DATA DGSITE /
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.492695, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.323625,0.6849390,
     &      0.0,0.351929,       0.0,0.3804160,0.2528530,
     &0.2273070,      0.0, 1.965888, 0.000000, 0.227307,
     & 0.227307, 0.213526, 0.227307, 0.227307, 0.227307,
     & 0.227307, 0.000000, 0.227307/
C
      DATA DGLBA /
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000,-0.122905, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.000000,      0.0,
     & 0.000000, 0.000000, 0.000000,      0.0,      0.0,
     &      0.0,      0.0,      0.0, 0.000000,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0, 0.000000,      0.0/
C
      DATA DGHAH /
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000,      0.0, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.000000,      0.0,
     & 0.000000, 0.000000, 0.000000,-0.0003580,     0.0,
     &      0.0,      0.0,      0.0, 0.000000,      0.0,
     &      0.0,      0.0, 0.000000,      0.0,      0.0,
     &      0.0, 0.000000,      0.0/
C----------
C DUMMY FOR SLOPE EQ 0
C----------
      DATA SLODUM /
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000,-0.174404,      0.0,
     &      0.0,-0.290174, 0.000000,      0.0,      0.0,
     &      0.0, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     & 0.000000, 0.000000, 0.000000/
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
C     & WRITE(JOSTND,9000) DGCON,DGDSQ,DGLD,DGCR,DGCRSQ,DGCCF,DGBAL
C 9000 FORMAT (/,11(1X,F10.5))
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES
C  DEPENDENT
C----------
      ALCCF=0.0
      IF(RELDEN .GT. 0.0)ALCCF=ALOG(RELDEN)
      DO 20 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      CONSPP= DGCON(ISPC) + COR(ISPC) + 0.01*DGCCF(ISPC)*RELDEN
     & +0.01*DGMACC(ISPC)*RMAI*RELDEN
      DGLDS= DGLD(ISPC)
      DGBALS=DGBAL(ISPC)
      DGCRS= DGCR(ISPC)
      DGCRS2=DGCRSQ(ISPC)
      DGDSQS=DGDSQ(ISPC)
      DGDBLS=DGDBAL(ISPC)
      SI=SITEAR(ISPC)
C
      IF(DEBUG)WRITE(JOSTND,9002)ISPC,DGCON(ISPC),COR(ISPC),
     &DGCCF(ISPC),DGMACC(ISPC),RELDEN,CONSPP
 9002 FORMAT(' IN DGF 9002 ISPC,DGCON,COR,DGCCF,DGMACC,RELDEN,CON
     &SPP=',I5,10F10.5)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES ISPC.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
      D=DIAM(I)
      WK2(I)=0.0
      IPCCF=ITRE(I)
      BARK=BRATIO(ISPC,D,HT(I))
      IF (D.LE. 0.0) GO TO 10
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
C----------
C  THE FOLLOWING IS JU(11) FROM THE UT VARIANT
C----------
      IF(ISPC.EQ.11)THEN
        DPP = D
        IF(DPP .LT. 1.0) DPP = 1.0
        BATEM = BA
        IF(BATEM .LT.  1.0) BATEM = 1.0
        DF = 0.25897 + 1.03129 * DPP - 0.0002025464 * BATEM
     &         + 0.00177 * SI
        IF((DF-DPP) .GT. 1.0) DF = DPP + 1.0
CCCC        IF(DF .GT. DBHMAX(IS)) DF = DBHMAX(IS)
        IF(DF .LT. DPP) DF = DPP
        DIAGR = (DF - DPP) * BARK
        IF(DIAGR .LE. 0.) THEN
          DDS=-9.21
        ELSE
          DDS = ALOG( (DIAGR * (2.0 * DPP * BARK + DIAGR)) ) + CONSPP
          IF(DDS .LT. -9.21) DDS=-9.21
        ENDIF
        IF(DEBUG)WRITE(JOSTND,*)' ISPC,D,DIAGR,DPP,BA,BARK,CONSPP= '
        IF(DEBUG)WRITE(JOSTND,*)ISPC,D,DIAGR,DPP,BA,BARK,CONSPP
        GO TO 9
      ELSEIF(ISPC.EQ.24)THEN
C----------
C  AS(24) IS FROM THE UT VARIANT
C----------
        CR = ICR(I)
        CALL DGFASP(D,ASPDG,CR,BARK,SI,DEBUG)
      IF(DEBUG)WRITE(JOSTND,*)' D,ASPDG,CR,BARK,SI= ',D,ASPDG,CR,BARK,SI
      IF(DEBUG)WRITE(JOSTND,*)' COR2, COR= ',COR2(ISPC),COR(ISPC)
        DDS = ASPDG + ALOG(COR2(ISPC)) + COR(ISPC)
        GO TO 9
C----------
C  RED ALDER USES A DIFFERENT EQUATION.
C  FUNCTION BOTTOMS OUT AT D=18. DECREASE LINERALY AFTER THAT TO
C  DG=0 AT D=28, AND LIMIT TO .1 ON LOWER END.  GED 4-15-93.
C----------
      ELSEIF(ISPC .EQ. 22) THEN
        BARK=BRATIO(22,D,HT(I))
        CONST=3.250531 - 0.003029*BA
        IF(D .LE. 18.) THEN
          DIAGR = CONST - 0.166496*D + 0.004618*D*D
        ELSE
          DIAGR = CONST - (CONST/10.)*(D-18.)
        ENDIF
        IF(DIAGR .LT. 0.1) DIAGR=0.1
        DDS = ALOG(DIAGR*(2.0*D*BARK+DIAGR))+ALOG(COR2(ISPC))+COR(ISPC)
        IF(DEBUG)WRITE(JOSTND,*)' RA-BARK,D,BA,DIAGR,COR2,COR,DDS= '
        IF(DEBUG)WRITE(JOSTND,*)BARK,D,BA,DIAGR,COR2(ISPC),COR(ISPC),DDS
C
        GO TO 9
      ENDIF
C----------
C  SF(14) FROM EC NEEDS ADDITIONAL VARIABLE (DUMMY)
C----------
      IF (ISPC.EQ.14)THEN
        DUMMY=-0.799079
      ELSE
        DUMMY=0.
      ENDIF
C----------
C  SORNEC11 CODE FOLLOWS
C----------
      ALD=ALOG(D)
      CR=ICR(I)*0.01
      BAL = (1.0 - (PCT(I)/100.)) * BA
      IF(DEBUG)WRITE(JOSTND,*)' BAL,BA,PCT(I)= ',BAL,BA,PCT(I)
C----------
C  SPECIES 16 TT(1) AND 11 UT(12) USE SCALED BAL
C----------
      IF(ISPC.EQ.11.OR.ISPC.EQ.16)BAL=BAL/100.
C
      HOAVH=HT(I)/AVH
      IF(HOAVH .GT. 1.5)HOAVH=1.5
      DGLCCF=0.0
      DGPCF2=0.0
      IF(ISPC .EQ. 10)THEN
        DGLCCF = (-0.20488)
        DGPCF2 = .000001
        IF(PCCF(IPCCF) .GT. 400) DGPCF2=0.0
      ENDIF
      DDS=CONSPP +DGLDS*ALD + DGBALS*BAL + CR*(DGCRS+CR*DGCRS2)
     &           +DGDSQS*D*D  + DGDBLS*BAL/(ALOG(D+1.0))
     &           +DGPCCF(ISPC)*PCCF(IPCCF)
     &           +DGLCCF * ALCCF + DGPCF2 * (PCCF(IPCCF)**2)
     &           +DGHAH(ISPC)*RELHT
     &           +DGLBA(ISPC)*ALOG(BA)
     &           +DGBA(ISPC)*BA + DUMMY
      IF(ISPC.EQ.8)DDS=DDS+0.49649*HOAVH
C
C      IF(DEBUG)THEN
C      WRITE(JOSTND,*)' DGLDS*ALD= ',DGLDS*ALD
C      WRITE(JOSTND,*)' DGBALS*BAL= ', DGBALS*BAL
C      WRITE(JOSTND,*)' CR*DGCRS+= ',CR*DGCRS
C      WRITE(JOSTND,*)' CR*CR*DGCRS2= ',CR*CR*DGCRS2
C      WRITE(JOSTND,*)' DGDSQS*D*D= ',DGDSQS*D*D
C      WRITE(JOSTND,*)' DGDBLS*BAL/(ALOG(D)= ',DGDBLS*BAL/(ALOG(D+1.0))
C      WRITE(JOSTND,*)' DGPCCF(ISPC)*PCCF(I= ',DGPCCF(ISPC)*PCCF(IPCCF)
C      WRITE(JOSTND,*)' IPCCF,PCCF(IPCCF) ',IPCCF,PCCF(IPCCF)
C      WRITE(JOSTND,*)' DGLCCF * ALCCF= ',DGLCCF * ALCCF
C      WRITE(JOSTND,*)' DGPCF2 * (PCCF**2)= ',DGPCF2 * (PCCF(IPCCF)**2)
C      WRITE(JOSTND,*)' DGHAH(ISPC)*RELHT= ',DGHAH(ISPC)*RELHT
C      WRITE(JOSTND,*)' DGLBA(ISPC)*ALOG(BA)= ',DGLBA(ISPC)*ALOG(BA)
C      WRITE(JOSTND,*)' DGBA(ISPC)*BA + DUMMY= ',DGBA(ISPC)*BA + DUMMY
C      WRITE(JOSTND,*)' DDS= ', DDS
C      ENDIF
   9  CONTINUE

      IF(DEBUG)WRITE(JOSTND,*)' DGCON,COR,DGCCF,RELDEN,DGMACC,RMAI,',
     &'CONSPP,DGLDS,ALD,DGBALS,BAL,CR,DGCRS,DGCRS2,DGDSQS,D,DGDBLS,',
     &'DGPCCF,PCCF,DDS,DGLCCF,ALCCF,DGPCF2'
      IF(DEBUG) WRITE(JOSTND,8000) DGCON(ISPC),COR(ISPC),
     $ DGCCF(ISPC),RELDEN,DGMACC(ISPC),RMAI,CONSPP,DGLDS,ALD,
     $       DGBALS,BAL,CR,DGCRS,DGCRS2,DGDSQS,D,DGDBLS,
     $       DGPCCF(ISPC),PCCF(IPCCF),DDS,DGLCCF,ALCCF,DGPCF2
 8000 FORMAT(' IN DGF AT LINE 622',9F12.5/1X,8F12.5/
     $       1X,6F12.5/)
C----------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C----------
      BREL=0.01*(DGCCF(ISPC)+DGMACC(ISPC)*RMAI)
      XPPDDS=0.
      CALL PPDGF (XPPDDS,BAL,RELDEN,PCCF(IPCCF),D,BREL,DGBALS,DGDBLS,
     &            DGPCCF(ISPC),DGLCCF,DGPCF2)
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
     &      '       RELDEN=',F9.3,',  BA=',F9.3,', LN(DDS)=',F7.4)
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
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C  IDTYPE IS A HABITAT TYPE INDEX THAT IS COMPUTED IN **RCON**.
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
C----------
C  NOTE: FOR UT SPCIES 11(JU), 24(AS) AND TT 16(WB) 0.7854 IS 45 DEGREES
C        IN RADIANS. THIS CORRECTION WAS
C        PROBABLY DUE TO A PROBLEM IN THE WAY ASPECT WAS RECORDED
C        IN THE DATA SET USED TO FIT THE MODEL.  GED 12-20-94.
C  PUT SITE INTO ONE OF 5 CLASSES FOR UT SPCIES 11(JU) AND 24(AS)
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
      ISPHAB=1
      ISPCCF=1
      IF(DEBUG)WRITE(JOSTND,*)' IFOR= ',IFOR
      DO 30 ISPC=1,MAXSP
      ISPFOR=MAPLOC(IFOR,ISPC)
      ISPDSQ=MAPDSQ(IFOR,ISPC)
      DGCCF(ISPC)=DGCCFA(ISPC)
      XSLOPE=SLOPE
      IF(ISPC.EQ.11.OR.ISPC.EQ.16.OR.ISPC.EQ.24)THEN
        ASPTEM=ASPECT-0.7854
      ELSE
        ASPTEM=ASPECT
      ENDIF
      TEMEL=ELEV
      SELECT CASE(ISPC)
      CASE(21,25,26,28,29,30,31,33)
      IF (TEMEL.GT.30.)TEMEL=30.
      END SELECT
C----------
C  NULLIFY THE SLOPE COEF FOR JUNIPER BECAUSE OF POOR EXTRAPOLATION
C  IF(ISPC .EQ. 11)XSLOPE=0.0 USED IN SO11 FOR OTHER
C----------
       SASP=
     &                 +(DGSASP(ISPC) * SIN(ASPTEM)
     &                 + DGCASP(ISPC) * COS(ASPTEM)
     &                 + DGSLOP(ISPC)) * XSLOPE
     &                 + DGSLSQ(ISPC) * XSLOPE * XSLOPE
C
      IF((SLOPE .LE. 0.0).AND.((ISPC.EQ.14).OR.(ISPC.EQ.17)))
     &SASP=SLODUM(ISPC)                                        !FROM EC VARIANT
C
      DGCON(ISPC)=
     &                   DGFOR(ISPFOR,ISPC)
     &                 + DGEL(ISPC) * TEMEL
     &                 + DGEL2(ISPC) * TEMEL * TEMEL
     &                 + DGMAI(ISPC)*RMAI
     &                 + DGSIC(ISPC)*XSITE
     &                 + DGSITE(ISPC)*ALOG(SITEAR(ISPC))
     &                 + SASP
C
      DGDSQ(ISPC)=DGDS(ISPDSQ,ISPC)
C
C      IF(DEBUG)THEN
C      WRITE(JOSTND,*)' DGFOR(ISPFOR,ISPC)= ',       DGFOR(ISPFOR,ISPC)
C      WRITE(JOSTND,*)' DGEL(ISPC) * TEMEL= ',        DGEL(ISPC) * TEMEL
C      WRITE(JOSTND,*)' DGEL2(ISPC)*TEMEL*TEMEL= ',DGEL2(ISPC)*TEMEL*TEMEL
C      WRITE(JOSTND,*)' DGMAI(ISPC)*RMAI= ',         DGMAI(ISPC)*RMAI
C      WRITE(JOSTND,*)' DGSIC(ISPC)*XSITE= ',        DGSIC(ISPC)*XSITE
C      WRITE(JOSTND,*)' DGSITE*ALOG(SI)=',DGSITE(ISPC)*ALOG(SITEAR(ISPC))
C      WRITE(JOSTND,*)' SASP         = ',                SASP
C      WRITE(JOSTND,*)'DGSASP(ISPC) * SIN= ', DGSASP(ISPC) * SIN(ASPTEM)
C      WRITE(JOSTND,*)'DGCASP(ISPC) * COS= ', DGCASP(ISPC) * COS(ASPTEM)
C      WRITE(JOSTND,*)'DGSLOP(ISPC)) * XSLOPE= ',DGSLOP(ISPC) * XSLOPE
C      WRITE(JOSTND,*)'DGSLSQ*XSLOPE2= ',DGSLSQ(ISPC) * XSLOPE * XSLOPE
C      ENDIF
C
      IF(ISPC.EQ.8)
     & DGCON(ISPC)=DGCON(ISPC)+.86756*ALOG(SITEAR(ISPC))
      IF(ISPC.EQ.11.OR.ISPC.EQ.16.OR.ISPC.EQ.24)THEN
        ATTEN(ISPC)=IBSERV(ISIC,ISPC)
      ELSE
        ATTEN(ISPC)=OBSERV(ISPC)
      ENDIF
      SMCON(ISPC)=0.
C
      IF(DEBUG)WRITE(JOSTND,9030)
     & DGFOR(ISPFOR,ISPC),DGEL(ISPC),ELEV,DGEL2(ISPC),DGSASP(ISPC),
     &  ASPECT,DGCASP(ISPC),DGSLOP(ISPC),XSLOPE,DGSLSQ(ISPC),
     &  DGMAI(ISPC),RMAI,DGSITE(ISPC),ALOG(XSITE),SASP,DGCON(ISPC)
 9030 FORMAT(' IN DGF 9030',20F10.5)
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
