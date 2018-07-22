      SUBROUTINE ESPLT1 (ITREI,IMC1,NPNVRS,IPVARS)
      IMPLICIT NONE
C----------
C STRP $Id$
C----------
C
C     CALLED BY INTREE TO PASS PLOT SPECIFIC VARIABLES TO THE
C     ESTABLISHMENT MODEL.
C
C     ITREI = PLOT IDENTIFICATION.
C     IMC1  = MANAGEMENT CODE, 8=NONSTOCKABLE.
C     NPNVRS= THE NUMBER OF PLOT SITE VARIABLES PASSED.
C     IPVARS= A VECTOR OF PLOT SPECIFIC SITE ATTRIBUTES.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
      INCLUDE 'ESHAP2.F77'
C
C
COMMONS
C
      INTEGER IPVARS(NPNVRS),NSID(MAXPLT),IMC1,ITREI,NPNVRS,NSTK,I
      INTEGER IRTNCD
C
C     WARNING: ESB1 AND SUMPRB ARE BOTH MEMBERS OF /ESHAP2/ ... THEY
C              ARE BEING USED TO PASS DATA FROM ESPLT1 TO ESPLT2.
C
      EQUIVALENCE (NSID,ESB1),(NSTK,SUMPRB)
C
C     IF PLOT DATA ALREADY READ USING PLOTINFO OPTION, THEN:
C     BRANCH TO CHECK THE STOCKABILITY STATUS OF THIS PLOT.
C
      IF (IPINFO.EQ.1) GOTO 20
C
C     ELSE: SAVE THE PLOT STOCKABILITY.
C
      NPTIDS=NPTIDS+1
C
C     IF TOO MANY POINTS, ERROR.
C
      IF (NPTIDS.GT.MAXPLT) CALL ERRGRO (.FALSE.,13)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     SAVE THE PLOT IDENTIFICATION.
C
      IPTIDS(NPTIDS)=ITREI
C
C     IF THIS IS A NON-STOCKABLE PLOT, THEN INDICATE BY SETTING THE SITE
C     PREP CODE EQUAL -1.
C
      IPPREP(NPTIDS)=0
      IF (IMC1.NE.8) GOTO 10
      IPPREP(NPTIDS)=-1
      RETURN
   10 CONTINUE
C
C     IF PLOT VARIABLES ARE NOT BEING PASSED, THEN: RETURN.
C
      IF (NPNVRS.LE.1) RETURN
      IPINFO=2
      PSLO(NPTIDS)=FLOAT(IPVARS(1))
      PASP(NPTIDS)=FLOAT(IPVARS(2))
      IPHAB(NPTIDS)=IPVARS(3)
      IPHYS(NPTIDS)=IPVARS(4)
      IPPREP(NPTIDS)=IPVARS(5)
      RETURN
   20 CONTINUE
C
C     THE SITE DATA HAS BEEN READ USING PLOTINFO.  CHECK THE
C     STOCKABILITY OF THIS PLOT.
C
      IF (IMC1.NE.8) RETURN
C
C     PLOT IS NONSTOCKABLE, FIND THE PLOT ID CODE AND CHANGE THE
C     SITE PREP CODE TO -1 INDICATING THAT THE POINT IS NONSTOCKABLE.
C
      DO 30 I=1,NPTIDS
      IF (IPTIDS(I).NE.ITREI) GOTO 30
      IPPREP(I)=-1
      RETURN
   30 CONTINUE
C
C     IF YOU CAN'T FIND THE PLOT ID, THEN: SAVE IT IN A LIST OF
C     NONSTOCKABLE IDS.
C
      NSTK=NSTK+1
      NSID(NSTK)=ITREI
      RETURN
      END
