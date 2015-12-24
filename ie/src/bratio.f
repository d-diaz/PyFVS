      FUNCTION BRATIO(IS,D,H)
      use prgprm_mod
      implicit none
C----------
C  **BRATIO--NI23   DATE OF LAST REVISION:  05/20/11
C----------
C FUNCTION TO COMPUTE BARK RATIOS AS A FUNCTION OF DIAMETER AND SPECIES.
C REPLACES ARRAY BKRAT IN NI VARIANT.
C----------
C  COMMONS
C
C  COMMONS
C----------
C  SPECIES ORDER:
C   1=WP,  2=WL,  3=DF,  4=GF,  5=WH,  6=RC,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=MH, 12=WB, 13=LM, 14=LL, 15=PI, 16=JU,
C  17=PY, 18=AS, 19=CO, 20=MM, 21=PB, 22=OH, 23=OS
C----------
      REAL BARK1(MAXSP),BARK2(MAXSP),H,D,BRATIO,TEMD
      INTEGER IMAP(MAXSP),IS,IEQN

      DATA BARK1/0.964, 0.851, 0.867, 0.915, 0.934, 0.950, 0.969,
     &    0.956, 0.937, 0.890, 0.934, 0.851, 0.969, 0.937, 0.000,
     &    0.000, 0.969, 0.950, 0.892, 0.950, 0.950, 0.892, 0.934/
      DATA BARK2/0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000,
     &    0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000,
     &    0.000, 0.000, 0.000, -.086, 0.000, 0.000, -.086, 0.000/
      DATA IMAP/     2,     2,     2,     2,     2,     2,     2,
     &        2,     2,     2,     2,     2,     2,     2,     1,
     &        1,     2,     2,     3,     2,     2,     3,     2/
C----------
C  PI, JU USE PP BARK EQUATION FROM CR VARIANT.
C  WB USE COEFFICIENTS FOR WL
C  LM AND PY USE COEFFICIENTS FROM TT FOR LM
C  LL USE COEFFICIENTS FOR AF
C  AS, MM, PB USE COEFFIECIENTS FOR AS FROM UT
C  CO, OH USE COEFFIECIENTS FOR OH FROM CR
C  OS USE COEFFEICIENTS FOR MH
C----------
      IEQN=IMAP(IS)
      TEMD=D
      IF(TEMD.LT.1.)TEMD=1.
C
      IF(IEQN .EQ. 1) THEN
        IF(BARK1(IS).EQ.0.0 .AND. BARK2(IS).EQ.0.0)THEN
          IF(TEMD.GT.19.)TEMD=19.
          BRATIO = 0.9002 - 0.3089*(1/TEMD)
        ELSE
          BRATIO=BARK1(IS)+BARK2(IS)*(1/TEMD)
        ENDIF
C
      ELSEIF(IEQN .EQ. 2)THEN
        BRATIO=BARK1(IS)
C
      ELSEIF(IEQN .EQ. 3)THEN
        BRATIO=BARK1(IS)+BARK2(IS)*(1.0/TEMD)
      ENDIF
C
      IF(BRATIO .GT. 0.99) BRATIO=0.99
      IF(BRATIO .LT. 0.80) BRATIO=0.80
C
      RETURN
      END

