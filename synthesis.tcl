# Optimization settings
# The period has to be changed to see if the design can meet the timing constraint
set period 20

#  Define the names to be used by the script
set design Tetris

# Define the directory paths
set BASE_DIR	 [pwd]
set RPT_DIR      "${BASE_DIR}/RPT"
set RTL_DIR 	 "${BASE_DIR}/verilog/Project/TetrisASIC"
set GATE_DIR 	 "${BASE_DIR}/verilog/gate"
set SDF_DIR 	 "${BASE_DIR}/SDF"
set SDC_DIR 	 "${BASE_DIR}/SDC"
set DDC_DIR 	 "${BASE_DIR}/DDC"

#  dependency rules
set HDL_FILES [list \
$RTL_DIR/Tetris.v \
$RTL_DIR/Input_Controller.v \
$RTL_DIR/Grid_Controller.v \
$RTL_DIR/Grid_Mem.v \
$RTL_DIR/Grid_To_Video.v \
$RTL_DIR/Line_Clearer.v \
$RTL_DIR/Piece_Placer.v \
$RTL_DIR/VGA_Controller.v \
$RTL_DIR/VGA_Mem.v ]



#  Start from fresh state
remove_design -designs

#  Analyze the Verilog sources
puts "-i- Analyze Verilog sources"
analyze -format sverilog $HDL_FILES

#  Elaborate the design
puts "-i- Elaborate design"
elaborate ${design} -update -library DEFAULT

#  Save the elaborated design
puts "-i- Save elaborated design"
write -hierarchy -format ddc -output ${DDC_DIR}/${design}_elab.ddc

#  Define constraints
puts "-i- Define constraints"
puts "-i- set_max_area 0"
puts "-i- set_clock"
set_max_area 0
create_clock -name "clk" -period $period clk

#Check the design for warnings
check_design

#  Do not ungroup the hierarchy
set_ungroup [get_designs *] false

#  Map and optimize the design
puts "-i- Map and optimize design"
compile_ultra

#  Save the mapped design
puts "-i- Save mapped design"
write -hierarchy -format ddc -output ${DDC_DIR}/${design}_mapped.ddc

#  Generate reports
puts "-i- Generate reports"
report_constraint -nosplit -all_violators > ${RPT_DIR}/${design}_mapped_allviol.rpt
report_area > ${RPT_DIR}/${design}_mapped_area.rpt
report_timing > ${RPT_DIR}/${design}_mapped_timing.rpt
report_power -nosplit -analysis_effort low > ${RPT_DIR}/${design}_mapped_power.rpt

#  Generate the Verilog netlist
puts "-i- Generate Verilog netlist"
write -format verilog -hierarchy -output ${GATE_DIR}/${design}_mapped.v

#  Generate the design constraint file
puts "-i- Generate SDC design constraint file"
write_sdc -nosplit ${SDC_DIR}/${design}_mapped.sdc

#  Save the synthesized design
puts "-i- Save synthesized design"
write -hierarchy -format ddc -output ${DDC_DIR}/${design}_synthesized.ddc

puts "-i- Finished"
