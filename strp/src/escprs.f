      SUBROUTINE ESCPRS (ITRGT,DEBUG)
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **ESCPRS DATE OF LAST REVISION:   06/21/11
C----------
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'ESHAP.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      LOGICAL DEBUG
      REAL PRMS(2)
      REAL SPCNT(MAXSP,3)
      REAL SITAGE,SITHT,AGMAX,H,HTMAX,HTMAX2,D1,D2
      INTEGER IS,IM,ISPC
      INTEGER MYACT(1),ITRGT,I,N,KDT
      DATA MYACT/250/
C
C     CALL THE COMPRESSION ROUTINE.
C
      I=ITRN
      N=ITRGT
      PRMS(2)=.5
      CALL COMPRS (N,PRMS(2))
C
C     REESTABLISH THE SPECIES-ORDER SORT.
C
      CALL SPESRT
C
C     INITIALIZE SPCNT.
C
      DO I=1,MAXSP
         SPCNT(I,1)=0.
         SPCNT(I,2)=0.
         SPCNT(I,3)=0.
      ENDDO
      IF (ITRN.GT.0) THEN
C
C        RE-COMPUTE THE SPECIES COMPOSITION
C
         DO 70 I=1,ITRN
         IS=ISP(I)
         IM=IMC(I)
         SPCNT(IS,IM)=SPCNT(IS,IM)+PROB(I)
   70    CONTINUE
C
C        REESTABLISH THE DIAMETER SORT.
C
         CALL RDPSRT (ITRN,DBH,IND,.TRUE.)
C
C        RE-COMPUTE THE DISTRIBUTION OF TREES PER ACRE AND
C        SPECIES-TREE CLASS COMPOSITON BY TREES PER ACRE.
C
         CALL PCTILE(ITRN,IND,PROB,WK3,ONTCUR(7))
C-------
C  ESTTE MISSING TOTAL TREE AGES
C-------
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
            CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,
     &                  HTMAX2,DEBUG)
            IF(SITAGE .GT. 0.)ABIRTH(I)=SITAGE
         ENDIF
         ENDDO
C
      ENDIF
C
C     (MAKE SURE IFST=1, TO GET A NEW SET OF POINTERS TO THE
C      DISTRIBUTIONS).
C
      IFST=1
      CALL DIST(ITRN,ONTCUR,WK3)
      CALL COMP(OSPCT,IOSPCT,SPCNT)
C
C     WRITE A MSG SAYING THAT COMPRESS WAS CALLED.
C
      IF (DEBUG) WRITE (JOREGT,10) I,N,IY(ICYC+1)-1
   10 FORMAT('IN ESCPRS: COMPRS: ',I5,' RECS',
     &  ' TO',I5,'.  YEAR:',I5)
C
C     ADD COMPRESS TO THE ACTIVITIY SCHEDULE AND SIGNAL THAT IT IS
C     BY SETTING THE STATUS CODE TO KDT (THIRD ARGUMENT).
C
      PRMS(1)=N
      KDT=IY(ICYC+1)-1
      CALL OPADD (KDT,MYACT(1),KDT,2,PRMS,I)
      RETURN
      END
