# Verilog Study Project
Verilog를 공부하고 테스트하기 목적으로 작성한 프로젝트입니다.

## 개발환경   
WINDOWS 10 64 BIT   
VSCODE     
IcarusVerilog    
Vivado 2018.2 (10번 프로젝트 이후에 적용)
        
## 참고 교재 or Link
[verilog hdl](https://book.naver.com/bookdb/book_detail.nhn?bid=1912296 "verilog hdl 교재")   

[Nandland](https://www.nandland.com/verilog/tutorials/index.html "Nandland")

## 기타 
GTKwave로 파형 볼 수 있도록 코드 작성   
SPI / AXI / Test Pattern Generator 같은 코드는 vivado 자료를 업로드 함

## How to Build
``` 
iverilog -o output.vvp source1.v source2.v sourcen.v
vvp output.vvp
```
source files should be included test bench file   
instruction of 'vvp' shows test bench file results.

it can run by gtkwave if you want to verificate waveform.
```
gtkwave blahblah.vcd
```
vcd filename can be found in test bench file(usally named '_tb' in the end)