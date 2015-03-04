      SUBROUTINE MAICAL
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **MAICAL--SO   DATE OF LAST REVISION:  04/24/09
C----------
C  THIS SUBROUTINE CALCULATES THE MAI FOR THE STAND. IT IS CALLED
C  FROM CRATET.
C----------
C
      INCLUDE  'PLOT.F77'
C
      INCLUDE  'COEFFS.F77'
C
      INCLUDE  'CONTRL.F77'
C
      INCLUDE  'OUTCOM.F77'
C
      INCLUDE  'HTCAL.F77'
C
C----------
      LOGICAL DEBUG
      INTEGER ISPNUM(MAXSP),ISICD,IERR
      REAL SSSI,ADJMAI
C----------
C  INITIALIZE INTERNAL VARIABLES:
C
C  SPECIES ORDER:
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C----------
      DATA ISPNUM /
     & 119, 117, 202, 015, 264, 122, 108, 093, 101, 122,
     & 101, 015, 021, 101, 101, 101, 101, 101, 101, 101,
     & 746, 746, 746, 746, 746, 746, 746, 746, 746, 746,
     & 746, 202, 746/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'MAICAL',6,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE MAICAL  CYCLE =',I5)
C----------
C   RMAI IS FUNCTION TO CALCULATE ADJUSTED MAI.
C
C   IF SPECIES IS DF CONVERT COCHRAN SITE INDEX TO MCARDLE SITE
C   INDEX. IF SPECIES IS HEMLOCK CONVERT SITE INDEX TO ENGLISH
C   (SITE INDEX WAS PUBLISHED IN METRIC).
C----------
      IF (ISISP .EQ. 0) ISISP=3
      SSSI=SITEAR(ISISP)
      IF (SSSI .EQ. 0.) SSSI=140.0
      IF (ISISP .EQ. 3) SSSI= -43.78 + 2.16*SSSI
      IF (ISISP .EQ. 5) SSSI=SSSI*3.28
      ISICD=ISPNUM(ISISP)
      RMAI=ADJMAI(ISICD,SSSI,10.0,IERR)
C      RMAI=50.
      IF(RMAI .GT. 128.0)RMAI=128.0
      IF(DEBUG) WRITE(JOSTND,10)ICYC,RMAI
   10 FORMAT(' LEAVING SUBROUTINE MAICAL  CYCLE =',I5,5X,'RMAI =',F10.3)
      RETURN
      END
