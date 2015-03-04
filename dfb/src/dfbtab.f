      SUBROUTINE DFBTAB(CFTVOL)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **DFBTAB  DATE OF LAST REVISION  05/30/13
C----------
C
C  PRINTS OUT THE DOUGLAS-FIR BEETLE SUMMARY TABLE.
C
C  CALLED BY :
C     DFBMRT [DFB]
C
C  CALLS :
C     DFBIND  (SUBROUTINE)  [DFB]
C
C  PARAMETERS :
C     CFTVOL - ARRAY THAT HOLDS THE CUBIC FOOT VOLUME LOST DUE TO DFB
C              FOR EACH DBH CLASS.
C
C  LOCAL VARIABLES :
C     DCLASS - ARRAY THAT HOLDS THE DIAMETER CLASS HEADINGS THAT ARE
C              TO BE PRINTED IN THE SUMMARY TABLE.
C     I      - INDEX,  COUNTER.
C     TDEAD  - HOLDS THE TOTAL NUMBER OF DOUGLAS-FIR KILLED BY THE DFB
C              (TREES/ACRE).
C     TLIVE  - HOLDS THE TOTAL NUMBER OF LIVE DOUGLAS-FIR (TREES/ACRE).
C     DCNDX  - THE DBH CLASS OF THE CURRENT TREE RECORD.
C     TTOTL  - HOLDS THE TOTAL NUMBER OF LIVE TREES (TREES/ACRE).
C     TVOL   - HOLDS THE TOTAL CUBIC FOOT VOLUME LOST DUE TO THE DFB.
C     TOTGRN - ARRAY THAT HOLDS THE TOTAL LIVE TREES/ACRE FOR EACH DBH
C              CLASS IN THE STAND.
C
C  COMMON BLOCK VARIABLES USED :
C     DBH    - (ARRAYS)  INPUT
C     DEADDF - (DFBCOM)  INPUT
C     DFKILL - (DFBCOM)  INPUT
C     ICYC   - (CONTRL)  INPUT
C     ITRN   - (CONTRL)  INPUT
C     IY     - (CONTRL)  INPUT
C     IYOUT  - (DFBCOM)  INPUT
C     JODFB  - (DFBCOM)  INPUT
C     JODFBX - (DFBCOM)  INPUT
C     LINPRG - (DFBCOM)  INPUT/OUTPUT
C     LINV   - (DFBCOM)  INPUT/OUTPUT
C     LIVEDF - (DFBCOM)  INPUT
C     PREKLL - (DFBCOM)  INPUT
C     PROB   - (ARRAYS)  INPUT
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'DFBCOM.F77'
C

      INTEGER I, DCNDX

      REAL    TOTGRN(20), CFTVOL(20), TDEAD, TLIVE, TTOTL, TVOL

      CHARACTER*8 DCLASS(20)

      DATA DCLASS / ' 1 -  3',' 3 -  5',' 5 -  7',' 7 -  9',' 9 - 11',
     &              '11 - 13','13 - 15','15 - 17','17 - 19','19 - 21',
     &              '21 - 23','23 - 25','25 - 27','27 - 29','29 - 31',
     &              '31 - 33','33 - 35','35 - 37','37 - 39','39 - 40+' /

C
C     INITIALIZE TOTGRN
C
      DO 100 I = 1,20
         TOTGRN(I) = 0.0
  100 CONTINUE

C
C     BREAK PROGNOSIS PROB ARRAY INTO DBH CLASSES.
C
      DO 250 I = 1, ITRN
         CALL DFBIND (DBH(I), DCNDX)
         TOTGRN(DCNDX) = TOTGRN(DCNDX) + PROB(I)
  250 CONTINUE

C
C     PRINT DOUGLAS-FIR BEETLE SUMMARY TABLE HEADERS.
C
      WRITE (JODFB,500)
      WRITE (JODFB,510)

      IF (LINV .AND. LINPRG .AND. ICYC .EQ. 1)
     &   WRITE (JODFB,515) INT(PREKLL), IYOUT
C
C     TURN OFF OUTBREAK IN PROGRESS.
C
      LINV   = .FALSE.
      LINPRG = .FALSE.

C
C     PRINT TABLE HEADERS.
C
      WRITE (JODFB,520) IY(ICYC)
      WRITE (JODFB,525) DFKILL
      WRITE (JODFB,*)
      WRITE (JODFB,530)

  500 FORMAT (//,'             DOUGLAS-FIR BEETLE MORTALITY')
  510 FORMAT (1X,'---------------------------------------------------',
     &        '-------')
  515 FORMAT (1X,I4,' TREES WERE READ IN AS DEAD AFTER ',I1,' YEAR(S) ',
     &       'OF DFB MORTALITY.')
  520 FORMAT (1X,'YEAR OF THE OUTBREAK             : ',I5)
  525 FORMAT (1X,'PROJECTED MORTALITY (TREES/ACRE) : ',F5.1)
  530 FORMAT (1X,'             TOTAL         DF          DF     ',
     &        '     DF    ',/,
     &        1X,'           TREES/ACRE  TREES/ACRE  TREES/ACRE ',
     &        ' CU/FT VOL ',/,
     &        1X,'DBH CLASS    ALIVE       ALIVE       KILLED   ',
     &        '    LOST   ',/,
     &        1X,'---------  ----------  ----------  ---------- ',
     &        ' ----------')

C
C     IF USER WANTS POST PROCESSOR OUTPUT THEN PRINT THE YEAR TO THE
C     POST PROCESSOR FILE.
C
      IF (JODFBX .GT. 0) WRITE (JODFBX,540) IY(ICYC)
  540 FORMAT (I4)

C
C     INITIALIZE THE VARIABLES THAT KEEP THE TOTALS.
C
      TLIVE = 0.0
      TDEAD = 0.0
      TTOTL = 0.0
      TVOL  = 0.0

C
C     PRINT OUT SUMMARY TABLE INFORMATION AND CALCULATE TOTALS.
C
      DO 600 I = 1,20
         TOTGRN(I) = TOTGRN(I) - DEADDF(I)
         WRITE (JODFB,700) DCLASS(I), TOTGRN(I), LIVEDF(I),
     &                     DEADDF(I), CFTVOL(I)
C
C        PRINT POST PROCESSOR OUTPUT IF USER USED DFBECHO KEYWORD.
C
         IF (JODFBX .GT. 0) WRITE (JODFBX,700) DCLASS(I),
     &      TOTGRN(I), LIVEDF(I), DEADDF(I), CFTVOL(I)
         TLIVE = TLIVE + LIVEDF(I)
         TDEAD = TDEAD + DEADDF(I)
         TTOTL = TTOTL + TOTGRN(I)
         TVOL  = TVOL  + CFTVOL(I)
  600 CONTINUE

C
C     PRINT OUT THE SUMMARY TABLE TOTALS.
C
      WRITE (JODFB,710)
      WRITE (JODFB,720) TTOTL, TLIVE, TDEAD, TVOL

C
C     PRINT SUMMARY TOTALS TO POST PROCESSOR OUTPUT IF USER USED
C     DFBECHO KEYWORD.
C
      IF (JODFBX .GT. 0) THEN
         WRITE (JODFBX,710)
         WRITE (JODFBX,720) TTOTL, TLIVE, TDEAD, TVOL
         WRITE (JODFBX,*)
      ENDIF

  700 FORMAT (3X,A8,3X,F6.1,6X,F6.1,6X,F6.1,5X,F7.1)
  710 FORMAT (2X,'           ----------  ----------  ---------- ',
     &        ' ----------')
  720 FORMAT (14X,F6.1,6X,F6.1,6X,F6.1,5X,F7.1)


 1000 CONTINUE
      RETURN
      END
