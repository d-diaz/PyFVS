      SUBROUTINE NOTRE
      use contrl_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C  THIS SUBROUTINE CALCULATES THE NUMBER OF TREES PER ACRE EACH
C  TREE RECORD REPRESENTS BASED ON THE INPUT SAMPLING DESIGN
C  FACTORS.  ON INPUT, THE TREE LIST IS SEPARATED INTO 2 GROUPS
C  DEPENDING ON WHETHER RECORDS ARE PROJECTABLE OR NOT. THE
C  FIRST IREC1 RECORDS IN THE LIST ARE PROJECTABLE. THE RECORDS
C  FROM (MAXTP1-IREC2) TO MAXTRE ARE NON-PROJECTABLE.
C----------
COMMONS
C----------
C       VP -- VARIABLE PLOT EXPANSION FACTOR.  IF BAF IS NEGATIVE,
C             VP IS SET TO ZERO, AND BAF IS ASSUMED TO BE THE
C             INVERSE OF THE AREA FOR THE FIXED PLOT ON WHICH LARGE
C             TREES WERE SAMPLED.
C       FP -- FIXED PLOT EXPANSION FACTOR FOR SMALL TREE SAMPLE.
C       FP2-- FIXED PLOT EXPANSION FACTOR FOR LARGE TREE SAMPLE, SET
C             TO ZERO WHEN BAF IS POSITIVE.
C----------
C
      REAL FP,FP2,VP,P,D
      INTEGER I1,I2,I
C
      IF ((ITRN.LE.0).AND.(IREC2.GE.MAXTP1)) RETURN
      FP = FPA/PI
      FP2=0.0
      IF(TFPA.GT.0.0) FP=1.0/TFPA
      VP = BAF*183.3465/PI
      IF(BAF.GT.0.0) GO TO 5
      VP=0.0
      FP2=-BAF/PI
    5 CONTINUE
      I1= 1
      I2= IREC1
C----------
C  FIRST, PROCESS THE PROJECTABLE TREE RECORDS.
C----------
   10 CONTINUE
      DO 40 I= I1, I2
      P=PROB(I)
      D=DBH(I)
      IF (P .LE. 0.0) P=1.0
      IF ( D .LT. BRK ) GO TO 20
      P = P*VP/(D*D) + P*FP2
      GO TO 30
   20 P = P*FP
   30 IF ( P .LE. 0.0 ) P = 9.E-25
C----------
C  ASSIGN PROB; ADJUST FOR NON-STOCKABLE POINTS.
C----------
      PROB(I)=P*GROSPC
C----------
C   CALL WESTERN ROOT DISEASE MODEL VER. 3.0 SUBROUTINE TO ASSIGN TPA
C   VALUES TO WESTERN ROOT DISEASE PROB VARIABLES
C----------
      CALL RDPRIN (I)
C----------
C   CALL TO FIRE AND FUEL EFFECTS MODEL IS DONE IN **CRATET**,
C   SINCE SNAG HEIGHT DUBBING MAY BE REQUIRED
C----------
   40 CONTINUE
      IF( I1 .NE. 1 ) GO TO 60
      IF( IREC2 .EQ. MAXTP1 ) GO TO  60
C----------
C  RETURN TO STATEMENT 10 TO PROCESS THE NON-PROJECTABLE RECORDS
C  AT THE END OF THE LIST.
C----------
      I1= IREC2
      I2= MAXTRE
C----------
C  MULTIPLY THE PROB OF MORTALITY TREES BY THE RATIO OF THE GROWTH
C  MEASUREMENT PERIOD LENGTH TO THE MORTALITY OBSERVATION PERIOD
C
C  THE INFLATION OF PROB FOR DEAD TREES IS DONE TO FACILITATE
C  CALIBRATION. DURING CALIBRATION THE RECENT DEAD TREES NEED
C  TO BE ADDED BACK INTO THE STAND TO GET THE CORRECT BACKDATED
C  DENSITY. THE CORRECT ADJUSTMENT IS THE CYCLE LENGTH DIVIDED
C  BY THE LENGTH OF THE MORTALITY OBSERVATION PERIOD. IT IS ASSUMED
C  THAT THE SAME PROPORTION OF TREES WILL DIE/YEAR IN THE CYCLE, AS
C  DIED/YEAR IN THE MORTALITY OBSERVATION PERIOD. THE PROB
C  VALUES ARE INFLATED FOR ALL DEAD TREES, BUT ONLY THE RECENT
C  DEAD TREES ARE USED FOR CALCULATING BACKDATED DENSITY. TREES
C  CLASSIFIED AS "OLDER DEAD" ARE IGNORED IN THIS PROCESS. HOWEVER,
C  WHEN IT COMES TO REPRESENTING THE TREES/ACRE FOR A RECORD IN THE
C  TREELIST, OR WHEN NEEDED IN OTHER CALCULATIONS, THIS INFLATION
C  SHOULD NOT BE DONE.  ANY TIME THESE RECORDS ARE USED FOR ANOTHER
C  PURPOSE DURING "CYCLE 0" PROCESING, THIS SCALING NEEDS TO BE
C  "UNDONE" (SEE CALL TO **FMSSEE** IN **CRATET**, AND PROB
C  DEFLATING IN **PRTRLS**, TO SEE HOW THIS IS DONE).
C----------
      VP=VP*(FINT/FINTM)
      FP=FP*(FINT/FINTM)
      FP2=FP2*(FINT/FINTM)
      GO TO 10
   60 CONTINUE
      RETURN
      END
