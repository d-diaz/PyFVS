      SUBROUTINE DFBWIN(LDFBGO)
      use contrl_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **DFBWIN  DATE OF LAST REVISION:  05/30/13
C----------
C
C  DOUGLAS-FIR BEETLE WINDTHROW MODEL.
C
C  CALLED BY :
C     GRADD  [PROGNOSIS]
C
C  CALLS :
C     OPFIND  (SUBROUTINE)   [PROGNOSIS]
C     OPGET   (SUBROUTINE)   [PROGNOSIS]
C     OPDONE  (SUBROUTINE)   [PROGNOSIS]
C     OPREDT  (SUBROUTINE)   [PROGNOSIS]
C     OPINCR  (SUBROUTINE)   [PROGNOSIS]
C
C  PARAMETERS :
C     LDFBGO - LOGICAL VARIABLE THAT IS .TRUE. WHEN THERE IS GOING TO
C              BE A DFB OUTBREAK IN THIS STAND IN THIS CYCLE.  (INPUT)
C
C  LOCAL VARIABLES :
C     CRASH  - USER DEFINED PROPORTION OF ELIGIBLE TREES THAT CAN BE
C              WINDTHROWN.
C     DF9KIL - TOTAL NUMBER OF DOUGLAS-FIR TREES/ACRE WITH A DBH >= 9
C              INCHES THAT WERE WINDTHROWN.
C     ELIGBL - ARRAY THAT HOLDS THE NUMBER OF TREES/ACRE ELIGIBLE FOR
C              WINDTHROW FOR EACH TREE SPECIES.
C     IACTK  - HOLDS THE OPTION PROCESSOR CODE FOR PARAMETER RETRIEVAL.
C              USED IN CALLS TO OPGET.
C     I,J    - INDEXES.
C     I1,I2  - INDEXES FOR THE INDEX ARRAY IND1.  I1 IS THE STARTING
C              INDEX FOR A SPECIES IN ARRAY IND1.  I2 IS THE ENDING
C              INDEX FOR A SPECIES IN ARRAY IND1.
C     ISPI   - TREE SPECIES INDEX.
C     KDT    - HOLDS THE DATE THE ACTIVITY (WINDTHROW) IS SCHEDULED.
C              RETURNED FROM OPTION PROCESSOR ROUTINE OPGET.
C     MYACT  - HOLDS THE OPTION PROCESSOR CODES FOR DFB EVENTS.
C              USED IN CALLS TO OPFIND.
C     NPS    - THE NUMBER OF PARAMETERS RETURNED FROM OPTION PROCESSOR
C              ROUTINE OPGET.
C     NREDTS - THE NUMBER OF ACTIVITIES THAT WERE RESCHEDULED.  RETURNED
C              FROM THE OPTION PROCESSOR ROUTINE OPREDT.
C     NTODO  - VALUE RETURNED FROM OPFIND THAT IS GREATER THEN 1 IF
C              THERE IS WINDTHROW SCHEDULED FOR THIS CYCLE.
C     PRMS   - THE PARAMETERS THAT ARE RETURNED FROM OPTION PROCESSOR
C              ROUTINE OPGET.
C     SPCNUM - THE NUMBER OF DIFFERENT TREE SPECIES THAT ARE IN THE
C              STAND.
C     TELIG  - TOTAL NUMBER OF TREES/ACRE ELIGIBLE FOR WINDTHROW.
C     THRESH - USER DEFINED MINIMUM DENSITY (TREES/ACRE) NECESSARY FOR
C              WINDTHROW TO OCCUR.
C     TOTKLL - TOTAL NUMBER OF TREES/ACRE THAT ARE WINDTHROWN.
C     TOTSUC - TOTAL FOR ARRAY OF RELATIVE SUSCEPTIBILITY OF TREE
C              SPECIES TO WINDTHROW (WINSUC).
C
C  COMMON BLOCK VARIABLES USED :
C     DBH    - (ARRAYS)  INPUT
C     HT     - (ARRAYS)  INPUT
C     ICYC   - (CONTRL)  INPUT
C     IDFSPC - (DFBCOM)  INPUT
C     IFVSSP - (DFBCOM)  INPUT
C     IND1   - (ARRAYS)  INPUT
C     ISCT   - (CONTRL)  INPUT
C     IY     - (CONTRL)  INPUT
C     JODFB  - (DFBCOM)  INPUT
C     MAXSP  - (PRGPRM)  INPUT
C     MWINHT - (DFBCOM)  INPUT
C     NCYC   - (CONTRL)  INPUT
C     OKILL  - (DFBCOM)  OUTPUT
C     PCT    - (ARRAYS)  INPUT
C     PROB   - (ARRAYS)  INPUT
C     PRPMRT - (DFBCOM)  OUTPUT
C     ROWDOM - (DFBCOM)  INPUT
C     WINSUC - (DFBCOM)  INPUT
C     WK2    - (ARRAYS)  OUTPUT
C     WORKIN - (DFBCOM)  OUTPUT
C
C REVISION HISTORY:
C   06-AUG-2001 LANCE R. DAVID (FHTET)
C     CORRECTED ARGUMENTS TYPES IN CALL TO OPFIND.
C     (PREVIOUS REVISION DATE WAS 12/05/95)
C   26-SEP-2002 Lance R. David (FHTET)
C     Added debug statements.
C   26-JAN-2010 Lance R. David (FHTET)
C     Changed MYACT to MYACT(1) in call to OPREDT (from Don Robinson, ESSA).
C-------------------------------------------------------------------------------
COMMONS
      INCLUDE  'DFBCOM.F77'
C
      LOGICAL LDFBGO

      INTEGER NTODO, KDT, IACTK, NPS, ISPI, I1, I2, J, I, NREDTS
      INTEGER MYACT(1)

      REAL ELIGBL(MAXSP), PRMS(2), CRASH, TELIG, THRESH, TOTSUC
      REAL SPCNUM, DF9KIL, TOTKLL

C.... TEST TO SEE IF WINDTHROW WAS SCHEDULED.  IF NOT THEN GO TO THE END
C.... OF THIS ROUTINE AND RETURN.

      MYACT(1) = 2210
      CALL OPFIND (1,MYACT,NTODO)
      IF (NTODO .LE. 0) GOTO 1000

C.... GET THE PROPORTION TO WINDTHROW AND THE THRESHOLD VALUE FROM
C.... THE OPTION PROCESSOR.

      CALL OPGET (NTODO,2,KDT,IACTK,NPS,PRMS)
      CRASH = PRMS(1)
      THRESH = PRMS(2)

C.... INITIALIZE THE TOTAL SUSCEPTIBILITY, THE NUMBER OF SPECIES,
C.... DF TREES GREATER THAN 9 INCH DBH, AND TOTAL TREES KILLED.

      TOTSUC = 0.0
      SPCNUM = 0.0
      DF9KIL = 0.0
      TOTKLL = 0.0

C.... ENTER LOOP THAT CALCULATES THE NUMBER OF TREE SPECIES IN THE
C.... STAND, THE TOTAL SUSCEPTIBILITY OF THOSE SPECIES AND THE
C.... TREES/ACRE ELIGIBLE FOR WINDTHROW IN EACH SPECIES.

      DO 300 ISPI = 1,MAXSP
         ELIGBL(ISPI) = 0.0

         IF (ISCT(ISPI,1) .GT. 0) THEN
            SPCNUM = SPCNUM + 1.0
            TOTSUC = TOTSUC + WINSUC(IFVSSP(ISPI))

            I1 = ISCT(ISPI,1)
            I2 = ISCT(ISPI,2)

            DO 200 J = I1,I2
               I = IND1(J)

C....          CALCULATE TREES/ACRE ELIGIBLE FOR WINDTHROW.

               IF (PCT(I) .GE. ROWDOM(ISPI) .AND.
     &               HT(I) .GT. MWINHT) THEN
                  ELIGBL(ISPI) = ELIGBL(ISPI) + PROB(I)
               ENDIF
  200       CONTINUE
         ENDIF
  300 CONTINUE

C.... CALCULATE THE TOTAL NUMBER OF TREES/ACRE IN THE STAND ELIGIBLE FOR
C.... WINDTHROW.

      TELIG = 0.0
      DO 400 ISPI = 1,MAXSP
         TELIG = TELIG + ELIGBL(ISPI)
  400 CONTINUE

      IF (DEBUIN) WRITE(JODFB,*) ' IN DFBWIN: ICYC = ',ICYC,
     &   ' TOTAL ELIGIBLE = ',TELIG

C.... IF THE NUMBER OF ELIGIBLE TREES/ACRE THAT CAN BE WINDTHROWN
C.... IS GREATER THAN THE THRESHOLD THEN A WINDTHROW WILL OCCUR.

      IF (TELIG .GE. THRESH) THEN

C....    TELL THE OPTION PROCESSOR THAT THE WINDTHROW OCCURED.

         CALL OPDONE(NTODO,IY(ICYC))

C....    CALCULATE THE PROPORTION OF EACH TREE RECORD TO KILL BASED
C....    ON SPECIES.

         IF (DEBUIN) WRITE(JODFB,*) ' IN DFBWIN:  CRASH = ',CRASH,
     &      ' TOTSUC  = ',TOTSUC

        DO 600 ISPI = 1,MAXSP
            IF (ELIGBL(ISPI) .GT. 0.0) THEN
               PRPMRT(ISPI) = (CRASH * ELIGBL(ISPI) *
     &                        (WINSUC(IFVSSP(ISPI)) /
     &                        (TOTSUC / SPCNUM))) / ELIGBL(ISPI)
               IF (PRPMRT(ISPI) .GT. 0.95) PRPMRT(ISPI) = 0.95
               IF (DEBUIN) WRITE(JODFB,*) ' IN DFBWIN: ISPI = ',
     &            ISPI,' PRPMRT = ',PRPMRT(ISPI)
            ENDIF

C....       ENTER LOOP TO SET WK2 ARRAY (PROGNOSIS MORTALITY ARRAY) TO
C....       THE TREES/ACRE KILLED BY WINDTHROW.  ONLY TREE RECORDS THAT
C....       REPRESENT ELIGIBLE TREES WILL BE MODIFIED.
C
C     Revision (RNH 03/98), to correct a run time error, IND1(0) is
C     out of bounds.  The following IF statement skips species that
C     are not in the tree list. This is a similar method to that used
C     on line 132 in the origional code
C
      IF ( ISCT(ISPI,1) .GT. 0.) THEN
C

            I1 = ISCT(ISPI,1)
            I2 = ISCT(ISPI,2)

            DO 500 J = I1,I2
               I = IND1(J)
               IF (PCT(I) .GE. ROWDOM(ISPI) .AND.
     &                HT(I) .GT. MWINHT) THEN

C....             THE CURRENT RECORD WILL SHOW WINDTHROW MORTALITY.
                  IF (DEBUIN) WRITE(JODFB,*)
     &            ' IN DFBWIN: BEF MRT: I = ',I,
     &            ' WK2 = ',WK2(I),' PROB = ',PROB(I)

                  WK2(I) = WK2(I) + PROB(I) * PRPMRT(ISPI)
                  IF (PROB(I) - WK2(I) .LT. 1E-6)
     &               WK2(I) = PROB(I) - 1E-6

                  IF (DEBUIN) WRITE(JODFB,*)
     &            ' IN DFBWIN: AFT MRT: I = ',I,
     &            ' WK2 = ',WK2(I),' PROB = ',PROB(I)

C....             CALCULATE THE NUMBER OF DF TREES/ACRE WINDTHROWN THAT
C....             ARE GREATER THEN OR EQUAL TO 9 INCHES DBH.

                  IF (ISPI .EQ. IDFSPC .AND. DBH(I) .GE. 9.0)
     &               DF9KIL = DF9KIL + WK2(I)

C....             CALCULATE THE TOTAL TREES/ACRE WINDTHROWN.

                  TOTKLL = TOTKLL + WK2(I)
               ENDIF
  500       CONTINUE
C
C     End of IF statement revision (RNH 03/98)
C
      END IF
C

  600    CONTINUE

C....    IF ENOUGH LARGE DF (DBH >= 9 INCHES) ARE KILLED THEN CHECK FOR
C....    REGIONAL OUTBREAK.  IF REGIONAL OUTBREAK THEN ACTIVATE STAND
C....    OUTBREAK.

         IF (DF9KIL .GE. 1.0) THEN

C....       IF STAND OUTBREAK NOT ALREADY ACTIVATED THEN TRY TO
C....       ACTIVATE ONE.

            IF (.NOT. LDFBGO) THEN

C....           CALL OPFIND TO SEE IF A REGIONAL OUTBREAK IS OCCURING.

                MYACT(1) = 2208
                CALL OPFIND (1,MYACT,NTODO)
                IF (NTODO .EQ. 0) THEN
                   MYACT(1) = 2209
                   CALL OPFIND (1,MYACT,NTODO)
                ENDIF

                IF (NTODO .GT. 0) THEN

C....              REGIONAL OUTBREAK IS OCCURING, ACTIVATE A STAND
C....              OUTBREAK.

                   LDFBGO = .TRUE.
                   WORKIN(ICYC) = .TRUE.
                   CALL OPDONE (NTODO,IY(ICYC))
                ENDIF
            ENDIF

C....       IF OUTBREAK ACTIVATED FOR THIS STAND IN THIS CYCLE
C....       THEN SET OKILL TO EQUAL THE NUMBER OF LARGE DF WINDTHROWN.

            IF (LDFBGO) OKILL = DF9KIL
         ENDIF

         WRITE (JODFB,700)
         WRITE (JODFB,725)
         WRITE (JODFB,750) ICYC, IY(ICYC)
         WRITE (JODFB,775) TOTKLL
         WRITE (JODFB,800) DF9KIL

  700    FORMAT (///,23X,'WINDTHROW MODEL')
  725    FORMAT (1X,58('-'))
  750    FORMAT (' CYCLE AND YEAR WHEN WINDTHROW OCCURED : ',I2,
     &           ' : ',I4)
  775    FORMAT (' TREES/ACRE WINDTHROWN                 :  ',F8.2)
  800    FORMAT (' DF TREES/ACRE WINDTHROWN              :  ',F8.2)

      ELSE

C....    NO OUTBREAK!!!   RESCHEDULE EVENT FOR NEXT CYCLE.

         MYACT(1) = 2210
         CALL OPREDT (MYACT(1),IY(ICYC),IY(ICYC+1),NREDTS)
         CALL OPINCR (IY,ICYC,NCYC)
      ENDIF

 1000 CONTINUE
      RETURN
      END
