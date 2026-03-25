# Vivado batch build script for Nexys A7 CSA tree project
# Usage:
#   vivado -mode batch -source build_vivado.tcl
#
# Notes:
# - Default part is Nexys A7-100T: xc7a100tcsg324-1
# - For Nexys A7-50T, change PART below to xc7a50tcsg324-1

set PROJECT_NAME csa_tree_nexys
set PROJECT_DIR  ./vivado_project
set PART         xc7a100tcsg324-1
set TOP_MODULE   top_csa_tree_nexys

file mkdir $PROJECT_DIR
create_project $PROJECT_NAME $PROJECT_DIR -part $PART -force

# RTL sources
add_files [list \
    full_adder.v \
    csa.v \
    csa_tree.v \
    final_adder.v \
    top_csa_tree.v \
    top_csa_tree_nexys.v \
]

# Constraints
add_files -fileset constrs_1 nexys_a7_csa_tree.xdc

# Simulation sources
add_files -fileset sim_1 testbench.v
set_property top testbench [get_filesets sim_1]

# Synthesis/implementation top
set_property top $TOP_MODULE [get_filesets sources_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

open_run impl_1
report_timing_summary -file $PROJECT_DIR/timing_summary.rpt
report_utilization   -file $PROJECT_DIR/utilization.rpt

puts "Build complete. Bitstream and reports are in $PROJECT_DIR"
