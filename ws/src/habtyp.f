      SUBROUTINE HABTYP (KARD2,ARRAY2)
      use contrl_mod
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **HABTYP--WS   DATE OF LAST REVISION:  01/26/11
C----------
C
C     TRANSLATES HABITAT TYPE  CODE INTO A SUBSCRIPT, ITYPE, AND IF
C     KODTYP IS ZERO, THE ROUTINE RETURNS 0.
C
C----------
COMMONS
C----------
      INTEGER NR5,I,I2,I1,IHB
      PARAMETER (NR5=406)
      CHARACTER*8 R5HABT(NR5)
C
      REAL ARRAY2
      CHARACTER*10 KARD2
      LOGICAL DEBUG
      LOGICAL LPVCOD,LPVREF,LPVXXX
C----------
C  LOAD REGION 5 HABITAT TYPE ARRAY
C----------
      DATA (R5HABT(I),I=1,50)/
C 1-25
     &'43014   ', '43015   ', '43016   ', '43017   ', '43031   ',
     &'43061   ', '43062   ', '43063   ', '43064   ', '43065   ',
     &'43066   ', '43067   ', '43071   ', '43072   ', '43073   ',
     &'43074   ', '43075   ', '43076   ', '43106   ', '43153   ',
     &'43154   ', '43156   ', '43246   ', '43247   ', '43261   ',
C 26-50
     &'43262   ', '43263   ', '43264   ', '43265   ', '43266   ',
     &'43272   ', '43273   ', '43274   ', '43275   ', '43276   ',
     &'43282   ', '43284   ', '43285   ', '43287   ', '43288   ',
     &'43289   ', '43290   ', '43291   ', '43292   ', '43293   ',
     &'43294   ', '43304   ', '43325   ', '43327   ', '43328   '/
      DATA (R5HABT(I),I=51,100)/
C 51-75
     &'43329   ', '43351   ', '43352   ', '43451   ', '43500   ',
     &'43554   ', '43605   ', '43606   ', '43651   ', '43803   ',
     &'43811   ', '43872   ', '43883   ', '43905   ', '43911   ',
     &'43915   ', '43916   ', '43991   ', '43995   ', 'CCOCCO00',
     &'CCOCCO11', 'CCOCCO12', 'CCOCCO13', 'CCOCCO14', 'CCOCFW00',
C 76-100
     &'CCOCFW11', 'CCOCFW12', 'CCOCFW13', 'CCOCFW14', 'CCOCFW15',
     &'CCOCFW16', 'CCOCFW17', 'CCOCFW18', 'CD000000', 'CD0CCI00',
     &'CD0CCI11', 'CD0CPJ00', 'CD0CPJ11', 'CD0HAR00', 'CD0HAR11',
     &'CD0HBC00', 'CD0HBC11', 'CD0HBC12', 'CD0HGC00', 'CD0HGC11',
     &'CD0HGC12', 'CD0HGC13', 'CD0HGC14', 'CD0HGC15', 'CD0HGC16'/
      DATA (R5HABT(I),I=101,150)/
C 101-125
     &'CD0HGC17', 'CD0HMA00', 'CD0HMA11', 'CD0HMA12', 'CD0HMA13',
     &'CD0HOB00', 'CD0HOB11', 'CD0HOB12', 'CD0HOB13', 'CD0HOL00',
     &'CD0HOL11', 'CD0HOL12', 'CD0HOL13', 'CD0HOO00', 'CD0HOO11',
     &'CD0HOO12', 'CD0HT000', 'CD0HT011', 'CD0HT012', 'CD0SM000',
     &'CD0SM011', 'CD0SOH00', 'CD0SOH12', 'CD0SOH13', 'CPJ00000',
C 126-150
     &'CPJCCI00', 'CPJCCI11', 'CPJCCI12', 'CPJCCI13', 'CPJCCI14',
     &'CPJCFW11', 'CPJCFW12', 'CPJGFI00', 'CPJGFI11', 'CPJGFI12',
     &'CPJSOD11', 'CPL00000', 'CPLSOH00', 'CPLSOH11', 'CPLSOH12',
     &'CPLST000', 'CPLST011', 'CPS00000', 'CPSCPL00', 'CPSCPL11',
     &'CPSCPL12', 'CPSCPW00', 'CPSCPW11', 'CPSHGC00', 'CPSHGC11'/
      DATA (R5HABT(I),I=151,200)/
C 151-175
     &'CPW00000', 'CPWCD000', 'CPWCD011', 'CPWCFW00', 'CPWCFW11',
     &'CPWCPL00', 'CPWCPL11', 'CPWCPS00', 'CPWCPS11', 'HT000000',
     &'HT0CCI00', 'HT0CCI11', 'HT0CCO00', 'HT0CCO11', 'HT0CCO12',
     &'HT0CCO13', 'HT0CCO14', 'HT0CCO15', 'HT0CCO16', 'HT0CCO17',
     &'HT0CCO18', 'HT0CCO19', 'HT0HBC00', 'HT0HBC11', 'HT0HBC12',
C 176-200
     &'HT0HGC00', 'HT0HGC11', 'HT0HGC12', 'HT0HGC13', 'HT0HGC14',
     &'HT0HGC15', 'HT0HGC16', 'HT0HM000', 'HT0HM011', 'HT0HM012',
     &'HT0HM013', 'HT0HOB00', 'HT0HOB11', 'HT0HOL00', 'HT0HOL11',
     &'HT0HOL12', 'HT0HOL13', 'HT0HOL14', 'HT0HOL15', 'HT0HOL16',
     &'HT0SD000', 'HT0SD011', 'HT0SD012', 'HT0SEH12', 'HT0SEH13'/
      DATA (R5HABT(I),I=201,250)/
C 201-225
     &'HT0SM000', 'HT0SM011', 'HT0SOH00', 'HT0SOH11', 'HT0SSG12',
     &'HT0SSG13', 'HT0SEH00', 'HT0SEH11', 'HT0SSG00', 'HT0SSG11',
     &'CC0311  ', 'CPJGBW11', 'CPJGNG11', 'CPJSAM11', 'CPJSAM12',
     &'CPJSBB11', 'CPJSBB12', 'CPJSBB13', 'CPJSBB14', 'CPJSBB15',
     &'CPJSBB16', 'CPJSBB17', 'CPJSBB18', 'CPJSBB19', 'CPJSBB20',
C 226-250
     &'CPJSBB21', 'CPJSBB23', 'CPJSMC11', 'CPJSMC12', 'CPJSMC13',
     &'CPJSOH11', 'CPJSSB11', 'CPJSSS12', 'CPJSSY11', 'CPOSMP11',
     &'CPOSSY11', 'CPPSAM11', 'CPPSAM12', 'CPPSAM13', 'CPPSAM14',
     &'CPPSAM15', 'CPPSAM16', 'CPPSBB11', 'CPPSBB12', 'CPPSBB13',
     &'CPPSBB14', 'CPPSBB15', 'CPPSBB16', 'CPPSBB17', 'CPPSBB18'/
      DATA (R5HABT(I),I=251,300)/
C 251-275
     &'CPPSBB19', 'CPPSBB20', 'CPPSBB21', 'CPPSBB22', 'CPPSSB11',
     &'DC0811  ', 'DC0812  ', 'DC0813  ', 'DC0911  ', 'DH0711  ',
     &'PC0611  ', 'QS0111  ', 'WC0911  ', 'WC0912  ', 'WC0913  ',
     &'WC0914  ', 'WC0915  ', 'WC0916  ', 'WC0917  ', 'CC0411  ',
     &'DC1011  ', 'DC1012  ', 'DC1013  ', 'DC1014  ', 'DC1015  ',
C 276-300
     &'DC1016  ', 'DC1017  ', 'DC1018  ', 'DC1019  ', 'DS0911  ',
     &'PG0611  ', 'PG0612  ', 'PG0613  ', 'PG0614  ', 'PS0911  ',
     &'WC1011  ', 'WC1012  ', 'WC1013  ', 'CX000000', 'CX0D0000',
     &'CX0FBB11', 'CX0FFS11', 'CX0FRE11', 'CX0FTP11', 'CX0FWS11',
     &'CX0GCR11', 'CX0HAW11', 'CX0HDP00', 'CX0HDP13', 'CX0HDP14'/
      DATA (R5HABT(I),I=301,350)/
C 301-325
     &'CX0HMB12', 'CX0HOL00', 'CX0HOL15', 'CX0HOL16', 'CX0HOL17',
     &'CX0HT000', 'CX0HT012', 'CX0HT013', 'CX0HT011', 'CX0HT014',
     &'CX0M0000', 'CX0R0000', 'CX0SAM12', 'CX0SE000', 'CX0SE011',
     &'CX0SE012', 'CX0SE013', 'CX0SE014', 'CX0SHN12', 'CX0SLS11',
     &'CX0SMA11', 'CX0SMA12', 'CX0SMM00', 'CX0SMM11', 'CX0SMM12',
C 326-350
     &'CX0SSS13', 'CX0W0000', 'CX0SDA11', 'RS0511  ', 'WC0413  ',
     &'JC0111  ', 'JC0112  ', 'MC0211  ', 'PS0811  ', 'PS0812  ',
     &'PS0813  ', 'QC0211  ', 'QC0212  ', 'RC0011  ', 'RC0331  ',
     &'RC0421  ', 'RC0511  ', 'RC0512  ', 'RC0513  ', 'RC0611  ',
     &'RC0612  ', 'RC0613  ', 'RF0411  ', 'RF0412  ', 'RS0114  '/
      DATA (R5HABT(I),I=351,400)/
C 351-375
     &'WC0711  ', 'WC0712  ', 'CD0SOH11', 'CN00000 ', 'CN00011 ',
     &'CNF0111 ', 'CNF0211 ', 'CNF0311 ', 'CNHB011 ', 'CNHT011 ',
     &'CPPSSS11', 'HOD00000', 'HODGA000', 'HODGA011', 'HODGA012',
     &'HODGA013', 'HODGA014', 'HODGA015', 'HODGA016', 'HODGA017',
     &'HODGA018', 'HODGA019', 'HODGA020', 'HODGA021', 'HODGA022',
C 375-400
     &'HODHOI00', 'HODHOI11', 'SA000000', 'SA0SB000', 'SA0SBS00',
     &'SA0SCC00', 'SA0SCH00', 'SA0SCT00', 'SA0SCW00', 'SA0SMB00',
     &'SA0SME00', 'SB0SSW00', 'SBM00000', 'SCH00000', 'SMB00000',
     &'SME00000', 'SOC00000', 'SOI00000', 'SOISCL00', 'SOISOC00',
     &'SOISOS00', 'SOS00000', 'SOSSA000', 'SOSSBM00', 'SOSSCH00'/
      DATA (R5HABT(I),I=401,NR5)/
C 401-NR5
     &'SOSSCL00', 'SR000000', 'SR0SA000', 'SSC00000', 'SSCSB000',
     &'SSCSSB00'/
C
      LPVREF=.FALSE.
      LPVCOD=.FALSE.
      LPVXXX=.FALSE.
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HABTYP',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,*)
     &'ENTERING HABTYP CYCLE,KODTYP,KODFOR,KARD2,ARRAY2,CPVREF= ',
     &ICYC,KODTYP,KODFOR,KARD2,ARRAY2,CPVREF
C----------
C  DETERMINE IF A CODE WAS ENTERED
C----------
      I1=0
      I2=0
      DO 20 I=1,10
         IF (KARD2(I:I).NE.' ') THEN
            IF (I1.EQ.0) I1=I
         ELSE
            IF (I1.GT.0.AND. I2.EQ.0) I2=I-1
         ENDIF
 20   CONTINUE
      IF (I2.EQ.0 .AND. I1.GT.0) I2=10
C
      IF (I2-I1.GT.0) THEN
C----------
C  IF REFERENCE CODE IS NON-ZERO THEN MAP PV CODE/REF. CODE TO
C  FVS HABITAT TYPE/ECOCLASS CODE. THEN PROCESS FVS CODE
C----------
        IF(CPVREF.NE.'          ') THEN
          CALL PVREF5(KARD2,ARRAY2,LPVCOD,LPVREF)
          ICL5=0
          IF((LPVCOD.AND.LPVREF).AND.
     &        (KARD2.EQ.'          ').AND.(KARD2.NE.'UNKNOWN   '))THEN
            CALL ERRGRO(.TRUE.,34)
            LPVXXX=.TRUE.
            PCOMX='2NDPASS '
          ELSEIF((.NOT.LPVCOD).AND.(.NOT.LPVREF).AND.
     &           (KARD2.NE.'UNKNOWN   '))THEN
            CALL ERRGRO(.TRUE.,33)
            CALL ERRGRO(.TRUE.,32)
            LPVXXX=.TRUE.
             PCOMX='2NDPASS '
         ELSEIF((.NOT.LPVREF).AND.LPVCOD.AND.
     &           (KARD2.NE.'UNKNOWN   '))THEN
            CALL ERRGRO(.TRUE.,32)
            LPVXXX=.TRUE.
            PCOMX='2NDPASS '
          ELSEIF((.NOT.LPVCOD).AND.LPVREF.AND.
     &           (KARD2.NE.'UNKNOWN   '))THEN
            CALL ERRGRO(.TRUE.,33)
            LPVXXX=.TRUE.
            PCOMX='2NDPASS '
          ENDIF
        ENDIF
C----------
C  DIGEST HABITAT TYPE CODE
C----------
        IF(DEBUG)WRITE(JOSTND,*)'DIGESTING HABITAT CODE: KODFOR,',
     &  'KODTYP= ',KODFOR,KODTYP
        CALL CRDECD(KODTYP,R5HABT(1),NR5,ARRAY2,KARD2)
        IF(DEBUG)WRITE(JOSTND,*)'AFTER R5 DECODE,KODTYP= ',KODTYP
        IF(KODTYP .LT. 0) KODTYP=0
        ITYPE=KODTYP
      ELSE
        KODTYP=0
        ITYPE=0
      ENDIF
C----------
C  IF NO MATCH WAS FOUND, TREAT IT AS A SEQUENCE NUMBER.
C----------
      IF(KODTYP .EQ. 0)THEN
        IF(DEBUG)WRITE(JOSTND,*)'EXAMINING FOR INDEX, ARRAY2= ',ARRAY2
        IHB = IFIX(ARRAY2)
        IF(IHB.LE.NR5)THEN
          KODTYP=IHB
          ITYPE=IHB
        ENDIF
      ENDIF
C----------
C  FINISH FINAL SETTINGS OR SET DEFAULT CONDITIONS
C----------
      IF(KODTYP .NE. 0)THEN
        ICL5=KODTYP
        KARD2=R5HABT(ITYPE)
        IF(LSTART)WRITE(JOSTND,311) KARD2
  311   FORMAT(/,T12,'HABITAT TYPE CODE USED IN THIS PROJECTION IS ',
     &  A8)
      ELSE
        IF((LSTART).AND.(.NOT.LPVXXX).AND.(PCOMX.NE.'2NDPASS '))
     &  CALL ERRGRO (.TRUE.,14)
          KARD2='UNKNOWN   '
          PCOM='UNKNOWN '
          PCOMX='2NDPASS '
          ICL5=0
      ENDIF
C
      IF(DEBUG)WRITE(JOSTND,*)'LEAVING HABTYP KODTYP,ITYPE,ICL5,KARD2='
     &,KODTYP,ITYPE,ICL5,KARD2
C
      RETURN
      END
