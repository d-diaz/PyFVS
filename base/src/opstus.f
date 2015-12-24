      SUBROUTINE OPSTUS(IACTK,IYR1,IYR2,ISQNUM,
     >                  NTIMES,IDT,NPRMS,ISTAT,KODE)
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     OPSTUS IS USED TO CHECK THE STATUS OF AN ACTIVITY.  THE
C     USEFULNESS OF THE ROUTINE LIES IN ITS ABILITY TO FIND OUT IF
C     AS ACTIVITY HAS BEEN ACCOMPLISHED, DELETED, OR AWAITS
C     ACCOMPLISHMENT WITHOUT TAKING ANY ACTION TO CHANGE ITS
C     STATUS.  NOTE THAT THE SEARCHING LOGIC USED BY THIS ROUTINE
C     IS THE SAME AS THAT USED IN OPGET2 EXCEPT THAT DELETED AND
C     ACCOMPLISHED ACTIVITIES COUNT AS "FINDS"; ACTIVITIES WITH
C     THESE STATUS CODES ARE IGNORED BY OPGET2 AND THEREFORE THE
C     VALUE OF ISQNUM CAN HAVE A DIFFERENT EFFECT WHEN USED WITH
C     THE TWO DIFFERENT ROUTINES.  THE ARGUMENTS:
C
C     IACTK, IYR1, IYR2, ISQNUM, IDT, AND KODE ARE THE SAME
C     AS UNDER OPGET2.
C     NTIMES= THE NUMBER OF TIMES THE ACTIVITY EXISTS WITHIN THE
C             THE RANGE OF DATES.
C     NPRMS = THE NUMBER OF PARAMETERS FOR THE ACTIVITY MEETING THE
C             SEARCH RESTRICTIONS (IYR1,IYR2, & ISQNUM).
C     ISTAT = THE STATUS OF THE ACTIVITY MEETING THE SEARCH
C             RESTRICTIONS; WHERE:
C             0  IMPLIES THAT THE ACTIVITY IS AWAITING ACCOMPLISHMENT
C             -1 IMPLIES THAT THE ACTIVITY HAS BEEN DELETED, AND
C             >0 IMPLIES THAT THE ACTIVITY WAS ACCOMPLISHED ON
C                ON DATE ISTAT.
C
C     ***** AND ENTRY POINT IN OPSTUS *****
C
C     ENTRY OPEVAC (IACTK,NTIMES)
C
C     COUNTS UP THE NUMBER OF TIMES (NTIMES) THAT AN ACTIVITY (IACTK)
C     HAS BEEN SET UP TO OCCUR AFTER AN EVENT.
C
      INCLUDE 'OPCOM.F77'
C
      INTEGER KODE,ISTAT,NPRMS,IDT,NTIMES,ISQNUM,ITR2,IYR1,IACTK
      INTEGER IFIND,I2,II,I,ID,J1,J2,NACT,IYR2
C
C     PREFORM THE SEARCH FOR THE ACTIVITY IN ASSENDING DATE ORDER.
C
      KODE=0
      IFIND=0
      NTIMES=0
      I2=IMGL-1
      DO 40 II=1,I2
      I=IOPSRT(II)
      ID=IDATE(I)
      IF (ID.LT.IYR1 .OR. ID.GT.IYR2 .OR. IACTK.NE.IACT(I,1)) GOTO 40
      NTIMES=NTIMES+1
      IF (ISQNUM.GT.0) GOTO 30
      IFIND=I
      GOTO 40
   30 CONTINUE
      IF (ISQNUM.NE.NTIMES) GOTO 40
      IFIND=I
   40 CONTINUE
      IF (IFIND.GT.0) GOTO 60
      KODE=1
      RETURN
C
C     THE SEARCH IS COMPLETE. LOAD THE REST OF THE OPTION INFORMATION.
C
   60 CONTINUE
      IDT=IDATE(IFIND)
      NPRMS=0
      J1=IACT(IFIND,2)
      IF (J1.GT.0) GOTO 75
      GOTO 76
   75 CONTINUE
      J2=IACT(IFIND,3)
      NPRMS=J2-J1+1
   76 CONTINUE
      ISTAT=IACT(IFIND,4)
      RETURN
C
      ENTRY OPEVAC (IACTK,NTIMES)
C
      NTIMES=0
C
C     IEPT POINTS TO THE NEXT AVAILABLE PLACE TO STORE ACTIVITIES THAT
C     FOLLOW AN EVENT.  IF IEPT IS GE MAXACT, NO ACTIVITIES HAVE BEEN
C     STORED THAT FOLLOW AN EVENT.
C
      IF (IEPT.GE.MAXACT) RETURN
      NACT=IEPT+1
      DO 90 I=NACT,MAXACT
      IF (IACTK.EQ.IACT(I,1)) NTIMES=NTIMES+1
   90 CONTINUE
      RETURN
      END
