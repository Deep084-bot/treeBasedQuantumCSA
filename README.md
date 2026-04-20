# 4-Input 4-Bit Pipelined Tree-Based Carry Save Adder (CSA) - Vivado Ready Project

## Overview
This project implements a pipelined CSA tree on Nexys A7.

Current implemented datapath:
1. Four 4-bit inputs: A, B, C, D
2. CSA reduction tree to two 6-bit operands
3. Final 6-bit ripple-carry carry-propagate adder
4. Two pipeline stages in top-level core

Result range is 0 to 60 because the design computes:

result = A + B + C + D

where each input is 0 to 15.

## Project Files
- full_adder.v: 1-bit structural full adder (xor/and/or gates)
- csa.v: parameterized 3-input carry-save adder (default WIDTH=4)
- csa_tree.v: 4-input CSA tree reduction network with stage visibility outputs
- final_adder.v: parameterized ripple-carry adder used as final CPA
- top_csa_tree.v: pipelined core (clk/rst + A/B/C/D -> 6-bit result)
- Seg7adder.v: 7-segment multiplexed decimal display driver for 0 to 60
- top_csa_tree_nexys.v: Nexys A7 wrapper (clock/reset/switches/7-seg/LED)
- nexys_a7_csa_tree.xdc: constraints for clock, reset, switches, 7-seg, LEDs
- testbench.v: self-checking simulation testbench for pipelined core
- build_vivado.tcl: batch script to create project and generate bitstream

Generated artifact in folder:
- csa_tree_tb.vvp: compiled simulation output from Icarus Verilog

## Architecture Notes
The CSA tree avoids immediate carry propagation during compression:
- Stage 1 compresses A, B, C into stage1_sum and stage1_carry
- Stage 2 compresses D, stage1_sum, and shifted stage1_carry
- Final CPA computes exact binary sum from two reduced operands

Core pipeline details in top_csa_tree.v:
- Pipeline Stage 1 register captures CSA operands
- Pipeline Stage 2 register captures final adder output
- Latency: 2 clock cycles
- Throughput: 1 result per clock after pipeline fill

## Nexys A7 I/O Mapping
In top_csa_tree_nexys.v and nexys_a7_csa_tree.xdc:

Switches:
- SW[3:0] -> A
- SW[7:4] -> B
- SW[11:8] -> C
- SW[15:12] -> D

Reset and clock:
- CLK100MHZ -> core clock
- CPU_RESETN -> active-low board reset button, inverted to active-high rst

Display outputs:
- 7-segment decimal output:
  - AN[0] shows units digit
  - AN[1] shows tens digit
  - Leading zero on tens is blanked
- LED[5:0] shows raw binary result
- LED[15:6] are forced low

## Vivado GUI Flow
1. Open Vivado and create a new RTL project.
2. Add RTL source files:
   - full_adder.v
   - csa.v
   - csa_tree.v
   - final_adder.v
   - top_csa_tree.v
   - Seg7adder.v
   - top_csa_tree_nexys.v
3. Add constraints file:
   - nexys_a7_csa_tree.xdc
4. Set top module:
   - top_csa_tree_nexys
5. Select FPGA part:
   - Nexys A7-100T: xc7a100tcsg324-1
   - Nexys A7-50T: xc7a50tcsg324-1 (if using 50T board)
6. Run Synthesis, Implementation, and Generate Bitstream.

## Vivado Batch Build
From this folder:

```bash
vivado -mode batch -source build_vivado.tcl
```

Bitstream path after successful run:

./csa_tree_4bit/csa_tree_4bit.runs/impl_1/top_csa_tree_nexys.bit

## Simulation (Icarus Verilog)
From this folder:

```bash
iverilog -g2012 -o csa_tree_tb.vvp full_adder.v csa.v csa_tree.v final_adder.v top_csa_tree.v testbench.v
vvp csa_tree_tb.vvp
```

The testbench is pipeline-aware and checks output after two clock cycles for each input case.

## Conceptual Extension to Reversible/Quantum Logic
The same reduction-tree concept can be adapted conceptually to reversible arithmetic by replacing irreversible adder blocks with reversible ones. Practical reversible or quantum-oriented implementations must also manage ancilla signals and garbage outputs while preserving bijective behavior.
