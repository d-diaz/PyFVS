module varcom_mod
    use prgprm_mod
    implicit none
!ODE SEGMENT VARCOM
!----------
!  **VARCOM---COMMON      DATE OF LAST REVISION:  07/20/2011
!----------
      CHARACTER*8 PCOM,PCOMX
      COMMON /VARCHR/ PCOM,PCOMX
      LOGICAL  LBAMAX,LFLAGV,LFIXSD
      INTEGER  IABFLG(MAXSP),ISTAGF(MAXSP),MAXSDI(MAXSP), &
            ISILFT,MFLMSB,IBASP
      REAL     AA(MAXSP),BB(MAXSP),B0ACCF(MAXSP),B1ACCF(MAXSP),      &
            B0BCCF(MAXSP),B1BCCF(MAXSP),B0ASTD(MAXSP),               &
            B1BSTD(MAXSP),HTT1(MAXSP,9),HTT2(MAXSP,9),               &
            BB0(MAXSP),BB1(MAXSP),BB2(MAXSP),BB3(MAXSP),BB4(MAXSP),  &
            BB5(MAXSP),BB6(MAXSP),BB7(MAXSP),BB8(MAXSP),BB9(MAXSP),  &
            BB10(MAXSP),BB11(MAXSP),BB12(MAXSP),BB13(MAXSP),         &
            PTBALT(MAXTRE),PTBAA(MAXPLT),CEPMRT,SLPMRT,TPAMRT,       &
            QMDMSB,SLPMSB,CEPMSB,EFFMSB,DLOMSB,DHIMSB
!----------
!  DEFINITIONS OF VARIABLES IN 'VARCOM' & 'VARCHR' COMMON BLOCKS:
!----------
!     NOTE: THIS COMMON BLOCK CONTAINS ALL THE 'STRAGGLER' VARIABLES
!     FOR ALL THE GEOGRAPHIC VARIANTS EMT THROUGH NWC.
!
!      AA   -- CALCULATED COEFFICIENTS FOR THE SMALL TREE HEIGHT GROWTH
!      BB      MODEL. USED TO DUB MISSING HEIGHTS IN CRATET AND
!              CALCULATE SMALL TREE HEIGHTS IN REGENT.
!
!     B0ACCF-- COEFFICIENTS USED TO ESTIMATE HEIGHT GROWTH. USED IN
!     B1ACCF   REGENT AND ESGROW. THESE COEFFS ARE USED IN EMT.
!     B0BCCF
!     B1BCCF
!     B0ASTD
!     B1BSTD
!
!  BB0-BB13 -- COEFFIEIENTS FOR USE IN CALCULATION OF HEIGHT
!              GROWTH. SET IN SITSET. USED IN HTGF AND SITSET.
!              THESE COEFFS ARE USED IN ECS AND NWC.
!
!    IABFLG -- FLAG CONTROLLING WHETHER TO USE THE DEFAULT WYKOFF
!              HT-DBH COEFFICIENTS (IABFLG=1) OR THE WYKOFF COEFFICIENTS
!              CALIBRATED TO THE INPUT DATA (IABFLG=0).
!              INITIALLY SET IN **GRINIT**; USED AND POSSIBLY CHANGED
!              IN **CRATET**; USED IN **REGENT**.
!              (ALSO SEE VARIABLE LHTDRG IN THE CONTRL COMMON BLOCK)
!    ISILFT -- SILVAH FOREST TYPE: 0=NONE, 1=NORTHERN HARDWOOD,
!              2=NORTHERN HARDWOOD-HEMLOCK, 3=ALLEGHENY HARDWOOD,
!              4=OAK-HICKORY, 5=TRANSITION
!              DEFINED IN ENTRY SILFTY IN ***SDICAL***
!    ISTAGF -- STAGNATION FLAG 0 = OFF, 1 = ON
!              SET WITH FIELD 5 OF SDIMAX KEYWORD
!
!    MAXSDI -- FLAGS TO RETAIN USER SET SDIMAX VALUES, BY SPECIES,
!              THROUGHOUT THE SIMULATION (SN VARIANT)
!    LFLAGV -- LOGICAL VARIABLE FOR VARIANT-SPECIFIC USE
!              SN VARIANT -- USED TO PREVENT (=.T.) RESETING FOREST
!              TYPE CALCULATION FROM CYCLE TO CYCLE. SET IN INITRE
!    LBAMAX -- LOGICAL VARIABLE THAT IS SET TO TRUE WHEN A USER ENTERS
!              A BAMAX VALUE. USED IN SDICAL TO CHANGE BAMAX AS SDI MAX
!              CHANGES IF THE USER DID NOT ENTER A BAMAX; OTHERWISE, THE
!              USER DEFINED BAMAX IS USED.
!              IN THE SOUTHERN (SN) VARIANT, IT ALSO PREVENTS
!              RESETTING OF BAMAX, OR SDIDEF UPON CHANGES IN FOREST TYPE
!    QMDMSB -- QMD AT WHICH THE MATURE STAND BOUNDARY GOES INTO EFFECT.
!              USED IN SDI-BASED MORTALITY MODELS
!    SLPMSB -- SLOPE OF THE MATURE STAND BOUNDARY LINE.
!              USED IN SDI-BASED MORTALITY MODELS
!    CEPMSB -- INTERCEPT OF THE MATURE STAND BOUNDARY LINE.
!              USED IN SDI-BASED MORTALITY MODELS
!    EFFMSB -- MSB MORTALITY EFFICIENCY; PROPORTION OF THE TREE RECORD TO
!              BE KILLED; USED IN **MSBMRT**
!    DLOMSB -- MSB MORTALITY LOWER DBH LIMIT (GE); USED IN **MSBMRT**
!    DHIMSB -- MSB MORTALITY UPPER DBH LIMIT (LT); USED IN **MSBMRT**
!    MFLMSB -- MSB MORTALITY FLAG; 1 = FROM ABOVE, 2 = FROM BELOW, 3 =
!              THROUGHOUT, WITHIN THE DBH RANGE; USED IN **MSBMRT**
!     PTBAA -- POINT BASAL AREA; COMPUTED IN PTBAL WHICH IS CALLED FROM
!              DENSE.  NEEDED FOR DBH INC. PREDICTIONS IN WS.
!    PTBALT -- BASAL AREA IN LARGER TREES WITHIN THE POINT.
!              COMPUTED IN PTBAL WHICH IS CALLED FROM DENSE.
!              NEEDED FOR DBH INC. PREDICTIONS IN WS.
!      PCOM -- ALPHANUMERIC PLANT COMMUNITY REPRESENTATION.
!              (ALIAS: PLANT ASSOCIATION, ECOCLASS CODE)
!     PCOMX -- IS USED TO COORDINATE PV CODE / PV REFERENCE CODE
!              ERROR REPORTING FROM THE HABTYP ROUTINES IN SOME VARIANTS
!    CEPMRT -- INTERCEPT TERM IN MORTALITY FUNCTION
!    SLPMRT -- SLOPE TERM IN MORTALITY FUNCTION
!    TPAMRT -- RESIDUAL TREES PER ACRE LEAVING MORTS
!     IBASP -- SPECIES REPRESENTING PLURALITY OF BASAL AREA
!
!-----END SEGMENT
end module varcom_mod
