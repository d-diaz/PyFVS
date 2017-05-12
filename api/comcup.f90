      SUBROUTINE COMCUP
      use findage_mod, only: findag
      use prgprm_mod
      use arrays_mod
      use contrl_mod
      use outcom_mod

      implicit none
!----------
!  $Id$
!----------
!
!     INTERFACE ROUTINE TO COUPLE THE COMPRESSION ROUTINE TO
!     THE PROGNOSIS MODEL FOR STAND DEVELOPMENT.
!
!     ADDED THE CAPABILITY TO DELETE TREES THAT HAVE ZERO (AND/OR
!     NEAR-ZERO) PROBS...TOTAL REWRITE.  NL CROOKSTON, JUNE 1991.
!
!     N.L. CROOKSTON       INT-MOSCOW     DEC. 1981 & JUNE 1982
!
      LOGICAL LDEBU,LCMPRS
      INTEGER NDEL,I,NTODO,NPRMS,IACT,IDT,ITARG,IS,IM,MYACT(1),ISPC
      REAL SPCNT(MAXSP,3),PRMS(3),PN1
      REAL SITAGE,SITHT,AGMAX,H,HTMAX,HTMAX2,D1,D2
!
      DATA MYACT/250/
!
!     CHECK FOR DEBUG REQUEST.
!
      CALL DBCHK (LDEBU,'COMCUP',6,ICYC)
!
!     CHECK THE TREELIST FOR ZERO PROBS.  SET UP IND2 IN THE SAME
!     PASS.
!
      LCMPRS= .FALSE.
      NDEL=0
      IF (ITRN.GT.0) THEN
         DO 10 I=1,ITRN
         IF (PROB(I).LE. 1E-5) THEN
            IND2(I)=-I
            NDEL=NDEL+1
         ELSE
            IND2(I)=I
         ENDIF
   10    CONTINUE
      ENDIF
!
!     IF ALL THE TREES HAVE ZERO PROBS, SET ITRN TO ZERO.
!
      IF (NDEL.EQ.ITRN) THEN
         ITRN=0
         IREC1=0
      ENDIF
      IF (LDEBU) WRITE (JOSTND,20) ITRN,NDEL
   20 FORMAT (/' IN COMCUP (TOP): ITRN,NDEL=',2I6)
!
!     IF THERE ARE SOME ZERO PROBS, AND ITRN IS GREATER THAN ZERO,
!     THEN DELETE THEM USING TREDEL.
!
      IF (NDEL.GT.0 .AND. ITRN.GT.0) CALL TREDEL (NDEL,IND2)
!
!     GET THE COMPRESSION REQUEST.
!
      CALL OPFIND (1,MYACT,NTODO)
!
!     IF NTODO IS GT ZERO, THEN:
!
      IF (NTODO .GT. 0) THEN
!
!        GET THE LAST COMPRESSION REQUEST AND DELETE ALL THE OTHERS.
!
         CALL OPGET (NTODO,3,IDT,IACT,NPRMS,PRMS)
         IF (NTODO.GT.1) THEN
            DO 40 I=1,(NTODO-1)
            CALL OPDEL1(I)
   40       CONTINUE
         ENDIF
!
!        SET THE PARAMETERS OF COMPRESSION.
!
         ITARG=IFIX(PRMS(1))
         PN1 = PRMS(2)/100.
!
!        DETERMINE IF COMPRESSION WILL TAKE PLACE AFTER ALL.
!
         LCMPRS = ITARG.LT.ITRN
!
!        WRITE DEBUG MSG, IF REQUESTED.
!
         IF (LDEBU) WRITE (JOSTND,50) ITARG,PN1,LCMPRS
   50    FORMAT (/' IN COMCUP: ITARG,PN1,LCMPRS: ',I5,F8.3,L3)
!
!        IF COMPRESSION IS TO TAKE PLACE; THEN: COMPRESS THE
!        TREE LIST.
!
         IF (LCMPRS) THEN
!
!           FOR THIS CALL TO COMPRS, WK2 MUST BE INITIALIZED
!           TO ZERO.
!
            DO 55 I=1,ITRN
            WK2(I)=0.0
   55       CONTINUE
!
!           COMPRESS THE TREE LIST.
!
            CALL COMPRS (ITARG,PN1)
!
!           SIGNAL THAT COMPRESSION HAS TAKEN PLACE.
!
            CALL OPDONE (NTODO,IY(ICYC))
!
!           SUPPRESS RECORD TRIPLING.
!
            NOTRIP=.TRUE.
!
         ELSE
!
!           SIGNAL OPDEL1.
!
            CALL OPDEL1 (NTODO)
         ENDIF
      ENDIF
!
!     IF COMPRESSION TOOK PLACE, OR IF TREES WITH PROBS OF ZERO,
!     WERE DELETED FROM THE TREELIST, THEN: DO THE FOLLOWING:
!     (NOTE: ALL THIS CAN BE DONE WITH ITRN=0).
!
      IF (LCMPRS.OR.NDEL.GT.0) THEN
!
!        REESTABLISH THE SPECIES-ORDER SORT.
!
         CALL SPESRT
!
!        INITIALIZE SPCNT.
!
         DO I=1,MAXSP
            SPCNT(I,1)=0.
            SPCNT(I,2)=0.
            SPCNT(I,3)=0.
         ENDDO
         IF (ITRN.GT.0) THEN
!
!           RE-COMPUTE THE SPECIES COMPOSITION
!
            DO 70 I=1,ITRN
            IS=ISP(I)
            IM=IMC(I)
            SPCNT(IS,IM)=SPCNT(IS,IM)+PROB(I)
   70       CONTINUE
!
!           REESTABLISH THE DIAMETER SORT.
!
            CALL RDPSRT (ITRN,DBH,IND,.TRUE.)
!
!           RE-COMPUTE THE DISTRIBUTION OF TREES PER ACRE AND
!           SPECIES-TREE CLASS COMPOSITON BY TREES PER ACRE.
!
            CALL PCTILE(ITRN,IND,PROB,WK3,ONTCUR(7))
!----------
!  ESTIMATE MISSING TOTAL TREE AGES
!----------
            DO I=1,ITRN
            IF(ABIRTH(I) .LE. 0.)THEN
              SITAGE = 0.0
              SITHT = 0.0
              AGMAX = 0.0
              HTMAX = 0.0
              HTMAX2 = 0.0
              ISPC = ISP(I)
              D1 = DBH(I)
              H = HT(I)
              D2 = 0.0
              CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX, &
                          HTMAX2,LDEBU)
              IF(SITAGE .GT. 0.)ABIRTH(I)=SITAGE
            ENDIF
            ENDDO
!
         ENDIF
!
!        (MAKE SURE IFST=1, TO GET A NEW SET OF POINTERS TO THE
!         DISTRIBUTIONS).
!
         IFST=1
         CALL DIST(ITRN,ONTCUR,WK3)
         CALL COMP(OSPCT,IOSPCT,SPCNT)
!
!        RE-COMPUTE THE STAND DENSITY STATISTICS AND SIGNAL THAT
!        DENSE HAS BEEN COMPUTED.
!
         CALL DENSE
      ENDIF
      IF (LDEBU) WRITE (JOSTND,80) ITRN,NDEL
   80 FORMAT (/' IN COMCUP (BOT): ITRN,NDEL=',2I6)
      RETURN
      END
