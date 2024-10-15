         TITLE 'Standalone Test PRNO Instruction'
*
*        Function -
*
*          This module tests the PRNO instruction in a
*          standalone environment.
*
*        Operation -
*
*          PRNOTEST exercises PRNO QUERY, DRNG, and TRNG functions
*          and does plausibility checks on the results.
*
*          - If all tests pass, PRNOTEST enters an enabled wait state.
*
*          - If a test fails, the test sequence is aborted and a
*            disabled wait state DEAD is entered.
*
PRNOTEST CSECT
         USING *,0
         ORG   PRNOTEST+X'1A0'
         DC    X'00000001800000000000000000000200' # z/Arch restart PSW
         ORG   PRNOTEST+X'1D0'
         DC    X'0002000180000000000000000000DEAD' # z/Arch pgm new PSW
         ORG   PRNOTEST+X'200'
***
***      QUERY
***
         LGFI  R0,0           R0->function code 0
         MVC   PB(240),PBNULL clear parameter block
         LA    R1,PB          R1->parameter block
         PRNO  R2,R4          perform random number operation
         CLC   ERQUERY(16),PB compare with expected result
         BE    *+6            result OK
         DC    H'0'           disabled wait DEAD if result invalid
***
***      DRNG: FIPS known answer test
***
         LGFI  R0,131         R0->function code 3 with modifier: seed
         MVC   PB(240),PBNULL clear parameter block
         LA    R1,PB          R1->parameter block
         LA    R2,FO          R2->first  operand address
         LGFI  R3,0           R3->first  operand length
         LA    R4,SO          R2->second operand address
         LGFI  R5,64          R3->second operand length
         MVC   SO(64),ENTROPY provide predefined entropy
         PRNO  R2,R4          perform random number seed operation
         LGFI  R0,3           R0->function code 3: generate
         LA    R1,PB          R1->parameter block
         LA    R2,FO          R2->first  operand address
         LGFI  R3,64          R3->first  operand length
         LA    R4,SO          R2->second operand address
         LGFI  R5,0           R3->second operand length
         PRNO  R2,R4          perform random number generate operation
         CLC   ERFIPS(64),FO  compare with expected result
         BE    *+6            result OK
         DC    H'0'           disabled wait DEAD if result invalid
***
***      DRNG: Reseed and generate
***
         LGFI  R0,131         R0->function code 3 with modifier: reseed
         LA    R1,PB          R1->parameter block
         LA    R2,FO          R2->first  operand address
         LGFI  R3,0           R3->first  operand length
         LA    R4,SO          R2->second operand address
         LGFI  R5,64          R3->second operand length
         MVC   SO(64),PB+17   steal seed material (ignored by Hercules)
         PRNO  R2,R4          perform random number reseed operation
         LGFI  R0,3           R0->function code 3: generate
         LA    R1,PB          R1->parameter block
         LA    R2,FO          R2->first  operand address
         LGFI  R3,65536       R3->first  operand length
         LA    R4,SO          R2->second operand address
         LGFI  R5,0           R3->second operand length
         PRNO  R2,R4          perform random number generate operation
         CLC   FO(64),PBNULL  first 64 bytes zero ..
         BNE   *+6            .. is not plausible
         DC    H'0'           disabled wait DEAD if first 64 bytes zero
         LGFI  R3,FO+65536-63 last 64 bytes ..
         CLC   0(64,R3),PBNULL .. zero ..
         BNE   *+6            .. is not plausible
         DC    H'0'           disabled wait DEAD if last 64 bytes zero
***
***      TRNG Query
***
         LGFI  R0,112         R0->function code 112
         MVC   PB(240),PBNULL clear parameter block
         LA    R1,PB          R1->parameter block
         PRNO  R2,R4          perform random number operation
         CLC   TRQUERY(8),PB  compare with expected result
         BE    *+6            result OK
         DC    H'0'           disabled wait DEAD if result invalid
***
***      TRNG
***
         LGFI  R0,114         R0->function code 114: TRNG
         LA    R2,FO          R2->first  operand address
         LGFI  R3,64          R3->first  operand length
         LA    R4,SO          R2->second operand address
         LGFI  R5,64          R3->second operand length
         PRNO  R2,R4          perform random number generate operation
         CLC   FO(64),PBNULL  first operand zero ..
         BNE   *+6            .. is not plausible
         DC    H'0'           disabled wait DEAD if first operand zero
         CLC   SO(64),PBNULL  seconf operand zero ..
         BNE   *+6            .. is not plausible
         DC    H'0'           disabled wait DEAD if second operand zero
         LPSWE WAITPSW        load enabled wait PSW
         ORG   PRNOTEST+X'400'
WAITPSW  DC    X'07020001800000000000000000000000' enabled wait PSW
         ORG   PRNOTEST+X'480'
PB       DS    XL240          current parameter block
SO       DS    XL64           second operand
         ORG   PRNOTEST+X'600'
PBNULL   DC    240X'00'       empty parameter block
ERQUERY  DC    X'9000000000000000000000000000A000' expected query reslt
TRQUERY  DC    X'000000C000000020'  expected Hercules TRNG query result
ENTROPY  DC    X'3295117F02371270'  predefined entropy for
         DC    X'105A3783CFE0BF5A'  FIPS known answer test
         DC    X'C1408E6CEAC5AEEB'
         DC    X'D6D814BC827DC04D'
         DC    X'21A1E480E3D5F2E3'
         DC    X'78319ADE9BDDDA4C'
         DC    X'2E93B74E348D5EE3'
         DC    X'2ED46A1AE62566E0'
ERFIPS   DC    X'F1DFE8330811ECD1'  expected generate result for
         DC    X'0AEB68728FAC57B0'  FIPS known answer test
         DC    X'5DC8B4116DFCC066'
         DC    X'C4FBB654B317FB0E'
         DC    X'011265748F7929B0'
         DC    X'180366625DE0665B'
         DC    X'116C878B0F05BAD8'
         DC    X'319416258824DFDC'
         ORG   PRNOTEST+X'800'
FO       DS    0X             first operand
         YREGS ,
         END
