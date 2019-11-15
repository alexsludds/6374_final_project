if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name libs_bc\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v2_basicCells.lib]
create_library_set -name libs_wc\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow_vdd1v2_basicCells.lib]
create_rc_corner -name typ_rc\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/typ_rc/gpdk045.tch
create_delay_corner -name typ_rc_bc\
   -library_set libs_bc\
   -rc_corner typ_rc
create_delay_corner -name typ_rc_wc\
   -library_set libs_wc\
   -rc_corner typ_rc
create_constraint_mode -name sys_con\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/sys_con/sys_con.sdc]
create_analysis_view -name av_wc -constraint_mode sys_con -delay_corner typ_rc_wc -latency_file ${::IMEX::dataVar}/mmmc/views/av_wc/latency.sdc
create_analysis_view -name av_bc -constraint_mode sys_con -delay_corner typ_rc_bc -latency_file ${::IMEX::dataVar}/mmmc/views/av_bc/latency.sdc
set_analysis_view -setup [list av_wc] -hold [list av_bc] -leakage av_wc -dynamic av_wc
