      FUNCTION BRATIO(IS,D,H)
      use prgprm_mod
      implicit none
C----------
C  **BRATIO--SO  DATE OF LAST REVISION:  09/09/13
C----------
C
C  FUNCTION TO COMPUTE BARK RATIOS, OR CONSTANTS.  THIS ROUTINE IS
C  VARIANT SPECIFIC AND EACH VARIANT USES ONE OR MORE OF THE ARGUMENTS
C  PASSED TO IT.
C
C  SPECIES LIST FOR SO VARIANT
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C----------
COMMONS
      REAL BARKB(3,MAXSP),BRDAT(MAXSP),H,D,BRATIO,DIB,TEMD
      INTEGER IS
C
      DATA BRDAT /
     & .964, .851, .867, .915, .934, .950, .969, .956, .000, .890,
     & .000, .915, .937, .903, .000, .969, .851, .950, .000, .000,
     & .000, .000, .000, .950, .000, .000, .000, .000, .000, .000,
     & .000, .867, .000/
C
      DATA BARKB/
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &   -0.1593,    0.8911,        2.,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.904973,  1.000000,  1.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.933710,  1.000000,  1.000000,
     &  0.933290,  1.000000,  1.000000,
     &  0.075256,  0.949670,  2.000000,
     &  0.075256,  0.949670,  2.000000,
     &  0.083600,  0.947820,  2.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.075256,  0.949670,  2.000000,
     &  0.075256,  0.949670,  2.000000,
     &  -0.30722,   0.95956,        2.,
     &  0.075256,  0.949670,  2.000000,
     &  0.075256,  0.949670,  2.000000,
     &  0.900000,  1.000000,  1.000000,
     &  0.900000,  1.000000,  1.000000,
     &  0.000000,  0.000000,  0.000000,
     &  0.900000,  1.000000,  1.000000/
C----------
C  SPECIES FORM WC VARAINT
C  NOTE: COEFFICIENTS FOR SPECIES 312, 431, & 815 IN PILLSBURY &
C  KIRKLEY ARE METRIC. INTERCEPT IS DIVIDED BY 2.54 TO CONVERT THESE
C  EQUATIONS TO ENGLISH.
C  BARK COEFS
C  202,15,122,116,81 FROM WALTERS ET.AL. RES BULL 50
C  312,431,815  FROM PILLSBURY AND KIRKLEY RES NOTE PNW 414
C  242,93,108   FROM WYKOFF ET.AL. RES PAPER INT 133
C
C  EQUATION TYPES
C  1  DIB = a * DOB ** b
C  2  DIB = a + bDOB
C  3  DIB = a*DOB = a * DOB ** b, (eQ.1), WITH b= 1.0
C  MODEL TYPE 1
C----------
      SELECT CASE (IS)
C----------
C  SPECIES FROM WC,CA VARIANT
C----------
      CASE(9,15,19:23,25,26,27,28:31,33)
C
        IF (D .GT. 0) THEN
          IF(BARKB(3,IS) .EQ. 1.)THEN
            DIB=BARKB(1,IS)*D**BARKB(2,IS)
            BRATIO=DIB/D
          ELSEIF (BARKB(3,IS) .EQ. 2.)THEN
            DIB=BARKB(1,IS) + BARKB(2,IS)*D
            BRATIO=DIB/D
          ENDIF
        ELSE
          BRATIO = 0.99
        ENDIF
C----------
C  FROM UT(12) JU
C----------
      CASE(11)
        TEMD=D
        IF(TEMD.LT.1.)TEMD=1.
        IF(TEMD.GT.19.)TEMD=19.
        BRATIO = 0.9002 - 0.3089*(1/TEMD)
C----------
C  BARK RATIO IS CONSTANT
C----------
      CASE DEFAULT
        BRATIO=BRDAT(IS)
      END SELECT
C
      IF(BRATIO .GT. 0.99) BRATIO= 0.99
      IF(BRATIO .LT. 0.80) BRATIO= 0.80
C
      RETURN
      END
