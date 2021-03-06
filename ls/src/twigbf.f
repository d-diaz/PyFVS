      SUBROUTINE TWIGBF(ISPC,H,D,VMAX,BBFV)
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  **TWIGBF---LS    DATE OF LAST REVISION:   07/11/08
C----------
C
C  ************** BOARD FOOT MERCHANTABILITY SPECIFICATIONS ********
C
C  BFVOL CALCULATES BOARD FOOT VOLUME OF ANY TREE LARGER THAN A MINIMUM
C  DBH SPECIFIED BY THE USER.  MINIMUM DBH CAN VARY BY SPECIES,
C  BUT CANNOT BE LESS THAN 2 INCHES.  DEFAULTS ARE 7 IN. FOR SOFTWOODS
C  AND 9 IN. FOR HARDWOODS.  MINIMUM MERCHANTABLE DBH IS
C  SET WITH THE BFVOLUME KEYWORD.
C
C  MERCHANTABLE TOP DIAMETER CAN BE SET WITH THE BFVOLUME KEYWORD
C  AT ANY VALUE BETWEEN 2 IN. AND ACTUAL DBH.  THIS DIAMETER IS
C  OUTSIDE BARK -- IF DIB IS DESIRED, ALLOWANCE FOR DOUBLE BARK
C  THICKNESS MUST BE MADE IN SPECIFICATION OF TOP DIAMETER.
C
C----------
      REAL B1(MAXSP),B2(MAXSP),B3(MAXSP),B4(MAXSP),BBFV,VMAX,D,H
      INTEGER ISPC
C----------
C  COEFFICIENTS FOR NET BOARD FOOT VOLUME EQUATION FOR ACCEPTABLE
C  TREES (TREE CLASS 1 & 2).
C----------
      DATA B1/
     &  2*168.57868,2*2969.2993,36276658.,2*35253.479,27980.016,
     &  28937072.,
     &  62.984496,5756054.6,2586729.4,2*168.57868,2*10925208.,
     &  15938236.,
     &  3*120.30581,3*1211352.6,400.48678,201.41217,3*711.68082,
     &  10925208.,
     &  7*1007.3288,3*8070.0366,3*393.32540,9103704.2,
     &  25*8070.0366/
      DATA B2/
     &  2*.39510939,2*.2551933,.14235722,2*.0,.33410389,.063071273,
     &  .22695026,.0,.054371839,2*.39510939,2*.022442414,.7571799,
     &  3*.27194223,3*.57651474,.31603106,.26548744,3*.0,.022442414,
     &  7*.000,3*.63809141,3*.19531946,.000,25*.63809141/
      DATA B3/
     &  2*.051243289,2*.017900628,.00082741036,2*.011088055,
     &  .0096929089,
     &  .0014004165,.32849793,.00079044754,.0013929982,2*.051243289,
     &  2*.00082185175,.00029248070,3*.17342255,3*.00012726733,
     & .045870491,
     &  .11156278,3*.099521009,.00082185175,7*.068868975,
     &  3*.00039508458,
     &  3*.064037756,.00017368079,25*.00039508458/
      DATA B4/
     &  2*3.1962314,2*2.7608809,2.9729355,2*2.8661399,3.2610843,
     &  3.1647187,
     &  26.890578,2.4631793,2.6363294,2*3.1962314,2*2.5637377,
     &  2.7398161,
     &  3*11.675789,3*1.8336385,3.4177655,6.4197635,3*5.8660766,
     &  2.5637377,
     &  7*4.3821328,3*1.3461604,3*3.6809576,1.882183,
     &  25*1.3461604/
C-----------------------------------------------------------------
C  LAKE STATES ACCEPTABLE TREE CLASS VOLUME EQUATION:
C  --RAILLE, GERHARD K., W.B. SMITH, C.A. WEIST. 1982. A NET VOLUME
C    EQUATION FOR MICHIGAN'S UPPER AND LOWER PENINSULAS. 12 P.
C    USDA FOREST SERVICE GEN TECH REPORT NC-80.
C
C          V = B1*SI**B2*[1-EXP(-B3*DBH)]**B4
C
C  WHERE:
C        V = VOLUME
C       SI = SITE INDEX
C      DBH = DIAMETER BREAST HEIGHT
C    B1-B4 = SPECIES SPECIFIC COEFFICIENTS
C------------------------------------------------------------------
C----------
C  COMPUTE TOTAL BOARD FOOT VOLUME (VMAX)
C----------
        VMAX=B1(ISPC)*SITEAR(ISPC)**B2(ISPC)*(1-EXP(-1.0*B3(ISPC)
     &       *D))**B4(ISPC)
C----------
C  COMPUTE MERCH BOARD FOOT VOLUME (BBFV)
C----------
        BBFV=VMAX
        RETURN
        END

