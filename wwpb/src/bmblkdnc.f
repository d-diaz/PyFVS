      BLOCK DATA BMBLKD
      use prgprm_mod
      implicit none
C----------
C  **BMBLKD NC--WESTWIDE PINE BEETLE MODEL
C           Northern California (Klamath Mountains) FVS variant
C  Created 5/31/05 ajm, based on bmblkso.f
C----------
***********************************************************************
* The following Westwide Pine Beetle Model variable initializations
* were originally within the subroutine BMINIT code.
* It was moved to this BLOCK DATA subprogram to satisfy the FORTRAN
* standards enforced by Lahey FORTRAN compiler.
* 08/16/94 Lance R. David
*
* Ammended 4/10/00.  Made host tree species and main pine beetle species
* undefined; that is, users must now explicitly define them.
*
* This subroutine is identical to bmblkd routine for SO variant except for the
* species-specific falldown rates.  For these, I am using Table 4.12.3 of the
* FFE addendum (Reinhard and Crookston, May, '05).
* Species therein having a falldown multiplier greater than 1 are being assigned
* a "medium" falldown rate herein.  For those species in FFE having a
* falldown rate multiplier less than or equal to one, I am assigning a WWPBM
* falldown rate of "slow" (=code of "3")
***********************************************************************

C.... Parameter include files.

      INCLUDE 'PPEPRM.F77'
      INCLUDE 'BMPRM.F77'

C.... Common include files.

      INCLUDE 'BMCOM.F77'
      INCLUDE 'BMRCOM.F77'

C.... Data statements

C     Logical variable to control initialization of beetle model. True
C     means that subroutine BMINIT needs to be called.
C
      DATA LBMINT/.TRUE./

c Defaults: PBSPEC= 1 : Mountain Pine Beetle is simulated
c           NBGEN=  1 : 1 generation of PBSPEC per year
c           NIBGEN= 2 : 2 generation of Ips per year
c           Keywords can modify

c      DATA PBSPEC/1/, NBGEN/1/, NIBGEN/2/
      DATA  NBGEN/1/, NIBGEN/2/
c Defaults: IPSON= false  :Ips is NOT a driving variable
c           IPSMIN= 2     :smallest size class Ips will attack
c           IPSMAX= 5     :biggest size class that Ips will kill tree in
c                          (but will attack larger classes)
C           PFSLSH=.9     :prop slash to fill before attacking trees
c           Keywords can modify

      DATA IPSON/.FALSE./, IPSMIN/2/, IPSMAX/5/
      DATA PFSLSH/0.9/

C Default host tree species is now turned OFF.  User must define via keyword!
C
C  Klamath (NC) FVS species are:   OC SP DF WF  M IC BO TO RF PP OTH
C
      DATA (HSPEC(1,I), I=1,MAXSP) /0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0/
      DATA (HSPEC(2,I), I=1,MAXSP) /0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0/
      DATA (HSPEC(3,I), I=1,MAXSP) /0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0/

c      DATA (HSPEC(1,I), I=1,MAXSP) /0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0/
c      DATA (HSPEC(2,I), I=1,MAXSP) /0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0/
c      DATA (HSPEC(3,I), I=1,MAXSP) /0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0/

c Defaults: breakpoints for the DBH size classes. There can be no more than
c           NSCL of these. The computation which follows computes a rough
c           value for the basal area in each size class. "Rough" since it
c           has no treelist as a basis.

      DATA UPSIZ/3, 6, 9, 12, 15, 18, 21, 25, 30, 50/

C Defaults: DEAD WOODY POOL DBH SIZE CLASSES

      DATA WPSIZ/10, 20, 60/

C Defaults: Species falldown rates (1=fast,2=medium,3=slow) for standing dead
C Klamath FVS species are:
C                 OC SP DF WF  M IC BO TO RF PP OTH
      DATA ISPFLL /3, 2, 3, 3, 2, 3, 2, 2, 3, 2, 2/

C Note: above falldown rates arbitrarily assigned by Andrew McMahan 5/31/05
C using data from table 4.12.3 FFE addendum (Reinhardt and Crookston, 2005)  If
C the falldown multipliers in FFE addendum were greater than 1, then herein the
C species is assigned a "medium" falldown rate.  Otherwise "slow".
C The WWPB Model "fast" fall down rate is extremely fast (20% per year) relative
C to FFE's, so it wont be used.

C Defaults: Falldown rates (standing -> dead) for the different pool qualities
C           (fast, medium, slow)

      DATA FALLRT /0.2, 0.1, 0.05/

c Defaults: The smallest attrative size class varies with species.
c           MPB & WPB wont go into stands with only trees < 6 inches (sc<3),
c           and Ips won't see stands with trees less than 3 inches only.
c           Keyword can modify

      DATA ISCMIN/3,3,2/

c Defaults: Seeds for the random number generator BMRANN.

      DATA BMS0/55329D0/, BMSS/55329./

      END
