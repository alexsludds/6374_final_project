set VERILOG_SRC      { ../../../build/rc-synth/current/synthesized.v }
 set VERILOG_TOPLEVEL mpadd256_full
 set SDC_FILE         par.sdc 
 set MMMC_FILE        par_mmmc.tcl
 set TIMELIBS_MAX     { /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v2_basicCells.lib }
 set TIMELIBS_MIN     { /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib }
 set QXTECH_TYP       /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/qrc/qx/gpdk045.tch
 set LEF_FILES        { /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_tech.lef /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_macro.lef /mit/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_multibitsDFF.lef }
 set VCD_FILE_NAME    mpadd.vcd;
 set VCD_SCOPE        mpadd_tb/u_DUT;
 
