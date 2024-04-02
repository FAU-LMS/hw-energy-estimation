[![License](https://img.shields.io/badge/license-BSD%203--Clause-green)](https://opensource.org/licenses/BSD-3-Clause)
   



# Documentation of Relative Expected HW Energy Demand (REHWED) Calculation

## Introduction

### 1. Feature Extraction
Use the following command to extract Valgrind processor events of your anchor and test bitstreams:

- Anchor:

    Valgrind --tool=callgrind --simulate-cache=yes --dump-instr=yes --collect-jumps=yes --branch-sim=yes --I1=32768,8,64 --D1=32768,8,64 --LL=12582912,64,24   [decoder command] >> [bitstreamAnchor].log


- Test:
    Valgrind --tool=callgrind --simulate-cache=yes --dump-instr=yes --collect-jumps=yes --branch-sim=yes --I1=32768,8,64 --D1=32768,8,64 --LL=12582912,64,24   [decoder command] >> [bitstreamTest].log


Export your SW profiling with Valgrind in two separate folders in the directory Import.


### 2. REHWED Evaluation
Open MainEvaluateREHWED.m in Matlab, adapt the names of the two folders in l.19 and l.20 accordingly. Run script!

## References
[1] M. Kränzler, C. Herglotz, and A. Kaup, "Predicting the Energy Demand of a Hardware Video Decoder with Unknown Design Using Software Profiling", https://doi.org/10.48550/arXiv.2402.09926, Feb. 2024. <br/>


## License

BSD 3-Clause. For details, see [LICENSE](https://github.com/FAU-LMS/HWComplexityScore/blob/main/LICENSE).