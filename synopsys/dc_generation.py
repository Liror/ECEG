#! python3
import sys                      # read command line arguments
import os                       # create the output folder
import shutil                   # copy files

####################################################################################################
def writeDCFile(folder):

	# Open DC settings file
	if (sim == 0):
		dcFile = open(folder+"/compile.dc.txt", "w")
	else:
		dcFile = open(folder+"/compile.dc.sim.txt", "w")

	# Write DC settings file
	dcFile.write("set CIRCUIT_NAME "+cipherName+"\n")
	dcFile.write("set CIRCUIT_PATH ./ \n")
	dcFile.write("set CIRCUIT_ENTITY_NAME $CIRCUIT_NAME\n")
	dcFile.write("set EXPORT_PATH FR-$CIRCUIT_ENTITY_NAME/\n")
	dcFile.write("set MY_CIRCUIT_NAME FR-$CIRCUIT_NAME\n")
	dcFile.write("remove_design -all\n")
	dcFile.write("set link_library { ../library.db }\n")
	dcFile.write("set target_library { ../library.db }\n")
	dcFile.write("set synthetic_library { ../library.db }\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/FA_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/CLKBUF*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/SDFF_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/SDFFR_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/SDFFS_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/DFF_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/DFFS_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/DFFR_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/SDFFRS_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/DFFRS_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/DLH_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/DLL_*\n")
	dcFile.write("set_dont_use NangateOpenCellLibrary/TLAT_*\n")
	dcFile.write("set verilogout_no_tri true\n")
	dcFile.write("set verilogout_equation false\n")
	dcFile.write("set verilogout_higher_designs_first false\n")
	dcFile.write("set verilogout_show_unconnected_pins false\n")
	dcFile.write("set bus_naming_style %s_%d\n")
	dcFile.write("set search_path  [concat $search_path $CIRCUIT_PATH]\n")
	dcFile.write("set verilogFileName  $CIRCUIT_NAME.v\n")
	# dcFile.write("set vhdlFileName  $CIRCUIT_NAME.vhd\n")
	dcFile.write("analyze -library WORK -format VERILOG Ops.v\n")
	dcFile.write("analyze -library WORK -format VERILOG ModOps.v\n")
	dcFile.write("analyze -library WORK -format VERILOG PointInversion.v\n")
	dcFile.write("analyze -library WORK -format VERILOG PointAdder.v\n")
	dcFile.write("analyze -library WORK -format VERILOG PointSubtraction.v\n")
	dcFile.write("analyze -library WORK -format VERILOG PointMultiplier.v\n")
	dcFile.write("analyze -library WORK -format VERILOG Decrypt.v\n")
	dcFile.write("analyze -library WORK -format VERILOG Encrypt.v \n")
	dcFile.write("analyze -library WORK -format VERILOG $verilogFileName \n")
	# dcFile.write("elaborate $CIRCUIT_NAME -library WORK -update\n")
	dcFile.write("elaborate $CIRCUIT_NAME -library WORK\n")
	dcFile.write("define_name_rules SIMPLE -allowed \"A-Z _a-z0-9\"\n")
	dcFile.write("set default_name_rules SIMPLE\n")
	dcFile.write("change_names\n")
	dcFile.write("link\n")
	dcFile.write("uniquify\n")
	dcFile.write("remove_bus *\n")
	dcFile.write("set_fix_multiple_port_nets -buffer_constants -feedthroughs -outputs\n")
	dcFile.write("#check_design\n")
	dcFile.write("compile -exact_map -ungroup_all -map_effort medium -area_effort medium\n")
	dcFile.write("check_design > tmp.txt\n")
	dcFile.write("file mkdir $EXPORT_PATH;\n")
	dcFile.write("write $CIRCUIT_NAME -format verilog -output $EXPORT_PATH$MY_CIRCUIT_NAME.v\n")
	dcFile.write("write_sdf $EXPORT_PATH$MY_CIRCUIT_NAME.sdf\n")
	dcFile.write("report_reference -hierarchy\n")
	dcFile.write("exit\n")

	# Close DC settings file
	dcFile.close();

	# Open compile script
	if (sim == 0):
		runDcFile = open(folder+"/runDc.sh", "w")
	else:
		runDcFile = open(folder+"/runDc_sim.sh", "w")

	# Write compile script
	runDcFile.write("#!/bin/bash\n\n")
	runDcFile.write("source /cad/synopsys/2017-12/syn/setup.sh\n")
	
	if (sim == 0):
		runDcFile.write("dc_shell-xg-t -f compile.dc.txt\n\n")
	else:
		runDcFile.write("dc_shell-xg-t -f compile.dc.sim.txt\n\n")
	
	runDcFile.write("rm -rf ARCH\n")
	runDcFile.write("rm -rf ENTI\n")
	runDcFile.write("rm *.svf\n")
	runDcFile.write("rm *.mr\n")
	runDcFile.write("rm *.syn\n")
	runDcFile.write("rm tmp.txt\n")
	runDcFile.write("rm command.log\n")

	# Close compile script
	runDcFile.close()

####################################################################################################

#--------------------------------------------------------------------------------------------------#
#---------------------------------------------- Main ----------------------------------------------#
#--------------------------------------------------------------------------------------------------#

####################################################################################################
if __name__ == "__main__":
  
	#Cipher Name
	cipherName = "Top"

	# Output folder
	folder = "."
	if not os.path.exists(folder):
		os.makedirs(folder)
	
	# generate a file for the design compiler
	sim = 0
	writeDCFile(folder)

	## create simulation files
	sim = 1
	writeDCFile(folder)
	
####################################################################################################

