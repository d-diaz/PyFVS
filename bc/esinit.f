      SUBROUTINE ESINIT
      use esparm_mod
      use prgprm_mod
      use escomn_mod
      use esrncm_mod
      use eshap_mod
      implicit none
C----------
C  $Id$
C----------
C     CALLED FROM INITRE, ONLY ONCE, TO INITIALIZE REGEN. MODEL.
C
      INCLUDE 'ESWSBW.F77'
COMMONS

      INTEGER NSTK,I,KODE,JOSTND
      REAL SUMPRB,X
      CHARACTER*40 CNAME
      EQUIVALENCE (NSTK,SUMPRB)
      LOGICAL LTEMP,LKECHO
      CALL PPEATV (LTEMP)
      DO 10 I=1,MAXSP
      HTADJ(I)=0.0
      XESMLT(I)=1.0
   10 CONTINUE
      ITRNRM=0
      NSTK=0
      NBWHST=0
      STOADJ=0.0
      CONFID=5.0
      LINGRW=.FALSE.
      LAUTAL=.FALSE.
      LSPRUT=.TRUE.
      IPRINT=1
      IF(LTEMP) IPRINT=0
      INADV=0
      LOAD=0
      IBLK=0
      MINREP=50
      KDTOLD=-99
      IPINFO=0
      NTALLY=0
      IDSDAT=-9999
      IYRLRM=-9999
	DO I = 1,3
	  JDST(I) = -9999
	ENDDO
      XTES=0.0
      THRES1=0.10
      THRES2=0.30
      CALL ESRNSD (.FALSE.,X)
      NPTIDS=0
      INQUIRE (UNIT=JOREGT,OPENED=LTEMP)
      IF(.NOT.LTEMP) THEN
        CNAME=' '
        CALL MYOPEN (JOREGT,CNAME,4,133, 0,1,1,0,KODE)
        IF(KODE.GT.0) WRITE(*,'('' OPEN FAILED FOR '',I4)') JOREGT
      ENDIF
      RETURN
C
C     CALLED FROM INITRE WHEN NOTREES KEYWORD IS ENTERED.
C
      ENTRY ESEZCR (JOSTND,LKECHO)
      INADV=1
      IF(LKECHO)WRITE(JOSTND,30)
   30 FORMAT(T13,'(EZCRUISE OPTION IN REGENERATION ESTABLISHMENT ',
     &  'MODEL IS AUTOMATICALLY INVOKED.)'  )
      RETURN
      END
