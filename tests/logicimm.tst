logopt notime 
sysclear 
archmode z 
ostailor null 
*Testcase logicimm assembled 23 Sep 2015 12:49:32 by BLDHTC EXEC 
r    1A0=00000001800000000000000000000200
r    1D0=0002000180000000FFFFFFFFDEADDEAD
r    200=1B00B2B0083041000008411000014120
r    210=08004410024044100244441002484410
r    220=024C4410025044100254412020018910
r    230=000146000212D407
r    238=08300838B2B202589400200094002008
r    248=96002010960020189700202097002028
r    258=00020001800000000000000000000000
r    800=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
r    810=00000000000000000000000000000000
r    820=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
r    838=0000000000000800
restart 
pause 1 
*Compare
r 800.10
*Want               01020408 10204080 01020408 10204080
*Compare
r 810.10
*Want               01020408 10204080 01020408 10204080
*Compare
r 820.10
*Want               FEFDFBF7 EFDFBF7F FEFDFBF7 EFDFBF7F
*Compare
r 830.8
*Want               00000000 00000800
*Done
quit 
