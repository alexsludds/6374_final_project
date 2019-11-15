# Setup
source make_generated_vars.tcl

read_activity_file -format VCD -scope ${VCD_SCOPE} ${VCD_FILE_NAME}

setCheckMode -netlist true -library true
set init_import_mode {-treatUndefinedCellAsBbox 0 -keepEmptyModule 1}
set init_top_cell $VERILOG_TOPLEVEL
set init_verilog $VERILOG_SRC
set init_design_netlisttype Verilog
set init_design_settop 1
set init_lef_file $LEF_FILES
set init_gnd_net {VSS}
set init_pwr_net {VDD}
set init_mmmc_file $MMMC_FILE
set init_design_uniquify 1

# Load design
init_design

#####################
### Chip Planning ###
#####################
# Floorplanning
setDesignMode -process 45 -addPhysicalCell hier
setDrawView fplan

# Most of our absolute measurements should be in multiples of either
# the standard cell height (for Y measurements) or the vertical track
# spacing (for X measurements). We use two TCL variables to specify
# these values.

set vtrack_unit   0.2
set cell_height   1.71 

# A die includes the core area where the standard cell rows are
# located as well as the margins around the core for pads and the
# power ring. We specify the margins using some TCL variables.

set margin_left   [expr 36   * $vtrack_unit]
set margin_bottom [expr 4    * $cell_height]
set margin_right  [expr 36   * $vtrack_unit]
set margin_top    [expr 4    * $cell_height]

# We have two options when specifying the actual dimensions of the
# core. The first specifies the die area as an aspect ratio and a
# utilization of the total cell area estimated from the gate-level
# netlist. We should use relatively low utilizations since Innovus
# needs room to do buffer insertion and local netlist resynthesis.
# This approach is useful since you don't need to change anything as
# you refine the design - the core area will grow or shrink as
# necessary to achieve the desired utilization. We can use the
# following commands for this approach. The aspect ratio is the height
# divided by the width.
#
 set aspect_ratio 1
 set density      0.7

floorPlan -r $aspect_ratio $density \
              $margin_left $margin_bottom $margin_right $margin_top

# The second way to specify the core dimensions is to use absolute
# measurements in microns. This gives the designer much more control
# and enables much more precise module floorplanning, but these
# measurements must be adjusted whenever we make a significant change
# to the design. We can use the following commands for this approach.
#
#set die_width     [expr 1000 * $vtrack_unit]
#set die_height    [expr 100  * $cell_height]
#set core_width    [expr $die_width - $margin_left - $margin_right]
#set core_height   [expr $die_height - $margin_bottom - $margin_top]
#set die_width     1000 
#set die_height    1000
#set core_width    960 
#set core_height   960 

#floorPlan -d $die_width $die_height \
             $margin_left $margin_bottom $margin_right $margin_top

# Rings
addRing -type core_rings \
	-layer {top M10 bottom M10 left M9 right M9} \
	-width 2.0 \
	-spacing 1.0 \
	-center 1 \
	-nets {VDD VSS}

# Power pins
createPGPin VSS! -net VSS -geom M9 1.1 8 3.1 10
createPGPin VDD! -net VDD -geom M9 4.1 8 6.1 10

# Stripes
addStripe -direction horizontal \
	-layer M10 \
	-width 1.0 \
	-spacing 10.0 \
	-set_to_set_distance 22.0 \
	-nets {VDD VSS}

addStripe -direction vertical \
	-layer M9 \
	-width 1.0 \
	-spacing 10.0 \
	-set_to_set_distance 22.0 \
	-nets {VDD VSS}

# Core routing
sroute -connect corePin -nets {VDD VSS}

#############################
### Placement and Routing ###
#############################
# Global connections
globalNetConnect VSS -type pgpin -inst * -pin VSS  -module {}
globalNetConnect VDD -type pgpin -inst * -pin VDD -module {}
globalNetConnect VDD -type tiehi -inst * -module {}
globalNetConnect VSS -type tielo -inst * -module {}

# Placement
setDrawView place
setPlaceMode -place_global_place_io_pins true
place_opt_design
checkPlace

# Add tie cells
setTieHiLoMode -cell {TIEHI TIELO} -maxFanout 20
addTieHiLo -prefix TIE

# Clock tree synthesis (CTS)
set_ccopt_property buffer_cells { CLKBUFX* }
set_ccopt_property inverter_cells { CLKINVX* }
set_ccopt_property target_max_trans 100ps
set_ccopt_property target_skew 50ps
create_ccopt_clock_tree_spec
ccopt_design

# Post-CTS reports and checks
report_ccopt_clock_trees -file clock_trees.rpt
report_ccopt_skew_groups -file skew_groups.rpt

# Post-CTS hold optimization
# setOptMode -effort high -holdTargetSlack 0.1
optDesign -postCTS -hold

# Route design
routeDesign

# Post-route checks
setExtractRCMode -engine postRoute -effortLevel medium
setDelayCalMode -SIAware false
timeDesign -postRoute -outDir postRouteTiming
timeDesign -postRoute -hold -outDir postRouteTiming
saveDesign par_postRoute.enc

# Post-route optimization
optDesign -postRoute -setup -hold
checkRoute

# Add fillers
setFillerMode -add_fillers_with_drc false
#addFiller -cell { DECAP2 DECAP3 DECAP4 DECAP5 DECAP6 DECAP7 DECAP8 DECAP9 DECAP10 } -prefix DCAP
addFiller -fitGap -cell { FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 } -prefix FILL
addFiller -fitGap -cell { FILL1 } -prefix FILL

# Fix DRC errors, if any
ecoRoute
verify_drc -limit 100000

# Timing sign-off
timeDesign -signoff -reportOnly -outDir signOffTiming
timeDesign -signoff -hold -reportOnly -outDir signOffTiming

# Save design
saveDesign par_final.enc

# Export GDS and netlist and SDF
streamOut par.gds -mapFile gds.map -mode ALL -unit 1000
saveNetlist par.v -excludeLeafCell -includePhysicalCell { DECAP2 DECAP3 DECAP4 DECAP5 DECAP6 DECAP7 DECAP8 DECAP9 DECAP10 TIEHI TIELO }
write_sdf par.sdf

##########################
### Post-route reports ###
##########################
report_power -outfile postroute_power.rpt

setAnalysisMode -checkType setup
buildTimingGraph
report_timing -net -max_paths 200 > postroute_setup_timing.rpt

setAnalysisMode -checkType hold
buildTimingGraph
report_timing -net -max_paths 200 > postroute_hold_timing.rpt

reportGateCount -level 5 -limit 100 -stdCellOnly -outfile postroute_area.rpt
reportWire postroute_wire.rpt

exit