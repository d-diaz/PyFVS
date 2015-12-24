      SUBROUTINE CFVOL(ISPC,D,H,D2H,VN,VM,VMAX,TKILL,LCONE,BARK,ITHT,
     1                 CTKFLG)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use volstd_mod
      use prgprm_mod
      implicit none
C----------
C  **CFVOL--KT    DATE OF LAST REVISION:  04/03/08
C----------
C THIS ROUTINE CALCULATES TOTAL CUBIC FOOT VOLUME USING A NUMBER OF
C DIFFERENT METHODS.
C----------
COMMONS
C----------
C  DIMENSION STATEMENT FOR INTERNAL ARRAYS.
C----------
      REAL SMDIA(20),GLOGLN(20)
      LOGICAL TKILL,LCONE,LOGOK,LMRCH,CTKFLG
      INTEGER INC,ITHT,ISPC,I,LAST,NUMLOG
      REAL BARK,VMAX,VM,VN,D2H,H,D,TSIZE,VOLT,BEHRE,STUMP,DMRCH,HTMRCH
      REAL RCF,VOLM,S3,TD,DIB,FC,HTRUNC,D1SQ,TLOG,D2SQ,XLOG
      REAL PLEFT,VOLLOG,DTSQ,PK
C----------
C  METHC = 1: VOLUME COMPUTED USING REGRESSION MODEL WITH EITHER DEFAULT
C  (SEE **CUBRDS**) OR USER SUPPLIED PARAMETERS (SEE CFVOLEQ KEYWORD).
C  THE REGRESSION MODEL ESTIMATE IS ALSO NEEDED TO PERMIT TAPER
C  PARAMETER ESTIMATION WHEN CUBIC FOOT VOLUME IS DETERMINED BY LOG RULE
C  AND BOARD FOOT VOLUME WILL BE COMPUTED FROM FORMULA.
C----------
      TSIZE=D
      IF(ICTRAN(ISPC).GT.0) TSIZE=D2H
      IF(TSIZE.LT.CTRAN(ISPC)) THEN
        VMAX=CFVEQS(1,ISPC)
     &    +CFVEQS(2,ISPC)*D
     &    +CFVEQS(3,ISPC)*D*H
     &    +CFVEQS(4,ISPC)*D2H
     &    +CFVEQS(5,ISPC)*D**CFVEQS(6,ISPC)*H**CFVEQS(7,ISPC)
      ELSE
        VMAX=CFVEQL(1,ISPC)
     &    +CFVEQL(2,ISPC)*D
     &    +CFVEQL(3,ISPC)*D*H
     &    +CFVEQL(4,ISPC)*D2H
     &    +CFVEQL(5,ISPC)*D**CFVEQL(6,ISPC)*H**CFVEQL(7,ISPC)
      ENDIF
      IF(VMAX .LT. 0.) VMAX = 0.
C----------
C  BRANCH TO STMT 100 TO COMPUTE VOLUME FROM LOG RULE (METHC=2 OR 3).
C----------
      IF(METHC(ISPC).EQ.2 .OR. METHC(ISPC).EQ.3) THEN
        CTKFLG = .FALSE.
        GO TO 100
      ELSE
        CTKFLG = .TRUE.
        VN = VMAX
        IF(VN .EQ. 0.)THEN
          VM = 0.
          CTKFLG = .FALSE.
          GO TO 50
        ENDIF
        CALL BEHPRM (VMAX,D,H,BARK,LCONE)
        VOLT=BEHRE(0.0,1.0)
C----------
C  COMPUTE MERCHANTABLE CUBIC VOLUME USING TOP DIAMETER, MINIMUM
C  DBH, AND STUMP HEIGHT SPECIFIED BY THE USER.
C----------
        STUMP = 1. - (STMP(ISPC)/H)
        IF(D.LT.DBHMIN(ISPC).OR.D.LT.TOPD(ISPC)) THEN
          VM=0.0
        ELSE
          DMRCH=TOPD(ISPC)/D
          HTMRCH=((BHAT*DMRCH)/(1.0-(AHAT*DMRCH)))
C----------
C  SPECIAL KT VARIANT SECTION
C
C  COMPUTE MERCHATABLE CUBIC-FOOT VOLUME BY MULTIPLYING TOTAL
C  CUBIC-FOOT VOLUME BY A REDUCTION FACTOR.  FOR WP, WL, DF, GF,
C  LP, AND PP.
C
        CALL KTFCTR(ISPC,TOPD(ISPC),D,RCF)
        IF(RCF .GT. 0.) THEN
          VM=RCF*VN
          RETURN
        ENDIF
C
C  END OF SPECIAL KT SECTION
C----------
          IF(.NOT.LCONE) THEN
            VOLM=BEHRE(HTMRCH,STUMP)
            VM=VMAX*VOLM/VOLT
          ELSE
C----------
C         PROCESS CONES.
C----------
            S3=STUMP**3
            VOLM=S3-HTMRCH**3
            VM=VMAX*VOLM
          ENDIF
        ENDIF
      ENDIF
   50 CONTINUE
      RETURN
C
C----------
C  METHC = 2 OR 3:  VOLUME COMPUTED USING ONE OF THE REGION 6 LOG
C  RULES.  BOUND VMAX TO A NUMBER GREATER THAN OR EQUAL TO ZERO.
C----------
  100 CONTINUE
      IF(VMAX.LT.0.0) VMAX=0.0
      TD=TOPD(ISPC)*BARK
      DIB=D*BARK
C----------
C  CALL **FORMCL** TO DETERMINE FORM CLASS
C----------
      CALL FORMCL(ISPC,IFOR,D,FC)
C----------
C  ZERO VOLUME RETURNED IF DIB IS LESS THAN 1 INCH.
C----------
      IF (DIB.LT. 1.0) RETURN
C----------
C  LOAD HTRUNC AND H FOR TOP DAMAGED TREES.
C----------
      HTRUNC=0.0
      IF(TKILL) HTRUNC=ITHT/100.0
C----------
C  CALL **RXDIBS** TO COMPUTE NUMBER OF 16FT LOGS AND EACH SMALL-END DIB
C----------
      CALL RXDIBS(D,FC,H,1.0,SMDIA,GLOGLN,NUMLOG,JOSTND)
C----------
C  INITIALIZE:
C     D1SQ=SQUARED DIAMETER AT LARGE END OF CURRENT LOG.
C     D2SQ=SQUARED DIAMETER AT SMALL END OF CURRENT LOG.
C     TLOG=CUMULATIVE LENGTH OF LOGS ALREADY PROCESSED.
C     LMRCH=SET TO FALSE WHEN LOG CONTAINING MERCHANTABLE TOP IS
C           PROCESSED.  LMRCH IS ALSO SET FALSE WHEN TREE DOES NOT
C           MEET MINIMUM DBH FOR MERCHANTABILITY STANDARD.
C     LOGOK=SET TO FALSE WHEN LOG CONTAINING BROKEN TOP IS PROCESSED.
C     VOLM=MERCHANTABLE VOLUME OF LOG CONTAINING MERCHANTABLE TOP.
C----------
      D1SQ=DIB*DIB
      TLOG=0.0
      VOLM=0.0
      LMRCH=.TRUE.
      IF(D.LT.DBHMIN(ISPC)) LMRCH=.FALSE.
      LOGOK=.TRUE.
      IF(METHC(ISPC).EQ.3) GO TO 200
C----------
C  REGION 6 EAST SIDE VOLUME (16 FOOT LOGS).  BRANCH TO STATEMENT 200 FOR
C  WESTSIDE CALCULATIONS (32 FOOT LOGS).
C----------
      DO 110 I = 1,NUMLOG
C----------
C  EXIT LOOP IF LAST LOG INCLUDED A BROKEN TOP.
C----------
      IF(.NOT.LOGOK) GO TO 120
      IF(SMDIA(I).GT.120.) THEN
         SMDIA(I)=120.0
         WRITE(JOSTND,105)
  105    FORMAT(/' ******** ERROR: SMALL END LOG DIAMETER GREATER THAN',
     &   ' 120 INCHES; RESET TO 120 INCHES')
         CALL RCDSET(2,.TRUE.)
      ENDIF
      D2SQ=SMDIA(I)*SMDIA(I)
      XLOG=GLOGLN(I)
C----------
C  SET FLAG AND ADJUST THE TOP DIAMETER AND LOG LENGTH IF THIS LOG
C  CONTAINS A DEAD TOP.
C----------
      IF(TKILL .AND. (TLOG+XLOG).GT.HTRUNC) THEN
        PLEFT=(HTRUNC-TLOG)/XLOG
        IF(PLEFT.LE.0.0) GO TO 120
        XLOG=HTRUNC-TLOG
        D2SQ=D1SQ-PLEFT*(D1SQ-D2SQ)
        LOGOK=.FALSE.
      ENDIF
      TLOG=TLOG+XLOG
      VOLLOG=0.00272708*XLOG*(D1SQ+D2SQ)
C----------
C  CHECK TO SEE IF THE MERCHANTABLE TOP IS IN THIS LOG.  IF SO, COMPUTE
C  THE MERCHANTABLE VOLUME.
C----------
      IF(LMRCH .AND. (.NOT.LOGOK .OR. TD.GE.SMDIA(I))) THEN
        LMRCH=.FALSE.
        IF(.NOT.LOGOK .AND. TD.LE.SQRT(D2SQ)) THEN
          VOLM=VOLLOG
        ELSE
          DTSQ=TD*TD
C----------
C         ESTIMATE NEW LOG LENGTH CORRESPONDING TO TOPD BY ASSUMING LOG
C         IS A FRUSTRUM OF A PARABALOID.  LOG LENGTH IS PROPORTIONAL TO
C         THE DIFFERENCE BETWEEN THE SQUARED DIAMETERS OF THE LOG ENDS.
C----------
          PK=XLOG/(D1SQ-D2SQ)
          XLOG=PK*(D1SQ-DTSQ)
          VOLM=0.00272708*XLOG*(D1SQ+DTSQ)
        ENDIF
        VM=VN+VOLM
      ENDIF
      VN=VN+VOLLOG
      D1SQ=D2SQ
  110 CONTINUE
  120 CONTINUE
      RETURN
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
      IF(SMDIA(I).GT.120.) THEN
         SMDIA(I)=120.0
         WRITE(JOSTND,105)
         CALL RCDSET(2,.TRUE.)
      ENDIF
      D2SQ=SMDIA(I)*SMDIA(I)
      IF(INC .EQ. 2) THEN
        XLOG=GLOGLN(I)+GLOGLN(I-1)
      ELSE
        XLOG=GLOGLN(I)
      ENDIF
C----------
C  SET FLAG AND ADJUST THE TOP DIAMETER AND LOG LENGTH IF THIS LOG
C  CONTAINS A DEAD TOP.
C----------
      IF(TKILL .AND. (TLOG+XLOG).GT.HTRUNC) THEN
        PLEFT=(HTRUNC-TLOG)/XLOG
        IF(PLEFT.LE.0.0) GO TO 220
        XLOG=HTRUNC-TLOG
        D2SQ=D1SQ-PLEFT*(D1SQ-D2SQ)
        LOGOK=.FALSE.
      ENDIF
      TLOG=TLOG+XLOG
      VOLLOG=0.00272708*XLOG*(D1SQ+D2SQ)
C----------
C  CHECK TO SEE IF THE MERCHANTABLE TOP IS IN THIS LOG.  IF SO, COMPUTE
C  THE MERCHANTABLE VOLUME.
C----------
      IF(LMRCH .AND. (.NOT.LOGOK .OR. TD.GE.SMDIA(I))) THEN
        LMRCH=.FALSE.
        IF(.NOT.LOGOK.AND.TD.LE.SQRT(D2SQ)) THEN
          VOLM=VOLLOG
        ELSE
          DTSQ=TD*TD
C----------
C         ESTIMATE NEW LOG LENGTH CORRESPONDING TO TOPD BY ASSUMING LOG
C         IS A FRUSTRUM OF A PARABALOID.  LOG LENGTH IS PROPORTIONAL TO
C         THE DIFFERENCE BETWEEN THE SQUARED DIAMETERS OF THE LOG ENDS.
C----------
          PK=XLOG/(D1SQ-D2SQ)
          XLOG=PK*(D1SQ-DTSQ)
          VOLM=0.00272708*XLOG*(D1SQ+DTSQ)
        ENDIF
        VM=VN+VOLM
      ENDIF
      VN=VN+VOLLOG
      D1SQ=D2SQ
      IF(I .LT. NUMLOG) THEN
        LAST = NUMLOG-I
        IF(LAST .EQ. 1) INC=1
        GO TO 205
      ENDIF
  220 CONTINUE
      RETURN
      END
