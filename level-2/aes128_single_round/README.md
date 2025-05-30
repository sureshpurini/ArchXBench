# AES-128 Single Round

## Benchmark Status

### Problem Description
- **Verified:** true  
- **Remarks:**  
  - Implements one AES-128 round: SubBytes, ShiftRows, MixColumns, AddRoundKey.  
  - Operates on a 4×4 byte state matrix; round key is 128-bit.  
  - Clarified that SubBytes uses Rijndael S-box, MixColumns uses standard GF(2⁸) matrix, and ShiftRows rotates each row by its index.

### Design Specifications
- **Verified:** true  
- **Remarks:**  
  - Fully parameterized for 128-bit state and key inputs.  
  - Combinational or optional pipelined implementation for low latency or high throughput.  
  - All operations occur in a single cycle when `start` is asserted; `done` indicates completion.

### References
- **Links:**  
  - https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf  
  - Daemen & Rijmen, *The Design of Rijndael*

## Testbench

### Completeness & Coverage
- **SubBytes:** test every byte value (0x00–0xFF) through the S-box.  
- **ShiftRows:** verify row shifts by 0,1,2,3 positions for known patterns.  
- **MixColumns:** test columns [0x01,0x02,0x03,0x01] and edge polynomials (e.g., 0x80).  
- **AddRoundKey:** verify XOR with zero key, all-ones key, and random.  
- **Full Round Vectors:**  
  - Known AES test vector (plaintext= “00112233445566778899aabbccddeeff”, key= “0f0e0d0c0b0a09080706050403020100”, expected= “6ce5317a7280fdfce1a5a863dad007fb”).  
  - 49 random plaintext/key pairs for additional coverage.  

### Generation Approach
- Manual scripting of fixed NIST vectors plus SystemVerilog loops generating random 128-bit values.  
- Each test applies `start`, waits for `done`, then captures `state_out` and `done`.

### Validation
- Oracle comparison against a Python AES reference that performs exactly one round:  
```python
    def aes_round(state, round_key):  
        # SubBytes  
        for i in 0..15: state[i] = sbox[state[i]]  
        # ShiftRows  
        rotate row 1 left by 1, row 2 by 2, row 3 by 3  
        # MixColumns  
        for each column c:  
            new_c[0] = mul2[c0] ^ mul3[c1] ^ c2 ^ c3  
            new_c[1] = c0 ^ mul2[c1] ^ mul3[c2] ^ c3  
            new_c[2] = c0 ^ c1 ^ mul2[c2] ^ mul3[c3]  
            new_c[3] = mul3[c0] ^ c1 ^ c2 ^ mul2[c3]  
        # AddRoundKey  
        for i in 0..15: state[i] ^= round_key[i]  
        return state
```  

- Testbench compares DUT output to this model; logs `[PASS]`/`[FAIL]`.

## Reference Design

- **Status:** completed  
- **Issues:** none—compiles and simulates cleanly under Icarus Verilog and Synopsys VCS.  
- **Model Used (LLM):** o3-mini-high 
- **Prompt Engineering:**  
  - Provided detailed operation sequence and byte-matrix conventions.  
  - Iteratively refined timing control (`start`/`done`) and pipelining options.  
- **Error Logs:**  
  - No synthesis or simulation warnings when run with `iverilog -g2012` and `vcs -full64`.  
