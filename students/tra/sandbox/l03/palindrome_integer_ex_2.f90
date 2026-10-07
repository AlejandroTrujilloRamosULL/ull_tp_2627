! Program to check if an integer is a palindrome, so whether if the number can be read the same forwards as backwards

program palindrome

    implicit none
    character(len=:), allocatable :: integer_str
    integer :: integer_str_size, all_stat, i, counter, idx

    ! here we ask the user to input the integer number to be checked and see if it is a palindrome
    write (*, "(a)") "Enter the extent of the integer (how many numbers it has): "
    read (*, *) integer_str_size

    ! allocating the dynamic string
    allocate(character(len=integer_str_size) :: integer_str, stat=all_stat)
    if (all_stat>0) stop "Dynamic string could not be allocated."

    ! here we ask the user to input the integer number to be checked and see if it is a palindrome
    write (*, "(a)") "Enter the integer number: "
    read (*, *) integer_str

    ! loop to see if the length of the integer string is even or odd and act accordingly
    counter = 0
    if (mod(integer_str_size, 2)==0) then ! even case
        do i=1, integer_str_size/2
            idx = integer_str_size - i + 1 ! index to begin from last element and check the right half of the integer
            if (integer_str(i:i)==integer_str(idx:idx)) then ! checking respective elements forwards from the left and backwards from the right
                counter = counter + 1 ! the respective pair is equal, increase the counter
            end if
        end do
        if (counter==integer_str_size/2) then ! if all pairs considered are equal we have a palindrome
            print *
            print *, "Your integer is a palindrome."
         else 
            print *
            print *, "Your integer is not a palindrome."
        end if
    else ! odd case
        do i=1, int(real(integer_str_size)/2.0) ! rounding down is necessary as for an odd palindrome number its central number is not important
            idx = integer_str_size - i + 1 ! index to begin from last element and check the right half of the integer
            if (integer_str(i:i)==integer_str(idx:idx)) then ! checking respective elements forwards from the left and backwards from the right
                counter = counter + 1 ! the respective pair is equal, increase the counter
            end if
        end do
        if (counter==int(integer_str_size/2)) then ! if all pairs considered are equal we have a palindrome
            print *
            print *, "Your integer is a palindrome."
        else 
            print *
            print *, "Your integer is not a palindrome."
        end if
    end if

end program palindrome