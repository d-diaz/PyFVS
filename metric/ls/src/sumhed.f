      SUBROUTINE SUMHED
      use outcom_mod
      use prgprm_mod
      use plot_mod
      use screen_mod
      implicit none
C----------
C  **SUMHED--LS/M DATE OF LAST REVISION:  06/02/08
C----------
C  THIS SUBROUTINE WRITES A HEADER FOR THE SUMMARY OUTPUT ON THE
C  SCREEN.
C----------
COMMONS
C----------
      CHARACTER*7 FMT
      CHARACTER VVER*7,REV*10
      INTEGER I1,I2,ISTFNB,ISTLNB
      IF (.NOT.LSCRN) GOTO 1000
C----------
C  GET VARIANT NAME AND REVISION DATE.
C----------
      CALL VARVER (VVER)
      CALL REVISE (VVER,REV)
      IF(VVER(:2).EQ.'SM' .OR. VVER(:2).EQ.'SP' .OR. VVER(:2).EQ.'BP'
     & .OR. VVER(:2).EQ.'SF' .OR. VVER(:2).EQ.'LP')THEN
        WRITE(JOSCRN,1) VVER(:2),REV
    1   FORMAT(/T20,'CR-',A2,' FVS METRIC VARIANT -- RV:',A10/)
      ELSE
        WRITE(JOSCRN,2) VVER(:2),REV
    2   FORMAT(/T20,A2,' FVS-ONTARIO METRIC VARIANT -- RV:',A10/)
      ENDIF
C
      WRITE(JOSCRN,5) NPLT,MGMID
    5 FORMAT(/T10,'STAND = ',A26,'  MANAGEMENT CODE = ',A4/)
      I1=ISTFNB(ITITLE)
      IF (I1.GT.0) THEN
         I2=ISTLNB(ITITLE)
         WRITE (FMT,'(''(T'',I2.2,'',A)'')') (81-I2+I1)/2
         WRITE (JOSCRN,FMT) ITITLE(I1:I2)
      ENDIF
      WRITE (JOSCRN,10)
   10 FORMAT (/T17,'SUMMARY STATISTICS (BASED ON TOTAL STAND AREA)'
     >  /1X,76('-')/
     >  T8,'START OF SIMULATION PERIOD    REMOVALS/HA  ',4X,
     >  'AFTER TREATMENT GROWTH',/,T7,28('-'),1X,17('-'),1X,16('-'),
     >  ' CU  M',/, T7,'TREES',9X,'TOP',6X,'MERCH TREES MERCH SAWLG',
     >  9X,'TOP',6X,'PER YR',/,1X,'YEAR  /HA   BA SDI  HT  QMD ',
     >  'CU  M  /HA  CU  M CU  M  BA SDI  HT  QMD ACC MOR',/,1X,
     >  '---- ----- --- --- --- ---- ----- ----- ----- ----- ',
     >  '--- --- --- ---- --- ---')
 1000 CONTINUE
      RETURN
      END
