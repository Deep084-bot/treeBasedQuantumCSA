# build_vivado.tcl
# Batch build script for the 4-input 4-bit pipelined CSA tree.
# Run from the project folder:
#   vivado -mode batch -source build_vivado.tcl

set project_name "csa_tree_4bit"
set part         "xc7a100tcsg324-1"   ;# Nexys A7-100T
# For Nexys A7-50T use: xc7a50tcsg324-1

# Create project
create_project $project_name ./$project_name -part $part -force

# Add all RTL source files (full_adder.v is unchanged from original)
add_files -norecurse {
    full_adder.v
    csa.v
    csa_tree.v
    final_adder.v
    top_csa_tree.v
    top_csa_tree_nexys.v
}

# Add constraints
add_files -fileset constrs_1 -norecurse nexys_a7_csa_tree.xdc

# Set top module
set_property top top_csa_tree_nexys [current_fileset]

# Update compile order
update_compile_order -fileset sources_1

# Run synthesis, implementation, and bitstream generation
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed."
}

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Implementation failed."
}

puts "Build complete. Bitstream: ./${project_name}/${project_name}.runs/impl_1/top_csa_tree_nexys.bit"