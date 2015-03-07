      SUBROUTINE ESPADV
      use esparm_mod
      use prgprm_mod
      use escomn_mod
      use pden_mod
      use plot_mod
      implicit none
C----------
C   **ESPADV--NI23   DATE OF LAST REVISION:   04/01/08
C----------
COMMONS
      INCLUDE 'ESCOM2.F77'
C
      INCLUDE 'ESHAP.F77'
C
      INCLUDE 'ESHAP2.F77'
C
C     PREDICT PROBS OF ADVANCE SPECIES. P(ADVANCE WHITE PINE)
C
      REAL PN
C
      IF(IPREP.GT.3) GO TO 20
      PN= -1.8733029 +CHAB(IHAB,1) -1.5893204*XCOS -3.7865858*XSIN
     &  -3.9780395*SLO -0.228477*TIME +.0251953*BAA -.0003143*BAASQ
     &  +0.0385460*ELEV +CPRE(IPREP,1)
      IF(OVER(1,NNID).GT.9.95) PN=PN +0.6721733
      IF(IFO.EQ.7.OR.IFO.EQ.16) PN=PN -1.1379313
      PADV(1)=(1.0/(1.0+EXP(-PN)))*OCURHT(IHAB,1)*XESMLT(1)
     &  *OCURNF(IFO,1)
C
C     P(ADVANCE WESTERN LARCH).
C
   20 CONTINUE
      IF(IPREP.GT.2) GO TO 21
      PN= -5.0092864 +0.2560369*XCOS +1.5965058*XSIN +CHAB(IHAB,2)
     &  -0.1719499*SLO
      IF(OVER(2,NNID).GT.9.95) PN=PN +2.1039474
      PADV(2)= (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,2)  *XESMLT(2)
     &  *OCURNF(IFO,2)
C
C     P(ADVANCE DOUGLAS-FIR). 3/22/87
C
   21 CONTINUE
      PN= -.691118 +CHAB(IHAB,3)+CPRE(IPREP,3)-.224932*XCOS-.461642*
     &  XSIN +1.390878*SLO+.0151871*BAA -.0000814*BAASQ -.0137814*ELEV
      IF(OVER(3,NNID).GT.9.95) PN=PN +1.0047915
      PADV(3)=(1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,3)   *XESMLT(3)
     &  *OCURNF(IFO,3)
C
C     P(ADVANCE GRAND FIR).
C
      PN= -2.8426666  +CHAB(IHAB,4) +CPRE(IPREP,4)
     &  +1.3658730*SLO+ .0072484*BAA -.0000307*BAASQ +.1643756*ELEV
     &  -0.0020789*ELEVSQ -0.1182024*REGT -0.1092534*BWAF
      IF(OVER(4,NNID).GT.9.95) PN=PN +1.0538200
      PADV(4) = (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,4) *XESMLT(4)
     &  *OCURNF(IFO,4)
C
C     P(ADVANCE WESTERN HEMLOCK)
C
      PN= -1.8378316 +3.8978596*XCOS -0.4192431*XSIN -0.0317794*SLO
     &  +CPRE(IPREP,5)
      IF(OVER(5,NNID).GT.9.95) PN=PN +1.1918564
      PADV(5)=(1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,5)   *XESMLT(5)
     &  *OCURNF(IFO,5)
C
C     P(ADVANCE WESTERN REDCEDAR) 3/19/87
C
      PN= -0.3039302 +0.6771111*XCOS -1.0103344*XSIN +1.7631934*SLO
     &  +.0057510*BAA -.0390010*ELEV -.0818480*TIME  +CPRE(IPREP,6)
      IF(IFO.EQ.4) PN=PN -1.1554776
      IF(OVER(6,NNID).GT.9.95) PN=PN +1.4044088
      IF(IPHY.EQ.1) PN=PN +1.1103909
      PADV(6)= (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,6)  *XESMLT(6)
     &  *OCURNF(IFO,6)
C
C     P(ADVANCE LODGEPOLE PINE). 3/25/87
C
      IF(IPREP.GT.3) GO TO 28
      PN= -7.8876414 +CHAB(IHAB,7) -1.7125410*SLO +0.2981326*BAALN
     &  +0.0457937*ELEV
      IF(OVER(7,NNID).GT.9.95) PN=PN+ 2.4799900
      PADV(7)= (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,7)  *XESMLT(7)
     &  *OCURNF(IFO,7)
C
C     P(ADVANCE ENGELMANN SPRUCE)   10/03/89
C
   28 CONTINUE
      PN= -12.2236052 +0.2787733*ELEV -.0019948*ELEVSQ
     &  -.0924103*REGT +.1547716*BWB4 -.0478975*BWAF +CPRE(IPREP,8)
      IF(OVER(8,NNID).GT.9.95) PN=PN +1.4522984
      IF(IFO.EQ.19.OR.IFO.EQ.20) PN=PN +1.1484108
      IF(IFO.EQ.14.OR.IFO.EQ.16) PN=PN +0.9481026
      IF(IFO.EQ.4) PN=PN +0.8911886
      IF(IFO.EQ.5) PN=PN +0.9723801
      PADV(8)= (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,8)  *XESMLT(8)
     &  *OCURNF(IFO,8)
C
C     P(ADVANCE SUBALPINE FIR)   9/13/89
C
      IF(IPREP.GT.3) GO TO 32
      PN= -14.9235325+CHAB(IHAB,9) +.2327975*XCOS -.8445729*XSIN
     &  +.0810013*SLO +CPRE(IPREP,9) +.0053038*BAA +.4097059*ELEV
     &  -.0603046*REGT -.0542131*BWAF -.0033011*ELEVSQ
      IF(OVER(9,NNID).GT.9.95) PN=PN +1.6659029
      PADV(9)= (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,9)  *XESMLT(9)
     &  *OCURNF(IFO,9)
C
C     P(ADVANCE PONDEROSA PINE) 3/24/87
C
   32 CONTINUE
      IF(IPREP.GT.3) GO TO 34
      PN= -2.0755525 -2.5323539*XCOS -0.5925702*XSIN -0.5511553*SLO
     &  +.0227489*BAA -.0002398*BAASQ -.1262596*REGT -.0857334*BWAF
     &  +CHAB(IHAB,10) +CPRE(IPREP,10)
      IF(IFO.EQ.19.OR.IFO.EQ.20) PN=PN +1.5321411
      IF(OVER(10,NNID).GT.9.95) PN=PN +1.0523320
      PADV(10)= (1.0/(1.0+EXP(-PN))) * OCURHT(IHAB,10)*XESMLT(10)
     &  *OCURNF(IFO,10)
C
C     P(ADVANCE OTHER SPECIES)
   34 CONTINUE
      PADV(11)=0.0
      PADV(12)=0.0
      PADV(13)=0.0
      PADV(14)=0.0
      PADV(15)=0.0
      PADV(16)=0.0
      PADV(17)=0.0
      PADV(18)=0.0
      PADV(19)=0.0
      PADV(20)=0.0
      PADV(21)=0.0
      PADV(22)=0.0
      PADV(23)=0.0
C
      RETURN
      END
