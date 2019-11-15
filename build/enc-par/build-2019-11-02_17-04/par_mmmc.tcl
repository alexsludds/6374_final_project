#------------------------------------------------------------
# Initialize timing (MMMC)
#------------------------------------------------------------
# Create libraries
create_library_set -name libs_wc -timing $TIMELIBS_MAX
create_library_set -name libs_bc -timing $TIMELIBS_MIN

# Create a constraint based on our .sdc file
create_constraint_mode -name sys_con -sdc_files $SDC_FILE

# Create RC corners from captables
create_rc_corner -name typ_rc -qx_tech_file $QXTECH_TYP

# Create delay corners based on library and rc corner
create_delay_corner -name typ_rc_bc -library_set libs_bc -rc_corner typ_rc
create_delay_corner -name typ_rc_wc -library_set libs_wc -rc_corner typ_rc

# Create best case and worst case analysis views given constraint mode and delay corners
create_analysis_view -name av_bc -constraint_mode sys_con -delay_corner typ_rc_bc
create_analysis_view -name av_wc -constraint_mode sys_con -delay_corner typ_rc_wc

# Associate setup and hold analysis with the analysis views
set_analysis_view -setup av_wc -hold av_bc
