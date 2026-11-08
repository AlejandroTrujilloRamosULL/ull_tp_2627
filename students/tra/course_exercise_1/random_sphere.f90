! Creates the initial conditions for an N-body simulation: n particles
! with equal masses (total mass 1) at random positions inside a sphere of
! radius 1, all at rest. The output has the same format as input.dat, so
! it can be given directly to the simulation:
!
!   gfortran -o random_sphere random_sphere.f90
!   ./random_sphere 1000 > sphere_1000.dat
!   ./random_sphere 1000 42 > sphere_1000.dat
!
! The optional second argument is a seed for the random number generator.
! The same seed always gives the same particles, which is useful when you
! compare the run times of different versions of a program. Without a
! seed, every run gives different particles.
!
! The first three lines (dt, dt_out, and t_end) are only suggestions:
! edit them in the output file as needed.

program random_sphere
  use iso_fortran_env, only: real64, error_unit
  implicit none
  integer, parameter :: dp = real64
  ! OWN COMMENT: dt_out changed to equal t_end for benchmarking of the timing of the run with multiple threads so I/O handling does not dominate
  real(dp), parameter :: dt = 0.001_dp, dt_out = 0.1_dp, t_end = 0.1_dp
  character(len=32) :: arg
  integer, allocatable :: seed(:)
  integer :: n, user_seed, seed_size, ios, i
  real(dp) :: r(3)

  if (command_argument_count() < 1 .or. command_argument_count() > 2) then
    write(error_unit, '(a)') 'Usage: ./random_sphere <number of particles> [seed]'
    stop 1
  end if

  call get_command_argument(1, arg)
  read(arg, *, iostat=ios) n
  if (ios /= 0 .or. n < 1) then
    write(error_unit, '(a)') 'The number of particles must be a positive integer.'
    stop 1
  end if

  if (command_argument_count() == 2) then
    call get_command_argument(2, arg)
    read(arg, *, iostat=ios) user_seed
    if (ios /= 0) then
      write(error_unit, '(a)') 'The seed must be an integer.'
      stop 1
    end if
    call random_seed(size=seed_size)
    allocate(seed(seed_size))
    seed = user_seed + 37 * [(i, i = 1, seed_size)]
    call random_seed(put=seed)
  else
    call random_seed()
  end if

  print '(f8.5)', dt
  print '(f8.5)', dt_out
  print '(f8.5)', t_end
  print '(i0)', n

  do i = 1, n
    ! Draw points uniformly in the cube [-1, 1]^3 until one is inside the
    ! sphere. This keeps the distribution uniform inside the sphere.
    do
      call random_number(r)
      r = 2 * r - 1
      if (sum(r**2) < 1) exit
    end do
    print '(7(es23.15, 1x))', 1.0_dp / n, r, 0.0_dp, 0.0_dp, 0.0_dp
  end do
end program random_sphere
