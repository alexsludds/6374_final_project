#=======================================================================
# MIT ASIC flow setup - created for 6.375, 6.973 and 6.374
# Contributors: Christopher Batten, Ajay Joshi 
#-----------------------------------------------------------------------
#
# This makefile will use Cadence Encounter to place and route
# a gate-level verilog netlist.
#

default : all

basedir  = ../..

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

synthdir = $(basedir)/build/rc-synth/current
vsrcs = $(synthdir)/synthesized.v

# Specify what the toplevel verilog module is

toplevel = mpadd32_shift

# Specify VCD file and instance name
vcdfilename = mpadd.vcd
vcdscope = mpadd_tb/u_DUT

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

build_suffix   := $(shell date +%Y-%m-%d_%H-%M)
build_dir      := build-$(build_suffix)
curr_build_dir := current
curr_build_dir_tstamp := current/timestamp.txt
par_verilog    := $(curr_build_dir)/par.v

par_tcl        := par_main.tcl
par_mmmc       := par_mmmc.tcl
par_sdc        := par.sdc 
rtl_vcd        := $(synthdir)/$(vcdfilename)
scripts        := $(par_tcl) $(par_mmmc) $(par_sdc) $(rtl_vcd)
map_file       := gds.map
makegen_tcl    := make_generated_vars.tcl

libdir = /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045
par_vars = \
	set VERILOG_SRC      { $(addprefix ../, $(vsrcs)) }\n\
	set VERILOG_TOPLEVEL $(toplevel)\n\
	set SDC_FILE         $(par_sdc)\n\
	set MMMC_FILE        $(par_mmmc)\n\
	set TIMELIBS_MAX     { $(libdir)/timing/slow_vdd1v2_basicCells.lib }\n\
	set TIMELIBS_MIN     { $(libdir)/timing/fast_vdd1v2_basicCells.lib }\n\
	set QXTECH_TYP       $(libdir)/qrc/qx/gpdk045.tch\n\
	set LEF_FILES        { $(libdir)/lef/gsclib045_tech.lef $(libdir)/lef/gsclib045_macro.lef $(libdir)/lef/gsclib045_multibitsDFF.lef }\n\
	set VCD_FILE_NAME    $(vcdfilename);\n\
	set VCD_SCOPE        $(vcdscope);\n\

define new-build-dir-cmds
	mkdir $(build_dir)
	rm -rf $(curr_build_dir)
	ln -s $(build_dir) $(curr_build_dir)
	cp $(scripts) $(map_file) $(curr_build_dir)
	echo '$(par_vars)' > $(curr_build_dir)/$(makegen_tcl)
endef

new-build-dir :
	$(new-build-dir-cmds)

$(par_verilog) : $(vsrcs) $(floorplan) $(scripts) 
	$(new-build-dir-cmds)
	cd $(curr_build_dir); \
	innovus -no_gui -files $(par_tcl) | tee innovus.log; \
	cd ..

par : $(par_verilog)

junk += 

.PHONY : par new-build-dir

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : par

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf build-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9] \
	       current $(junk) *~ \#*
