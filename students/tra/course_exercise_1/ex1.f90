! Main program of first scored exercise

! In this program we are going to modify the leapfrog.f90 source code to make it compatible with the use of the geometry and particle modules where
! we have defined our vector and point types and the operations between them and with real numbers

! The leapfrog scheme ... (finish)
! I NEED TO ADD A SOFTENING LENGTH (MAYBE)

! ADDITION (work in progress): We have also added as an extra task an improvement on the method, with the contribution 
! from Haruo Yoshida with his upgrade on the accuracy of symplectic integrators 
! (Yoshida's contribution is of 4th order, compared to the 2nd order leapfrog method)
! The method is selected at the command line (second, optional argument): "leapfrog" (default) or "yoshida"
! see (https://en.wikipedia.org/wiki/Leapfrog_integration)

! =====================================================================
! Reference for the Yoshida 4th-Order Symplectic Integrator:
! Author: Haruo Yoshida
! Title:  "Construction of higher order symplectic integrators"
! Journal: Physics Letters A, Volume 150, Issues 5-7, 1990, Pages 262-268
! DOI: https://doi.org/10.1016/0375-9601(90)90092-3
! =====================================================================

program leapfrog
    !$ use omp_lib
    use kinds, only: dp
    use iso_fortran_env, only: error_unit
    use geometry
    use particle
    implicit none

    real(kind=dp) :: dt, dt_out, t_end
    !$ real(kind=dp) :: t_start, t_final
    integer :: u, w, n, i, step, n_steps, out_every, all_stat_m, all_stat_r, all_stat_v, all_stat_a, open_status, open_status_out
    character(len=256) :: file_name, output_file_name
    character(len=32) :: method
    character(len=*), parameter :: fmt = "(*(3f12.8))"
    logical :: found

    ! OWN ADDITION: Yoshida 4th-order coefficients (see reference above for values and definitions)
    real(kind=dp) :: w0, w1
    real(kind=dp), dimension(4) :: c_yoshida
    real(kind=dp), dimension(3) :: d_yoshida

    real(kind=dp), dimension(:), allocatable :: m      ! mass
    type(point3d), dimension(:), allocatable :: r      ! position
    type(vector3d), dimension(:), allocatable :: v, a  ! velocity, acceleration

    ! firstly we set the calling of arguments for the command line calling
    ! OWN ADDITION: the method (leapfrog or yoshida) is now an optional 2nd argument leapfrog
    if (command_argument_count() < 1 .or. command_argument_count() > 2) then
        print *, "Usage: ./leapfrog <input_file> [method]"
        print *, " Integration method is optional: 'leapfrog' (set by default if no method is defined) or 'yoshida'"
        stop "Command line is not correctly written. & 
              & Try again adding the input file name as an argument in the command line as shown above."
    end if

    call get_command_argument(1, file_name)
    print *, "Reading ", trim(file_name) 

    method = "leapfrog" ! default method if none is given
    if (command_argument_count() == 2) then ! case of two arguments (if an integration method is given)
        call get_command_argument(2, method)
    end if

    if (trim(method) /= "leapfrog" .and. trim(method) /= "yoshida") then
        write (error_unit, "(a)") "Error: method must be 'leapfrog' or 'yoshida'."
        stop "Try again."
    end if
    print *, "Using method: ", trim(method)

    ! opening of the input file
    ! see if the file exists and if not report to error_unit (constant of iso_fortran_env module)
    inquire(file=file_name, exist=found)
    if (.not. found) then
        write (error_unit, "(a)") "Error: input file was not found."
        stop "Try again."
    else
        print *, "Found input file."
    end if

    ! opening the input file to retrieve the parameters
    open(newunit=u, file=file_name, action="read", iostat=open_status)
    if (open_status /= 0) stop "The opening of the input file was not successful."

    ! reading the first 4 arguments from the input data to set up the method
    read (u, *) dt
    read (u, *) dt_out
    read (u, *) t_end
    read (u, *) n

    ! allocation of the arrays that define the particle's mass, positions and velocities (as we now know the number of particles n)
    allocate(m(n), stat=all_stat_m)
    if (all_stat_m /= 0) stop "Allocation of mass array was unsuccesful."
    allocate(r(n), stat=all_stat_r)
    if (all_stat_r /= 0) stop "Allocation of positions array was unsuccesful."
    allocate(v(n), stat=all_stat_v)
    if (all_stat_v /= 0) stop "Allocation of velocities array was unsuccesful."
    allocate(a(n), stat=all_stat_a)
    if (all_stat_a /= 0) stop "Allocation of accelerations array was unsuccesful."

    ! now we read from the file the characteristics of the n particles, mass, positions and velocities (m, x, y, z, vx, vy, vz)
    do i=1, n
        read (u, *) m(i), r(i)%x, r(i)%y, r(i)%z, v(i)%x, v(i)%y, v(i)%z
    end do

    close(u) ! closing of the input file

    ! here we retrieve the number of steps and the time an output is printed (not all outputs are printed)
    n_steps = nint(t_end/dt) ! rounding to the nearest integer the quotient between (total time)/(time step) 
    out_every = max(1, nint(dt_out/dt)) ! maximum of rounding to the nearest integer the quotient between (time of printed outputs/time step) or 1

    ! OWN ADDITION: Yoshida 4th-order coefficients, computed once before the step loop (see the values in the reference paper or the Wiki page attached)
    w0 = -(2.0_dp**(1.0_dp/3.0_dp)) / (2.0_dp - 2.0_dp**(1.0_dp/3.0_dp))
    w1 = 1.0_dp / (2.0_dp - 2.0_dp**(1.0_dp/3.0_dp))
    c_yoshida = [w1/2.0_dp, (w0+w1)/2.0_dp, (w0+w1)/2.0_dp, w1/2.0_dp]
    d_yoshida = [w1, w0, w1]

    ! here we calculate the initial accelerations to use at the first step of the integration, which at posterior steps will be updated
    ! for parallelization we will use a reduction clause to avoid a race condition from happening
    ! also we are scheduling dynamically as iterations over pairs are uneven in workload (first iterations work more than others)
    ! we defined a subroutine below as Yoshida's method uses the loop various times
    call accelerations(r, m, n, a)

    ! we create an output file where the results can be written inside it
    write(unit=output_file_name, fmt="(a)") "output.dat" ! CAREFUL as it is overwritten if ran with and without openmp
    open(newunit=w, file=output_file_name, form="formatted", action="write", status="replace", iostat=open_status_out)
    if (open_status_out /= 0) stop "The creating and writing of the output file was not successful."

    !$ t_start = omp_get_wtime()
    ! here we implement the chosen integration method
    if (trim(method) == "leapfrog") then
        do step=1, n_steps
            v = v + a*dt/2.0_dp ! kick
            r = r + v*dt        ! drift
            call compute_accelerations(r, m, n, a)
            v = v + a*dt/2.0_dp ! kick

            ! storing in an output.dat file the time and positions of the planets as (t, p1x, p1y, p1z, ..., pnx, pny, pnz) where p indicates planet
            if (mod(step, out_every)==0) then
                write (w, "(f12.6)", advance="no") step*dt
                do i=1, n
                    if (i==n) then
                        write (w, fmt) r(i)%x, r(i)%y, r(i)%z
                    else 
                        write (w, fmt, advance="no") r(i)%x, r(i)%y, r(i)%z
                    end if
                end do
            end if
        end do
    else ! yoshida method
        do step=1, n_steps
            ! OWN ADDITION: Yoshida 4th-order method
            r = r + c_yoshida(1)*v*dt ! drift
            call accelerations(r, m, n, a)
            v = v + d_yoshida(1)*a*dt ! kick

            r = r + c_yoshida(2)*v*dt ! drift
            call accelerations(r, m, n, a)
            v = v + d_yoshida(2)*a*dt ! kick

            r = r + c_yoshida(3)*v*dt ! drift
            call accelerations(r, m, n, a)
            v = v + d_yoshida(3)*a*dt ! kick

            r = r + c_yoshida(4)*v*dt ! drift

            ! storing in an output.dat file the time and positions of the planets as (t, p1x, p1y, p1z, ..., pnx, pny, pnz) where p indicates particle
            if (mod(step, out_every)==0) then
                write (w, "(f12.6)", advance="no") step*dt
                do i=1, n
                    if (i==n) then
                        write (w, fmt) r(i)%x, r(i)%y, r(i)%z
                    else 
                        write (w, fmt, advance="no") r(i)%x, r(i)%y, r(i)%z
                    end if
                end do
            end if
        end do
    end if
    !$ t_final = omp_get_wtime()
    !$ print *, "The total run time (wall-clock time) is of: ", t_final - t_start, " seconds."

    close(w) ! closing the output file

contains

    subroutine accelerations(r_sub, m_sub, n_sub, a_sub)
    !! subroutine to calculate the accelerations between every pair of particles i and j
    !! for parallelization we will use a reduction clause to avoid a race condition from happening
    !! also we are scheduling dynamically as iterations over pairs are uneven in workload (first iterations work more than others)

        !! arguments
        type(point3d), dimension(:), intent(in) :: r_sub
        !! (in) positions of the n particles
        real(kind=dp), dimension(:), intent(in) :: m_sub
        !! (in) masses of the n particles
        integer, intent(in) :: n_sub
        !! (in) number of particles
        type(vector3d), dimension(:), intent(out) :: a_sub
        !! (out) accelerations of the n particles

        !! local variables
        integer :: ii, jj
        real(kind=dp) :: dist, dist3
        type(vector3d) :: rji_sub

        a_sub%x = 0.0_dp
        a_sub%y = 0.0_dp
        a_sub%z = 0.0_dp
        !$omp parallel do reduction(+:a_sub) schedule(dynamic) private(jj, rji_sub, dist, dist3)
        do ii=1, n_sub
            do jj=ii+1, n_sub
                rji_sub = r_sub(jj) - r_sub(ii) 
                dist = distance(r_sub(jj), r_sub(ii)) 
                dist3 = dist**3
                a_sub(ii) = a_sub(ii) + m_sub(jj)*rji_sub/dist3
                a_sub(jj) = a_sub(jj) - m_sub(ii)*rji_sub/dist3
            end do
        end do
        !$omp end parallel do

    end subroutine accelerations

end program leapfrog