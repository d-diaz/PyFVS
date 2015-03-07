      SUBROUTINE MISINT
      use contrl_mod
      use prgprm_mod
      implicit none
***********************************************************************
*  **MISINT--AK  Date of last revision:  07/12/11
*----------------------------------------------------------------------
*  Purpose:
*     Mistletoe parameter initialization routine. This routine is
*  variant dependent and sets the variant dependent variables for other
*  mistletoe routines. This is the SEAPROG (Alaska) version.
*
*  Mountain hemlock changed to a non-host species, in response to a discussion
*  with Paul Hennon and Lori Trummer. The occurrance of mistletoe on
*  mountain hemlock is too rare to be considered a host for modeling
*  purposes. Matt Oberle mjo 3/15/99.
*----------------------------------------------------------------------
*
*  Call list definitions:
*
*  Local variable definitions:
*     DEBUG:  Logical flag to turn debug on and off.
*     AFIT:   Array of MISFIT data.
*     ACSP:   Array of CSPARR data.
*     ADGP:   Array of DGPMDR data.
*     APMC:   Array of PMCSP data.
*
*  Common block variables and parameters:
*     CSPARR: From MISCOM; 2-char. representations of all species.
*     DGPDMR: From MISCOM; diameter growth potentials based on species
*                and DMR (0-6).
*     ICYC:   From CONTRL; cycle index number.
*     JOSTND: From CONTRL; logical unit number for stand output.
*     MISFIT: From MISCOM; tells which species are affected by DM.
*     PMCSP:  From MISCOM; percent mortality coefficients by species.
*
*  12-JUL-2011 Lance R. David (FMSC)
*    Added arrays for height growth impacts.
*    Impact values must be supplied by MistHMod keyword.
***********************************************************************

C.... Parameter statements.

C.... Parameter include files.


C.... Common include files.

      INCLUDE 'MISCOM.F77'

C.... Variable declarations.

      LOGICAL DEBUG
      REAL AFIT(MAXSP),ADGP(MAXSP,7),AHGP(MAXSP,7),APMC(MAXSP,3)
      CHARACTER*2 ACSP(MAXSP)
      INTEGER I,J

C.... Data statements.

C.... Species character representations

      DATA (ACSP(I),I=1,13)
     &   /'WS','RC','SF','MH','WH','YC','LP','SS','AF','RA',
     &    'CW','OH','OS'/

C.... Species affected by mistletoe

      DATA (AFIT(I),I=1,13)
     &   / 0,   0,   1,   0,   1,   0,   1,   0,   1,   0,
     &     0,   0,   0/

C.... Diameter growth rates

      DATA ((ADGP(I,J),J=1,7),I=1,MAXSP)
     &  /1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,.98,.95,.70,.50,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,.94,.80,.59,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,.94,.80,.59,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,.98,.95,.70,.50,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0/

C Old mountain hemlock growth rate parameters  1.0,1.0,1.0,.98,.86,.73,.50,

C.... Height growth potential rates
C....
C.... Using Douglas-fir height growth impact values described in:
C....
C.... Marshall, Katy 2007. Permanent plots for measuring spread and
C.... impact of Douglas-fir dwarf mistletoe in the Southern Oregon
C.... Cascades, Pacific Northwest Region: Results of the ten year
C.... remeasurement. USDA Forest Service, Pacific Northwest Region,
C.... Southwest Oregon Forest Insect and Disease Service Center,
C.... Central Point, Oregon. SWOFIDSC-07-04. 34 pp.
C....
C.... Default values for DF in this table would be:
C.... &   1.0,1.0,1.0,.95,.65,.50,.10,
C.... So that impacts are not unknowingly applied to projections,
C.... the values must be supplied with the MistHMod keyword.
C.... when appropriat default values are developed, they will be
C.... set here.

      DATA ((AHGP(I,J),J=1,7),I=1,MAXSP)
     &  /1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0,
     &   1.0,1.0,1.0,1.0,1.0,1.0,1.0/

C.... Mortality coefficients

      DATA ((APMC(I,J),J=1,3),I=1,MAXSP)
     &  /0.0,0.0,0.0,
     &   0.0,0.0,0.0,
     &   0.0,0.00159,0.00508,
     &   0.0,0.0,0.0,
     &   0.00112,0.02170,-0.00171,
     &   0.0,0.0,0.0,
     &   0.00112,0.02170,-0.00171,
     &   0.0,0.0,0.0,
     &   0.0,0.00159,0.00508,
     &   0.0,0.0,0.0,
     &   0.0,0.0,0.0,
     &   0.0,0.0,0.0,
     &   0.0,0.0,0.0/

C Old mountain hemlock mortality coeffs  0.00681,-0.00580,0.00935,

C.... Check for debug.

      CALL DBCHK(DEBUG,'MISINT',6,ICYC)

      IF(DEBUG) WRITE(JOSTND,10)ICYC
   10 FORMAT(' Begin/end MISINTAK: Cycle = ',I5)

C.... Mistletoe model initializations.

      DO 200 I=1,MAXSP
         MISFIT(I)=AFIT(I)
         CSPARR(I)=ACSP(I)
         DO 100 J=1,7
            DGPDMR(I,J)=ADGP(I,J)
            HGPDMR(I,J)=AHGP(I,J)
  100    CONTINUE
         DO 150 J=1,3
            PMCSP(I,J)=APMC(I,J)
  150    CONTINUE
  200 CONTINUE

      RETURN
      END
