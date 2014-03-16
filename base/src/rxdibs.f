      SUBROUTINE RXDIBS(DBH,FC,HT,TOPD,SMDIA,GLOGLN,NUMLOG,JOSTND)
      IMPLICIT NONE
C----------
C  $Id: rxdibs.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C  SAME AS OLD  R6DIBS --- NAME CHANGED TO ALLOW USE OF NEW R6DIBS
C  FROM VOLUME LIBRARY
C----------
C  THIS SUBROUTINE COMPUTES THE NUMBER OF 16FT LOGS
C  AND THE INSIDE BARK DIAMETERS FOR EACH.
C----------------------------------------------------------------------
C               LIST OF VARIABLES FOUND IN SUBROUTINE DIBS
C NAME   SOURCE TYPE                    DESCRIPTION
C
C D16    LOCAL  REAL  DIAMETER INSIDE BARK @ 16 FT.
C DBH    ARGMT  REAL  DIAMETER BREAST HEIGHT OUTSIDE BARK.
C SMDIA  ARGMT  R(19) DIAMETER INSIDE BARK FOR EACH LOG.
C FC     ARGMT  REAL  TREE FORM CLASS.
C HT    ARGMT  INTGR TOTAL TREE HEIGHT.
C GLOGLN ARGMT  R(19) LOG LENGTHS FOR EACH LOG IN TREE.
C NUMLOG ARGMT  INTGR NUMBER OF LOGS IN THE TREE.
C STMFND LOCAL  REAL  LENGTH OF STEM ALREADY CALCULATED.
C STMCAL LOCAL  REAL  LENGTH OF STEM NEEDING DIA'S AND LENGTHS.
C STMRAT LOCAL  REAL  RATIO OF STEM REMAINING TO UPPER STEM HEIGHT.
C TOPD   ARGMT  REAL  MERCHANTIBLE TOP DIAMETER FOR TREE.
C USHT   LOCAL  REAL  UPPER STEM HEIGHT.
C---------------------------------------------------------------------
C
      INTEGER JOSTND,NUMLOG,I
      REAL TOPD,HT,DBH,D16,USHT,STMFND,STMCAL,STMRAT,XD,XM,FC
      REAL SMDIA(20),GLOGLN(20)
C----------
C  INITIALIZE DIAMETER & LOG LENGTH ARRAYS...
C----------
      DO 1 NUMLOG = 1,20
         SMDIA(NUMLOG)=0.0
         GLOGLN(NUMLOG) = 0.0
    1 CONTINUE
C----------
C  COMPUTE DIB AT 16.3' (FORM CLASS HEIGHT)...
C----------
      D16=DBH*(FC/100.0)
C----------
C  CHECK FOR A TREE HAVING ONLY 1 LOG...
C----------
      IF (D16.LE.TOPD) THEN
C----------
C        ONLY ONE LOG IN TREE.
C----------  
         NUMLOG = 1
C----------
C  SET THE SMALL END DIAMETER OF THE 1ST LOG TO MERCH TOP...
C----------
         SMDIA(1) = TOPD
C----------
C  COMPUTE THE LENGTH OF THE LOG AS A RATIO BETWEEN DBH TO MERCH TOP
C  AND DBH TO DIB @ 16.3'; MINIMUM LOG LENGTH = 0.1 FT.
C----------
!         GLOGLN(1) = (((DBH**2-TOPD**2)/(DBH**2-D16**2))*12.3)+4.0
         GLOGLN(1) = (((DBH*DBH-TOPD*TOPD)/(DBH*DBH-D16*D16))*12.3)+4.0
         IF( GLOGLN(1) .LT. 0.1 ) GLOGLN(1) = 0.1
      ELSE
C----------
C  TREE HAS MORE THAN ONE LOG; SET SMALL END DIAMETER OF BUTT LOG TO 
C  D16 AND LOG LENGTH TO 16.3 FT.
C----------
         SMDIA(1) = D16
         GLOGLN(1) = 16.3
C----------
C  COMPUTE TOTAL STEM LENGTH ABOVE THE BUTT LOG; LOOP TO COMPUTE
C  REMAINING LOG LENGTHS AND SMALL END DIAMETERS.
C----------
         USHT = HT - 16.3
         DO 150 NUMLOG = 2,20
         STMFND = 16.3*(NUMLOG-1)
         STMCAL = USHT - STMFND
C----------
C  CHECK FOR LAST LOG LESS THAN 16.3 FT.
C----------
         IF (STMCAL.LT.0.0) GO TO 167
C----------
C  CALCULATE DIAMETER INSIDE BARK FOR SMALL END OF CURRENT LOG
C  AND CHECK TO SEE IF GREATER THAN MERCHANTABILITY LIMIT.
C----------
         STMRAT = STMCAL/USHT
         SMDIA(NUMLOG) = (STMRAT/(0.49*STMRAT+0.51))*D16
         IF(SMDIA(NUMLOG).LE.TOPD) GO TO 167
C----------
C  FULL LOG: ASSIGN LENGTH AND CONTINUE LOOP.
C----------
         GLOGLN(NUMLOG) = 16.3
  150    CONTINUE
C----------
C  MORE THAN 20 LOGS IN CURRENT TREE.  PRINT ERROR MESSAGE AND RETURN.
C----------
         WRITE(JOSTND,151)
  151    FORMAT(/' ********  ERROR: IN **R6DIBS**  MORE THAN 20 LOGS', 
     &    ' WERE FOUND IN A TREE; VOLUME TRUNCATED AT 20 LOGS')
         WRITE(JOSTND,152)  DBH,FC,HT,NUMLOG,TOPD,(SMDIA(I),I=1,NUMLOG)
  152    FORMAT(' IN DIBS: DBH FC HT NUMLOG TOPD SMDIA=',
     &            3F8.1,I5,F8.1,/,19F6.1)
         RETURN
  167    CONTINUE
C----------
C  COMPUTE LENGTH OF LAST LOG IN MULTI-LOG TREE. SET SMALL END DIAMETER 
C  TO TOPD.
C----------
         SMDIA(NUMLOG) = TOPD
         USHT = HT - 16.3
C----------
C  COMPUTE A TAPER RATE AS THE RATIO BETWEEN SMALL ENDS OF THE
C  FIRST AND LAST LOGS...
C----------
         XD = TOPD / SMDIA(1)
C----------
C  COMPUTE THE LENGTH OF THE TIP OF THE STEM ABOVE MERCH TOP.
C----------
         XM = (XD*0.51*USHT) / (1.0-(0.49*XD))
C----------
C  SUBTRACT THE TIP LENGTH AND THE LENGTH OF THE LOGS BETWEEN THE TOP
C  OF THE FIRST AND LAST LOGS (DIB @ 16.3' AND TOPD) TO GIVE THE LENGTH
C  OF THE LAST PIECE BELOW MERCH TOP.  BOUND TO MINIMUM OF 0.1 FT.
C----------
         GLOGLN(NUMLOG) = (USHT - XM) - ((NUMLOG-2)*16.3)
         IF( GLOGLN(NUMLOG) .LE. 0.0 ) GLOGLN(NUMLOG) = 0.1
      END IF
C
      RETURN
      END
