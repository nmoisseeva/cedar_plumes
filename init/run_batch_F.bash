#!/bin/bash
#=======input==========
Floop=(5 6 8 9 10 11 12 13)
R=R4
W=W5
spinup=false
#======end of input====

current=$(pwd)
echo "Running wind set for $W,$R:"
for i in "${Floop[@]}"
do
	echo "--FUEL RUN: category $i "
	#link main executables
	if $spinup; then
	        run=${W}F$i${R}spinup
	        echo ".....creating a run folder $run"
	        mkdir -p ../runs/$run
	        cd ../runs/$run
	        if [ "$(ls -A)" ]; then
	                rm *
	        fi

		#link surface and sounding
		ln -s ../../init/landuse/LANDUSE.TBL_F$i LANDUSE.TBL
		ln -s ../../init/sounding/input_sounding$W$R input_sounding
		ln -s ../../init/surface/input_tsk$R input_tsk
		#link namelists
	        ln -s ../../init/namelist/namelist.inputF${i}spinup namelist.input
		
		#create slurm script and run
		SLURMFILE="$run.sh"
		/bin/cat <<EOF >$SLURMFILE
#!/bin/bash
#SBATCH -t 23:00:00
#SBATCH --mem-per-cpu=4000M
#SBATCH --nodes=1
#SBATCH --ntasks=31
#SBATCH --account=def-rstull
#SBATCH --job-name=$run
#SBATCH --output=%x-%j.out

module load  nixpkgs/16.09  intel/2016.4  openmpi/2.1.1
module load wrf-fire-1tracer

mpirun -np 1 ideal.exe
srun wrf.exe
mv wrfout_* ../../complete/spinup/wrfout_$run
mv wrfrst_d01_0000-08-01_12:30:00 ../../restart/wrfrst_d01_0000-08-01_12:30:00_${W}F$i$R
EOF
	else
	
              	run=${W}F$i$R
	        echo ".....creating a run folder $run"
		mkdir -p ../runs/$run
		cd ../runs/$run
		if [ "$(ls -A)" ]; then
			rm *
		fi

		#link restart file
	        ln -s ../../restart/wrfrst_d01_0000-08-01_12:30:00_${W}F$i$R wrfrst_d01_0000-08-01_12:30:00
	        #link namelists
	        ln -s ../../init/namelist/namelist.inputF$i namelist.input

                #create slurm script and run
                SLURMFILE="$run.sh"
                /bin/cat <<EOF >$SLURMFILE
#!/bin/bash
#SBATCH -t 10:00:00
#SBATCH --mem-per-cpu=4000M
#SBATCH --nodes=1
#SBATCH --ntasks=31
#SBATCH --account=def-rstull
#SBATCH --job-name=$run
#SBATCH --output=%x-%j.out

module load  nixpkgs/16.09  intel/2016.4  openmpi/2.1.1
module load wrf-fire-1tracer

srun wrf.exe
mv wrfout_* ../../complete/wrfout_$run
EOF
	fi

	#link common files	
	ln -s ../../init/namelist/namelist.fire namelist.fire
	ln -s ../../init/namelist/namelist.fire_emissions ./

	#link slurm script and run
	echo ".....submitting job to slurm"
	sbatch $run.sh
	cd $current
done
echo "COMPLETE"
