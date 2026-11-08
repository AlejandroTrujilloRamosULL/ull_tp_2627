# Makefile for exercise 1 
# ex1.f90 source file uses the kinds, geometry and particle modules
# We are going to use variables and pattern rules

FC = gfortran
FCFLAGS = -Wall -fcheck=all
OPENMPFLAG = -fopenmp
OBJECTS = kinds.o geometry.o particle.o ex1.o 

# default target (running make builds both exceutables by default)
all: ex1 ex1_omp

# executable (without -fopenmp flag)
ex1: $(OBJECTS)
	$(FC) $(FCFLAGS) -o $@ $^

# executable (with -fopenmp flag)
# shares kinds, geometry and particle objects since only ex1.f90 is parallelised
ex1_omp: kinds.o geometry_omp.o particle.o ex1_omp.o
	$(FC) $(FCFLAGS) $(OPENMPFLAG) -o $@ $^

#building the ic generator random_sphere executable
random_sphere: random_sphere.o
	$(FC) $(FCFLAGS) -o $@ $<

# using the pattern rule for module compilation
%.o: %.f90
	$(FC) $(FCFLAGS) -c $<

# as the geometry module has a reduction clause declaration, we define separately its rule with the needed openmp flag
geometry_omp.o: geometry.f90
	$(FC) $(FCFLAGS) $(OPENMPFLAG) -c $< -o $@

# rule for the compilation of the random ic generator
random_sphere.o: random_sphere.f90
	$(FC) $(FCFLAGS) -c $<

# dedicating a separate rule for openmp executable (non-matching names)
ex1_omp.o: ex1.f90
	$(FC) $(FCFLAGS) $(OPENMPFLAG) -c $< -o $@

# adding manually the extra dependencies that some object files need
geometry.o: kinds.o
geometry_omp.o: kinds.o
particle.o: kinds.o geometry.o 

# .PHONY target makes sure that all and clean can always be run even if files with same name exist
.PHONY: all clean

# cleaning command for produced executables, modules and output file
clean:
	rm -f *.o *.mod ex1 ex1_omp random_sphere output*.dat sphere_*.dat

