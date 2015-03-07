      SUBROUTINE BFVOL(ISPC,D,H,D2H,BBFV,TKILL,LCONE,BARK,VMAX,ITHT,
     1                 BTKFLG)
      use contrl_mod
      use prgprm_mod
      use plot_mod
      use coeffs_mod
      use arrays_mod
      implicit none
C----------
C  **BFVOL--TT   DATE OF LAST REVISION:   03/10/10
C----------
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'VOLSTD.F77'
C
C  ************** BOARD FOOT MERCHANTABILITY SPECIFICATIONS ********
C
C  BFVOL CALCULATES BOARD FOOT VOLUME OF ANY TREE LARGER THAN A MINIMUM
C  DBH SPECIFIED BY THE USER.  MINIMUM DBH CAN VARY BY SPECIES,
C  BUT CANNOT BE LESS THAN 2 INCHES.  MINIMUM MERCHANTABLE DBH IS
C  SET WITH THE BFVOLUME KEYWORD.  FOR METHB = 1-4 MERCHANTABLE
C  TOP DIAMETER CAN BE SET TO ANY VALUE BETWEEN 2 IN. AND MINIMUM DBH.
C  MINIMUM DBH AND TOP DIAMETER ARE ASSUMED TO BE MEASURED OUTSIDE
C  BARK--IF DIB IS DESIRED, ALLOW FOR DOUBLE BARK THICKNESS IN
C  SPECIFICATIONS.
C
C  VOLUME CAN BE COMPUTED BY FORMULA (METHB=1 OR 2) OR BY APPLYING THE
C  REGION 6 LOG RULES (METHB=3 OR 4).
C
C  FOR METHB=1 KEMP'S EQUATIONS ARE USED.  KEMP'S EQUATIONS IMPLY
C  SPECIFIC MERCHANTABILITY STANDARDS WHICH ARE:
C  STANDARDS (9" MINIMUM DBH, 8" MINIMUM TOP DIAMETER, AND 1' STUMP).
C  VOLUME ABOVE THE 8" TOP IS IGNORED.
C
C  ALL PARAMETERS IN THE KEMP EQUATION FORM CAN BE REPLACED BY THE
C  USER WITH THE BFVOLEQU KEYWORD.  IF A USER ENTERS THEIR OWN EQUATION
C  IT IS ASSUMED TO APPLY FROM THE STUMP TO THE MERCH TOP.
C
C  DEFAULT COEFFICIENTS FOR THE KEMP EQUATIONS ARE LOADED IN BLKDAT.
C  VARIANTS OTHER THAN NORTH IDAHO MAY HAVE DEFAULT COEFFICIENTS FOR
C  THE KEMP EQUATION FORM, BUT THEY AREN'T KEMP'S EQUATIONS. IN THIS
C  CASE THE KEMP MERCHANTABILITY STANDARDS STATED ABOVE DO NOT APPLY.
C
C  VOLUME LOSS DUE TO TOP DAMAGE (TKILL=.TRUE.) IS ESTIMATED WITH A
C  BEHRE HYPERBOLA TAPER MODEL, WITH PARAMETERS ESTIMATED FROM TOTAL
C  CUBIC FOOT VOLUME, HEIGHT AND DIAMETER.
C
C  FOR METHB=3 OR 4, BOTH TOTAL VOLUME AND VOLUME LOSS DUE TO TOP
C  DAMAGE ARE COMPUTED WITH THE LOG RULE.
C----------
      LOGICAL LOGOK,LCONE,TKILL,BTKFLG
      REAL SMDIA(20),GLOGLN(20)
      REAL VMAX,BARK,BBFV,D2H,H,D,TSIZE,HTRUNC,TD,DIB
      REAL FC,SMDOLD,TLOG,XLOG,SMD,PLEFT,D1SQ,FACTOR
      INTEGER ITHT,ISPC,ID,ITD,NUMLOG,I,INC,LAST
C
C----------
C  INITIALIZE VOLUME ESTIMATE.
C----------
      BBFV=0.0
C----------
C  TRANSFER TO STATEMENT 300 TO PROCESS WESTERN SIERRA LOG RULES.
C  (METHB=5)
C----------
      IF(METHB(ISPC).EQ.5) GO TO 300
C----------
C  TRANSFER TO STATEMENT 100 TO PROCESS REGION 6 LOG RULES.
C  (METHB= 3 OR 4).
C----------
      IF(METHB(ISPC).EQ.3 .OR. METHB(ISPC).EQ.4) GO TO 100
C----------
C  ASSIGN TRANSITION SIZE.
C----------
      TSIZE=D
      IF(IBTRAN(ISPC).GT.0) TSIZE=D2H
      IF(TSIZE.GE.BTRAN(ISPC)) GO TO 20
C
      BBFV = BFVEQS(1,ISPC)
     &     + BFVEQS(2,ISPC)*D
     &     + BFVEQS(3,ISPC)*D*H
     &     + BFVEQS(4,ISPC)*D2H
     &     + BFVEQS(5,ISPC)*D**BFVEQS(6,ISPC)*H**BFVEQS(7,ISPC)
      GO TO 30
   20 CONTINUE
      BBFV = BFVEQL(1,ISPC)
     &     + BFVEQL(2,ISPC)*D
     &     + BFVEQL(3,ISPC)*D*H
     &     + BFVEQL(4,ISPC)*D2H
     &     + BFVEQL(5,ISPC)*D**BFVEQL(6,ISPC)*H**BFVEQL(7,ISPC)
C----------
C  THE FOLLOWING PIECE OF FOOLISHNESS (J.E.B.) IS REQUIRED
C  BY NATIONAL FOREST SCALING AND CRUISING RULES.  BE CAREFUL IF
C  YOU BUY A CORRAL POLE SALE BASED ON A SCRIBNER CRUISE VOLUME.
C----------
   30 CONTINUE
      IF(BBFV.LT.10.0) BBFV=10.0
C----------
C  SET TOPKILL FLAG AND RETURN.
C----------
      BTKFLG = .TRUE.
      RETURN
C
C----------
C  METHB = 3 OR 4:  VOLUME COMPUTED USING ONE OF THE REGION 6 LOG
C  RULES.  MINIMUM DBH FOR LOG RULE IS 4 INCHES.
C----------
  100 CONTINUE
      IF (D.LT. BFMIND(ISPC)) RETURN
C----------
C  LOAD HTRUNC AND H FOR TOP DAMAGED TREES.
C----------
      HTRUNC=0.0
      IF(TKILL) HTRUNC=ITHT/100.0
C----------
C  CALL **FORMCL** TO DETERMINE FORM CLASS
C----------
      TD=BFTOPD(ISPC)*BARK
      DIB=D*BARK
      CALL FORMCL(ISPC,IFOR,D,FC)
C----------
C  CALL **RXDIBS** TO COMPUTE NUMBER OF 16FT LOGS AND EACH SMALL-
C  END DIB
C----------
      CALL RXDIBS(D,FC,H,TD,SMDIA,GLOGLN,NUMLOG,JOSTND)
C----------
C  INITIALIZE:
C     TLOG=CUMULATIVE LENGTH OF LOGS ALREADY PROCESSED.
C     LOGOK=SET TO FALSE WHEN LOG CONTAINING BROKEN TOP IS PROCESSED.
C----------
      SMDOLD=DIB
      TLOG=0.0
      LOGOK=.TRUE.
      IF(METHB(ISPC).EQ.4) GO TO 200
C----------
C  REGION 6 EAST SIDE VOLUME (16 FOOT LOGS).  BRANCH TO STATEMENT 200
C  FOR WESTSIDE CALCULATIONS (32 FOOT LOGS).
C----------
      DO 110 I = 1,NUMLOG
C----------
C  EXIT LOOP IF LAST LOG INCLUDED A BROKEN TOP.
C----------
      IF(.NOT.LOGOK) GO TO 120
      XLOG=GLOGLN(I)
      SMD=SMDIA(I)
C----------
C  SET FLAG AND ADJUST THE TOP DIAMETER AND LOG LENGTH IF THIS LOG
C  CONTAINS A DEAD TOP.
C----------
      IF(TKILL .AND. (TLOG+XLOG).GT.HTRUNC) THEN
        PLEFT=(HTRUNC-TLOG)/XLOG
        IF(PLEFT.LE.0.0) GO TO 120
        XLOG=HTRUNC-TLOG
        D1SQ=SMDOLD*SMDOLD
        SMD=SQRT(D1SQ-PLEFT*(D1SQ-SMD*SMD))
        LOGOK=.FALSE.
      ENDIF
      CALL SCALEF(SMD,XLOG,FACTOR,JOSTND)
      TLOG=TLOG+XLOG
      BBFV=BBFV+XLOG*FACTOR
      SMDOLD=SMD
  110 CONTINUE
  120 CONTINUE
      RETURN
C
C----------
C  REGION 6 WESTSIDE VOLUME.  32 FOOT LOGS; PROCESS EVERY OTHER LOG.
C----------
  200 CONTINUE
      I=0
      INC=2
  205 CONTINUE
      I=I+INC
C----------
C  EXIT LOOP IF LAST LOG INCLUDED A BROKEN TOP.
C----------
      IF(.NOT.LOGOK) GO TO 220
      IF(INC .EQ. 2) THEN
        XLOG=GLOGLN(I)+GLOGLN(I-1)
      ELSE
        XLOG=GLOGLN(I)
      ENDIF
      SMD=SMDIA(I)
C----------
C  SET FLAG AND ADJUST THE TOP DIAMETER AND LOG LENGTH IF THIS LOG
C  CONTAINS A DEAD TOP.
C----------
      IF(TKILL .AND. (TLOG+XLOG).GT.HTRUNC) THEN
        PLEFT=(HTRUNC-TLOG)/XLOG
        IF(PLEFT.LE.0.0) GO TO 220
        XLOG=HTRUNC-TLOG
        D1SQ=SMDOLD*SMDOLD
        SMD=SQRT(D1SQ-PLEFT*(D1SQ-SMD*SMD))
        LOGOK=.FALSE.
      ENDIF
      CALL SCALEF(SMD,XLOG,FACTOR,JOSTND)
      TLOG=TLOG+XLOG
      BBFV=BBFV+XLOG*FACTOR
      SMDOLD=SMD
      IF(I .LT. NUMLOG) THEN
        LAST = NUMLOG - I
        IF(LAST .EQ. 1) INC=1
        GO TO 205
      ENDIF
  220 CONTINUE
      RETURN
C----------
C  WESTERN SIERRA LOG RULES.
C----------
  300 CONTINUE
      ITD=BFTOPD(ISPC)+0.5
      IF(ITD.GT.100) ITD=100
      CALL LOGS(D,H,ITD,BFMIND(ISPC),ISPC,BFSTMP(ISPC),BBFV)
      BTKFLG = .TRUE.
      RETURN
C
      END
