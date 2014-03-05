        SUBROUTINE VARVOL
        IMPLICIT NONE
C----------
C  **VARVOL--CA    DATE OF LAST REVISION:   03/20/13
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 8)
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C
C----------
C
      INTEGER IR,I1,I2,IFIASP,IFC,IREGN,I02,I03,I04,I05,ISPC,INTFOR
      INTEGER IERR,IZERO,I01,IT,ITRNC,LOGST
      REAL BBFV,VM,VN,DBT,X01,X02,X03,X04,X05,X06,X07,X08,X09,X010
      REAL X011,X012,FC,DBTBH,TVOL1,TVOL4,X0,TDIBB,TDIBC,BRATIO
      REAL VMAX,BARK,H,D,TOPDIB
C
      REAL LOGLEN(20),BOLHT(21),SCALEN(20),TVOL(15)
      REAL NLOGS
      REAL NLOGMS,NLOGTW
      INTEGER ERRFLAG
      LOGICAL DEBUG,TKILL,CTKFLG,BTKFLG,LCONE
      CHARACTER*10 VOLEQ
      CHARACTER CTYPE*1,FORST*2,HTTYPE,PROD*2
      CHARACTER*10 EQNC,EQNB
C
C SPECIES ORDER IN CA VARIANT:
C  1=PC  2=IC  3=RC  4=WF  5=RF  6=SH  7=DF  8=WH  9=MH 10=WB
C 11=KP 12=LP 13=CP 14=LM 15=JP 16=SP 17=WP 18=PP 19=MP 20=GP
C 21=JU 22=BR 23=GS 24=PY 25=OS 26=LO 27=CY 28=BL 29=EO 30=WO
C 31=BO 32=VO 33=IO 34=BM 35=BU 36=RA 37=MA 38=GC 39=DG 40=FL
C 41=WN 42=TO 43=SY 44=AS 45=CW 46=WI 47=CN 48=CL 49=OH
C----------
C  NATIONAL CRUISE SYSTEM ROUTINES (METHOD = 0)
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
      DBT = D*(1-BARK)
C----------
C  FOR REGION 5 FORESTS, BRANCH TO R5 LOGIC.
C----------
      IF(IFOR .LE. 5) GO TO 100
C----------
C  R6 VOLUME LOGIC
C
C----------
      DO 103 IZERO=1,15
      TVOL(IZERO)=0.
  103 CONTINUE
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
C  CONSTANT CHARACTER ARGUMENTS  --  CF SECTION
C----------
      CTYPE=' '
      PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
      I1= 1
      IREGN= 6
      IF((VEQNNC(ISPC)(4:4).EQ.'F'))THEN
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
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
      ELSE
C----------
C  OLD R6 FORM CLASS SECTION
C  GET FORM CLASS FOR THIS TREE.
C----------
        CALL FORMCL(ISPC,IFOR,D,FC)
        IFC=IFIX(FC)
        NLOGS = 0.
        NLOGMS = 0.
        NLOGTW = 0.
        DBTBH = D-D*BARK
C----------
C  CALL R6VOL/BLM TO COMPUTE CUBIC VOLUME.
C----------
        IF((VEQNNC(ISPC)(1:3).EQ.'616').OR.
     &    (VEQNNC(ISPC)(1:3).EQ.'632')) THEN
        CALL R6VOL(VEQNNC(ISPC),FORST,D,BARK*100.,IFC,TOPDIB,H,'F',TVOL,
     &  LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X01,CTYPE,IERR)
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
      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)).OR.
     &  (BFSTMP(ISPC).NE.STMP(ISPC)) .OR.
     &  (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 101 IZERO=1,15
        TVOL(IZERO)=0.
  101   CONTINUE
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
C  CONSTANT CHARACTER ARGUMENTS  --  BOARD FT
C----------
        CTYPE=' '
        PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
        IREGN= 6
        IF((VEQNNB(ISPC)(4:4).EQ.'F'))THEN
C
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,
     &    BFSTMP(ISPC),D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,
     &    X08,X09,I02,DBT,BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,
     &    TVOL,I03,X010,X011,I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,
     &    IERR)
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
        ELSE
C----------
C  OLD R6 FORM CLASS SECTION
C  GET FORM CLASS FOR THIS TREE.
C----------
          CALL FORMCL(ISPC,IFOR,D,FC)
          IFC=IFIX(FC)
          NLOGS = 0.
          NLOGMS = 0.
          NLOGTW = 0.
          DBTBH = D-D*BARK
          IREGN= 6
C----------
C  CALL R6VOL/BLMVOL TO COMPUTE BOARD VOLUME.
C----------
          IF((VEQNNB(ISPC)(1:3).EQ.'616').OR.
     &       (VEQNNB(ISPC)(1:3).EQ.'632')) THEN
            CALL R6VOL(VEQNNB(ISPC),FORST,D,BARK*100.,IFC,TOPDIB,H,
     &      'F',TVOL,LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
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
          TVOL(1)=TVOL1
          TVOL(4)=TVOL4
        ENDIF
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
C
C
  100 CONTINUE
C----------
C  SET PARAMETERS & CALL PROFILE OR R5HARV TO COMPUTE R5 VOLUMES.
C----------
      DO 105 IZERO=1,15
      TVOL(IZERO)=0.
  105 CONTINUE
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
C  CONSTANT CHARACTER ARGUMENTS  --  CU FT SECTION
C----------
      CTYPE=' '
      PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
      I1= 1
      IREGN= 5
      IF(VEQNNC(ISPC)(4:6) .EQ. 'WO2')THEN
C
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &   ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &   DBT,BARK

        CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &  HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &  LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
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
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
      ELSE
        IF(DEBUG)WRITE(JOSTND,*)' CALLING R5HARV CF ISPC,VEQNNC(ISPC)',
     &  'D,H,TOPDIB,I1= ',ISPC,VEQNNC(ISPC),D,H,TOPDIB,I1
        CALL R5HARV(VEQNNC(ISPC),D,H,TOPDIB,TVOL,I1,I1,IERR)
        IF(DEBUG)WRITE(JOSTND,*)' AFTER R5HARV CF TVOL= ',TVOL
      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE OR R5HARV AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)).OR.
     &   (BFSTMP(ISPC).NE.STMP(ISPC)).OR.
     &   (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 104 IZERO=1,15
        TVOL(IZERO)=0.
  104   CONTINUE
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
        IREGN= 5
C
        IF(VEQNNB(ISPC)(4:6).EQ.'WO2')THEN
C
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,I1,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE(IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,BFSTMP(ISPC)
     &    ,D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,
     &    BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,
     &    I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
        ELSE
          IF(DEBUG)WRITE(JOSTND,*)' CALLING R5HARV BF ISPC,R5EQN,D,H,TOP
     &    DIB,I1= ',ISPC,VEQNNB(ISPC),D,H,TOPDIB,I1
          CALL R5HARV(VEQNNB(ISPC),D,H,TOPDIB,TVOL,I1,I1,IERR)
          IF(DEBUG)WRITE(JOSTND,*)' AFTER R5HARV CF TVOL= ',TVOL
        ENDIF
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
      RETURN
C
C
C----------
C  ENTER ANY OTHER CUBIC HERE
C----------
      ENTRY OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              CTKFLG,IT)
C
      VN=0.
      VMAX=0.
      VM=0.
      CTKFLG = .FALSE.
      RETURN
C
C
C----------
C  ENTER ANY OTHER BOARD HERE.
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              BTKFLG,IT)
      BBFV=0.
      BTKFLG = .FALSE.
      RETURN
C
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
