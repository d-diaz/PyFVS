      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX1,HTMAX2,
     &                  DEBUG)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **FINDAG--EM  DATE OF LAST REVISION:  01/14/11
C----------
C  THIS ROUTINE SETS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  SUCH AS TREE HEIGHT.  IN EM, AGE IS CALCULATED FOR THE ORIGINAL
C  SPECIES WB, WL, DF, LP, ES, AF, PP, AND OS, ALSO THE ADDED SPECIES
C  AS AND PB
C  CALLED FROM **CRATET
C  CALLED FROM **COMCUP
C----------
C  COMMONS
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC
      REAL H,SI100,SI50,PHTG
      REAL D1,D2,SITAGE,SITHT,AGMAX,HTMAX1,HTMAX2
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
C
      IF(DEBUG)WRITE(JOSTND,*)' ENTERING FINDAG'
      IF(DEBUG)WRITE(JOSTND,91201)SITEAR
91201 FORMAT(' SITEAR =',10(11F10.4,/' ',8X))
C----------
C  AT THIS POINT PRODUCE A SITE INDEX FOR THE SPECIES
C   SPECIES   BASE YR   REF
C     WB       100      ALEXANDER TACKLE AND DAHMS REDUCED TO .75
C     DF        50      MONSERUD
C     LP       100      ALEXANDER TACKLE AND DAHMS
C     AF       100      ALEXANDER
C     ES       100      ALEXANDER
C     PP       100      MEYER  BULL 630
C      ALL OTHERS PRODUCE A HTG OF 0.0
C
C THIS MAY REQUIRE AN EARLIER CONVERSION TO A 50 YR BASE STD INDEX
C PRODUCED FROM PFISTER HABS OF MONTANA
C THEN 50YR BASE = 1.0096 + .6279*SI100
C----------
      SI100 = 0.0
      SI50  = 0.0
      IF(ISPC .EQ. 3) THEN
        SI50 = 1.0096 + 0.6279 * SITEAR(ISISP)
        IF(ISISP .EQ. 3)SI50 = SITEAR(ISISP)
      ENDIF
      IF(ISPC .EQ. 1 .OR. (ISPC.GE.7 .AND. ISPC.LE.10)) THEN
       SI100 = SITEAR(ISISP)
        IF(ISISP .EQ. 3) SI100 = (SITEAR(ISISP) - 1.0096) / 0.6279
      ENDIF
      IF((ISPC .EQ. 2) .OR. (ISPC .EQ. 18)) SI100= SITEAR(ISPC)
C----------
C  CALL  POTHTG TO CALCULATE EFFECTIVE TREE AGE
C  THE ABIRTH ARRAY IS SET IN POTHTG
C----------
      CALL POTHTG(I,ISPC,H,SI50,SI100,PHTG,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)I,ISPC, SI100, H, DBH(I), ABIRTH(I)
91200 FORMAT(' IN FINDAG--I,ISPC, SI100, H, DBH, ABIRTH= ',2I5,4F10.2)
C
      IF(DEBUG)WRITE(JOSTND,50)ICYC
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  CYCLE =',I5)
C
      RETURN
      END
C**END OF CODE SEGMENT
