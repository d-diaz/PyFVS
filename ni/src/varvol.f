        SUBROUTINE VARVOL
      use contrl_mod
      use volstd_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **VARVOL--NI    DATE OF LAST REVISION:   03/20/13
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 8)
C----------
C
C----------
      CHARACTER CTYPE*1,FORST*2,HTTYPE,VVER*7,VAR*2,PROD*2
      INTEGER IFIAVL,ERRFLAG,LOGST
      REAL SCALEN(20),BOLHT(21),LOGLEN(20),TVOL(15)
      REAL NLOGS
      REAL X01,X02,X03,X04,X05,X06,X07,X08,X09,X010,X011,X012
      REAL NLOGMS,NLOGTW
      INTEGER I01,I02,I03,I04,I05
      INTEGER IT,ITRNC,ISPC,IREGN,IZERO,I1,IFC,IFIASP,IR,IERR,INTFOR
      REAL VMAX,BARK,H,DH,BBFV,VM,VN,DBT,TOPDIB,TVOL1,TVOL4,FC
      REAL TOP,TDIB,DBTBH,X0,TDIBB,TDIBC,BRATIO,D
      LOGICAL DEBUG,TKILL,CTKFLG,BTKFLG,LCONE
      CHARACTER*10 EQNC,EQNB
C----------
C SPECIES ORDER:    1   2   3   4   5   6   7   8   9  10  11
C                  WP   L  DF  GF  WH   C  LP   S  AF  PP  OT
C
C----------
C  NATIONAL CRUISE SYSTEM ROUTINES (METHOD = 6)
C----------
      ENTRY NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'VARVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE VARVOL CYCLE =',I5)
C----------
C  SET PARAMETERS
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      HTTYPE='F'
      IERR=0
      VAR=VVER(:2)
      DBT = D*(1-BARK)
C
      IF(IFOR.EQ.5)THEN
        IREGN=6
      ELSE
        IREGN=1
      ENDIF
C
      IF(DEBUG)WRITE(JOSTND,*)' IFOR, IREGN,ISPC,VEQNNC(ISPC)= ',
     &IFOR, IREGN,ISPC,VEQNNC(ISPC)
C----------
C  BRANCH TO R6 LOGIC FOR COLVILLE NATIONAL FOREST.
C----------
      IF(IFOR .EQ. 5) GO TO 100
C
C----------
C  REGION 1 NATCRS SEQUENCE
C----------
      DO 10 IZERO=1,15
      TVOL(IZERO)=0.
   10 CONTINUE
      TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
      I01=0
      I02=0
      I03=0
      I04=0
      I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
      X01=0.
      X02=0.
      X03=0.
      X04=0.
      X05=0.
      X06=0.
      X07=0.
      X08=0.
      X09=0.
      X010=0.
      X011=0.
      X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
      CTYPE=' '
      PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
      I1= 1
C
      IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &  ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &  DBT,BARK
C
      CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &I05,X012,CTYPE,I01,PROD,IERR)
C
      IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
C
      IF(D.GE.BFMIND(ISPC))THEN
        IF(IT.GT.0)HT2TD(IT,1)=X02
      ELSE
        IF(IT.GT.0)HT2TD(IT,1)=0.
      ENDIF
      IF(D.GE.DBHMIN(ISPC))THEN
        IF(IT.GT.0)HT2TD(IT,2)=X02
      ELSE
        IF(IT.GT.0)HT2TD(IT,2)=0.
      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)).OR.
     &   (BFSTMP(ISPC).NE.STMP(ISPC)).OR.
     &   (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 20 IZERO=1,15
        TVOL(IZERO)=0.
   20   CONTINUE
        TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I01=0
        I02=0
        I03=0
        I04=0
        I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
        X01=0.
        X02=0.
        X03=0.
        X04=0.
        X05=0.
        X06=0.
        X07=0.
        X08=0.
        X09=0.
        X010=0.
        X011=0.
        X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE=' '
        PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
C
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &  ISPC,IREGN,VEQNNB(ISPC),VEQNNB(ISPC),BFSTMP(ISPC),D,H,
     &  DBT,BARK
C
        CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,BFSTMP(ISPC),
     &  D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.
     &  ,LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
C
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
C
        TVOL(1)=TVOL1
        TVOL(4)=TVOL4
      ENDIF
C----------
C  SET RETURN VALUES.
C----------
      VN=TVOL(1)
      IF(VN.LT.0.)VN=0.
      VMAX=VN
      IF(D .LT. DBHMIN(ISPC))THEN
        VM = 0.
      ELSE
        VM=TVOL(4)
        IF(VM.LT.0.)VM=0.
      ENDIF
      IF(D.LT.BFMIND(ISPC))THEN
        BBFV=0.
      ELSE
        IF(METHB(ISPC).EQ.9) THEN
          BBFV=TVOL(10)
        ELSE
          BBFV=TVOL(2)
        ENDIF
        IF(BBFV.LT.0.)BBFV=0.
      ENDIF
      CTKFLG = .TRUE.
      BTKFLG = .TRUE.
      RETURN
C
C----------
C  REGION 6 NATCRS SEQUENCE
C----------
  100 CONTINUE
C----------
C  BRANCH TO EITHER THE PROFILE EQN OR OLD R6 FORM CLASS EQN
C----------
      IF(VEQNNC(ISPC)(1:1).EQ.'I')THEN
        DO 110 IZERO=1,15
        TVOL(IZERO)=0.
  110   CONTINUE
        TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I01=0
        I02=0
        I03=0
        I04=0
        I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
        X01=0.
        X02=0.
        X03=0.
        X04=0.
        X05=0.
        X06=0.
        X07=0.
        X08=0.
        X09=0.
        X010=0.
        X011=0.
        X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE=' '
        PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
        IREGN= 6
C
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &    DBT,BARK
C
        CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &  HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &  LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
        IF(D.GE.DBHMIN(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,2)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,2)=0.
        ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
        IF(BFTOPD(ISPC).NE.TOPD(ISPC) .OR.
     &     BFSTMP(ISPC).NE.STMP(ISPC)) THEN
          TVOL1=TVOL(1)
          TVOL4=TVOL(4)
          DO 120 IZERO=1,15
          TVOL(IZERO)=0.
  120     CONTINUE
          TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
          I01=0
          I02=0
          I03=0
          I04=0
          I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
          X01=0.
          X02=0.
          X03=0.
          X04=0.
          X05=0.
          X06=0.
          X07=0.
          X08=0.
          X09=0.
          X010=0.
          X011=0.
          X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
          CTYPE=' '
          PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
          I1= 1
          IREGN= 6
C
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,
     &    BFSTMP(ISPC),D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,
     &    I02,DBT,BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,
     &    X010,X011,I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
          TVOL(1)=TVOL1
          TVOL(4)=TVOL4
        ENDIF
C----------
C  SET RETURN VALUES.
C----------
        VN=TVOL(1)
        IF(VN.LT.0.)VN=0.
        VMAX=VN
        IF(D .LT. DBHMIN(ISPC))THEN
          VM = 0.
        ELSE
          VM=TVOL(4)
          IF(VM.LT.0.)VM=0.
        ENDIF
        IF(D.LT.BFMIND(ISPC))THEN
          BBFV=0.
        ELSE
          IF(METHB(ISPC).EQ.9) THEN
            BBFV=TVOL(10)
          ELSE
            BBFV=TVOL(2)
          ENDIF
          IF(BBFV.LT.0.)BBFV=0.
        ENDIF
        CTKFLG = .TRUE.
        BTKFLG = .TRUE.
C
      ELSE
C----------
C  OLD R6 FORM CLASS SECTION
C
C  GET FORM CLASS FOR THIS TREE.
C----------
        IREGN= 6
        CALL FORMCL(ISPC,IFOR,D,FC)
        IFC=IFIX(FC)
C----------
C  SET R6VOL PARAMETERS FOR CUBIC VOLUME
C----------
        TOP = TOPD(ISPC)
        TDIB = TOP*BARK
        NLOGS = 0.
        NLOGMS = 0.
        NLOGTW = 0.
        DBTBH = D-D*BARK
        IERR=0
        DO 130 IZERO=1,15
        TVOL(IZERO)=0.
  130   CONTINUE
        CTYPE=' '
        X0=0.
C----------
C  CALL R6VOL/BLMVOL TO COMPUTE CUBIC VOLUME.
C----------
        IF((VEQNNC(ISPC)(1:3).EQ.'616').OR.
     &    (VEQNNC(ISPC)(1:3).EQ.'632')) THEN
        CALL R6VOL(VEQNNC(ISPC),FORST,D,BARK*100.,IFC,TDIB,H,'F',TVOL,
     &             LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
          IF(DEBUG)WRITE(16,*)' AFTER R6VOL-VEQNNC(ISPC),FORST,D',
     &    ',BARK*100.,IFC,TOPDIB,H,TVOL,LOGVOL,NLOGS,LOGDIA,',
     &     'SCALEN,DBTBH,X01,CTYPE,IERR= ',VEQNNC(ISPC),FORST,D,
     &     BARK*100.,IFC,TOPDIB,H,TVOL,LOGVOL,NLOGS,LOGDIA,
     &     SCALEN,DBTBH,X01,CTYPE,IERR
        ELSE
          IF(DEBUG)WRITE(16,*)' before BLMVOL-TOPD(ISPC),BARK= ',
     &                          TOPD(ISPC),BARK
          CALL BLMVOL(VEQNNC(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &           LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,1,1,IERR)
          IF(DEBUG)WRITE(16,*)' AFTER BLMVOL-VEQNNC(ISPC),TOPD(ISPC),',
     &    'H,X01,D,IFC,TVOL,LOGDIA, LOGLEN,LOGVOL,LOGST,NLOGMS,',
     &    'NLOGTW,IERR= ',VEQNNB(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &               LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW
        ENDIF
C----------
C  SET RETURN VARIABLES.
C----------
        VN=TVOL(1)
        IF(VN.LT.0.)VN=0.
        VMAX=VN
        IF(D.LT.DBHMIN(ISPC) .OR. D.LT.TOPD(ISPC))THEN
          VM=0.
        ELSE
          VM=TVOL(4)
          IF(VM.LT.0.)VM=0.
        ENDIF
C----------
C  IF BF TOP IS DIFFERENT THAN CF TOP SET PARAMETERS FOR
C  BOARD FOOT VOLUME.
C----------
        IF(BFTOPD(ISPC) .NE. TOPD(ISPC)) THEN
          TOP = BFTOPD(ISPC)
          TDIB = TOP*BARK
          NLOGS = 0.
          NLOGMS = 0.
          NLOGTW = 0.
          DBTBH = D-D*BARK
          IERR=0
          DO 140 IZERO=1,15
          TVOL(IZERO)=0.
  140     CONTINUE
          CTYPE=' '
          X0=0.
C----------
C  CALL R6VOL/BLM TO COMPUTE BOARD VOLUME.
C----------
          IF((VEQNNB(ISPC)(1:3).EQ.'616').OR.
     &       (VEQNNB(ISPC)(1:3).EQ.'632')) THEN
            IF(DEBUG)WRITE(JOSTND,*)' CALLING BF R6VOL ARGS= ',
     &      IFOR,FORST,VEQNNB(ISPC),D,BARK*100.,IFC,TOPDIB,H,DBTBH

            CALL R6VOL(VEQNNB(ISPC),FORST,D,BARK*100.,IFC,TDIB,H,'F',
     &             TVOL,LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
            IF(DEBUG)WRITE(JOSTND,*)' AFTER BF R6VOL TVOL= ',TVOL
          ELSE
            IF(DEBUG)WRITE(16,*)' before BLMVOL-BFTOPD(ISPC),BARK= ',
     &      BFTOPD(ISPC),BARK
C
            CALL BLMVOL(VEQNNB(ISPC),BFTOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &                  LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,
     &                  1,1,IERR)
            IF(DEBUG)WRITE(16,*)' AFTER BLMVOL-VEQNNB(ISPC),',
     &      'BFTOPD(ISPC),H,X01,D,F,IFC,TVOL,LOGDIA, LOGLEN,LOGVOL,',
     &      'LOGST,NLOGMS,NLOGTW= ',VEQNNB(ISPC),BFTOPD(ISPC),H,
     &      X01,D,'F',IFC,TVOL,LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW
          ENDIF
        ENDIF
        IF(D.LT.BFMIND(ISPC))THEN
          BBFV=0.
        ELSE
          IF(METHB(ISPC).EQ.9) THEN
            BBFV=TVOL(10)
          ELSE
            BBFV=TVOL(2)
          ENDIF
          IF(BBFV.LT.0.)BBFV=0.
        ENDIF
        CTKFLG = .TRUE.
        BTKFLG = .TRUE.
      ENDIF
C
      IF(VN.LE.0.) THEN
        VM=0.
        BBFV=0.
        CTKFLG = .FALSE.
        BTKFLG = .FALSE.
      ENDIF
      RETURN
C
C----------
C  ENTER ANY OTHER CUBIC HERE
C----------
      ENTRY OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              CTKFLG,IT)
      VN=0.
      VMAX=0.
      VM=0.
      CTKFLG = .FALSE.
      RETURN
C
C----------
C  ENTER ANY OTHER BOARD HERE
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              BTKFLG,IT)
C----------
C  SET RETURN VALUES.
C----------
      BBFV=0.
      BTKFLG = .FALSE.
      RETURN
C
C----------
C  ENTRY POINT FOR SENDING VOLUME EQN NUMBER TO THE FVS-TO-NATCRZ ROUTINE
C----------
      ENTRY GETEQN(ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB)
      EQNC=VEQNNC(ISPC)
      EQNB=VEQNNB(ISPC)
      TDIBC=TOPD(ISPC)*BRATIO(ISPC,D,H)
      TDIBB=BFTOPD(ISPC)*BRATIO(ISPC,D,H)
      RETURN
C
      END
