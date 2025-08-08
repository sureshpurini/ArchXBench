```
@inproceedings{purini2025mlcad,
  author       = {Suresh Purini and Siddhant Garg and Mudit Gaur and Sankalp Bhat and Arun Ravindran},
  title        = {ArchXBench: A Complex Digital Systems Benchmark Suite for LLM Driven RTL Synthesis},
  booktitle    = {Proceedings of the 7th ACM/IEEE International Symposium on Machine Learning for CAD (MLCAD)},
  year         = {2025},
  pages        = {pp.\,xx--yy},
  month        = sep,
  address      = {Santa Cruz, California, USA},
  publisher    = {ACM and IEEE},
}
```
# ArchXBench
```
                   _    __   ______                  _     
    /\            | |   \ \ / /  _ \                | |    
   /  \   _ __ ___| |__  \ V /| |_) | ___ _ __   ___| |__  
  / /\ \ | '__/ __| '_ \  > < |  _ < / _ \ '_ \ / __| '_ \ 
 / ____ \| | | (__| | | |/ . \| |_) |  __/ | | | (__| | | |
/_/    \_\_|  \___|_| |_/_/ \_\____/ \___|_| |_|\___|_| |_|
```

---

## Level 0: Logic Building Blocks

Fundamental combinational and sequential primitives (multiplexers, decoders, encoders, registers, counters, simple control) that serve as the foundation for all higher-level designs.

| S.No | Circuit                                                                 |
|------|-------------------------------------------------------------------------|
| 1    | Binary Encoder                                                          |
| 2    | Bit Manipulation Unit (rotate, mask, pack, unpack).                     |
| 3    | Clock Divider.                                                          |
| 4    | 4-bit Comparator.                                                       |
| 5    | 8-bit Comparator using two 4-bit Comparators.                           |
| 6    | 2-to-4 Decoder.                                                         |
| 7    | 3-to-8 Decoder using 2-to-4 Decoders.                                   |
| 8    | 1-to-2 demultiplexer.                                                   |
| 9    | 1-to-4 demultiplexer using 1-to-2 demultiplexers.                       |
| 10   | Loadable Down Counter.                                                  |
| 11   | Gray Code Counter.                                                      |
| 12   | Johnson Counter                                                         |
| 13   | 2-to-1 multiplexer.                                                     |
| 14   | 4-to-1 multiplexer using 2-to-1 multiplexers                            |
| 15   | Priority Encoders                                                       |
| 16   | Ring Counter                                                            |
| 17   | SIPO 8-bit Shift Register                                               |
| 18   | SISO 8-bit Shift Register                                               |
| 19   | PISO 8-bit Shift Register                                               |
| 20   | Up Counter.                                                             |



---

## Level 1a: Simple Arithmetic Circuits

Basic integer and bit-wise operators such as ripple-carry adders, small look-ahead adders, shift-and-add multipliers, barrel shifters, LFSRs, and lookup-based S-Boxes.

| S.No | Circuit                                                             |
|------|---------------------------------------------------------------------|
| 1    | 32-bit Ripple Carry Adder                                           |
| 2    | 8-bit Carry Look-Ahead Adder                                        |
| 3    | Barrel Shifter                                                      |
| 4    | Linear Feedback Shift Register (LFSR) for Stream Cipher Primitives  |
| 5    | GF(2⁸) Field Multiplier for AES MixColumns Operation.               |
| 6    | S-Box Implementation using Lookup Table and Logic Optimization.     |

---

## Level 1b: Hierarchical and Parametric Designs

Parameterizable arithmetic modules assembled hierarchically (e.g., ripple-carry adders with CLA blocks, carry-skip/select adders, parametric multipliers, and approximate adders).

| S.No | Circuit                                                             |
|------|---------------------------------------------------------------------|
| 1    | 32-bit Ripple Carry Adder with 4-bit CLA.                           |
| 2    | 32-bit Carry Skip Adder with 4-bit Carry Skip Blocks.               |
| 3    | 32-bit Carry Select Adder with 4-bit Blocks.                        |
| 4    | Parametric Shift-and-Add Integer Multiplier.                        |
| 5    | Approximate Adder (e.g., Lower-Part OR Adder).                      |


---

## Level 1c: Complex Arithmetic Circuits

High-performance integer units: parallel-prefix adders (Kogge-Stone, Brent-Kung), tree multipliers (Wallace, Dadda), and both restoring and non-restoring integer dividers.

| S.No | Circuit                             |
|------|-------------------------------------|
| 1    | 32-bit Kogge-Stone Adder            |  
| 2    | 32-bit Brent-Kung Adder             |  
| 3    | Booth Multiplier                    |
| 4    | Wallace Tree Multiplier             |  
| 5    | Dadda Multiplier                    |  
| 6    | Restoring Integer Divider           |  
| 7    | Constant Divider via Multiplication |  


---

## Level 2: Pipelined Integer and Modular Designs

Deeply pipelined integer and modular arithmetic pipelines, including multi-stage adders, multipliers, dividers (SRT), single-round AES encryption, and Montgomery modular multipliers.

| S.No | Circuit                                                                                 |
|------|-----------------------------------------------------------------------------------------|
| 1    | Single-Round AES-128 Encryption (SubBytes, ShiftRows, MixColumns, AddRound-Key)         |
| 2    | Pipelined 32-bit Ripple Carry Adder (4 Stages).                                         |    
| 3    | Pipelined 32-bit CLA Adder (4 Stages).                                                  |     
| 4    | Pipelined Wallace Tree Multiplier.                                                      |  
| 5    | Pipelined Dadda Multiplier.                                                             |  


---

## Level 3: Iterative Floating-Point and Fixed-Point Designs

Multi-cycle implementations of floating-point and fixed-point operations using iterative algorithms (SRT division, Newton-Raphson division, square root, logarithm, reciprocal, and CORDIC).

| S.No | Circuit                                          |
|------|--------------------------------------------------|
| 1    | Floating-Point Adder.                            |   
| 2    | Floating-Point Multiplier.                       |  
| 3    | Iterative Newton-Raphson Method for Polynomial.  |  
| 4    | Iterative Newton-Raphson Method for square root. |  
| 5    | Gauss Siedel                                     |   
| 6    | Gradient Descent                                 |   


---

## Level 4: Pipelined Floating-Point and DSP Designs

High-throughput, deeply pipelined floating-point units and DSP kernels: pipelined FP add/mul/div/FMA, fixed-point FFT/IFFT, DCT/IDCT, and IIR filters.

| S.No | Circuit                                                                   |
|------|-------------------------------------------------------------------------- |
| 1    | Pipelined Floating-Point Adder.                                           |
| 2    | Pipelined Floating-Point Multiplier.                                      |
| 3    | 16-point Iterative Fixed-Point Radix-2 FFT.                               |
| 4    | 16-point Iterative Fixed-Point Radix-2 IFFT.                              |
| 5    | Band Pass FIR Filter.                                                     |
| 6    | High Pass FIR Filter.                                                     |
| 7    | Low Pass FIR Filter.                                                      |


---

## Level 5: Streaming and Systolic Array Computations

Streaming architectures and systolic-array accelerators for image filters, corner detection, GEMM, dynamic programming (Needleman–Wunsch), convolution, and FIR filtering.

| S.No | Circuit                                                                       |
|------|-------------------------------------------------------------------------------|
| 1    | 1D Convolution                                                                |
| 2    | 2D Convolution                                                                |
| 3    | Unsharp Mask.                                                                 |
| 4    | Harris Corner Detection.                                                      |
| 5    | Pipelined 8-point 1D Fixed-Point DCT and IDCT for Image Compression.          |
| 6    | Systolic Array for GEMM.                                                      |


---

## Level 6: Highly Complex Domain Specific Accelerators

Full-feature accelerator IPs: AES encryption/decryption cores, 3D convolution, real-time streaming FFTs, DCTs, FIR/IIR filters, elliptic-curve scalar multiplication, and quantized matrix mult units.

| S.No | Circuit                                                                       |
|------|-------------------------------------------------------------------------------|
| 1    | Multi Channel 2D Convolution                                                  |
| 2    | 3D Convolution.                                                               |
| 3    | Pipelined 64-point Streaming FFT for Real-Time Signal Processing.             |
| 4    | Floating Point Band Pass FIR Filter.                                          |
| 5    | Floating Point High Pass FIR Filter.                                          |
| 6    | Floating Point Low Pass FIR Filter.                                           |
| 7    | Quantized Matrix-Matrix Multiply Unit for ML Inference.                       |
| 8    | AES-128 Encryption Core with 10 Rounds and Key Expansion.                     |

| 9    | AES-128 Decryption Core with 10 Rounds and Key Expansion.                     |
