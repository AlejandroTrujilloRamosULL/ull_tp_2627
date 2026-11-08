! Program to contain a module to import for the utilization of 32 or 64 bit reals, depending on the preference of the user
! defined by the single precision parameter "sp" or the double precision parameter "dp"

module kinds
    use iso_fortran_env, only: real32, real64
    implicit none

    integer, parameter :: sp = real32
    integer, parameter :: dp = real64

end module kinds