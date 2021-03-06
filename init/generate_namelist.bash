#!/bin/bash
#=======input==========
InputFile=namelist.input
Spinup="TE"
EditVal="fire_fuel_cat      = "
LoopVar=(2 3 5)
BaseVal=7
#======end of input====

current=$(pwd)
echo "Creating namelist set for $EditVal:"
cd ./namelist/
for i in "${LoopVar[@]}"
do
	#move to folder
	run=${InputFile}F${i}$Spinup
	echo "Editing run: $run"
	cp ${InputFile}F$BaseVal$Spinup $run
	sed -i "s/$EditVal$BaseVal/$EditVal$i/g" $run
done
cd $current
echo "COMPLETE"
