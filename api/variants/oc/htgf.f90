      SUBROUTINE HTGF
      use findage_mod, only: findag
      
      use htcal_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use pden_mod
      use varcom_mod
      use prgprm_mod
      use multcm_mod
      use organon_mod
      implicit none
!----------
!  **HTGF--OC    DATE OF LAST REVISION:  03/30/15
!----------
!  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
!  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
!  HEIGHT INCREMENT IS PREDICTED FROM SPECIES, HABITAT TYPE,
!  HEIGHT, DBH, AND PREDICTED DBH INCREMENT.  THIS ROUTINE
!  IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.  ENTRY
!  **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE DEPENDENT
!  CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
!----------
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,INDEX,I3,ITFN
      REAL AGP10,HGUESS,SCALE,XHT,SINDX,AGMAX,H,POTHTG,XMOD,CRATIO
      REAL RELHT,CRMOD,RHMOD,TEMHTG
      REAL SITAGE,SITHT,HTMAX,HTMAX2,D1,D2
      REAL MISHGF
!-----------
!  SEE IF WE NEED TO DO SOME DEBUG.
!-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF CYCLE =',I5)
!
      SCALE=FINT/YR
!----------
!  GET THE HEIGHT GROWTH MULTIPLIERS.
!----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- ISPC,IY(ICYC),XHMULT= ',ISPC, &
       IY(ICYC), XHMULT
!----------
!   BEGIN SPECIES LOOP:
!----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XHT=XHMULT(ISPC)
      SINDX = SITEAR(ISPC)
!-----------
!   BEGIN TREE LOOP WITHIN SPECIES LOOP
!
!   XHT CONTAINS THE HEIGHT GROWTH MULTIPLIER FROM THE HTGMULT KEYWORD
!   HTCON CONTAINS THE HEIGHT GROWTH MULTIPLIER FROM THE READCORH KEYWORD
!-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I).LE.0.0) GO TO 161
!----------
!  START ORGANON
!
      IF(IORG(I) .EQ. 1) THEN
        HTG(I)=SCALE*XHT*HGRO(I)*EXP(HTCON(ISPC))
        IF(DEBUG)WRITE(JOSTND,*)' HTGF ORGANON I,ISP,DBH,HT,HTG,HGRO,', &
        'SCALE,XHT,HTCON,IORG= ',I,ISP(I),DBH(I),HT(I),HTG(I),HGRO(I), &
        SCALE,XHT,HTCON(ISPC),IORG(I)
        GO TO 161
      ENDIF
!
!  END ORGANON
!----------
      H=HT(I)
      AGP10 = 0.0
      HGUESS = 0.0
!
      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D1 = DBH(I)
      D2 = 0.0
      CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,DEBUG)
!
!----------
!  NORMAL HEIGHT INCREMENT CALCULATON BASED ON INCOMMING TREE AGE
!  FIRST CHECK FOR MAX, ASMYPTOTIC HEIGHT
!----------
      IF (SITAGE .GT. AGMAX) THEN
        POTHTG = 0.10
        GO TO 1320
      ELSE
        AGP10= SITAGE + 5.0
      ENDIF
!----------
! R5 USE DUNNING/LEVITAN SITE CURVE.
! R6 USE VARIOUS SPECIES SITE CURVES.
! SPECIES DIFFERENCES ARE ARE ACCOUNTED FOR BY THE SPECIES
! SPECIFIC SITE INDEX VALUES WHICH ARE SET AFTER KEYWORD PROCESSING.
!----------
      CALL HTCALC(IFOR,SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG)
!
      POTHTG= HGUESS - SITHT
!
      IF(DEBUG)WRITE(JOSTND,91200)I,ISPC,AGP10,HGUESS,H
91200 FORMAT(' IN GUESS AN AGE--I,ISPC,AGEP10,HGUESS,H ',2I5,3F10.2)
!----------
! ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
!----------
 1320 CONTINUE
      XMOD=1.0
      CRATIO=ICR(I)/100.0
      RELHT=H/AVH
      IF(RELHT .GT. 1.0)RELHT=1.0
      IF(PCCF(ITRE(I)) .LT. 100.0)RELHT=1.0
!--------
!  THE TREE HEIGHT GROWTH MODIFIER (SMHMOD) IS BASED ON THE RITCHIE &
!  HANN WORK (FOR.ECOL.&MGMT. 1986. 15:135-145).  THE ORIGINAL COEFF.
!  (1.117148) IS CHANGED TO 1.016605 TO MAKE THE SMALL TREE HEIGHTS
!  CLOSE TO THE SITE INDEX CURVE.  THE MODIFIER HAS TWO PARTS, ONE
!  (CRMOD) FOR TREE VIGOR USING CROWN RATIO AS A SURROGATE; OTHER
!  (RHMOD) FOR COMPETITION FROM NEIGHBORING TREES USING RELATIVE TREE
!  HEIGHT AS A SURROGATE.
!----------
      CRMOD=(1.0-EXP(-4.26558*CRATIO))
      RHMOD=(EXP(2.54119*(RELHT**0.250537-1.0)))
      XMOD= 1.016605*CRMOD*RHMOD
      HTG(I) = POTHTG * XMOD
      IF(HTG(I) .LT. 0.1) HTG(I)=0.1
!
      IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I), &
       POTHTG,AVH,HTG(I),DBH(I),RMAI,HGUESS,AGP10,XMOD,ABIRTH(I)
  901 FORMAT(' HTGF',I5,14F9.2)
!----------
!  HTG IS MULTIPLIED BY SCALE TO CHANGE FROM A YR  PERIOD TO FINT AND
!  MULTIPLIED BY XHT AND HTCON TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
!----------
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
!
      IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,DBH,DG,H,HTG,SCALE,XHT,HTCON= ', &
      I,ISPC,DBH(I),DG(I),H,HTG(I),SCALE,XHT,HTCON(ISPC)
!
  161 CONTINUE
!----------
!    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
!    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
!----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
!
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
!
      HTG(ITFN+1)=TEMHTG
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
!
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
!----------
!   END OF TREE LOOP
!----------
   30 CONTINUE
!----------
!   END OF SPECIES LOOP
!----------
   40 CONTINUE
!
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN
!
      ENTRY HTCONS
!----------
!  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
!  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.  HGHC
!  CONTAINS HABITAT TYPE INTERCEPTS, HGLDD CONTAINS HABITAT
!  DEPENDENT COEFFICIENTS FOR THE DIAMETER INCREMENT TERM, HGH2
!  CONTAINS HABITAT DEPENDENT COEFFICIENTS FOR THE HEIGHT-SQUARED
!  TERM, AND HGHC CONTAINS SPECIES DEPENDENT INTERCEPTS.  HABITAT
!  TYPE IS INDEXED BY ITYPE (SEE /PLOT/ COMMON AREA).
!----------
!  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
!----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)= &
          HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
      RETURN
      END
