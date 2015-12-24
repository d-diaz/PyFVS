      SUBROUTINE FORMCL(ISPC,IFOR,D,FC)
      use contrl_mod
      use prgprm_mod
      implicit none
C----------
C  **FORMCL--NI     DATE OF LAST REVISION:  04/09/08
C----------
C
C THIS PROGRAM CALCULATES FORM FACTORS FOR CALCULATING CUBIC AND
C BOARD FOOT VOLUMES.
C
C----------
      REAL COLVFC(MAXSP,5),FC,D
      INTEGER IFOR,ISPC,IFCDBH
C----------
C  FOREST ORDER: (IFOR)
C  1=BITTERROOT(103)    2=IDAHO PANHANDLE(104) 3=CLEARWATER(105)
C  4=COEUR D'ALENE(106) 5=COLVILLE(621)        6=FLATHEAD(110)
C  7=KANIKSU(113)       8=KOOTENAI(114)        9=LOLO(116)
C 10=NEZPERCE(117)     11=ST JOE(118)
C
C  SPECIES ORDER: (ISPC)
C  1=WP  2=L   3=DF  4=GF  5=WH  6=C   7=LP  8=S   9=AF 10=PP 11=OT
C----------
C  COLVILLE FORM CLASS VALUES
C----------
      DATA COLVFC/
     & 78., 78., 78., 76., 76., 64., 80., 77., 78., 78., 75.,
     & 80., 78., 76., 78., 78., 65., 82., 79., 76., 80., 78.,
     & 80., 80., 75., 77., 80., 66., 82., 80., 74., 80., 79.,
     & 82., 80., 74., 76., 80., 66., 80., 80., 74., 82., 79.,
     & 80., 80., 74., 76., 82., 66., 80., 81., 74., 80., 78./
C----------
C  FOR REGION 6 FOREST, LOAD THE FORM CLASS USING TABLE VALUES.
C  IF A FORM CLASS HAS BEEN ENTERED VIA KEYWORD, USE IT INSTEAD.
C
C  REGION 1 VOLUME ROUTINES DON'T USE FORM CLASS.
C----------
      IF(IFOR.EQ.5 .AND. FRMCLS(ISPC).LE.0.) THEN
        IFCDBH = (D - 1.0) / 10.0 + 1.0
        IF(IFCDBH .LT. 1) IFCDBH=1
        IF(D.GT.40.9) IFCDBH=5
        FC = COLVFC(ISPC,IFCDBH)
      ELSE
        FC=FRMCLS(ISPC)
        IF(FC .LE. 0.) FC=80.
      ENDIF
C
      RETURN
      END
