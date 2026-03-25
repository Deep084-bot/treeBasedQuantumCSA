# 8-bit Tree-Based Carry Save Adder (CSA) - Vivado Ready Project

## Files
- `full_adder.v`: 1-bit full adder (structural gate-level)
- `csa.v`: parameterized carry-save adder for 3 operands
- `csa_tree.v`: CSA tree reducing 6 inputs to 2 operands
- `final_adder.v`: parameterized ripple-carry final adder
- `top_csa_tree.v`: required core top module with A/B/C/D/E/F inputs
- `top_csa_tree_nexys.v`: Nexys A7 board wrapper (switch/button/LED mapping)
- `nexys_a7_csa_tree.xdc`: Nexys A7 pin constraints
- `testbench.v`: self-checking functional testbench
- `build_vivado.tcl`: batch script to create/build project

## Quick Start (Vivado GUI)
1. Open Vivado and create a new RTL project.
2. Add source files:
   - `full_adder.v`
   - `csa.v`
   - `csa_tree.v`
   - `final_adder.v`
   - `top_csa_tree.v`
   - `top_csa_tree_nexys.v`
3. Add constraints file: `nexys_a7_csa_tree.xdc`.
4. Set top module to: `top_csa_tree_nexys`.
5. Select part:
   - Nexys A7-100T: `xc7a100tcsg324-1`
   - Nexys A7-50T: `xc7a50tcsg324-1`
6. Run Synthesis -> Run Implementation -> Generate Bitstream.
7. Program board and use:
   - `SW[7:0]` as input `A`
   - `SW[15:8]` as input `B`
   - `BTNU/BTND/BTNL/BTNR` to choose internal patterns for `C/D/E/F`
   - `LED[15:0]` displays final `result`

## Quick Start (Batch Build)
Run from this folder:

```bash
vivado -mode batch -source build_vivado.tcl
```

## Simulation (Icarus Verilog)
Run from this folder:

```bash
iverilog -g2012 -o csa_tree_tb.vvp full_adder.v csa.v csa_tree.v final_adder.v top_csa_tree.v testbench.v
vvp csa_tree_tb.vvp
```

## Notes on Architecture
- Carry-save addition reduces carry-propagation delay by postponing carry resolution.
- The CSA tree performs parallel reduction of multiple operands.
- Final stage uses a ripple-carry adder to compute the exact result from two reduced operands.

## Conceptual Extension to Reversible/Quantum Logic
The same reduction-tree idea can be conceptually adapted using reversible adders (for example Toffoli-based constructions), but practical quantum/reversible implementations must manage ancilla bits and garbage outputs.
