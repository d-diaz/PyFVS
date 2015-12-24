module esparm_mod
!ODE SEGMENT ESPARM
!----------
!  **ESPARM--PN   DATE OF LAST REVISION:  04/19/10
!----------
!
!     PARAMETERS FOR THE REGENERATION ESTABLISHMENT MODEL:
!
      INTEGER   NDBHCL,NSPSPE
      PARAMETER (NDBHCL=10,NSPSPE=14)
!
!     NDBHCL -- NUMBER OF DBH CLASSES FOR STUMP SPROUTS.  CHANGE DBHMID
!               IN BLKDAT TO CORRESPOND TO THE CORRECT NUMBER.
!     NSPSPE -- NUMBER OF SPROUTING SPECIES.  CHANGE ISPSPE IN BLKDAT
!               TO CORRESPOND TO THE CORRECT NUMBER.
!     NOTE: NDBHCL AND NSPSPE DEFINE AN IMAGINARY ARRAY WITH CELLS THAT
!     ARE NUMBERED CONSECUTIVELY.  THE NUMBER IN THE GRID INDEXES
!     SPECIES AND DIAMETER CLASS.  THE PRODUCT OF NDBHCL*NSPSPE CANNOT
!     EXCEED 999 BECAUSE ANY LARGER NUMBER WOULD CAUSE ISHOOT(I) TO
!     BECOME LARGER THAN A 10-DIGIT NUMBER.
!
!-----END SEGMENT
end module esparm_mod
