      SUBROUTINE MAICAL
      use htcal_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  **MAICAL--TT   DATE OF LAST REVISION:  09/21/11
C----------
C  THIS SUBROUTINE CALCULATES THE MAI FOR THE STAND. IT IS CALLED
C  FROM CRATET.
C----------
C
      INCLUDE  'OUTCOM.F77'
C
C----------
      LOGICAL DEBUG
      INTEGER ISPNUM(MAXSP),ISICD,IERR
      REAL SSSI,ADJMAI
C----------
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
C----------
C  INITIALIZE INTERNAL VARIABLES:
C----------
      DATA ISPNUM/
     & 101, 101, 202, 101, 093, 746, 108, 093, 019, 122,
     & 101, 101, 746, 746, 101, 746, 101, 101/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'MAICAL',6,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE MAICAL  CYCLE =',I5)
C-------
C   RMAI IS FUNCTION TO CALCULATE ADJUSTED MAI.
C-------
      IF (ISISP .EQ. 0) ISISP=3
      SSSI=SITEAR(ISISP)
      IF (SSSI .EQ. 0.) SSSI=140.0
      ISICD=ISPNUM(ISISP)
      RMAI=ADJMAI(ISICD,SSSI,10.0,IERR)
      IF(RMAI .GT. 128.0)RMAI=128.0
      IF(DEBUG) WRITE(JOSTND,10)ICYC,RMAI
   10 FORMAT(' LEAVING SUBROUTINE MAICAL  CYCLE =',I5,5X,'RMAI =',F10.3)
C
      RETURN
      END
