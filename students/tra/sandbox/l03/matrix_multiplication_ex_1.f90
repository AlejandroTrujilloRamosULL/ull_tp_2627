! Program to calculate the matrix multiplication of two real arrays and prints the result

program mat_mul

    implicit none
    integer :: nrows_1, ncolumns_1, nrows_2, ncolumns_2, all_stat_1, all_stat_2
    real, dimension(:, :), allocatable :: array_1, array_2

    ! asking the user for the shape of the array and the elements within it
    write (*, "(a)") "Enter the number of rows and columns of array 1: "
    read (*, *) nrows_1, ncolumns_1

    write (*, "(a)") "Enter the number of rows and columns of array 2: "
    read (*, *) nrows_2, ncolumns_2

    ! here we set the matrix multiplication and declare the conditions the matrices must verify to be able to 
    ! be multiplied between them
    if (ncolumns_1/=nrows_2) then
        stop "Number of rows of second matrix must be equal to number of colums of first matrix." 
    end if

    ! allocating the array to have the shape and size that the user prefers
    allocate(array_1(nrows_1, ncolumns_1), stat=all_stat_1)
    if (all_stat_1>0) stop "The allocation of array_1 was not succesful. Try again."
    
    allocate(array_2(nrows_2, ncolumns_2), stat=all_stat_2)
    if (all_stat_2>0) stop "The allocation of array_2 was not succesful. Try again."

    ! asking the user to input the elements he/she wishes to be inside the array
    write (*, "(a)") "Enter the elements of array 1 (remember it is column-major order, so a11, a21, ...): "
    read (*, *) array_1

    write (*, "(a)") "Enter the elements of array 2 (remember it is column-major order, so a11, a21 ...): "
    read (*, *) array_2

    ! printing the arrays to be multiplied
    print *
    print *, "Matrices to take the product of: "
    print *, array_1
    print *
    print *, array_2

    ! output
    print *
    print *, "Resulting matrix from the product: "
    print *, matmul(array_1, array_2)

    ! deallocating the arrays
    deallocate(array_1)
    deallocate(array_2)


end program mat_mul