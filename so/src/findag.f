      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,
     &                  HTMAX2,DEBUG)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **FINDAG--SO  DATE OF LAST REVISION:  01/12/11
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C  CALLED FROM **HTGF
C----------
C
C  COMMONS
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
C----------
C  DECLARATIONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC
      REAL AGMAX(MAXSP),HTMAX(MAXSP)
      REAL AG,DIFF,H,HGUESS,SINDX,TOLER
      REAL SITAGE,SITHT,AGMAX1,HTMAX1,HTMAX2,D1,D2
      REAL AG2,HITE1,HITE2
      REAL HTGR
C----------
C  DATA STATEMENTS
C----------
      DATA AGMAX/
     & 500., 400., 900., 450., 650., 650., 350., 400., 500., 900.,
     & 900., 350., 350., 400., 400., 400., 400., 550., 550., 350.,
     & 350., 100., 100., 100., 100.,  50., 250.,  50.,  75.,  50.,
     &  50., 400., 100./
C
      DATA HTMAX/
     & 165., 160., 180., 180., 150., 150., 130., 165., 180., 175.,
     &  80., 165., 120., 165., 165.,  85., 175., 165., 165.,  50.,
     &  50., 100., 100.,  75., 125.,  30.,  75.,  30.,  30.,  20,
     &  25., 165., 100./
C----------
C  INITIALIZATIONS
C----------
      TOLER=2.0
      SINDX = SITEAR(ISPC)
      AGMAX1 = AGMAX(ISPC)
      IF(IFOR .GT. 3) AGMAX1=400.
      HTMAX1 = HTMAX(ISPC)
      AG = 2.0
C----------
C THE FOLLOWING LINES ARE AN RJ FIX 7-28-88
C----------
      IF(ISPC.EQ.2 .OR. ISPC.EQ.10) AG=(98.38*EXP(SINDX*(-0.0422)))+1.0
      IF(AG .LT. 2.0)AG = 2.0
      IF(ISPC .EQ. 3)AG=18.0
C----------
C  CRATET CALLS FINDAG AT THE BEGINING OF THE SIMULATION TO
C  CALCULATE THE AGE OF INCOMING TREES.  AT THIS POINT ABIRTH(I)=0.
C  THE AGE OF INCOMING TREES HAVING H>=HTMAX1 IS CALCULATED BY
C  ASSUMING A GROWTH RATE OF 0.10FT/YEAR FOR THE INTERVAL H-HTMAX1.
C  TREES REACHING HTMAX1 DURING THE SIMULATION ARE IDENTIFIED IN HTGF.
C----------
      IF(H .GE. HTMAX1) THEN
        SITAGE = AGMAX1 + (H - HTMAX1)/0.10
        SITHT = H
        IF(DEBUG)WRITE(JOSTND,*)' ISPC,AGMAX1,H,HTMAX1= ',ISPC,
     $  AGMAX1,H,HTMAX1
        GO TO 30
      ENDIF
C----------
C  DEAL WITH SPECIES THAT DON'T NEED ITEATION HERE:
C
C  COMPUTE HT GROWTH AND AGE FOR ASPEN. EQN FROM WAYNE SHEPPARD RMRS.
C----------
      IF(ISPC.EQ.24)THEN
        SITAGE = (H*2.54*12.0/26.9825)**(1.0/1.1752)
        SITHT = H
        GO TO 30
C----------
C  WESTERN JUNIPER
C  WHITEBARK PINE
C----------
      ELSEIF(ISPC.EQ.11 .OR. ISPC.EQ.16) THEN
        SITAGE = 0.
        SITHT = H
        GO TO 30
      ENDIF
C
   75 CONTINUE
C
      HGUESS = 0.
      IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG, CALLING HTCALC'
      CALL HTCALC(IFOR,SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)I,IFOR,ISPC,AG,HGUESS,H
91200   FORMAT(' FINDAG I,IFOR,ISPC,AG,HGUESS,H ',3I5,3F10.2)
C
      DIFF = ABS(HGUESS-H)
      IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
        SITAGE = AG
        SITHT = HGUESS
        GO TO 30
      END IF
      AG = AG + 2.
C
      IF(AG .GT. AGMAX1) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX1
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C
   30 CONTINUE
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT,AGMAX1,HTMAX1
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  I,SITAGE,SITHT,AGMAX1,',
     &'HTMAX1 = ',I5,4F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT
