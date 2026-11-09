#!/bin/bash

# making sure the files needed are generated/udpated 
make all
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


