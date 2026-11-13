#!/bin/bash

# making sure the files needed are generated/udpated 
make all

# changing the value of dt_out to be equal to t_end in random sphere source file by the use
# of the sed command (see https://www.gnu.org/software/sed/manual/sed.html#The-_0022s_0022-Command)
sed -i "s/dt_out[[:space:]]*=[[:space:]]*0.01_dp/dt_out = 0.1_dp/" random_sphere.f90

# generation of random_sphere executable after the change in the value of dt_out
make random_sphere

n_particles=(1000 2000 5000 10000)
n_threads=(1 2 4 8)
seed=42

# for loop to generate the random sphere initial conditions automatically
for particle in "${n_particles[@]}"
do
    ./random_sphere $particle $seed > "sphere_${particle}.dat"
done

# for loop to run simulation with n number of particles and n threads
for particle in "${n_particles[@]}"
do 
    echo
    echo "----------"
    echo "n=$particle"
    echo "----------"

    input="sphere_${particle}.dat"

    for thread in "${n_threads[@]}"
    do
        echo
        echo "n_threads=$thread"
        echo "----------"
        OMP_NUM_THREADS=$thread ./ex1_omp "$input" leapfrog
    done
done


