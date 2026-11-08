! Program to create a derived type particle that contains its mass, positions and velocity in 3d 
! That is the format that is used in the input file (input.dat) m, x, y, z, vx, vy, vz
! We are importing the geometry module where the derived types of points and vectors and their operations are defined 

module particle
    use kinds, only: dp
    use geometry
    implicit none

    type particle3d
        real(kind=dp) :: m  ! mass (double precision)
        type(point3d) :: p  ! point triplet (x, y, z)
        type(vector3d) :: v ! vector triplet (x, y, z)
    end type

end module particle