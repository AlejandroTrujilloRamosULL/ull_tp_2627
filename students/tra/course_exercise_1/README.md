# **Direct N-body simulation with OpenMP**

This repository contains the first scored exercise of the *Técnicas de Programación* class from *Máster de Astrofísica* (**STILL NOT FINISHED**). All the files needed for running the simulation are contained in here.

This repository, as stated in the title, was created to make a calculation of the orbits of n bodies, given their initial conditions. These are parallelized via OpenMP, and the efficiency is tested by using a different number of threads and presenting the different run times.

---

## Workings of the Code and Contents

This code is mainly an n-body integrator. It uses a main program **ex1.f90**, which uses a leapfrog algorithm, either the common 2nd order algorithm of Yoshida's 4th order integration algorithm (own implementation). It depends on some modules (listed below) and a source file **random_sphere.f90** which creates the initial conditions for a given number of particles and a given seed (for random number generation and uniformity in the testing with different cases) which are used for the execution of the main program to produce outputs.

### Modules

This code makes use of various modules for the execution of the main program, and they serve different purposes:

- `kinds.f90`: contains single precision and double precision kinds for use. Double precision is utilized by default in this project.
- `geometry.f90`: contains custom derived types **vector3d** and **point3d** and custom operations between them for a more efficient calculation and handling of these types.
- `particle.f90`: contains a derived type **particle3d**, which is described by its mass, position and velocity.  


### Source files

- `random_sphere.f90`: initial conditions algorithm which creates particles inside a sphere at random positions uniformly, initially at rest and with equal mass, given a number of particles and a seed.
- `ex1.f90`: main program which contains the leapfrog algorithm (both the 2nd order one and the Yoshida algorithm, implemented by the author) and the calculations to give the **output.dat** file in the serial and parallelized case.

### Make file and Shell Script

- `makefile`: makes the modules and executables building and linking easy by writing the command `make` in the terminal. To erase the outputs and run from scratch again just run the command `make clean`.
- `run_tests.sh`: shell script to automatize the running of tests for different number of particles and number of threads. By default, it uses the values asked to use in the task, but the user might modify it as he/she pleases.

---

## Compilation and Running

Building both executables:

```bash
make all
```

This produces `ex1` (compiled without `-fopenmp` flag) and `ex1_omp` (compiled with `-fopenmp` flag).

Generate an initial-conditions file (example for N=1000, seed=42) writing it into `sphere_1000.dat` file by:

```bash
make random_sphere
./random_sphere 1000 42 > sphere_1000.dat
```

the `make random_sphere` command needs to be executed just the first time of generating an initial conditions file.

Run without OpenMP:

```bash
./ex1 sphere_1000.dat
```

Run with OpenMP, optionally setting the number of threads via `OMP_NUM_THREADS`:

```bash
OMP_NUM_THREADS=4 ./ex1_omp sphere_1000.dat
```

Both produce identical results (`output.dat`). 
Something to consider is to take caution of overwriting the output file if running them consecutively (with and without OpenMP or viceversa), as both produce a file with the same name. A recommendation if you run one first is to change the name of the generated output file via:

```
mv <old_output_file> <new_output_file>
```
and then run the other case.

The command line for running the simulation takes two arguments actually, the input file with the initial conditions and the integration method to use, so, the general command line would be:

```
./ex1 <ic_file> [method]
```
where `[method]` is an optional argument. It can take the string values `leapfrog` to use the common 2nd order integrator, or `yoshida` to use Yoshida's method. If no method is specified, `leapfrog` is used as default.

---

## Integration methods (STILL NOT FINISHED)

### Leapfrog (2nd order)

The leapfrog method updates velocity and position by defining a kick-drift-kick sequence. The kick updates the velocity, indicating that the gravity gave the particle a push, and the drift updates the position, where the particle coasts with the current velocity,. The method outlined in order for every leapfrog step is:

$$v_{i+1/2} = v_i + a_i \frac{\Delta t}{2}, \\ r_{i+1} = r_i + v_{i+1/2} \Delta t, \\ a_{i+1}  \text{ calculated from } r_{i+1}, \\ v_{i+1} = v_{i+1/2} + a_{i+1} \frac{\Delta t}{2},$$

where $r_i, v_i$ are the starting position and velocity, $a_i$ is the acceleration at position $r_i$, and $r_{i+1}, v_{i+1}$ are the updated position and velocity after one leapfrog step. This requires an acceleration evaluation per step, which is calculated via:

$$\mathbf{a}_i = \sum_{j \neq i} m_j \frac{\mathbf{r}_j - \mathbf{r}_i}{|\mathbf{r}_j - \mathbf{r}_i|^3} .$$



### Yoshida (4th order)

Haruo Yoshida devised a method (1990) to construct explicit higher order symplectic integrators. He noticed that if the correct coefficients were used, terms of linear and third order would cancel and a fourth order method could be utilized.  
The equations for the 4th order integrator to update position and velocity are:

$$r_i^1 = r_i + c_1 v_i \Delta t, \qquad v_i^1 = v_i + d_1\, a_i^1\, \Delta t,$$

$$r_i^2 = r_i^1 + c_2 v_i^1 \Delta t, \qquad v_i^2 = v_i^1 + d_2\, a_i^2\, \Delta t,$$

$$r_i^3 = r_i^2 + c_3 v_i^2 \Delta t, \qquad v_i^3 = v_i^2 + d_3\, a_i^3\, \Delta t,$$

$$r_{i+1} \equiv r_i^4 = r_i^3 + c_4 v_i^3 \Delta t, \qquad v_{i+1} \equiv v_i^4 = v_i^3$$

where $r_i, v_i$ are the starting position and velocity, $r_i^n, v_i^n$ are intermediary position and velocity at intermediary step $n$, $a_i^n$ is the acceleration at the position $r_i^n$, and $r_{i+1}, v_{i+1}$ are the final position and velocity under one 4th order Yoshida step. This method requires **three** acceleration evaluations per step.

Coefficients $(c_1, c_2, c_3, c_4)$ and $(d_1, d_2, d_3)$ are derived in Haruo Yoshida's paper [Yoshida, H. (1990). Construction of higher order symplectic integrators. *Physics Letters A*, 150(5-7), 262-268.](https://doi.org/10.1016/0375-9601(90)90092-3) (see equation (4.6) in the original paper for the coefficients definitions and values):

$$w_0 \equiv -\frac{\sqrt[3]{2}}{2-\sqrt[3]{2}}, \qquad w_1 \equiv \frac{1}{2-\sqrt[3]{2}},$$

$$c_1 = c_4 \equiv \frac{w_1}{2}, \qquad c_2 = c_3 \equiv \frac{w_0+w_1}{2},$$

$$d_1 = d_3 \equiv w_1, \qquad d_2 \equiv w_0.$$

---

## Benchmarking

Run time was measured for `ex1_omp` across different number of particles and threads using the `run_tests.sh` shell script:

```bash
./run_tests.sh
```

Firstly, before execution of the shell script, it is important to give it execution permissions. For that just run the command:

```
chmod +x run_tests.sh
```

You can verify it worked by running :

```
ls -l run_tests.sh
```

and checking the permissions of the file.

This script builds all executables, generates the initial conditions files above automatically, and runs the simulation across n_particles = 1000, 2000, 5000, 10000 and n_threads = 1, 2, 4, 8. So shortly, it does the timing test of the different use of threads and for a different number of particles automatically. Different values can be used for n_particles and n_threads just by changing them inside the file.

Timing is measured using `omp_get_wtime()`, which can be found inside the main simulation loop in `ex1.f90`. `dt_out` was set equal to `t_end` in `random_sphere.f90` so that output writing does not dominate the measured time.

---

## Results

By the execution of the `./run_tests.sh` command it prints the execution time for the different number of particles and threads defined inside the `run_tests.sh` file. The output in my case gave the following results:

### Formatted table with OpenMP parallelization results

| n_particles | n_threads | time (s) |
|-------|---------|----------|
| 1000  | 1       | 6.4863   |
| 1000  | 2       | 2.4449   |
| 1000  | 4       | 1.6851   |
| 1000  | 8       | 1.0111   |
| 2000  | 1       | 25.7726  |
| 2000  | 2       | 10.3659  |
| 2000  | 4       | 6.3539   |
| 2000  | 8       | 4.5393   |
| 5000  | 1       | 146.6428 |
| 5000  | 2       | 65.2967  |
| 5000  | 4       | 51.9339  |
| 5000  | 8       | 40.3395  |
| 10000 | 1       | 631.6296 |
| 10000 | 2       | 336.4140 |
| 10000 | 4       | 184.3949 |
| 10000 | 8       | 150.5765 |

In terms of the results, we observe what was expected, a higher number of threads gives a shorter amount of time for execution. (**STILL TO BE FINISHED**) 