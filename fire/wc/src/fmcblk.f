!      BLOCK DATA FMCBLK
      SUBROUTINE FMCBLK()
      use fmprop_mod
      use prgprm_mod
      implicit none
C----------
C   **FMCBLK--FIRE-WC  DATE OF LAST REVISION:   08/15/06
C----------
COMMONS

      INTEGER J

C     GROUPING FOR THE JENKINS BIOMASS EQUATIONS FOR C REPORTING
C     SOFTWOODS
C       1=CEDAR/LARCH
C       2=DOUGLAS-FIR
C       3=TRUE FIR/HEMLOCK
C       4=PINE
C       5=SPRUCE
C     HARDWOODS
C       6=ASPEN/ALDER/COTTONWOOD/WILLOW
C       7=SOFT MAPLE/BIRCH
C       8=MIXED HARDWOOD
C       9=HARD MAPLE/OAK/HICKORY/BEECH
C      10=WOODLAND JUNIPER/OAK/MESQUITE

      BIOGRP = (/
     &  3, 3, 3, 3, 3,
     &  2, 3, 1, 1, 5, ! 10
     &  4, 4, 4, 4, 4,
     &  2, 1, 1, 3, 3, ! 20
     &  7, 6, 6, 7, 8,
     &  6, 6, 9,10, 1, ! 30
     &  4, 4, 3, 8, 8,
     &  8, 6, 2, 7 /)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;sw;pulp
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      FAPROP(1,1:101,1,1,1) = (/
     & 0.5000,0.4223,0.3567,0.3013,0.2544,0.2149,0.1799,0.1496,0.1215,
     & 0.0961,0.0747,0.0575,0.0441,0.0338,0.0259,0.0198,0.0152,0.0116,
     & 0.0089,0.0063,0.0045,0.0032,0.0024,0.0018,0.0014,0.0010,0.0008,
     & 0.0006,0.0005,0.0004,0.0003,0.0002,0.0002,0.0001,0.0001,0.0001,
     & 0.0001,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     & 0.0000,0.0000/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;sw;pulp
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      FAPROP(1,1:101,2,1,1) = (/
     & 0.0000,0.0257,0.0467,0.0638,0.0777,0.0888,0.0981,0.1057,0.1125,
     & 0.1181,0.1224,0.1253,0.1269,0.1275,0.1273,0.1266,0.1255,0.1241,
     & 0.1225,0.1210,0.1193,0.1176,0.1158,0.1140,0.1122,0.1105,0.1088,
     & 0.1072,0.1057,0.1043,0.1029,0.1015,0.1002,0.0990,0.0979,0.0968,
     & 0.0957,0.0947,0.0937,0.0928,0.0920,0.0911,0.0903,0.0896,0.0889,
     & 0.0882,0.0876,0.0869,0.0863,0.0858,0.0853,0.0848,0.0843,0.0838,
     & 0.0834,0.0830,0.0826,0.0822,0.0818,0.0815,0.0812,0.0809,0.0806,
     & 0.0803,0.0800,0.0798,0.0795,0.0793,0.0791,0.0789,0.0787,0.0785,
     & 0.0783,0.0782,0.0780,0.0778,0.0777,0.0775,0.0774,0.0773,0.0772,
     & 0.0771,0.0769,0.0768,0.0767,0.0766,0.0766,0.0765,0.0764,0.0763,
     & 0.0762,0.0762,0.0761,0.0760,0.0760,0.0759,0.0759,0.0758,0.0758,
     & 0.0757,0.0757/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;sw;pulp
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      FAPROP(1,1:101,3,1,1) = (/
     & 0.3520,0.3818,0.4095,0.4332,0.4534,0.4706,0.4859,0.4993,0.5119,
     & 0.5233,0.5330,0.5410,0.5472,0.5521,0.5560,0.5590,0.5614,0.5633,
     & 0.5647,0.5661,0.5672,0.5679,0.5684,0.5688,0.5690,0.5692,0.5693,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,0.5694,
     & 0.5694,0.5694/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;sw;saw
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      FAPROP(1,1:101,1,2,1) = (/
     & 0.7399,0.7034,0.6702,0.6403,0.6132,0.5885,0.5657,0.5446,0.5248,
     & 0.5061,0.4890,0.4734,0.4591,0.4461,0.4341,0.4229,0.4124,0.4026,
     & 0.3933,0.3844,0.3760,0.3681,0.3605,0.3532,0.3463,0.3396,0.3332,
     & 0.3270,0.3210,0.3152,0.3097,0.3043,0.2991,0.2941,0.2892,0.2844,
     & 0.2799,0.2754,0.2711,0.2669,0.2628,0.2589,0.2550,0.2513,0.2476,
     & 0.2441,0.2406,0.2372,0.2340,0.2307,0.2276,0.2246,0.2216,0.2187,
     & 0.2158,0.2130,0.2103,0.2077,0.2051,0.2025,0.2000,0.1976,0.1952,
     & 0.1929,0.1906,0.1883,0.1861,0.1839,0.1818,0.1797,0.1777,0.1757,
     & 0.1737,0.1718,0.1699,0.1680,0.1662,0.1644,0.1626,0.1608,0.1591,
     & 0.1574,0.1558,0.1541,0.1525,0.1509,0.1494,0.1478,0.1463,0.1448,
     & 0.1434,0.1419,0.1405,0.1391,0.1377,0.1363,0.1350,0.1337,0.1324,
     & 0.1311,0.1298/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;sw;saw
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      FAPROP(1,1:101,2,2,1) = (/
     & 0.0000,0.0183,0.0350,0.0502,0.0638,0.0762,0.0876,0.0981,0.1079,
     & 0.1169,0.1252,0.1327,0.1396,0.1459,0.1516,0.1570,0.1619,0.1665,
     & 0.1709,0.1750,0.1788,0.1824,0.1858,0.1890,0.1921,0.1950,0.1978,
     & 0.2005,0.2030,0.2054,0.2077,0.2100,0.2121,0.2142,0.2161,0.2180,
     & 0.2199,0.2216,0.2234,0.2250,0.2266,0.2282,0.2297,0.2311,0.2325,
     & 0.2339,0.2352,0.2365,0.2378,0.2390,0.2402,0.2414,0.2425,0.2436,
     & 0.2447,0.2458,0.2468,0.2478,0.2488,0.2498,0.2507,0.2517,0.2526,
     & 0.2535,0.2544,0.2553,0.2561,0.2570,0.2578,0.2586,0.2594,0.2602,
     & 0.2610,0.2617,0.2625,0.2632,0.2640,0.2647,0.2654,0.2661,0.2668,
     & 0.2675,0.2682,0.2688,0.2695,0.2701,0.2708,0.2714,0.2720,0.2727,
     & 0.2733,0.2739,0.2745,0.2751,0.2756,0.2762,0.2768,0.2774,0.2779,
     & 0.2785,0.2790/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;sw;saw
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      FAPROP(1,1:101,3,2,1) = (/
     & 0.1254,0.1338,0.1413,0.1481,0.1542,0.1597,0.1647,0.1694,0.1739,
     & 0.1780,0.1819,0.1853,0.1884,0.1912,0.1938,0.1962,0.1984,0.2005,
     & 0.2024,0.2042,0.2060,0.2076,0.2092,0.2107,0.2121,0.2135,0.2148,
     & 0.2160,0.2172,0.2184,0.2195,0.2206,0.2216,0.2226,0.2235,0.2244,
     & 0.2253,0.2261,0.2269,0.2277,0.2284,0.2292,0.2298,0.2305,0.2311,
     & 0.2317,0.2323,0.2329,0.2334,0.2339,0.2344,0.2348,0.2353,0.2357,
     & 0.2361,0.2365,0.2369,0.2372,0.2376,0.2379,0.2382,0.2385,0.2388,
     & 0.2390,0.2393,0.2395,0.2397,0.2399,0.2401,0.2403,0.2405,0.2407,
     & 0.2408,0.2410,0.2411,0.2412,0.2413,0.2414,0.2415,0.2416,0.2417,
     & 0.2418,0.2418,0.2419,0.2419,0.2420,0.2420,0.2420,0.2421,0.2421,
     & 0.2421,0.2421,0.2421,0.2421,0.2421,0.2421,0.2421,0.2421,0.2421,
     & 0.2421,0.2421/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;hw;all
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      FAPROP(1,1:101,1,1,2) = (/
     & 0.5307,0.4808,0.4375,0.3999,0.3671,0.3384,0.3125,0.2893,0.2678,
     & 0.2481,0.2307,0.2157,0.2028,0.1918,0.1822,0.1738,0.1664,0.1597,
     & 0.1536,0.1479,0.1428,0.1381,0.1338,0.1298,0.1260,0.1225,0.1191,
     & 0.1159,0.1129,0.1099,0.1072,0.1045,0.1019,0.0995,0.0971,0.0948,
     & 0.0926,0.0905,0.0885,0.0865,0.0846,0.0828,0.0810,0.0793,0.0776,
     & 0.0760,0.0744,0.0729,0.0715,0.0700,0.0686,0.0673,0.0660,0.0647,
     & 0.0635,0.0623,0.0611,0.0600,0.0589,0.0578,0.0567,0.0557,0.0547,
     & 0.0537,0.0528,0.0519,0.0510,0.0501,0.0492,0.0484,0.0476,0.0468,
     & 0.0460,0.0452,0.0445,0.0437,0.0430,0.0423,0.0416,0.0410,0.0403,
     & 0.0397,0.0391,0.0384,0.0379,0.0373,0.0367,0.0361,0.0356,0.0350,
     & 0.0345,0.0340,0.0335,0.0330,0.0325,0.0320,0.0316,0.0311,0.0307,
     & 0.0302,0.0298/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;hw;all
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      FAPROP(1,1:101,2,1,2) = (/
     & 0.0000,0.0213,0.0396,0.0553,0.0689,0.0807,0.0911,0.1003,0.1086,
     & 0.1160,0.1225,0.1279,0.1325,0.1363,0.1395,0.1423,0.1446,0.1467,
     & 0.1485,0.1501,0.1515,0.1528,0.1539,0.1549,0.1558,0.1566,0.1573,
     & 0.1580,0.1587,0.1593,0.1599,0.1604,0.1609,0.1614,0.1619,0.1623,
     & 0.1627,0.1631,0.1635,0.1639,0.1642,0.1646,0.1649,0.1652,0.1656,
     & 0.1659,0.1662,0.1665,0.1668,0.1670,0.1673,0.1676,0.1679,0.1681,
     & 0.1684,0.1686,0.1689,0.1691,0.1694,0.1696,0.1698,0.1701,0.1703,
     & 0.1705,0.1708,0.1710,0.1712,0.1714,0.1716,0.1718,0.1720,0.1723,
     & 0.1725,0.1727,0.1729,0.1731,0.1733,0.1734,0.1736,0.1738,0.1740,
     & 0.1742,0.1744,0.1746,0.1747,0.1749,0.1751,0.1753,0.1754,0.1756,
     & 0.1758,0.1759,0.1761,0.1762,0.1764,0.1766,0.1767,0.1769,0.1770,
     & 0.1772,0.1773/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;hw;all
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      FAPROP(1,1:101,3,1,2) = (/
     & 0.2885,0.3046,0.3190,0.3317,0.3427,0.3524,0.3612,0.3691,0.3765,
     & 0.3834,0.3895,0.3948,0.3993,0.4031,0.4065,0.4094,0.4120,0.4143,
     & 0.4164,0.4184,0.4202,0.4218,0.4233,0.4247,0.4260,0.4272,0.4284,
     & 0.4295,0.4305,0.4315,0.4324,0.4333,0.4341,0.4349,0.4357,0.4364,
     & 0.4371,0.4378,0.4384,0.4390,0.4395,0.4401,0.4406,0.4410,0.4415,
     & 0.4419,0.4423,0.4427,0.4431,0.4434,0.4438,0.4441,0.4444,0.4446,
     & 0.4449,0.4451,0.4454,0.4456,0.4458,0.4460,0.4461,0.4463,0.4464,
     & 0.4466,0.4467,0.4468,0.4469,0.4470,0.4471,0.4472,0.4472,0.4473,
     & 0.4473,0.4474,0.4474,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,
     & 0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,
     & 0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,
     & 0.4475,0.4475/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;hw;all
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      FAPROP(1,1:101,1,2,2) = (/
     & 0.5307,0.4808,0.4375,0.3999,0.3671,0.3384,0.3125,0.2893,0.2678,
     & 0.2481,0.2307,0.2157,0.2028,0.1918,0.1822,0.1738,0.1664,0.1597,
     & 0.1536,0.1479,0.1428,0.1381,0.1338,0.1298,0.1260,0.1225,0.1191,
     & 0.1159,0.1129,0.1099,0.1072,0.1045,0.1019,0.0995,0.0971,0.0948,
     & 0.0926,0.0905,0.0885,0.0865,0.0846,0.0828,0.0810,0.0793,0.0776,
     & 0.0760,0.0744,0.0729,0.0715,0.0700,0.0686,0.0673,0.0660,0.0647,
     & 0.0635,0.0623,0.0611,0.0600,0.0589,0.0578,0.0567,0.0557,0.0547,
     & 0.0537,0.0528,0.0519,0.0510,0.0501,0.0492,0.0484,0.0476,0.0468,
     & 0.0460,0.0452,0.0445,0.0437,0.0430,0.0423,0.0416,0.0410,0.0403,
     & 0.0397,0.0391,0.0384,0.0379,0.0373,0.0367,0.0361,0.0356,0.0350,
     & 0.0345,0.0340,0.0335,0.0330,0.0325,0.0320,0.0316,0.0311,0.0307,
     & 0.0302,0.0298/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;hw;all
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      FAPROP(1,1:101,2,2,2) = (/
     & 0.0000,0.0213,0.0396,0.0553,0.0689,0.0807,0.0911,0.1003,0.1086,
     & 0.1160,0.1225,0.1279,0.1325,0.1363,0.1395,0.1423,0.1446,0.1467,
     & 0.1485,0.1501,0.1515,0.1528,0.1539,0.1549,0.1558,0.1566,0.1573,
     & 0.1580,0.1587,0.1593,0.1599,0.1604,0.1609,0.1614,0.1619,0.1623,
     & 0.1627,0.1631,0.1635,0.1639,0.1642,0.1646,0.1649,0.1652,0.1656,
     & 0.1659,0.1662,0.1665,0.1668,0.1670,0.1673,0.1676,0.1679,0.1681,
     & 0.1684,0.1686,0.1689,0.1691,0.1694,0.1696,0.1698,0.1701,0.1703,
     & 0.1705,0.1708,0.1710,0.1712,0.1714,0.1716,0.1718,0.1720,0.1723,
     & 0.1725,0.1727,0.1729,0.1731,0.1733,0.1734,0.1736,0.1738,0.1740,
     & 0.1742,0.1744,0.1746,0.1747,0.1749,0.1751,0.1753,0.1754,0.1756,
     & 0.1758,0.1759,0.1761,0.1762,0.1764,0.1766,0.1767,0.1769,0.1770,
     & 0.1772,0.1773/)

C DATA Statement Debug Information
C         Variant   = WC
C        Interval   = 1 yrs
C      Field tags   = PWW;hw;all
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      FAPROP(1,1:101,3,2,2) = (/
     & 0.2885,0.3046,0.3190,0.3317,0.3427,0.3524,0.3612,0.3691,0.3765,
     & 0.3834,0.3895,0.3948,0.3993,0.4031,0.4065,0.4094,0.4120,0.4143,
     & 0.4164,0.4184,0.4202,0.4218,0.4233,0.4247,0.4260,0.4272,0.4284,
     & 0.4295,0.4305,0.4315,0.4324,0.4333,0.4341,0.4349,0.4357,0.4364,
     & 0.4371,0.4378,0.4384,0.4390,0.4395,0.4401,0.4406,0.4410,0.4415,
     & 0.4419,0.4423,0.4427,0.4431,0.4434,0.4438,0.4441,0.4444,0.4446,
     & 0.4449,0.4451,0.4454,0.4456,0.4458,0.4460,0.4461,0.4463,0.4464,
     & 0.4466,0.4467,0.4468,0.4469,0.4470,0.4471,0.4472,0.4472,0.4473,
     & 0.4473,0.4474,0.4474,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,
     & 0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,
     & 0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,0.4475,
     & 0.4475,0.4475/)

      END
