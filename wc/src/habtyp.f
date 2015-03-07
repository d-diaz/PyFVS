      SUBROUTINE HABTYP (KARD2,ARRAY2)
      use contrl_mod
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **HABTYP--WC   DATE OF LAST REVISION:  01/25/2011
C----------
C
C     TRANSLATES HABITAT TYPE  CODE INTO A SUBSCRIPT, ITYPE, AND IF
C     KODTYP IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C----------
COMMONS
C----------
      INTEGER NPA,I,IHB
      PARAMETER (NPA=139)
      REAL ARRAY2
      CHARACTER*10 KARD2
      CHARACTER*8 PCOML(NPA)
      LOGICAL DEBUG
      LOGICAL LPVCOD,LPVREF,LPVXXX
C----------
      DATA (PCOML(I),I=1,75)/
C 1-25
     &'CAF211  ', 'CAF311  ', 'CAG211  ', 'CAG311  ', 'CAG312  ',
     &'CAS211  ', 'CAS411  ', 'CDC711  ', 'CDC712  ', 'CDC713  ',
     &'CDS211  ', 'CDS212  ', 'CDS213  ', 'CDS641  ', 'CFC251  ',
     &'CFC311  ', 'CFF152  ', 'CFF153  ', 'CFF154  ', 'CFF250  ',
     &'CFF253  ', 'CFF312  ', 'CFF450  ', 'CFM111  ', 'CFS110  ',
C 26-50
     &'CFS151  ', 'CFS152  ', 'CFS154  ', 'CFS216  ', 'CFS221  ',
     &'CFS222  ', 'CFS223  ', 'CFS224  ', 'CFS225  ', 'CFS226  ',
     &'CFS229  ', 'CFS230  ', 'CFS231  ', 'CFS251  ', 'CFS252  ',
     &'CFS253  ', 'CFS254  ', 'CFS255  ', 'CFS256  ', 'CFS257  ',
     &'CFS258  ', 'CFS259  ', 'CFS260  ', 'CFS351  ', 'CFS352  ',
C 51-75
     &'CFS550  ', 'CFS551  ', 'CFS552  ', 'CFS554  ', 'CFS555  ',
     &'CFS651  ', 'CFS652  ', 'CFS653  ', 'CFS654  ', 'CHC212  ',
     &'CHC213  ', 'CHF111  ', 'CHF123  ', 'CHF124  ', 'CHF125  ',
     &'CHF133  ', 'CHF134  ', 'CHF135  ', 'CHF151  ', 'CHF221  ',
     &'CHF222  ', 'CHF250  ', 'CHF321  ', 'CHF421  ', 'CHM121  '/
      DATA (PCOML(I),I=76,139)/
C 76-100
     &'CHS111  ', 'CHS113  ', 'CHS114  ', 'CHS124  ', 'CHS125  ',
     &'CHS126  ', 'CHS127  ', 'CHS128  ', 'CHS129  ', 'CHS130  ',
     &'CHS135  ', 'CHS140  ', 'CHS141  ', 'CHS223  ', 'CHS224  ',
     &'CHS251  ', 'CHS325  ', 'CHS326  ', 'CHS327  ', 'CHS328  ',
     &'CHS351  ', 'CHS352  ', 'CHS353  ', 'CHS354  ', 'CHS355  ',
C 101-125
     &'CHS511  ', 'CHS513  ', 'CHS522  ', 'CHS523  ', 'CHS524  ',
     &'CHS611  ', 'CHS612  ', 'CHS613  ', 'CHS614  ', 'CHS615  ',
     &'CHS625  ', 'CHS626  ', 'CMF250  ', 'CMF251  ', 'CMS114  ',
     &'CMS210  ', 'CMS216  ', 'CMS218  ', 'CMS221  ', 'CMS223  ',
     &'CMS241  ', 'CMS244  ', 'CMS245  ', 'CMS246  ', 'CMS250  ',
C 126-139
     &'CMS251  ', 'CMS252  ', 'CMS253  ', 'CMS254  ', 'CMS255  ',
     &'CMS350  ', 'CMS351  ', 'CMS352  ', 'CMS353  ', 'CMS450  ',
     &'CMS612  ', 'CWF211  ', 'CWS521  ', 'CWS522  '/
C
      LPVREF=.FALSE.
      LPVCOD=.FALSE.
      LPVXXX=.FALSE.
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HABTYP',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,*)
     &'ENTERING HABTYP CYCLE,KODTYP,KODFOR,KARD2,ARRAY2= ',
     &ICYC,KODTYP,KODFOR,KARD2,ARRAY2
C----------
C  IF REFERENCE CODE IS NON-ZERO THEN MAP PV CODE/REF. CODE TO
C  FVS HABITAT TYPE/ECOCLASS CODE. THEN PROCESS FVS CODE
C----------
      IF(CPVREF.NE.'          ') THEN
        CALL PVREF6(KARD2,ARRAY2,LPVCOD,LPVREF)
        ICL5=0
        IF(DEBUG)WRITE(JOSTND,*)'AFTER PVREF KARD2,ARRAY2= ',
     &  KARD2,ARRAY2
        ICL5=0
        IF(DEBUG)WRITE(JOSTND,*)'AFTER PVREF KARD2,ARRAY2= ',
     &  KARD2,ARRAY2
        IF((LPVCOD.AND.LPVREF).AND.
     &      (KARD2.EQ.'          '))THEN
          CALL ERRGRO(.TRUE.,34)
          ITYPE=52
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.(.NOT.LPVREF))THEN
          CALL ERRGRO(.TRUE.,33)
          CALL ERRGRO(.TRUE.,32)
          ITYPE=52
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVREF).AND.LPVCOD)THEN
          CALL ERRGRO(.TRUE.,32)
          ITYPE=52
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.LPVREF)THEN
          CALL ERRGRO(.TRUE.,33)
          ITYPE=52
          LPVXXX=.TRUE.
          GO TO 30
        ENDIF
      ENDIF
C----------
C  DECODE HABITAT TYPE/PLANT ASSOCIATION FIELD.
C----------
      CALL HBDECD (KODTYP,PCOML(1),NPA,ARRAY2,KARD2)
      IF(DEBUG)WRITE(JOSTND,*)'AFTER HAB DECODE,KODTYP= ',KODTYP
      IF (KODTYP .LE. 0) GO TO 20
C
      PCOM = PCOML(KODTYP)
      ITYPE=KODTYP
      IF(LSTART)WRITE(JOSTND,10) PCOM
   10 FORMAT(/,T12,'PLANT ASSOCIATION CODE USED IN THIS',
     &' PROJECTION IS ',A8)
      GO TO 40
C----------
C  NO MATCH WAS FOUND, TREAT IT AS A SEQUENCE NUMBER.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'EXAMINING FOR INDEX, ARRAY2= ',ARRAY2
      IHB = IFIX(ARRAY2)
      IF(IHB.GT.0 .AND. IHB.LE.NPA)THEN
        KODTYP=IHB
        ITYPE=IHB
        PCOM = PCOML(KODTYP)
        GO TO 40
      ELSE
C----------
C  DEFAULT CONDITIONS --- PA = CFS551
C----------
        ITYPE=52
        GO TO 30
      ENDIF
C
   30 CONTINUE
      IF(.NOT.LPVXXX)CALL ERRGRO(.TRUE.,14)
      KODTYP=ITYPE
      PCOM = PCOML(KODTYP)
      IF(LSTART)WRITE(JOSTND,10) PCOM
C
   40 CONTINUE
      ICL5=KODTYP
      KARD2=PCOM
C
      IF(DEBUG)WRITE(JOSTND,*)'LEAVING HABTYP KODTYP,ITYPE,ICL5,KARD2',
     &' PCOM =',KODTYP,ITYPE,ICL5,KARD2,PCOM
C
      RETURN
      END
