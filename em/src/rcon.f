      SUBROUTINE RCON
      use htcal_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  **RCON--EM   DATE OF LAST REVISION:  02/22/11
C----------
C  MOST OF THE MODELS IN THE PROGNOSIS PROGRAM CONTAIN TERMS
C  FOR VARIABLES SUCH AS HABITAT TYPE, SLOPE, ASPECT, ELEVATION,
C  AND GEOGRAPHIC LOCATION (FOREST) THAT ARE CONSTANT FOR THE
C  DURATION OF ANY STAND PROJECTION.  THIS SUBROUTINE IS CALLED
C  BY **CRATET** BEFORE MODEL CALIBRATION TO EVALUATE THE ABOVE
C  EFFECTS FOR THE SPECIFIED CONDITIONS.  THESE EFFECTS ARE THEN
C  LOADED INTO VECTORS THAT ARE SUBSCRIPTED BY SPECIES.
C----------
COMMONS
      INCLUDE 'OUTCOM.F77'
C
      LOGICAL DEBUG
      INTEGER IHCODE(122),IDTYPE,I
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
C  IHCODE IS A LIST OF THE HABITAT TYPES IN THE ORDER THAT THE
C  HABITAT DEPENDENT COEFFICIENTS ARE LOADED FOR THE DIAMETER
C  INCREMENT, MORTALITY, AND SMALL TREE GROWTH MODELS.  IDTYPE
C  IS LOADED WITH THE SUBSCRIPT OF THE HABITAT TYPE INPUT FOR
C  A PROJECTION.
C----------
      DATA IHCODE/
     &  10, 65, 70, 74, 79, 91, 92, 93, 95,100,
     & 110,120,130,140,141,161,170,171,172,180,
     & 181,182,200,210,220,221,230,250,260,261,
     & 262,280,281,282,283,290,291,292,293,310,
     & 311,312,313,315,320,321,322,323,330,331,
     & 332,340,350,360,370,371,400,410,430,440,
     & 450,460,461,470,480,591,610,620,624,625,
     & 630,632,640,641,642,650,651,653,654,655,
     & 660,661,662,663,670,674,690,691,692,700,
     & 710,720,730,731,732,733,740,750,751,770,
     & 780,790,791,792,810,820,830,832,850,860,
     & 870,900,910,920,930,940,950,999,4*0 /
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'RCON',4,ICYC)
C----------
C  DECODE THE HABITAT CLASSES FOR THE DIAMETER GROWTH MODEL.
C----------
      DO 5 IDTYPE=1,117
      IF(ICL5.EQ.IHCODE(IDTYPE)) GO TO 6
    5 CONTINUE
      IDTYPE=118
    6 CONTINUE
C----------
C  CALL SPECIAL ENTRIES WITHIN GROWTH MODELS TO LOAD SITE
C  DEPENDENT COEFFICIENTS.
C----------
      CALL DGCONS(IDTYPE)
      CALL HTCONS
      CALL REGCON
      CALL MORCON
      CALL CRCONS
C----------
C  PRINT DEBUG INFO IF REQUESTED.
C----------
      IF(.NOT.DEBUG) RETURN
      WRITE(JOSTND,9001)
      WRITE(JOSTND,9002) 'DGCON',DGCON
      WRITE(JOSTND,9002) 'ATTEN',ATTEN
      WRITE(JOSTND,9002) 'HTCON',HTCON
      WRITE(JOSTND,9002) 'RHCON',RHCON
      WRITE(JOSTND,9002) 'CRCON',CRCON
 9001 FORMAT(/,' DEBUG TABLE SHOWING VALUES OF MODEL CONSTANTS',
     &       ' BY SPECIES')
 9002 FORMAT(1X,A,4X,((T11,11F10.4)))
      WRITE(JOSTND,9003) H2COF,HDGCOF
 9003 FORMAT(/' H2COF=',F10.4,',  HDGCOF=',F10.4)
      RETURN
      END
