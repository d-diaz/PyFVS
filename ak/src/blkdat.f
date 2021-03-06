      BLOCK DATA BLKDAT
	  use keycom_mod
      use htcal_mod
      use fvsstdcm_mod
      use pden_mod
      use esparm_mod
      use rancom_mod
      use contrl_mod
      use coeffs_mod
      use econ_mod
      use plot_mod
      use screen_mod
      use escomn_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **BLKDAT--AK   DATE OF LAST REVISION:  05/08/12
C----------
C
C     SEE **MAIN** FOR DICTIONARY OF VARIABLE NAMES.
C
C----------
      INTEGER I,J
C----------
C     TYPE DECLARATIONS AND COMMON STATEMENT FOR CONTROL VARIABLES.
C----------
      DATA COR2 /MAXSP*1./, HCOR2 /MAXSP*1./,RCOR2/MAXSP*1.0/,
     &     BKRAT/MAXSP*0./
C
      DATA TREFMT /
     >'(I4,T1,I7,F6.0,I1,A3,F4.1,F3.1,2F3.0,F4.1,I1,3(I2,I2),2I1,I2,2I3,
     >2I1,F3.0)' /
C
      DATA YR / 10.0 /, IRECNT/ 0 /,ICCODE/0/
C
      DATA IREAD,ISTDAT,JOLIST,JOSTND,JOSUM,JOTREE/ 15,2,3,16,4,8 /
C----------
C   COMMON STATEMENT FOR ESCOMN VARIABLE
C----------
      DATA XMIN/0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 1.0,
     &          1.0, 1.0, 0.5/
      DATA DBHMID/1.0,3.0,5.0,7.0,9.0,12.0,16.0,20.0,24.0,28.0/,
     &  ISPSPE/ 10,11/,BNORML/3*1.0,1.046,1.093,1.139,1.186,1.232,
     &  1.278,1.325,1.371,1.418,1.464,1.510,1.557,1.603,1.649,1.696,
     &  1.742,1.789/,HHTMAX/27.0,31.0,2*25.0,26.0,24.0,28.0,
     &  2*20.0,50.0, 20.0,18.0,26.0/,
     &  IFORCD/ 1003, 1002, 1005, 701, 1004,15*0 /
     &  IFORST/  1,  2,  3,  4, 1, 15*0 /
C
C     OCURHT ZEROES OUT PROBABILITIES WHICH CANNOT OCCUR BY DEFINITION.
C     OCURHT DIMENSIONED (16,MAXSP)
C
      DATA ((OCURHT(I,J),I=1,16),J=1,MAXSP)/ 208 * 1.0 /
C
C     OCURNF ZEROES OUT PROBABILITIES ON NATIONAL FORESTS BY SPECIES.
C     OCURNF DIMENSIONED (20,MAXSP)
C
      DATA ((OCURNF(I,J),I=1,20),J=1,MAXSP)/ 260 * 1.0 /
C----------
C     COMMON STATEMENT FOR PLOT VARIABLES.
C
C     SPECIES LIST FOR ALASKA VARIANT.
C
C     1 = WHITE SPRUCE (WS)           PICEA GLAUCA
C     2 = WESTERN REDCEDAR (RC)       THUJA PLICATA
C     3 = PACIFIC SILVER FIR (SF)     ABIES AMABILIS
C     4 = MOUNTAIN HEMLOCK (MH)       TSUGA MERTENSIANA
C     5 = WESTERN HEMLOCK (WH)        TSUGA HETEROPHYLLA
C     6 = ALASKA CEDAR (YC)           CALLITROPSIS NOOTKATENSIS
C     7 = LODGEPOLE PINE (LP)         PINUS CONTORTA
C     8 = SITKA SPRUCE (SS)           PICEA SITCHENSIS
C     9 = SUBALPINE FIR (AF)          ABIES LASIOCARPA
C    10 = RED ALDER (RA)              ALNUS RUBRA
C    11 = BLACK COTTONWOOD (CW)       POPULUS TRICHOCARPA
C    12 = OTHER HARDWOODS (OH)
C    13 = OTHER SOFTWOODS (OS)
C----------
      DATA JSP /
     & 'WS ',   'RC ',   'SF ',   'MH ',   'WH ',   'YC ',   'LP ',
     & 'SS ',   'AF ',   'RA ',   'CW ',   'OH ',   'OS '/
C
      DATA FIAJSP /
     & '094',   '242',   '011',   '264',   '263',   '042',   '108',
     & '098',   '019',   '351',   '747',   '998',   '298'/
C
      DATA PLNJSP /
     & 'PIGL  ','THPL  ','ABAM  ','TSME  ','TSHE  ','CANO9 ','PICO  ',
     & 'PISI  ','ABLA  ','ALRU2 ','POBAT ','2TD   ','2TE   '/
C
      DATA JTYPE /130,170,250,260,280,290,310,320,330,420,
     &            470,510,520,530,540,550,570,610,620,640,
     &            660,670,680,690,710,720,730,830,850,999,92*0 /
C
      DATA NSP /'WS1','RC1','SF1','MH1','WH1','YC1','LP1','SS1','AF1',
     &'RA1','CW1','OH1','OS1','WS2','RC2','SF2','MH2','WH2','YC2',
     &'LP2','SS2','AF2','RA2','CW2','OH2','OS2','WS3','RC3','SF3',
     &'MH3','WH3','YC3','LP3','SS3','AF3','RA3','CW3','OH3','OS3'/
C----------
C   COMMON STATEMENT FOR COEFFS VARIABLES
C----------
C   HT1 AND HT2 CONTAIN RED ALDER AND COTTONWOOD HEIGHT DUBBING
C   COEFFICIENTS FOR TREES 5.0" DBH AND LARGER.
C
      DATA HT1/ 9*0.0, 4.875, 5.152, 2*0.0 /
      DATA HT2/ 9*0.0, -8.639, -13.576, 2*0.0 /
C
C  RESIDUAL ERROR ESTIMATES WERE MULTIPLIED BY 0.75 TO APPROXIMATE
C  CORRECTION FOR MEASUREMENT ERROR; 5/10/91--WRW.
C
      DATA SIGMAR/
     & 0.34599, 0.28119, 0.34599, 0.33275, 0.33275, 0.28778,
     & 0.28778, 0.34599, 0.34599, 0.3328 , 0.5357 , 0.28778, 0.34599/
C----------
C   COMMON STATEMENT FOR VARCOM VARIABLES
C----------
C   HTT1 AND HTT2, DIMENSIONED (MAXSP,9)
C   USED IN THE HEIGHT DUBBING FUNCTIONS.  IN THE CASE OF RED ALDER
C   AND COTTONWOOD, THESE ARE FOR TREES LESS THAN 5.0" DBH.
C
      DATA ((HTT1(I,J),I=1,MAXSP),J=1,4)/
     & 4.8945, 4.6060, 4.8945, 4.7407, 4.8933, 4.8028,
     & 4.6150, 4.8945, 4.8945, 0.0994, 0.0994, 4.8028, 4.8945,
     & 4.8945, 4.6060, 4.8945, 4.7407, 4.8933, 4.8028,
     & 4.6150, 4.8945, 4.8945, 4.9767, 4.9767, 4.8028, 4.8945,
     & 4.8945, 4.6060, 4.8945, 4.7407, 4.8933, 4.8028,
     & 4.6150, 4.8945, 4.8945, 0.0   , 0.0   , 4.8028, 4.8945,
     & 4.9727, 4.6060, 4.9727, 4.7666, 4.9013, 4.8028,
     & 4.6150, 4.9727, 4.9727, 0.0   , 0.0   , 4.8028, 4.9727/
      DATA ((HTT1(I,J),I=1,MAXSP),J=5,9)/
     & 4.9727, 4.6060, 4.9727, 4.7666, 4.9013, 4.8028,
     & 4.6150, 4.9727, 4.9727, 0.0   , 0.0   , 4.8028, 4.9727,
     & 4.9727, 4.6060, 4.9727, 4.7666, 4.9013, 4.8028,
     & 4.6150, 4.9727, 4.9727, 0.0   , 0.0   , 4.8028, 4.9727,
     & 4.8753, 4.6060, 4.8753, 4.7666, 4.8043, 4.8028,
     & 4.6150, 4.8753, 4.8753, 0.0   , 0.0   , 4.8028, 4.8753,
     & 4.8753, 4.6060, 4.8753, 4.7666, 4.8043, 4.8028,
     & 4.6150, 4.8753, 4.8753, 0.0   , 0.0   , 4.8028, 4.8753,
     & 4.8753, 4.6060, 4.8753, 4.7666, 4.8043, 4.8028,
     & 4.6150, 4.8753, 4.8753, 0.0   , 0.0   , 4.8028, 4.8753/
      DATA ((HTT2(I,J),I=1,MAXSP),J=1,4)/
     &  -6.8703,  -7.6276,  -6.8703, -12.0745,  -8.7008, -11.2306,
     & -10.4718,  -6.8703,  -6.8703,   0.0   ,   0.0   , -11.2306,
     &  -6.8703,
     &  -6.8703,  -7.6276,  -6.8703, -12.0745,  -8.7008, -11.2306,
     & -10.4718,  -6.8703,  -6.8703,   0.0   ,   0.0   , -11.2306,
     &  -6.8703,
     &  -6.8703,  -7.6276,  -6.8703, -12.0745,  -8.7008, -11.2306,
     & -10.4718,  -6.8703,  -6.8703,   0.0   ,   0.0   , -11.2306,
     &  -6.8703,
     &  -8.9697,  -7.6276,  -8.9697, -11.8502,  -8.9024, -11.2306,
     & -10.4718,  -8.9697,  -8.9697,   0.0   ,   0.0   , -11.2306,
     &  -8.9697/
      DATA ((HTT2(I,J),I=1,MAXSP),J=5,9)/
     &  -8.9697,  -7.6276,  -8.9697, -11.8502,  -8.9024, -11.2306,
     & -10.4718,  -8.9697,  -8.9697,   0.0   ,   0.0   , -11.2306,
     &  -8.9697,
     &  -8.9697,  -7.6276,  -8.9697, -11.8502,  -8.9024, -11.2306,
     & -10.4718,  -8.9697,  -8.9697,   0.0   ,   0.0   , -11.2306,
     &  -8.9697,
     & -10.4921,  -7.6276, -10.4921, -11.8502,  -9.4649, -11.2306,
     & -10.4718, -10.4921, -10.4921,   0.0   ,   0.0   , -11.2306,
     & -10.4921,
     & -10.4921,  -7.6276, -10.4921, -11.8502,  -9.4649, -11.2306,
     & -10.4718, -10.4921, -10.4921,   0.0   ,   0.0   , -11.2306,
     & -10.4921,
     & -10.4921,  -7.6276, -10.4921, -11.8502,  -9.4649, -11.2306,
     & -10.4718, -10.4921, -10.4921,   0.0   ,   0.0   , -11.2306,
     & -10.4921/
C
      DATA BB0/ 9*0.0, 59.5864, 0.6192, 2*0.0 /
C
      DATA BB1/ 9*0.0, 0.7953, -5.3394, 2*0.0 /
C
      DATA BB2/ 9*0.0, 0.00194, 240.29, 2*0.0 /
C
      DATA BB3/ 9*0.0, -0.0007403, 3368.9, 2*0.0 /
C
      DATA BB4/ 9*0.0, 0.9198, 3*0.0 /
C
      DATA BB5/ MAXSP*0. /
C
      DATA BB6/ MAXSP*0. /
C
      DATA BB7/ MAXSP*0. /
C
      DATA BB8/ MAXSP*0. /
C
      DATA BB9/ MAXSP*0. /
C
      DATA BB10/ MAXSP*0. /
C
      DATA BB11/ MAXSP*0. /
C
      DATA BB12/ MAXSP*0. /
C
      DATA BB13/ MAXSP*0. /
C
      DATA REGNBK/2.999/
C
      DATA S0/55329D0/,SS/55329./
C
      DATA LSCRN,JOSCRN/.FALSE.,6/
C
      DATA JOSUME/13/
C
      DATA KOLIST,FSTOPEN /27,.FALSE./
C
      END
