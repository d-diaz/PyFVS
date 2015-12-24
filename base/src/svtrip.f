      SUBROUTINE SVTRIP (IBASE,IT1)
      use svdata_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     STAND VISUALIZATION GENERATION
C     N.L.CROOKSTON -- RMRS MOSCOW -- NOVEMBER 1998
C
C     UPDATES THE VISUALIZATION FOR RECORD TRIPLING.
C
C     CALLED FROM TRIPLE.
C     INPUT IBASE, IS THE BASE TREE RECORD, IT1 IS THE FIRST
C     TRIPLE.
C
      INTEGER NRT(3),ITR(3)
      INTEGER IT1,IBASE,NR,ISVOBJ,I,NTOC
      ITR(1)=IBASE
      ITR(2)=IT1
      ITR(3)=IT1+1
C
C     GET THE NUMBER OF OBJECTS USED TO REPRESENT THE BASE TREE.
C
      NR = 0

      DO ISVOBJ=1,NSVOBJ
         IF (IOBJTP(ISVOBJ).EQ.1 .AND. IS2F(ISVOBJ).EQ.IBASE) NR = NR +1
      ENDDO

      IF (NR.LE.1) RETURN
C
C     COMPUTE THE NUMBER OF OBJECTS THAT EACH TRIPLE WILL GET.
C
      NRT(1)=IFIX(FLOAT(NR)*.6+.5)
      NRT(2)=MAX(0,IFIX(FLOAT(NR-NRT(1))*.625+.5))
      NRT(3)=MAX(0,NR-NRT(1)-NRT(2))
C
      IF (NRT(2).LE.0) RETURN
C
C     PROCESS THE TRIPLES.
C
      I = 1
      NTOC=NRT(1)
      DO ISVOBJ = 1,NSVOBJ
         IF (IS2F(ISVOBJ).EQ.IBASE .AND. IOBJTP(ISVOBJ).EQ.1) THEN
            IS2F(ISVOBJ) = ITR(I)
            NTOC = NTOC -1
            IF (NTOC.EQ.0) THEN
               I = I + 1
               IF (I.GT.3) RETURN
               NTOC = NRT(I)
               IF (NTOC.EQ.0) RETURN
            ENDIF
         ENDIF
      ENDDO

      RETURN
      END
