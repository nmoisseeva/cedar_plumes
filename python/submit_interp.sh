#!/bin/bash

#for Case in $( ls -p ../complete/. | grep -v / )
for Case in $( ls ../complete/*W5F7R7TM )
do
	tag=${Case:19}
	echo $tag
	FILE="./slurm/interp_$tag.sh"

	/bin/cat <<EOF >$FILE
#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH --mem-per-cpu=192000M
#SBATCH -n 1
#SBATCH --account=def-rstull
#SBATCH --job-name=$tag
#SBATCH --output=%x.out

module load python
module load scipy-stack
source /home/moisseev/.vewrf/bin/activate

python /home/moisseev/projects/rrg-rstull/moisseev/plume/aug2019/python/prep_plumes_extratall.py $tag
#python /home/moisseev/projects/rrg-rstull/moisseev/plume/aug2019/python/prep_plumes.py $tag
echo Completed $tag
EOF
	echo Submitting $tag for interpolation
	sbatch ./slurm/interp_$tag.sh	

done

