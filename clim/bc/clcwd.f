      REAL FUNCTION CLCWD(Q10,REF)
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     CLIMATE EXTENSION -- COMPUTES MAT_BASED DECAY MODIFIER BASED ON HABITAT
C     IF CLIMATE DATA ARE NOT LOADED, THE HISTORIC MAT IS USED. THE MODIFIER
C     IS BASED ON THE STANDARD Q10 RELATIONSHIP
C
C     EXP((MAT-REFTEMP)*LN(Q10)*0.1))
C
      INCLUDE 'CLIMATE.F77'
C

C      Q10 = TEMPERATURE-RESPIRATION SCALING: 10C INCREASE INCREASES RESPIRATION BY Q10
C      REFTEMP = REFERENCE TEMPERATURE FOR Q10, SHOULD BE 10c
C      MULT = MULTIPLIER BASED ON MAT VS REFTEMP AND Q10=2

      LOGICAL DEBUG,LOK
      REAL X,Q10,REF,MULT
      REAL THISYR,ALGSLP,MAT_NOW

      CALL DBCHK (DEBUG,'CLCWD',5,ICYC)

      IF (DEBUG) WRITE (JOSTND,1) LCLIMATE,Q10,REF
    1 FORMAT ('IN CLCWD, LCLIMATE=',L2,'Q10,REF=',2F6.3)

C     Q10 MUST BE IN THE 0.5 - 4.0 RANGE
C     REF MUST BE IN THE RANGE -5.0 - 40 CELSIUS
      CLCWD = 1.0
      IF (Q10 .LT. 0.5 .OR. Q10 .GT. 4) RETURN
      IF (REF .LT. -5.0 .OR. REF .GT. 40) RETURN

C     ENSURE THE MULTIPLIER IS INITIALLY 1.0 (NO CLIMATE EFFECT).

      IF (DEBUG) WRITE (JOSTND,2) ICYC,IY(ICYC),IXMAT
    2 FORMAT ('IN CLCWD, ICYC,IY(ICYC)=',2I5,
     >        ' IXMAT=',I4)

C     IF CLIMATE NOT ACTIVE OR DATA IS ABSENT, TAKE FROM HISTORIC
C     MAT USING HABITAT ZONE
      LOK = .TRUE.

      IF ((.NOT.LCLIMATE) .OR. (IXMAP*IXMAT*IXMTCM*IXDD5.EQ.0)) THEN
        CALL CLHAB(MAT_NOW, LOK)
        IF (.NOT.LOK) RETURN
      ELSE
C       LOAD THE CLIMATE DATA FOR THIS YEAR
        THISYR=FLOAT(IY(ICYC))+(FINT/2)
        MAT_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXMAT), NYEARS)
      ENDIF

C     NOW CALCULATE THE MULTIPLER BASED ON REFTEMP AND MAT.
C     ULTIMATELY THIS WILL MODIFY THE DECAY RATE
C     ANSWER IS BOUNDED BY 10**-3 AND 10**3
      X = (MAT_NOW-REF)*LOG(Q10)*0.1
      X = MAX(-6.91,MIN(X,6.91))
      MULT = EXP(X)
      CLCWD = MULT

      RETURN
      END

