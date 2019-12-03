#=======================================================================
# 6.374 Makefile for rc-synth
#-----------------------------------------------------------------------
#
# This makefile will use Cadence Genus Synthesis Solution to synthesize
# your RTL into a gate-level verilog netlist.
#
# Modified on June 4, 2019 by Alex Ji: Replaced rc command with genus

default : all

basedir  = ../..

#--------------------------------------------------------------------
# Sources for pe_array
#--------------------------------------------------------------------

#srcdir = $(basedir)/src
#vsrcs = \
#	$(srcdir)/pe_array.v \

#toplevel = pe_array

#--------------------------------------------------------------------
# Sources for shadow_register
#--------------------------------------------------------------------

srcdir = $(basedir)/src
vsrcs = \
	$(srcdir)/ShadowReg.sv \

toplevel = ShadowReg


#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

build_suffix   := $(shell date +%Y-%m-%d_%H-%M)
build_dir      := build-$(build_suffix)
curr_build_dir := current
curr_build_dir_tstamp := current/timestamp.txt
synth_verilog  := $(curr_build_dir)/synthesized.v

synth_tcl      := synth.tcl
libs_tcl       := libs.tcl
synth_sdc      := synth.sdc
scripts        := $(synth_tcl) $(libs_tcl) $(synth_sdc)
makegen_tcl    := make_generated_vars.tcl

synth_vars = \
	set SEARCH_PATH      { ../$(srcdir) }\n\
	set VERILOG_SRCS     { ../$(vsrcs) }\n\
	set VERILOG_TOPLEVEL $(toplevel)\n\

define new-build-dir-cmds
	mkdir $(build_dir)
	rm -f $(curr_build_dir)
	ln -s $(build_dir) $(curr_build_dir)
	cp $(scripts) $(curr_build_dir)
	echo '$(synth_vars)' > $(curr_build_dir)/$(makegen_tcl)
endef

new-build-dir :
	$(new-build-dir-cmds)

$(synth_verilog) : $(vsrcs) $(scripts) 
	$(new-build-dir-cmds)
	cd $(curr_build_dir); \
	genus -f $(synth_tcl) \


synth : $(synth_verilog)

junk += 

.PHONY : synth new-build-dir

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : synth

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf build-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9] \
	       current $(junk) *~ \#*
