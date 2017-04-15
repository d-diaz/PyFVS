      SUBROUTINE ORIN (DEBUG,LKECHO,LNOTRE)
      use contrl_mod
      use volstd_mod
      use plot_mod
      use prgprm_mod
      use organon_mod
      implicit none
C----------
C  **ORIN  ORGANON--DATE OF LAST REVISION:  04/15/2015
C----------
C
C     ORGANON EXTENSION KEYWORD PROCESSOR.
C----------
COMMONS
C----------
C VARIABLE DECLARATIONS:
C----------
      INTEGER    KWCNT
      PARAMETER (KWCNT = 4)
c
      LOGICAL      LNOTBK(7)
      LOGICAL      LOK
      LOGICAL      LKECHO,LNOTRE
      LOGICAL      DEBUG
C
      CHARACTER*8  TABLE(KWCNT)
      CHARACTER*8  KEYWRD
      CHARACTER*8  PASKEY
      CHARACTER*10 KARD(7)
      CHARACTER    VVER*7,FNAME*80
      INTEGER      KODE,IPRMPT,NUMBER,I
      INTEGER      ORGINP
C
      REAL         ARRAY(7)
C----------
C INITIALIZATIONS:
C----------
C
      DATA TABLE /
     >    'END     ',      ! Option 100
     >    'ORGINFO ',      ! Option 200
     >    'ORGVOLS ',      ! Option 300
     >    'INPFILE '/      ! Option 400
C
C----------
C     **********          EXECUTION BEGINS          **********
C----------
      LORGANON = .TRUE.
      LORGVOLS = .FALSE.
      CALL VARVER(VVER)
C
 10   CONTINUE
C----------
C CALL KEYWORD READER
C----------
      CALL KEYRDR (IREAD,JOSTND,DEBUG,KEYWRD,LNOTBK,
     >             ARRAY,IRECNT,KODE,KARD,LFLAG,LKECHO)
C----------
C  RETURN KODES 0=NO ERROR,1=COLUMN 1 BLANK OR ANOTHER ERROR,2=EOF
C               LESS THAN ZERO...USE OF PARMS STATEMENT IS PRESENT.
C----------

      IF (KODE.LT.0) THEN
         IPRMPT=-KODE
      ELSE
         IPRMPT=0
      ENDIF
      IF (KODE .LE. 0) GO TO 30
      IF (KODE .EQ. 2) CALL ERRGRO(.FALSE.,2)
      CALL ERRGRO (.TRUE.,6)
      GOTO 10
C----------
C  CHECK FOR VALID ORGANON KEYWORD
C----------
   30 CONTINUE
      CALL FNDKEY (NUMBER,KEYWRD,TABLE,KWCNT,KODE,.FALSE.,JOSTND)
C----------
C  RETURN KODES 0=NO ERROR,1=KEYWORD NOT FOUND,2=KEYWORD NOT SPELLED CORRECTLY
C----------
      IF (KODE .EQ. 0) GOTO 90
      IF (KODE .EQ. 1) THEN
         CALL ERRGRO (.TRUE.,1)
         GOTO 10
      ENDIF
      GOTO 90
C----------
C     SPECIAL END-OF-FILE TARGET (USED IF YOU READ PARAMETER CARDS)
C----------
      CALL ERRGRO (.FALSE.,2)
C----------
C     PROCESS OPTIONS
C----------
   90 CONTINUE
      GO TO( 100, 200, 300, 400 ), NUMBER
C
C  ==========  OPTION NUMBER  1: END       ===========================END
C
  100 CONTINUE
      IF(LKECHO) THEN
      WRITE(JOSTND,105) KEYWRD
  105 FORMAT (/A8,'   END OF ORGANON KEYWORDS')
      END IF
      GO TO 2000
C
C  ==========  OPTION NUMBER  2: ORGINFO   =======================ORGINFO
C
C  F1 = MODEL TYPE = (1,2,3)
C  F2 = UNEVEN-AGED = 0,  EVEN-AGED = 1
C  F3 = NO MAXSDI_MORTALITY = 0, MAXSDI_MORTALITY = 1
C  F4 = HEIGHT CALIBRATION FLAG (0 = NO, 1 = YES (DEFAULT))
C  F5 = HEIGHT-TO-CROWN BASE CALIBRATION FLAG (0 = NO, 1 = YES (DEFAULT))
C  F6 = DIAMETER GROWTH CALIBRATION FLAG (0 = NO, 1 = YES (DEFAULT))
C
  200 CONTINUE
C
C  F1:
C  ASSIGN THE MODEL TYPE. INITIALIZED TO 0 IN **GRINIT**; DEFAULT SET TO
C  1 OR 2 DEPENDING ON VARIANT IN **SITSET** IF IT ISN'T SET HERE
C
      IF (LNOTBK(1)) THEN
        IMODTY = IFIX(ARRAY(1))
        SELECT CASE (VVER(:2))
          CASE ('OC')
            IF(IMODTY .NE. 1) THEN
              IF(LKECHO ) WRITE(JOSTND,202) KEYWRD
  202         FORMAT (/1X,A8,'   INVALID VERSION. USING VERSION 1 = SWO'
     &        )
              IMODTY = 1
            ENDIF
          CASE DEFAULT
            IF((IMODTY .LT. 2) .OR. (IMODTY .GT. 3)) THEN
              IF(LKECHO ) WRITE(JOSTND,204) KEYWRD
  204         FORMAT (/1X,A8,'   INVALID VERSION. USING VERSION 2 = NWO'
     &        )
              IMODTY = 2
            ENDIF
        END SELECT
      ENDIF
C
C  F2:
C  ASSIGN THE UNEVEN-AGE/EVEN-AGED FLAG FROM THE SECOND POSITION
C  DEFAULT IS THAT THE STAND IS EVEN AGED (SET IN **GRINIT**)
C  0=UNEVEN-AGED STAND; 1=EVEN-AGED STAND
C  IF THIS FLAG INDICATES EVEN-AGED BUT STAND AGE DOES NOT GET SET USING
C  THE STDINFO KEYWORD OR FROM THE ORGANON .INP FILE, THEN THIS WILL
C  GET SET TO UNEVEN-AGED IN **SITSET**
C
      IF (LNOTBK(2)) THEN
        INDS(4) = IFIX(ARRAY(2))
        IF((INDS(4).LT.0) .OR. (INDS(4).GT.1))THEN
          INDS(4) = 1
          IF(LKECHO ) WRITE(JOSTND,206) KEYWRD
  206     FORMAT (/1X,A8,'   INVALID EVEN-AGED/UNEVEN-AGED FLAG.',
     &    ' USING 1 = EVEN-AGED')
        ENDIF
      ENDIF
C
C  F3:
C  ASSIGN THE ADDITIONAL MORTALITY FLAG
C  0 = NO ADDITIONAL MORTALITY
C  1 = CALCULATE ADDITIONAL MORTALITY USING MAX SDI (DEFAULT SET IN **GRINIT**)
C
      IF (LNOTBK(3)) THEN
        INDS(9) = IFIX(ARRAY(3))
        IF((INDS(9).LT.0) .OR. (INDS(9).GT.1))THEN
          INDS(9) = 1
          IF(LKECHO ) WRITE(JOSTND,208) KEYWRD
  208     FORMAT (/1X,A8,'   INVALID MORTALITY FLAG. USING 1 = YES')
        ENDIF
      ENDIF
C
C  F4:
C  ASSIGN HEIGHT CALIBRATION VALUES. DEFAULT SET TO 1 = YES (CALCULATE
C  AND USE CALIBRATION VALUES) IN **GRINIT**.
C
      IF (LNOTBK(4)) THEN
        INDS(1) = IFIX(ARRAY(4))
        IF((INDS(1).LT.0) .OR. (INDS(1).GT.1))THEN
          INDS(1) = 1
          IF(LKECHO) WRITE(JOSTND,210) KEYWRD
  210     FORMAT (/1X,A8,'   INVALID HEIGHT CALIBRATION FLAG.',
     &    ' USING 1 = YES')
        ENDIF
      ENDIF
C
C  F5:
C  ASSIGN HEIGHT-TO-CROWN BASE CALIBRATION VALUES. DEFAULT SET TO 1 = YES
C  (CALCULATEAND USE CALIBRATION VALUES) IN **GRINIT**.
C
      IF (LNOTBK(5)) THEN
        INDS(2) = IFIX(ARRAY(5))
        IF((INDS(2).LT.0) .OR. (INDS(2).GT.1))THEN
          INDS(2) = 1
          IF(LKECHO) WRITE(JOSTND,212) KEYWRD
  212     FORMAT (/1X,A8,'   INVALID HEIGHT-TO-CROWN BASE CALIBRATION ',
     &    ' FLAG. USING 1 = YES')
        ENDIF
      ENDIF
C
C  F6:
C  ASSIGN HEIGHT CALIBRATION VALUES. DEFAULT SET TO 1 = YES (CALCULATE
C  AND USE CALIBRATION VALUES) IN **GRINIT**.
C
      IF (LNOTBK(6)) THEN
        INDS(3) = IFIX(ARRAY(6))
        IF((INDS(3).LT.0) .OR. (INDS(3).GT.1))THEN
          INDS(3) = 1
          IF(LKECHO) WRITE(JOSTND,214) KEYWRD
  214     FORMAT (/1X,A8,'   INVALID DIAMETER GROWTH CALIBRATION FLAG.',
     &    ' USING 1 = YES')
        ENDIF
      ENDIF
C
C WRITE THE KEYWORD OUTPUT TO THE OUTPUT FILE.
C ORGINFO:
C   ORGANON MODEL TYPE (1=SWO,2=NWO,3=SMC)
C   STAND TYPE (0=UNEVEN-AGED,1=EVEN-AGED)= 0
C   ADDITIONAL MAX-SDI MORTALITY (0=NO,1=YES)
C   HEIGHT CALIBRATION (0=NO,1=YES)
C   HEIGHT-TO-CROWN BASE CALIBRATION (0=NO,1=YES)
C   DIAMETER GROWTH CALIBRATION (0=NO,1=YES)
C
      IF (LKECHO) then
        WRITE(JOSTND,216) KEYWRD,IMODTY,INDS(4),INDS(9),INDS(1),INDS(2),
     &  INDS(3)
  216   FORMAT (/A8,'   ORGANON ',
     >       'VARIANT (1=SWO,2=NWO,3=SMC) = ',I2,
     >       '; EVEN-AGED (0=NO,1=YES) = ',I2,
     >       '; MAX-SDI MORTALITY (0=NO,1=YES) = ',I2,';',/,11X,
     >       'HEIGHT CALIBRATION (0=NO,1=YES)=',I2,
     >       '; HEIGHT-TO-CROWN BASE CALIBRATION (0=NO,1=YES)=',I2,
     >       '; DIAMETER GROWTH CALIBRATION (0=NO,1=YES)=',I2)
      END IF
      GOTO 10
C
C  ==========  OPTION NUMBER  3: ORGVOLS   ======================ORGVOLS
C
C  F1 = LOG TRIM
C  F2 = MIN LOG LENGTH
C  F3 = TARGET LOG LENGTH
C  F4 = STUMP HT
C  F5 = TOP DIB
C
C  ORGANON USER'S GUIDE SHOW THESE AS DEFAULTS:
C    CFTD=0.0
C    CFSH=0.0
C    LOGTD=6.0
C    LOGSH=0.5
C    LOGTA=8.0
C    LOGLL=32.0
C    LOGML=8.0
C  JEFF HAS THESE SET AT:
C  VOLS     VOLS     VOLS       VOLS      GRINIT GRINIT GRINIT
C  TOPD(i), STMP(i), BFTOPD(i), BFSTMP(i), 10.0,  32.0,  12.0
C  BUT, FOR EXAMPLE, TOPD(i)=0.0 IN **GRINIT**, THEN = 4.5 OR 6.0 IN **SITSET**
C  SO THESE NEED TO BE EXAMINED AND STRAIGHTENED OUT
C
  300 CONTINUE
      LORGVOLS = .TRUE.
C
C  THESE ARE COMMON TO BOTH CUBIC FOOT AND BOARD FOOT.
C
      IF(LOGTA .LE. 0.0) LOGTA=8.0
      IF (LNOTBK(1)) THEN
        LOGTA =   ARRAY(1)     ! LOG TRIM, IN INCHES.
      ENDIF
C
      IF(LOGML .LE. 0.0) LOGML=8.0
      IF (LNOTBK(2)) THEN
        LOGML =   ARRAY(2)     ! MINIMUM LOG LENGTH, IN FEET.
      ENDIF
C
      IF(LOGLL .LE. 0.0) LOGLL=32.0
      IF (LNOTBK(3)) THEN
        LOGLL =  ARRAY(3)     ! TARGET LOG LENGTH, IN FEET.
      ENDIF
C
C  ASSIGN THE BOARD FOOT VOLUME STUMP HEIGHT SPEC
C
      IF (LNOTBK(4)) THEN
        DO I = 1, MAXSP
        BFSTMP( I ) = ARRAY(4) ! STUMP HEIGHT, IN FEET.
        END DO
      ELSE
        DO I = 1, MAXSP
        ARRAY(4)    = 0.5           ! IF IT'S NOT HERE, THEN SIMPLY ASSIGN IT.
        BFSTMP( I ) = ARRAY(4)      ! STUMP HEIGHT, IN FEET.
        END DO
      ENDIF
C
C  ASSIGN THE BOARD FOOT VOLUME TOP DIAMETER SPEC
C
      IF (LNOTBK(5)) then
        DO I = 1, MAXSP
          BFTOPD( I )  = ARRAY(5)   ! BF LOG TOP DIAMETER, IN INCHES.
        END DO
      ELSE
        DO I = 1, MAXSP
        ARRAY(5)     = 6.0        ! IF IT'S NOT HERE, THEN SIMPLY ASSIGN IT.
        BFTOPD( I )  = ARRAY(5)   ! BF LOG TOP DIAMETER, IN INCHES.
        END DO
      ENDIF
C
C  ASSIGN THE CUBIC FOOT VOLUME STUMP HEIGHT
C
      IF (LNOTBK(6)) then
        DO I = 1, MAXSP
        STMP( I ) = ARRAY(6)      ! STUMP HEIGHT, IN FEET.
        END DO
      ELSE
        DO I = 1, MAXSP
        ARRAY(6)    = 0.0         ! IF IT'S NOT HERE, THEN SIMPLY ASSIGN IT.
        STMP( I ) = ARRAY(6)      ! STUMP HEIGHT, IN FEET.
        END DO
      ENDIF
C
C  ASSIGN THE BOARD FOOT VOLUME TOP DIAMETER SPEC
C
      IF (LNOTBK(7)) then
        DO I = 1, MAXSP
        TOPD( I )    = ARRAY(7)   ! FT^3 VOL, MIN. TOP DIAMETER, INCHES.
        END DO
      ELSE
        DO I = 1, MAXSP
        ARRAY(7)     = 0.0        ! IF IT'S NOT HERE, THEN SIMPLY ASSIGN IT.
        TOPD( I )    = ARRAY(7)   ! FT^3 VOL, MIN. TOP DIAMETER, INCHES.
        END DO
      ENDIF
C
C WRITE THE KEYWORD OUTPUT TO THE OUTPUT FILE.
C
      IF (LKECHO .AND. LORGVOLS ) THEN
        WRITE(JOSTND,311) KEYWRD, LOGTA,LOGML,LOGLL
  311   FORMAT (/A8,'   ORGANON ',
     >  'LOG TRIM IS ', F4.1, ' INCHES',
     >  '; MINIMUM LOG LENGTH IS ', F4.1, ' FEET',
     >  '; TARGET LOG LENGTH IS ', F4.1, ' FEET;' )
C
        WRITE(JOSTND,312) ARRAY(4), ARRAY(5)
  312   FORMAT ('           ',
     >  'BF STUMP HEIGHT IS ', F4.1, ' FEET;',
     >  ' BF MIN TOP DIB IS ', F4.1, ' INCHES' )
C
        WRITE(JOSTND,313) ARRAY(6), ARRAY(7)
  313   FORMAT ('           ',
     >  'CF STUMP HEIGHT IS ', F4.1, ' FEET;',
     >  ' CF MIN TOP DIB IS ', F4.1, ' INCHES' )
      ENDIF
      GO TO 10
C
C  ==========  OPTION NUMBER  4: INPFILE   ======================INPFILE
C
C  SUPPLEMENTAL RECORD = FILENAME
C
C  USE UNIT NUMBER 80 FOR ORGANON .INP FILE INPUT
C
  400 CONTINUE
C
C READ FILE NAME FROM THE SUPPLEMENTAL RECORD
C
      READ(IREAD,402)FNAME
  402 FORMAT(A80)
C
C OPEN THE FILE
C
      ORGINP=80
      OPEN(UNIT=ORGINP,FILE=TRIM(FNAME),STATUS='OLD',RECL=101,ERR=420)
      IF(LKECHO) THEN
        WRITE(JOSTND,404) KEYWRD,FNAME
  404   FORMAT(/A8,'   FILE NAME = ',A80)
      ENDIF
C
      CALL ORG_INTREE(ORGINP,VVER)
C
      BAF = -1.0
      BRK = 0.0
      LNOTRE=.TRUE.
C
C  IF STARTING FROM A PREPPED FILE, TURN THE ORGANON PREPARED FILE
C  SWITCH TO TRUE SO **PREPARE** WON'T GET CALLED FROM **CRATET**
C
      LORGPREP=.TRUE.
C
      CLOSE(80)
      GO TO 10
C
C  FILE DID NOT OPEN
C
  420 CONTINUE
      IF (LKECHO) THEN
        WRITE(JOSTND,422) KEYWRD,FNAME
  422   FORMAT (/1X,A8,'   FILE DID NOT OPEN: FILE NAME = ',A80)
      ENDIF
      GO TO 10
C
 2000 CONTINUE
      RETURN
      END

