! Program to contain the module for the operations that are going to be done for the leapfrog project or first scored exercise
! Here we are going to define the operations between what we call points (point3d) (positions) and vectors (vector3d) (velocities and accelerations)
! The addition and subtraction operations between a position and a vector yields a point
! The operation of subtraction between points yields a vector (definition of a vector, difference between two points)
! but the addition between points yields nothing with physical significance (that is why we define these derived types and their operations)

module geometry
    use kinds, only: dp ! importing the kinds module for dp usage
    implicit none

    type :: vector3d
        real(kind=dp) :: x, y, z
    end type

    type :: point3d
        real(kind=dp) :: x, y, z
    end type

    ! we are defining here the operations between points, vectors and reals (we use operator overloading for our defined derived types)
    interface operator(+)
        module procedure sumvp, sumpv, sumvv
    end interface

    interface operator(-)
        module procedure subpv, subpp, subvv
    end interface

    interface operator(*)
        module procedure mulrv, mulvr
    end interface

    interface operator(/)
        module procedure divvr
    end interface

    ! declaring a custom OpenMP reduction clause for vector3d derived types so reduction(+:a) in main program works on arrays of vector3d types
    ! see (https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2023-0/declare-reduction.html) 
    ! for more information on definition and arguments of declaration
    !$omp declare reduction (+:vector3d:omp_out = omp_out + omp_in) &
    !$omp& initializer(omp_priv = vector3d(0.0_dp, 0.0_dp, 0.0_dp))

contains

    ! we make the operations with the derived types with elemental functions so it can handle and apply operations in arrays element by element

    elemental type(point3d) function sumvp(v, p)
    !! function to sum vector and point yielding a point 

        !! arguments
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)
        type(point3d), intent(in) :: p
        !! (in) point triplet (x, y, z)

        sumvp = point3d(v%x + p%x, v%y + p%y, v%z + p%z)
    end function sumvp

    elemental type(point3d) function sumpv(p, v)
    !! function to sum vector and point yielding a point 

        !! arguments
         type(point3d), intent(in) :: p
        !! (in) point triplet (x, y, z)
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)

        sumpv = point3d(p%x + v%x, p%y + v%y, p%z + v%z)
    end function sumpv

    elemental type(vector3d) function sumvv(v, w)
    !! function to sum two vectors yielding a vector
        
        !! arguments
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)
        type(vector3d), intent(in) :: w
        !! (in) vector triplet (x, y, z)

        sumvv = vector3d(v%x + w%x, v%y + w%y, v%z + w%z)
    end function sumvv 

    elemental type(point3d) function subpv(p, v)
    !! function to subtract point and vector yielding a point

        !! arguments
        type(point3d), intent(in) :: p
        !! (in) point triplet (x, y, z)
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)

        subpv = point3d(p%x - v%x, p%y - v%y, p%z - v%z)
    end function subpv

    elemental type(vector3d) function subpp(p1, p2)
    !! function to subtract two points yielding a vector

        !! arguments
        type(point3d), intent(in) :: p1
        !! (in) point triplet (x, y, z)
        type(point3d), intent(in) :: p2
        !! (in) point triplet (x, y, z)

        subpp = vector3d(p1%x - p2%x, p1%y - p2%y, p1%z - p2%z)
    end function subpp

    elemental type(vector3d) function subvv(v, w)
    !! function to subtract two vectors yielding a vector

        !! arguments
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)
        type(vector3d), intent(in) :: w
        !! (in) vector triplet (x, y, z)

        subvv = vector3d(v%x - w%x, v%y - w%y, v%z - w%z)
    end function subvv

    elemental type(vector3d) function mulrv(r, v)
    !! function to take the product of a real and a vector yielding a vector scaled by the real

        !! arguments
        real(kind=dp), intent(in) :: r
        !! (in) real number (double precision)
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)

        mulrv = vector3d(r*v%x, r*v%y, r*v%z)
    end function mulrv

    elemental type(vector3d) function mulvr(v, r)
    !! function to take the product of a real and a vector yielding a vector scaled by the real

        !! arguments
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)
        real(kind=dp), intent(in) :: r
        !! (in) real number (double precision)

        mulvr = vector3d(r*v%x, r*v%y, r*v%z)
    end function mulvr 

    elemental type(vector3d) function divvr(v, r)
    !! fuction to divide a vector by a real number yielding a vector scaled by the inverse of the real

        !! arguments
        type(vector3d), intent(in) :: v
        !! (in) vector triplet (x, y, z)
        real(kind=dp), intent(in) :: r
        !! (in) real number (double precision)

        divvr = vector3d(v%x/r, v%y/r, v%z/r)
    end function divvr

    real(kind=dp) function distance(p1, p2) result(d)
    !! function to calculate the distance between two points p1 and p2

        !! arguments
        type(point3d), intent(in) :: p1
        !! (in) point triplet (x1, y1, z1)
        type(point3d), intent(in) :: p2
        !! (in) point triplet (x2, y2, z2)

        d = sqrt((p2%x - p1%x)**2 + (p2%y - p1%y)**2 + (p2%z - p1%z)**2)
    end function distance


end module geometry