      SUBROUTINE FILOPN
      use contrl_mod
      use econ_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C--------
C
C  THIS ROUTINE OPENS THE FILES FOR THE PROGNOSIS MODEL.
C  TO PROMPT FOR FILE NAMES, SET LPT TRUE,
C  IF PROMPTS ARE NOT WANTED, SET LPT FALSE.
C
      INTEGER LENKEY,KODE,I,LENNAM,ISTLNB
      CHARACTER*250 KEYFIL
      CHARACTER*160 CNAME
      CHARACTER VVER*7,REV*10
      LOGICAL LPT
      DATA LPT/.TRUE./
C----------
C  KEYWORD FILE.
C----------
      KWDFIL=' '
      IF (LPT) THEN
C----------
C  GET VARIANT NAME AND REVISION DATE.
C  NOTE: CR VARIANT WILL ALWAYS BE SM (SOUTHWEST MIXED CONIFERS
C  (DEFAULT)) AT THIS POINT BECAUSE KEYWORDS HAVE NOT BEEN READ.
C----------
      CALL VARVER (VVER)
      CALL REVISE (VVER,REV)
        IF(VVER(:2).EQ.'SM') THEN
           WRITE(*,1) REV
    1      FORMAT(/T20,'CR FVS METRIC VARIANT -- RV:',A10/)
        ELSE
           WRITE(*,2) VVER(:2),REV
    2      FORMAT(/T20,A2,' FVS METRIC VARIANT -- RV:',A10/)
        ENDIF
C
      WRITE (*,'('' ENTER KEYWORD FILE NAME ('',I2.2,
     >        ''): '')') IREAD
C
      ENDIF
C
      READ (*,'(A)',END=100) KWDFIL
      CALL UNBLNK(KWDFIL,LENKEY)
      IF (LENKEY.LE.0) THEN
         WRITE (*,'('' A KEYWORD FILE NAME IS REQUIRED'')')
         CALL RCDSET (3,.FALSE.)
      ENDIF
      CALL MYOPEN (IREAD,KWDFIL,3,150,0,1,1,0,KODE)
      IF (KODE.GT.0) THEN
         WRITE (*,'('' OPEN FAILED FOR '',A)')
     >        KWDFIL(1:LENKEY)
         WRITE (*,'('' A KEYWORD FILE IS REQUIRED'')')
         CALL RCDSET (3,.FALSE.)
      ENDIF
C----------
C     DBS EXTENSION NEEDS THIS FILENAME WITH EXTENSION FOR CASES TABLE
C----------
      CALL DBSVKFN(KWDFIL)
C----------
C  FIND THE LAST PERIOD IN THE FILENAME AND SET THE REST OF THE
C  KEYWORD FILE NAME TO BLANKS
C----------
      DO I= LENKEY, 1, -1
        IF (KWDFIL(I:I) .EQ. '.') THEN
        KEYFIL=KWDFIL
        KWDFIL(I:)=' '
        GO TO 10
        END IF
      END DO
   10 CONTINUE
C----------
C  MAIN OUTPUT FILE NEEDS KEYFILE NAME WITH EXTENSION. KEYFN ENTRY
C  IS IN KEYRDR ROUTINE
C----------
      CALL KEYFN(KEYFIL)
C----------
C  TREE DATA FILE.
C----------
      IF (LPT) THEN
         WRITE (*,'('' ENTER TREE DATA FILE NAME ('',I2.2,
     >                 ''): '')') ISTDAT
      ENDIF
      READ (*,'(A)',END=100) CNAME
      CALL UNBLNK(CNAME,LENNAM)
      IF (LENNAM.GT.0) THEN
         CALL MYOPEN (ISTDAT,CNAME,1,150,0,1,1,0,KODE)
         IF (KODE.GT.0) WRITE (*,'('' OPEN FAILED FOR '',A)') CNAME
      ENDIF
C----------
C  PRINT FILE.
C----------
      IF (LPT) THEN
         WRITE (*,'('' ENTER MAIN OUTPUT FILE NAME ('',I2.2,
     >                  ''): '')') JOSTND
      ENDIF
      READ (*,'(A)',END=100) CNAME
      CALL UNBLNK(CNAME,LENNAM)
      IF (LENNAM.LE.0) CNAME=KWDFIL(:ISTLNB(KWDFIL))//'.out'
      CALL MYOPEN (JOSTND,CNAME,5,133,0,1,1,1,KODE)
      IF (KODE.GT.0) THEN
         WRITE (*,'('' OPEN FAILED FOR '',A)') CNAME
         WRITE (*,'('' ALL OUTPUT IS SENT TO STANDARD OUT'')')
         JOSTND=6
      ENDIF
C----------
C  TREELIST OUTPUT.
C----------
      IF (LPT) THEN
         WRITE (*,'('' ENTER TREELIST OUTPUT FILE NAME ('',
     >        I2.2,''):  '')') JOLIST
      ENDIF
      READ (*,'(A)',END=100) CNAME
      CALL UNBLNK(CNAME,LENNAM)
      IF (LENNAM.LE.0) CNAME=KWDFIL(:ISTLNB(KWDFIL))//'.trl'
      CALL UNBLNK(CNAME,LENNAM)
      CALL MYOPEN (JOLIST,CNAME,5,133,0,1,1,1,KODE)
      IF (KODE.GT.0) WRITE (*,'('' OPEN FAILED FOR '',A)') CNAME
C----------
C  SUMMARY OUTPUT FILE.
C----------
      IF (LPT) THEN
         WRITE (*,'('' ENTER SUMMARY OUTPUT FILE NAME ('',
     >                  I2.2,''): '')') JOSUM
      ENDIF
      READ (*,'(A)',END=100) CNAME
      CALL UNBLNK(CNAME,LENNAM)
      IF (LENNAM.LE.0) CNAME=KWDFIL(:ISTLNB(KWDFIL))//'.sum'
      CALL UNBLNK(CNAME,LENNAM)
      CALL MYOPEN (JOSUM,CNAME,5,133,0,1,1,0,KODE)
      IF (KODE.GT.0) WRITE (*,'('' OPEN FAILED FOR '',A)') CNAME
C----------
C  AUXILIARY FILE (CHEAPOII) FILE
C----------
      IF (LPT) THEN
         WRITE (*,'('' ENTER CHEAPOII/CALBSTAT '',
     >        ''OUTPUT FILE NAME ('',I2.2,''): '')') JOSUME
      ENDIF
      READ (*,'(A)',END=100) CNAME
      CALL UNBLNK(CNAME,LENNAM)
      IF (LENNAM.LE.0) CNAME=KWDFIL(:ISTLNB(KWDFIL))//'.chp'
      CALL MYOPEN (JOSUME,CNAME,5,91,0,1,1,0,KODE)
      IF (KODE.GT.0) WRITE (*,'('' OPEN FAILED FOR '',A)') CNAME
C----------
C  OPEN THE SAMPLE TREE SCRATCH FILE.
C----------
      CNAME=' '
      CALL MYOPEN (JOTREE,CNAME,4,512, 0,2,1,0,KODE)
      IF (KODE.GT.0) WRITE (*,'('' OPEN FAILED FOR '',I4)') JOTREE
  100 CONTINUE
C
      RETURN
      END
